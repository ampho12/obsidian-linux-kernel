
# Measure Theory

Consider a measure space $(\Omega, \mathcal{F}, \mu)$. The measure is defined as
$$
\mu: \mathcal{F} \to [0, \infty)
$$


Now we will try to define what integral against $\mu$ looks like.

# From Riemann to Lebesgue Integration

## Setup

We work in a measure space $(\Omega, \mathcal{F}, \mu)$, where $\mu: \mathcal{F} \to [0, \infty]$ assigns a size to each measurable set. The goal is to define $\int f \, d\mu$ using nothing but $\mu$ and limits.

---

## 1. Riemann Integration Slices the Domain

Partition the domain $[a,b]$ into small intervals of width $\Delta x_i$ and sum:

$$
\sum_i f(x_i)\,\Delta x_i \;\longrightarrow\; \int_a^b f(x)\,dx
$$

Each term is **height $\times$ width**: a vertical rectangle.

```
f(x)
│     ┌──┐
│  ┌──┤  ├──┐
│  │  │  │  │
│──┤  │  │  ├──
│  │  │  │  │
└──┴──┴──┴──┴──── x
   Δx₁ Δx₂ Δx₃
```

This requires a notion of **width** ($\Delta x$, ultimately $dx$) between points in the domain. On an abstract space $\Omega$ with no distance or ordering, $\Delta x$ has no meaning. We need a different approach.

---

## 2. The Lebesgue Idea: Rethink the Function

To integrate on an abstract space, we don't need a new integral — we need a new way to **look at the function**.

### Any function is a stack of indicator functions

Take the simplest possible function: the indicator $\mathbf{1}_A$, which is $1$ on a set $A$ and $0$ elsewhere. We know everything about this function — it's fully described by the set $A$, and $\mu$ can measure that set.

Now notice: a function that takes the value $3$ on $A$ is just $3 \cdot \mathbf{1}_A$. A function that is $3$ on $A$ and $5$ on $B$ is $3 \cdot \mathbf{1}_A + 5 \cdot \mathbf{1}_B$. Any function that takes finitely many values can be written this way:

$$
\psi(\omega) = \sum_{i=1}^n a_i \cdot \mathbf{1}_{B_i}(\omega)
$$

These are called **simple functions** — weighted sums of indicators over disjoint measurable sets. They are built entirely from **sets** (which $\mu$ can measure) and **constants** (which are just numbers). No notion of distance, no $dx$, no structure on $\Omega$ beyond the measure.

### Partition the range to approximate any function

A general function $f \geq 0$ takes infinitely many values, so it isn't simple. But we can **approximate** it by one. Partition the range:

$$
0 = a_0 < a_1 < \cdots < a_n
$$

Each band $[a_{k-1}, a_k)$ defines a **level set** — all points in the domain whose function values fall in that band:

$$
A_k = \{\, \omega \in \Omega : a_{k-1} \leq f(\omega) < a_k \,\}
$$

```
f(ω)
│─ ─ ─ ─ ─ ─ ─ ─ ─ ─  a₃
│         ╱╲
│─ ─ ─ ─ ╱─ ╲─ ─ ─ ─  a₂        A₃ = preimage of [a₂, a₃)
│       ╱    ╲                  A₂ = preimage of [a₁, a₂)
│─ ─ ─ ╱─ ─ ─ ╲─ ─ ─  a₁        A₁ = preimage of [a₀, a₁)
│     ╱        ╲
│─── ╱──────────╲──── 0
└────────────────────── Ω
     A₁   A₃  A₂  A₁
```

Now **round down**: on each level set $A_k$, replace every value of $f$ with the floor of the band $a_{k-1}$. This produces a simple function:

$$
\psi(\omega) = \sum_{k=1}^n a_{k-1} \cdot \mathbf{1}_{A_k}(\omega)
$$

This $\psi$ is a staircase that sits just below $f$. Make the bands finer and the staircase hugs $f$ more tightly:

$$
\psi_n \uparrow f
$$

So every nonnegative measurable function is the **pointwise limit of an increasing sequence of simple functions**. We have rewritten an arbitrary $f$ entirely in terms of building blocks we understand.

---

