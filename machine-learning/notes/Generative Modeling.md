
# Problem Description
All forms of generative modeling begin with something to model

e.g. a distribution of samples $x^{(i)} \sim p(x)$.


we then parameterize our model of $p(x)$ using some parameter $\theta$, and then try to fine $\theta$ to minimize the KL divergence
$$
\text{KL} ( p(x) \ ||\  p_\theta(x))
$$

Using the definition of KL divergence, we get our problem to use $\theta$ to find
$$
\min_{\theta} E_p [\log( p / p_\theta)]
$$
$$
\min_{\theta} \left( E_p [\log p ] - E_p[\log p_\theta] \right)
$$

The first term is constant, hence we ignore it. Also we can absorb the sign and make this a maximization problem.
$$
\max_{\theta} E_p[\log p_\theta]
$$
This formulation is Maximum Likelihood Estimation or MLE. But we don't know the true $p$, we only have samples $x^{(i)}$

So we approximate
$$
E_p[ \ln p_\theta(x)] 
\approx 
\frac1n \sum_{i=1}^n \ln p_\theta(x^{(i)})
$$
This is called the empirical approximation of the expectation and becomes better with more data.

Since $\frac1n$ is a constant, maximizing the above is same as maximizing
$$
\sum_{i=1}^n \ln p_\theta(x^{(i)}) = \ln \prod_{i=1}^n\ln p_\theta (x^{(i)}) = \ln p_\theta(X)
$$
The last step here assumes each sample is independent of the other.

We will rewrite it at $\ln p_\theta(X) = \ln p(X; \theta)$, which is equivalent notation.

We will see this term everywhere in statistics, let's get familiar with it
$$
\ln p(X; \theta) 
$$

Maximizing this quantity is quintessential to fitting parameters. If the model is simple and there is no missing data, this is easy

However a simple model like a single gaussian is not always the best modeling choice, and sometimes we don't have all the data.

We can get around this by positing a variable $Z$. This lets us handle the case of incomplete data and the case of complex modeling.

1. Say we had a faulty sensor and we missed it's data $Z$. If we had the data, we could directly maximize $\ln p(X, Z; \theta)$. Since we don't have that data, we maximize $\ln p(X; \theta)$ and marginalize over $Z$.
$$
p(X; \theta) = \int p(X, Z; \theta)dZ
$$
2. If we don't want a simple model but a more expressive one, we can introduce a latent variable $Z$ and express our model as a sum of simpler models: $p(X|Z; \theta)$. The simpler model can be a single gaussian but the aggregate is much richer.
$$
p(X; \theta) = \int p(X|Z; \theta) p(Z; \theta) dZ = \int p(X, Z; \theta) dZ
$$

This makes the optimization harder however, as to compute $\nabla_\theta \ln p(X; \theta)$, we need to compute $p(X; \theta)$ which is an integral $p(X; \theta)  = \int p(X | Z; \theta) p(Z; \theta) dZ$. There is no easy to way to get rid of the integral.

Why is the integral hard? If $p(X|Z; \theta)$ is a neural network, the integral is intractable.

# Evidence Lower Bound
One solution is to use Evidence Lower Bound as a proxy. Choose any distribution for $q(Z)$ over $Z$.

Now we can write

$$
\ln p(X; \theta) = \ln p(X; \theta) - KL(q||p(Z | X; \theta)) + KL(q || p(Z | X; \theta))
$$

We define

$$
ELBO = \ln p(X; \theta) - KL(q||p(Z | X; \theta)) 
$$

Since $KL \geq 0$, ELBO is a lower bound on $\ln p(X; \theta)$. We can group the terms to write it in its tractable form
$$
ELBO = E_q \left[ \ln \frac{p(X, Z; \theta)}{q(Z)} \right]
$$

We call the term $\ln p(X; \theta)$ "evidence", this is a rather loose way of putting it. This is actually the likelhood.

Briefly, evidence is way to measure how well the model as a whole explains the data, if we tried all possible parameters, i.e marginalized over them.
$$
p_\text{model}(X) = \int p_\text{model}(X | \theta)p(\theta)d\theta
$$

In this case, we are taking the "evidence" by marginalizing $Z$. 
$$
p_\text{model}(X; \theta) = \int p_\text{model}(X, Z; \theta) dZ
$$

Now note this interesting property: If we change $q$, the evidence doesn't change at all, no matter the choice of $q$.


To maximize $\ln p_\text{model}(X; \theta)$ we need to maximize the ELBO over both $q$ and $\theta$. No matter the choice of the algorithm, we will always maximize both. We get three cases

## Expectation Maximization

Note that if $\theta$ is fixed,  $q = p(Z|X; \theta)$ is the best choice of q. If $p(Z|X; \theta)$ is tractable, then we can simply start with a random $\theta_0$, then do these steps
    1. E-Step: find $q = p(Z|X; \theta_0$)
    2. M-Step: maximize elbo over theta with fixed $q = p(Z|X; \theta_0)$. Let this be $\theta_{EM}$. Then go back to step 1 with $\theta_0 = \theta_{EM}$. Repeat until convergence.

## Variational Expectation Maximization

If $p(Z|X; \theta)$ is not tractable, we can choose $q$ from a simple family. This is similar to variational calculus where we optimize over a family of functions. This approach is called VEM.

## Variational Inference

If $p(Z|X; \theta$) is not tractable and we don't want to restrict over a simple family, we can approximate q using a neural network. i.e $q(Z | X; \phi)$.  Then we run joint optimization over $\theta$ and $\phi$. This approach is called Full Variational Inference. eg VAE.


# Case Studies

Before jumping into case studies, let's understand that there are two choices we must make when using ELBO. The first choice is inevitable in all of generative modelling, i.e choose a model for $p \approx p_\theta$.

The second choice is ELBO specific. When try to maximize the ELBO, any choice for $q$ is valid. A poor choice of $q$ (i.e which has a high $KL(q||p(Z|X))$) just means we would have a loose bound on the actual $ln(p_\theta) \geq ELBO$ inequality. The bound is valid, we just leave some performance on the table. 

Finally both models, for $p \approx p_\theta$ and $q \approx p_\theta(Z|X)$ need to be tractable, this means there is a tradeoff between how exact we can make our model and what's computable.

To summarize, the two choices are
1. Choose model / approximation of the true distribution $p \approx p_\theta$
2. If using ELBO, choose an approximation q of the model's posterior $p_\theta(Z|X)$

# Hierarchical Latent Variable Models

## Modelling Choice 1: The Generative Model

Instead of a single latent variable, we take $T$ latent variables $x_1, x_2, \ldots, x_T$.
This gives us a model of the data distribution $x_0$ as

$$
p(x_0; \theta) = \int \int \ldots \int p(x_0, x_1, x_2, \ldots, x_T; \theta) \, dx_1 \, dx_2 \ldots dx_T
$$

We need to choose how to parameterize the joint $p(x_{0:T}; \theta)$. We **choose** a Markov structure in the reverse direction:

