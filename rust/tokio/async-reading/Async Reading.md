
In tokio's `AsyncFd` you have two ways to wait for readable readiness.





# Tokio Architecture


Tokio has the following components

- One global "injector" queue 
- Per thread task-pool

When we create futures using `tokio::spawn` , they are added to the injector queue and then picked by into the local per thread task-pool.

The threads poll the futures from their local task pool. When any future returns Poll::Pending, it gets registered with the reactor with a waker. The waker wakes up the task and puts it back into **local** task-pool (not the global injector).






# Composite Futures


## `tokio::join!`

It generates a future and calls await on it such that 

`tokio::join!(f1, f2, f3, f4)`

get polled in the following order (if all of the return poll pending)


```
f1 -> f2 -> f3 -> f4

f2 -> f3 -> f4 -> f1

f3 -> f4 -> f1 -> f2

// so on
```

eg.

```rust
async fn fut1() {
    log::info!("fut1 1");
    tokio::task::yield_now().await;
    log::info!("fut1 2");
    tokio::task::yield_now().await;
    log::info!("fut1 3");
}

async fn fut2() {
    log::info!("fut2 1");
    tokio::task::yield_now().await;
    log::info!("fut2 2");
    tokio::task::yield_now().await;
    log::info!("fut2 3");
}

async fn fut3() {
    log::info!("fut3 1");
    tokio::task::yield_now().await;
    log::info!("fut3 2");
    tokio::task::yield_now().await;
    log::info!("fut3 3");
}

tokio::join!(fut1(), fut2(), fut3());
```

prints

```
// f1 -> f2 -> f3 on first loop of tokio::join!
fut1 1
fut2 1
fut3 1

// f2 -> f3 -> f1 on second loop of tokio::join!
fut2 2
fut3 2
fut1 2

// f3 -> f1 -> f2 on third loop of tokio::join!
fut3 3
fut1 3
fut2 3
```



## `tokio::time::timeout`

Tokio's timeout helps create time-bounded futures. When we build a timeout future like 

```rust

let timeout_fut = tokio::time::timeout(
    std::time::Duration::from_millis(50),
    my_fut,
);
```

This wraps `my_fut` within some bounds like so. The full details are not critical

```rust
impl<T> Future for Timeout<T>
    T: Future,
{
    type Output = Result<T::Output, Elapsed>;

    fn poll(self: Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Self::Output> {
        let me = self.project();

        let had_budget_before = coop::has_budget_remaining();

        // First, try polling the future
        if let Poll::Ready(v) = me.value.poll(cx) {
            return Poll::Ready(Ok(v));
        }

        let has_budget_now = coop::has_budget_remaining();

        let delay = me.delay;

        let poll_delay = || -> Poll<Self::Output> {
            match delay.poll(cx) {
                Poll::Ready(()) => Poll::Ready(Err(Elapsed::new())),
                Poll::Pending => Poll::Pending, 
            }
        };

        if let (true, false) = (had_budget_before, has_budget_now) {
            // if it is the underlying future that exhausted the budget, we poll
            // the `delay` with an unconstrained one. This prevents pathological
            // cases where the underlying future always exhausts the budget and
            // we never get a chance to evaluate whether the timeout was hit or
            // not.
            coop::with_unconstrained(poll_delay)
        } else {
            poll_delay()
        }
    }
}
```

But timeout works like the following

```rust
// delay is a tokio::time::Sleep(dur) future
poll() {
    match inner.poll() {
        Poll::Ready(v) => Poll::Read(Ok(v)),
        Poll::Pending => match delay.poll() {
            Poll::Read(()) => Poll::Read(Err(Elapsed::new())),
            Poll::Pending => Poll::Pending,
        }
    }
}
```

So we first poll our future, then the sleep future. 

> If our future is cpu heavy, then we may never return from poll on the inner future and check the timeout , rendering the timeout useless.

It is also worth noting that depending on scheduling, we may have the timeout fire strangely due to **co-operative scheduling with the timer wheel**.

E.g. consider the following 

```rust
async fn cpu_bound(n: u64) {
    log::info!("id: {:?} cpu bound fib({})", std::thread::current().id(), n);

    let mut a = 0;
    for i in 0..10_000_000 {
        a = 0;
        let mut b = 1;
        for _ in 0..(n - 1) {
            let c = a + b;
            a = b;
            b = c;
        }
        if i == 0 || i == 5_000_000 || i == 7_000_000 {
        // if i == 0 || i == 5_000_000 {
            log::info!("id: {:?} cpu bound fib({}) i: {}", std::thread::current().id(), n, i);
            tokio::task::yield_now().await;
        }

    }
    let result = a;
    log::info!("id: {:?} cpu bound fib({}) = {}", std::thread::current().id(), n, result);
}
```

