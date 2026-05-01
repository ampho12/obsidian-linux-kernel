# Linux Boot Process: x86_64 vs aarch64

## Table of Contents
1. [Traditional Boot Process](#traditional-boot-process)
2. [How Bootloaders Work](#how-bootloaders-work)
3. [How Initrd is Passed to Kernel](#how-initrd-is-passed-to-kernel)
4. [NixOS Specifics](#nixos-specifics)
5. [QEMU Direct Kernel Boot](#qemu-direct-kernel-boot)

---

## Traditional Boot Process

### Standard Boot Flow (Both Architectures)

```
1. Firmware (BIOS/UEFI)
   - Hardware initialization
   - Find boot device
   - Load bootloader
   ↓
2. Bootloader (GRUB/systemd-boot/U-Boot)
   - Read /boot partition
   - Load kernel into RAM
   - Load initrd into RAM
   - Prepare boot parameters/DTB
   - Jump to kernel entry point
   ↓
3. Kernel Execution
   - Initialize CPU, memory, drivers
   - Unpack initrd into RAM-based tmpfs
   - Execute /init from initrd (in RAM)
   ↓
4. Initrd's /init Script
   - Parse kernel command line (root=, console=, etc.)
   - Load necessary kernel modules (virtio, ext4, etc.)
   - Search for root device (e.g., /dev/vda, PARTUUID=...)
   - Mount root device to /mnt-root
   - Execute switch_root to /mnt-root
   ↓
5. Real Root's /init (usually systemd)
   - System fully boots
   - Services start
```

### Key Concepts

**Bootloader's Limited Knowledge:**
- GRUB/systemd-boot only reads `/boot` partition
- Bootloader never mounts or understands the root filesystem
- Bootloader just passes `root=/dev/sda2` as text to kernel
- The kernel/initrd figure out what that means

**Example GRUB Config:**
```
menuentry "Linux" {
    linux /vmlinuz root=/dev/sda2 console=ttyS0
    initrd /initrd.img
}
```
GRUB doesn't know what `/dev/sda2` is - it just passes this text to the kernel.

---

## How Bootloaders Work

### What GRUB Actually Does

```
Step 1: Read /boot (or EFI System Partition)
  - GRUB has drivers for: FAT32, ext2/3/4, XFS, Btrfs, etc.
  - Reads: /boot/vmlinuz, /boot/initrd.img, /boot/grub/grub.cfg

Step 2: Load Files to Memory
  - kernel → RAM address X
  - initrd → RAM address Y

Step 3: Prepare Boot Information
  - x86_64: Fill boot_params structure
  - aarch64: Update Device Tree Blob (DTB)

Step 4: Jump to Kernel
  - Set CPU registers
  - Jump to kernel entry point
  - GRUB is now gone (kernel has control)
```

### GRUB Never:
- ❌ Executes the kernel
- ❌ Executes the initrd
- ❌ Mounts the root filesystem
- ❌ Understands kernel parameters (just passes them)

GRUB is a **loader**, not an executor.

---

## How Initrd is Passed to Kernel

The initrd location is **NOT** passed via kernel command line. Instead, it uses architecture-specific boot protocols:

### x86_64 Boot Protocol

**Bootloader → Kernel Interface:**

```c
// Boot parameters structure (simplified)
struct boot_params {
    uint32_t initrd_addr_max;   // Physical address of initrd
    uint32_t initrd_size;       // Size in bytes
    char     cmdline[256];      // Kernel command line
    // ... other fields
};
```

**Register Convention:**
```asm
; When GRUB jumps to kernel:
mov esi, [address_of_boot_params]   ; ESI/RSI = pointer to boot_params
jmp kernel_entry                    ; Jump to kernel

; Kernel entry (arch/x86/boot/header.S):
; Reads ESI/RSI register to find boot_params
```

### aarch64 Boot Protocol

**Bootloader → Kernel Interface:**

Uses Device Tree Blob (DTB) format:

```dts
/ {
    chosen {
        linux,initrd-start = <0x44000000>;  // Physical address
        linux,initrd-end   = <0x45000000>;  // End address
        bootargs = "console=ttyAMA0 root=/dev/vda";
    };
};
```

**Register Convention:**
```asm
; When bootloader jumps to kernel:
mov x0, [dtb_physical_address]  ; x0 = pointer to DTB
mov x1, #0                       ; x1 = 0 (reserved)
mov x2, #0                       ; x2 = 0 (reserved)
mov x3, #0                       ; x3 = 0 (reserved)
br  kernel_entry                 ; Branch to kernel

; Kernel entry (arch/arm64/kernel/head.S):
; Reads x0 register to find DTB
```

### Summary: How Kernel Finds Initrd

| Architecture | Method | Location Info |
|--------------|--------|---------------|
| x86_64 | boot_params struct | ESI/RSI register → struct pointer |
| aarch64 | Device Tree Blob | x0 register → DTB pointer |
| Both | Physical RAM address | Initrd already loaded in RAM |

**Important:** Kernel doesn't read initrd from disk - it's already in RAM!

---

## NixOS Specifics

### Traditional Linux Distros

```
Filesystem Layout:
/boot/                              # Boot partition (FAT32/ext2)
  ├── vmlinuz-5.15.0-91            # Current kernel
  ├── initrd.img-5.15.0-91         # Current initrd
  ├── vmlinuz-5.15.0-90            # Old kernel
  ├── initrd.img-5.15.0-90         # Old initrd
  └── grub/

/                                   # Root partition
  ├── /bin, /usr, /etc, /lib
  └── /sbin/init                    # System init
```

**Why /boot exists:**
- Bootloaders need simple, compatible filesystem
- UEFI only reads FAT32
- Keep boot files separate from complex root

### NixOS Architecture

```
Filesystem Layout:
/nix/store/                                    # Everything in root partition
  ├── abc123-linux-6.6.116/
  │   ├── Image                                # Kernel (generation 45)
  │   └── modules/
  ├── def456-initrd-6.6.116/
  │   └── initrd                               # Initrd (generation 45)
  ├── xyz789-nixos-system-generation-45/
  │   ├── init -> /nix/store/.../systemd      # System init
  │   ├── kernel -> abc123-linux-6.6.116/Image
  │   ├── initrd -> def456-initrd-6.6.116/initrd
  │   └── kernel-params                        # Kernel command line
  ├── old111-linux-6.6.115/                    # Previous kernel
  ├── old222-initrd-6.6.115/                   # Previous initrd
  └── old333-nixos-system-generation-44/       # Previous generation

/run/current-system -> /nix/store/xyz789-nixos-system-generation-45/

/boot/ (optional - only if bootloader enabled)
```

**NixOS Design Principles:**

1. **Atomic Generations**
   - Each system generation = complete set of kernel + initrd + config
   - Rollback = switch symlink to previous generation
   - Multiple generations coexist safely

2. **Content-Addressed Storage**
   - Hash-based paths (abc123) prevent conflicts
   - Immutable store
   - Deduplication

3. **/boot is a Cache, Not Source of Truth**
   - Source: `/nix/store/` (on root partition)
   - Copy: `/boot/` (only if bootloader needs it)
   - Can be regenerated from /nix/store

### NixOS With Bootloader Enabled

```nix
# configuration.nix
boot.loader.systemd-boot.enable = true;  # or grub
```

**Result: Duplication**

```
/boot/                                      # FAT32 partition (~500MB)
  └── loader/entries/
      ├── nixos-generation-45.conf
      └── nixos-generation-44.conf
  └── EFI/nixos/
      ├── kernel-abc123.efi               # COPY from /nix/store
      ├── initrd-def456.efi               # COPY from /nix/store
      ├── kernel-xyz789.efi               # COPY (old generation)
      └── initrd-uvw012.efi               # COPY (old generation)

/nix/store/
  ├── abc123-linux-6.6.116/Image          # ORIGINAL
  ├── def456-initrd-6.6.116/initrd        # ORIGINAL
  └── ...
```

**Why duplication?**
- UEFI firmware can only read FAT32
- Some bootloaders can't read ext4/btrfs/zfs
- NixOS copies from /nix/store to /boot automatically

**Boot process:**
```
1. UEFI firmware → reads /boot (FAT32)
2. systemd-boot → loads kernel/initrd from /boot
3. Kernel → executes initrd's /init
4. Initrd → mounts root filesystem (ext4/btrfs/etc)
5. Switch root → /run/current-system/init (symlink to /nix/store)
```

### NixOS With Bootloader Disabled

```nix
# configuration.nix
boot.loader.grub.enable = false;
boot.loader.systemd-boot.enable = false;
boot.loader.generic-extlinux-compatible.enable = false;
```

**Result: No /boot Partition**

```
/nix/store/
  ├── abc123-linux-6.6.116/Image
  ├── def456-initrd-6.6.116/initrd
  └── xyz789-nixos-system-generation-45/
      ├── init
      ├── kernel -> /nix/store/abc123.../Image
      └── initrd -> /nix/store/def456.../initrd

/run/current-system -> /nix/store/xyz789-nixos-system-generation-45/

# No /boot directory at all!
```

**Use cases:**
1. **QEMU direct kernel boot** (our case)
   - QEMU reads kernel/initrd from host filesystem
   - No bootloader needed

2. **Network boot (PXE/iPXE)**
   - Kernel/initrd served over network
   - No local boot partition

3. **Embedded systems with U-Boot**
   - U-Boot loads kernel/initrd from custom location
   - May use SD card partition, not /boot

---

## QEMU Direct Kernel Boot

### What is Direct Kernel Boot?

QEMU can bypass bootloaders entirely and load kernel/initrd directly:

```bash
qemu-system-aarch64 \
  -kernel /path/on/host/kernel \    # Read from host filesystem!
  -initrd /path/on/host/initrd \    # Read from host filesystem!
  -append "console=ttyAMA0 root=/dev/vda" \
  -drive file=rootfs.img,if=virtio
```

### How QEMU Direct Boot Works

```
Step 1: QEMU reads files from HOST filesystem
  - kernel file: /nix/store/abc123.../Image
  - initrd file: /nix/store/def456.../initrd
  - These are on the x86_64 build host, not in the aarch64 guest!

Step 2: QEMU loads into GUEST memory
  - kernel → guest RAM at 0x40080000
  - initrd → guest RAM at 0x44000000

Step 3: QEMU creates boot protocol structures
  - x86_64: Fills boot_params with initrd location
  - aarch64: Creates DTB with /chosen/linux,initrd-start

Step 4: QEMU starts guest CPU
  - x86_64: ESI/RSI = pointer to boot_params
  - aarch64: x0 = pointer to DTB
  - PC = kernel entry point
  - Guest CPU starts executing

Step 5: Guest kernel boots
  - Kernel unpacks initrd (already in guest RAM)
  - Initrd mounts root from /dev/vda (the disk image)
  - System boots
```

### QEMU Internal Process (Simplified)

```c
// Pseudocode of QEMU's direct kernel boot
void qemu_arm_boot() {
    // Load kernel from host filesystem to guest RAM
    uint64_t kernel_addr = 0x40080000;
    load_image_to_guest_ram("host/path/kernel", kernel_addr);

    // Load initrd from host filesystem to guest RAM
    uint64_t initrd_addr = 0x44000000;
    uint64_t initrd_size = load_image_to_guest_ram("host/path/initrd", initrd_addr);

    // Create or modify Device Tree Blob
    void *dtb = create_device_tree_for_virt_machine();
    qemu_fdt_setprop_u64(dtb, "/chosen", "linux,initrd-start", initrd_addr);
    qemu_fdt_setprop_u64(dtb, "/chosen", "linux,initrd-end", initrd_addr + initrd_size);
    qemu_fdt_setprop_string(dtb, "/chosen", "bootargs", cmdline);

    // Load DTB to guest RAM
    uint64_t dtb_addr = 0x43000000;
    load_dtb_to_guest_ram(dtb, dtb_addr);

    // Set up guest CPU registers (ARM boot protocol)
    cpu->regs[0] = dtb_addr;      // x0 = DTB address
    cpu->regs[1] = 0;             // x1 = 0
    cpu->regs[2] = 0;             // x2 = 0
    cpu->regs[3] = 0;             // x3 = 0
    cpu->pc = kernel_addr;        // PC = kernel entry

    // Start the guest
    vm_start();
}
```

### Key Differences from Bootloader Boot

| Aspect | Traditional Bootloader | QEMU Direct Boot |
|--------|------------------------|------------------|
| Kernel location | Guest disk (/boot) | Host filesystem |
| Initrd location | Guest disk (/boot) | Host filesystem |
| Who loads kernel? | GRUB/systemd-boot | QEMU |
| Who creates DTB/boot_params? | Bootloader | QEMU |
| Guest needs bootloader? | Yes | No |
| Guest needs /boot partition? | Yes | No |

### Our NixOS + QEMU Setup

```nix
# flake.nix
apps.boot-qemu-minimal = {
  # ...
  qemu-system-aarch64 \
    -kernel ${piKernel.kernel}/Image \        # Host path!
    -initrd $INITRD \                         # Host path!
    -append "$KERNEL_PARAMS" \
    -drive file=$DISK_IMG,if=virtio
};
```

**The Bug We Found:**

```bash
# Mount guest disk to extract initrd path
sudo mount disk.img /tmp/mount
INITRD=$(readlink -f /tmp/mount/run/current-system/initrd)
# Now INITRD = "/tmp/mount/nix/store/abc123.../initrd"

sudo umount /tmp/mount
# Now /tmp/mount/nix/store/abc123.../initrd DOESN'T EXIST!

qemu-system-aarch64 -initrd "$INITRD"  # FAILS - file not found on host!
```

**The Fix:**

```bash
# Mount guest disk
sudo mount disk.img /tmp/mount
INITRD=$(readlink -f /tmp/mount/run/current-system/initrd)

# Copy to host filesystem before unmounting
INITRD_COPY="/tmp/initrd-$$.img"
cp "$INITRD" "$INITRD_COPY"

sudo umount /tmp/mount

# Now QEMU can read it
qemu-system-aarch64 -initrd "$INITRD_COPY"  # Works!
```

**Why this matters:**
- QEMU reads kernel/initrd from **host filesystem** (x86_64)
- The guest disk image contains the rootfs for **guest runtime** (aarch64)
- We mounted the guest disk temporarily to find the initrd path
- We must copy it to host filesystem before unmounting
- QEMU then loads it into guest RAM at boot time

---

## Summary Comparison

### Boot Process Comparison

| Stage | Traditional (Bootloader) | NixOS (Bootloader) | NixOS (No Bootloader) | QEMU Direct Boot |
|-------|--------------------------|--------------------|-----------------------|-------------------|
| Firmware | BIOS/UEFI | BIOS/UEFI | N/A | N/A (QEMU emulates) |
| Bootloader | GRUB/systemd-boot | GRUB/systemd-boot | None | None (QEMU loads directly) |
| Kernel location | /boot/vmlinuz | /boot/EFI/... (copy) | /nix/store/... | Host: /nix/store/... |
| Initrd location | /boot/initrd.img | /boot/EFI/... (copy) | /nix/store/... | Host: /nix/store/... |
| Root location | /dev/sda2 | /dev/sda2 | /dev/vda | Guest: /dev/vda |
| Boot protocol | boot_params or DTB | boot_params or DTB | boot_params or DTB | DTB (aarch64) |
| How kernel finds initrd | Bootloader fills boot_params/DTB | Bootloader fills boot_params/DTB | N/A | QEMU fills DTB |

### Filesystem Layout Comparison

**Traditional Linux:**
```
/boot/           # Separate partition (FAT32/ext2)
  vmlinuz
  initrd.img
/                # Root partition
  /bin, /usr, /etc, /sbin/init
```

**NixOS (with bootloader):**
```
/boot/           # Cache (FAT32)
  EFI/nixos/
    kernel-abc.efi      # COPY
    initrd-def.efi      # COPY
/nix/store/      # Source of truth
  abc-linux/Image       # ORIGINAL
  def-initrd/initrd     # ORIGINAL
```

**NixOS (no bootloader):**
```
# No /boot at all
/nix/store/
  abc-linux/Image
  def-initrd/initrd
  xyz-system/init
```

**QEMU Direct Boot:**
```
Host filesystem (x86_64):
  /nix/store/
    abc-linux/Image       ← QEMU reads this
    def-initrd/initrd     ← QEMU reads this

Guest disk image (aarch64):
  /nix/store/
    (full system, used after boot)
```

---

## Further Reading

- [Linux Boot Protocol (x86)](https://www.kernel.org/doc/html/latest/x86/boot.html)
- [Linux Boot Protocol (ARM64)](https://www.kernel.org/doc/html/latest/arm64/booting.html)
- [Device Tree Specification](https://www.devicetree.org/)
- [QEMU Direct Kernel Boot](https://qemu.readthedocs.io/en/latest/system/linuxboot.html)
- [NixOS Boot Process](https://nixos.wiki/wiki/Bootloader)
