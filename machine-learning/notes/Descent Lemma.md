
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
g(1) = \underbrace{g(0) + \nabla f(\gamma(0)) \cdot (\gamma(1) - \gamma(0))}_{\text{linear approximation of f at x}} + \underbrace{\int_0^1 \bigg( \nabla f(\gamma(t)) - \nabla f(\gamma(0)) \bigg)\cdot \gamma'(t) dt}_{\text{error from the linear approximation}}
$$






The descent lemma says
$$
f(y) \leq f(x) + \nabla f(x)^\top (y - x) + \frac{L}{2} ||y - x||^2
$$


Let's look at L-smoothness.

First the definition of L-Lipschitz -- a function is L--lipschitz if it can't change faster than rate L, i.e $|f(x) - f(y)| \leq L \cdot | x - y |$.

Now we state the descent lemma

