
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

Translating back to $f$ via $g(0) = f(x)$, $g(1) = f(y)$, $\gamma(0) = x$, $\gamma(1) - \gamma(0) = y - x$. And replacing dot product with the transpose:

$$\boxed{\,f(y) \leq f(x) + \nabla f(x)^\top (y-x) + \frac{L}{2}\,||y-x||^2\,}$$

This is the **descent lemma** (also called the *quadratic upper bound* or sometimes the L-smoothness inequality). Geometrically: at every point $x$, the function $f$ is dominated by an upward-opening parabola that touches $f$ at $x$ with the same tangent plane and curvature exactly $L$.


## Gradient Descent

Gradient descent says: from point $x$, move to $y = x - \eta \nabla f(x)$, where $\eta$ is the step size. Substitute this into the descent lemma:

$$f(y) \leq f(x) + \nabla f(x)^\top (y - x) + \frac{L}{2} ||y-x||^2$$
Compute the pieces:
- $y - x = -\eta \nabla f(x)$
- $\nabla f(x)^\top (y-x) = -\eta \, ||\nabla f(x)||^2$
- $||y - x||^2 = \eta^2 \, ||\nabla f(x)||^2$

Plug in:
$$f(y) \leq f(x) - \eta \, ||\nabla f(x)||^2 + \frac{L \eta^2}{2} \, ||\nabla f(x)||^2 = f(x) - \eta\left(1 - \frac{L\eta}{2}\right) ||\nabla f(x)||^2$$

For this to be a *decrease* (i.e. $f(y) < f(x)$), we need the coefficient on $||\nabla f(x)||^2$ to be positive:

$$\eta\left(1 - \frac{L\eta}{2}\right) > 0 \quad \Longleftrightarrow \quad 0 < \eta < \frac{2}{L}$$

So **any step size between 0 and 2/L gives guaranteed descent** (assuming $\nabla f(x) \neq 0$, i.e. you're not already at a stationary point). Outside that range, the lemma can't promise anything — you might overshoot so badly that the parabolic bound itself is higher than $f(x)$.

**The optimal step size.** Maximize the decrease by maximizing $\eta(1 - L\eta/2)$ over $\eta$. Take the derivative, set to zero: $1 - L\eta = 0$, so $\eta^\star = 1/L$. This is *exactly the step size that lands you at the minimum of the parabolic upper bound* — which makes sense: if your guarantee is "f is below this parabola," the best you can do is move to the parabola's minimum.

At $\eta = 1/L$, the guaranteed decrease becomes:

$$f(y) \leq f(x) - \frac{1}{2L} ||\nabla f(x)||^2$$

So **every step decreases $f$ by at least $||\nabla f(x)||^2 / (2L)$**. 

Notice that f(y) lower bounds the parabola. So if we jump the to minimum of the parabola in $\eta$, then we are at $f(y)$, which is at most the minima of the parabola. 

In the following diagram we are not jumping from x to y, we simply show the parabolas at two points x and y. Every descent step, we move from $x$ to $x'$ where $x'$ is the minima of the parabola intersecting $f$ at x.


![[Pasted image 20260506120239.png]]

**Why this matters for tuning.** This derivation is *the* reason learning rates around $1/L$ are theoretically motivated. If you set $\eta$ too large (above $2/L$), the upper-bound argument breaks and the algorithm can diverge. If you set it too small, you're being needlessly conservative — guaranteed progress per step shrinks. In practice, $L$ is unknown, which is why people use line search, adaptive methods, or just empirical tuning. But the descent lemma tells you what game you're playing.