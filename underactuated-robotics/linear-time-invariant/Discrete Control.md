

If your sampling rate is 100Hz, the signals you can control are 10Hz. 

Why is this true for zero order hold systems - i.e majority of software we write today? 

- A state machine is basically a 0 order hold system.


# Phase Lag

Say we run a control law at 100Hz.

```
out = kp * (target - current)
```

This means we sample -> calculate -> output (hold) -> wait for next cycle. 

Our sampling rate is is 10ms. We can actually transform this to a continuous system such that the dynamics are mathematically equivalent. The way to change a discrete signal to a continuous one such that system dynamics are equivalent is via the relation

$$
C(\text{discrete}_T, s) = C(\text{continuous}, s) \cdot e^{-sT/2}
$$

The delay due to sampling is a fixed $T/2$ this fixed lag for any input signal. Phase shift however, is not measured in absolute terms: it is a percent of input frequency. For a low freqeuncy signal, the same phase shift is not a small phase. For a faster signal, this is a large phase.

For example, consider a phase shift of $T/2 = 5\text{ms}$. (10ms sample period).

If signal frequency is 5Hz, time period is 1/5 = 200ms. 5/200 = 2.5% phase shift. If we map this to 360 degrees, this is 2.5 / 100 * 360 = 9.0 degrees. 

If we map this to a 40hz signal though, the phase shfit would increase 8 fold to 72 degrees.

Here is a visualization why phase shift by T/2 of continous makes sense.

![[Pasted image 20260128145916.png]]


# Z Transform