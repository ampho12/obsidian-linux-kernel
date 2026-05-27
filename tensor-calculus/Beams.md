
# Continuum Mechanics — First Principles

## Spaces

- **Body B**: abstract manifold of material points (no intrinsic metric)
- **ℝ³**: physical space with fixed Euclidean metric **g**
- **Material coordinates X**: labels on B that travel with material chunks
- **Spatial coordinates x**: coordinates on ℝ³

## Embedding

A map **φ: B → ℝ³** that places the body in physical space.

- **φ₀**: reference embedding (initial placement)
- **φ_t**: current embedding (at time t)
- Same body, different placements → same labels X, different spatial positions

## Jacobian (differential of an embedding)

The Jacobian **dφ** at each material point pushes material vectors to spatial vectors.

- **F₀ = dφ₀**: pushforward via reference embedding
- **F_t = dφ_t**: pushforward via current embedding

A material vector **U** at X becomes:

- F₀·**U** at φ₀(X) under the reference embedding
- F_t·**U** at φ_t(X) under the current embedding

## Configuration

- **Q**: configuration manifold — space of *all possible* embeddings
- A point **q ∈ Q** ≡ one entire embedding φ
- System state at time t: q(t) = φ_t
- A path q(t) through Q ≡ a deformation history

## Pullback

Operation that transports a geometric object (e.g. a metric) from target space *back* to source space via a map.

For the spatial metric **g** via embedding φ:

$$(\phi^* g)(\mathbf{U}, \mathbf{V}) = g(F\mathbf{U},, F\mathbf{V})$$

In components: $(\phi^* g)*{AB} = g*{ij}, F^i_A, F^j_B$

Each embedding gives its own pullback metric on B:

- **G = φ₀*g**: reference metric (via F₀)
- **C = φ_t*g**: current metric (via F_t)

Both pull back the *same* spatial metric g, but through different embeddings — that’s why G ≠ C.

## Deformation gradient

The standard “deformation gradient” is **F = F_t = dφ_t** — the differential of the current embedding.

- Maps material vectors → current-spatial vectors
- Components: $F^i_A = \partial x^i / \partial X^A$

**Special case** (φ₀ = identity, i.e., material coordinates coincide with reference spatial coordinates):

- F₀ = I, G = δ_AB (Cartesian reference)
- F = I + ∇u where u = φ_t(X) − X is the displacement

**General case**: F = ∂φ_t/∂X with no automatic “I + ∇u” form.

## Strain

$$\boxed{;E_{AB} = \tfrac{1}{2}(C_{AB} - G_{AB});}$$

### Where C − G comes from (length-change construction)

A material fiber dX has different physical lengths in the two states:

$$dS^2 = G_{AB},dX^A,dX^B \quad\text{(reference)}, \qquad ds^2 = C_{AB},dX^A,dX^B \quad\text{(current)}$$

The change in squared length is directly:

$$ds^2 - dS^2 = (C_{AB} - G_{AB}),dX^A,dX^B$$

So **C − G is the change in inner-product structure** on the body. Same dX (same labels), different metrics → different physical lengths.

### Why the factor of ½

Define E so that $ds^2 - dS^2 = 2,E_{AB},dX^A,dX^B$. The ½ makes E behave as the *relative stretch* at first order.

For a fiber dX = dS · **n** with **n** unit in G (i.e., G(**n**, **n**) = 1):

$$ds^2 = dS^2\big(1 + 2,E(\mathbf{n}, \mathbf{n})\big) ;\Longrightarrow; \frac{ds - dS}{dS} \approx E(\mathbf{n}, \mathbf{n})$$

So E(**n**, **n**) gives the **engineering strain** (relative stretch) in direction **n** for small strains.

### What E(n, n) means

E is a (0,2) tensor — a bilinear form on material vectors. Evaluating it on a unit direction **n** in both slots:

$$E(\mathbf{n}, \mathbf{n}) = E_{AB},n^A n^B$$

is the **scalar strain in direction n**. Pick any direction; this contraction gives the strain there.

### What strain captures

- **Diagonal E_AA**: changes in length along direction A (**stretches**)
- **Off-diagonal E_AB**, A ≠ B: changes in angle between fibers in directions A and B (**shears**)

A single tensor captures both — because the metric encodes both lengths and angles through inner products. Change the metric → both lengths and angles change → strain encodes all of it.

## The flow

```
Body B
  │
  │  embed via φ
  ▼
ℝ³ with spatial metric g
  │
  │  pull g back through F (= dφ)
  ▼
Pullback metric on B

Two embeddings (φ₀, φ_t)  →  two pullback metrics (G, C)
                          →  Strain E = ½(C − G)
```