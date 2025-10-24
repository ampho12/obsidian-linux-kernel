When a structure holds references, it **must** declare lifetimes for those reference members explicitly: 

```rust
struct MyStruct<'a, 'b> {
    ref1: &'a Type1,
    ref2: &'b Type2,
}
```


This leads to a transitive relation if we hold a reference to `MyStruct`. Assume we have a borrow `&'c MyStruct`. Then the following must *always* hold true:


```
'a outlives 'c
'b outlives 'c
```

In rust's notation, this is written as

```
'a : 'c
'b : 'c
```

This makes sense. If `'c` where to outlive `'a` then at some point we will hold a dangling reference to `Type1`.


## General Rule

 Whenever we do
 ```rust
 &'o MyStruct<'a, 'b, 'c>
 ```

we enforce:
```
'a : 'o && 'b: 'o && 'c: 'o
```



## Pretension

The compiler errors around lifetimes don't highlight core issues, just the end issues. This is because even if some coercions cannot occur, the compiler pretends they can happen.

In simple terms, if we have

```rust
'a : 'o
```


but we try coerce our `'o` reference to a `'a` reference, compiler will not immediately error out but proceed by pretending that's possible.


Why??




# Classic Borrow Checker


Consider this

```rust
let mut x: u32 = 22;
let y: &u32 = &x; // Loan L shared borrow x
x += 1; // statement N accesses the path `x`, in a way that violates L
println!(y); // L is live at N as it is used here
```

We expect this to fail as x was mutated while it had a live borrow


Error at program statement N if 

1. the statement N accesses path P
2. the access would cause violation the terms of some loan L
3. the loan L is *live*
## Definitions

### Path

> A `path` P is an expression that leads to a memory lcoation

eg

1. `x` local variable on the stack
2. `x.f` a field of another path
3. `*x.f` 

### Loan

A loan is a name for a borrow expression like `&x`

terms
1. For shared loan, modifying P violates it (directly or indirectly)
2. For mutable loan, any access (direct or indirect) of a path P is violation (no one else should access P while this loan is active)


*Direct*

```rust
let mut x: u32 = 22;
let y = &x;
x += 1; // direct violtion
print(y);
```

*Indirect*

```rust
let mut x: SomeStruct { field: 22 };
let y: &SomeStruct = &x;
x.field += 1; // indirect violation
print(y);
```

A loan is live if the reference created by the loan -- or some reference derived from it -- might be used later.

> lifetime of a loan is the lifetime of that reference that represents the loan.
### Live

> Something that **MIGHT** get used later on


```rust
let mut x = 1
// not live
x = 2;
// not live
if something {
// not live
    x = 4;
// not live
}
// live
print(x);
// not live
```

Liveness analysis is complicated. Classically we compute a lifetime

### Lifetime


We think of it as `'a` or '`b'

Compiler thinks of this as 

> A set of line numbers where the variable **MIGHT** be used.

(Compiler would actually make a control flow graph and compute nodes where it may be used)


so `'a` is a set of lines, so is `'b`. Every reference has a lifetime

```rust
let mut x: u32 = 22;
let y: &'0 u32 = &'1 x;
x += 1;
println!(y);
```


`'0` is the set of lines where `y` is live, `'0: { 2, 3}`

`'1` is not live in the sense of being used, but it must outlive `'0`

`'1` flows into `'0` so `'1` must outlive `'0` (suubtyping)

Thus, `'1: { 2, 3}`

lifetime of a loan is the lifetime of that reference that represents the loan.



# Non-Lexical Lifetimes (2018)


Lifetimes in NLL can be either

1. a set of lines
2. a named lifetime like `'a` which includes all lines in the function

eg.

```rust
fn get_or_insert<'a>(
    map: &'a mut HashMap<u32, String> 
) -> &'a String {

    match HashMap::get(&*map, &22) {
        Some(v) => v,
        None => {
            map.insert(22, String::from("hi"));
            &map[&22]
        }
    }
}
```

In this case, `'a` is the liftime of `&'a mut HashMap` in the function argument and it includes all lines in the function.

Because of this when we call `map.insert` we have 'a live already, so we cannot create another borrow (?)


# Polonius

In rust, we have non-lexical lifetimes, which means 

> scope of each borrow is determined by where it is actually used, not by the text of the program

Compared to classical approach, we do this:

> Compute at origin for each reference R

Instead of computing for a loan L, where it **MIGHT** be referred to by a set R, we compute a set of loans where R **MIGHT** have come from

```rust
/*0*/ let mut x: u32 = 22;
/*1*/ let y: &{L1} u32 = &{L1} x;
/*2*/ x += 1;
/*3*/ println!(y);
```

The loans get encoded into the type of the variables. So type of x would include the loan L1. The type of `y` would also include the loan `L1`. (we can think of y's type  as `&{L1}` )

On line 2, we increment x . The type of x has associated loan L1 which is violated. However, we don't know if `L1` is live or not

To check that, we will look at all variables that are live at line 2. The variable `y` is live at line 2. Therefore all loans in the type of `y` are also live.

Since `L1` is in the type of `y` , it is live. Hence we have an error

> A loan `L` is live at line `N` if at least one variable `y` whose type has `L` is live at line `N`.



Lifetimes are now a sets of loans which are borrow expressions

Resolution increase: outlives graph is now dynamic









