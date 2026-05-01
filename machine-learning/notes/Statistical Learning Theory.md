# Foundations of Statistical Learning Theory

## The Fundamental Problem

There is a data generating process. We don't know the process, and we only see finite samples from it. We want to learn a function that works well not just on the finite data we can see, but on everything the process could generate.

The finite data is the "training data," and the gap between "works on training data" vs. "works in general" is the central question of statistical learning theory.

---

## Setup

### Data Distribution

There is some unknown probability distribution $p_{data}(x)$ over the sample space. We never have access to this — it is the platonic ideal of "reality."

Each sample could be a single point or an input-output pair. For supervised learning, $(x, y) \sim p_{data}$.

### Training Set

We draw $m$ samples i.i.d. from $p_{data}$:

$$\mathcal{D} = \{x_1, x_2, \ldots, x_m\}$$

This finite dataset induces the **empirical distribution**, which places a spike of mass $1/m$ on each observed point:

$$\hat{p}_{data}(x) = \frac{1}{m} \sum_{i=1}^{m} \delta(x - x_i)$$

### Hypothesis Class

A family of candidate functions (or distributions) $\Pi = \{p_\theta : \theta \in \Theta\}$ that we search over. Restricting to a structured class prevents overfitting — we can't search over all possible functions.

---

## The Three Equivalent Axioms

The central insight is that three seemingly different starting points lead to **exactly the same optimization**. None is more fundamental than the others — they are equivalent characterizations, like how "minimize distance," "follow the straight line," and "take the path of zero curvature" are three descriptions of a geodesic.

### Axiom 1: Maximum Likelihood Estimation (MLE)

**Motivation:** A good model should assign high probability to things that actually happen.

$$\hat{\theta}_{MLE} = \arg\max_\theta \prod_{i=1}^{m} p_\theta(x_i)$$

Take the log, flip the sign, divide by $m$:

$$\hat{\theta}_{MLE} = \arg\min_\theta \left( -\frac{1}{m} \sum_{i=1}^{m} \log p_\theta(x_i) \right)$$

### Axiom 2: Minimize KL Divergence

**Motivation:** We want our model distribution to be as close as possible to the true data distribution. The KL divergence measures this distance:

$$D_{KL}(p_{data} \| p_\theta) = \mathbb{E}_{x \sim p_{data}} \left[ \log \frac{p_{data}(x)}{p_\theta(x)} \right]$$

Since we can't compute expectations under $p_{data}$, we approximate with the empirical average. The $\log p_{data}(x_i)$ term is constant with respect to $\theta$, so minimizing KL reduces to:

$$\arg\min_\theta \left( -\frac{1}{m}\sum_{i=1}^{m} \log p_\theta(x_i) \right)$$

### Axiom 3: Minimize Cross-Entropy

**Motivation:** Entropy measures the expected surprise of a distribution — how unpredictable samples are:

$$H(p) = \mathbb{E}_{x \sim p}[-\log p(x)]$$

Cross-entropy extends this: the expected surprise when data comes from one distribution ($p_{data}$) but we evaluate surprise under a different one ($p_\theta$):

$$H(p_{data}, p_\theta) = \mathbb{E}_{x \sim p_{data}}[-\log p_\theta(x)]$$

This decomposes as:

$$H(p_{data}, p_\theta) = H(p_{data}) + D_{KL}(p_{data} \| p_\theta)$$

That is, cross-entropy equals the irreducible entropy of reality plus how far our model is from reality. Since $H(p_{data})$ is constant with respect to $\theta$, minimizing cross-entropy is equivalent to minimizing KL divergence.

Cross-entropy is also the **population risk** — the expected loss under the true distribution. It is what determines real-world performance, but it is uncomputable because we don't know $p_{data}$. Approximating with finite samples:

$$\hat{H}(p_{data}, p_\theta) \approx \frac{1}{m}\sum_{i=1}^{m} -\log p_\theta(x_i)$$

This is the **empirical risk** — the average loss over training data. Training a model means **empirical risk minimization (ERM)**: picking the $\theta$ that minimizes this quantity:

$$\hat{\theta} = \arg\min_\theta \frac{1}{m}\sum_{i=1}^{m} -\log p_\theta(x_i)$$

### All three axioms arrive at the same place

$$\boxed{\hat{\theta} = \arg\min_\theta \frac{1}{m} \sum_{i=1}^{m} -\log p_\theta(x_i)}$$

