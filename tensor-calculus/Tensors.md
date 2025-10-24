
A tensor is multilinear map from a space of $n$ vectors and $m$ covectors to the field on which it is defined on $\mathbb{F}$.

$$
T: 
(V^* \times V^* \times \ldots \times V^*) \mapsto \mathbb{F}
\times 
(V \times V \times \ldots \times V) 
$$


We represent this tensor as 
$$
T_{j_1, j_2, \ldots j_n}^{i_1, i_2, \ldots i_m}
$$
in index notation. Strictly speaking this is a $(m, n)$ tensor indicating it maps $m$ covectors and $n$ vectors to a field.

We can also do partial application. For instance, if we let an $(m, n)$ tensor T operate on a vector, then the result is another tensor that is $(m, n - 1)$

A vector is a $(1, 0)$ tensor, a co-vector is a $(0, 1)$ tensor.

A matrix can be one of $(0, 2), (1, 1), (2, 0)$ tensor. 

# Transpose

Strictly speaking a transpose is way to map between the vector space and the covector space. There are multiple bijective maps that can do this. 

A metric tensor provides a canonical bijection for this mapping. Once we have defined a metric tensor, we can use to lower indices (vector -> covector) or raise indices (covector->vector)

The tensor consistent transpose is called the adjoint and for a map $A$ it is given by

$$
\langle Av, w \rangle_W = \langle v, A^\dagger w \rangle_W
$$




# Tensor Transformation

There are two ways to transform a tensor

1. Passive Transform: This changes the basis only, not the object
2. Active Transform: Changes the object only, not the basis

if we have a map $A: V \mapsto V$ , from vector space to vector space, then A is a $(1, 1)$ tensor.

In the active case, A doesn't change the basis but the vector itself, i.e A is applied to vector not basis. But in passive case, A is applied to basis and not the vector.

| **Tensor Type**  | **Index Form** | **Active**                                             | **Passive**                                          | **Notes**                                                                         |
| ---------------- | -------------- | ------------------------------------------------------ | ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| **Vector**       | $v^i$          | $v'^i = A^i{}_j v^j$                                   | $v'^i = (A^{-1})^i{}_j v^j$                          | Contravariant index transforms with $A$ (active) or $A^{-1}$ (passive).           |
| **Covector**     | $\omega_i$     | $\omega'_i = (A^{-\top})_i{}^j \omega_j$               | $\omega'_i = (A^{\top})_i{}^j \omega_j$              | Covariant index transforms with inverse transpose of the vector rule.             |
| **(0,2) Tensor** | $M_{ij}$       | $M'_{ij} = (A^{-\top})_i{}^p (A^{-\top})_j{}^q M_{pq}$ | $M'_{ij} = (A^{\top})_i{}^p (A^{\top})_j{}^q M_{pq}$ | Two covariant indices → both follow the covector rule.                            |
| **(1,1) Tensor** | $T^i{}_j$      | $T'^i{}_j = A^i{}_p (A^{-1})^q{}_j T^p{}_q$            | $T'^i{}_j = (A^{-1})^i{}_p, A^q{}_j, T^p{}_q$        | One upper (contravariant) and one lower (covariant) index → mixed transformation. |
| **(2,0) Tensor** | $S^{ij}$       | $S'^{ij} = A^i{}_p A^j{}_q S^{pq}$                     | $S'^{ij} = (A^{-1})^i{}_p, (A^{-1})^j{}_q, S^{pq}$   | Two contravariant indices → both follow the vector rule.                          |
