
Linear time invariant systems are cool. Why is that?

Let's start with what an linear time invariant or LTI system means.

The "Linear" part. If input $u_1$ produces output $y_1$, and $u_2$ produces $y_2$ then $\alpha u_1 + \beta u_2$ produces $\alpha y_1 + \beta y_2$.

The "Time Invariant" part. If we apply an input $u_1$ now or at any other time in the future, it will still produce the same output starting at when the input was applied. More concretely
$$
u(t) \mapsto y(t) \implies u(t - \tau) \mapsto y(t - \tau)
$$

Recall that $u(t + \tau)$ means applying $u(t)$ but turning it "on" at $t + \tau$.


Now let's talk about impulse responses. An impulse is like a finite force applied across an infinitesimal time horizon. We will not go into the intuition behind this (should be easy to check from other resources). We represent this using the Dirac delta $\delta(t)$, which is an impulse of magnitude 1 applied at $t = 0$.

We define the time-domain transfer function to be the impulse response of a system. That is if I apply the input $u(t) = \delta(t)$, then the output $y(t) = g(t)$ is the transfer function.
$$
\delta(t) \mapsto g(t)
$$

That's all the theory we need for some cool math facts. After the cool math facts, we will look at practical stuff.

## Cool Math Fact 1

What happens if I apply multiple impulses in succession?

Let's look at an example, let $g(t) = cos(t)$

Say we apply an impulse $\delta(t)$ and ask the response at $t = \pi$. This is easy enough, we know $y(t) = g(t)$ for an impulse $\delta(t)$, so $y(\pi) = g(\pi) = cos(\pi) = -1$

What if we applied the impulse instead at $t = \pi/2$ ? Now $y(t) = g(t - \pi/2)$ (the response just starts at $t = \pi/2$). So at $t = \pi$, $y(\pi) = g(\pi - \pi/2) = cos(\pi/2) = 0$. This is because our system is time invariant.

Strictly speaking, $\delta(t - \tau) \mapsto \mu(t - \tau)g(t - \tau)$ where $\mu$ is the step function
 $$
u(t - \tau) = \begin{cases}
1 & t >= \tau \\
0 & t < \tau
\end{cases}
$$

but we will omit this for notational brevity.

What if we now apply the input $u(t) = \delta(t) + \delta(t - \pi / 2)$ ?  We know our system is linear so
$$
\delta(t) + \delta(t - \pi / 2) \mapsto g(t) + g(t - \pi/2)
$$
So $y(t) = g(t) + g(t - \pi/2)$. This is simply $(-1)+ 0 = -1$.

Instead of two, we can keep doing this with infinitely many impulses
$$
\sum_i \delta(t - t_i) \mapsto \sum_i g(t - t_i)
$$

We can also vary the amplitude at each step $i$
$$
\sum_i f(t_i)\delta(t - t_i) \mapsto \sum_i f(t_i) g(t - t_i)
$$

where $f(t_i)$ gives a real coefficient at step $i$. Finally, what if we make this continuous? We can change the summation with an integral

$$
\int_0^t  f(\tau)\delta(t - \tau) d\tau \mapsto \int_0^t f(\tau) g(t - \tau)d\tau
$$

Let's slow down and example each integral. The left side is actually just the function $f(t)$, the right side is what we call the convolution operator.

$$
f(t) \mapsto g(t) * f(t)
$$
This why LTI systems are great!

> If you know the impulse response, you know the response to any arbitrary function using convolution.

This is why we call the impulse response the *Transfer Function*. It transfers the input to the output.

A quick note, convolutions are commutative: 
$$
g(t) * f(t) = f(t) * g(t)
$$
## Cool Math Fact 2

We will dive into more detail here, but the idea is to recover eigenvalues, eigenfunctions, and Laplace transform. This will serve as basis for concepts like Bode, Stability, and analyzing frequency response.

We start by considering the convolution in $e^{st}$ with any function.  $s$ is any complex number. The reason will become clear down the line. For now, it is important to think of $e^{st}$ as a helix in the complex plane with axis along the time dimension.

Strictly speaking convolution is over $-\infty$ to $\infty$
$$
h(t) * e^{st} = \int_{-\infty}^{\infty} h(\tau)e^{s(t - \tau)}d\tau
$$
We can factor out $e^{st}$ on the right hand side
$$
h(t) * e^{st} = \left( \int_{-\infty}^{\infty} h(\tau)e^{-s\tau}d\tau \right) e^{st}
$$
The quantity in the parenthesis is called the Laplace Transform of $h(t)$
$$
H(s) = 
\int_{-\infty}^{\infty} h(t)e^{-s\tau}d\tau 
$$

