
A tensor is multilinear map from a space of $n$ vectors and $m$ covectors to the field on which it is defined on $\mathbb{F}$.

$$
T: 
(V^* \times V^* \times \ldots \times V^*) 
\times 
(V \times V \times \ldots \times V) 
\mapsto \mathbb{F}
$$


If we choose a basis, we can express tensor in index notation
$$
T_{j_1, j_2, \ldots j_n}^{i_1, i_2, \ldots i_m}
$$

This is a $(m, n)$ tensor indicating it maps $m$ covectors and $n$ vectors to a field.

We can also do partial application. For instance, if we let an $(m, n)$ tensor T operate on a vector, then the result is another tensor that is $(m, n - 1)$

A vector is a $(1, 0)$ tensor, a co-vector is a $(0, 1)$ tensor.

A matrix can be one of $(0, 2), (1, 1), (2, 0)$ tensor. 

# Tensor Transformation

There are two types of tensor transformations

1. Passive Transform: This changes the basis only, not the object. This is ALWAYS a jacobian. Passive transforms cannot expressed in a frame -- they inhernelty live between two frames.
$$
J^{i'}_i = \frac{de^{i'}}{de^i}
$$

2. Active Transform: Changes the object only, not the basis. These quantities are geometric, but can be expressed in basis. An active transforms needs m + n basis if the output space is m coordinates and input is n coordinates. We can change the input basis by using a passive transform, the output bases using another passive transform, or both.

if we have a map $A: V \mapsto V$ , from vector space to vector space, then A is a $(1, 1)$ tensor.

In the active case, A doesn't change the basis but the vector itself, i.e A is applied to vector not basis. But in passive case, A is applied to basis and not the vector.

| **Tensor Type**  | **Index Form** | **Active**                                             | **Passive**                                          | **Notes**                                                                         |
| ---------------- | -------------- | ------------------------------------------------------ | ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| **Vector**       | $v^i$          | $v'^i = A^i{}_j v^j$                                   | $v'^i = (A^{-1})^i{}_j v^j$                          | Contravariant index transforms with $A$ (active) or $A^{-1}$ (passive).           |
| **Covector**     | $\omega_i$     | $\omega'_i = (A^{-\top})_i{}^j \omega_j$               | $\omega'_i = (A^{\top})_i{}^j \omega_j$              | Covariant index transforms with inverse transpose of the vector rule.             |
| **(0,2) Tensor** | $M_{ij}$       | $M'_{ij} = (A^{-\top})_i{}^p (A^{-\top})_j{}^q M_{pq}$ | $M'_{ij} = (A^{\top})_i{}^p (A^{\top})_j{}^q M_{pq}$ | Two covariant indices → both follow the covector rule.                            |
| **(1,1) Tensor** | $T^i{}_j$      | $T'^i{}_j = A^i{}_p (A^{-1})^q{}_j T^p{}_q$            | $T'^i{}_j = (A^{-1})^i{}_p, A^q{}_j, T^p{}_q$        | One upper (contravariant) and one lower (covariant) index → mixed transformation. |
| **(2,0) Tensor** | $S^{ij}$       | $S'^{ij} = A^i{}_p A^j{}_q S^{pq}$                     | $S'^{ij} = (A^{-1})^i{}_p, (A^{-1})^j{}_q, S^{pq}$   | Two contravariant indices → both follow the vector rule.                          |


More generally consider any $(m, n)$ tensor $T$. This will eat a 