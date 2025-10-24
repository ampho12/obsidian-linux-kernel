
Here is a minimal derivation

```nix
builtins.derivation {
    name = "example-derivation";
    builder = "/bin/true";
    system = "x86_64-linux";
}
```

a derivation is like a special attribute set. This is what each attribute means


1. `name` : metadata for the nix derivation
2. `builder` : a program to run to build something else
3. `system`: the **TARGET** architecture (i.e where the output of the derivation will be used)

However, a derivation also has the following restrictions
1. Anything used by the derivation must a be a nix store path. Specificially, its a [deriving path](https://nix.dev/manual/nix/2.28/store/derivation/#deriving-path). These path's refer to objects in the nix store that may or may not be realized.
2. Anything used by the derivation must be *explicitly* specified, even if it is in the nix store. This is for isolation and repeatability. Thus, we need to add `inputDrvs` which takes an array of results of other derivatations.
3. Finally, a derivation must produce an output file which is in the environment variable `$out`


but this is a minimal *working* derviation

```nix
let
    pkgs = import <nixpkgs> { };
in
builtins.derivation {
    name = "example-derivation";
    inputDrvs = [ pkgs.bash ];
    builder = "${pkgs.bash}/bin/bash";
    system = "x86_64-linux";
    args = [
        "-c"
        "echo Hello, World! > $out"
    ];
}

```

> Recall we need to add this to a git repo for nix to pick it up

> Once added to git, we can run this with nix-build file1.nix


Here is a minimal derivation to build a c file 

```nix
let
    pkgs = import <nixpkgs> { };
in
    builtins.derivation {
        name = "hello-world-derivation";
        inputDrvs = [ pkgs.gcc pkgs.bash];
        builder = "${pkgs.bash}/bin/bash";
        system = "x86_64-linux";
        args = [
            "-c" "$gcc/bin/gcc -o $out $file"
        ];
        file = ./hello-world.c;
        gcc = pkgs.gcc;
    }
```

We see that file and gcc's directory are being passed as environment variables

## Some Sneak Peek

We can find out what the environment of the derivation is using this small derivation

```nix
let
    pkgs = import <nixpkgs> { };
in
builtins.derivation {
    name = "example-derivation";
    inputDrvs = [ pkgs.coreutils ];
    builder = "${pkgs.coreutils}/bin/printenv";
    system = "x86_64-linux";
}
```

The output is 
```
HOME=/homeless-shelter
NIX_BUILD_CORES=20
NIX_BUILD_TOP=/build
NIX_LOG_FD=2
NIX_STORE=/nix/store
PATH=/path-not-set
PWD=/build
TEMP=/build
TEMPDIR=/build
TERM=xterm-256color
TMP=/build
TMPDIR=/build
builder=/nix/store/wdap4cr3bnm685f27y9bb6q5b6q18msl-coreutils-9.5/bin/printenv
inputDrvs=/nix/store/wdap4cr3bnm685f27y9bb6q5b6q18msl-coreutils-9.5
name=example-derivation
out=/nix/store/l9z6dqmpjpw9w1rja8qyg5lzl2w762m1-example-derivation
system=x86_64-linux
```



More info here: https://nix.dev/manual/nix/2.28/language/derivations



which gives a nice sneak peek at the environment the builder runs with

1. inputDrvs is an array that used space as a separator. Since we have only one inputDrv, this doesn't matter right now.


This is the AI overview

| Variable                                   | Meaning                                                                                                                                                                                               |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **HOME**                                   | Always set to `/homeless-shelter` inside a build, so that builds can’t accidentally read/write your real $HOME.                                                                                       |
| **NIX_BUILD_CORES**                        | The number of CPU cores Nix will allow the build to use (by default, the number of cores on your machine).                                                                                            |
| **NIX_BUILD_TOP**                          | The root of the temporary build directory (`/build`); all “unpack”, “build” and “install” phases run under here.                                                                                      |
| **NIX_LOG_FD**                             | The file‑descriptor number (here, `2`) where build-phase logs should be written.                                                                                                                      |
| **NIX_STORE**                              | The path to the immutable Nix store (`/nix/store`), so build scripts can reference it if needed.                                                                                                      |
| **PATH**                                   | Normally `"/path-not-set"` in raw derivations—Nix doesn’t populate $PATH for you unless you use helpers; you must reference binaries by their full store paths or explicitly add inputs to your PATH. |
| **PWD**                                    | The current working directory, set to the build’s top (`/build`).                                                                                                                                     |
| **TEMP**, **TMP**, **TEMPDIR**, **TMPDIR** | All pointed at the same directory (`/build`) for any tools or scripts that need a temporary directory.                                                                                                |
| **TERM**                                   | Passed through from your environment (here `xterm-256color`), so that any scripts or programs using terminal capabilities behave reasonably.                                                          |
| **builder**                                | The absolute store path of the “builder” program or script Nix will invoke (e.g. `/nix/store/...‑coreutils‑9.5/bin/printenv`).                                                                        |
| **inputDrvs**                              | A colon‑separated (or single) list of the _derivation values_ you declared—i.e. the packages whose outputs Nix has mounted into the sandbox.                                                          |
| **name**                                   | The name of the derivation (used in the final output path), here `example‑derivation`.                                                                                                                |
| **out**                                    | The path under `/nix/store` where your build must deposit its output (the `$out` directory).                                                                                                          |
| **system**                                 | The target platform triple of the build, e.g. `x86_64-linux`.                                                                                                                                         |



# builtins.derivation vs stdenv.mkDerivation


|Feature|Raw `builtins.derivation`|`stdenv.mkDerivation`|
|---|---|---|
|**Builder script**|You must supply your own `builder` (binary or script).|Uses Nix’s standard shell‑wrapper (`setup.sh`) as the builder.|
|**Phases**|No phases—you write one monolithic `args` or shell logic.|Provides named phases (`unpackPhase`, `patchPhase`, `configurePhase`, `buildPhase`, `installPhase`, etc.) you can override or extend.|
|**Environment**|Minimal: only `$out`, `$builder`, `$inputDrvs`, temps, etc.|Populates a full build environment: `$PATH`, `CC`, `CFLAGS`, `LDFLAGS`, `PKG_CONFIG_PATH`, etc.|
|**Inputs on `$PATH`**|You must list tools in `inputDrvs` and call them via absolute paths (`${pkgs.gcc}/bin/gcc`).|You declare `buildInputs`/`nativeBuildInputs` and those tools automatically appear on `$PATH`.|
|**Source unpacking**|You must unpack and stage sources yourself (if not a single file).|Handles `src = ./.` or `fetchurl` automatically: unpacks tarballs into the build directory.|
|**Multiple outputs**|You’d have to manage multiple outputs by hand.|Support for `outputs = [ "out" "dev" "doc" ]` and variables `$out`, `$dev`, `$doc`.|
|**Standard metadata**|You supply only what you need (`name`, `builder`, `args`, etc.)|You get `pname`, `version`, `description`, `license`, `maintainers`, etc., with automatic path naming.|
|**Cross‑compilation support**|You must wire up `crossSystem` yourself if using flakes or raw Nix.|Built‑in support for `stdenv.cc` and `stdenv.cc.cross` in Nixpkgs, plus `nativeBuildInputs` vs `buildInputs`.|
|**Test hooks**|No test support by default.|Provides `checkPhase` and wiring to run `doCheck` tests.|