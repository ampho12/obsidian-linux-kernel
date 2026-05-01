We want to package:

1. kernel
2. rootfs
3. kernel

# Login

We need to make sure the same hashes are for passwd

| Daemon / Tool             | How password checking works                                                                 | Library used                  | Sensitive to `libxcrypt` mismatch? |
| ------------------------- | ------------------------------------------------------------------------------------------- | ----------------------------- | ---------------------------------- |
| **BusyBox login / getty** | Parses `/etc/passwd` + `/etc/shadow` itself; uses its own built-in SHA-crypt implementation | None (internal BusyBox code)  | ❌ No                               |
| **Dropbear**              | Has its *own* `crypt()` fallback in-tree; never calls glibc’s `crypt()`                     | None (internal Dropbear code) | ❌ No                               |
| **OpenSSH (sshd)**        | Calls the system's `crypt()` via `libcrypt.so` to verify hashes from `/etc/shadow`          | `libxcrypt` / glibc plugin    | ✅ Yes                              |

Need this setup:

```
/etc/passwd (with x indicating use /etc/shadow for passwd)
/etc/shadow
/etc/nsswitch.conf : use local / ldap for checking login
/etc/group group config (needs sshd for sshd)
/etc/shells # needed for valid shells
```

passwd- and shadow- are backups, if something goes wrong:

```
cp /etc/passwd- /etc/passwd
cp /etc/shadow- /etc/shadow
```

## Initrd/Initramfs

Initramfs is the modern version, but many people still refer to it as initrd.

1. BIOS/UEFI firmware
   ↓
2. GRUB (bootloader)
   - Reads /boot partition
   - Loads kernel (vmlinuz) into RAM
   - Loads initrd into RAM (see below)
   - Passes command line: "root=/dev/vda console=ttyAMA0 ..."
   - Jumps to kernel entry point
   ↓
3. Kernel starts executing
   - Initializes CPU, memory, drivers
   - Unpacks initrd into a RAM-based filesystem (tmpfs)
   - Kernel executes /init FROM THE INITRD (in RAM)
   ↓
4. initrd's /init script runs
   - Parses kernel command line (looks for "root=...")
   - Loads necessary kernel modules (virtio_blk, ext4, etc.)
   - Searches for the root device (/dev/vda)
   - Mounts root device to /mnt-root
   - Does switch_root to /mnt-root
   ↓
5. Real root filesystem's /init starts (usually systemd)
   - This is /sbin/init or /run/current-system/init on the rootfs
   - System fully boots

### System Updates copy initrd from rootfs to bootfs

Most distros have an initrd in rootfs too. Why? For system updates.

Exactly! When you enable a bootloader, you get duplicates:

#### With Bootloader Enabled

```nix
boot.loader.systemd-boot.enable = true;  # or GRUB
```

Partition layout:

/dev/sda1 → /boot (FAT32, ~500MB)
  └── loader/entries/
      ├── nixos-generation-45.conf
      └── nixos-generation-44.conf
  └── EFI/
      └── nixos/
          ├── kernel-abc123.efi          # COPY of kernel gen 45
          ├── initrd-def456.efi          # COPY of initrd gen 45
          ├── kernel-xyz789.efi          # COPY of kernel gen 44
          └── initrd-uvw012.efi          # COPY of initrd gen 44

/dev/sda2 → / (ext4, rest of disk)
  └── nix/store/
      ├── abc123-linux-6.6.116/Image     # ORIGINAL kernel gen 45
      ├── def456-initrd-6.6.116/initrd   # ORIGINAL initrd gen 45
      ├── xyz789-linux-6.6.115/Image     # ORIGINAL kernel gen 44
      └── uvw012-initrd-6.6.115/initrd   # ORIGINAL initrd gen 44
