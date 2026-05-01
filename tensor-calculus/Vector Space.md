A **vector space** over a field $\Bbb F$ (typically $\Bbb R$ or $\Bbb C$) is a set $V$ together with two operations:

1. **Vector addition**

   $$
     + : V \times V \;\longrightarrow\; V,\quad (u,v)\mapsto u+v.
   $$
2. **Scalar multiplication**

   $$
     \cdot : \Bbb F \times V \;\longrightarrow\; V,\quad (a,v)\mapsto a\,v.
   $$

These operations must satisfy the following eight axioms for all $u,v,w\in V$ and all scalars $a,b\in\Bbb F$:

1. **Associativity of addition**:
   $(u + v) + w = u + (v + w)$.
2. **Commutativity of addition**:
   $u + v = v + u$.
3. **Additive identity**:
   There exists an element $0\in V$ such that $v + 0 = v$.
4. **Additive inverse**:
   For each $v\in V$ there exists $-v\in V$ such that $v + (-v) = 0$.
5. **Compatibility of scalar multiplication with field multiplication**:
   $(ab)\,v = a\,(b\,v)$.
6. **Identity element of scalar multiplication**:
   $1\,v = v$, where $1$ is the multiplicative identity in $\Bbb F$.
7. **Distributivity of scalar sums**:
   $(a + b)\,v = a\,v + b\,v$.
8. **Distributivity of vector sums**:
   $a\,(u + v) = a\,u + a\,v$.

---

* From these axioms one proves that scalar multiplication by $0$ gives $0_V$, that $(-1)\,v = -v$, and so on.
* Every vector space has a uniquely defined **dimension** (possibly infinite), the size of any basis.



# Vector Spaces and Covector Spaces

Vector Space is an overloaded term. In the most strict sense, refers to a set V with multiplication and addition operations that satisfy the eight axioms. 

However, we can also also use a vector space to mean 
1. A vector space whose elements are vectors

Similarly, a covector space is a dual of a vector space
1. A vector space whose elements are covectors


Every vector space $V$, has a unique covector space $V^*$(and vice versa) defined as

$$
V^* = \{ \psi : V \to \mathbb{R} | \psi \ \text{is linear} \}
$$
i.e a set of functions that take a vector of the vector space as an input and yields a real number.

## Working with Vector Spaces

### Injection

To prove that a **linear** function over a vector space is injective, we need to show that the only element mapped to a zero element by the function is the 0 vector alone.

This follows from the definition, that a function is an injection if
$$
f(a) = f(b) \implies a = b
$$
we can write $b = a + \epsilon$ . Since $f$ is linear,

$$
f(a) = f(b) \implies f(a) = f(a) + f(\epsilon)
$$
that is 
$$
f(\epsilon) = 0 \implies \epsilon = 0
$$
### Surjection
In finite dimensions, an injective linear map between two n-dimensional spaces is automatically surjective.

## Bijection

It is easy to see that if a linear function over a vector space is an injection, and the dimensionality of the domain and the range is finite and equal, then it must be a surjection. As it is both surjective and injective then it is also a bijection.

This means, we just need to show injection, and we get surjectivity and bijectivity for free.



## Special Types of Vector Spaces

