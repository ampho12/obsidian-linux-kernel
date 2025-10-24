




# State Equations

Every system can be described by state equations

$$
\dot{\bf x} (t)
= 
{\bf f}
(
{\bf x}(t)
,
{\bf u}(t)
)
$$
$$
{\bf y} (t)
= 
{\bf g}
(
{\bf x} (t)
,
{\bf u} (t)
)
$$

every higher order system can be reduced to the first order case



## General System Equation

A general n-th order system equation looks like

$$
\frac{d^n \bf q}{d t^n}
=
{\bf f}
(
{\bf q}
,
\dot{\bf q}
,
\ddot{\bf q}
,
\ldots
,
{\bf q}^{(n-1)}
,
{\bf u}
,
t
)
$$

## State Space Idea

In control theory, a **state** is defined as the minimal set of variables that completely describe the system's future evolution.

To reduce higher ordder ODE into first-order form, we can define state variables as follows

$$
{\bf x}
=
\begin{bmatrix}
{\bf q} \\
\dot{\bf q} \\
\ddot{\bf q} \\
\vdots \\
{\bf q}^{(n-1)}
\end{bmatrix}
$$

Thus, we get a state space equaton

$$
\dot{\bf x} = {\bf f}({\bf x}, {\bf u}, t)
$$

Same logic applies to the output.


## Feedback Equivalence

Consider two systems

$$
\dot{\bf x}
=
{\bf f}_1
(
    {\bf x},
    {\bf u},
    t
)
$$
$$
\dot{\bf x}
=
{\bf f}_2
(
    {\bf x},
    {\bf v},
    t
)
$$

If we apply a closed loop control law $u = h(v, x)$, to system 1 such that 
$$
{\bf f}_1
(
    {\bf x},
    {\bf h(v, x)},
    t
)
=
{\bf f}_2
(
    {\bf x},
    {\bf v},
    t
)
$$

then we have a feedback control law that makes system 1 behave like system 2. This means they are feedback equivalent.

> Sometimes we also need a state transformation like $z = T(x)$



# Linearity


## Global Linearity / Input Output Linearity
A system is linear if it satisfies the superposition principle with zero initial conditions

1. Additivity: 
   if a control trajectory $u_1(t)$ gives output trajectory $y_1(t)$, and another control trajectory $u_2(t)$ gives output trajectory $y_2(t)$, then control trajectory $u_1(t) + u_2(t)$ should give output trajectory $y_1(t) + y_2(t)$.
2. Homegeneity (Scaling)
   if control trajectory $u_1(t)$ gives output trajectory $y_1(t)$, then $\alpha u_1(t)$ gives output trajectory $\alpha y_1(t)$

> **Note on initial conditions.** Superposition is tested for **zero initial state**; otherwise the free response adds an extra term that can break additivity/homogeneity even for a linear system

to translate this into the general state space idea, we show that both $\bf f$ and $\bf g$ must be linear functions in ${\bf u}(t)$ and ${\bf x}(t)$


## Local Linearity / State Output Linearity

At each time t, there is a linear map from $(u(t), x(t)) \mapsto (\dot{x}(t), u(t))$

$$
\dot{x}(t) = A(t)x(t) + B(t)u(t)
$$

$$
\dot{y}(t) = C(t)x(t) + D(t)u(t)
$$


Then it is globally linear.




# Dynamics Law

Consider the following dynamics relation


$$
M(q, v)\dot{v} + C(q, v) v + g(q) = \tau
$$

here $\tau$ is the applied torque 

The dimensions are as follows

(note these are presented in drake order)
1. $q$ is the generalized coordinates, e.g `[ x, y, z, qw, qx, qy, qz, joint_angle ... ]`
2. $v$ is the generalized velocity e..g `[x_dot, y_dot, z_dot, r_dot, p_dot, y_dot, joint_angles_dot]`
3. $\dot{v}$ is the generalized acceleration, same dimensions as $v$.
4. $\tau$ is generalized forces, same dimensions as $\dot{v}$.


