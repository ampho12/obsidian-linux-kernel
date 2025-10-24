
Pinning guarantees that

1. The value will not be moved out of that specific place in memory (i.e. bytes will not be copied out)
2. Pinned value will remain 'valid' at that specific place in memory

Therefore, in rust, `Pin` guarantees:

> The pinned value remains valid at a fixed address, until drop is called




If a type doesn't implement the `Unpin` trait, then the only way to construct a `Pin<Ptr>` is to use `new_unchecked` which is unsafe and now its the programmers responsibility to manage the Pin guarantees.

For instance, the following programs shows a way to break pin guarantees

```rust
use std::task::{Context, Poll};
use std::future::Future;
use std::pin::Pin;

use futures_util::pending;
use futures::task::{
    noop_waker,
    //noop_waker_ref,
};

async fn async_one() -> i32 {
    let s = String::from("hello");
    let sref = &s;
    pending!();
    println!("printing s: {}", sref);
    1i32
}

fn main() {

    let mut pin1 = unsafe { Pin::new_unchecked(Box::new(async_one())) };
    let mut pin2 = unsafe { Pin::new_unchecked(Box::new(async_one())) };

    let waker = noop_waker();
    let mut cx = Context::from_waker(&waker);

    println!("{:?}", pin1.as_mut().poll(&mut cx));

    // now we swap the futures so that self references start dangling
    unsafe {
        let fa: &mut _ = Pin::get_unchecked_mut(pin1.as_mut());
        let fb: &mut _ = Pin::get_unchecked_mut(pin2.as_mut());
        std::mem::swap(fa, fb);
    }

    // now poll again
    println!("{:?}", pin2.as_mut().poll(&mut cx));
}
```

In the first unsafe block, we create a Pin by saying "the programmer has the responsibility to manage the pin". Rust then prevents us from moving out of the pin. However, 

## Invalidation

A values can be invalidated in multiple ways, but these involve "storage reuse"


### Memory De-allocation

The value was on the stack and it got dropped and some other value was constructed in its place.

Heap allocated value is dropped and the heap storage is reused for another object.
    
### Without De-allocation
If we have an `Option` which contains a `Some(v)` where `v` is pinned, then any data type holding a `Pin<Ptr>` where `Ptr` points to `v`, will point to an invalid data when `None` is added.
    
```
                    +-------------------+
                    | Discriminant [Some]
                    +-------------------+
Ptr points here ->  | Field1
                    | Field2
                    | Field3
                    +-------------------+
```

when we set this to non
```
                    +-------------------+
                    | Discriminant [None]
                    +-------------------+
Ptr points here ->  | 0xdeadbeef
                    | 0xdeadbeef
                    | 0xdeadbeef
                    +-------------------+
```


A similar case can happen if a vector holds pinned values and then its size shrinks

To avoid these issues, pinned data must be invalidated to inform all pointers and references that this `Pin` is not valid



# Projection 


## Motivation

Consider the following code

```rust
#[derive(Debug)]
struct NonCopyU8 {
    value: u8,
}

impl NonCopyU8 {
    fn new(value: u8) -> Self {
        NonCopyU8 {
            value,
        }
    }
}

enum ExpStorage {
    Configure(NonCopyU8),
    Operate(NonCopyU8),
}

impl Future for ExpStorage {
    type Output = std::io::Result<()>;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context) -> Poll<Self::Output> {
        *self = ExpStorage::Operate(NonCopyU8::new(0));
        Poll::Ready(Ok(()))
    }
}
```

This compiles and works as expected as we can `DerefMut` on `self: Pin<&mut Self>`.

However, if we do something like

```rust
#[derive(Debug)]
struct NonCopyU8 {
    value: u8,
    _pin: PhantomPinned,
}

impl NonCopyU8 {
    fn new(value: u8) -> Self {
        NonCopyU8 {
            value,
            _pin: PhantomPinned,
        }
    }
}

enum ExpStorage {
    Configure(NonCopyU8),
    Operate(NonCopyU8),
}

impl Future for ExpStorage {
    type Output = std::io::Result<()>;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context) -> Poll<Self::Output> {
        *self = ExpStorage::Operate(NonCopyU8::new(0));
        Poll::Ready(Ok(()))
    }
}
```

Now `self` is no longer `DerefMut`. Why? Because `DerefMut` is implemented for `Pin<Ptr>` if `Ptr: DerefMut` and `<Ptr as Deref>::Target : Unpin`.

We just took away the `property` by telling the compiler that the structure `NonCopyU8` cannot be moved after it is pinned (until the pin is dropped).

However, what if we had values that are safe to be moved while some are not? Do we pin the whole structure? No, one way to bypass this is simply drop into unsafe 

```rust
impl Future for ExpStorage {
    type Output = std::io::Result<()>;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context) -> Poll<Self::Output> {
        let this = unsafe { Pin::get_unchecked_mut(self.as_mut()) };
        *this = ExpStorage::Operate(NonCopyU8::new(0));
        Poll::Ready(Ok(()))
    }
}
```

now, however, its is the programmer's responsibility to maintain correctness of the structure.

What if we had a struct where only some fields need to be pinned

```rust
struct Bar {
    a: NeedsPinning,
    b: u32,
    c: NeedsPinning,
}
```

In this case, we would have to make the whole structure mutable in order to just modify b. Since we still want to provide pinning guarantees on a and c however, getting an unchecked mutable reference for thos fieldsd doesn't make sense.

So we "project" the structure into another structure where we repin a and c

```rust
struct BarProj {
    a: Pin<&mut NeedsPinning>,
    b: &mut u32,
    c: Pin<&mut NeedsPinning>,
}
```

Now, we can simply do something like

```rust
poll(self: Pin<&mut Self>, cx: &mut Context) -> Poll<Self::Output> {

    let this = self.project();
    *this.b += 1;
}
```

both a and c are projected pins, we can call `poll` on them too if needed

```rust
this.sub_fut.poll(cx)
```

as we obtain `Pin<&mut impl Future<Output = ...>>` as part of `this.sub_fut`. An example of such a struct is 

```rust
#[derive(Debug)]
#[pin_project]
pub struct ExpState<T> 
where
    T: Future<Output = std::io::Result<()>>, /* T can be pinnable */
{
    pub common1: u32,
    #[pin]
    storage: ExpStorage,

    #[pin]
    sub_fut: T,
}
```


# Unpin

This is a trait that is auto-implemented. If any of the structs within in an enum is `!Unpin` the whole enum is `!Unpin`. 

However if we provide a manual implementation of Unpin for a subset of a type, then Unpin would not be auto implemented. Eg

```rust
impl<State> Unpin for Socket<State>
where
    State: SocketConfigurator + Unpin,
{ }
```

prevents autoimplementation for all State that doesn't satisfy these trait bounds


If a type implements `!Unpin` this means that once pinned, it is not safe to move the type. Otherwise it is still safe to consume the `Pin<Ptr>` and move the internal data.


We can't project an enum like we can project a struct.