We have a cpu bound workload that periodically yields. 

Let the timeout be

```rust
let timeout_fut = tokio::time::timeout(
    std::time::Duration::from_millis(50),
    cpu_bound(45),
);
```

This should fire well before 5 million iterations. (which take about 1s on my machine).

However, if we do

```rust
// create single threaded runtime
let rt_s = tokio::runtime::new_current_thread().enable_time().build().unwrap()

// put the future in global injector queue and then wait for it to complete
rt_s.block_on(rt_s.spawn(timeout_fut));
```

We see

```
[tokio_exp] id: ThreadId(1) cpu bound fib(45)
[tokio_exp] id: ThreadId(1) cpu bound fib(45) i: 0
[tokio_exp] id: ThreadId(1) cpu bound fib(45) i: 5000000
[tokio_exp] id: ThreadId(1) cpu bound fib(45) i: 7000000 # third yield!
[tokio_exp] id: ThreadId(1) ret: Err(Elapsed(()))
[tokio_exp] Elapsed time: 1.613521098s
```

Why did it take 3 yields for the timer to fire? To answer that, we will use a multi_thread executor.


```rust
// multi threaded runtime
let rt = tokio::runtime::Builder::new_multi_thread()
    .worker_threads(3)
    .enable_time()
    .build().unwrap();

// put the future in global injector queue and then wait for it to complete
rt_s.block_on(rt_s.spawn(timeout_fut));
```

We now see

```
[tokio_exp] id: ThreadId(3) cpu bound fib(45)
[tokio_exp] id: ThreadId(3) cpu bound fib(45) i: 0
[tokio_exp] id: ThreadId(3) cpu bound fib(45) i: 5000000 // second yield
[tokio_exp] id: ThreadId(3) ret: Err(Elapsed(()))
[tokio_exp] Elapsed time: 1.0301300s
```

we see the timer fires after the second yeild! This suggests some kind of blocking.

This is indeed correct. Tokio's timer wheel is able to run on a thread when all futures for that cycle have been run. For the timeout there, is only one top level future. On a single threaded executor, we see

### `yield_now().await`

- calls `cx.waker().wake_by_ref()`: this puts the task back in the local threads ready queue
-  returns `Poll::Pending`

```
# Iter1 at i = 0
timeout_fut.poll(cx)
- cpu_heavy.poll(cx) -> yield_now().await calls wake_by_ref() to enqueue task on local queue and returns Poll::Pending.
- delay.poll(cx) registers same waker with tokio's timerwheel (not reactor)

timer_wheel -> 50ms not elapsed, sleep
reactor: not-needed (can be disabled!)

# Iter2 at i = 5,000,000
timeout_fut.poll(cx)
- cpu_heavy.poll(cx) -> yield_now().await calls wake_by_ref() to enqueue task on local queue and returns Poll::Pending.
- delay.poll(cx) checks if deregistered/awoken . which is false so it does nothing.

timer_wheel -> 50ms elapsed, call wake_by_ref() on the same task. Since the task is already enqueued on the localy queue ,waker coalescing makes this no-op.
reactor: not-needed (can be disabled!)

# Iter3 at i = 7,000,000
timeout_fut.poll(cx)
- cpu_heavy.poll(cx) -> yield_now().await calls wake_by_ref() to enqueue task on local queue and returns Poll::Pending.
- delay.poll(cx) checks if deregistered/awoken. This returns true and we get Poll:Ready(Elapsed()) which is returned
```

The issue is that timer_wheel can only make progress when `timeout_fut` is done which takes more than 50ms. 

If we spawn two threads, the timer wheel can run in the other thread

```
# Iter1 at i = 0
timeout_fut.poll(cx)
- cpu_heavy.poll(cx) -> yield_now().await calls wake_by_ref() to enqueue task on local queue and returns Poll::Pending.
- delay.poll(cx) registers same waker with tokio's timerwheel (not reactor)

--- 50 ms elapsed, timer_wheel calls wake_by_ref in the second thread ----

# Iter2 at i = 5,000,000
timeout_fut.poll(cx)
- cpu_heavy.poll(cx) -> yield_now().await calls wake_by_ref() to enqueue task on local queue and returns Poll::Pending.
- delay.poll(cx) checks if deregistered/awoken. This returns true and we get Poll:Ready(Elapsed()) which is returned
```




