
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
g'(t) &= \nabla f(\gamma(t)) \cdot (y - x) \\
\end{align*}
$$



The descent lemma says
$$
f(y) \leq f(x) + \nabla f(x)^\top (y - x) + \frac{L}{2} ||y - x||^2
$$


Let's look at L-smoothness.

First the definition of L-Lipschitz -- a function is L--lipschitz if it can't change faster than rate L, i.e $|f(x) - f(y)| \leq L \cdot | x - y |$.

Now we state the descent lemma

