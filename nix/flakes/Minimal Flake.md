
A minimal flake looks like the following (`flake.nix`)

```nix

{
    description = "minimal flake";
    output = { self }: {
       # attributes to evaluate 
    };
}
```



## Description
This is just a description, any string works


## Output

This is a function that maps `attrset -> attrset`. The fields in the attreset can be evaluated individually

To evaluate this, we must

1. `git add flake.nix` (this is necessary)
2. `nix eval .`

This will evaluate the default attribute in the attribute in the attr-set returned by output, which is

```
packages.${system}.default
```

or 

```
defaultPackage.${system}
```


### Defaults

Conventional default names:

```nix
{
  packages.x86_64-linux.default = /* your main package */;
  lib.default = /* your main library */;
  devShells.x86_64-linux.default = /* your main dev shell */;
}
```


### Defaults with commands

When you run nix eval . (without `attr-name` ), it searches for these in order:

```
packages.<system>.default
defaultPackage.<system> (legacy format)
```

This is the same default lookup as nix build . and nix run .

```nix
nix build .              # Looks for packages.<system>.default
nix run .                # Looks for packages.<system>.default  
nix develop .            # Looks for devShells.<system>.default
```

## Self Parameter

The self parameter is important in nix flakes, it is basically an attrset that is the whole file but
1. There is no description field
2. There is an added source-info field which contains version info