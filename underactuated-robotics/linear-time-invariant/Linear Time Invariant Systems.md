
Linear time invariant systems are cool. Why is that?

Let's start with what an linear time invariant or LTI system means.

The "Linear" part. If input $u_1$ produces output $y_1$, and $u_2$ produces $y_2$ then $\alpha u_1 + \beta u_2$ produces $\alpha y_1 + \beta y_2$.

The "Time Invariant" part. If we apply an input $u_1$ now or at any other time in the future, it will still produce the same output starting at when the input was applied. More concretely
$$
u(t) \mapsto y(t) \implies u(t - \tau) \mapsto y(t - \tau)
$$

Recall that $u(t + \tau)$ means applying $u(t)$ but turning it "on" at $t + \tau$.

Any LTI system can be written in state space form (TODO: add proof)

$$
\begin{aligned}
\dot{x} &= Ax + Bu \\
y &= Cx + Du
\end{aligned}
$$

For now, we will focus on SISO systems. A SISO system implies that there is one scalar input (u(t)) and one scalar output (y(t)). However, we may still have n-dimensional state. Let's unpack this.

## State in LTI Systems

Essentially, state is not real physical quantity, its a mathematical reinterpretation of existing dynamics that
1. Rewrites order-n dynamics in 1 dimension as first-order dynamics in n-dimensions
2. A way to capture system memory (i.e minimum information at time $t$ needed to predict all future behavior for any input $u(t)$).

Consider the following n-th order dynamics

$$
y^{(n)}(t)
+ a_{n-1}y^{(n-1)}(t)
+ a_{n-2}y^{(n-2)}(t)
+ \cdots 
+ a_{0}y(t)
=
b_0u(t)
$$

We can introduce a variable for state
$$
x = \begin{bmatrix}
y \\
y^{(1)} \\
y^{(2)} \\
\vdots \\
y^{(n-1)} \\
\end{bmatrix}
$$
This gives 
$$
\frac{d}{dt} x_n = y^{(n)}(t) = 
- a_{n-1}y^{(n-1)}(t)
- a_{n-2}y^{(n-2)}(t)
- \cdots 
- a_{0}y(t)
+ b_0u(t)
$$

We can put this together in a matrix equation
$$
\dot{x} = Ax + Bu
$$
where
$$
A = \begin{bmatrix}
0 & 1 & 0 & \ldots & 0 \\
0 & 0 & 1 & \ldots & 0 \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
0 & 0 & 0 & \ldots & 1 \\
-a_0 & -a_1 & 0 & \ldots & -a_{n-1}
\end{bmatrix}
$$
and
$$
B = \begin{bmatrix}
0 \\
0 \\
\vdots \\
0 \\
b_0
\end{bmatrix}
$$

## LTI System Response

Let's find the solution of $\dot{x} = Ax + Bu$

This is

$$
x(t) = 
e^{At}x(0) + \int e^{A(t - \tau)} Bu(\tau) d\tau
$$
Again, state is not real, the system output is given by
$$
y(t) = Cx(t) + D(u)
$$
i.e
$$
y(t) = 
Ce^{At}x(0) 
+ C\int e^{A(t - \tau)} Bu(\tau) d\tau
+ Du(t)
$$

Now, we define two pieces

1. Zero-State Response: 
$$
C\int e^{A(t - \tau)} Bu(\tau) d\tau
+ Du(t)
$$
1. Zero-Input Response:
$$
Ce^{At}x(0) 
$$




# Zero State Response


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

We will omit this for notational brevity, it will be implicit if there is a step function or not.

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

Let's slow down and examine each integral. The left side is actually just the function $f(t)$, the right side is what we call the convolution operator.

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

We start by considering the convolution in $e^{st}$ with any function.  $s$ is any complex number. The reason will become clear down the line. For now, it is important to think of $e^{st}$ as a helix in the complex plane that wraps about the positive time dimension.

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


# Interpreting the Transfer function

The transfer function describes how a **time-domain input** maps to a **time-domain output** through a linear time-invariant (LTI) system.

Consider the example  
$$
G(s) = \frac{(s + a)(s + b)(s + c)}{(s + d)(s + e)}.
$$

