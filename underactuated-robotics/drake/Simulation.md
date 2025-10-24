
This is how  most robotics simulators compute **forward dynamics with contact** (a.k.a. *constrained forward dynamics*). This is the algorithm that takes:

* the current state $q,\dot q$
* applied joint torque $\tau$,
* and contact constraints $J_c$ (known contact points, sticking/no-slip),

and returns:

* generalized acceleration $\ddot q$,
* updated velocity $\dot q_{k+1}$,
* and the ground reaction wrench/forces $\lambda$.

---
# Constrained Forward Dynamics

We start from the continuous rigid-body dynamics

$$
M(q),\ddot q + h(q,\dot q) = S^\top \tau + J_c^\top \lambda
$$
plus the kinematic no-slip constraint

$$
J_c(q),\ddot q + \dot J_c(q,\dot q),\dot q = 0.
$$

Here:

* $M$ = mass matrix,
* $h$ = Coriolis + gravity,
* $S^\top \tau$ = actuation
* $J_c$ = contact Jacobian,
* $\lambda$ = unknown contact forces/wrenches.


We can write the above two equations as a matrix system

Write the unknown vector 
$$
x = \begin{bmatrix}
\ddot q \\ \lambda
\end{bmatrix}
$$
Stack dynamics and the contact acceleration constraint:

$$
\begin{bmatrix}
M & -J_c^\top \\
J_c & 0
\end{bmatrix}
\begin{bmatrix}
\ddot q \\ 
\lambda
\end{bmatrix}
=
\begin{bmatrix}
S^\top \tau - h \\ -\dot J_c \dot q
\end{bmatrix}.
$$

This is a **KKT system**.

## Jc is full rank

If the contact mode is fixed and $J_c$ full row rank, this is a square linear system of size $(n+6+m)$ where $m$ = number of contact constraints.

Solve it:

$$
x = \begin{bmatrix}
\ddot q \\ \lambda
\end{bmatrix}
=
\begin{bmatrix}
M & -J_c^\top \\
J_c & 0
\end{bmatrix}^{-1}
\begin{bmatrix}
S^\top \tau - h \\
-\dot J_c\dot q
\end{bmatrix}.
$$

This gives **consistent** accelerations and contact forces for the applied $\tau$

Another way we can solve the below equation is using Schur Complement
$$
\begin{bmatrix}
M & -J_c^\top \\
J_c & 0
\end{bmatrix}
\begin{bmatrix}
\ddot q \\ 
\lambda
\end{bmatrix}
=
\begin{bmatrix}
S^\top \tau - h \\ -\dot J_c \dot q
\end{bmatrix}.
$$



From dynamics,
$$
\ddot{q} = M^{-1} \left( S^\top \tau - h + J_c^\top \lambda \right)
$$
Plug into the constraint
$$
J_c(q),\ddot q + \dot J_c(q,\dot q),\dot q = 0.
$$

$$
J_cM^{-1} \left( S^\top \tau - h + J_c^\top \lambda \right) = -J_c(q,\dot q)\dot{q}
$$
We Define the constraint inertia, this is (symmetric positive definite) (SPD)
$$
A = J_c M^{-}J_c ^\top
$$
this gives
$$
\lambda = A^{-1} \left[
-\dot{J}_c(q,\dot q)\dot{q}
-
J_cM^{-1} \left( S^\top \tau - h\right)
\right]
$$
and we subtitute for $\ddot{q}$ in
$$
J_c(q),\ddot q + \dot J_c(q,\dot q),\dot q = 0.
$$

### Affine (matrix) form

It’s convenient to expose the dependence on $\tau$ explicitly as an **affine map**.

Define
$$
B \equiv A^{-1} J_c M^{-1} S^\top,\qquad
d \equiv A^{-1}\big(\dot J_c \dot q - J_c M^{-1} h\big)
$$
Then
$$
\boxed{
\lambda(\tau) = B \, \tau + d
}
$$

