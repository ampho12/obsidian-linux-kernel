
# Thunk
A thunk is a type of Nix value that is not yet evaluated. It consists of the expression that the value should be evaluated from, and the environment in which the expression should be evaluated, aka the variables in scope.

So a thunk is a pair: `(expression, environment)`.

### What a `let` binding does

When Nix processes:

```nix
let
  a = 1 + 2;
  b = a + 10;
in b
```

It creates an environment with all the bindings at once:

```
env = {
  "a" → thunk(1 + 2,       env)
  "b" → thunk(a + 10,      env)
}
```

Every thunk captures **the same `env`** as its environment. That's why all bindings can see all other bindings regardless of order — they all share the same environment, and that environment contains all of them.

### References are resolved through the environment

When a thunk's expression mentions a variable like `a`, it doesn't contain the value of `a`. It contains a **reference** that says "look up `a` in my environment." The environment maps `"a"` to another thunk. That's the chain.

### Forcing a thunk

If another expression needs z, the thunk will be forced, meaning that the expression will be computed using the environment, and the thunk is overwritten. Any subsequent use of z will see the final value, so z will be evaluated at most once.

This is important — once forced, the thunk is **replaced in place** with the computed value. It's memoized. If ten things reference `a`, the expression `1 + 2` runs once, the thunk becomes `3`, and everyone else just sees `3`.

### Why self-reference works

```nix
let
  self = {
    a           = self.callPackage ./a.nix {};
    callPackage = pkgs.newScope self;
  };
in self
```

The environment is:

```
env = {
  "self" → thunk({ a = ...; callPackage = ...; },  env)
}
```

The thunk for `self` contains an expression that references `self` — which is a lookup back into `env["self"]`. But that's fine, because:

1. Creating the attrset `{ a = ...; callPackage = ...; }` doesn't force its attributes — it just records thunks for each attribute
2. The thunk for `self` gets forced to an **attrset structure** (the keys exist, the values are still thunks), and that's enough
3. Only when you access `self.a` does the thunk for `a` get forced, which then looks up `self.callPackage`, which forces that thunk, etc.

### Why `//` doesn't rewire things

```nix
let
  self     = { a = 1; b = self.a + 10; };
  newThing = self // { a = 999; };
in newThing.b
# => 11, not 1009
```

The environment is:

```
env = {
  "self"     → thunk({ a = 1; b = self.a + 10; },  env)
  "newThing" → thunk(self // { a = 999; },          env)
}
```

`newThing` is a new entry in the dict. The thunk for `b` inside `self` was created with an expression that says `self.a + 10`. The `self` in that expression resolves through the environment to `env["self"]` — the original attrset. It has no idea `env["newThing"]` exists. `//` creates a new attrset value, but it copies the existing thunks as-is, and those thunks still close over the original environment where `self` means the original `self`.

# Package vs Derivation

A derivation in nix is a `.drv` path. We can build one like this

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

This is not very portable though.

1. will import its own bash
2. hardcodes to `x86_64-linux` system


Often we paremeterize our derivations. Call 
```nix
{ bash, stdenv}:
builtins.derivation {
    name = "example";
    builder = "${bash}/bin/bash";
    system = stdenv.buildPlatform.system;
    args = [
        "-c"
        "echo hello > $out"
    ];
}
```

This parameterized form of the derivation is called a `package`. We can use this to instantiate a derivation

```nix
import ./hello.nix { pkgs.bash, pkgs.stdenv}
```


## The Call Package rescue

The wiring for package is highly manual, mainly If the package input args change, the API has to propagate upwards.

So nix supplies a special attribute in a package set called `callPackage`.  A "package set" is nothing more than an attribute set where values are packages. 

The `callPackage` function basically introspects the API of the package we are trying to call and substitues arguments by finding the keys in the current package set and replacing the arguments.

```nix
callPackage = fn: overrides:
  let
    f = if builtins.isFunction fn then fn else import fn;
    args = builtins.functionArgs f;
    # for each argument name, look it up in the package set
    autoArgs = builtins.mapAttrs (name: _: pkgs.${name}) args;
  in
    f (autoArgs // overrides);
```

So when we do
```nix
let
    pkgs = import <nixpkgs> { };
in
    pkgs.callPackage ./example.nix { }
```

The `callPackage` finds the keys in the "example" derivation, which are bash and stdenv. Nixpkgs has these defined, so it substitutes those values. I.e the identical code is

```nix
let
    pkgs = import <nixpkgs> { };
in
    import ./hello.nix { pkgs.bash, pkgs.stdenv}
```

but now if we change the example package's signature, we don't need all upstream to change.

# Package Set

A package set is an attribute set where values are expressions
```nix
{
    foo = expr1;
    bar = expr2;
    baz = expr3;
}
```

Nixpkgs is a function that returns a package set

```nix
import <nixpkgs> { <args> }
```