(Usually we will use lower bound of 0 and not $\infty$ as our system only starts at $t = 0$)

Thus,
$$
h(t) * e^{st} = H(s) e^{st}
$$

$e^{st}$ is an eigenfunction of the convolutional operator. If we treat the input to our LTI system as $e^{st}$ , then the output is the convolution with $g(t)$, or simply multiplication with $H(s)$.

We will now use some facts about complex numbers
1. the input $e^{st}$ is a complex number. To see this use $s = \sigma + \omega j$. Now using Euler's identity,
$$
e^{st} = e^{\sigma t} \bigg( cos(\omega t) + j sin(\omega t) \bigg)
$$
2. $H(s)$ is another complex number that depends on $s$. The effect of multiplying a complex number by another complex number is simply scaling by the original complex number $e^{st}$ by magnitude $|H(s)|$ and rotating it in the imaginary plane by the phase of $H(s)$ or $\angle H(s)$.

> In our case, imagine taking the original helix $e^{st}$ and changing its magnitude by $|H(s)|$, but also rotating it by $\angle H(s)$.

Why do we care about $e^{st}$ ? What if I told you that we can write the dirac delta as a linear combination of $e^{st}$ ? This is the identity (proof left out)
$$
\delta(t) = \frac{1}{2 \pi j} \int_{c -j\infty}^{c + j\infty} e^{st}ds
$$

So if every function is a linear combination of $\delta(t)$, and $\delta$ itself is linear combination of all $e^{st}$, we can study responses to all possible $e^{st}$ to find out response of our system to any function! In practice, most functions can be directly written as a linear combination of $e^{st}$ so we can skip the $\delta(t)$ indirection.

# Practical Stuff (Stability)


Okay, sure we can represent the transfer function as a complex number if the input is $e^{st}$. How does that help?

Let's say we want a closed loop system where the feedback is the just negative that of the output of the transfer function applied to the input. This is same as multiplying the output by $-1$ and adding it to the input

In Block Diagram notation, 

```
   e^{st}
     |
     v
   ( + )<----------------------+
     |                         |
     v                         |
   +-----------+               |
   |   G(s)    |               |
   +-----------+               |
     |                         |
     |                         |
     |                         |
     +---------------( - )-----+
     |
     |
     Y(s)
```


Now what if output complex number has $|Y(s)| \ge 1$ and it has a difference of 180 degrees from the input, i.e $\angle Y(s) = 180$

Well, this indicates the output is as big (or perhaps bigger) than the input in magnitude and faces the opposite direction to that of the input (i.e antiparallel in the complex plan).

If you multiply this quantity by $-1$, the output is parallel to input. This then gets added to the input, which more than doubles the input. Okay, so far so good.

What happens if we feed this into the system again? The output would amplify and feed back in. We keep repeating the process until the output becomes so large that the system breaks.

This is an instability. More precisely, whenever the output grows exponentially, the system is unstable.

In general there are two types of instabilities
1. disturbance instability: when even small impulse disturbances can balloon out of control.
2. feedback instability: when the feedback compounds the input, causing the output to grow exponentially.

Both need to be analyzed

## Disturbance Instability

Consider the transfer function $G(s) = \frac{N(s)}{D(s)}$. A pole of the transfer function is any complex number $s$ such that the $D(s) = 0$.


Let $s_1$ be one pole that has the largest real part. This means $G(s)$ exists only for $Re(s) > Re(s_t)$. This ties into Region of Convergence argument. (TODO add ROC).

If $s_1$ is positive however, then we have a term $e^{s_1t}$ in the time domain transfer function. Any tiny disturbance, whether in our control input or external will likely excite this and cause the response to balloon exponentially. Theoretically, we can provide a pure $e^{st}$ input that does not excite this mode, but it is practically impossible. Hence we say a system is unstable if any poles of the transfer function are in the Right half complex plane. $Re(s)> 0$.

> TODO: add nyquist plot 

## Feedback Instability
We have already built the intuition regarding the feedback instability, here we will look at tools to explore this.

> TODO: add bode plots and stability margins
> TODO: add nyquist stability criterion and sensitivity








