$$
x_T \to x_{T-1} \to \ldots \to x_2 \to x_1 \to x_0
$$

This gives the generative model:

$$
p(x_{0:T}; \theta) = p_\theta(x_T) \cdot \prod_{t=1}^{T} p_\theta(x_{t-1} | x_t)
$$

where $p_\theta(x_T)$ is a chosen prior (no learnable parameters in practice, but written with $\theta$ for consistency since it's part of the generative model).

This modelling choice fully defines a joint distribution, and therefore also defines a true posterior $p_\theta(x_{1:T} | x_0)$ via Bayes' rule. However, this posterior is **intractable** — we cannot compute it or the marginal $p(x_0; \theta)$ directly.

---

## Modelling Choice 2: The Variational Distribution

To train the model, we introduce a variational distribution $q(x_{1:T} | x_0)$. For **any** choice of $q$, we get the identity:

$$
\ln p(x_0; \theta) = \underbrace{\mathbb{E}_{q(x_{1:T}|x_0)} \left[ \ln \frac{p(x_{0:T}; \theta)}{q(x_{1:T} | x_0)} \right]}_{\text{ELBO}} + KL\big(q(x_{1:T} | x_0) \;\|\; p_\theta(x_{1:T} | x_0)\big)
$$

Since $KL \geq 0$, we have $\ln p(x_0; \theta) \geq \text{ELBO}$, so maximizing the ELBO pushes up the data log-likelihood.

We **choose** $q$ to have a Markov structure in the forward direction:

$$
x_0 \to x_1 \to x_2 \to \ldots \to x_{T-1} \to x_T
$$

$$
q(x_{1:T} | x_0) = \prod_{t=1}^{T} q(x_t | x_{t-1})
$$

This is a design choice, not an approximation. A bad choice of $q$ doesn't break anything — it only gives a looser bound (larger KL gap), leaving performance on the table. The Markov structure is chosen because:
- Each $q(x_t | x_{t-1})$ is easy to specify and sample from.
- The forward posteriors $q(x_{t-1} | x_t, x_0)$ are tractable via Bayes' rule (which is what makes the ELBO decomposition below clean).

---

## Reverse Factorization of $q$

Since $q$ is a Markov chain $x_0 \to x_1 \to \ldots \to x_T$, we can also factor $q(x_{1:T}|x_0)$ in the **reverse** direction. Using the chain rule in reverse order:

$$
q(x_{1:T}|x_0) = q(x_T|x_0) \cdot q(x_{T-1}|x_T, x_0) \cdot q(x_{T-2}|x_{T-1}, x_T, x_0) \cdots q(x_1|x_2, \ldots, x_T, x_0)
$$

By the Markov property of the forward chain, $x_{t-1}$ is conditionally independent of $x_{t+1}, \ldots, x_T$ given $(x_t, x_0)$. So each term simplifies:

$$
q(x_{1:T}|x_0) = q(x_T|x_0) \cdot \prod_{t=2}^{T} q(x_{t-1}|x_t, x_0)
$$

where each reverse conditional is given by Bayes' rule. We factor the joint $q(x_{t-1}, x_t, x_0)$ in two ways:

$$
q(x_{t-1}, x_t, x_0) = q(x_t | x_{t-1}) \, q(x_{t-1} | x_0) \, q(x_0)
$$

and

$$
q(x_{t-1}, x_t, x_0) = q(x_{t-1} | x_t, x_0) \, q(x_t | x_0) \, q(x_0)
$$

Equating and cancelling $q(x_0)$:

$$
q(x_{t-1} | x_t, x_0) = \frac{q(x_t | x_{t-1}) \, q(x_{t-1} | x_0)}{q(x_t | x_0)}
$$

This will be useful in the ELBO decomposition below.

---

## ELBO Decomposition

Expanding the ELBO:

$$
\text{ELBO} = \mathbb{E}_{q(x_{1:T}|x_0)} \left[ \ln \frac{p(x_{0:T}; \theta)}{q(x_{1:T} | x_0)} \right]
$$

Substituting both Markov factorizations:

$$
= \mathbb{E}_{q} \left[ \ln \frac{p_\theta(x_T) \cdot \prod_{t=1}^{T} p_\theta(x_{t-1} | x_t)}{\prod_{t=1}^{T} q(x_t | x_{t-1})} \right]
$$

Converting products to sums of logs:

$$
= \mathbb{E}_{q} \left[ \ln p_\theta(x_T) + \sum_{t=1}^{T} \ln p_\theta(x_{t-1} | x_t) - \sum_{t=1}^{T} \ln q(x_t | x_{t-1}) \right]
$$

**Key step:** For $t \geq 2$, we rewrite $q(x_t | x_{t-1})$ using Bayes' rule. Note that $x_0$ is already in the picture — everything lives inside $\mathbb{E}_{q(x_{1:T}|x_0)}$, so $q(x_t|x_{t-1})$ is really shorthand for $q(x_t|x_{t-1}, x_0)$ (the Markov property makes $x_0$ redundant, but it's always implicitly conditioned on). Using the result from the reverse factorization section:

$$
q(x_{t-1} | x_t, x_0) = \frac{q(x_t | x_{t-1}) \, q(x_{t-1} | x_0)}{q(x_t | x_0)}
$$

Take log of both sides and rearrange:

$$
\ln q(x_t | x_{t-1}) = \ln q(x_{t-1} | x_t, x_0) + \ln q(x_t | x_0) - \ln q(x_{t-1} | x_0)
$$

The $\ln q(x_t|x_0) - \ln q(x_{t-1}|x_0)$ terms **telescope** across the sum over $t = 2, \ldots, T$:

$$
\sum_{t=2}^{T} \big[\ln q(x_t|x_0) - \ln q(x_{t-1}|x_0)\big] = \ln q(x_T|x_0) - \ln q(x_1|x_0)
$$

### Collecting terms

After substituting the Bayes' rule rewrite and telescoping, and separating the $t=1$ term, we arrive at:

$$
\text{ELBO} = \mathbb{E}_{q(x_{1:T}|x_0)} \left[ \underbrace{\ln p_\theta(x_T) - \ln q(x_T|x_0)}_{(A)} + \sum_{t=2}^{T}\underbrace{\big[\ln p_\theta(x_{t-1}|x_t) - \ln q(x_{t-1}|x_t, x_0)\big]}_{(B_t)} + \underbrace{\ln p_\theta(x_0|x_1)}_{(C)} \right]
$$

Everything is inside one big $\mathbb{E}_{q(x_{1:T}|x_0)}$. We simplify each group by noting that irrelevant variables integrate out.

**Term (A):** Only depends on $x_T$. The expectation over $x_1, \ldots, x_{T-1}$ integrates to 1, leaving:

$$
\mathbb{E}_{q(x_T|x_0)}\left[\ln \frac{p_\theta(x_T)}{q(x_T|x_0)}\right] = -KL(q(x_T|x_0) \| p_\theta(x_T))
$$

**Term (C):** Only depends on $x_1$. Same logic:

