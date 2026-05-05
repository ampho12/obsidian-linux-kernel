
On a loss landscape, consider two points in the domain. $x, y \in \mathcal{D}$. Then we get a straight line between the points
$$
\gamma(t) = x + t(y - x), \ t \in [0, 1]
$$

Let the loss value at any point $x$ be given by $f(x)$. Now we get
$$
g(t) = f(\gamma(t))
$$
By the fundamental theorem of calculus
$$
g(1) - g(0) = \int_0^1 g'(t)dt
$$
By the chain rule
$$
\begin{align*}
g'(t) &= \nabla f(\gamma(t)) \cdot \gamma'(t) \\
\end{align*}
$$
Giving
$$
g(1) - g(0) = \int_0^1 \nabla f(\gamma(t)) \cdot \gamma'(t) dt
$$
Adding and subtracting $\nabla f(\gamma(0))$  inside the integral
$$
g(1) - g(0) = \int_0^1 \bigg( \nabla f(\gamma(t)) + \nabla f(\gamma(0)) - \nabla f(\gamma(0)) \bigg)\cdot \gamma'(t) dt
$$

Rearranging
$$
g(1) = 
\underbrace{g(0) + \nabla f(\gamma(0)) \cdot (\gamma(1) - \gamma(0))}_{\text{linear approximation of f at x}} 
+ 
\underbrace{\int_0^1 \bigg( \nabla f(\gamma(t)) - \nabla f(\gamma(0)) \bigg)\cdot \gamma'(t) dt}_{\text{error from the linear approximation}}
$$


We can bound the linear approximation error term using cauchy-shwarz and lipschitz property.

Note that cauchy shwarze gives us $a^\top b \leq |a^\top b | \leq ||a|| \cdot ||b||$.

$$
\bigg( \nabla f(\gamma(t)) - \nabla f(\gamma(0)) \bigg)\cdot \gamma'(t)
\leq
|| \bigg( \nabla f(\gamma(t)) - \nabla f(\gamma(0)) \bigg) || \cdot ||\gamma'(t)|| 
$$

Now we use Lipschitz
$$
|| \bigg( \nabla f(\gamma(t)) - \nabla f(\gamma(0)) \bigg) || \leq L || \gamma(t) - \gamma(0) ||
$$
Substituting 
$$
\bigg( \nabla f(\gamma(t)) - \nabla f(\gamma(0)) \bigg)\cdot \gamma'(t)
\leq
L || \gamma(t) - \gamma(0)|| \cdot ||\gamma'(t)|| 
$$

Substituting the pointwise bound into the integral:

$$g(1) \leq g(0) + \nabla f(\gamma(0)) \cdot (\gamma(1) - \gamma(0)) + \int_0^1 L \, ||\gamma(t) - \gamma(0)|| \cdot ||\gamma'(t)|| \, dt$$

Now compute each piece using $\gamma(t) = x + t(y-x)$:

$$\gamma(t) - \gamma(0) = t(y-x) \quad \Rightarrow \quad ||\gamma(t) - \gamma(0)|| = t\,||y-x||$$

$$\gamma'(t) = y-x \quad \Rightarrow \quad ||\gamma'(t)|| = ||y-x||$$

Plug these in:

$$\int_0^1 L \, ||\gamma(t) - \gamma(0)|| \cdot ||\gamma'(t)|| \, dt = \int_0^1 L \cdot t \, ||y-x|| \cdot ||y-x|| \, dt = L \, ||y-x||^2 \int_0^1 t \, dt$$

And $\int_0^1 t \, dt = \frac{1}{2}$, so the error term is bounded by $\frac{L}{2}||y-x||^2$.

Translating back to $f$ via $g(0) = f(x)$, $g(1) = f(y)$, $\gamma(0) = x$, $\gamma(1) - \gamma(0) = y - x$:

$$\boxed{\,f(y) \leq f(x) + \nabla f(x)^\top (y-x) + \frac{L}{2}\,||y-x||^2\,}$$

This is the **descent lemma** (also called the *quadratic upper bound* or sometimes the L-smoothness inequality). Geometrically: at every point $x$, the function $f$ is dominated by an upward-opening parabola that touches $f$ at $x$ with the same tangent plane and curvature exactly $L$.