Now say we have a desired generalized acceleration $\dot{v}_d$ , then the torque needed to drive towards this generalized acceleration is computed using the above dynamics

given state $q, v$, we have desired torque $\tau_d$.

$$
M(q, v)\dot{v_d} + C(q, v) v + g(q) = \tau_d
$$


For actuation, not all generalized torques can be realized if the system is underactuated. We define the matrix mapping control input to generalized torques as $B$. This gives the possible torque we can drive.

$$
Bu
$$

Now, we compute u that minimizes $\tau_d - Bu$




## Constrained Dynamics

Now let us assume we some constraints. Some examples of constraints include


1. Holonomic Constraint: These are constraints on the configuration that can be expressed as $\phi(q) = C$ that must hold at all times.
2. Non-Holonomic Constraint: these are constraints on velocities that cannot be integrated into a constraint on coordinates

Let us take an example of a foot that doesn't leave the ground. Let the $p_z(q)$ be the height of the foot above the ground, then

$$
p_z(q) = 0
$$

We can write this as
$$
\phi(q) = p_z(q) = 0
$$

which is a holonomic constraint.


Now imagine we are doing control law with holonomic constrants, our lagrangian function with the constraint multipliers is 
$$
L'(q, \dot{q}, \lambda) = L(q, \dot{q}) + \lambda^T \phi
$$

Plugging in the EL equation
$$
\frac{d}{dt} \frac{\partial L'}{\partial \dot{q}} - \frac{\partial L'}{\partial q} = Q_{ne}
$$

This yields
$$
M(q)\dot{v} + C(q, v)v + g(q) - J_c(q)^T\lambda = Q_{ne}
$$
Rearranging,
$$
M(q)\dot{v} + C(q, v)v + g(q) = Q_{ne} + J_c(q)^T\lambda 
$$

## Control under Constrained Dynamics

Let us rewrite the constrained dynamics relation again

$$
M(q)\ddot{q} + C(q, v)\dot{q} + g(q) = \tau + J_c(q)^T\lambda 
$$

where we have put the holonomic constraint into the control law
$$
\phi(q) = 0
$$

Differentiating the constraint twice with respect to time, we get
$$
J_c(q),\ddot q + \dot J_c(q,\dot q)\dot q = 0.
$$
We can combine this with the dynamics equation to get the constrained dynamics. We simply stack dynamics and the contact acceleration constraint:
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

This is a **KKT system**. We are usually conserved with how to find the triplet $(\ddot{q}, \lambda, \tau)$. We have the following cases usually

| $J_c$ rank         | Forward dynamics $;\tau \to (\ddot q,\lambda)$                                                                                                                                                                                                                                                        | Inverse dynamics $;(\ddot q,\lambda) \to \tau$                                                                                                                      | Inverse dynamics $;\ddot q \to (\lambda,\tau)$                                                                                                                                                                     |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Full rank**      | • KKT matrix $\begin{bmatrix}M & -J_c^\top \\ J_c & 0\end{bmatrix}$ is nonsingular.<br><br>• For any applied $\tau$ there is a **unique** pair $(\ddot q,\lambda)$.                                                                                                                                   | • If $(\ddot q,\lambda)$ satisfy $J_c\ddot q+\dot J_c\dot q=0$, then $$\tau = S\big(M\ddot q+h-J_c^\top\lambda\big)$$ is **unique**.                                | • Given only $\ddot q$, $\lambda$ is not unique.<br>• Must choose a **selection rule** (e.g. min–norm $\lambda$, friction QP, dynamically consistent projection).<br>• Once $\lambda$ is chosen, $\tau$ is unique. |
| **Rank deficient** | • $A=J_cM^{-1}J_c^\top$ is singular $\Rightarrow$ KKT not invertible.<br><br>• Forward solutions $(\ddot q,\lambda)$ are **not unique**.<br>• Simulators pick a unique pair via **regularization / optimization** (mass–weighted projection, min–norm $\lambda$, small compliance, QP with friction). | • If a **consistent** pair $(\ddot q,\lambda)$ is supplied (i.e. $J_c\ddot q+\dot J_c\dot q=0$), then $$\tau = S(M\ddot q+h-J_c^\top\lambda)$$ is still **unique**. | • Given only $\ddot q$, both $\lambda$ and $\tau$ are underdetermined.<br>• Must choose a **selection rule** (pseudoinverse, min–norm, QP, friction model) to fix $\lambda$; then $\tau$ is uniquely determined.   |