$$
\mathbb{E}_{q(x_1|x_0)}[\ln p_\theta(x_0|x_1)]
$$

**Term ($B_t$):** Depends on **both** $x_t$ and $x_{t-1}$. All other variables integrate out, leaving a joint expectation:

$$
\mathbb{E}_{q(x_{t-1}, x_t | x_0)}\left[\ln \frac{p_\theta(x_{t-1}|x_t)}{q(x_{t-1}|x_t, x_0)}\right]
$$

Now split this joint expectation using $q(x_{t-1}, x_t|x_0) = q(x_t|x_0) \cdot q(x_{t-1}|x_t, x_0)$:

$$
= \mathbb{E}_{q(x_t|x_0)}\left[\;\mathbb{E}_{q(x_{t-1}|x_t, x_0)}\left[\ln \frac{p_\theta(x_{t-1}|x_t)}{q(x_{t-1}|x_t, x_0)}\right]\right]
$$

The **inner** expectation is over $x_{t-1}$ with $x_t$ held fixed — this is exactly $-KL(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t))$, a KL divergence that is a function of $x_t$.

The **outer** expectation then averages this KL over different values of $x_t$:

$$
= \mathbb{E}_{q(x_t|x_0)}\big[-KL(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t))\big]
$$

### Final result

Combining all three terms:

$$
\text{ELBO} = \underbrace{-KL\big(q(x_T | x_0) \;\|\; p_\theta(x_T)\big)}_{L_T} + \sum_{t=2}^{T} \underbrace{\mathbb{E}_{q(x_t|x_0)}\big[-KL\big(q(x_{t-1} | x_t, x_0) \;\|\; p_\theta(x_{t-1} | x_t)\big)\big]}_{L_t} + \underbrace{\mathbb{E}_{q(x_1|x_0)}\big[\ln p_\theta(x_0 | x_1)\big]}_{L_0}
$$

**Key observation:** The middle terms compare $p_\theta(x_{t-1} | x_t)$ not against the forward conditionals $q(x_t | x_{t-1})$, but against the **forward posteriors** $q(x_{t-1} | x_t, x_0)$. Nobody assumed this — it fell out of the algebra. The consequence: training pushes $p_\theta(x_{t-1}|x_t)$ toward $q(x_{t-1}|x_t, x_0)$, so the reverse process **learns to invert the forward process** as a result of optimization, not as an assumption.

---

## Interpretation of Each Term

- **$L_T$**: How well the end of the forward chain matches the prior $p_\theta(x_T)$. No learnable parameters in practice (since the prior is fixed by design), but the term still measures alignment.
- **$L_t$ (for $2 \leq t \leq T$)**: How well the learned reverse step $p_\theta(x_{t-1}|x_t)$ matches the forward posterior $q(x_{t-1}|x_t, x_0)$.
- **$L_0$**: Reconstruction quality — how well the final reverse step recovers $x_0$ from $x_1$.

---

## Notes

- Everything above is general — no diffusion-specific assumptions have been made.
- We have not specified the form of $q(x_t | x_{t-1})$ (e.g., Gaussian noise).
- We have not specified $p_\theta(x_T) = \mathcal{N}(0, I)$.
- The DDPM-specific design choices determine how $q(x_{t-1}|x_t, x_0)$ and the KL terms become tractable.

---

## Who Moves Toward Whom?

The $L_t$ terms minimize $KL(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t))$, averaged over $q(x_t|x_0)$. A natural question: does $p_\theta$ move toward $q$, or $q$ toward $p_\theta$?

The answer depends on **who has learnable parameters**. In DDPM, $q$ is entirely fixed (the noise schedule $\{\beta_t\}$ is a hyperparameter, not learned). Only $p_\theta$ has learnable parameters, so only $p_\theta$ moves. The target $q(x_{t-1}|x_t, x_0)$ is stationary.

In a general VAE, both $q_\phi$ and $p_\theta$ have learnable parameters, so both sides move during training. If we made the DDPM noise schedule learnable, the same would happen — $q$ would shift as $\beta_t$ changes, while $p_\theta$ chases it.

---

# DDPM: Gaussian Modelling Choices

The general framework above left $q(x_t|x_{t-1})$ and $p_\theta(x_T)$ unspecified. DDPM makes specific choices:

1. **Markov $q$** (already assumed above)
2. **Gaussian transitions:** $q(x_t|x_{t-1}) = \mathcal{N}(\sqrt{\alpha_t}\,x_{t-1},\; \beta_t I)$ with a fixed noise schedule $\{\beta_t\}$, where $\alpha_t = 1 - \beta_t$
3. **Gaussian prior:** $p_\theta(x_T) = \mathcal{N}(0, I)$
4. **Gaussian reverse:** $p_\theta(x_{t-1}|x_t) = \mathcal{N}(\mu_\theta(x_t, t),\; \tilde\beta_t I)$ where $\mu_\theta$ is a neural network

### Closed form for $q(x_t|x_0)$

Since each forward step is Gaussian, composing them gives:

$$
q(x_t|x_0) = \mathcal{N}(\sqrt{\bar\alpha_t}\,x_0,\; (1-\bar\alpha_t)I), \qquad \bar\alpha_t = \prod_{s=1}^{t} \alpha_s
$$

This lets us sample any $x_t$ directly from $x_0$ without running the chain: $x_t = \sqrt{\bar\alpha_t}\,x_0 + \sqrt{1-\bar\alpha_t}\,\epsilon$ where $\epsilon \sim \mathcal{N}(0,I)$.

### Closed form for $q(x_{t-1}|x_t, x_0)$

From the Bayes' rule result derived earlier:

$$
q(x_{t-1}|x_t, x_0) = \frac{q(x_t|x_{t-1})\,q(x_{t-1}|x_0)}{q(x_t|x_0)}
$$

All three terms are Gaussian. Since $q(x_t|x_0)$ doesn't depend on $x_{t-1}$, it acts as a normalizing constant. We combine the two quadratic forms in $x_{t-1}$:

$$
\ln q(x_{t-1}|x_t, x_0) = \underbrace{-\frac{1}{2\beta_t}\|x_t - \sqrt{\alpha_t}\,x_{t-1}\|^2}_{\text{from } q(x_t|x_{t-1})} \;\underbrace{- \frac{1}{2(1-\bar\alpha_{t-1})}\|x_{t-1} - \sqrt{\bar\alpha_{t-1}}\,x_0\|^2}_{\text{from } q(x_{t-1}|x_0)} + \text{const}
$$

**Collecting the $x_{t-1}^2$ coefficient** (gives the posterior variance):

$$
-\frac{1}{2}\left(\frac{\alpha_t}{\beta_t} + \frac{1}{1-\bar\alpha_{t-1}}\right) = -\frac{1}{2}\cdot\frac{1-\bar\alpha_t}{\beta_t(1-\bar\alpha_{t-1})}
$$

using $(1-\beta_t)(1-\bar\alpha_{t-1}) + \beta_t = 1 - \bar\alpha_t$. So:

