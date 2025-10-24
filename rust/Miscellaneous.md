
When pattern matching against a reference (i.e the scrutinee is a reference `&T`)


```rust
let Some(a) = &my_opt;
```

Rust auto inserts two things for ergonomics


```rust
let Some(ref a) = *&my_opt;
```

- [ ] i.e match by reference

When we do 

```rust
let Some(a) = *&my_opt;
```

There is no compiler sugar and it will compile to "match and move out of my_opt". `my_opt` is a reference however, so it cannot be moved out from.


j