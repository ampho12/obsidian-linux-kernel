

# Array Types
There are 3 array types

1. `Array<S, D>`
2. `ArcArray<S, D>`
3. `CowArray`

All of them implement `ArrayBase` and we can get different views into them using `ArrayView` and `ArrayViewMut` types.

`S` is the type of data
`D` is the type data

We can create a new 2x2x3 array like this

```rust
ndarray::Array3::<f64>::zeros((2, 2, 3));
ndarray::Array::<f64, ndarray::Ix3>::zeros((2, 2, 3));
ndarray::Array::<f64, ndarray::Dim<[usize;3]>>::zeros((2, 2, 3));
```

all are equivalent.

> The logical order of any array’s elements is the row major order (the rightmost index is varying the fastest). The iterators .iter(), .iter_mut() always adhere to this order, for example.


`ArrayView` and `ArrayViewMut` and read only an read-write views respectively. 



> All types of arrays and views are just specializations of ArrayBase

```rust
// array
pub type Array<A, D> = ArrayBase<OwnedRepr<A>, D>;
pub type ArcArray<A, D> = ArrayBase<OwnedArcRepr<A>, D>;
pub type CowArray<'a, A, D> = ArrayBase<CowRepr<'a, A>, D>;

// views
pub type ArrayView<'a, A, D> = ArrayBase<ViewRepr<&'a A>, D>;
pub type ArrayViewMut<'a, A, D> = ArrayBase<ViewRepr<&'a mut A>, D>;
```

# NdProducer

Core abstraction for anything that can "produce" an n-dimensional set of items.

```rust
pub trait NdProducer {
    /// The type of element produced per “cell”
    type Item;
    /// The dimension (shape) of the producer
    type Dim: Dimension;

    /// Return the shape of this producer
    fn raw_dim(&self) -> Self::Dim;
}
```