## 3. The Integral Falls Out

### Simple functions

Intuitively, if we want to integrate a simple function $\psi = \sum_{k=1}^n a_k \cdot \mathbf{1}_{A_k}$, there is only one sensible answer: sum up height times size of base for each piece:

$$
\int \psi \, d\mu = \sum_{k=1}^n a_k \, \mu(A_k)
$$

This hinges on one foundational rule — the **indicator axiom**:

$$
\int \mathbf{1}_A \, d\mu = \mu(A)
$$

The integral of a function that is $1$ on $A$ and $0$ elsewhere equals the measure of $A$. Once this is fixed, linearity forces the formula above for any simple function.

Notice the $d\mu$ in the notation $\int \psi \, d\mu$. This is not decoration — it tells us **which measure** we are integrating against. The same function $\psi$ can be integrated against different measures, and $d\mu$ encodes that choice. The weights $\mu(A_k)$ in the sum come directly from $\mu$; change the measure, change the integral.

### Nonnegative functions (take the limit)

Since $\psi_n \uparrow f$, define:

$$
\int f \, d\mu = \lim_{n \to \infty} \int \psi_n \, d\mu
$$

Equivalently, this is the supremum over all simple functions below $f$:

$$
\int f \, d\mu = \sup \left\{\, \int \psi \, d\mu \;:\; \psi \text{ simple},\; 0 \leq \psi \leq f \,\right\}
$$

### General functions (positive and negative parts)

Decompose $f = f^+ - f^-$ where $f^+ = \max(f,0)$ and $f^- = \max(-f,0)$, then:

$$
\int f \, d\mu = \int f^+ \, d\mu - \int f^- \, d\mu
$$

provided at least one side is finite.

---

## 4. Continuous vs Discrete Measures

The integral $\int f\,d\mu = \lim \sum a_k\,\mu(A_k)$ works for any measure. But measures themselves come in fundamentally different flavors.

### Atomic (discrete) measures

A set $A \in \mathcal{F}$ is an **atom** if $\mu(A) > 0$ and there is no subset $B \subset A$ with $0 < \mu(B) < \mu(A)$. An atom is an indivisible lump of mass — you cannot split it into two pieces that both have positive measure.

A measure is **purely atomic** (discrete) if all of its mass is concentrated on atoms.

### Atomless (continuous) measures

A measure is **atomless** if for every $A \in \mathcal{F}$ with $\mu(A) > 0$, there exists $B \subset A$ with $0 < \mu(B) < \mu(A)$. Every set of positive measure can be split into strictly smaller pieces. There are no indivisible lumps — the mass is spread out.

These are properties of the **measure itself**, defined on any abstract $(\Omega, \mathcal{F})$. No reference to $\mathbb{R}$ or distance is needed.

### Measure density

A stronger notion than atomless is **absolute continuity**. Given two measures $\mu$ and $\nu$ on $(\Omega, \mathcal{F})$, we say $\mu$ is **absolutely continuous** with respect to $\nu$ (written $\mu \ll \nu$) if:

$$
\nu(A) = 0 \;\Longrightarrow\; \mu(A) = 0
$$

The Radon–Nikodym theorem says that in this case, there exists a nonnegative measurable function $g$ — the **density** (or Radon–Nikodym derivative) — such that:

$$
\mu(A) = \int_A g \, d\nu \quad \text{for all } A \in \mathcal{F}
$$

We write $d\mu = g\,d\nu$. The density $g$ tells you how much heavier or lighter $\mu$ is compared to $\nu$, point by point.

The most common instance uses the **Lebesgue measure** on $\mathbb{R}$ as the reference measure $\nu$. Lebesgue measure is the unique measure on $(\mathbb{R}, \mathcal{B}(\mathbb{R}))$ that assigns to every interval its length:

$$
\nu([a, b]) = b - a
$$

It is the formalization of "ordinary length" — and it extends consistently to all Borel sets, not just intervals. When $\mu$ is absolutely continuous with respect to Lebesgue measure, we get:

$$
\mu(A) = \int_A g(x)\,dx
$$

and $g$ is the familiar density function from probability and analysis. The notation $dx$ here is shorthand for "integrate with respect to Lebesgue measure."

