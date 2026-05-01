

When we have some data and we have a parameterized model for it, we define the likelhood as the probability of generating the data given the probabilistic model and the parameters.

$$
L(\theta) = p_\text{model}(\text{observed data}; \theta)
$$

Once we have a model, we can distinguish probability vs likelihood

- **Probability:** $\theta$ is fixed, $X$ varies. "Given these parameters, how probable is the data?" This is a proper measure — it integrates/sums to 1 over $X$.
- **Likelihood:** $X$ is fixed (observed), $\theta$ varies. "Given this data, how compatible are different parameter values?" This is **not** a probability distribution over $\theta$ — it doesn't integrate to 1 over $\theta$ in general.

Same function, different perspective:

$$\underbrace{p(X; \theta)}_{\text{probability in } X} \quad \longleftrightarrow \quad \underbrace{L(\theta) = p(X_{\text{obs}}; \theta)}_{\text{likelihood in } \theta}$$

The MLE estimation is just maximizing the likelihood

$$
\theta_{\text{MLE}} = \arg \max_\theta L(\theta)
$$

We can also take the natural log of the likelihood, called the log likelihood. 
$$
\theta_{\text{MLE}} = \arg \max_\theta \ln L(\theta)
$$

In practice we either set $\frac{d\ln L}{d\theta} = 0$ or use numerical methods like gradienct descent, newton- raphson or EM algorithm.

So the goal is two forth:
1. Choose a parameterized probabilistic model of the data
2. Find the parameters that maximize the probability from the **Chosen** model.


## Ordinary Least Squares

Say we have some data $(X_i, Y_i)$. We choose a model like this
$$
y = ax + b + \mathcal{N}(0, 1)
$$

This is sloppy notation, what we should write is
$$
Y_i \sim \mathcal{N}(aX_i + b, 1)
$$
In this case our parameters are $\theta = (a, b)$,

Note that each datapoint doesn't depend on any other data (zero correlation). Thus
$$
L(\theta) = p_\text{model}((X_1, Y_1), (X_2, Y_2), \cdots (X_n, Y_n); \theta)
$$
Simplifies to
$$
L(\theta) = \prod_i^n p_\text{model}((X_i, Y_i); \theta)
$$
This gives 
$$
p_\text{model}((x, y); \theta) = \frac1{\sqrt{2\pi}} e^{-\frac12(y - ax - b)^2}
$$

We can try maximizing the likelihood over $\theta$ . A natural log here is very convenient
$$
p_\text{model}((x, y); \theta) = \frac1{\sqrt{2\pi}} e^{-\frac12(y - ax - b)^2}
$$

Once taken, we get
$$
\ln L(\theta) = -\frac{n}{2} \ln(2\pi) - \frac12 \sum_i^n (Y_i - aX_i - b)^2
$$
Which is simply ordinary least squares used in linear regression. The solution can be found quickly using orthogonal projection.


## Logistic Regression

We again have some data $(X_i, Y_i)$. We choose a model like this
$$
Y_i \sim \text{Bernoulli}(p_i)
$$
Where
$$
p_i = \sigma(aX_i + b) = \frac{1}{1 + e^{-(aX_i + b)}}
$$

This implies outcomes are independent, and we get
$$
p_\text{model}((Y_i, X_i); \theta) = p_i^{Y_i}(1 - p_i)^{1 - Y_i}
$$



# Expectation Maximization



