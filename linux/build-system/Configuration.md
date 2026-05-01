

# Parts 

1. Kconfig files and Config.in files live scattered throughout build system.
2. Front-end
    1. menuconfig
    2. nconfig
    3. xconfig
    4. oldconfig
    5. olddefconfig
    6. merge_config.sh and other helpers
3. Seeds configs
    1. a board or an SoC defconfig `arch/arm64/configs/<something>_defconfig`
    2. fragments that are merged in
4. Outputs: a single `.config` file (root of the tree) and some generated files read by kbuild:
    1. `include/generate/autconf.h`
    2. `include/config/*`
    3. `include/config/ayto.conf`


Think of all the `Kconfig` files as a questionnare and the `.config` file as answers to these questions.

To overwrite .config with the default recommended answers, use.
```
make defconfig
```

If the questionnare changes, but we have the same answers mostly we can run

```
# For any question in KConfig not answered in .config, answer with default
make olddefconfig 
```

```
# For any question in KConfig not answered in .config, prompt for answer
make oldconfig
```

# Kconfig: where options are defined

Every directory can have a `Kconfig`. Options look like:

```kconfig
config VIDEO_OV5647
    tristate "OmniVision OV5647 sensor"
    depends on I2C && VIDEO_DEV
    help
      Say Y or M if you have this camera...
```

* `tristate` → values: **y** (built-in), **m** (module), or **n** (off).
* `depends on` gates visibility/validity.
* `select` force-enables another symbol (use sparingly).
* Defaults can be conditional: `default y if ARCH_AMLOGIC`.

# 2) Pick a starting config (defconfig)

You start from a defconfig tailored for your board/SoC:

```bash
make ARCH=arm64 <board>_defconfig
# or simply: make defconfig      # generic defaults for the arch
```

This **creates `.config`** by enabling a curated set of symbols.

> In vendor build systems (like Fenix), sourcing their env typically picks a **board defconfig** for you. If you **don’t** run `menuconfig`, building uses that default as-is.

# 3) Change it (interactively or with fragments)

* **Interactive**:

  ```bash
  make menuconfig        # curses UI (starts from current .config)
  make nconfig/xconfig   # alternatives
  ```

  Save → `.config` is updated.





* **Non-interactive updates**:

  ```bash
  # Update old .config to new Kconfig without prompts (use defaults)
  make olddefconfig

  # Or prompt for any new symbols:
  make oldconfig
  ```

* **Merge fragments** (great for enabling a few things on top of defconfig):

  ```bash
  scripts/kconfig/merge_config.sh -m \
      arch/arm64/configs/<board>_defconfig \
      my_camera_fragment.cfg \
      another_fragment.cfg
  # result: .config   (-m warns on conflicting settings)
  ```

  Fragment lines look like:

  ```
  CONFIG_VIDEO_OV5647=m
  CONFIG_MEDIA_SUPPORT=y
  ```

* **Save a minimal defconfig** from your tuned `.config`:

  ```bash
  make savedefconfig
  # writes ./defconfig (only the deviations from tiny defaults)
  ```

**Precedence** when merging: later files override earlier ones. Hidden symbols (no prompt) can still be set if dependencies allow.

# 4) How `.config` becomes something the build can use

As soon as you run a build or any Kconfig target, kbuild generates:

* **`include/generated/autoconf.h`**
  C macros like `#define CONFIG_VIDEO_OV5647 1` or `/* #undef CONFIG_VIDEO_OV5647 */`.
* **`include/config/auto.conf`**
  A Makefile snippet that defines variables so `Makefile`s can test `CONFIG_*`.
* **`include/config/<firstletters>/CONFIG_...`**
  Tiny marker files used for dependency tracking.

# 5) How kbuild uses the config

Kernel and driver `Makefile`s are full of lines like:

```make
obj-$(CONFIG_VIDEO_OV5647) += ov5647.o
```

This expands to:

* **`CONFIG_* = y`** → add object to the built-in objects (linked into `vmlinux`).
* **`CONFIG_* = m`** → build a **module** (`ov5647.ko`) placed under `.../modules/`.
* **unset** → don’t compile it at all.

C code sees:

```c
#ifdef CONFIG_VIDEO_OV5647
/* compiled only if y or m */
#endif
```

…and can also use `IS_ENABLED(CONFIG_VIDEO_OV5647)` for either y or m.

After building modules, `depmod` creates `modules.dep`/`modules.alias`; **udev/modprobe** can autoload modules when a device with a matching **modalias** appears.

# 6) Typical flows you’ll use

### A) “Take the board default and build”

```bash
make <board>_defconfig
make -j$(nproc)         # or via your vendor wrapper (e.g., fenix `make kernel`)
```

### B) “Enable a few drivers on top of the default”

```bash
make <board>_defconfig
scripts/kconfig/merge_config.sh -m .config my_extra.cfg
make olddefconfig       # ensure consistency, fill new defaults
make -j$(nproc)
```

### C) “Interactive tweak”

```bash
make <board>_defconfig
make menuconfig
make -j$(nproc)
```

### D) “Bake your tuned config into a sharable defconfig”

```bash
make savedefconfig
# move ./defconfig to arch/<arch>/configs/<new>_defconfig in your tree
```

# 7) A few subtle but important mechanics

* **`depends on` vs `select`**
  `depends on` prevents enabling unless prerequisites are met.
  `select` force-enables another symbol **without** checking its deps—use carefully (maintainers prefer `depends on` where possible).

* **Tristate rules**
  A module (`m`) is only allowed if the symbol’s **parent** (e.g., `CONFIG_MODULES`) permits it, and if all dependencies aren’t `n`.

* **Choices**
  `choice` blocks ensure only one of several options is on.

* **Hidden symbols**
  Options without a prompt line can be set by defaults or via `select/imply`, but don’t appear in `menuconfig`.

* **Environment knobs**

  * `KCONFIG_CONFIG=alt.config make menuconfig` → use a different config file name.
  * `KCONFIG_ALLCONFIG=fragment.cfg make allnoconfig` → seed from a fragment.

* **Version string**
  `LOCALVERSION` or `CONFIG_LOCALVERSION` appends to `uname -r` (useful when shipping custom kernels).

# 8) How this maps to your camera case

* Enabling **OV5647**:

  * Upstream path: set `CONFIG_VIDEO_OV5647=m` (or `y`) and use a DT node with `compatible = "ovti,ov5647"`.
  * Vendor Amlogic path: use their **`amlogic,sensor`** wrapper; the module you need is whatever that wrapper lives in (often enabled by SoC camera options), not necessarily the upstream `ov5647` module.
* Regardless of path, the choice you make lands in `.config`, becomes `autoconf.h`/`auto.conf`, and controls whether the relevant `.o` is compiled and linked.

---

## Cheat sheet

* **Start**: `make <board>_defconfig` → creates `.config`.
* **Tweak**: `make menuconfig` *or* merge fragments with `scripts/kconfig/merge_config.sh`.
* **Normalize**: `make olddefconfig`.
* **Build**: `make` (or your vendor wrapper).
* **What kbuild reads**: `include/config/auto.conf` + `include/generated/autoconf.h`.
* **What code sees**: `CONFIG_*` in Makefiles and C ifdefs.

If you want, tell me which exact defconfig your build picks, and I’ll show you where in the tree the camera/CSI options live and how to add a tiny fragment to enable them cleanly.

