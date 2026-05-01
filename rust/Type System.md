

Rust's type system is great, but some thing are weird



# Opaque Types

```rust
trait SimpleTrait {}

// Foo implements SimpleTrait
struct Foo {}
impl SimpleTrait for Foo {}

fn make() -> impl SimpleTrait {
    Foo {}
}

fn main() {
    let foo: Foo = make(); // will not compile
}
```



# Constrained Implementation and Struct

```rust

struct Foo<T> 
where 
    // there are 3 types of constraints
    T: Future, // Trait bound
    T::Output : Debug, // Associated Type Trait Bound
    T: Future<Output = MyStruct>, // Associated Type Equality Bound
{
}
```

These constraint the type of T and associated types. The struct / impl now cannot assume one type for its defintion it has to build itself as if it works for all T that fit the constraints, not just one. 

So if we don't have the `T: Future<Output = MyStruct>` constriant, when access T::Output, we cannot assume it is MyStruct, even if that's perhaps the only we use Foo.

We must build Foo such that all types that fit the constraints can use the implementation.


