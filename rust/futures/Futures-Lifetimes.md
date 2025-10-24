
Every struct that has a reference must have an explicit lifetime. Consequently, all future implementations for this must also carry the lifetime generic.

```rust
struct ReadyFut<'a> {
    shared: &'a mut ActuatorBusSharedState,
    stage:   u8,
}

impl<'a> Future for ReadyFut<'a> {
    type Output = ActuatorBusState;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        // use `self.shared` and bump `stage`…
    }
}
```


