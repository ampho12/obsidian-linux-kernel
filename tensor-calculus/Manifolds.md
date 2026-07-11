# Connections and Covariant Derivatives

## 0. The problem

A vector field Y assigns a vector to each point: Y(p) ∈ T_pM. To differentiate it along a curve, we need something like Y(γ(t+h)) − Y(γ(t)) — but these live in **different tangent spaces**. Subtraction is undefined. The manifold provides no canonical identification of tangent spaces; one must be **chosen**. That choice is the connection.

## 1. Foundations (chart-free)

- **Manifold** M: points + smooth structure. Smoothness enforced via atlas; it defines the algebra C∞(M) of smooth functions. Charts unused beyond this.
- **Vector at p**: a derivation at p — a linear map C∞(M) → ℝ satisfying Leibniz: X_p(fg) = X_p(f)·g(p) + f(p)·X_p(g). Every curve through p gives one via f ↦ d/dt f(γ(t))|₀; every derivation arises this way; curves sharing instantaneous velocity give the same vector.
- **Vector field**: a smooth assignment p ↦ X_p; equivalently one linear + Leibniz map C∞(M) → C∞(M), via (Xf)(p) = X_p(f).
- **Notation**: Xf = apply field to function (differentiation, free). fX = scale field by function (no differentiation).
- **Frame** E₁,...,Eₙ: smooth vector fields forming a basis of every tangent space on a patch. Components: V = VᵏEₖ.

Differentiating **functions** along fields is free (Xf). Differentiating **fields** along fields is not constructible from the smooth structure — it must be supplied.

## 2. Transport and connection (one structure)

**Transport is the baseline: it establishes what zero change looks like.** A vector is *unchanged* along a curve if it is exactly the transport of its earlier values. This is a definition supplied by choice, not discovered — the manifold has no prior notion of a vector at one point "equaling" a vector at another. Everything downstream (the covariant derivative, parallelism, geodesics) measures against this baseline.

**Transport**: for every curve γ, a family of linear maps

> P_{s→t} : T_{γ(s)}M → T_{γ(t)}M

with: P_{t→t} = Id; composition P_{s→u} = P_{t→u} ∘ P_{s→t}; invertibility; smoothness.

**Components**: in a frame, transport is a matrix — P_t(Eⱼ) = cᵏⱼ(t)·Eₖ(γ(t)), c(0) = I; it acts on component columns by multiplication.

**Connection = the first-order data of transport.** Smoothness gives the short-time expansion

> c_{t→t+h} = I + h·A(t) + O(h²)

which defines A(t) — a matrix depending only on the current point and velocity, linear in the velocity. Composition turns this into an ODE: split [0, t+h] at t,

> c(t+h) = c_{t→t+h}·c(t)  ⟹  **c′(t) = A(t)·c(t)**,  c(0) = I

