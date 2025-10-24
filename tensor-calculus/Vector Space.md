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

### Inner product and Riesz Map

If we define an inner product over a vector space, then we can derive a pretty cool covector space as follows:

for any vector $v \in V$, we define a covector $\flat(v)$ ( called v-flat). The following relationship holds
$$
\flat(v)(w) = \langle v, w \rangle
$$
since the rule is linear in $w$, we have a covector space.

Furthermore, the mapping
$$
\flat: V \to V^*
$$
is linear in $v$.

To prove it is an injection we need to show $\flat(\epsilon) = 0 \implies \epsilon = 0$. Clearly, $\flat(\epsilon) = 0$ implies $g(\epsilon, w) = 0$ for all $w \in V$. Since g is not degenerate, then $\epsilon = 0$.

Therefore the "v-flat" is a bijection. 


## Use of covector

One way to think about covectors is using level sets. A covector $w$ can be used to find hyperplanes in V.

w(v) = c, is set of all vectors lying on the hyperplane that give c as acted by w. (i.e w-coordinate is c)

Then any other vector v will tell you how much of v is along the direction specified by the hyperplane not in absolute terms, but relative to other vectors. e.g if 

$$c_1 < w(v) < c_2$$

then v is more along w using level set c_1 but less along w than level set c_2




# Transpose


A transpose of a linear map $f: V \to W$ is

$$ f^T: W^* \to V^*$$
where

$$
(f^T(\phi))(v) = \phi(f(v))
$$

$\phi \in W^*, v \in V$. This is also called the adjoint or pullback.


Consider a matrix transform $A: V \to W$. Since this is a linear map, it's transpose is the function
$$A^T : W^* \to V^*$$


If r is a row-vector / linear funcitional in $W^*$, then $A^\top(r)$ is the row vector / linear functional in $V^*$.





# Bases


A vector space doesn't need basis, it can exist without it. 



