**Notes:**

* “Selection rule” = extra optimality (mass weighting / dynamically consistent pseudoinverse, minimum‐norm forces, QP with friction, etc.).
* All “unique” statements assume a **fixed contact mode** and **bilateral/sticking** constraints.
* With **unilateral/friction** contacts, uniqueness can depend on the **active set**; a well-posed convex QP with strict complementarity still gives a single solution.


> This is the crux of controls. i.e given a desired generalized acceleration and optionally contact forces that are feasible, find the right $\tau$ that will produce them (or find the right lambda)


### Full Rank $J_c$

In this case, we want to find a feasable $\ddot{q}$ closest to our command say $v$.
$$  
v \equiv \ddot q_{\text{raw}} \in \mathbb R^{n}.  
$$  
It could come from PD terms, inverse dynamics, a policy, etc.—**before** enforcing contacts.


However With contacts, accelerations must satisfy the acceleration-level constraint  
$$  
J_c\ddot q + \dot J_c\dot q = 0.  
$$  
So a **feasible** acceleration is any $\ddot q$ that makes that true. Equivalently,  
$$  
\ddot q = \underbrace{\ddot q_p}_{\text{particular (cancels }\dot J_c\dot q)} + \underbrace{z}_{\in\ker(J_c)}
$$  
To find a good solution from the feasible set,  we pick the one **closest to our command $v$** in the **physically meaningful metric** (kinetic energy), i.e. minimize  
$$  
\frac12|\ddot q - v|_{M}^{2} = 
\frac12(\ddot q-v)^\top M(\ddot q-v) 
$$  
One way to solve this is to directly solve this optimization problem.

$$
\mathcal{L}(\ddot{q}, \lambda) = 
\frac12(\ddot q-v)^\top M(\ddot q-v) 
+ \lambda^\top \left(J_c \ddot{q} + \dot{J_c}\dot{q} \right)
$$

we get 
$$
M(\ddot{q} - v) + J_c^\top \lambda = 0
$$
that is
$$
\ddot{q} = 
v - M^{-1}J_c^\top \lambda
$$
Substituting into the constraint, we get
$$
J_c \left( v - M^{-1}J_c^\top \lambda \right)
+
\dot{J_c}\dot{q}
=
0
$$
$$
J_c v
+
\dot{J_c}\dot{q}
=
J_cM^{-1}J_c^\top \lambda 
$$

define $A = J_c M^{-1} J_c^\top$, if A is not invertible, use the moore penrose inverse
$$
A^+ \left(
J_c v
+
\dot{J_c}\dot{q}
\right)
= 
\lambda
$$
Thus, we get
$$
\ddot{q} = 
v - M^{-1}J_c^\top 
A^+ \left(
J_c v
+
\dot{J_c}\dot{q}
\right)
$$

We can take another approach where we take a two step approach

This is a two step process

1. Find a particular solution $\ddot{q}_p$  of the constraint using the dynamic consistency. We already have the close formed solution in [[Underdetermined Systems]]
   $$
   \ddot{q}_p = -M^{-1}J_c^\top A^+(\dot{J}_c \dot{q})
   $$