Next define
$$
H \equiv M^{-1}\big(S^\top + J_c^\top B\big), \qquad
c \equiv M^{-1}\big(J_c^\top d - h\big)
$$
Then
$$
\boxed{
\ddot q(\tau) = H\,\tau + c
}
$$


So the **forward dynamics** under full-row-rank (J_c) is simply:
$$
\tau \mapsto
\begin{cases}
\lambda(\tau) = B\tau + d \\
\ddot q(\tau) = H\tau + c
\end{cases}
$$
a unique affine map at the current $(q,\dot q)$.

### Minimal pseudo-code (numerically stable)

```python
# Given: q, v, M, h, Jc, Jc_dot, S, tau

# Solve linear systems instead of inverting
Minv_times = lambda rhs: np.linalg.solve(M, rhs)

A  = Jc @ Minv_times(Jc.T)                        # SPD
rhs_lam = - Jc @ Minv_times(S.T @ tau - h) - Jc_dot @ v
lambda_ = np.linalg.solve(A, rhs_lam)

qdd = Minv_times(S.T @ tau - h + Jc.T @ lambda_)
```

If you want the **affine form** once (useful for inversion or optimization):

```python
# Precompute operators
A_inv   = np.linalg.inv(A)                        # or Cholesky solve wrapper
B       = - A_inv @ Jc @ Minv_times(S.T)
d       = - A_inv @ (Jc_dot @ v - Jc @ Minv_times(h))

H       = Minv_times(S.T + Jc.T @ B)
c       = Minv_times(Jc.T @ d - h)

# Then: lambda(tau) = B @ tau + d,    qdd(tau) = H @ tau + c
```

# Jc is rank deficient

In case of rank deficient 

check appendix



---

# Time stepping

Simulators then integrate to the next velocity and configuration:

* **Semi-implicit Euler (common):**
  $$
  \dot q_{k+1} = \dot q_k + \ddot q,\Delta t,\quad
  q_{k+1} = q_k + \dot q_{k+1},\Delta t.
  $$

* If contact is **new** (impact), they may instead solve an *impulse* problem at velocity level:

  $$
  M(\dot q^+ - \dot q^-) = S^\top \tau\Delta t + J_c^\top p,
  \quad J_c \dot q^+ = 0,
  $$

  where (p) is an impulse (integral of force over (\Delta t)).


> Note that we cannot usually change $\dot{q}$, this is only changed using an impulse or an integral of acceleration





---

## 4. Friction, unilateral contact

The above is for **bilateral, sticking** contact. Real simulators add:

* **Unilateral constraint**: (f_n \ge 0).
* **Coulomb friction cone**: (\sqrt{f_t^2} \le \mu f_n).
* Sometimes **linearized friction pyramid** for QP/LCP solve.

This turns the linear KKT solve into a **mixed linear complementarity problem (MLCP/LCP)** or a **convex QP**:

[
\min_{\ddot q,\lambda}\frac12 \ddot q^T M \ddot q + \dots
\quad
\text{s.t. }
M\ddot q+h = S^\top\tau+J_c^\top\lambda,;
J_c\ddot q+\dot J_c\dot q=0,;
\lambda\in\mathcal{C}_{\text{fric}}.
]

Different engines:

* **MuJoCo / Drake:** solve QP or convex cone complementarity.
* **Bullet / ODE:** LCP with friction pyramid.
* **Compliant contact:** avoid complementarity, add spring-damper forces then solve unconstrained FD.

---

## 5. Why this matters for your control

* If you supply only (\tau), the simulator just runs this **forward dynamics solve** each step: it finds (\ddot q) and (\lambda) that best satisfy rigid contact + friction.
* If you want to *control* those (\ddot q) or (\lambda), you must design (\tau) to make the solution of that KKT/MLCP problem come out the way you want.
* A common way: **inverse dynamics QP** — you solve the same equations *yourself* to pick a (\tau) that would produce your desired (\ddot q) (and optionally (\lambda)), then send that torque.

---

