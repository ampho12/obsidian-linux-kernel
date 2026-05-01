
At the heart of a nixos system build, there is a 

```
system.build.toplevel
```

That’s the root closure — the fully built, dependency-resolved directory tree that represents the running system.

Every generator format — whether ISO, raw, docker, or rootfs — does the same thing:

Take system.build.toplevel, then stage it into whatever shape the target format expects.

For a Pi rootfs:

The root filesystem comes from system.build.toplevel.

The kernel + modules + firmware are packaged within it (because they’re declared as system dependencies).

This is why all generator formats feel consistent: they all transform the same underlying NixOS system closure.




# Rootfs


Generating a rootfs is a can of worms

But here is the main rundown

1. Filesystem: this is done partly at build time and partly and runtime
2. Modules: these are needed if modules are loaded at boot time
3. Firmware: this is additional firmware usually needed by the kernel.


The filesystem defines everything (i.e where the modules are and where the firmware is)

### Firmware
`/lib/firmware` is just a conventional default path. The kernel’s firmware loader looks there only if nothing else is configured. In NixOS (and many embedded builds), it’s completely normal to skip that and explicitly tell the kernel where firmware lives.

The kernel’s firmware loading subsystem (the firmware_class module) checks these locations, in order:


1. path set using `echo /path/to/firmware > /sys/module/firmware_class/parameters/path`
2. The built-in search paths in the kernel (default includes /lib/firmware)
3. Any directory embedded via CONFIG_EXTRA_FIRMWARE_DIR (compile-time option).


### Modules

These must live in a location such that the modprobe command knows how to find them.

Then we can simply override where the kernel thinks the modprobe binary is

```
echo /nix/store/...-kmod-.../bin/modprobe > /proc/sys/kernel/modprobe
```

And now the modules can live anywhere!

Conventionally, modules lives in `/lib/modules`



### Custom Formats


The `nixos-generators` tool ships with many *built-in formats* (ISO, raw image, cloud images, container tarballs, etc.).

`customFormats` is a mechanism that lets you **extend or override** these built-in formats with your own format modules — e.g., you might want to tweak partitioning, add extra hooks, or make a new format that isn’t supported out-of-the-box.

When you call `nixosGenerate` (or use the flake output in your `flake.nix`), you can pass the `customFormats` argument. That maps format names to format modules and lets your invocation use those instead of (or in addition to) built-ins.

---

## 🧱 How they integrate (internals)

Here’s a step-by-step of what happens under the hood when you use `customFormats`:

1. You call `nixosGenerate` with something like:

   ```nix
   nixosGenerate {
     system = "aarch64-linux";
     format = "myFormat";
     modules = [ … ];
     customFormats = { myFormat = <myFormatModule>; };
   }
   ```

   In the call you supply `format="myFormat"` and supply a `customFormats` attribute set mapping `"myFormat"` → module. ([GitHub][3])

2. Inside `nixos-generators`, the code builds `extraFormats` by mapping `customFormats` names into modules:

   ```nix
   extraFormats = lib.mapAttrs' (name: value:
     lib.nameValuePair name { imports = [ value ./format-module.nix ]; }
   ) customFormats;
   ```

3. Then `formatModule` is selected by:

   ```nix
   formatModule = getAttr format ( self.nixosModules // extraFormats );
   ```

   So your custom format module gets merged with the built-ins. ([GitHub][3])

4. It then builds a NixOS system via `nixosSystem { modules = [ formatModule ] ++ modules; … }`. That means your custom format module can inject settings/options in the NixOS config (via NixOS modules) that change how the image is built (partitions, bootloader, etc.). ([GitHub][4])

5. Finally, when the system config is evaluated, the output path it builds is `system.build.${image.config.formatAttr}` (i.e., the attribute set defined by the format module). The format module usually sets `formatAttr = "<something>"` and `fileExtension = ".<ext>"`. Then the CLI picks that artifact. ([GitHub][4])

---

## 🛠 How to define your own `customFormat`

Here’s a breakdown of how to write one:

### A) Create a format module file (e.g., `my-format.nix`)

```nix
{ config, lib, pkgs, modulesPath, ... }:
{
  # Optionally import a built-in base format or partition helper
  imports = [ "${toString modulesPath}/installer/netboot/netboot-minimal.nix" ];

  # Set what attribute in system.build you’ll build
  formatAttr = "myImage";          # e.g., system.build.myImage
  fileExtension = ".img";          # e.g., .img
  # Then other config overrides:
  boot.loader.grub.enable = lib.mkDefault false;
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
    # …
  };
  # You can add new build hooks:
  system.build.myImage = pkgs.runCommand "myImage" { ... } ''
    # build commands here
    echo "hello" > $out/README
  '';
}
```

### B) In your `flake.nix` or config where you call `nixosGenerate`

```nix
nixosGenerate {
  system = "x86_64-linux";
  format = "myFormat";                   # matches key in customFormats
  customFormats = {
    myFormat = ./path/to/my-format.nix;
  };
  modules = [ ./configuration.nix ];
}
```

### C) What your format module can do:

* Set `formatAttr`, `fileExtension`, maybe `fileSystems`, `boot.loader` & other NixOS module options.
* Provide a `system.build.<formatAttr>` derivation or reuse an existing one.
* Import one of the built-in “installer” or “image” modules for common logic (to avoid reinventing everything).
* Let you tweak partition layout, kexec scripts, rootfs details etc.

### D) Use-cases:

* You want an image with custom partitioning that the built-in formats don’t support.
* You want to embed additional steps (firmware loading, post-install scripts, specific initrd hooks).
* You want a completely new target (say a specialized hardware board) that doesn’t fit existing formats.

---

## ⚠️ Caveats & what to watch for

* The format module must be compatible with the architecture/system you’re targeting (eg. cross builds).
* When using flakes, make sure `customFormats` is in the same namespace the `nixosGenerate` call expects (i.e., the right key). Some users have reported confusion/bugs. ([NixOS Discourse][5])
* If your format uses `pkgs.runCommand` or similar, ensure you satisfy `strictDeps`, `nativeBuildInputs`, etc — especially for cross builds.
* If you are only modifying a small part of an existing format (e.g., only tweaking kexec’s builder), overriding the existing format module or using `overrideAttrs` might be simpler than writing a full custom module.

---

If you like, I can **pull up a minimal `customFormat` example** from `nixos-generators` repo (or a community example) that matches your scenario (kexec + rootfs), and we can modify it for your cross aarch64 build. Would you like me to fetch that?

[1]: https://github.com/nix-community/nixos-generators?utm_source=chatgpt.com "nix-community/nixos-generators - GitHub"
[2]: https://github.com/nix-community/nixos-generators/issues/133?utm_source=chatgpt.com "How to use custom formats when using generators as a flake? #133"
[3]: https://github.com/nix-community/nixos-generators/blob/master/flake.nix?utm_source=chatgpt.com "nixos-generators/flake.nix at master - GitHub"
[4]: https://github.com/nix-community/nixos-generators/blob/master/README.md?plain=1&utm_source=chatgpt.com "nixos-generators/README.md at master - GitHub"
[5]: https://discourse.nixos.org/t/using-nixos-generators-in-a-flake-with-customformats/35115?utm_source=chatgpt.com "Using nixos-generators in a flake with customFormats"



When using nixos rebuild switch,
 this command tries to use the new boot
 
 ```
 /run/current-system/bin/switch-to-configuration boot
 ```