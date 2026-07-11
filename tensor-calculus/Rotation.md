

## Group element, group dimension, algebra dimension

Three different questions, three different answers:

- **Group element** — how many numbers you _write it with_ (the redundant description).
- **Group dimension** — how many independent knobs actually specify it (its true freedom, as a curved surface).
- **Algebra dimension** — how many numbers a _velocity_ needs. Always equals the group dimension, since the algebra is the tangent space, and a tangent space has the same dimension as its manifold.

||group element|group dimension|algebra dimension|
|---|---|---|---|
|SO(2)|2×2 = 4 numbers|1|1|
|SO(3)|3×3 = 9 numbers|3|3|

The extra numbers are eaten by constraints: for SO(3), `RᵀR = I` gives 6 constraints, so `9 − 6 = 3`.

## The group and the algebra

**SO(3):** 3×3 matrices with `RᵀR = I`, `det R = 1`. 9 numbers, 6 constraints → 3 DOF, a curved surface in 9D matrix space. Rotations compose by multiplication; `R₁ + R₂` leaves the surface.

**so(3):** the tangent space at `I` — skew-symmetric 3×3 matrices, `≅ ℝ³`. Differentiating `RᵀR = I` at `R = I` gives `Aᵀ = −A`, the linearized "stay a rotation" condition. Elements are angular velocities.

## exp / log

Every `R = exp(A)` for some skew `A = θn̂`. Rodrigues:

```
exp(θn̂) = I + sin θ · n̂ + (1 − cos θ) · n̂²
```

Inverse: `θ = arccos((tr R − 1)/2)`, axis from `R − Rᵀ = 2 sin θ · n̂`. Onto but many-to-one (`θ`, `θ + 2π` coincide) — `log` returns `θ ∈ [0, π]`.

## The circle picture

Moving along a circle by angle `θ` from `(1,0)`:

```
arc:            θ
tangent shadow: sin θ        (chord's straight-line projection)
normal shadow:  1 − cos θ    (curvature — how far the surface bends away)
```

Rodrigues is exactly this, promoted to matrices.

## Velocity is arc length, not chord

`Ṙ·t`, the tangent step, has the right direction and its length is the true arc length `θ = |ω|t` — not the shorter chord `sin θ` — because `Ṙ` is a derivative, living in the `dt → 0` limit where chord and arc coincide. But laid out straight, it leaves the surface: `R + Ṙt ∉ SO(3)`.

## Bending it back: two maps

1. **Trivialize** (linear, exact): `v ↦ R⁻¹v` undoes the tilt of `T_R = R·so(3)`, landing the velocity in the fixed reference space:
    
    ```
    ω̂t = R⁻¹Ṙ·t ∈ so(3)
    ```
    
2. **Exponentiate** (nonlinear — the only place curvature enters):
    
    ```
    R_new = R · exp(ω̂t)
    ```
    

Exact for constant `ω̂` (it solves `Ṙ = Rω̂`) and stays on SO(3) for all `t`. Agrees with the naive step to first order, with `exp` supplying the higher-order corrections that keep it orthogonal:

```
R · exp(ω̂t) = R + Rω̂t + O(t²) = R + Ṙt + O(t²)
```

## Why route through so(3)

A generic manifold needs its own exponential map at every point. A Lie group needs only one: every tangent space is the same so(3), translated, so you solve "how straight lines bend" once at the identity and reach everywhere else by translation:

```
exp_R(v) = R · exp(R⁻¹v)
```

`Ṙ·t ↦ R·exp(R⁻¹Ṙ·t)` factors as **trivialize (linear) → exponentiate (nonlinear, once) → compose (linear)**.

_Convention: post-multiplying matches body-frame rate `ω̂ = RᵀṘ` (what a gyro reports) — standard in IMU/SLAM. Spatial rate `ṘRᵀ` would pre-multiply instead._