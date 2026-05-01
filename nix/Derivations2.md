

In nix we have one `stdenv` per derivation

# `stdenv`

And stdenv is the standard environment. It has a raw compile eg `clang`) r, a raw linker (e.g. `lld`), and other tools (`ar`, etc)

The raw compiler however, doesn't know about system libs, start files, c headers and libs, etc. Same for the raw 

So usually we wrap the raw compiler an dlinker in scripts that are aware of the standard headers, libs.

Nix exposes these wrapped tools using stdenv.

> Only on stdenv is active per derivation, unless we specifically override ENV vars

`stdenv.cc` is the wrapped compiler (could be wrapped clang, wrapped gcc etc)
`stdenv.ld` is the wrapped linker (could be lld, gold, mold, gld etc)

stdenv exposes these wrapped compilers using env vars

`CC` : wrapped c compiler
`CXX`: wrapped c++compiler
`LD` : wrapped linker

At the very start of a Nix build, stdenv runs its setup script. That script exports a bunch of vars like:

CC
CXX
AR
LD
flags, sysroot paths, etc.


We can create custom stdenv uisng stdenvAdapters. e.g.

```

llvm = pkgs.llvmPackages_20; 
clangStdenv = pkgs.stdenvAdapters.overrideCC pkgs.stdenv llvm.clang;
```

will just override CC but keep the wrapping intact
## Rust Building

Rust builds using rust c and then links using the linker.

Cargo/Rustc choose linkers/compilers via these patterns:

Target linker:
`CARGO_TARGET_<TRIPLE>_LINKER` (highest priority)
then falls back to rustc’s default (often cc from PATH).

Target C compiler for build scripts / cc crate:
`CC_<triple>` and `CFLAGS_<triple>` (used by the cc crate and some build scripts).
Cargo doesn’t invent these; crates read them.

Host/build C compiler:
`HOST_CC, HOST_CFLAGS` are not a Cargo core feature, but they are read by the Rust cc crate and some Autotools/CMake-in-build.rs setups to compile host-side helpers.

So in practice:

Cargo/rustc care most about `CARGO_TARGET_<TRIPLE>_LINKER`

The cc crate cares about HOST_CC/HOST_CFLAGS for build-platform C, and CC_<triple>/CFLAGS_<triple> for target C.

Precedence in the cc crate (roughly)

For a given compilation:

If it’s building for host/build platform, it checks:

HOST_CC / HOST_CFLAGS

then CC / CFLAGS

then cc from PATH

If it’s building for a specific target triple, it checks:

CC_<triple> / CFLAGS_<triple> (underscore form)

sometimes also CC_<triple-with-dashes> (dash form)
(you saw it printing both)

then CC / CFLAGS

then cc from PATH

That’s why your log printed CFLAGS_x86_64_unknown_linux_gnu etc.

Why setting both matters in Nix cross builds

When cross-compiling, a crate might:

compile target C glue (needs target sysroot)

compile a tiny host helper (needs host sysroot)

If you only set target vars, host C accidentally uses target toolchain → missing host headers.
If you only set host vars, target C uses host toolchain → wrong arch.

So the “safe nix pattern” is:

HOST_CC / HOST_CFLAGS → buildPackages wrapper + host headers

CC_<target> / CFLAGS_<target> (or CARGO_TARGET_<target>_LINKER) → target stdenv wrapper + target headers

If you want, I can give you a tiny helper let block to auto-generate the env var names from your rustcTarget so you don’t have to hardcode aarch64_* ever again.

