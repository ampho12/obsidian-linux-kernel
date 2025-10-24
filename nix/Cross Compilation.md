
Let's checkout how to do simple cross compilation



We have the following tools available

```
pkgs.pkgsCross.<host>.<derived object>
```

e.g.

```
pkgs.pkgsCross.aarch64-multiplatform.gcc
```

This `gcc` is not the cross compiler however, it is gcc compiled for aarch64-multiplatform. This is true for any `derived object`

How do you get the cross compilation environment? We need to use `pkgs.pkgsCross.aarch64-multiplatform.stdenv`  This is a cross compilation environment


Let's test it. This is a stdenv derivation for a hello-world c file that runs on x86_64-linux-gnu

```nix
let
    pkgs = import <nixpkgs> {};
in
    pkgs.stdenv.mkDerivation {
      pname = "hello-world-stdenv";
      version = "1.0";
      src = ./hello-world.c;
      dontUnpack = true;
      buildInputs = [ pkgs.gcc ];
      buildPhase = ''
        mkdir -p $out/bin
        gcc -o $out/bin/hello $src
      '';
    }
```

Now let's switch stdenv to use the cross compilation environment

```nix
let
    pkgs = import <nixpkgs> {};
in
    pkgs.pkgsCross.aarch64-multiplatform.stdenv.mkDerivation {
      pname = "hello-world-stdenv";
      version = "1.0";
      src = ./hello-world.c;
      dontUnpack = true;
      buildInputs = [ pkgs.gcc ];
      buildPhase = ''
        mkdir -p $out/bin
        gcc -o $out/bin/hello $src
      '';
    }
```

that's it! one line change