```

#### Why the Duplication?

1. /boot must be bootloader-friendly:
   - UEFI firmware can only read FAT32
   - GRUB may not support ZFS/Btrfs easily
   - /boot is kept simple and compatible

2. /nix/store is the source of truth:
   - NixOS activation script COPIES to /boot
   - If /boot gets corrupted, NixOS can rebuild it from /nix/store

3. /boot is automatically managed:
   ```bash
   nixos-rebuild switch
   # → Builds new generation in /nix/store
   # → Copies kernel/initrd to /boot
   # → Updates bootloader entries
   ```

### Grub to Kernel Handoff

#### On x86/x86_64:

1. GRUB loads kernel to memory address X
2. GRUB loads initrd to memory address Y
3. GRUB fills in a "boot_params" structure:
   - boot_params.initrd_addr_max = address Y
   - boot_params.initrd_size = size in bytes
4. GRUB jumps to kernel with pointer to boot_params

#### On ARM/aarch64 (like our case):

1. GRUB loads kernel to memory
2. GRUB loads initrd to memory
3. GRUB updates the Device Tree Blob (DTB):
   - /chosen/linux,initrd-start = address
   - /chosen/linux,initrd-end = address + size
4. GRUB jumps to kernel with pointer to DTB

The kernel reads the boot_params (x86) or DTB (ARM) to find where the initrd is in RAM.

#### x86/x86_64 Architecture

When GRUB jumps to the kernel:

```asm
; GRUB sets up:
mov esi, [address_of_boot_params]   ; ESI/RSI = pointer to boot_params
jmp kernel_entry_point              ; Jump to kernel

; Kernel entry point expects:
; ESI/RSI = pointer to boot_params structure
```

The kernel's entry point (in arch/x86/boot/header.S) reads the ESI/RSI register.

#### ARM/aarch64 Architecture (our case!)

When GRUB/U-Boot/QEMU jumps to the kernel:

```asm
; Set up registers according to Linux ARM boot protocol:
mov x0, [dtb_physical_address]  ; x0 = pointer to DTB
mov x1, #0                      ; x1 = 0 (reserved, was machine type)
mov x2, #0                      ; x2 = 0 (reserved, was atags)
mov x3, #0                      ; x3 = 0 (reserved)
br  kernel_entry_point          ; Branch to kernel
```

The kernel's entry point (in arch/arm64/kernel/head.S) reads the x0 register to find the DTB.

### Qemu Case

Qemu doesn't use the boot partition anyway so it cannot load the bootloader from there. It has its own bootloader.

Qemu emulates this process, e.g.

#### In QEMU's Case

When you run `qemu-system-aarch64 -kernel ... -initrd ...`:

```c
// Pseudocode of what QEMU does internally:
void qemu_boot_kernel() {
    // Load kernel to guest RAM at 0x40080000
    load_image("kernel.img", 0x40080000);

    // Load initrd to guest RAM at 0x44000000
    load_image("initrd.img", 0x44000000);

    // Create/modify DTB
    dtb = create_device_tree();
    fdt_setprop_u64(dtb, "/chosen", "linux,initrd-start", 0x44000000);
    fdt_setprop_u64(dtb, "/chosen", "linux,initrd-end", 0x44000000 + initrd_size);

    // Place DTB at 0x43000000
    load_dtb(dtb, 0x43000000);

    // Set up virtual CPU registers
    vcpu->regs[0] = 0x43000000;  // x0 = DTB address
    vcpu->regs[1] = 0;           // x1 = 0
    vcpu->regs[2] = 0;           // x2 = 0
    vcpu->regs[3] = 0;           // x3 = 0
    vcpu->pc = 0x40080000;       // PC = kernel entry

    // Start the guest CPU
    run_vcpu(vcpu);
}
```

**TL;DR:** The pointer is passed in CPU register x0 (aarch64) or ESI/RSI (x86) according to the architecture's boot protocol specification.

# FAQ

```
[    2.487110] PM: genpd: Disabling unused power domains
[    2.516565] EXT4-fs (mmcblk0p2): mounted filesystem 44444444-4444-4444-8888-888888888888 r/w with ordered data mode. Quota mode: none.
[    2.530642] VFS: Mounted root (ext4 filesystem) on device 179:2.
[    2.536936] devtmpfs: error mounting -2
[    2.542059] Freeing unused kernel memory: 2304K
[    2.546675] Run /run/current-system/init as init process
[    2.552026] Kernel panic - not syncing: Requested init /run/current-system/init failed (error -2).
[    2.561021] CPU: 1 UID: 0 PID: 1 Comm: swapper/0 Not tainted 6.12.47-v8-16k #1-NixOS
[    2.568795] Hardware name: Raspberry Pi 5 Model B Rev 1.0 (DT)
[    2.574646] Call trace:
[    2.577093]  dump_backtrace.part.0+0xe0/0x100
[    2.581469]  show_stack+0x20/0x40
[    2.584789]  dump_stack_lvl+0x60/0x80
[    2.588460]  dump_stack+0x18/0x28
[    2.591781]  panic+0x170/0x370
[    2.594842]  kernel_init+0xf0/0x150
[    2.598340]  ret_from_fork+0x10/0x20
[    2.601925] SMP: stopping secondary CPUs
[    2.605859] Kernel Offset: 0x106f4e400000 from 0xffffc00080000000
[    2.611972] PHYS_OFFSET: 0x0
[    2.614855] CPU features: 0x10,00000017,00280928,0200720b
[    2.620271] Memory Limit: none
[    2.623333] ---[ end Kernel panic - not syncing: Requested init /run/current-system/init failed (error -2). ]---
```

`-2` means not found

Check if services come up on boot:

```
[root@nixos:~]# ls -la /etc/systemd/system/multi-user.target.wants/
total 16
dr-xr-xr-x  2 root root  4096 Jan  1  1970 .
dr-xr-xr-x 57 root root 12288 Jan  1  1970 ..
lrwxrwxrwx  1 root root    17 Jan  1  1970 dhcpcd.service -> ../dhcpcd.service
lrwxrwxrwx  1 root root    15 Jan  1  1970 getty.target -> ../getty.target
lrwxrwxrwx  1 root root    30 Jan  1  1970 logrotate-checkconf.service -> ../logrotate-checkconf.service
lrwxrwxrwx  1 root root    24 Jan  1  1970 network-setup.service -> ../network-setup.service
lrwxrwxrwx  1 root root    40 Jan  1  1970 reload-systemd-vconsole-setup.service -> ../reload-systemd-vconsole-setup.service
lrwxrwxrwx  1 root root    19 Jan  1  1970 remote-fs.target -> ../remote-fs.target
lrwxrwxrwx  1 root root    21 Jan  1  1970 resolvconf.service -> ../resolvconf.service
lrwxrwxrwx  1 root root    15 Jan  1  1970 sshd.service -> ../sshd.service
lrwxrwxrwx  1 root root    33 Jan  1  1970 systemd-ask-password-wall.path -> ../systemd-ask-password-wall.path
lrwxrwxrwx  1 root root    25 Jan  1  1970 systemd-logind.service -> ../systemd-logind.service
lrwxrwxrwx  1 root root    31 Jan  1  1970 systemd-modules-load.service -> ../systemd-modules-load.service
lrwxrwxrwx  1 root root    23 Jan  1  1970 systemd-oomd.service -> ../systemd-oomd.service
lrwxrwxrwx  1 root root    25 Jan  1  1970 systemd-sysctl.service -> ../systemd-sysctl.service
lrwxrwxrwx  1 root root    32 Jan  1  1970 systemd-user-sessions.service -> ../systemd-user-sessions.service
lrwxrwxrwx  1 root root    25 Jan  1  1970 wpa_supplicant.service -> ../wpa_supplicant.service

