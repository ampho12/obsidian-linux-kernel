
# math foundations → mechanics

Here's the full layering, by math area and where each lands in engineering. Then a focused look at duality.

## Master mapping table

|Math area|Key objects|Rigid body|Continuum mechanics|
|---|---|---|---|
|**Linear algebra**|vectors, covectors, scalars|position, velocity, force, moment|displacement vectors, traction vectors|
|**Multilinear algebra**|tensors of rank ≥ 2, symmetric/antisymmetric parts|inertia tensor I; ω as skew matrix|strain ε, stress σ, elasticity tensor Cᵢⱼₖₗ|
|**Differential geometry**|manifolds, TQ, T*Q, Lie groups, Lie algebras|Q = SE(3); twists and wrenches; angular velocity in so(3)|Q = space of deformation maps; F = ∂x/∂X as a map T_XΩ₀ → T_xΩₜ|
|**Exterior calculus**|k-forms, wedge ∧, exterior derivative d, Stokes' theorem|symplectic 2-form ω = dp∧dq on phase space; preserved by Hamiltonian flow|divergence theorem (Stokes' for n-forms) → localization of integral balance laws into PDEs|
|**Calculus of variations**|functionals, functional derivative δ, Euler–Lagrange|Hamilton's principle for finite-DOF → ODEs|δS = 0 for field problems → PDEs + natural BCs (PVW = static version)|
|**Functional analysis**|Banach / Hilbert spaces, duality of function spaces, weak convergence|lighter use — phase space is finite-dim and manageable|function spaces of admissible displacements; stress as a continuous functional on velocities|
|**Sobolev spaces & weak formulations**|Hᵏ spaces, weak derivatives, trace operators, weak/variational PDEs|not really needed|rigorous setting for elasticity PDEs; FEM convergence theory; weak form ≡ PVW|

## How the layers stack

```
Linear / multilinear algebra
        ↓  (extend to curved spaces)
Differential geometry & tensor calculus
        ↓  (add forms and integration)
Exterior calculus
        ↓  (add functionals and stationarity)
Calculus of variations
        ↓  (infinite-DOF, rigorous topology)
Functional analysis
        ↓  (right function spaces for PDEs)
Sobolev spaces & weak formulations
        ↓
Mechanics
```

Rigid-body mechanics is comfortable with the first four levels. Continuum mechanics formally needs all seven — though for engineering work, the first five are usually enough.

## Duality, the thread that runs through everything

This is the unifying idea. The same pattern repeats at every scale.

### At the linear algebra level

For every vector space V there's a **dual space** V* = { linear maps V → ℝ }. A vector v ∈ V pairs with a covector α ∈ V* to give a scalar: ⟨α, v⟩. That's the most basic duality — and it's what every higher level builds on.

### At the rigid-body level

At each configuration q ∈ Q:

- **Tangent vectors** = velocities / infinitesimal displacements (_kinematic_): v ∈ T_q Q
- **Cotangent vectors** = forces / momenta (_kinetic_): F ∈ T*_q Q
- **Their pairing** ⟨F, v⟩ = **power** (or virtual work, if v is a δq)

Force and velocity aren't the same kind of object — they live in dual spaces, and their pairing produces work/power. _That's why "F · v = power" works out in any coordinate system: it's an intrinsic pairing, not coordinate-dependent._

### At the continuum level

The same structure, but now tensor-valued at each point:

- **Strain field** ε(X) — symmetric tensor field, _kinematic_ (built from gradients of displacement)
- **Stress field** σ(X) — symmetric tensor field, _kinetic_ (force per area)
- **Their pairing** σ : ε = σᵢⱼεᵢⱼ = **energy density** (a scalar per unit volume)

The colon ":" is the tensor contraction — the multilinear version of ⟨·, ·⟩.

## The kinematic ↔ kinetic table

The pattern across all of mechanics:

|Kinematic side (TQ, geometry)|Kinetic side (T*Q, physics)|Pairing →|
|---|---|---|
|displacement / velocity (vector)|force / momentum (covector)|work, power|
|generalized coordinate q|generalized force Q|Q · q (work)|
|generalized velocity q̇|generalized momentum p|p · q̇|
|strain ε (symmetric tensor)|stress σ (symmetric tensor)|σ : ε (energy density)|
|deformation gradient F|1st Piola–Kirchhoff P|P : Ḟ (power per unit ref. volume)|
|Green–Lagrange strain E|2nd Piola–Kirchhoff S|S : Ė|
|velocity gradient ∇v|Cauchy stress σ|σ : d (stress power, current config.)|

Each row is a **work-conjugate pair**: kinematic on the left, kinetic on the right, paired to a scalar that's energy, work, or power. The right column in continuum mechanics is exactly what we mean by "the right kind of stress measure for that strain measure" — they always come in matched pairs by construction.

## The constitutive law lives _across_ the duality

This is what makes the framework powerful:

> **Strain $(\epsilon)$ is kinematic** — pure geometry, how the body is deformed. **Stress $(\sigma)$ is kinetic** — pure dynamics, what the forces are. **The constitutive law σ = σ(ε) bridges them.** For elastic materials it has the form: $$\sigma = \frac{\partial W}{\partial \varepsilon}$$ i.e., _stress is the gradient of stored energy with respect to strain._

This is exactly the same statement as "F = −∂U/∂q" for a conservative force on a particle — the duality pairing ⟨·, ·⟩ written in continuum form. The variational view of continuum mechanics sees stress as a **derived** quantity: you postulate kinematics + energy density W, and the duality structure gives you stress automatically.

## Where functional analysis comes in

For continua, the kinematic-kinetic duality becomes a duality between _function spaces_:

- Displacement field u lives in some space V (e.g., H¹(Ω) for linear elasticity)
- The "force field" on the body lives in V*, the dual space — it's a continuous linear functional on velocities, evaluating to the power delivered

The weak / variational form of equilibrium:

$$\int_\Omega \sigma : \varepsilon(v),dV ;=; \int_\Omega \mathbf{b}\cdot\mathbf{v},dV + \int_{\partial\Omega^t}\bar{\mathbf{t}}\cdot\mathbf{v},dS \quad \forall v \in V$$

is exactly **PVW**. From functional analysis, it says "the equilibrium condition equates two continuous linear functionals on V." That's the deep reason FEM works:

- Discretize V into a finite-dim subspace
- The same duality pairing carries over to the discrete matrix world
- The stiffness matrix is symmetric because the underlying bilinear form a(u, v) = ∫ σ(u) : ε(v) dV is symmetric
- Convergence theorems follow from the Banach/Hilbert structure of the function spaces

## The picture you can hold in your head

```
                  KINEMATIC                      KINETIC
                  (geometry, TQ)                 (physics, T*Q)
                  
Linear algebra    vector v                       covector α
                  velocity, displacement         force, momentum
                  
Mech (particle)   q, q̇                          Q, p
                  
Continuum         strain ε, ε̇, F                stress σ, P
                  
                            ⟨ , ⟩ pairing  → scalar (work, energy)
                            constitutive law σ = ∂W/∂ε
                            (bridges the two columns)
```

That's the map. Three things to take from it:

1. **Mechanics has two columns**: kinematic and kinetic. They're not the same kind of object.
2. **They pair to scalars** (work, power, energy). That's what makes the framework coordinate-invariant.
3. **The constitutive law bridges the columns** via an energy gradient — that's the bridge from pure geometry to physics.

Let me know where to dig next — the natural specialization from here is small-strain linear elasticity (the simplest concrete instance of the σ = ∂W/∂ε bridge), but we can also spend a session on any single math area if you want depth on its own.