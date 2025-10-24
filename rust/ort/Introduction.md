



# Session


## SessionInputs

This is an enum that can be put into the `session.run(..)` function

```rust
pub enum SessionInputs<'i, 'v, const N: usize = 0> {
    ValueMap(Vec<(Cow<'i, str>, SessionInputValue<'v>)>),
    ValueSlice(&'i [SessionInputValue<'v>]),
    ValueArray([SessionInputValue<'v>; N]),
}
```

it implements these traits

```rust
#[cfg(feature = "std")]
#[cfg_attr(docsrs, doc(cfg(feature = "std")))]
impl<'i, 'v, K: Into<Cow<'i, str>>, V: Into<SessionInputValue<'v>>> From<std::collections::HashMap<K, V>> for SessionInputs<'i, 'v> {
	fn from(val: std::collections::HashMap<K, V>) -> Self {
		SessionInputs::ValueMap(val.into_iter().map(|(k, v)| (k.into(), v.into())).collect())
	}
}

impl<'i, 'v, K: Into<Cow<'i, str>>, V: Into<SessionInputValue<'v>>> From<Vec<(K, V)>> for SessionInputs<'i, 'v> {
	fn from(val: Vec<(K, V)>) -> Self {
		SessionInputs::ValueMap(val.into_iter().map(|(k, v)| (k.into(), v.into())).collect())
	}
}

impl<'i, 'v> From<&'i [SessionInputValue<'v>]> for SessionInputs<'i, 'v> {
	fn from(val: &'i [SessionInputValue<'v>]) -> Self {
		SessionInputs::ValueSlice(val)
	}
}

impl<'v, const N: usize> From<[SessionInputValue<'v>; N]> for SessionInputs<'_, 'v, N> {
	fn from(val: [SessionInputValue<'v>; N]) -> Self {
		SessionInputs::ValueArray(val)
	}
}
```

## Session Input Values
These the the session input values

```rust
pub enum SessionInputValue<'v> {
    ViewMut(ValueRefMut<'v, DynValueTypeMarker>),
    View(ValueRef<'v, DynValueTypeMarker>),
    Owned(Value<DynValueTypeMarker>),
}
```


with similar `From` functions

```rust
impl<'v, T: ValueTypeMarker + ?Sized> From<ValueRefMut<'v, T>> for SessionInputValue<'v> {
	fn from(value: ValueRefMut<'v, T>) -> Self {
		SessionInputValue::ViewMut(value.into_dyn())
	}
}

impl<'v, T: ValueTypeMarker + ?Sized> From<ValueRef<'v, T>> for SessionInputValue<'v> {
	fn from(value: ValueRef<'v, T>) -> Self {
		SessionInputValue::View(value.into_dyn())
	}
}

impl<T: ValueTypeMarker + ?Sized> From<Value<T>> for SessionInputValue<'_> {
	fn from(value: Value<T>) -> Self {
		SessionInputValue::Owned(value.into_dyn())
	}
}

impl<'v, T: ValueTypeMarker + ?Sized> From<&'v Value<T>> for SessionInputValue<'v> {
	fn from(value: &'v Value<T>) -> Self {
		SessionInputValue::View(value.view().into_dyn())
	}
}
```

Thus, we can create an array of zeroed out tensors that are inputs to our model

# Tensors

Tensors in ORT are aliases to value type

```rust
pub type Tensor<T> = Value<TensorValueType<T>>;
pub type TensorRef<'v, T> = ValueRef<'v, TensorValueType<T>>;
pub type TensorRefMut<'v, T> = ValueRefMut<'v, TensorValueType<T>>;


pub type DynTensorRefMut<'v> = ValueRefMut<'v, DynTensorValueType>;
```