Knowing A at all points reconstructs c along every curve (linear ODE). So the choice of transport and the choice of A are the same choice: **A is the connection** — equivalently, A is the baseline stated infinitesimally: the component drift rate that counts as zero change. (In a coordinate frame, A's entries are the Christoffel symbols: Aᵏⱼ = −Γᵏᵢⱼ γ̇ⁱ.)

## 3. The covariant derivative

V(t) ∈ T_{γ(t)}M along the curve. Naive derivative: lim [V(t+h) − V(t)]/h — fails invariantly (different tangent spaces). In frame components the limit exists: it is V̇. Add and subtract the baseline P_{t→t+h}V(t):

> V(t+h) − V(t) = [ V(t+h) − P_{t→t+h}V(t) ] + [ P_{t→t+h}V(t) − V(t) ]

**First bracket**: both vectors in T_{γ(t+h)}M — legal subtraction; compares V against the baseline. Define:

> **DV/dt := lim_{h→0} [ V(t+h) − P_{t→t+h}V(t) ] / h**

**Second bracket**: doesn't involve V(t+h) — measures the baseline itself. Evaluate with the expansion of §2:

> lim [ P_{t→t+h}V(t) − V(t) ] / h = A(t)·V(t)

**Reassemble**:

> **V̇ = DV/dt + A·V  ⟹  DV/dt = V̇ − A·V**

Properties (all from linearity of P): DV/dt is an honest vector at γ(t) (frame-dependence of V̇ and AV cancels); linear in V; Leibniz D(fV)/dt = ḟV + f·DV/dt.

**Parallel**: DV/dt = 0 ⟺ V̇ = AV ⟺ V(t) = c(t)V(0). The unchanged vectors are exactly the transported ones — the baseline recovered as the kernel of its own derivative.

**Pointwise version**: for a field Y, ∇_v Y at p := DY(γ(t))/dt along any curve with γ̇(0) = v (only (p, v) matters). Axioms it satisfies: tensorial in the direction (∇_{fX}Y = f∇_X Y), Leibniz in the field (∇_X(fY) = (Xf)Y + f∇_X Y). Conversely these two axioms characterize connections — posit ∇, integrate DV/dt = 0 to rebuild P. One structure, two doors:

> **∇ → (restrict to curve) → DV/dt = 0 → (integrate ODE) → P → (short-time expansion) → A → ∇** ✓

## 4. General solution along a curve

Prescribed change DV/dt = S(t), initial V(0):

> V(t) = c(t)·V(0) + c(t)·∫₀ᵗ c(s)⁻¹ S(s) ds

= transported start + transported accumulation of changes (each change carried to the fixed space T_pM before summing — changes at different points cannot be added where they occur). S ≡ 0 recovers parallel transport.

## 5. What the choice buys and what remains

- **Geodesic**: the curve steering by its own transported velocity — DV/dt = 0 with V = γ̇; in coordinates ẍᵏ + Γᵏᵢⱼ ẋⁱ ẋʲ = 0. The connection converts an initial velocity into a trajectory.
- **Path-dependence**: transport between two points depends on the path. Around a closed loop, P_loop ≠ Id in general — the **holonomy**. Its density per unit area is the **curvature** R (built from A: derivatives of A plus the commutator [A, A] — surviving because matrix products don't commute). Curvature is the obstruction to any path-independent identification of tangent spaces — the precise reason the problem of §0 had no free solution.
- **Torsion**: T(X,Y) = ∇_X Y − ∇_Y X − [X,Y] — the failure of infinitesimal parallelograms to close, measured against the manifold's free bracket.
- **Levels of "change"**: raw V̇ (frame-junk) → DV/dt (frame-independent, but baseline-relative) → nothing above: no connection-free notion of a vector changing exists.

## 6. Metric and Levi-Civita

A **metric** g: a smooth, symmetric, positive-definite (0,2) tensor field — a pointwise inner product on tangent spaces. Two conditions single out one baseline:

- **Metric compatibility** (∇g = 0): transport preserves lengths and angles — every P_{s→t} is an isometry. In an orthonormal frame, A(t) is antisymmetric: transport is a curve in the rotation group, A its infinitesimal rotation rate.
- **Torsion-free** (T = 0).

**Fundamental theorem**: exactly one connection satisfies both — the **Levi-Civita connection**, computable from the metric:

> Γᵏᵢⱼ = ½ gᵏˡ ( ∂ᵢg_jl + ∂ⱼg_il − ∂ˡg_ij )

## 7. The sphere (standing example)

S² ⊂ ℝ³ with the round metric. Levi-Civita transport = differentiate in ℝ³, project onto the tangent plane ("as constant as the surface allows"); equivalently, roll a tangent plane along the curve without slipping or twisting. Geodesics = great circles. Transport around a closed loop returns vectors rotated by the enclosed area (holonomy = ∬K dA, K = 1) — e.g. 90° around an octant triangle. This nonzero holonomy is the concrete proof that no canonical identification of tangent spaces existed: the answer to §0's problem was necessarily a choice.
