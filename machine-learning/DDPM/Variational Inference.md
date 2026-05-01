
Vi is a trick for doing probabilistic inference when the exact calculation is intractable. 

We usually want the posterior over some latent variables $z$, given data $x$,

$$
p(z | x) = \frac{p(x, z)}{p(x)}
$$

The normalizer $p(x)$ is an integral or a sum and is hard to compute.
$$
p(x) = \int p(x, z) dz
$$
without this, we can't $p(z | x)$ or maximize likelihood given by $\log(p(x))$.

# The VI Idea

pick a distribution with known parameters, then try to fit it as close as the true posterior $p(z|x)$ by minimizing KL-divergence. Let the parameterized dist be $q(z|x; \phi)$

We minimize
$$
KL(q(z|x; \phi) || p(z|x))
$$
Again, we can't compute $p(z|x)$ as we can't find $p(x)$. So we use an equivalent objective as minimizing KL divergence.

$$
\mathrm{KL}\!\left(q_\phi(z\mid x)\,\|\,p_\theta(z\mid x)\right)
=
\mathbb{E}_{q_\phi(z\mid x)}\!\left[\log \frac{q_\phi(z\mid x)}{p_\theta(z\mid x)}\right]
\ge 0.
$$

Bayes' rule:
$$
p_\theta(z\mid x) = \frac{p_\theta(x,z)}{p_\theta(x)}.
$$

Plug in:
$$
\mathrm{KL}\!\left(q_\phi(z\mid x)\,\|\,p_\theta(z\mid x)\right)
=
\mathbb{E}_{q_\phi(z\mid x)}\!\left[\log \frac{q_\phi(z\mid x)}{p_\theta(x,z)/p_\theta(x)}\right].
$$

Rewrite the log:
$$
=
\mathbb{E}_{q_\phi(z\mid x)}\!\left[\log q_\phi(z\mid x) - \log p_\theta(x,z) + \log p_\theta(x)\right].
$$

Since $$\log p_\theta(x)$$ does not depend on $z$:
$$
\mathrm{KL}\!\left(q_\phi(z\mid x)\,\|\,p_\theta(z\mid x)\right)
=
\mathbb{E}_{q_\phi(z\mid x)}[\log q_\phi(z\mid x)]
-
\mathbb{E}_{q_\phi(z\mid x)}[\log p_\theta(x,z)]
+
\log p_\theta(x).
$$

Move terms:
$$
\log p_\theta(x)
=
\left(
\mathbb{E}_{q_\phi(z\mid x)}[\log p_\theta(x,z)]
-
\mathbb{E}_{q_\phi(z\mid x)}[\log q_\phi(z\mid x)]
\right)
+
\mathrm{KL}\!\left(q_\phi(z\mid x)\,\|\,p_\theta(z\mid x)\right).
$$

Define
$$
\mathcal{L}(\theta,\phi;x)
\equiv
\mathbb{E}_{q_\phi(z\mid x)}[\log p_\theta(x,z)]
-
\mathbb{E}_{q_\phi(z\mid x)}[\log q_\phi(z\mid x)].
$$

Then
$$
\log p_\theta(x) = \mathcal{L}(\theta,\phi;x) + \mathrm{KL}\!\left(q_\phi(z\mid x)\,\|\,p_\theta(z\mid x)\right).
$$


Now to minimize KL across all $\phi$, we can simply maximize $\mathcal{L}$ across all $\phi$. 