### Key takeaway

**Forward dynamics in a simulator = solving a constrained dynamics system:**

1. Build KKT matrix with (M, J_c).
2. Solve for (\ddot q) and (\lambda) that satisfy dynamics + contact acceleration + friction cones.
3. Integrate to get (\dot q_{k+1}, q_{k+1}).

So if you know exactly which (J_c) and friction mode the simulator is using, and you send the torque that satisfies those same equations with your desired (\ddot q), you’ll reproduce it (up to integration error).
But if the contact set/mode changes or your desired (\lambda) violates friction/unilaterality, the solver will pick a different (\lambda,\ddot q) than you planned.




# Appendix

Great question. When (J_c) is **rank-deficient** (not full row rank), the rigid contact equations don’t pick a unique ((\ddot q,\lambda)). You need a **selection/regularization** to choose one physically reasonable solution. Here are the standard, working options—what they mean, when to use them, and the exact formulas.

---

# What “rank-deficient” implies

KKT system:
$$
\begin{bmatrix}M & -J_c^\top \\ J_c & 0\end{bmatrix}
\begin{bmatrix}\ddot q \\ \lambda\end{bmatrix}
=
\begin{bmatrix}S^\top\tau - h \\ -\dot J_c \,\dot q\end{bmatrix}
$$



Let $A=J_c M^{-1}J_c^\top$. If $J_c$ lacks row rank, then $A$ is **singular** ⇒ many $(\ddot q,\lambda)$ satisfy the equations.

---

# Four practical strategies

## 1) **Mass-weighted (dynamically consistent) projection** + minimum-norm wrench

This matches the “compliant-limit” physics and many simulators’ default.

* Replace $A^{-1}$ by the **Moore–Penrose pseudoinverse** $A^{+}$ (or add Tikhonov: $A_\varepsilon^{-1}=(A+\varepsilon I)^{-1})$.
* **Particular solution** (cancels bias in the constraint):
  $$
  \ddot q_p = -\,M^{-1}J_c^\top A^{+}(\dot J_c \dot q)
  $$
* **Projector** onto the (mass-weighted) constraint nullspace:
  [
  N_c = I - M^{-1}J_c^\top A^{+} J_c.
  ]
* To get a contact-consistent acceleration closest (in kinetic-energy sense) to a raw command (\ddot q_{\rm raw}):
  [
  \boxed{;
  \ddot q^\star
  = \ddot q_{\rm raw}

  * M^{-1}J_c^\top A^{+}
    \big(J_c \ddot q_{\rm raw} + \dot J_c \dot q\big).
    ;}
    ]
* If you **also** want a wrench, choose the **minimum-norm** solution
  [
  \boxed{;
  \lambda^\star
  = A^{+}!\Big[-\dot J_c \dot q - J_c M^{-1}(S^\top\tau - h)\Big].
  ;}
  ]
  (or use (A_\varepsilon^{-1}) for more damping).

**When**: general control, when you want behavior consistent with stiff but compliant contact.

---

## 2) **Small-compliance (“soft constraint”) regularization**

Mimic stiff springs/dampers at the constraint; numerically very robust.

* Modify KKT:
  [
  \begin{bmatrix}M & -J_c^\top \ J_c & \epsilon I\end{bmatrix}
  \begin{bmatrix}\ddot q \ \lambda\end{bmatrix}
  =============================================

  \begin{bmatrix}S^\top\tau - h \ -\dot J_c \dot q\end{bmatrix},
  ]
  with tiny (\epsilon>0) (ERP/CFM idea).
* This makes (A_\epsilon=J_c M^{-1}J_c^\top+\epsilon I) **invertible**, giving a unique
  [
  \lambda = A_\epsilon^{-1}!\Big[-\dot J_c \dot q - J_c M^{-1}(S^\top\tau - h)\Big],
  \quad
  \ddot q = M^{-1}(S^\top\tau - h + J_c^\top\lambda).
  ]