# Waker

In tokio, waker simply enqueue tasks back into a local thread queue where the original spawn-future was scheduled to run.

There is also waker coalescing in tokio, where every `wake_by_ref()` goes through the task_handle which has a notified atomic flag. If the flag is false, `wake_by_ref` sets it to true and puts task in local ready queue. Otherwise, `wake_by_ref()` is a no-op.

# Reactor

> Tokio has a reactor future.

Like all futures, this future is cooperatively scheduled. So, for instance, if on a single threaded executor we have a cpu bound future (i.e doesn't return `Poll::Pending` or `Poll::Ready(T)` and keeps processing), then the reactor will never run and events 
registered will never fire.

Consider an example where we want to do some time-bounded work using `tokio::timeout`. `tokio::time::timeout` registers a waker on a timer event. However this timer event needs to be polled by the reactor future. If the work that we want to time bound is cpu bound and never returns, the timeout will have no effect

```rust
// cpu bound workloaded that computes the same fibonacci number
// 10 million times
async fn cpu_bound(n: u64) {
    log::info!("id: {:?} cpu bound fib({})", std::thread::current().id(), n);

    let mut a = 0;
    for _i in 0..10_000_000 {
        a = 0;
        let mut b = 1;
        for _ in 0..(n - 1) {
            let c = a + b;
            a = b;
            b = c;
        }
    }
    let result = a;
    log::info!("id: {:?} cpu bound fib({}) = {}", std::thread::current().id(), n, result);
}


async fn driver() {
    // create the future, no polling yet
    // compute fib(45) but timeout if it takes too long
    let timeout_fut = tokio::time::timeout(
        time::Duration::from_millis(100),
        cpu_bound(45),
    );

    // poll the future
    let _ = timeout_fut.await;
}

fn main() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_time()
        .build().unwrap();
    let drv = driver();
    let start = std::time::Instant::now();
    rt.block_on(drv);
    let elapsed = start.elapsed();
    log::info!("Elapsed time: {:?}", elapsed);
}
```

This prints
```
INFO  [tokio_exp] id: ThreadId(1) cpu bound fib(45)
INFO  [tokio_exp] id: ThreadId(1) cpu bound fib(45) = 1134903170
INFO  [tokio_exp] Elapsed time: 1.826s
```

The 100ms timeout didn't do anything as our work was cpu bound!. To show that the poller future would indeed run if the fib future had yeilded, we can add `tokio::sched::yield_now().await` which basically tells tokio to yield the cpu and run other futures (e.g. our reactor!)

```rust
async fn cpu_bound(n: u64) {
    log::info!("id: {:?} cpu bound fib({})", std::thread::current().id(), n);

    let mut a = 0;
    for _i in 0..10_000_000 {
        a = 0;
        let mut b = 1;
        for _ in 0..(n - 1) {
            let c = a + b;
            a = b;
            b = c;
        }
        // yield the cpu after every iteration
        tokio::task::yield_now().await;
    }
    let result = a;
    log::info!("id: {:?} cpu bound fib({}) = {}", std::thread::current().id(), n, result);
}
```

This prints
```
INFO  [tokio_exp] id: ThreadId(1) created timeout future
INFO  [tokio_exp] id: ThreadId(1) cpu bound fib(45)
INFO  [tokio_exp] ret: Err(Elapsed(()))
INFO  [tokio_exp] Elapsed time: 101.001422ms
```

We can see we ran into the elapsed error (as we wanted) and our program took roughly 100ms.




In tokio there are the following ways to read data:


# AsyncFd

This is a handle to a raw file descriptor that is registered with tokio's mio's poll registery with a readable interest. Tokio has a a reactor thread that will poll on the registry (i.e all events registered in the registry) and wake up the futures associated with an event.

Thus, the `readable()` and `writable()` async functions implemented on `AsyncFd` are basically futures that poll on the state of the underlying raw file descriptor.



```rust
    pub async fn ready(&self, interest: Interest) -> io::Result<AsyncFdReadyGuard<'_, T>> {
        let event = self.registration.readiness(interest).await?;

        Ok(AsyncFdReadyGuard {
            async_fd: self,
            event: Some(event),
        })
    }
```


```rust
    pub fn poll_read_ready<'a>(
        &'a self,
        cx: &mut Context<'_>,
    ) -> Poll<io::Result<AsyncFdReadyGuard<'a, T>>> {
        let event = ready!(self.registration.poll_read_ready(cx))?;

        Poll::Ready(Ok(AsyncFdReadyGuard {
            async_fd: self,
            event: Some(event),
        }))
    }
```


In `registration.rs`

```rust
    /// A registration instance represents two separate readiness streams. One
    /// for the read readiness and one for write readiness. These streams are
    /// independent and can be consumed from separate tasks.
    ///
    /// **Note**: while `Registration` is `Sync`, the caller must ensure that
    /// there are at most two tasks that use a registration instance
    /// concurrently. One task for [`poll_read_ready`] and one task for
    /// [`poll_write_ready`]. While violating this requirement is "safe" from a
    /// Rust memory safety point of view, it will result in unexpected behavior
    /// in the form of lost notifications and tasks hanging.
    ///
    /// ## Platform-specific events
    ///
    /// `Registration` also allows receiving platform-specific `mio::Ready`
    /// events. These events are included as part of the read readiness event
    /// stream. The write readiness event stream is only for `Ready::writable()`
    /// events.
    ///
    /// [`new_with_interest_and_handle`]: method@Self::new_with_interest_and_handle
    /// [`poll_read_ready`]: method@Self::poll_read_ready`
    /// [`poll_write_ready`]: method@Self::poll_write_ready`
    #[derive(Debug)]
    pub(crate) struct Registration {
        /// Handle to the associated runtime.
        ///
        /// TODO: this can probably be moved into `ScheduledIo`.
        handle: scheduler::Handle,

        /// Reference to state stored by the driver.
        shared: Arc<ScheduledIo>,
    }

```

```rust
    pub(crate) async fn readiness(&self, interest: Interest) -> io::Result<ReadyEvent> {
        let ev = self.shared.readiness(interest).await;

        if ev.is_shutdown {
            return Err(gone());
        }

        Ok(ev)
    }
```

```rust
    pub(crate) fn poll_read_ready(&self, cx: &mut Context<'_>) -> Poll<io::Result<ReadyEvent>> {
        self.poll_ready(cx, Direction::Read)
    }
```

```rust
    /// Polls for events on the I/O resource's `direction` readiness stream.
    ///
    /// If called with a task context, notify the task when a new event is
    /// received.
    fn poll_ready(
        &self,
        cx: &mut Context<'_>,
        direction: Direction,
    ) -> Poll<io::Result<ReadyEvent>> {
        ready!(crate::trace::trace_leaf(cx));
        // Keep track of task budget
        let coop = ready!(crate::task::coop::poll_proceed(cx));
        let ev = ready!(self.shared.poll_readiness(cx, direction));

        if ev.is_shutdown {
            return Poll::Ready(Err(gone()));
        }

        coop.made_progress();
        Poll::Ready(Ok(ev))
    }
```


in `scheduled_io.rs`

```rust
pub(crate) struct ScheduledIo {
    pub(super) linked_list_pointers: UnsafeCell<linked_list::Pointers<Self>>,

    /// Packs the resource's readiness and I/O driver latest tick.
    readiness: AtomicUsize,

    waiters: Mutex<Waiters>,
}
```




# AsyncRead

Tokio's abstraction for "asynchronous reads" over any I/O source (sockets, files, serial-ports, etc).

At the core, it defines one method

```rust
pub trait AsyncRead {
    /// Attempt to read into `buf`, registering the waker if not ready.
    fn poll_read(
        self: Pin<&mut Self>,
        cx: &mut Context<'_>,
        buf: &mut ReadBuf<'_>,
    ) -> Poll<io::Result<()>>;
}
```


```rust
fn poll_read(
    self: Pin<&mut Self>,
    cx: &mut Context<'_>,
    buf: &mut ReadBuf<'_>,
) -> Poll<io::Result<()>> {
    // 1) Ask the AsyncFd if it’s readable yet
    let mut guard = match afd.poll_read_ready(cx)? {
        Poll::Ready(g) => g,              // go drain
        Poll::Pending   => return Poll::Pending,
    };

    // 2) Do exactly one non-blocking read into the ReadBuf
    let result = guard.try_io(|inner| {
        // inner: &mut SerialStream
        // perform the raw read
        let filled = inner.read(buf.initialize_unfilled())?;
        buf.advance(filled);
        Ok(())
    });

    // 3) If syscall said “would block”, loop (Pending)
    match result {
        Ok(Ok(_))        => {
            guard.clear_ready();        // reset edge-trigger flag
            Poll::Ready(Ok(()))
        }
        Ok(Err(e))       => Poll::Ready(Err(e)),  // real I/O error
        Err(_would_block) => {
            // readiness was stale—try again later
            Poll::Pending
        }
    }
}
```

