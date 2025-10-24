



# Metric, Norm, and Inner Product


1. A metric is a distance function i.e distance between x and y.
2. Norms are length functions. Distance between x and y can be seen as length of (x - y)
3. Inner products are bilinear maps that can induce norms and also measure angles
4. A metric tensor maps points on a manifold to local inner products.


Any norm can induce a metric but not vice versa

Any inner product can induce a norm but not vice versa

If an inner produce induces a norm, the norm must satisfy the parellelogram law and we can also recover the innder product from the norm.


![[Drawing 2025-07-29 04.07.45.excalidraw]]


> Metric Tensor is different from a Metric as we will see later

This document summarizes the key definitions and relationships between metrics, norms, and inner products.

---

## 1. Metric

A **metric** is a function that measures the distance between any two elements in a **set**, without requiring any algebraic structure.

The set may or not be a vector space


- **Definition:**  
  Let \(X\) be a set. A metric is  
$$
    d: X \times X \;\to\; [0,\infty)
$$
  such that, for all $x,y,z\in X$:
  1. **Non-negativity:**  
     $d(x,y)\ge0$  
  2. **Identity of indiscernibles:**  
     $d(x,y)=0\iff x=y$  
  3. **Symmetry:**  
     $d(x,y)=d(y,x)$  
  4. **Triangle inequality:**  
     $d(x,z)\le d(x,y)+d(y,z)$

- **Key point:**  
  Metrics exist on any set. No vector-space structure is needed.

---

## 2. Norm

A **norm** is a way to measure the length of vectors in a vector space. Every norm induces a metric.

Note that Norms are defined on vector spaces, not arbitrary sets.



- **Definition:**  
  Let $V$ be a real or complex vector space. A norm is  
$$
    \|\cdot\|: V \;\to\; [0,\infty)
$$
  satisfying, for all \(u,v\in V\) and scalars \(\alpha\):
  1. **Positive-definiteness:**  
     $\|v\|\ge0$, and $\|v\|=0\iff v=0$
  2. **Absolute homogeneity:**  
     $\|\alpha\,v\| = |\alpha|\,\|v\|$  
  3. **Triangle inequality:**  
     $\|u + v\|\le \|u\| + \|v\|$

- **Induced metric:**  
  $$
    d(x,y) \;=\; \|x - y\|
    $$
A metric over a vector space is not always a norm. If a metric over a vector space is 
1. Absolute homogeneity $d(\lambda x, \lambda y) = \lambda d(x, y)$ (for norms absolute homogeneity)
2. Translation in variance for triangle inequality
i.e to show:
$$
d(x + y, 0) \le d(x, 0) + d(y, 0)
$$

we start with
$$
d(x + y, 0) \leq d(x + y, y) + d(y, 0)
$$
and to show
$$
d(x + y, y) = d(x, 0)
$$

we need translational invariance

But vector space axioms don't mention it, so is this a property of coordinate systems?

---

## 3. Inner Product (Scalar Product)

An **inner product** is a bilinear form on a vector space that measures both lengths and angles.

- **Definition:**  
  A map  
  $$
    \langle\cdot,\cdot\rangle : V\times V \;\to\;\Bbb R
  $$
  satisfying, for all $u,v,w\in V$ and scalar $\alpha$:
  1. **Symmetry:**  
     $\langle u,v\rangle = \langle v,u\rangle$  
  2. **Linearity in the first slot:**  
     $\langle \alpha u + v,\,w\rangle = \alpha\,\langle u,w\rangle + \langle v,w\rangle$
  3. **Positive-definiteness:**  
     $\langle v,v\rangle\ge0$, with equality iff $v=0$

- **Induced norm:**  
  $$
    \|v\| = \sqrt{\langle v,v\rangle}
  $$
- **Angle between vectors:**  
  $$\cos\theta = \frac{\langle u,v\rangle}{\|u\|\;\|v\|}$$

### Dot Product

A dot product is a specific type of inner product. It is not a covector acting on a vector.

$$a \cdot b = \langle a, b \rangle$
$$
i.e a dot product is a function $g: V \times V \to \mathbb{R}$

---

## 4. Parallelogram Law & Equivalence

- A norm $\|\cdot\|$ **comes from** an inner product **if and only if** it satisfies the **parallelogram law**:
  $$
    \|u+v\|^2 + \|u-v\|^2 = 2\|u\|^2 + 2\|v\|^2,
    \quad\forall\,u,v\in V.
  $$
- When this holds, the inner product is **unique** and recovered via the **polarization identity**:
  $$
    \langle u,v\rangle
    = \tfrac12\bigl(\|u+v\|^2 - \|u\|^2 - \|v\|^2\bigr).
  $$

---
## 5. Summary of Relationships

| Structure         | Requirements                   | Yields                    | Angle? |
| :---------------- | :----------------------------- | :------------------------ | :----- |
| **Metric**        | Any set + distance function    | Distances \(d(x,y)\)      | No     |
| **Norm**          | Vector space + length function | Metric \(d(x,y)=\|x-y\|\) | No     |
| **Inner Product** | Vector space + bilinear form   | Norm & metric, angles     | Yes    |

- **Metrics** are most general (any set).  
- **Norms** require linear structure and measure lengths.  
- **Inner products** are norms + angle-measuring structure.


---


We have seen that if an inner product 

---

# Kronecker delta $\delta^i{}_j$

* **Definition**:

  $$
  \delta^i{}_j =
  \begin{cases}
  1 & i=j,\\
  0 & i\neq j.
  \end{cases}
  $$

