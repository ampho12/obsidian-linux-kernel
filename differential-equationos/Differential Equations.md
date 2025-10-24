

# Picard-Lindelof

For an Initial Value Problem (IVP) 
$$
\dot{x} = F(t, x)
$$
$$
x(t_0) = x_0
$$
if 
1. F is continuous in t (this means we can integrate => guarantees existence) -- TODO: definitions usually assume F is continuous, why is that?
2. F is Lipschitz in $x$ on a region in $t$ (no "branching" => guarantees uniqueness)

Then a unique solution exists in that region


## Linear Differential Equations

For a linear, time varying system,

$$
\dot{\bf x} = A(t) {\bf x}
$$
we 







# Appendix
## Lipschitz and Branching 

Consider an ODE
$$
\dot{x} = F(t, x(t))
$$
**branching** means that there are two different solutions that satisfy the same initial conditions and the ODE.

Consider the example

$$
\dot{x} = \sqrt{|x|}
$$
$$
x(0) = 0
$$
We have two solutions
1. $x(t) = 0$
2. $x(t) = \frac 1 4 t^2$

In order to guarantee uniqueness, we say the solutions must be Lipschitz. A function $F$ is Lipschitz on a region $[t_0, T]$. if there exists a constant $L > 0$, such that any pair of solutions $x_1, x_2$ satisfy
$$
|| F(t, x_1) - F(t, x_2)||
\leq
L||x_1 - x_2||
$$

Now we set
$$
z(t) = x_1(t) - x_2(t)
$$

Then using definition 
$$
z(t) 
= 
x_1(t) - x_2(t)
=
\int_{t_0}^{T}
[
F(s, x_1(s)) - F(s, x_2(s)) 
]
ds
$$
Now recall that for any continuous function,
$$
|| \Big( \int f \Big)|| \leq \int || f ||
$$

Therefore
$$
||z(t)|| 
=
\Bigg|\Bigg|
\int_{t_0}^{T}
F(s, x_1(s)) - F(s, x_2(s)) 
ds
\Bigg|\Bigg|
\leq
\int_{t_0}^{T}
||
F(s, x_1(s)) - F(s, x_2(s)) 
||
ds
$$

Using the Lipschitz condition (why is L) a function of s? is it that $L(s) = L_0$
$$
||z(t)|| 
\leq
\int_{t_0}^{T}
||
F(s, x_1(s)) - F(s, x_2(s)) 
||
ds
\leq
\int_{t_0}^{T}
L(s)
||
x_1(s) - x_2(s)
||
ds
$$
i.e
$$
||z(t)|| 
\leq
\int_{t_0}^{T}
L(s)
||
z(s)
||
ds
$$


This is similar to the Gronwall inequality

with 
1. $a$ = 0
2. $b(s) = L(s)$
3. $w(t) = ||z(t)||$

This becomes
$$||z(t)|| \leq 0$$

i.e $||z(t)|| = 0$. But $z(t) = x_1(t) - x_2(t)$ 




## Gronwall Inequality

Gronwalls's inequality says that if the growth of a function $w(t)$ is goverened by its own past value, it cannot grow faster than an exponential envelope (i.e upper bound on the growth rate).

Suppose we have non-negative function $w: [t_0, T] \to \mathbb{R}$ that satisfies

$$
w(t)
\leq
a
+
\int_{t_0}^t b(s)w(s)ds
$$
where:
1. `a` is a non-negative constant
2. $b(s)$ is a non-negative inegrable function (.e.g bounded and continuous)


Gronwall's inequality states if $w(t)$ satisfies
$$
w(t)
\leq
a
+
\int_{t_0}^t b(s)w(s)ds
$$

then 
$$
w(t) \leq a \exp
\Big(
\int_{t_0}^t b(s)ds
\Big)
$$


Perfect timing 👍 — you’ve intuited exactly how these pieces fit together: **Lipschitz → integral inequality → Grönwall → uniqueness.**
Let’s now focus only on **Grönwall’s inequality** itself, slowly and carefully.


### Proof Sketch

Define

$$
\phi(t) = a + \int_{t_0}^t b(s)\,w(s)\,ds.
$$

So $w(t)\le \phi(t)$.

Differentiate $\phi$. 




$$
\phi'(t) = b(t)w(t)
$$
Since $b(t), a, w(t)$ are non-negative, we get 
$$
w(t) \leq a + \int_{t_0}^t b(s)w(s)ds
$$

Thus
$$
\phi'(t) = b(t)w(t) \le b(t)\phi(t)$
$$

So $\phi(t)$ satisfies the differential inequality

$$
\phi'(t) \le b(t)\phi(t).
$$

Now divide both sides by $\phi(t)$ (positive for $t\ge t_0$) and integrate:

$$
\frac{\phi'(t)}{\phi(t)} \le b(t).
$$

Integrate from $t_0$ to $t$:

$$
\ln \phi(t) - \ln \phi(t_0) \le \int_{t_0}^t b(s)\,ds.
$$

But $\phi(t_0)=a$. So

$$
\phi(t) \le a\,\exp\!\Big(\int_{t_0}^t b(s)\,ds\Big).
$$

Since $w(t)\le \phi(t)$, the same bound holds for $w$.

---

# 4. The special case for uniqueness

In the uniqueness proof:

* We got $\|z(t)\| \le \int_{t_0}^t L(s)\|z(s)\|\,ds$.
* This is Grönwall’s inequality with $a=0$, $b(s)=L(s)$.

So

$$
\|z(t)\|\le 0\cdot \exp\Big(\int_{t_0}^t L(s)\,ds\Big)=0.
$$

Thus $\|z(t)\|\equiv 0$ ⇒ no branching ⇒ uniqueness.

---

* Grönwall is a “bootstrap inequality”: if the growth of $w$ is controlled by its own past values, then it can’t grow faster than an exponential envelope.
* The exponential is the “sharpest” possible growth rate under such a self-referential bound.
* If the initial term $a=0$, the exponential envelope is zero, so the function must stay zero.

