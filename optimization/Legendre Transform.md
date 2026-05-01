
Fairly useful. The idea is to take function that is a map from points (e.g $x \to x^2$)

and represent that as a mapping from slopes of the function to its $y$ intercepts.


$$
f(x)
$$

we map to 

$$
g \left(
\frac{\partial f}{\partial x}
\right)
=
x \left(
\frac{\partial f}{\partial x}
\right)
\frac{\partial f}{\partial x}
-
f \left(
x \left(
\frac{\partial f}{\partial x}
\right)
\right)
$$

For brevity let's use
$$
p = \frac{\partial f}{\partial x}
$$
We will see in a bit why this makes sense. Consider $g(p)$ as the negative y intercept of the slope $p$ at some $x$. If we note that the mapping from $x \to p$ is bijective, then we can write

$$
f(x(p)) + g(p) = px(p)
$$

![[Pasted image 20251029153336.png]]

The bijective condition is true if the function is convex along the chosen direction.

## Takeaway

The legendre transform takes a function, that gives a new function that outputs the negative y intercept as a function of slope. For general functions, the same slope may have multiple intercepts, which means we don't have a function. 

The y intercept of point $(x, f(x))$ with slope p is given by $f(x) - xp$.  Note that $p$ is not tied to $x$ or $f$, its a completely arbitrary choice.
$$
f^*(p) = \sup_x \{ xp - f(x)\}
$$
Since $xp(x) - f(x)$ is negative of intercept, this is essentially finding the most negative intercept for a slope. This arrangment naturally finds slope intercept pairs that are tangent to $f(x)$ at the point of contact. I.e these set of lines make a convex support for the function.

This can be seen as follows:
$$
\frac{d}{dx} xp - f(x) = 0 \implies p - f'(x) = 0
$$

We will alter notation to use $y = p$ as the slope. Just a change of variables. Now if we take a negative intercept $f^*(y)$, at a point $t$ along the x axis, the value due to the intercept $-f^*(y)$ and slope $y$ is given by
$$
-f^*(y) + ty
$$
Diffrent slopes map to different values:
$$
\{ -f^*(y) + ty: y \in \mathbb{R}\}
$$
if we take the supremum over these slopes, we get another function

$$
\sup_y \{ ty -f^*(y) \}
$$
This is just the convex conjugate of $f^*(y)$.
$$
f^{**}(t) = 
\sup_y \{ ty -f^*(y) \}
$$

This will reconstruct a convex hull of the original function. proof pending.


## Multivariate
The partial derivative allows us to isolate one variable out of a multivariable input
$$
g(p_1, x_2, x_3)
=
p_1 x_1(p_1, x_2, x_3)
-
f(x_1(p_1, x_2, x_3), x_2, x_3)
$$
Let $f:\mathbb{R}^3 \to \mathbb{R}$ be convex in $(x_1, x_2)$.

First, take the Legendre transform with respect to $x_1$:

$$
g_1(p_1, x_2, x_3)
= \sup_{x_1} \{\, p_1 x_1 - f(x_1, x_2, x_3) \,\}.
$$

Then, apply the Legendre transform with respect to $x_2$:

$$
g_{12}(p_1, p_2, x_3)
= \sup_{x_2} \{\, p_2 x_2 - g_1(p_1, x_2, x_3) \,\}.
$$

Equivalently, combining the two suprema gives the same result:

$$
g_{12}(p_1, p_2, x_3)
= \sup_{x_1, x_2} \{\, p_1 x_1 + p_2 x_2 - f(x_1, x_2, x_3) \,\}.
$$

At the maximizing point, the conjugate relations hold:

$$
p_1 = \frac{\partial f}{\partial x_1}, \quad
p_2 = \frac{\partial f}{\partial x_2}, \qquad
x_1 = \frac{\partial g_{12}}{\partial p_1}, \quad
x_2 = \frac{\partial g_{12}}{\partial p_2}.
$$

Hence, performing the Legendre transform sequentially in $x_1$ and then $x_2$
yields the same result as transforming in both variables simultaneously.

$$
g(p_1, p_2, x_3)
=
p_1 x_1(p_1, p_2, x_3)
+
p_2 x_2(p_1, p_2, x_3)
-
f(x_1(p_1, p_2, x_3), x_2(p_1, p_2, x_3), x_3)
$$



If we extend this

$$
g(\nabla f(\mathbf{x}))
=
\mathbf{x} \cdot \nabla f(\mathbf{x})
-
f(\mathbf{x})
$$

$$
g(\mathbf{p})
=
\mathbf{x}(\mathbf{p}) \cdot \mathbf{p}
-
f(\mathbf{x}(\mathbf{p}))
$$