---

## 5. What the Integral Looks Like in Practice

With these definitions in hand, we can now unpack $\int f\,d\mu$ in each case.

### Continuous case (measure with a density)

Suppose $\Omega = \mathbb{R}$ and $\mu$ has density $g$ with respect to Lebesgue measure, so $d\mu = g\,dx$. The level sets $A_k \subseteq \mathbb{R}$, and $\mu(A_k) = \int_{A_k} g(x)\,dx$. The Lebesgue integral reduces to:

$$
\int f \, d\mu = \int f(x) \, g(x) \, dx
$$

### Discrete case (point masses)

Suppose $\mu$ assigns mass $p_j$ to each point $\omega_j$ (countably many atoms). Then $\mu(A_k) = \sum_{\omega_j \in A_k} p_j$, and the integral becomes a weighted sum:

$$
\int f \, d\mu = \sum_j f(\omega_j) \, p_j
$$

There is no density to extract — the mass lives on atoms, not on intervals.

### Mixed case

A general measure can be part continuous and part discrete. The notation $d\mu$ absorbs whatever the measure is — density, point masses, or any combination — without forcing a decomposition.

---

## 6. The Layer Cake Formula (A Theorem)

Once the integral is defined, we can prove:

$$
\int_\Omega f \, d\mu = \int_0^\infty \mu\!\left(\{\, \omega : f(\omega) > t \,\}\right) dt
$$

At each height $t$, measure the set where $f$ exceeds $t$, and integrate over all heights. This is the continuous limit of horizontal slicing.

Note: the right-hand side is an ordinary integral over $\mathbb{R}$ with respect to $dt$. The layer cake formula **depends on** already having an integral available on $\mathbb{R}$, so it is a consequence, not a foundation.

---

## Summary

|                        | Riemann                      | Lebesgue                           |
| ---------------------- | ---------------------------- | ---------------------------------- |
| **Slices**             | Domain (vertical rectangles) | Range (horizontal bands)           |
| **Requires**           | Notion of width ($dx$)       | Only a measure $\mu$ and limits    |
| **Abstract $\Omega$?** | No                           | Yes                                |
| **Foundation**         | Intervals and length         | $\int \mathbf{1}_A\,d\mu = \mu(A)$ |

# Expectation

## The setup

If our measure is a probability measure, then we compute the expectation.

First recall that a measurable function is between two measure spaces
$$
f : (\Omega_1, \mathcal{F}_1) \to (\Omega_2, \mathcal{F}_2)
$$
where for every $B \in \mathcal{F}_2$, we must have pre-image
$$
f^{-1}(B) = \{\omega : f(\omega) \in B \} \in \mathcal{F}_1
$$
I.e the whole sets map between $\mathcal{F_1}$ and $\mathcal{F_2}$.

A random variable is just the special case where
1. $(\Omega_1, \mathcal{F}_1)$ is equipped with a probability measure $p$.
2. $(\Omega_2, \mathcal{F}_2) = (\mathbb{R}, \mathcal{B})$, where $\mathcal{B}$ is the borel sigma algebra.

The measurable function still acts on elements of $\Omega_1$, but follows the above constraints

Now expectation of a random variable $X(\omega)$, is simply its lebesgue integral with the probability measure 
$$
E[X] = \int_\Omega X \, dP
$$

Let's approximate $X$ pointwise 
$$
X = \lim_{n \to \infty} \psi_n
$$

## The Expectation

The indicator axiom becomes: $E[\mathbf{1}_A] = P(A)$. The expected value of an indicator is the probability of the event. Linearity forces:

$$
E[\psi] = \sum_{k=1}^n a_k \, P(A_k)
$$

This is already the familiar idea: **sum values weighted by their probabilities**. The $dP$ in $\int X\,dP$ encodes that the weights are probabilities.

Taking the limit:

$$
E[X] = \lim_{n \to \infty} E[\psi_n] = \int_\Omega X \, dP
$$

**Continuous case.** If $P$ is absolutely continuous with respect to Lebesgue measure with density $f_X$ (the PDF), then $dP = f_X(x)\,dx$ and:

$$
E[X] = \int_{-\infty}^{\infty} x \, f_X(x) \, dx
$$

**Discrete case.** If $X$ takes countably many values with $P(X = x_j) = p_j$, then:

$$
E[X] = \sum_j x_j \, p_j
$$

Both are special cases of $\int X\,dP$. The measure $P$ absorbs whether probability is spread via a density or concentrated on atoms — which is why measure theory unifies the continuous and discrete definitions of expectation into a single formula.
# Multivariate Measure Spaces

Builds on the Lebesgue integration notes. We assume familiarity with $(\Omega, \mathcal{F}, \mu)$, the Lebesgue integral, and expectation as $E[X] = \int X , dP$.

---

## 1. The Product Space

Given two measurable spaces $(\Omega_X, \mathcal{F}_X)$ and $(\Omega_Y, \mathcal{F}_Y)$, the product space lives on $\Omega_X \times \Omega_Y$ — the set of all pairs.

The simplest subsets are **measurable rectangles** $A \times B$ with $A \in \mathcal{F}_X$, $B \in \mathcal{F}_Y$. These generate the **product σ-algebra**:

$$ \mathcal{F}_X \otimes \mathcal{F}_Y = \sigma!\left({A \times B : A \in \mathcal{F}_X,; B \in \mathcal{F}_Y}\right) $$

This is the container — it tells us which subsets of $\Omega_X \times \Omega_Y$ are measurable. It says nothing about probabilities or dependencies. That is the job of the measure.

---

## 2. The Measure Encodes Dependence

Any valid measure on $\mathcal{F}_X \otimes \mathcal{F}_Y$ is a legitimate choice. Different measures encode different relationships between the two spaces.

### Independent: the product measure

The **product measure** is the specific choice where the factors contribute independently:

$$ (\mu_X \otimes \mu_Y)(A \times B) = \mu_X(A) \cdot \mu_Y(B) $$

When both measures are σ-finite, Carathéodory guarantees this extends uniquely to $\mathcal{F}_X \otimes \mathcal{F}_Y$. In the probability setting, $P_{XY} = P_X \otimes P_Y$ is exactly the definition of **independence** — the joint factors into marginals.

### Dependent: any other measure

Any measure where $\mu_{XY}(A \times B) \neq \mu_X(A) \cdot \mu_Y(B)$ for some sets encodes **dependence**. The joint carries information beyond what the marginals provide.

### Dependence is not direction

The measure tells you **that** a relationship exists, not **why** or **in which direction**. The same joint is compatible with:

- $X$ influences $Y$
- $Y$ influences $X$
- Some hidden $Z$ influences both
- Any combination of the above

For example, consider $\Omega_X = {H, T}$ (coin) and $\Omega_Y = {1, \ldots, 12}$ (observed number). A joint where $P(X = H, Y = 7) = 0$ is compatible with "flip coin, then roll dice based on outcome" — but also with a completely different experiment that happens to produce the same table of probabilities.

Causal structure — what causes what, in what order — is strictly richer than the joint. The mapping is one-way: given the experimental structure, the joint is determined. But given the joint, the experimental structure is not recoverable.

### Constructing a joint

There are several ways to specify a measure on the product space:

**Directly.** Write down a measure on $\mathcal{F}_X \otimes \mathcal{F}_Y$ (e.g., a joint probability table). You're declaring the dependence structure by hand.

**Product measure.** Use $\mu_X \otimes \mu_Y$. This declares independence.

**Pushforward.** Model the full experiment on a shared space $(\Omega, \mathcal{F}, P)$, define $X: \Omega \to \Omega_X$ and $Y: \Omega \to \Omega_Y$, and derive the joint as the pushforward of $P$ through $\omega \mapsto (X(\omega), Y(\omega))$. The joint isn't chosen — it falls out of the model.

---

## 3. Integration and Decomposition

Given a product measure space $(\Omega_X \times \Omega_Y, , \mathcal{F}_X \otimes \mathcal{F}_Y, , \mu_{XY})$ and a measurable function $h: \Omega_X \times \Omega_Y \to \mathbb{R}$, the integral is:

$$ \int_{\Omega_X \times \Omega_Y} h , d\mu_{XY} $$