**When**: you want to **match your simulator** (many use this internally), or need extra numerical stability.

---

## 3) **Contact QP with friction cones/CoP** (most general)

Solve a convex QP each tick (the simulator often does this):

[
\min_{\ddot q,\lambda};
\underbrace{|\ddot q-\ddot q_{\rm free}|*{M}^2}*{\text{mass-weighted projection}}
+\tfrac{\epsilon}{2}|\lambda|^2
]
s.t.
[
J_c\ddot q+\dot J_c\dot q=0,\quad
\lambda\in\text{friction cone/CoP},\quad
\ddot q_{\rm free}=M^{-1}(S^\top\tau-h).
]

Gives a **unique** ((\ddot q,\lambda)) (under mild conditions).

**When**: you must respect friction/CoP explicitly or match a QP-based engine (Drake, MuJoCo soft, DART).

---

## 4) **Upgrade the contact model to be full-rank**

If physically appropriate, model a **6D foot wrench** (torsional friction/rolling resistance) or multiple non-collinear points, so (\mathrm{rank}(J_c)=6). Then the standard (SPD) solve applies and redundancy disappears.

**When**: your “rank deficiency” is from an over-simplified contact model (e.g., point contact when a foot patch would be better).

---

# Using these in control (how to pick (\tau))

## Case A — You **accept the simulator’s** selection

Figure out if it uses soft constraints ((\epsilon)) or a QP. Then the **forward map** is affine:
[
\lambda(\tau)=B\tau+d,\quad
\ddot q(\tau)=H\tau+c
]
with
(B=-A_\epsilon^{-1}J_cM^{-1}S^\top), (d=-A_\epsilon^{-1}(\dot J_c\dot q - J_cM^{-1}h)),
(H= M^{-1}(S^\top+J_c^\top B)), (c = M^{-1}(J_c^\top d - h)).

* Target (\ddot q^\star): solve (H\tau=\ddot q^\star-c) (least squares if needed).
* Target ((\ddot q^\star,\lambda^\star)): solve
  (\begin{bmatrix}H\B\end{bmatrix}\tau=\begin{bmatrix}\ddot q^\star-c\ \lambda^\star-d\end{bmatrix})
  (if consistent; else weighted least squares).

Send that (\tau); the sim will reproduce your targets (up to integration error) because you inverted **its** rule.

## Case B — You want to **impose your own** choice

Solve your own tiny **inverse-dynamics QP**:
[
\min_{\ddot q,\lambda,\tau};
|\ddot q-\ddot q^\star|*{W_q}^2+|\lambda-\lambda^\star|*{W_\lambda}^2
+\rho|\lambda|^2+\rho_\tau|\tau|^2
]
s.t.
(
M\ddot q+h=S^\top\tau+J_c^\top\lambda,;
J_c\ddot q+\dot J_c\dot q=0
)
(+ friction/CoP, torque limits).
Pick (\rho) (and cones) to **match the sim** so your (\tau) leads the sim to the same ((\ddot q,\lambda)).

---

# Diagnostics & tips

* **Detect rank deficiency**: SVD of (J_c M^{-1/2}); treat singular values < (10^{-6}) as zero.
* **Prefer solves over inverses**: don’t form (M^{-1}) explicitly; use Cholesky/LDLT.
* **Regularization**: if using pseudoinverses, a small (\varepsilon) (e.g., (10^{-6}!\times!\text{trace}(A)/m)) stabilizes things.
* **Actuator limits**: include (\tau) bounds in your QP; otherwise you may not hit the target ((\ddot q,\lambda)).

---

## TL;DR

With rank-deficient (J_c), you’re not stuck: pick a **physically motivated selection** (mass-weighted projection with pseudoinverse or (\epsilon)-regularization, or a friction-QP). If you **match the simulator’s rule**, you can **invert** its forward map and choose (\tau) to realize your desired ((\ddot q,\lambda)). If you don’t match it, the sim will choose its own ((\ddot q,\lambda)) for your (\tau).