2. Then project the desired command $v$ into the null space. For this we need a projector that can do this to recover the optimal $\ddot{q}$
   $$
    \ddot{q} = \ddot{q}_p + N_c(v - \ddot{q_p})
    $$
    $$
    v - M^{-1}J_c^\top 
    A^+ \left(
    J_c v
    +
    \dot{J_c}\dot{q}
    \right)
    =
    \ddot{q}_p + N_c(v - \ddot{q_p})
    $$
    Solving,
    $$
    N_c = I - M^{-1}J_c^\top A^+ J_C
    $$


#### Constraint Consistent Inertia

Any feasible acceleration can be written as 
$$
N_c \ddot{q}
$$
let $\ddot{q}$ be produced by $\tau$ in an unconstrained manner, then $\ddot{q} = M^{-1} \tau$ and 
$$
N_c M^{-1} \tau
$$
is the forward dynamics acceleration produced by $\tau$. 





#### Task Space Control

### Rank Deficient $J_c$


> TODO
> Add how solving for $\tau$ guarantees that the same $\ddot{q}$ and $\lambda$ will be produced if the system is underdetermined. WIP see below

For finding the right tau in the rank deficient case, we need this

Great question. In the **rank-deficient** case you have _force/acceleration redundancy_. A simulator resolves that by adding its own **selection rule** (regularization/optimization). If you send only (\tau), the sim will pick **its** ((\ddot q,\lambda)). To make the sim output _your_ ((\ddot q^\star,\lambda^\star)), you have two choices:

## Your options

### A) **Match the simulator’s selection rule** (recommended)

Figure out (or assume) the rule your sim uses (e.g., **min-norm wrench**, or a tiny compliance/regularization):

- Common: replace (A=J_c M^{-1}J_c^\top) with (A_\varepsilon = J_c M^{-1}J_c^\top + \varepsilon I) (or a cone/QP).
    
- Then **the sim’s forward map** for a given (\tau) is
    

[  
\lambda(\tau) ;=; A_\varepsilon^{-1}!\Big[-\dot J_c,\dot q ;-; J_c M^{-1}\big(S^\top\tau - h\big)\Big],  
]  
[  
\ddot q(\tau) ;=; M^{-1}!\Big(S^\top\tau - h + J_c^\top \lambda(\tau)\Big).  
]

So (\lambda) and (\ddot q) are **affine** functions of (\tau).

- If you want **only (\ddot q^\star)**: solve the linear system  
    [  
    \ddot q(\tau) = \ddot q^\star  
    ]  
    for (\tau) (least squares if over/underdetermined).
    
- # If you want **both (\ddot q^\star) and (\lambda^\star)**: stack and solve  
    [  
    \begin{bmatrix}  
    \ddot q(\tau)[2pt] \lambda(\tau)  
    \end{bmatrix}
    
    \begin{bmatrix}  
    \ddot q^\star[2pt] \lambda^\star  
    \end{bmatrix}  
    ]  
    (feasible only if your target pair is consistent with that selection rule; otherwise solve weighted least squares).
    

This “inverts” the simulator’s own choice. If you match its (A_\varepsilon) (or its QP), the sim will reproduce what you solved for.

---

### B) **Wrap the sim with your own tiny inverse-dynamics QP**

Each tick, solve for ((\ddot q,\lambda,\tau)) with **your** objective but **include** a small term that mimics the sim’s regularization so both agree:

[  
\min_{\ddot q,\lambda,\tau};  
|\ddot q-\ddot q^\star|_{W_q}^2  
+|\lambda-\lambda^\star|_{W_\lambda}^2  
+\rho,|\lambda|^2  
+\rho_\tau,|\tau|^2  
]  
s.t.  
[  
M\ddot q+h = S^\top\tau + J_c^\top\lambda,\qquad  
J_c\ddot q+\dot J_c\dot q=0.  
]

Pick (\rho) (and friction/CoP bounds if needed) to mirror the sim. Send the resulting (\tau). Because your “selector” matches the sim’s, its forward step will return the same (or extremely close) ((\ddot q,\lambda)).

---

## Are you “at the mercy” of the simulator?

