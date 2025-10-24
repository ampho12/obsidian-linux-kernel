




Whenever we do pattern matching in rust


```rust
let Pattern { ... } = pattern;


// or
match pattern {
    Pattern { ... }
}
```


The types must be exactly equal, even for references. Rust will perform implicit conversion to try and achieve this. 

For instance 

```rust
fn main() {
    
    let my_struct = MyStruct {
        field1: NonCopyU32 { value: 42 },
        field2: String::from("Hello, world!"),
    };

    let myst_ref = &my_struct;

    let MyStruct {
        field1: field1,
        field2: field2,
    } = myst_ref;

}
```

can be changed to either 

```rust
    let MyStruct {
        field1: ref field1,
        field2: ref field2,
    } = *myst_ref;
```

or 

```rust
    let &MyStruct {
        field1: ref field1,
        field2: ref field2,
    } = myst_ref;
```


In both cases, we needed the `ref` keyword which is a binding modified.


# Binding Modifiers

These change the way we bind lhs to rhs.

There is one core rule


> Binding modifiers may only be written when default binding mode is move


