$$
\tilde\beta_t = \frac{\beta_t(1-\bar\alpha_{t-1})}{1-\bar\alpha_t}
$$

**Collecting the $x_{t-1}$ coefficient** and multiplying by $\tilde\beta_t$ (gives the posterior mean):

$$
\tilde\mu_t(x_t, x_0) = \frac{\sqrt{\alpha_t}(1-\bar\alpha_{t-1})}{1-\bar\alpha_t}\,x_t + \frac{\sqrt{\bar\alpha_{t-1}}\,\beta_t}{1-\bar\alpha_t}\,x_0
$$

Therefore:

$$
q(x_{t-1}|x_t, x_0) = \mathcal{N}(\tilde\mu_t(x_t, x_0),\; \tilde\beta_t I)
$$

### What $p_\theta$ learns

The $L_t$ terms tell $p_\theta(x_{t-1}|x_t)$ to match $q(x_{t-1}|x_t, x_0)$. But $\tilde\mu_t$ depends on **both** $x_t$ and $x_0$, and the network only sees $x_t$ at inference time. So to match this target, the network must **implicitly predict $x_0$ from $x_t$**.

Since $x_t = \sqrt{\bar\alpha_t}\,x_0 + \sqrt{1-\bar\alpha_t}\,\epsilon$, predicting $x_0$ is equivalent to predicting $\epsilon$. There are three equivalent parameterizations:

1. **Predict $x_0$:** Network outputs $\hat x_0(x_t, t)$, plug into $\tilde\mu_t$ formula.
2. **Predict $\epsilon$:** Network outputs $\hat\epsilon(x_t, t)$, recover $x_0$ via rearranging $x_t = \sqrt{\bar\alpha_t}\,x_0 + \sqrt{1-\bar\alpha_t}\,\epsilon$. This is the DDPM choice.
3. **Predict $\mu$ directly:** Network outputs $\mu_\theta(x_t, t)$. Less common.

All three produce the same gradient. DDPM uses the $\epsilon$-prediction parameterization, which empirically works best.

### Why the Need to Predict $x_0$ is Structural

The fact that $p_\theta(x_{t-1}|x_t)$ must implicitly predict $x_0$ is a consequence of the general hierarchical latent variable setup, not anything DDPM-specific.

Once you choose the Markov structure on both $p$ and $q$, the ELBO decomposes into terms of the form:

$$KL(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t))$$

The target distribution $q(x_{t-1}|x_t, x_0)$ depends on both $x_t$ and $x_0$ — this fell out of the algebra (the reverse factorization via Bayes' rule). But $p_\theta(x_{t-1}|x_t)$ only gets to see $x_t$ at inference time. So to minimize this KL, the network inside $p_\theta$ has no choice but to internally form some estimate of $x_0$ from $x_t$ in order to match a target that depends on $x_0$.

None of that reasoning used Gaussian assumptions, a noise schedule, or $\epsilon$-prediction. It's purely structural — it follows from the Markov factorizations of $p$ and $q$ plus the ELBO decomposition.

What DDPM adds is making everything Gaussian, which gives you a *closed-form* expression for $q(x_{t-1}|x_t, x_0)$ and makes the "predict $x_0$" requirement concrete: the posterior mean $\tilde{\mu}_t$ is an explicit linear function of $x_t$ and $x_0$, and since $x_t = \sqrt{\bar{\alpha}_t}\,x_0 + \sqrt{1-\bar{\alpha}_t}\,\epsilon$, predicting $x_0$ becomes equivalent to predicting $\epsilon$. That equivalence is DDPM-specific, but the underlying necessity of predicting $x_0$ is not.

### Why $q(x_{t-1}|x_t)$ is the Optimum

The $L_t$ term in the ELBO, for a single data point $x_0$, is:

$$L_t = \mathbb{E}_{q(x_t|x_0)}\big[-KL\big(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t)\big)\big]$$

Here $x_0$ is fixed and the expectation is only over $q(x_t|x_0)$. When we train, we average this over the dataset (the MLE objective), which introduces an outer $\mathbb{E}_{q(x_0)}$:

$$\mathbb{E}_{q(x_0)}\,\mathbb{E}_{q(x_t|x_0)}\Big[KL\big(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t)\big)\Big]$$

We can swap the order of expectations by rewriting the joint $q(x_0, x_t) = q(x_0)\,q(x_t|x_0) = q(x_t)\,q(x_0|x_t)$:

$$= \mathbb{E}_{q(x_t)}\,\mathbb{E}_{q(x_0|x_t)}\Big[KL\big(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t)\big)\Big]$$

Now for a fixed $x_t$, since $p_\theta(x_{t-1}|x_t)$ does not depend on $x_0$, the inner expectation over $q(x_0|x_t)$ can be rewritten. Using the identity that averaging KL divergences with a shared second argument over a mixture gives the KL of the mixture plus an entropy-like term independent of the second argument:

$$\mathbb{E}_{q(x_0|x_t)}\Big[KL\big(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t)\big)\Big] = KL\big(q(x_{t-1}|x_t) \| p_\theta(x_{t-1}|x_t)\big) + \text{const}$$

where $q(x_{t-1}|x_t) = \mathbb{E}_{q(x_0|x_t)}\big[q(x_{t-1}|x_t, x_0)\big]$ is the mixture of posteriors weighted by $q(x_0|x_t)$, and the constant does not depend on $\theta$.

So minimizing over $\theta$ is equivalent to minimizing $KL(q(x_{t-1}|x_t) \| p_\theta(x_{t-1}|x_t))$ for each $x_t$, and the unconstrained optimum is:

$$p_\theta(x_{t-1}|x_t) = q(x_{t-1}|x_t)$$

**Intuition:** The network sees the same $x_t$ paired with many different $x_0$'s during training. It cannot condition on $x_0$ at test time, so it learns to average over all $x_0$'s that could have produced that $x_t$. That average is exactly $q(x_{t-1}|x_t)$.

**Note on the ELBO vs. training objective:** The $L_t$ terms involve $\mathbb{E}_{q(x_t|x_0)}$, not $\mathbb{E}_{q(x_t)}$ — the outer $\mathbb{E}_{q(x_0)}$ comes from averaging the ELBO over the dataset, not from the ELBO itself. Only after combining both does the marginal $q(x_t)$ appear and the optimum argument go through. With shared network parameters across timesteps, all the $L_t$ objectives are coupled through $\theta$, but with sufficient network capacity (since $t$ is given as input), each timestep can in principle be matched independently.

---

# DDIM: Non-Markov Alternative

DDIM reuses the same trained $p_\theta$ (same network, same weights) but changes the **inference procedure** by choosing a different $q$.

### What stays the same
- $p_\theta(x_T) = \mathcal{N}(0, I)$
- Same marginals: $q(x_t|x_0) = \mathcal{N}(\sqrt{\bar\alpha_t}\,x_0,\; (1-\bar\alpha_t)I)$
- Same trained network

### What changes

