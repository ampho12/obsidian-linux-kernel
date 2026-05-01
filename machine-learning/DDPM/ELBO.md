 
 Elbo stands for Evidence Lower BOund.

 Start with
$$
p(x) = \int p(x, z) dz
$$

Now let's multiply and divide the term inside the integral by $q(z | x; \phi)$.
$$
p(x) = \int q(z|x; \phi) \frac{p(x, z)}{q(z|x; \phi)} dz
$$

The RHS is basically an expection of a continous random variable under $q(z|x; \phi)$. To see this, observe

$$
E_{q(z|x; \phi)}[Y(z)] = \int Y(z) q(z|x; \phi) dz
$$
Here we simply choose
$$
Y(z) = \frac{p(x,z)}{q(z|x; \phi)}
$$

substituting back in
$$
p(x) = E_{q(z|x; \phi)}[Y(z)]
$$

Now we take the log of both sides. We do this because log is concave.
$$
\log p(x) = \log E_{q(z|x; \phi)}[Y(z)]
$$

by jenson's inequality for concave function
$$
\log E[Y] \geq E(\log Y)
$$
I.e 

$$
\log p(x) \geq E_q[\log Y]
$$
$$
\log p(x) \geq
E_q \left[
\log(p(x,z)) - \log(q(z|x; \phi))
\right]
$$

We define the RHS as $ELBO(x)$.








Take log on both sides
$$
\log p(x) = \log \int p(x, z) dz
$$
