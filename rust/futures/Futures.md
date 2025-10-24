Rust futures are lazy and must be driven to completion by someone else.







## Await

An `await` call basically says

```
you (caller future) can continue if I am done, otherwise you must wait for me.
```

Therefore, it is inherently bound to be called within a future (e.g async fn).


Within a future, calling await on another future

```rust
let v = some_future.await;
```

is syntactic sugar by the compiler 

```rust
// inside the generated Future::poll for your async fn
// assume `some_future` has been pinned and stored in state already

match Pin::new(&mut this.some_future).poll(cx) {
    Poll::Ready(val) => {
        // extract the value and continue
        let v = val;
    }
    Poll::Pending => {
        // yield control: return Pending, and when the waker fires,
        // resume here (re-poll from this point)
        return Poll::Pending;
    }
}

```

We see that await returns `Poll::Pending` if the future is not ready. This `Poll::Pending` will bubble up the `.await` chain until it reaches the root future or somewhere where `Poll::Pending` is handled, e.g. by registering a waker.

## Await State Machine

Await has another critical function -- it changes the code flow into a state machine. Consider the following code:


```rust
struct Counter {
    count: usize,
}

impl Future for Counter {
    type Output = usize;

    fn poll(mut self: std::pin::Pin<&mut Self>, cx: &mut std::task::Context<'_>) -> std::task::Poll<Self::Output> {
        if self.count == 0 {
            std::task::Poll::Ready(0)
        } else {
            println!("Counting down: {} -> {}", self.count, self.count - 1);
            self.count -= 1;
            cx.waker().wake_by_ref();
            std::task::Poll::Pending
        }
    }
}

async fn count_plus_one(start: usize) {
    let counter1 = Counter { count: start };
    let counter2 = Counter { count: 1 };
    counter1.await;
    counter2.await;
}
```

This would be compiled into a state machine, where once we are done `await-ing` counter1, we will await counter2. Subsequent calls to the poll on the future returned by count_to_3 will directly call `counter2.poll()` and not `counter1.poll()` once `counter1.poll()` has returned `Poll::Ready(0)`

This code would be desugared something like so:

```rust
enum DriverStateMachine {
    Start(start),
    AwaitCounter1(Counter),
    AwaitCounter2(Counter),
    Done,
}

impl Future for DriverStateMachine {
    type Output = ();

    fn poll(mut self: std::pin::Pin<&mut Self>, cx: &mut std::task::Context<'_>) -> std::task::Poll<Self::Output> {
        loop {
            match *self {
                DriverStateMachine::Start(start) => {
                    println!("Starting...");
                    *self = DriverStateMachine::AwaitCounter1(Counter { count: start });
                }

                DriverStateMachine::AwaitCounter1(ref mut counter) => {
                    match Pin::new(counter).poll(cx) {
                        std::task::Poll::Pending => {
                            println!("Awaiting Counter 1 ...");
                            return std::task::Poll::Pending;
                        }
                        std::task::Poll::Ready(_) => {
                            println!("Counter 1 finished");
                            *self = DriverStateMachine::AwaitCounter2(Counter { count: 1 });
                        }
                    }
                }
                DriverStateMachine::AwaitCounter2(ref mut counter) => {
                    match Pin::new(counter).poll(cx) {
                        std::task::Poll::Pending => {
                            println!("Awaiting Counter 2...");
                            return std::task::Poll::Pending;
                        }
                        std::task::Poll::Ready(_) => {
                            println!("Counter 2 finished");
                            *self = DriverStateMachine::Done;
                        }
                    }
                }
                DriverStateMachine::Done => {
                    return std::task::Poll::Ready(())
                }
            }
        }
    }
}

fn count_to_plus_one(count: usize) -> impl Future<Output = ()> {
    DriverStateMachine::Start(count)
}
```

so subsequent calls to poll will call a loop that matches until we run into a return of `Poll::Pending`.

In the compiler, the state machine and state logic is implemented with the help of a closure.

```rust

fn count_to_plus_one(start) -> impl Future<Output = ()> {
    poll_fn(count_to_plus_one_closure)
}
```

`count_to_plus_one` will capture any variables in its environment used by the closure. More space will be allocated for a state variable.

> `poll_fn` simply returns a future whose `poll` method is the closure











