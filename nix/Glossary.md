
# Nixpkgs
Nixpkgs is a function whose argument is an attreset



# `<nixpkgs>`

This is path to the nxpkgs channel installed on the system

# `import`

This reads a path that is 
1. a file
2. a directory with `default.nix`

It then evaluates expression in that location

e.g.

Let `file1.nix` be
```nix
let
    file2 = import ./file2.nix;
in
    file2.name
```

and `file2.nix` be

```
{
    name = "hello";
}
```

then running `nix eval -f file1.nix` results in 
```
"hello"
```


Another example

```
# file1.nix
let
    add1 = import ./add1.nix;
in
    add1 1


# add1.nix
a: a + 1
```

 output is `2`


