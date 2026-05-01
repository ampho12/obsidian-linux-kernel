

These transforms are basically "sample and sum" transforms. The term for this is called "correlation"

1. A laplace transfrom samples a signal continously and sums each sample.
2. A Z transform does the same but discretely.

In both cases the sampling function is e^{-st}. In case of Z transform, we use a discretized version of e^{st}. We take a sequence 
$$
e^{0}, e^{sT}, e^{s2T}, \cdots
$$


We will call the sampling function the kernel. Sampling at time $t$ means multiplying the function with kernel
$$
\text{sample}(t) = f(t) e^{-st}
$$

Then we add them together, tail to tip. For continuous summation, we integrate
$$
F(s) = \int_0^\infty f(t)e^{-st}dt
$$
This is what it looks like for a continuous approximation

![[spiral.png]]

In case of Z transform, we take the summation
$$
F_Z(s) = \sum_{n = 0}^\infty f(nT)e^{-snT}
$$

The picture looks similar but sparse

![[spiral 1.png]]

We can see how these two converge to different locations (look at the scale on the cumulative sum).

Finally, we we represent the cumulative sum vector on the imaginary plane again. For a given $s$, $F(s)$ is the converged sum. The mapping $s \mapsto F(s)$ is shown on an s-plane. The height is $|F(s)|$ and the color is the phase.

$F_z(s)$ or the discrete sampled version can also be shown the same way as $F_z(s)$ but its actually shown differently. Rather than
$$
s \mapsto F_z(s)
$$
we define $z(s) = e^{sT}$. Then we plot the following
$$
z(s) \mapsto F_z(s)
$$

$s \mapsto z(s)$ is a bijection. 

This has the effect of taking $s = a + bj$
1. The magnitude $|z(s)| = e^{\text{Re}(s)T}$.
2. The angle $\angle z(s) = \text{Im}(s)T$.

I.e we map it to a polar coordinate. This has the effect of transforming the s plane.
![[Pasted image 20260129020425.png]]

We also rewrite the Z-transform in z(s)

$$
F_z(s) = \sum_{n = 0}^\infty f(nT)z(s)^{-n}
$$
We can get rid of s altogether, 
$$
F(z) = \sum_{n = 0}^\infty f(nT)z^{-n}
$$




# Laplace Transform

A laplace transform is sample + sum. It can be used to make a "machine" that takes a function end exposes the exponential helices within it.

A lot of functions can be written as a linear sum of helices

$$
f(t) = 
c_1 e^{s_1t}
+ c_2 e^{s_2t}
+ c_3 e^{s_3t}
$$

where $s_i \in \mathbb{C}$

For instance, 
$$
\cos(t) = \frac12 e^{-it} + \frac12 e^{it}
$$

The goal is to take $\cos(t)$ and do something with it that helps us detect the exponential helices.


# The Integration Idea

To do this effectively, let's look at complex integral of the following
$$
\int^\infty_0 e^{-st} dt
$$


We can treat it as a vector sum in the complex plane. When this vector sum converges to a single vector, we have a value. Sometimes it won't converge to a single vector. For instance

For $s= 0$, this is $\int_0^\infty 1 \cdot dt \to \infty$
For $Re(s) \leq 0$, this is $\int_0^\infty e^{-st}dt$ also doesn't converge, it keeps spinning and growing.

This defines the **Region of Convergence** or ROC. which is $Re(s) > 0$ for $e^{-st}$

On this region, we have the result
$$
\int^\infty_0 e^{-st} dt = \frac1s
$$


This shows an interesting behavior, if we plot the magnitude of the result against the input, i.e
$$
s \to \frac1{|s|}
$$
We get this plot

![[Pasted image 20260128183327.png]]

We can overlay the phase on top of this using colors.

$$
s \to \angle \frac1s
$$

![[Pasted image 20260128183448.png]]


## Analytic Continuation


# Probing for Exponential Helices

Now what if we try a simple helix as our function we want to probe? Try this
$$
\int^\infty_0 e^{at}e^{-st} dt = \frac1{s - a}
$$

This basically shifts the spike to $a$

![[Pasted image 20260128184141.png]]

Now we can run this with cosine 
$$
\int^\infty_0 \cos(t)e^{-st} dt = 
\frac12 \frac1{s - i} + \frac12 \frac1{s + i}
$$


![[Pasted image 20260128184251.png]]


We recover our poles at $-i$ and $+i$ i.e $\cos(t) = \frac12 e^{-it} + \frac12e^{it}$



# Z Plane 

