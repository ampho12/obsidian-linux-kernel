

# $M^k(t)$

Let's differentiate $M^k(t)$

$$
\frac{d M^k(t)}{dt} = \frac{dM(t) M(t) M(t) \ldots M(t)}{dt}
$$

This gives

$$
\sum_{j=0}^{k-1} = M^j(t) M'(t) M^{k - 1 - j}(t)
$$


# Exponential

We define

$$
\exp(M(t)) = \sum_{k=0}^\infty \frac{1}{k!} M^k(t)
$$

Now if we differentiate this

$$
\frac{d}{dt}
\exp(M(t))
= 
\sum_{k=0}^\infty 
\frac{1}{k!} 
\frac{d}{dt}
M^k(t)
$$

we get

$$
\frac{d}{dt}
\exp(M(t))
= 
\sum_{k=0}^\infty 
\frac{1}{k!} 
\sum_{j=0}^{k-1} = M^j(t) M'(t) M^{k - 1 - j}(t)
$$
