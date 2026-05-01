







The idea is that a we have a state machine whose transitions are futures.

Every time we call `next()` on the main state machine, it will delegate to the 
1. the currently inflight future that is driving the state change
2. the state itself to produce an inflight future.

Either way, `next()` gives a future that calls poll on the internal future.


When we drive the state machine itself, we delegate to the state

The state machine is a stream, so calling `next()` on it returns a `Future` that holds a `&mut Self` to the state machine.

This future will delegate to the per state future via  `&mut Self`. This per state future will return a `(state, result)` pair that indicates which state we landed on and if it was succesful, failure, some other warning etc.

This way, `next()` drives the main state machine to a different state by delegating to either the current state or the inflight transition.




















# Frontend


A way to request a future, fire it, and forget. Perhaps before firing it, we can wrap it in a timeout.



# Backend


Each state needs a way to return a future that holds the state itself + the factor.

State and StateFactory are both tied to the lifetime of the Store.

i.e
```
'State == 'StateFactory
```

at all times


The stream itself should own the current state and the factory. The factory could own the store via some Heap pointer, this is not necessary however.


```rust
#[derive(Debug)]
struct Store {
    str1: String,
    str2: String,
    strc: String,
}

#[derive(Debug)]
struct State1<'a> {
    str1_r: &'a mut String,
    strc_r: &'a mut String,
}

#[derive(Debug)]
struct State2<'a> {
    str2_r: &'a mut String,
}

#[derive(Debug)]
enum StateStore<'a> {
    StateOne(State1<'a>),
    StateTwo(State2<'a>),
}

#[derive(Clone, Copy, Debug)]
pub enum StateTag {
    One,
    Two,
}

#[derive(Debug)]
struct StateFactory<'a> {
    str1: Option<&'a mut String>,
    str2: Option<&'a mut String>,
    strc: Option<&'a mut String>,
}

impl<'a> StateFactory<'a> {
    pub fn new(store: &'a mut Store) -> Self {
        Self {
            str1: Some(&mut store.str1),
            str2: Some(&mut store.str2),
            strc: Some(&mut store.strc),
        }
    }

    fn put(&mut self, st: StateStore<'a>) {
        match st {
            StateStore::StateOne(st) => {
                let State1{ str1_r, strc_r } = st;
                self.str1 = Some(str1_r);
                self.strc = Some(strc_r);
            }
            StateStore::StateTwo(st) => {
                let State2{ str2_r } = st;
                self.str2 = Some(str2_r);
            }
        }
    }

    /// Instead of the get function being public, provide an
    /// initial state when new is called. The only public api should 
    /// be swap
    pub fn get(&mut self, tag: StateTag) -> StateStore<'a> {
        use std::mem::take;
        match tag {
            StateTag::One => {
                let str1_r = take(&mut self.str1).expect("str1 was None");
                let strc_r = take(&mut self.strc).expect("strc was None");
                StateStore::StateOne(State1 { str1_r, strc_r })
            }
            StateTag::Two => {
                let str2_r = take(&mut self.str2).expect("str2 was None");
                StateStore::StateTwo(State2 { str2_r })
            }
        }
    }

    pub fn swap(&mut self, st: StateStore<'a>, tag: StateTag) -> StateStore<'a> {
        self.put(st);
        self.get(tag)
    }
}

```


![[Drawing 2025-06-20 20.26.01.excalidraw]]