DDIM drops the Markov assumption on $q$ and directly specifies the joint as:

$$q(x_{1:T}|x_0) = q(x_T|x_0)\prod_{t=2}^T q(x_{t-1}|x_t, x_0)$$

Each reverse conditional $q(x_{t-1}|x_t, x_0)$ is **chosen directly** as a Gaussian — no forward Markov chain, no Bayes' rule derivation. The only constraint is marginal consistency: the chosen conditionals must be compatible with the fixed marginals $q(x_t|x_0) = \mathcal{N}(\sqrt{\bar\alpha_t}\,x_0,\;(1-\bar\alpha_t)I)$. You can't pick arbitrary Gaussians — this consistency requirement pins down the mean of $q(x_{t-1}|x_t, x_0)$, leaving only the variance $\sigma_t^2$ as a free parameter:

$$
q(x_{t-1}|x_t, x_0) = \mathcal{N}\Big(\sqrt{\bar\alpha_{t-1}}\,x_0 + \sqrt{1-\bar\alpha_{t-1}-\sigma_t^2}\cdot\frac{x_t - \sqrt{\bar\alpha_t}\,x_0}{\sqrt{1-\bar\alpha_t}},\;\; \sigma_t^2 I\Big)
$$

The two extremes fall out naturally. $\sigma_t = \sqrt{\tilde\beta_t}$ happens to give exactly the reverse conditionals that DDPM derived via Bayes' rule from a Markov forward chain. $\sigma_t = 0$ makes the reverse step fully deterministic. Everything in between is also valid — each choice yields a different joint $q(x_{0:T})$, but all share the same marginals $q(x_t|x_0)$ and are therefore compatible with the same trained $p_\theta$.

### Why the Marginals Must Be Preserved

There are two reasons — one mathematical, one practical.

**Mathematical:** The reverse factorization defines a valid joint distribution regardless of the choice of reverse conditionals. Specifying $q(x_{t-1}|x_t, x_0)$ freely always implies *some* marginals $q(x_t|x_0)$ — you get them by integrating out. In principle you could let the marginals be whatever they end up being; the ELBO is still valid. Nothing breaks mathematically.

**Practical:** The network was already trained. During DDPM training, the loss terms sample $x_t$ via $q(x_t|x_0) = \mathcal{N}(\sqrt{\bar\alpha_t}\,x_0,\;(1-\bar\alpha_t)I)$. The network learned to denoise inputs drawn from this specific distribution. If DDIM used reverse conditionals that implied different marginals, then at inference time the network would receive inputs from a distribution it never saw during training — a distribution mismatch that would cause it to perform poorly.

So the marginal constraint is not about keeping the math valid. It is about keeping the trained network compatible. DDIM's whole point is to be a different inference procedure for the **same** trained model, which is only possible if the distribution of $x_t$ the network encounters at inference time matches what it saw during training.

### The role of $\sigma_t$

The $\sigma_t = 0$ case is what makes DDIM powerful — the reverse step becomes fully deterministic, so there is no noise accumulation when skipping timesteps. Instead of running the full chain $x_T \to x_{T-1} \to \ldots \to x_0$, you can jump $x_T \to x_{T-10} \to x_{T-20} \to \ldots \to x_0$ and still get coherent samples.

### Summary comparison

| | DDPM | DDIM |
|---|---|---|
| Forward $q$ | Markov: define $q(x_t\|x_{t-1})$ | Non-Markov: define $q(x_{t-1}\|x_t, x_0)$ directly |
| Marginals $q(x_t\|x_0)$ | Same | Same |
| Posterior $q(x_{t-1}\|x_t, x_0)$ | Derived via Bayes' rule | Chosen directly |
| Stochasticity | Fixed ($\tilde\beta_t$) | Tunable ($\sigma_t$) |
| Network | Same | Same |

DDPM and DDIM are different **inference procedures** for the same trained model. They correspond to different choices of $q$ that share the same marginals, so the same $p_\theta$ is compatible with both.

---

# Flow Matching: A Different Framework

Flow matching arrives at a similar outcome (mapping noise to data) but with fundamentally different math. Instead of the discrete chain + ELBO machinery, it works with continuous dynamics directly.

### Core idea

Define a **continuous trajectory** governed by an ODE:

$$
\frac{dx}{dt} = v_\theta(x, t)
$$

where $t \in [0, 1]$, $x(0) \sim \mathcal{N}(0, I)$ is noise, and $x(1) = x_0$ is data. The neural network $v_\theta$ learns a **velocity field** that tells each point which direction to move at each time.

### Training objective

The training objective is a simple regression:

$$
\mathcal{L} = \mathbb{E}_{t,\, x_0,\, \epsilon}\left[\|v_\theta(x_t, t) - u_t(x_t | x_0)\|^2\right]
$$

where $u_t(x_t|x_0)$ is a **target velocity field**. The simplest choice is a straight line interpolation from noise to data:

$$
x_t = (1-t)\,\epsilon + t\,x_0, \qquad u_t = x_0 - \epsilon
$$

The target velocity is just "go from $\epsilon$ toward $x_0$." The network learns to regress onto this. No ELBO, no KL, no Bayes' rule.

### Why straight paths matter

Diffusion (via the noise schedule) induces **curved** transport paths from noise to data. Flow matching uses **straight** paths by design. Straight paths are the shortest route, which means fewer ODE solver steps are needed at inference time.

### Connection to diffusion

DDIM with $\sigma_t = 0$ is also an ODE (the "probability flow ODE"). Flow matching can be seen as: instead of deriving this ODE indirectly through ELBO → simplify → discover an ODE, just define the ODE directly and train with regression.

The diffusion path: modelling choices → ELBO → simplify → turns out you're predicting noise → which implies an ODE.

The flow matching path: define the ODE directly → train with regression.

Same destination, much shorter derivation. The cost is losing some probabilistic interpretation (no explicit $q$, $p_\theta$, or ELBO), but in practice results are comparable or better.

### Summary comparison

|                              | Diffusion (DDPM/DDIM)                 | Flow Matching        |
| ---------------------------- | ------------------------------------- | -------------------- |
| Framework                    | Discrete Markov chain + ELBO          | Continuous ODE       |
| Training derived from        | Variational bound                     | Direct regression    |
| What network predicts        | Noise $\epsilon$ (or $x_0$, or $\mu$) | Velocity $v$         |
| Transport path               | Curved (determined by noise schedule) | Straight (by design) |
| Noise schedule $\{\beta_t\}$ | Required                              | Not needed           |

# Hierarchical Latent Variable Models

## Modelling Choice 1: The Generative Model

Instead of a single latent variable, we take $T$ latent variables $x_1, x_2, \ldots, x_T$.
This gives us a model of the data distribution $x_0$ as

$$
p(x_0; \theta) = \int \int \ldots \int p(x_0, x_1, x_2, \ldots, x_T; \theta) \, dx_1 \, dx_2 \ldots dx_T
$$

We need to choose how to parameterize the joint $p(x_{0:T}; \theta)$. We **choose** a Markov structure in the reverse direction:

$$
x_T \to x_{T-1} \to \ldots \to x_2 \to x_1 \to x_0
$$

This gives the generative model:

$$
p(x_{0:T}; \theta) = p_\theta(x_T) \cdot \prod_{t=1}^{T} p_\theta(x_{t-1} | x_t)
$$

where $p_\theta(x_T)$ is a chosen prior (no learnable parameters in practice, but written with $\theta$ for consistency since it's part of the generative model).

This modelling choice fully defines a joint distribution, and therefore also defines a true posterior $p_\theta(x_{1:T} | x_0)$ via Bayes' rule. However, this posterior is **intractable** — we cannot compute it or the marginal $p(x_0; \theta)$ directly.

---

## Modelling Choice 2: The Variational Distribution

To train the model, we introduce a variational distribution $q(x_{1:T} | x_0)$. For **any** choice of $q$, we get the identity:

$$
\ln p(x_0; \theta) = \underbrace{\mathbb{E}_{q(x_{1:T}|x_0)} \left[ \ln \frac{p(x_{0:T}; \theta)}{q(x_{1:T} | x_0)} \right]}_{\text{ELBO}} + KL\big(q(x_{1:T} | x_0) \;\|\; p_\theta(x_{1:T} | x_0)\big)
$$

Since $KL \geq 0$, we have $\ln p(x_0; \theta) \geq \text{ELBO}$, so maximizing the ELBO pushes up the data log-likelihood.

We **choose** $q$ to have a Markov structure in the forward direction:

$$
x_0 \to x_1 \to x_2 \to \ldots \to x_{T-1} \to x_T
$$

$$
q(x_{1:T} | x_0) = \prod_{t=1}^{T} q(x_t | x_{t-1})
$$

This is a design choice, not an approximation. A bad choice of $q$ doesn't break anything — it only gives a looser bound (larger KL gap), leaving performance on the table. The Markov structure is chosen because:
- Each $q(x_t | x_{t-1})$ is easy to specify and sample from.
- The forward posteriors $q(x_{t-1} | x_t, x_0)$ are tractable via Bayes' rule (which is what makes the ELBO decomposition below clean).

---

## Reverse Factorization of $q$

Since $q$ is a Markov chain $x_0 \to x_1 \to \ldots \to x_T$, we can also factor $q(x_{1:T}|x_0)$ in the **reverse** direction. Using the chain rule in reverse order:

$$
q(x_{1:T}|x_0) = q(x_T|x_0) \cdot q(x_{T-1}|x_T, x_0) \cdot q(x_{T-2}|x_{T-1}, x_T, x_0) \cdots q(x_1|x_2, \ldots, x_T, x_0)
$$

By the Markov property of the forward chain, $x_{t-1}$ is conditionally independent of $x_{t+1}, \ldots, x_T$ given $(x_t, x_0)$. So each term simplifies:

$$
q(x_{1:T}|x_0) = q(x_T|x_0) \cdot \prod_{t=2}^{T} q(x_{t-1}|x_t, x_0)
$$

where each reverse conditional is given by Bayes' rule. We factor the joint $q(x_{t-1}, x_t, x_0)$ in two ways:

$$
q(x_{t-1}, x_t, x_0) = q(x_t | x_{t-1}) \, q(x_{t-1} | x_0) \, q(x_0)
$$

and

$$
q(x_{t-1}, x_t, x_0) = q(x_{t-1} | x_t, x_0) \, q(x_t | x_0) \, q(x_0)
$$

Equating and cancelling $q(x_0)$:

$$
q(x_{t-1} | x_t, x_0) = \frac{q(x_t | x_{t-1}) \, q(x_{t-1} | x_0)}{q(x_t | x_0)}
$$

This reverse factorization is not an assumption — it's a mathematical consequence of the forward Markov structure. It will be useful in the ELBO decomposition below.

---

## ELBO Decomposition

Expanding the ELBO:

$$
\text{ELBO} = \mathbb{E}_{q(x_{1:T}|x_0)} \left[ \ln \frac{p(x_{0:T}; \theta)}{q(x_{1:T} | x_0)} \right]
$$

Substituting both Markov factorizations:

$$
= \mathbb{E}_{q} \left[ \ln \frac{p_\theta(x_T) \cdot \prod_{t=1}^{T} p_\theta(x_{t-1} | x_t)}{\prod_{t=1}^{T} q(x_t | x_{t-1})} \right]
$$

Converting products to sums of logs:

$$
= \mathbb{E}_{q} \left[ \ln p_\theta(x_T) + \sum_{t=1}^{T} \ln p_\theta(x_{t-1} | x_t) - \sum_{t=1}^{T} \ln q(x_t | x_{t-1}) \right]
$$

**Key step:** For $t \geq 2$, we rewrite $q(x_t | x_{t-1})$ using Bayes' rule. Note that $x_0$ is already in the picture — everything lives inside $\mathbb{E}_{q(x_{1:T}|x_0)}$, so $q(x_t|x_{t-1})$ is really shorthand for $q(x_t|x_{t-1}, x_0)$ (the Markov property makes $x_0$ redundant, but it's always implicitly conditioned on). Using the result from the reverse factorization section:

$$
q(x_{t-1} | x_t, x_0) = \frac{q(x_t | x_{t-1}) \, q(x_{t-1} | x_0)}{q(x_t | x_0)}
$$

Take log of both sides and rearrange:

$$
\ln q(x_t | x_{t-1}) = \ln q(x_{t-1} | x_t, x_0) + \ln q(x_t | x_0) - \ln q(x_{t-1} | x_0)
$$

The $\ln q(x_t|x_0) - \ln q(x_{t-1}|x_0)$ terms **telescope** across the sum over $t = 2, \ldots, T$:

$$
\sum_{t=2}^{T} \big[\ln q(x_t|x_0) - \ln q(x_{t-1}|x_0)\big] = \ln q(x_T|x_0) - \ln q(x_1|x_0)
$$

### Collecting terms

After substituting the Bayes' rule rewrite and telescoping, and separating the $t=1$ term, we arrive at:

$$
\text{ELBO} = \mathbb{E}_{q(x_{1:T}|x_0)} \left[ \underbrace{\ln p_\theta(x_T) - \ln q(x_T|x_0)}_{(A)} + \sum_{t=2}^{T}\underbrace{\big[\ln p_\theta(x_{t-1}|x_t) - \ln q(x_{t-1}|x_t, x_0)\big]}_{(B_t)} + \underbrace{\ln p_\theta(x_0|x_1)}_{(C)} \right]
$$

Everything is inside one big $\mathbb{E}_{q(x_{1:T}|x_0)}$. We simplify each group by noting that irrelevant variables integrate out.

**Term (A):** Only depends on $x_T$. The expectation over $x_1, \ldots, x_{T-1}$ integrates to 1, leaving:

$$
\mathbb{E}_{q(x_T|x_0)}\left[\ln \frac{p_\theta(x_T)}{q(x_T|x_0)}\right] = -KL(q(x_T|x_0) \| p_\theta(x_T))
$$