Since the degree of the numerator is higher than that of the denominator, we can perform **polynomial division** and express $G(s)$ as a sum of a polynomial and a strictly proper rational function. After partial-fraction decomposition, it can be written in the form
$$
G(s)
=
a_n s^n
+ a_{n-1} s^{n-1}
+ \cdots
+ a_0
+ \frac{c_1}{s + b_1}
+ \frac{c_2}{s + b_2}
+ \frac{c_3}{s + b_3}
+ \cdots
$$

### Interpretation of the terms
1. The constant term $a_0$ corresponds to a **static gain**, scaling the input.
2. Multiplication by $s^k$ in the Laplace domain corresponds to the **$k$-th time derivative** in the time domain (assuming zero initial conditions).
3. Each term of the form $\frac{1}{s + b_i}$, with $b_i > 0$, represents a **stable first-order mode** whose impulse response is an exponentially decaying function $e^{-b_i t}$.

### Time-domain response
Let $u(t)$ be the input. The output $y(t) = g(t) * u(t)$ (convolution with the impulse response) can be written as
$$
\begin{aligned}
y(t) ={}&
a_n \, \frac{d^n u(t)}{dt^n}
+ a_{n-1} \, \frac{d^{n-1} u(t)}{dt^{n-1}}
+ \cdots
+ a_0 \, u(t) \\
&\quad
+ c_1 \int_0^t e^{-b_1 (t-\tau)} u(\tau)\, d\tau
+ c_2 \int_0^t e^{-b_2 (t-\tau)} u(\tau)\, d\tau
+ c_3 \int_0^t e^{-b_3 (t-\tau)} u(\tau)\, d\tau
+ \cdots
\end{aligned}
$$



This means,



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

System is unstable if there are Poles in the RHP for the closed loop transfer function. If so, the A matrix has at least one eignvalue with a positive real component.

Instability can be caused by many things

1. The system is unstable and the controller does not stabilize it.
2. The controller has too much gain cause some poles to shift into RHP
3. The controller has too much phase lag, causing poles to shift into RHP.
4. The controller is poorly designed.

At the end of the day, the goal is to make controller that can take an A matrix and change it to an A' matrix whose all eigenvalues are less than 0.

For example, we can choose $u(t) = -Kx(t) + B'u_1(t)$

Now our system is
$$
\dot{x} = Ax + Bu = (A - KB)x(t) + B'u_1(t)
$$
which we rewrite as
$$
\dot{x} = A'x(t) + B'u_1(t)
$$

Now If all real parts of the eigenvalues of $A'$ are less than 0 we have a stable system. Such an $A'$ is called Hurwitz.



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








Yep, that’s the right framing.

* **State space** naturally handles both **SISO and MIMO**:
  $$\dot x = Ax + Bu,\quad y = Cx + Du$$
  works with (u\in\mathbb{R}^m), (y\in\mathbb{R}^p) without changing the basic machinery.

* **Bode/Nyquist** in their classic “gain margin / phase margin from a single curve” form are **cleanest for SISO**, because the loop transfer (L(j\omega)) is a single complex number.

For **MIMO**, you don’t throw them away—you **generalize** them:

### MIMO “Bode-like” tools

Instead of a magnitude/phase of a scalar, you look at **singular values** of key transfer matrices:

* Sensitivity:
  $$S(j\omega) = (I + L(j\omega))^{-1}$$
* Complementary sensitivity:
  $$T(j\omega) = L(j\omega)(I + L(j\omega))^{-1}$$

Then you plot (\bar\sigma(S)), (\bar\sigma(T)), etc. This gives “worst-case gain across all directions” in input/output space—basically the MIMO version of robustness/performance.

### MIMO “Nyquist-like” tools

There is a **generalized Nyquist criterion** for MIMO, but it’s not a single Nyquist curve. Common ways it shows up:

* analyze (\det(I + L(s))) encirclements (conceptually similar but scalarized), or
* use more robust-control-oriented tests ((H_\infty), (\mu)).

### Important nuance

A **state coordinate change** doesn’t decouple the plant’s input–output coupling by itself. If you want “multiple independent SISO loops,” that’s a **controller/decoupler design choice**, and it only works well when coupling is weak or can be compensated.

So: **state-space = general**, **classic Bode/Nyquist = SISO**, **MIMO = use generalized frequency-domain tools (singular values / generalized Nyquist / robust control)**.
