[root@nixos:~]# ls -la /etc/systemd/system/multi-user.target.wants/ | grep -E 'polkit|dbus'

```


```
[root@nixos:~]# ls -la /etc/systemd/system/ | grep polkit
lrwxrwxrwx   1 root root     114 Jan  1  1970 polkit.service -> /nix/store/p3rfrrlmcffhpqs3aqrz1jq1ahmjjadv-polkit-aarch64-unknown-linux-gnu-126/lib/systemd/system/polkit.service
dr-xr-xr-x   2 root root    4096 Jan  1  1970 polkit.service.d

[root@nixos:~]# ls -la /etc/systemd/system/ | grep dbu
lrwxrwxrwx   1 root root      12 Jan  1  1970 dbus-broker.service -> dbus.service
lrwxrwxrwx   1 root root      25 Jan  1  1970 dbus-org.freedesktop.hostname1.service -> systemd-hostnamed.service
lrwxrwxrwx   1 root root      23 Jan  1  1970 dbus-org.freedesktop.import1.service -> systemd-importd.
```

Some services are socket activated:

```
[root@nixos:~]# ls -la /etc/systemd/system/sockets.target.wants/ | grep polkit

[root@nixos:~]#
```


## Remote deployment issues

1. After flashing sd image reboot once (don't know why)
2. Make sure arm64 emulation is enabled (sudo apt install or in nixos)
3. Make sure that dbus is running. It should come online on boot: `systemctl status dbus`

Polkit and dbus need to be enabled.

Polkit is activated via dbus so dbus should be active.

## DTBs

### NixOS uses a BUILD-TIME merge approach:

1. Compilation: Your DTS text (in hardware.deviceTree.overlays) is compiled to .dtbo format using dtc (device tree compiler)
2. Merging: NixOS then merges the overlays directly into the base DTB files using libfdt.fdt_overlay_apply() - this creates modified DTB files, NOT separate .dtbo files
3. Storage: The modified DTBs are stored in hardware.deviceTree.package in the Nix store
4. Deployment: Boot scripts should copy these merged DTBs to /boot

This is different from Raspberry Pi's standard approach, which uses:
- Separate .dtbo files in /boot/overlays/
- dtoverlay= directives in config.txt
- Firmware applies overlays at boot time

#### Standard Raspberry Pi Approach (Runtime Overlay Application)

```
/boot/
├── bcm2712-rpi-5-b.dtb          ← Base DTB
├── overlays/
│   ├── mcp2515-can0.dtbo        ← Separate overlay file
│   └── mcp2515-can1.dtbo        ← Separate overlay file
└── config.txt                    ← Says "dtoverlay=mcp2515-can0"
```

At boot time, the firmware:
1. Loads base DTB
2. Applies overlays listed in config.txt
3. Gives merged result to kernel

#### NixOS Approach (Build-Time Overlay Merging)

NixOS merges overlays at build time and outputs only merged DTB files (no separate .dtbo files):

```
hardware.deviceTree.package/
└── broadcom/
    └── bcm2712-rpi-5-b.dtb      ← Already has overlays merged in