**Term (C):** Only depends on $x_1$. Same logic:

$$
\mathbb{E}_{q(x_1|x_0)}[\ln p_\theta(x_0|x_1)]
$$

**Term ($B_t$):** Depends on **both** $x_t$ and $x_{t-1}$. All other variables integrate out, leaving a joint expectation:

$$
\mathbb{E}_{q(x_{t-1}, x_t | x_0)}\left[\ln \frac{p_\theta(x_{t-1}|x_t)}{q(x_{t-1}|x_t, x_0)}\right]
$$

Now split this joint expectation using $q(x_{t-1}, x_t|x_0) = q(x_t|x_0) \cdot q(x_{t-1}|x_t, x_0)$:

$$
= \mathbb{E}_{q(x_t|x_0)}\left[\;\mathbb{E}_{q(x_{t-1}|x_t, x_0)}\left[\ln \frac{p_\theta(x_{t-1}|x_t)}{q(x_{t-1}|x_t, x_0)}\right]\right]
$$

The **inner** expectation is over $x_{t-1}$ with $x_t$ held fixed — this is exactly $-KL(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t))$, a KL divergence that is a function of $x_t$.

The **outer** expectation then averages this KL over different values of $x_t$:

$$
= \mathbb{E}_{q(x_t|x_0)}\big[-KL(q(x_{t-1}|x_t, x_0) \| p_\theta(x_{t-1}|x_t))\big]
$$

### Final result

Combining all three terms:

$$
\text{ELBO} = \underbrace{-KL\big(q(x_T | x_0) \;\|\; p_\theta(x_T)\big)}_{L_T} + \sum_{t=2}^{T} \underbrace{\mathbb{E}_{q(x_t|x_0)}\big[-KL\big(q(x_{t-1} | x_t, x_0) \;\|\; p_\theta(x_{t-1} | x_t)\big)\big]}_{L_t} + \underbrace{\mathbb{E}_{q(x_1|x_0)}\big[\ln p_\theta(x_0 | x_1)\big]}_{L_0}
$$

**Key observation:** The middle terms compare $p_\theta(x_{t-1} | x_t)$ not against the forward conditionals $q(x_t | x_{t-1})$, but against the **forward posteriors** $q(x_{t-1} | x_t, x_0)$. Nobody assumed this — it fell out of the algebra. The consequence: training pushes $p_\theta(x_{t-1}|x_t)$ toward $q(x_{t-1}|x_t, x_0)$, so the reverse process **learns to invert the forward process** as a result of optimization, not as an assumption.

---

## Interpretation of Each Term

- **$L_T$**: How well the end of the forward chain matches the prior $p_\theta(x_T)$. No learnable parameters in practice (since the prior is fixed by design), but the term still measures alignment.
- **$L_t$ (for $2 \leq t \leq T$)**: How well the learned reverse step $p_\theta(x_{t-1}|x_t)$ matches the forward posterior $q(x_{t-1}|x_t, x_0)$.
- **$L_0$**: Reconstruction quality — how well the final reverse step recovers $x_0$ from $x_1$.

---

## Notes

- Everything above is general — no diffusion-specific assumptions have been made.
- We have not specified the form of $q(x_t | x_{t-1})$ (e.g., Gaussian noise).
- We have not specified $p_\theta(x_T) = \mathcal{N}(0, I)$.
- The DDPM-specific design choices determine how $q(x_{t-1}|x_t, x_0)$ and the KL terms become tractable.


---
# Appendix

This can be solved in various ways, depending some properties of the problem and modeling choices.
1. Expectation Maximization

Now we need a model for $p_\theta$ that can model this effectively. 


## Latent Variable MLE

Sometimes we hypothesize that there is a latent / hidden variable that influences our probability distribution, i.e our model $p_\theta$ is
$$
p_\theta(x) = \int p_\theta(x, z) dz
$$


### Exact Expectation Maximization / Exact Gradients

If the we can compute the expectation in closed form
$$
E_{p_\theta(z|x)}[.]
$$
then we can solve it with Expectation Maximization

1. E-Step: 

### Approximate Inference

If we can sample well from the posterior $p_\theta(z | x)$ or from the joint $p_\theta(z, x)$ reliably enough, we can solve our Latent Variable MLE approximately:

1. MCMC (data augmentation, Gibbs Metropolis, etc)
2. Monte Carlo EM (approximate the E step with sampels)
3. Importance sampling/ SMC variants.

This is similar to the first approach but can  be expensive.

### Variational Inference

Assume that the sampling based approaches wont work and the integral is still intractable.

If the integral is intractable and it makes it difficult to compute the gradients of $\log p_\theta$

For one datum $x$, consider
$$
\nabla_\theta \log p_\theta(x) = \frac1{p_\theta(x)} \nabla_\theta p_\theta(x)
$$
$$
\nabla_\theta \log p_\theta(x)
= 
\frac1{p_\theta(x)} \nabla_\theta \int p_\theta(x, z) dz
$$

Since the integeral is under z, we can move the gradient operator inside

$$
\nabla_\theta \log p_\theta(x)
= 
\frac1{p_\theta(x)} \int \nabla_\theta p_\theta(x, z) dz
$$

Now note that
$$
\nabla_\theta \log p_\theta(x,z) = \frac1{p_\theta(x,z)} \nabla_\theta p_\theta(x, z)
$$
$$
p_\theta(x,z) 
\nabla_\theta \log p_\theta(x,z)
= 
\nabla_\theta p_\theta(x, z)
$$

So we substitute in our original equation
$$
\nabla_\theta \log p_\theta(x)
= 
\frac1{p_\theta(x)} \int \nabla_\theta p_\theta(x, z) dz
=
\frac1{p_\theta(x)} \int 
p_\theta(x,z) 
\nabla_\theta \log p_\theta(x,z)
dz
$$

We can take $p_\theta(x)$ under the integral sign
$$
\nabla_\theta \log p_\theta(x)
=
\int
\frac{p_\theta(x,z)}{p_\theta(x)}
\nabla_\theta \log p_\theta(x,z)
dz
$$

Using Bayes' rule
$$
\frac{p_\theta(x, z)}{p_\theta(x)} = p_\theta(z | x)
$$

$$
\nabla_\theta \log p_\theta(x)
=
\int
p_\theta(z|x)
\nabla_\theta \log p_\theta(x,z)
dz
$$
This becomes
$$
\nabla_\theta \log p_\theta(x)
=
E_{p_\theta(z|x)}
[
\log p_\theta(x,z)
]
$$

i.e under an expectation under the posterior distribution of the latent variable.

To evaluate this, we need 
$$
\frac{p_\theta(x, z)}{p_\theta(x)} = p_\theta(z | x)
$$

where $p_\theta(x) = \int p_\theta(x, z) dz$. Since the integral is intractable, so is the gradient.

We try to approximate $p_\theta(z | x)$ with $q_\phi(z | x)$. We choose a family of tractable $q_\phi$ and try to find