- **Yes**, if you don’t model its selection. You can’t force a specific (\lambda) in a rank-deficient rigid contact by torque alone—the sim will distribute forces per its rule.
    
- **No**, if you **replicate** the rule (A) or **embed** it in your own QP (B). Then there’s a **consistent bijection** between (\tau) and the sim’s selected ((\ddot q,\lambda)).
    

---

## Concrete recipe (linear algebra form)

Assume the sim uses (A_\varepsilon = J_c M^{-1}J_c^\top + \varepsilon I) (min-norm wrench w/ Tikhonov):

1. Precompute:
    
    - (M^{-1}),
        
    - (A_\varepsilon^{-1}),
        
    - (B = -,A_\varepsilon^{-1} J_c M^{-1} S^\top),
        
    - (d = -,A_\varepsilon^{-1}(\dot J_c \dot q - J_c M^{-1} h)).
        
    
    Then  
    [  
    \lambda(\tau) = B,\tau + d.  
    ]
    
2. Then  
    [  
    \ddot q(\tau) = M^{-1}!\Big(S^\top\tau - h + J_c^\top(B,\tau + d)\Big)  
    = H,\tau + c,  
    ]  
    with (H = M^{-1}(S^\top + J_c^\top B)), ; (c = M^{-1}(J_c^\top d - h)).
    
3. Solve:
    
    - **Target (\ddot q^\star):** (H,\tau = \ddot q^\star - c) (least squares).
        
    - # **Target ((\ddot q^\star,\lambda^\star)):**  
        [  
        \begin{bmatrix}H\ B\end{bmatrix}\tau
        
        \begin{bmatrix}\ddot q^\star - c\ \lambda^\star - d\end{bmatrix}  
        ]  
        (feasible only if consistent; otherwise weighted least squares).
        
4. Send (\tau). The sim’s forward step (with the same (A_\varepsilon)) will return your targets (up to integration error).
    

---

## Practical tips

- If your sim uses **compliant contact** (spring–damper), build the same stiffness/damping; then (\lambda(\tau)) is still an affine map you can invert similarly (replace (A_\varepsilon^{-1}) by the compliant model’s operator).
    
- If friction cones are enforced: solve the **QP** version instead of using closed form (adds linear inequalities for friction/CoP).
    
- If your targets are aggressive and **actuator limits** clip (\tau), you won’t hit ((\ddot q^\star,\lambda^\star)); include torque bounds in your QP.
    

---

### Bottom line

In rank-deficient contact, **you control the outcome** if you **use the same selection rule** as the simulator (or wrap it in your own QP). If you don’t, you’re letting the sim choose ((\ddot q,\lambda)) within its rule and you won’t in general get the specific pair you want.

> Note that $\dot{q}$ is not chosen by us, for more details checkout [[Simulation]]



### Choosing $\ddot{q}$

For now, lets assume we can get $\lambda$ from the simulator

Let's look at the constraints
$$
J_c(q)\ddot q + \dot J_c(q,\dot q)\dot q = 0.
$$

Rearranging
$$
J_c(q)\ddot q = - \dot J_c(q,\dot q)\dot q
$$

This is a linear equation, $J_c$ may not be full rank, so we get 
$$
\ddot{q} = \ddot{q}_p + \mathcal{N}(J_c(q))
$$
where $\mathcal{N(\cdot)}$, denotes the null space and $\ddot{q}_p$ is a particular solution to the constraint we started with.

This is the set of all feasible $\ddot{q}$. 

To find one such $\ddot{q}$, we take an initial $\ddot{q}_\text{raw}$, and project it into the solution space (the RHS of the above equation). This is equivalent to solving minimimization

$$
||\ddot{q}_\text{raw} - \ddot{q}||^2
$$

with constraints 
$$
J_c(q)\ddot q + \dot J_c(q,\dot q)\dot q = 0.
$$
we get 
$$
\ddot{q}_p = -J_c(q)^+ \dot{J_c}(q, \dot{q})\dot{q}
$$











