

## `tokio::join!`

This macro essentially returns a future (`poll_fn`) that upon each poll will poll all futures it was meant to poll.

Example

```rust
tokio::join!(fut1, fut2, fut3)
```

desugars to

```rust
{

    for each fut in (fut1, fut2, fut3) poll them non deterministically and when all three futures are done return (Ready1, Ready2, Ready3);
}
```