$$
q^*(z|x) = arg \min_{q \in \mathcal{Q}} \text{KL}(q_\phi(z | x) \ || \ p_\theta(z|x))
$$

This objective is true $VI$, we have turned our inference problem into something like calculus of variations. However, here our goal is not just VI (which is needed to make a tractable approximation to $p_\theta(z | x)$) but also learning, which is to maximize the likelhood of data $\log p_\theta(x)$.

We will now describe how we do the $VI$ + learning approach. Consider 
$$
\log p_\theta(x) = E_{q_\phi} [\log p_\theta(x)]
$$
$$
E_{q_\phi} [\log p_\theta(x)] = E_{q_\phi} [ \log \frac{p_\theta(x, z)}{p_\theta(z | x)}]
$$
$$
E_{q_\phi} [\log p_\theta(x)] = 
E_{q_\phi} [ \log p_\theta(x, z)]
-
E_{q_\phi} [ \log p_\theta(z | x)]
$$
Now we add and subtract $E_{q_\phi}[\log q_\phi(z | x)]$
$$
E_{q_\phi} [\log p_\theta(x)] = 
E_{q_\phi} [ \log p_\theta(x, z)]
-
E_{q_\phi} [ \log p_\theta(z | x)
-E_{q_\phi}[\log q_\phi(z | x)]
+E_{q_\phi}[\log q_\phi(z | x)]
$$

If we rearrange
$$
E_{q_\phi} [\log p_\theta(x)] = 
\left( 
E_{q_\phi} [ \log p_\theta(x, z)]
-E_{q_\phi}[\log q_\phi(z | x)]
\right)
+
\left( E_{q_\phi}[\log q_\phi(z | x)]
-E_{q_\phi} [ \log p_\theta(z | x)
\right)
$$

The first term is the ELBO and the second is simply a KL divergence

$$
\text{ELBO}(x; \phi, \theta)
= 
E_{q_\phi} [ \log p_\theta(x, z)]
-E_{q_\phi}[\log q_\phi(z | x)]
$$
$$
\text{KL}(q_\phi(z|x) \ || \ p_\theta(z|x))
= 
E_{q_\phi} [ \log q_\phi(z | x)]
-E_{q_\phi}[\log p_\theta(z | x)]
$$

Since KL divergence is always non-negative,

$$
\log p_\theta(x) \geq \text{ELBO}(x; \theta, \phi)
$$
If we maximize ELBO, we are maximizing a lower bound on $\log p_\theta(x)$. This is a proxy method of maximizing our objective. However, there is a caveat here

1. True VI: If $\theta$ is fixed, then maximizing the ELBO same as minimizing $\text{KL}(q_\phi(z|x) \ || \ p_\theta(z|x))$. This maps 1:1 to SLAM when we want to approximate. $p_\theta(x_{1:T}, m | z_{1:T}, u_{1:T})$. where our observations and controls are the observed variables / data ($x^{(i)}$) and the map + robot positions are the latent variables. VI is used when $p_\theta$ is intractable, otherwise we can use other approaches.
2. VI + learning (MLE): If $\theta$ is not fixed, then maximizing ELBO will do both to some extent: it will try maximize $p_\theta$ but also minimize the KL. (Imagine that during optimization, some steps may not change the actual likelihood $p_\theta(x)$ very much, but reduce KL, while some steps may push $p_\theta(x)$ and not touch KL). This is also called variational EM where VI plays E step and update theta plays M step. Nuance: MLE with a variational lower bound (often called approximate MLE) as for non zero KL, we are only approximating the log likelhood.





## Expectation Maximization

Let $\theta \in \Theta$.  choose a random $\theta_0 \in \Theta$.

Now we can choose $q(Z) = p(Z | X; \theta_0)$.

The evidence is still the same as before nothing has changed. Now what if we try to maximize ELBO over theta?

$$
\max_\theta 
\ln p(X; \theta) - KL(p(Z | X; \theta_0) ||p(Z | X; \theta)) 
$$

Note that this maximization will do better than $\theta = \theta_0$. 




Thus if $\theta$ is known, we can maximize the elbo, which will minimize $KL(q || p(Z | X; \theta))$, essentially giving us a q close to $p(Z|X; \theta)$.






We can do a trick: 
1. Since  $p(X; \theta)$ doesn't depend on $Z$, we can take expectation under any distribution $q(Z)$.
$$
\ln p(X; \theta) = E_{q} \left[ \ln p(X; \theta) \right]
$$
2. we use Bayes' theorem
$$
p(X; \theta) = 
\frac{p(X, Z; \theta)}{p(Z | X; \theta)}
$$
This gives us 
$$
\ln p(X; \theta) = 
E_q
\left[
\ln \frac{p(X, Z; \theta)}{p(Z | X; \theta)}
\right]
$$

We can multiply and divide by $q(Z)$.
$$
\ln p(X; \theta) = 
E_q
\left[
\ln \left( \frac{p(X, Z; \theta)}{q(Z)}
\frac{q(Z)}{p(Z | X; \theta)}
\right)
\right]
$$

Expanding the natural log
$$
\ln p(X; \theta) = 
E_q
\left[
\ln 
\left( 
\frac{p(X, Z; \theta)}{q(Z)}
\right)
+
\ln 
\left( 
\frac{q(Z)}{p(Z | X; \theta)}
\right)
\right]
$$
$$
\ln p(X; \theta) = 
E_q
\left[
\ln 
\left( 
\frac{p(X, Z; \theta)}{q(Z)}
\right)
\right]
+
E_q
\left[
\ln 
\left( 
\frac{q(Z)}{p(Z | X; \theta)}
\right)
\right]
$$

The second term in the sum is simply the KL divergence, and the left term is the elbo
$$
\ln p(X; \theta) = 
E_q
\left[
\ln 
\left( 
\frac{p(X, Z; \theta)}{q(Z)}
\right)
\right]
+
KL
\left( 
q(Z) || p(Z | X; \theta)
\right)
$$


# Evidence
Yes, essentially. The term "evidence" comes from Bayesian inference where you also put a prior $p(\theta)$ on the parameters. In that setting:

$$p(X) = \int p(X|\theta), p(\theta), d\theta$$

This is called the **model evidence** or **marginal likelihood** — it's how probable the observed data is under the entire model (with parameters integrated out). It tells you how well your _model as a whole_ explains the data, which is why it's called "evidence" — it's the evidence the data provides in favor of your model.

In the EM/ELBO context, we're using it a bit more loosely. There, $\ln p(X;\theta)$ is just the log-likelihood for a fixed $\theta$, and $Z$ plays the role that $\theta$ plays in the Bayesian setting:

$$p(X;\theta) = \int p(X, Z;\theta), dZ$$

So "evidence" here just means "the thing we get after marginalizing out the variable we don't observe." The name stuck even though the context shifted slightly.

In short: evidence = marginal likelihood = the quantity obtained by integrating out whatever variables you're not observing. The ELBO is a lower bound on the log of this quantity.