This is a standard Lebesgue integral. When $\mu_{XY}$ is a probability measure, this integral is the expectation $E[h]$.

### Decomposing the joint measure

The **disintegration theorem** says that (on standard Borel spaces, which includes $\mathbb{R}^n$ and essentially everything in practice) any joint measure can be sliced:

$$ d\mu_{XY}(x,y) = d\mu_{X|Y}(x ,|, y) , d\mu_Y(y) $$

Here $\mu_{X|Y}(\cdot ,|, y)$ is a **family of measures on $\Omega_X$, one for each $y \in \Omega_Y$**. For a fixed $y$, it answers: "how is mass distributed over $x$ at this $y$?" The defining property is that reassembling the slices recovers the joint:

$$ \mu_{XY}(A \times B) = \int_B \mu_{X|Y}(A ,|, y) , d\mu_Y(y) $$

The vertical bar is notation for these slices — the "$X$-part of the joint, with $Y$ held fixed." This lets us write the integral as:

$$ \int h , d\mu_{XY} = \int_{\Omega_Y} \left(\int_{\Omega_X} h(x,y) , d\mu_{X|Y}(x ,|, y)\right) d\mu_Y(y) $$

**Fubini's theorem** guarantees the order can be swapped (provided $h \geq 0$ or $\int |h| , d\mu_{XY} < \infty$).

### Independence simplifies the decomposition

When $\mu_{XY} = \mu_X \otimes \mu_Y$, the slice $\mu_{X|Y}(\cdot ,|, y)$ does not depend on $y$ — it equals $\mu_X$ everywhere. The decomposition becomes:

$$ d\mu_{XY}(x,y) = d\mu_X(x) , d\mu_Y(y) $$

In the probability setting, when $h(x,y) = g(x) \cdot k(y)$, the integrals separate:

$$ E[g(X) \cdot k(Y)] = E[g(X)] \cdot E[k(Y)] $$

---

## 4. The Notation $E_{p(x,y)}$ and Worked Decomposition

When you see $E_{p(x,y)}[h(X,Y)]$, the subscript names the measure by its density:

$$ E_{p(x,y)}[h(X,Y)] = \int!!\int h(x,y) , p(x,y) , dx , dy $$

Strictly, $p(x,y)$ is a density and the measure is $d\mu_{XY} = p(x,y),dx,dy$. Writing $E_{p(x,y)}$ identifies the measure with its density — a standard shorthand when the reference measure (Lebesgue) is understood.

### Decomposition into nested expectations

Apply the disintegration from Section 3. The joint density factors as:

$$ p(x,y) = p(x ,|, y) , p(y) $$

Substituting into the expectation:

$$ E_{p(x,y)}[h(X,Y)] = \int!!\int h(x,y) , p(x ,|, y) , p(y) , dx , dy $$

Group the inner integral over $x$ (with $y$ fixed):

$$ = \int \underbrace{\left(\int h(x,y) , p(x ,|, y) , dx\right)}_{E_{p(x|y)}[h(X,y)]} , p(y) , dy $$

The inner integral is itself an expectation — $h$ integrated against the conditional density $p(x|y)$, with $y$ held fixed. The outer integral then averages this over $y$:

$$ E_{p(x,y)}[h(X,Y)] = E_{p(y)}!\left[, E_{p(x|y)}[h(X,Y)] ,\right] $$

This is the **law of iterated expectations** (or tower property) in density notation: the joint expectation equals an outer expectation over $y$ of an inner expectation over $x$ given $y$.

### Independence collapses the nesting

When $X \perp Y$, $p(x|y) = p(x)$ and $p(x,y) = p(x),p(y)$. Taking $h(x,y) = g(x) \cdot k(y)$ and applying the tower property:

$$ E_{p(x,y)}[g(X) \cdot k(Y)] = E_{p(y)}!\left[, E_{p(x)}[g(X)] \cdot k(Y) ,\right] = E_{p(x)}[g(X)] \cdot E_{p(y)}[k(Y)] $$

The inner expectation is a constant (it doesn't depend on $y$), so it pulls out of the outer expectation. The nested expectation collapses into a product of independent expectations.


---

