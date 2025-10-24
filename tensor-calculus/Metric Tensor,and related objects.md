
We saw that if vector spaces are armed with inner products, we obtain a nice dual space defined using the inner product. [[Vector Space#Inner product]]

Here we will talk about the metric tensor and some powerful objects that we obtain as a results

---
# Metric Tensor

A metric tensor is a smooth map that that maps any point p on a manifold M to an inner product .
$$ p \to g_p$$
This another way of saying that if we have a manifold and decide to work in a tangent space around point $p$, then we have a tangent space $T_pM$. The metric tensor provides an inner product for this chosen tangent space. 
$$ g_p: T_P M \times T_P M \to \mathbb{R} $$

For each point, we therefore have a given inner product that we can use to talk about lengths and angles. 

We will now talk about the index'd forms of these, that arise once we define basis for a vector space.

## Index Form

Let $g_{ij}$ be the metric tensor in index notation, defined as

$$
g_{ij} = g(e_i, e_j)
$$

This is the *index form of the metric tensor* and is dependent on the choice of basis.

We can now define dot product between two vectors $v$ and $w$ as follows

$$
v = v^i e_i
$$
$$
w = w^je_j
$$
Substituting,
$$
g(v, w) = g(v^ie_i,\ w^j e_j)
$$
we get as g is bilinear
$$
v^i w^j g(e_i, e_j)
$$
which is 
$$
g_{ij} v^i w^j
$$



# Lowering Indices
Recall that we can define a dual space using $\flat: V \to V^*$ where $\flat(v)(w) = g(v,w)$

Substituting the index form of g
$$
\flat(v)(w) = g_{ij} v^i w^j
$$

Observe that we have recovered a valid covector $\flat(v)$ which we can write in index form
$$
\flat(v)_j= g_{ij} v^i
$$

We simple abbreviate away the $\flat(v)_j  \mapsto v_j$


# Raising Indices

Note that "flat" is a bijection, so it must have an inverse. Let's call it "sharp".

Note that a lowered index $\alpha_i$ is a covector and can be written as $\flat(v)_i$


Also note that the metric has an inverse 
$$
g^{ik} \cdot g_{kj} = \delta^i_j
$$ 

Multiplying both sides by the vector $v^j$,

$$
g^{ik} \cdot g_{kj} v^j = \delta^i_j v^j
$$ 

Simplifying left hand side using flat, and right hand side using summation convention
$$
g^{ik} \cdot \flat(v)_k = v^i
$$ 