### Bidual
Strictly speaking, since covector spaces are also vector spaces (who's elements are covectors), we can have a dual of a covector space

$$
V^{**} = \{ \Lambda: V^* \to R \ | \Lambda \ \text{is linear} \}
$$


We will also show that there is a map defined by
$$
\iota: V \to V^{**}
$$
where, $\iota(v)(\psi) = \psi(v)$

if this map is injective, and if V is finite dimensional (i.e dim(V) < $\infty$), then we have a bijection


### Tangent and Cotangent Space


A **tangent space** is a vector space of vectors tangent to a point P on a manifold M. It is denoted by $T_P M$.

A **cotangent space** is the dual space of the tangent space. This means its elements are covectors.


## Musical Isomorphism

This concept is fundamental in mapping vector to covectors and vice-versa.

Firstly, let's start with a bilinear form $g: V \times V \to \mathbb{R}$.

We define the $v-flat$ map as
$$
\begin{align}
\flat_g &: V \to V^* \\
\flat_g(v)(w) &= g(v, w)
\end{align}
$$

However, $\flat$ may not be invertible. If the metric $g(v, w) = 0$ for all $w \in V$, then $\flat_g(v) = 0$ but $v \neq 0$ is a viable map from $V \to V^*$.

Also there may be a map from $V^* \to V$ but that is actually a flat transform from $V^* \to V^{**}$. and the bidual, is an isomorphism from $V$.

Now assume that the metric is non-degenerate, then we can say that $\flat_g$ is injective. In finite vector space, this also means its bijective. Therefore $\flat_g$ is invertible. This gives a canonical induced bilinear form for the covector space, namely 

$$
g^{-1}: V^* \times V^* \to \mathbb{R}
$$
$$
g^{-1}(\alpha, \beta) = g(\sharp_g \alpha, \sharp_g \beta)
$$

Normally, it is difficult to find closed form solution for $\sharp_g$ . The problem is we need to find vector $v$ given covector $\alpha$ such that
$$
\alpha(w) = g(v, w)
$$

This is hard. Fortunately, in finite dimensions any bilinear map can be reduced to a matrix by choosing basis $\{ e_i \}$.

We get $g_{i, j} = g(e_i, e_j)$. Then we need to solve

$$
g_{i, j} v^j = \alpha_i
$$
If $g$ is invertible, we get
$$
v^j = (g^{-1})^{i, j} \alpha_i
$$


At this stage, we still cannot say that the disjoint union of $S$ and $S^\perp$ is $V$. If the metric is not positive definite, then we can have still have metric like the Minkowski metric that messes things up. Here is an example

**Minkowski space $\mathbb{R}^{1,1}$:**

Metric: $g = \text{diag}(-1, 1)$

So $g(v, w) = -v^0 w^0 + v^1 w^1$.

**A null vector:**

Let $v = (1, 1)$.

$$g(v, v) = -1 + 1 = 0$$

So $v$ is null: nonzero but has "zero length."

**Consider $S = \text{span}{v}$:**

$$S^\perp = {w : g(v, w) = 0} = {w : -w^0 + w^1 = 0} = {w : w^0 = w^1}$$

But this is exactly $S$ again!

$$S^\perp = S$$

**The failure:**

$$S \cap S^\perp = S \neq {0}$$

$$S + S^\perp = S \neq V$$

**With positive definite:**

If $g(v, v) > 0$ for all $v \neq 0$, then:

Suppose $v \in S \cap S^\perp$. Then $v \in S$ and $g(v, w) = 0$ for all $w \in S$.

In particular, $g(v, v) = 0$.

Positive definiteness forces $v = 0$.

Therefore $S \cap S^\perp = {0}$, and dimension counting gives $V = S \oplus S^\perp$.

### Inner product and Riesz Map

If we define an inner product over a vector space, then we can derive a pretty cool covector space as follows:

for any vector $v \in V$, we define a covector $\flat(v)$ ( called v-flat). The following relationship holds
$$
\flat(v)(w) = \langle v, w \rangle
$$
since the relation is linear in $w$, we have a $\flat(v) = \flat_v$ a covector. 

Furthermore, the mapping
$$
\flat_V: V \to V^*
$$
is linear in $v$.

To prove it is an injection we need to show $\flat(\epsilon) = 0 \implies \epsilon = 0$. Clearly, $\flat(\epsilon) = 0$ implies $g(\epsilon, w) = 0$ for all $w \in V$. Since g is not degenerate, then $\epsilon = 0$.

Therefore $\flat_v : V \to V^*$ is a bijection. 

We define the inverse as v-sharp or $\sharp_V: V^* \to V$.

Strictly speaking, we don't need an inner product, just non-degenerace
**Metric (in the general sense)**

A symmetric bilinear form $g: V \times V \to \mathbb{R}$. This could be:
- Degenerate (has null vectors: $g(v, w) = 0$ for all $w$)
- Indefinite (like Minkowski metric in relativity: $g(v,v)$ can be positive, negative, or zero)

**What's needed for $\flat$ and $\sharp$?**

We can define $\flat$ and $\sharp$ with any metric, but for bijection we need non-degenerecy

Just non-degeneracy. If $g(v, w) = 0$ for all $w$ implies $v = 0$, then:
$$\flat: v \mapsto g(v, \cdot)$$
is injective, hence bijective in finite dimensions. So $\sharp = \flat^{-1}$ exists.

Minkowski metric works fine here—you get valid musical isomorphisms even though it's not positive definite.

**What's needed for Riesz?**

The full Riesz representation theorem requires an inner product: positive definite and (in infinite dimensions) completeness.

**Summary:**

| Structure                         | $\flat/\sharp$ exist? | Riesz applies? |
| --------------------------------- | --------------------- | -------------- |
| Degenerate bilinear form          | No                    | No             |
| Non-degenerate, indefinite        | Yes                   | No             |
| Inner product (positive definite) | Yes                   | Yes            |
## Use of covector

One way to think about covectors is using level sets. A covector $w$ can be used to find hyperplanes in V.

w(v) = c, is set of all vectors lying on the hyperplane that give c as acted by w. (i.e w-coordinate is c)

Then any other vector v will tell you how much of v is along the direction specified by the hyperplane not in absolute terms, but relative to other vectors. e.g if 

$$c_1 < w(v) < c_2$$

then v is more along w using level set c_1 but less along w than level set c_2





# Dual Map, Adjoint, Transpose


## Dual Map

This is the most fundamental structure. We don't need a metric

For any two vector spaces, $V, W$ given a linear map $J: V \to W$, we define a dual map $J^* : W^* \to V^*$. Let $\lambda \in W^*$, and $v \in V$.
$$
(J^*\lambda)(v) = \lambda (Jv)
$$
This always exists

# Transpose

The transpose is the coordinate expression of the dual map. It requires bases, i.e

Once we choose bases $\{e_i\}$ for $V$ and $\{f_a\}$ for $W$, $J$ becomes a matrix $J^a{}_i$. The transpose is just $(J^T)^i{}_a = J^a{}_i$ with indices swapped.

The transpose *represents* the dual map in the corresponding dual bases. So transpose is the coordinate expression of the dual map.

## Adjoint

An adjoint requires a metrics. Given $J: V \to W$ with metrics $g_V$ and $g_W$, define $J^\dagger: W \to V$ by:
$$\langle Jv, w \rangle_W = \langle v, J^\dagger w \rangle_V$$

### Relationship between all

```
              J
       V ────────────> W
       │               │
       │               │
v-flat │↓             ↓│ w-flat
       │               │
v-sharp│↑             ↑│ w-sharp
       │               │
       │      J*       │
       V* <──────────── W*
```



The adjoint factors through the dual map using the musical isomorphisms:

$$J^\dagger = \sharp_V \circ J^* \circ \flat_W$$
That is: $w \in W \xrightarrow{\flat_W} W^* \xrightarrow{J^*} V^* \xrightarrow{\sharp_V} V$

Similarly, we use $(J^*)^\dagger: V^* \to W^*$

| Construct           | Type             | Requires basis? | Requires metric?    |
| ------------------- | ---------------- | --------------- | ------------------- |
| Dual map $J^*$      | $W^* \to V^*$    | No              | No                  |
| Transpose $J^T$     | matrix operation | Yes             | No                  |
| Adjoint $J^\dagger$ | $W \to V$        | No              | Yes, on both spaces |


# Subspaces
## Annhilator Subspace

For a vector space $S \subset V$, the anhilator space of $S$ is the covector space $S^0$, defined by
$$
\{
\alpha \in V^* : \alpha(s) = 0, \forall s \in S
\}
$$

in general, the range of the dual of a linear map $J$, is the anhilator of its kernel (nullspace).

$$
\text{range}(J^*) = (\text{ker}(J))^0
$$

If we have a non-degenerate metric, then we can also say for any orthogonal complement subspace $S^\perp$, we get 

$$
\begin{align}
\flat(S^\perp) = S^0 \\
\sharp(S^0) = S^\perp \\
\end{align}
$$

We can prove this

Using the definition of orthogonal complement subspace with metric g, we get
$$
g(w, v) = 0
$$
for all $w \in S^\perp$. For any metric, we can show we have a covector $\flat_g(w)$ and  $\flat_g(w)(v) = g(w, v)$, This gives us $\flat_g (S^\perp) \subseteq S^0$

Now, for a non degenerate metric, we can find $\sharp_g = \flat_g ^{-1}$

which is defined as
$$
\sharp_g(\alpha) = w \iff g(w, v) = 0 \ \forall v
$$
By definition, for all $\alpha \in S^0$, $\alpha(v) = 0$ for all $v \in S$. This means $w \in S^\perp$. Thus $\sharp_g(S^0) \subseteq S^\perp$. 

But we know that $\sharp_g = \flat_g^{-1}$. So we get $S^0 \subseteq \flat_g(S^\perp)$.

Therefore, $\flat(S^\perp) = S^0$.


## Orthogonal Complement Subspace

Strictly speaking, we just need a bilinear form $g: V \times V \to \mathbb{R}$. Then:
$$S^\perp = \{w \in V : g(w, v) = 0 \ \forall v \in S\}$$

This is always a well-defined subspace.

**To get nice properties:**

| Property                            | Requires          |
| ----------------------------------- | ----------------- |
| $S^\perp$ is defined                | Any bilinear form |
| $\dim(S) + \dim(S^\perp) = \dim(V)$ | Non-degenerate    |
| $(S^\perp)^\perp = S$               | Non-degenerate    |
| $S \cap S^\perp = \{0\}$            | Positive definite |
| $V = S \oplus S^\perp$              | Positive definite |
| Projection Minimizes Norm           | Positive definite |

**The pathology with indefinite metrics:**

In Minkowski space, a null vector $v$ satisfies $g(v, v) = 0$, so $v \perp v$. If $S = \text{span}\{v\}$, then $v \in S^\perp$.

So $S \cap S^\perp \neq \{0\}$—the subspace intersects its own "orthogonal complement."

You can define orthogonal complements with just a metric (non-degenerate bilinear form). But for the clean decomposition $V = S \oplus S^\perp$ that we intuitively expect, you need an inner product.


## Projection on a Subspace

If a metric g is positive definite, we have an inner product equipped vector space $V$. Let $S \subset V$. Let $P_S$ be a g orthgobnal projector onto subspace $S$. For any $v \in V$

$$
P_S v = arg \min_{u \in S} || v - u ||_g
$$

We can prove it 

A g-orthogonal projector means projection onto a subspaces $S$ and $S^\perp$ are orthogonal, this means

$$
g(P_s v, P_s^\perp v) = 0
$$

Let $v_{||}= P_s v$ and $v_\perp = P_s^\perp v$.

Since metric is positive definite $g(v, u) > 0$





# Bases


A vector space doesn't need basis, it can exist without it. 




















