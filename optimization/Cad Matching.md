

Refer to a html file in this folder for a better explanation.


# Three Steps
1. convert problem to joint optimization and ensure minima exists
2. shape the landscape.
3. traverse to stationary point in whatever basin we started.






---
Let's phrase it better.

Y is a B-Rep, describe B-Rep (geometry + topology). We already have a good way to do this.

Mention this makes YN is not convex, need a chart per face, discrete jumps between faces.

Invoke the theorem about the minima over point beins same as integral minima over measures.

Reformulate problem to SE(3) x P(Y)^N

Now invoke the indepencene and product.

We get a minimization over SE(3) x P(Y)^N.



Now we can shape the landscape as needed. For now assume its unchanged.

make P(Y)^N latent, traverse to stationary point int basin.


# The formulation, assembled

## Y is a B-rep

A STEP model stores the part as a **boundary representation** — two layers.

_Geometry._ The surfaces themselves. Each is a map S: Ω → ℝ³ from a parameter rectangle Ω ⊂ ℝ² into space, written S(u,v). Planes, cylinders, cones, spheres, tori, and NURBS patches. Similarly curves C(t) mapping an interval into space.

_Topology._ What's trimmed to what, and how it joins. A **face** is a surface plus closed loops in its (u,v) domain cutting out the portion kept. An **edge** is a curve shared by two faces; a **vertex** a shared endpoint. Faces sewn along edges bound a closed **solid**.

So Y ⊂ ℝ³ is a compact 2-manifold: continuous, exact, described rather than sampled.

## The naive joint problem

The physical story: each measurement came from one location yᵢ ∈ Y, observed with noise after the part was placed by some T ∈ SE(3).

**E(T, y₁, …, y_N) = Σᵢ ‖T(xᵢ) − yᵢ‖²**

Search space **SE(3) × Yᴺ**. Correct, and intractable.

Y is not convex — average two surface locations and you leave the surface, so there are no convex combinations and no linear structure. Calculus requires a chart, and charts are per-face: the (u,v) parameterization breaks at trim boundaries and degenerates at cone apices and sphere poles. Worst, **which face yᵢ lies on is a discrete choice.** Moving between faces is not continuous motion in any single chart. The search over Yᴺ is combinatorial — Kᴺ branches for K faces — with continuous refinement inside each.

## The theorem

**min_{y ∈ Y} f(y) = min_{π ∈ P(Y)} ∫ f dπ**

≥ because no average beats a minimum, given total mass one. ≤ because δ at the minimizer attains it. An exact identity.

The reason it must be measures: cost is a value _at a location_, so it's a function on Y; weight is an amount _over a region_, and on a continuum a single point carries none. Whatever collapses a cost landscape to a bill does so linearly and continuously — that is a bounded functional on C(Y) — and **Riesz–Markov** says every such functional is integration against a unique measure, via an isometric isomorphism M(Y) ≅ C(Y)*. The weight object isn't modeled as a measure; it is one.

## Reformulated

**E(T, π₁, …, π_N) = Σᵢ ∫_Y ‖T(xᵢ) − y‖² dπᵢ(y)**

Search space **SE(3) × P(Y)ᴺ**.

Larger — infinite-dimensional per datum — but the pathologies are gone. Each P(Y) is **convex**: mixtures of measures are measures. The objective is **linear** in each πᵢ regardless of the cost's behavior. And the face problem dissolves — a measure spanning two faces is a legitimate point of P(Y), where a location on two faces was not. The combinatorial branching becomes movement inside a convex set. Compactness (Banach–Alaoglu, P(Y) closed in the unit ball of M(Y)) gives existence of a minimizer.

Note also that the trimmed-boundary and pole degeneracies stop mattering: δ_q is δ_q whether q sits in a face interior, on an edge curve, or at a vertex.

## Independence and the product

Nothing constrains what the model side _receives_ — no cap on Σᵢ πᵢ(A) for a region A. So the feasible set is a **product**, ∏ᵢ P(Y), and each πᵢ is unrestricted by the others. Therefore

min over (π₁,…,π_N) of Σᵢ (bill for i) = Σᵢ min over πᵢ

The N collapses are independent — one query per point, embarrassingly parallel. This is a property of _this_ dial setting, not a general fact: constrain the received mass and the product structure fails, fusing the N problems into one transport problem.

## Shaping (left unchanged for now)

The lifted block is where the freedom lives — admissible set, regularizer, schedule. Unshaped, the problem is linear over a convex compact set, so its optimum sits at an **extreme point**, and the extreme points of P(Y) are exactly the Diracs. The relaxation is tight: nothing spurious was admitted, and hard assignment wins. Fractional π appears only under ties, which are exactly the medial axis, which are exactly the kinks.

## Eliminate and traverse

Take the πᵢ as the block to eliminate — cheap to eliminate (a closed-form per-point argmin) and uninteresting to report (a list of N surface locations is not "where is the part"). Then

E(T) = min_π E(T, π)

is the **lower envelope** of the members E(·, π), each smooth in T. Kinks occur at handovers.

At T₀, solve the inner problem for π*. The member E(·, π*) lies **above** the envelope everywhere and **touches** at T₀, so minimizing it descends:

E(T₁) ≤ E(T₁, π*) ≤ E(T₀, π*) = E(T₀)

and by Danskin, ∇E(T₀) = ∇_T E(T₀, π*) — differentiating with π frozen gives the exact gradient. Majorize–minimize.

```
T ← init
repeat:  π ← argmin_π E(T, π)     # nearest-point query per datum
         T ← argmin_T E(T, π)     # 6×6 linear solve
```

Convergence: to a **stationary point of the envelope, in whatever basin you started**. Existence of a joint minimum was established above; nothing connects it to what this finds. The surrogate is assembled from purely local queries, so the step is local, so the convergence is local — structural, not an implementation defect.

That gap is where initialization, restarts, and annealing live — and shaping the landscape is the only structural lever on it.
 