* **Role**: It’s the identity map in index notation. Whenever you contract with it, it just renames the index:

  $$
  A^i \delta^j{}_i = A^j.
  $$

* **Properties**:

  * Symmetric: $\delta^i{}_j=\delta_j{}^i$.
  * In a matrix view: $\delta^i{}_j$ is the identity matrix $I$.

---

# 2. **Levi-Civita symbol** $\varepsilon_{ijk}$ (or in higher dimensions)

* **Definition** (in 3D): totally antisymmetric with values

  $$
  \varepsilon_{ijk} =
  \begin{cases}
  +1 & (i,j,k) \text{ is an even permutation of } (1,2,3),\\
  -1 & (i,j,k) \text{ is an odd permutation},\\
  0 & \text{if any indices repeat}.
  \end{cases}
  $$

* **Role**: Encodes orientation and cross products. For example:

  $$
  (A\times B)^i = \varepsilon^i{}_{jk} A^j B^k.
  $$

* **Key identities**:

  * Contraction with itself:

    $$
    \varepsilon_{ijk}\,\varepsilon^{imn}
    = \delta_j^m \delta_k^n - \delta_j^n \delta_k^m.
    $$
  * General double-epsilon identity gives determinants:

    $$
    \varepsilon_{ijk}\,\varepsilon_{lmn} = \det
    \begin{bmatrix}
    \delta_{il} & \delta_{im} & \delta_{in} \\
    \delta_{jl} & \delta_{jm} & \delta_{jn} \\
    \delta_{kl} & \delta_{km} & \delta_{kn}
    \end{bmatrix}.
    $$

---

# 3. **Metric tensor** $g_{ij}$

* **Definition**: A symmetric, non-degenerate bilinear form. It defines the inner product of tangent vectors:

  $$
  \langle u,v\rangle = g_{ij} u^i v^j.
  $$

* **Role**:

  * Converts (“raises” or “lowers”) indices:

    $$
    u_i = g_{ij} u^j, \qquad
    v^i = g^{ij} v_j,
    $$

    where $g^{ij}$ is the inverse metric ($g^{ik}g_{kj}=\delta^i{}_j$).
  * Determines lengths and angles: $|u|^2 = g_{ij}u^i u^j$.
  * Supplies the “volume form”: in curved coordinates, the Levi-Civita **tensor** is $\epsilon_{ijk}=\sqrt{|g|}\,\varepsilon_{ijk}$, where $|g|=\det(g_{ij})$.

---

# 4. **How they interplay**

* The **Kronecker delta** is the identity used to raise/lower consistently: $g^{ik} g_{kj} = \delta^i{}_j$.
* The **Levi-Civita symbol** is purely combinatorial, but when you want a *tensorial* object (that transforms correctly), you must “weight” it with $\sqrt{|g|}$ from the metric:

  $$
  \epsilon_{i_1\ldots i_n} = \sqrt{|g|}\,\varepsilon_{i_1\ldots i_n}.
  $$
* In curved coordinates (or non-orthonormal bases), cross products, curls, and determinants rely on this weighted Levi-Civita **tensor**, not the raw symbol.

---

# 5. Concrete 3D example (Euclidean metric)

* In Cartesian coordinates, $g_{ij}=\delta_{ij}$. So raising/lowering does nothing, $\epsilon_{ijk}=\varepsilon_{ijk}$.
* Identity:

  $$
  \varepsilon_{ijk}\,\varepsilon_{lmk}
  = \delta_{il}\delta_{jm}-\delta_{im}\delta_{jl}.
  $$

  This underlies vector calculus identities like

  $$
  \nabla\times(\nabla\times A) = \nabla(\nabla\cdot A) - \nabla^2 A.
  $$

---

✅ **Summary**:

* **Kronecker delta** = identity tensor.
* **Levi-Civita symbol** = antisymmetric sign gadget for orientation.
* **Metric tensor** = the object that lets you measure and raise/lower indices; it “upgrades” the symbol into a proper tensor.

---

Would you like me to show how all three combine explicitly to derive the cross product identity
$(\mathbf a \times \mathbf b)\cdot(\mathbf c \times \mathbf d) = (\mathbf a\cdot\mathbf c)(\mathbf b\cdot\mathbf d) - (\mathbf a\cdot\mathbf d)(\mathbf b\cdot\mathbf c)$ in index notation?


We can recover the metric tensor too:

1. A basis $\{e_i\}$ of each tangent space $T_pM$, and
2. The component functions $g_{ij}(p)$ relative to that basis,

together determine the **entire** metric tensor $g$.  Concretely:

* **Pointwise**, at each $p$, you reconstruct the bilinear form $g_p$ by declaring for any two tangent vectors $v = v^i e_i$ and $w = w^j e_j$:

  $$
    g_p(v,w)
    \;=\;
    \sum_{i,j} g_{ij}(p)\;v^i\,w^j.
  $$

  That is exactly the definition of $g_p$ in the $\{e_i\}$ frame.

* **Globally**, if your basis is a coordinate basis $e_i = \partial/\partial x^i$ and you know smooth functions $g_{ij}(x)$, then you assemble the tensor

  $$
    g \;=\;\sum_{i,j} g_{ij}(x)\;dx^i\otimes dx^j.
  $$

  This is the usual expression of the metric tensor across the manifold.

No other information is needed—components $+$ basis $=$ the full tensor.

dx^i are 1 forms. (TBD)