```

#### Why Your Overlays Aren't Working

The Problem: Your boot scripts are copying the wrong DTBs to /boot.

Looking at the build output, your overlays ARE being compiled and merged:
- Kernel DTBs (original): 77K
- Device Tree Package (with overlays): 78K ✓

But your scripts copy from:
- `${config.boot.kernelPackages.kernel}/dtbs` ← vanilla DTBs without overlays

Instead of:
- `${config.hardware.deviceTree.package}` ← merged DTBs with overlays

So the Pi boots with the original DTBs and never sees your MCP2515 configuration!

#### The Fix

Need to update two files to copy the correct DTBs:
  ⎿  User rejected Claude's plan:
     ╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
     │ Plan: Fix Device Tree Overlay Deployment                                                                                              │
     │                                                                                                                                       │
     │ 1. Update SD image boot script                                                                                                        │
     │                                                                                                                                       │
     │ File: formats/sd-image.nix                                                                                                            │
     │ - Change line 65 from KERNEL_DTBS="${config.boot.kernelPackages.kernel}/dtbs"                                                         │
     │ - To: KERNEL_DTBS="${config.hardware.deviceTree.package}"                                                                             │
     │ - This ensures the SD image gets the merged DTBs with MCP2515 overlays                                                                │
     │                                                                                                                                       │
     │ 2. Update runtime bootloader installer                                                                                                │
     │                                                                                                                                       │
     │ File: flake.nix                                                                                                                       │
     │ - Change the bootloader script (around line 340-350) to use config.hardware.deviceTree.package                                        │
     │ - This ensures nixos-rebuild switch updates use the correct DTBs                                                                      │
     │                                                                                                                                       │
     │ After these changes, rebuild the SD image and the DTBs with MCP2515 overlays will be deployed to /boot, enabling your CAN interfaces. │
     ╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

> didn't fully understand. There is a dtb binary and the overlay (dtbo). In the dtbs directory do we have both, the dtb and dtbo?

● Good question! Let me clarify the key difference:

  

 


# Differences


path chasing


# SD on PI

```
[root@nixos-sd-card:~]# readlink -f /run/current-system
/nix/store/xj9p2nlys145l9mq7sx1vx64wsir6sjc-nixos-system-nixos-sd-card-sd-card-25.11.20251108.b6a8526
```


```
❯ nix eval --raw .#nixosConfigurations.rpi.config.system.build.toplevel
warning: Git tree '/home/ampho/Documents/image1/exp1' is dirty
/nix/store/df7ipj8yrnla68xmczxxazlzi443iw2d-nixos-system-nixos-sd-card-25.11.20251108.b6a8526%                                       
```

```
❯ nix eval --json .#nixosConfigurations.rpi.config.system.nixos.tags
warning: Git tree '/home/ampho/Documents/image1/exp1' is dirty
[]
```

# Rebuild-switch