Only the KL framing explicitly motivates caring about the true distribution. MLE on its own is purely about training data, which is why we need additional machinery to justify why it generalizes.

---

## The Conditional / Supervised Case

When we have input-output pairs and model $p_\theta(y|x)$ rather than $p_\theta(x)$, everything carries over. The distributional assumption determines what loss function emerges:

- **Gaussian** $p_\theta(y|x) = \mathcal{N}(\pi_\theta(x), \sigma^2 I)$ gives squared error $\|y - \pi_\theta(x)\|^2$
- **Bernoulli** gives binary cross-entropy
- **Categorical** gives cross-entropy
- **Laplacian** gives absolute error $|y - f_\theta(x)|$

You don't pick squared error because it seems reasonable — you pick it because you assumed Gaussian noise, and the math gives you squared error.

---

## Bridging the Gap: Why Does Training Loss Predict True Performance?

By the law of large numbers, as $m \to \infty$, empirical risk converges to population risk. But three things are needed to make this useful with finite $m$:

**1. The i.i.d. assumption:** Training and future data come from the same distribution.

**2. Law of large numbers:** For any fixed $\theta$, empirical risk converges to population risk.

**3. Uniform convergence:** The convergence holds simultaneously for all $\theta$ in the hypothesis class, so optimizing over $\theta$ doesn't break the approximation. This is where overfitting lives — without this, ERM could find $\theta$ that looks great on training data but fails in general.

We need:

$$\sup_{\theta \in \Theta} |\mathcal{L}(\theta) - \hat{\mathcal{L}}_m(\theta)| \leq \epsilon$$

---

## Measuring Hypothesis Class Complexity

The uniform convergence bound depends on how complex the hypothesis class is. **Rademacher complexity** measures how well the class can correlate with random noise:

$$R_m(\Pi) = \mathbb{E}\left[\sup_{f \in \Pi} \frac{1}{m}\sum_{i=1}^{m} \sigma_i f(x_i)\right]$$

where $\sigma_i$ are random $\pm 1$ coin flips. This gives the standard generalization bound:

$$\sup_{f \in \Pi} |\mathcal{L}(f) - \hat{\mathcal{L}}_m(f)| \leq 2 R_m(\Pi) + C\sqrt{\frac{\log(1/\delta)}{m}}$$

with probability at least $1 - \delta$.

---

## Decomposing the Generalization Error

Let $f^* = \arg\min_{f \in \Pi} \mathcal{L}(f)$ be the best function in the class under the true distribution, and $\hat{f}$ the ERM solution. The total error decomposes as:

**Term A** — how much training loss underestimates the true loss of $\hat{f}$:

$$A = \mathcal{L}(\hat{f}) - \hat{\mathcal{L}}_m(\hat{f})$$

**Term B** $\leq 0$ by definition of ERM, since $\hat{f}$ minimizes empirical risk:

$$B = \hat{\mathcal{L}}_m(\hat{f}) - \hat{\mathcal{L}}_m(f^*)$$

**Term C** — how much training loss misrepresents the true loss of $f^*$:

$$C = \hat{\mathcal{L}}_m(f^*) - \mathcal{L}(f^*)$$

The generalization gap is $A + B + C$:

$$\mathcal{L}(\hat{f}) - \min_{f \in \Pi} \mathcal{L}(f) = A + B + C$$

Terms A and C are controlled by uniform convergence and bounded by Rademacher complexity.

---

## Connection to the RINSE Paper

The paper applies this framework to behavioral cloning:

- **Hypothesis class** $\Pi_L$: all $L$-Lipschitz policies (squared error loss, i.e. Gaussian assumption)
- **The Fourier trick**: smooth demonstrations can be represented by $K$ Fourier modes, reducing effective input dimension

Since Rademacher complexity of $L$-Lipschitz functions on $K$ dimensions is $O(L\sqrt{K}/m)$, and smooth data lets $K$ be small, the generalization bound tightens:

$$\mathcal{L}(\hat{\theta}) - \min_\theta \mathcal{L}(\theta) \leq C_1 \cdot L \cdot m^{-\alpha_0/(2\alpha_0+1)} + C_2 \cdot \frac{\log(1/\delta)}{m}$$

Smoother demonstrations (larger $\alpha_0$) → fewer Fourier modes needed → smaller effective hypothesis class → tighter generalization → fewer samples required.