1. `<nixpkgs>` is special in that it resolves to path of the installed nixpkgs on the system
2. `<args>` is arguments, eg host archicture, build architecture, etc

We can build these with `let` or `rec` blocks


# Package Scope

`callPackage` is useful, but what if we want to extend it? Normally, only nixpkgs has the callPackage attribute, what if I want to create a new package set and have `callPackage` work on it?


## newScope

`newScope` creates a new `callPackage` function that looks up arguments from a custom set merged with the original set

```nix
myCallPackage = pkgs.newScope {
    foo = <something>;
    bar = <something>;
};
```

If some package wants `foo` or `bar` as the arguments, our overriden definition would be used. For something like `stdenv`, it will fall through to the original `pkgs` (often nixpkgs).


## makeScope

our next problem is to assemble soemthing like this

```nix
self = {
    a = self.callPackage ./a.nix { };
    b = self.callPackage ./b.nix { };
    callPackage = pkgs.newScope self;
}
```

This might look circular, but recall that everything the right hand side of the assignment operator is an expression that is not evaluated until needed. Lazy evaluation substitutes the last unevaluated expression in that change.

So when we do

```
self.callPackage ./example.nix { }
```

nix must evaluate the expression behind `self.callPackage` which is `pkgs.newScope self`.

Here is the flow:
```
self.callPackage ./example.nix {}
│
│  resolve self.callPackage
▼
(pkgs.newScope self) ./example.nix {}
│
│  newScope self returns a callPackage function
│  that has self as its lookup table
▼
│  import ./example.nix → get a function
│  builtins.functionArgs → { a = false; stdenv = false; }
│
│  for each argument name, build an attrset:
│  {
│    a      = self.a;       ← an expression, not yet evaluated
│    stdenv = self.stdenv;  ← not in self, falls through to pkgs.stdenv
│  }
│
│  merge with overrides (the {} we passed):
│  {} // { a = self.a; stdenv = pkgs.stdenv; }
▼
│  call the function with that attrset:
│  (import ./example.nix) { a = self.a; stdenv = pkgs.stdenv; }
▼
a derivation (also unevaluated until someone forces it)
```

So makescope does something like this to automate the process

```nix
makeScope = newScope: f:
  let
    self = f self // {
      callPackage = newScope self;
      overrideScope = g: makeScope newScope (extends g f);
    };
  in self;
```


There is another problem that is addressed by overrideScope in the makeScope command

Say we begin with

```
self = {
    a = self.callPackage ./a.nix { };
    b = self.callPackage ./b.nix { }; // assume b takes a as argument
    callPackage = pkgs.newScope self;
}
```

and we want to replace `a` with a different version. but b and c still see old a

`overrideScope` lets you **modify packages inside a scope** and have those changes propagate to everything that depends on them.


Say you have a scope:

```nix
myScope = makeScope newScope (self: {
  a = self.callPackage ./a.nix {};
  b = self.callPackage ./b.nix {};  # b depends on a
  c = self.callPackage ./c.nix {};  # c depends on b
});
```

You want to swap out `a` for a different version. If you just do:

```nix
myScope // { a = somethingElse; }
```

That replaces `a` in the attrset, but `b` and `c` **still see the old `a`**. They were built with the original scope's `callPackage`, and that's already resolved. You've only changed the surface — the dependency graph underneath is untouched.

### What overrideScope does

```nix
myScope.overrideScope (final: prev: {
  a = somethingElse;
})
```

This **rebuilds the entire scope from scratch** with your modification layered in. Now:

- `a` is your new version
- `b` gets rebuilt, and its `callPackage` injects the **new** `a`
- `c` gets rebuilt, and picks up the **new** `b` (which uses the new `a`)

The change propagates through the whole dependency chain.

### How it works

Remember from `makeScope`:

```nix
self = f self // {
  overrideScope = g: makeScope newScope (extends g f);
};
```

When you call `overrideScope`, it:

1. Takes your override function `g = final: prev: { a = somethingElse; }`
2. Calls `extends g f` — this layers `g` on top of the original scope definition `f`
3. Calls `makeScope` again — this re-ties the fixed point from scratch

### What is `extends`?

```nix
extends = g: f: final:
  let prev = f final;
  in prev // g final prev;
```

It's function composition for fixed-point functions. It gives your override function `g` two arguments:

- **`final`** — the fully resolved scope (after all overrides)
- **`prev`** — what the scope looked like before your override

This is the same `final`/`prev` pattern as nixpkgs overlays. You can reference original packages through `prev` and the fully resolved result through `final`:

```nix
myScope.overrideScope (final: prev: {
  a = prev.a.overrideAttrs { version = "2.0"; };
  # prev.a = the original a
  # final.b = b rebuilt with the new a
})
```

### In short

- `//` replaces attributes on the surface, dependencies don't notice
- `overrideScope` rebuilds the whole scope with a new fixed point, so changes flow through the entire dependency graph

It's the scope equivalent of nixpkgs overlays.