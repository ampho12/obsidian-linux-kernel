
In dynamics, generalized positions $q$, generalized velocities $\dot{q}$ and generalized accelerations  $\ddot{q}$ all live in the same vector space called configuration space. The same vector can be a position, velocity or accel, depending on interpretation.

The same holds for the dual of this vector space. In the following sections, we will build this idea
# The Inertia Metric

In a vector space, an inner product is very useful in defining metrics and for defining orthogonality.

In the configuration space, the metric is inertia tensor $M(q)$ which is a $(0,2)$ tensor. And the inner product is
$$
\langle \dot{q}_1, \dot{q}_2 \rangle_M = M_{ij} \dot{q}^i \dot{q}^j
$$

Now that we have an inner product, we can define the Riesz map. For a vector $v \in V$, we can find a canonical bijection to a covector $\flat(v) \in V^*$ such that for all vectors $w \in V$,
$$
\flat(v)(w) = \langle v, w \rangle_M = M_{ij}v^i w^j
$$

This clearly means
$$
\flat(v)_j = M_{ij} v^i
$$

If we take $v$ to be generalized velocity $\dot{q}$, then the covector is the generalized momentum, $p$. This means generalized velocity and generalized momentums are duals.

# Momentum - Velocity Duality
There are two quantities, generalized velocities $\dot{q}$ and generalized momenta $p$. These are kinetic energy duals, in the sense that:

$$
T = \frac12 p^\top \dot{q}
$$
is constant irrespective of choice of basis of $\dot{q}$ and in fact for a particular choice of basis of $\dot{q}$, we have a canonical basis for $p$. 

$$
T = \frac12 p_1 ^\top \dot{q}_1 = \frac12 p_2 ^\top \dot{q}_2
$$

if $\dot{q}_2$ and $\dot{q}_1$ are isomorphic relative to a change of basis.

# Constrained Dynamics

This is critical to understand for biped systems where the foot is constrained to the ground at times and we want to control the joint positions, trajectories, etc.

First recall that $Q$ is the unconstrained configuration manifold with dimensions $n$, i.e n coordinates are needed. Constraints 
$$
g^a(q) = 0
$$
for $a = 1, 2, \cdots, m$ define a submanifold $C \subset Q$ of dimensions $n - m$. At each $q \in C$, we have
$$
V_c = \text{ker}(J_c) \subseteq T_qQ
$$

So $T_qQ$ is an $n$ dimensional space, but $V_c$ is an $n - m$ dimensional space. Since we have a non-degenerate metric, we can define all directions that do not have an admissible component to be in the M-orthogonal subspace, $V_c^\perp \subseteq T_qQ$ which is of dimension $m$.

We start with constraint function
$$
g: Q \to R^m
$$

we define $J_c(q)$ as the jacobian of g. It maps from configuration space to space of constraint velocities.
$$
J_c(q) : T_qQ \to W
$$
where $W \simeq R^m$  (isomorphic) is the space of constraint velocities. Any admissible perturbation $\delta q$ requires by definition
$$
J_c(q)\delta q = 0
$$
i.e $\delta q \in \text{ker}(J_c(q))$.

We know that the dual of $T_q Q$ is the Force covector space $T^*_q Q$. Using the dual of $J_c(q)$ we can sample a any covector from $W^*$ and obtain a force in $T^*_qQ$, i.e
$$
J_c^*(q) : W^* \to T_q^*Q
$$
Recall that range of the dual map of $J$, i.e $\text{range}(J_c^*)$ is the anhilator of J's kernel. 

i.e 
$$
\text{range}(J_c^*) = \text{ker}(J_c)^0
$$

This means $J_c^*$ maps any input vector from $W^*$ to a force $F \in T_q^*Q$ that is
$$
F \delta q = 0
$$
for all admissible $\delta q$.

This makes $F$ a constraint force by definition (from PVW). 

Also note that since we have a non-degenerate metric $M$, we have  $\flat_{T_qQ}(V_c^\perp) = (V_c)^0$. M is also positive definite so 
$$
V_c^\perp \oplus V_c = V
$$


## Orthogonal Projector Matrices

These are useful in projecting a vector into its admissible and inadmissible parts on the tangent space $T_q Q$ or a covecter between its contraint and active part in the cotangent space $T_q^*Q$. These matrices can be chosen project in orthogonal subspaces, i.e $I-P$ and $P$ have their ranges in orthogonal subspaces. This gives them the property of finding the projection that minimizes the norm from the original vector.

We will first find a projector matrix for $P_\perp$ which projects any vector $v \in T_q Q$ into $V_c^\perp$

Note that there is a bijection from $V_c^0$ and $V_c^\perp$ given by $\sharp_M(V_c^0) = V_c^\perp$. Recall that
$$
\text{range}(J_c^*) = \text{ker}(J_c)^0
$$
and 
$$
\text{ker}(J_c)^0 = V_c^0
$$
Therefore, any covector in $V_c^0$ can be written as $J_c^* \lambda$ for some $\lambda \in W^*$. 

Finally invoking the definition of $\sharp_g$, we get
$$
V_c^\perp = M^{-1} V_c^0 = \text{range}(M^{-1}J_c^*)
$$

Now note that $J_c \delta q = J_c \delta q_\perp$ for any $\delta q \in T_q Q$.

Note that $\delta q_\perp \in V_c^\perp$ So $\delta q_\perp = M^{-1}J_c^*\lambda$.
$$
J_c \delta q = J_c M^{-1} J_c^* \lambda
$$

This gives
$$
\left( J_c M^{-1} J_c^* \right)^{-1} J_c \delta q = \lambda
$$

We substitute back into $\delta q_\perp = M^{-1}J_c^* \lambda$.
$$
\delta q_\perp = 
M^{-1}J_c^*\left( J_c M^{-1} J_c^* \right)^{-1} J_c 
\delta q
$$

and we define
$$
P_\perp = 
M^{-1}J_c^*\left( J_c M^{-1} J_c^* \right)^{-1} J_c 
$$
This also gives $P_{||} = I - P_\perp$

Note that in finite dimensions, $J_c^* = J_c^T$

To find a projector onto $V_c^0$ note that $V_C^0 = \flat_M(V_C^\perp)$. So we get
$$
V_C^0 = \text{range}(M P_\perp)
$$

this will however project a vector into $V_c^0$. If we want to project a covector into $V_c^0$, we first map it to a vector. Using the the $\sharp_M$ map. So, the projector is
$$
P^0 = M P_\perp \sharp_M(\alpha)
$$
or
$$
P^0 = M P_\perp M^{-1}
$$

which gives us
$$
P^0 = J_c^*\left( J_c M^{-1} J_c^* \right)^{-1} J_c M^{-1}
$$

The projector onto the non-annihilator covector  space, can be found using $I - P^0$.


## Constrained Equations

The standard dynamics equations can be written as

$$
M(q)\ddot{q} + C(q, \dot{q})\dot{q} + \tau_g = \tau
$$

where the rightmost term is all non-conservative forces and $\tau_g$ are conservative forces. Derivation can be found in [[Controls]].


Now we know that if we have holonomic constriants $g(q) = 0$, then we have constraint jacobian
$$
J_c \delta q = 0
$$

the constraints can be put into the main equation using by affixing the constraint to the lagrangian.
$$
M(q)\ddot{q} + C(q, \dot{q})\dot{q} + \tau_g = \tau + J_c^\top \lambda
$$


### Gravity Compensation

We start from the standard equation

$$
M(q)\ddot{q} + C(q, \dot{q})\dot{q} + \tau_g = \tau + J_c^\top \lambda
$$

For gravity comp, we want to find control input that makes the joints feel weightless, as if there is no gravity. So we solve
$$
\tau_g = \tau + J_c^\top \lambda
$$

Note that the $\tau$ we capture here is just the torques needed to cancel gravity, we will add more torque for tracking, but this is just the gravity cancellation term.

#### Unconstrained
If there are no constraints to enforce, we get
$$
\tau_g = \tau
$$
Note that 
$$
\tau_g(q)_i = -\frac{\partial U}{\partial q^i}
$$


This quantity has an interesting property, based on how the kinematic links are attached, the partial derivative of the gravitational potential changes.

For e.g. if we have three links: torso leg and foot. And have actuators between torso-leg and leg-foot. We have the following configurations

1. Torso is root <- leg <- foot
2. Foot is root <- leg <- torso

In Case 1, moving the torso-leg actuator will move every child node below it, this is: the leg and the foot. So the change in gravitational potential when both the leg and foot move is what we use in $\tau_g$.

In case 2, moving the torso-leg actuator will move every child node below it, but now this is only the torso. This means the gravitational potential will only include the change due to torso.

This is expected with kinematic chains. The problem gets more interesting when we have constrains to enforce

#### Constrained

Now we have 
$$
    \tau_g = \tau + J_c^\top \lambda
$$

We can calculate 
$$
\tau_g = -\frac{\partial U}{\partial q^i}
$$

but now we have to solve for $\tau$ and $\lambda$.

One way is to find lambda and plug into the equation. For example, in a humonoid, all forces to balance the center of mass (moments + linear forces) must come from the ground reaction wrench. We choose $\lambda$ to balance out base. The base is usually free and doesn't have actuation. Let's write this in equations

$$
M(q)\ddot{q} + C(q, \dot{q})\dot{q}
+ \begin{bmatrix}
\tau_g(q)_\text{base} \\
\tau_g(q)_\text{joints}
\end{bmatrix}
= 
\begin{bmatrix}
\tau_\text{base} \\
\tau_\text{joints}
\end{bmatrix}
+ 
\begin{bmatrix}
J_{c,\text{base}} &
J_{c,\text{joints}}
\end{bmatrix}^T
\lambda
$$

Since base is free, $\tau_\text{base} = 0$, for gravity comp our equation reduces to
$$
\tau_g(q)_\text{base} = J_{c,\text{base}}^T \lambda
$$

This gives us a solution for lambda that we plug into
$$
\tau_g(q)_\text{joints} = \tau_\text{joints} + J_{c,\text{joints}}^T \lambda
$$

to finally get our control input $\tau_\text{joints}$


## Variable Transform $q = q(\varepsilon)$

Suppose we introduce a new set of generalized coordinates $\varepsilon \in \mathbb{R}^m$ (with $m \le n$) and define a smooth embedding $q = \Phi(\varepsilon)$. The configuration-space change of coordinates is captured by the Jacobian
$$
J_{q\varepsilon}(\varepsilon) = \frac{\partial \Phi(\varepsilon)}{\partial \varepsilon}
$$
which maps basis vectors in the $\varepsilon$ coordinates into admissible directions in the original $q$ coordinates. Full column rank of $J_{q\varepsilon}$ ensures the change of variables is locally invertible on the submanifold parametrized by $\varepsilon$.

With this Jacobian in hand we can rewrite every kinematic quantity:
$$
\dot{q} = J_{q\varepsilon} \ \dot{\varepsilon}
$$
Differentiating once more gives the accelerations,
$$
\ddot{q} 
= \frac{d}{dt}\left(J_{q\varepsilon} \ \dot{\varepsilon}\right)
= J_{q\varepsilon} \ \ddot{\varepsilon} + \dot{J}_{q\varepsilon} \ \dot{\varepsilon}
$$
where $\dot{J}_{q\varepsilon} = \frac{\partial J_{q\varepsilon}}{\partial \varepsilon} \ \dot{\varepsilon}$ collects the Coriolis-like terms that arise from the changing basis.

Substituting these expressions into the unconstrained manipulator equation,
$$
M(q)\left(J_{q\varepsilon} \ddot{\varepsilon} + \dot{J}_{q\varepsilon} \dot{\varepsilon}\right)
  + C\!\left(q,J_{q\varepsilon}\dot{\varepsilon}\right)J_{q\varepsilon}\dot{\varepsilon}
  + \tau_g(q)
  = \tau
$$
demonstrates that every instance of $\dot{q}$ and $\ddot{q}$ can be rewritten in terms of $\dot{\varepsilon}$ and $\ddot{\varepsilon}$ while the configuration dependence is carried through $q = \Phi(\varepsilon)$.

Premultiplying both sides by $J_{q\varepsilon}^\top$ then yields
$$
J_{q\varepsilon}^\top M(q) \left(J_{q\varepsilon} \ddot{\varepsilon} + \dot{J}_{q\varepsilon} \dot{\varepsilon}\right)
 + J_{q\varepsilon}^\top C\!\left(q,J_{q\varepsilon}\dot{\varepsilon}\right)J_{q\varepsilon}\dot{\varepsilon}
 + J_{q\varepsilon}^\top \tau_g(q)
 = J_{q\varepsilon}^\top \tau
$$
The term multiplying $\ddot{\varepsilon}$ defines the reduced mass matrix in the new coordinates:
$$
\widetilde{M}(\varepsilon) = J_{q\varepsilon}^\top M\big(\Phi(\varepsilon)\big) J_{q\varepsilon}
$$
which is positive definite whenever $M(q)$ is positive definite on admissible directions and $J_{q\varepsilon}$ has full column rank. The remaining terms provide the transformed Coriolis and gravitational contributions in $\varepsilon$-coordinates. In this way, the dynamics on the lower-dimensional chart inherit the correct metric structure from the original configuration space.








Now also note that $N^\dagger J_c^T = 0$

I.e $N^\dagger$ is orthognal to the span of $J^T_c$ . Recall that $J_c^T \lambda$ was the generalized constraint force. Hence $N^\dagger$ is the projector of the covectors into the complement of the anhilator subspace. (i.e these covector do not excite the constraints). 

> It is critical to note that not exciting the contact forces doesn't mean we have no contact forces. It just means we are not adding any contact forces explicitly. Gravity and coriolis forces might still add constraint forces.



To get the constrained equations of motion, 

1. We project all our configuration vectors into the admissible space. However, even if these are admissible, the torques / covectors that generate them can still excite constraints. 
2. Thus, we also project all our torques into the complement of the anhilator space.

This yields
$$
N^\dagger M N \ddot{q} + N^\dagger(h) = N^\dagger \tau 
$$

where no force excites constraints and no displacements violates constraints. Essentially, it is as if constraints didn't exist (they are automatically satisfied)


we simply premultiply by $N^\dagger$. That means our genralized forces are now constrained within the complement of the anhilator and do not excite constraints.

However, our configuration can still violate constraints. For that we must project our configuration vectors in the admissible space.

Therefore two projections need to occur








# Constrained Dynamics Cheatsheet (Drake-style)

## Conventions / Assumptions
- Joint coords $q$, velocities $v = \dot q$, accelerations $\ddot q$.
- Dynamics:
  $$
  M(q)\,\ddot q + h(q,v) = \tau + J_c(q)^\top \lambda,
  \qquad h = C(q,v)\,v - g(q).
  $$
- Holonomic contact constraints:
  $$
  J_c(q)\,v = 0, \qquad
  J_c(q)\,\ddot q + \dot J_c(q,v)\,v = 0.
  $$
- $M$ is SPD, $J_c$ full row rank.
- $\lambda$ is the **wrench on the robot** (choose frames so $+z$ is "up").

---

## 1) Torque-level projector $P$
Define the **contact-space (constraint) matrix** and its inverse:
$$
A_c \;\triangleq\; J_c\,M^{-1}\,J_c^\top,
\qquad
\Lambda_c \;\triangleq\; A_c^{-1}.
$$

Then the torque-space projector onto the **feasible/contact-consistent** subspace is
$$
\boxed{P \;=\; I - J_c^\top\,\Lambda_c\,J_c\,M^{-1}.}
$$

**Properties:**
$$
J_c\,M^{-1}\,P = 0, \qquad P^2 = P.
$$

---

## 2) Contact reaction as a function of torque $\lambda(\tau)$
Eliminating $\ddot q$ from dynamics and constraints gives:
$$
\boxed{
\lambda(\tau)
= -\,\Lambda_c\!\Big(J_c\,M^{-1}(\tau - h) + \dot J_c\,v\Big)
= \Lambda_c\!\Big(J_c\,M^{-1}(h - \tau) - \dot J_c\,v\Big).
}
$$

**Special cases:**
- Static ($v = 0$):
  $$
  \lambda(\tau) = \Lambda_c\,J_c\,M^{-1}(h - \tau).
  $$
- Static gravity/Coriolis **with** contact-compatible torque $\tau = P\,h$:
  $$
  \lambda = \Lambda_c\,J_c\,M^{-1}h, \qquad \ddot q = 0.
  $$

---

## 3) Constraint (contact-space) matrix $A_c$
$$
\boxed{
A_c = J_c\,M^{-1}\,J_c^\top,
\qquad
\Lambda_c = A_c^{-1}.
}
$$

- $A_c$ maps contact wrenches to accelerations under a unit wrench.
- $\Lambda_c$ is the **contact-space inertia** (used in $P$ and $\lambda(\tau)$).

---

## 4) Full KKT system (coupled dynamics + constraints)
The coupled linear system for $(\ddot q, \lambda)$ given $\tau$ is:
$$
\boxed{
\begin{bmatrix}
M & -J_c^\top\\
J_c & 0
\end{bmatrix}
\begin{bmatrix}
\ddot q\\[2pt] \lambda
\end{bmatrix}
=
\begin{bmatrix}
\tau - h\\[2pt] -\,\dot J_c\,v
\end{bmatrix}.
}
$$

From this:
- Recover $\ddot q = M^{-1}(\tau - h - J_c^\top\lambda)$.
- Joint-space balance (first row rearranged):
  $$
  \boxed{\tau = M\,\ddot q + h - J_c^\top \lambda.}
  $$

---

## Sanity Checks
- **Projector test:** $\|J_c M^{-1} P\| \approx 0$
- **Static stance:** with $\ddot q = 0, \tau = P h, \lambda = \Lambda_c J_c M^{-1} h$
  $$
  \| M\ddot q + h - \tau - J_c^\top \lambda \| \approx 0.
  $$
- **Consistency from KKT:** solve KKT for $(\ddot q, \lambda)$ given $\tau$;
  both expressions above must agree.







# Appending / Past Notes



## Constrained Dualities
In a constrained system, let $V_c$ be the set of all admissible displacements. If constraints are given by $J_c(q)\delta q = 0$.
$$
V_c(q) = \{ \delta q \in V \ \vert \ J_c(q)\delta q = 0\}
$$

Any displacement that is inadmissible is orthogonal to this subspace. Since our inner product is defined by the Mass metric we express our inner product as a tensor product,

$$
\langle \delta q_\perp, \delta q_\parallel \rangle_M
=
M_{ij} \ \delta q_{\perp, i} \ \delta q_{\parallel, j} = 0 
$$
Note that we can divide $\delta q$ by $dt$ to get
$$
M_{ij} \ \dot{q}_{\perp, i} \ \dot{q}_{\parallel, j} = 0 
$$
This means there is a dual vector, $\flat(\ddot{q}_{\perp, i})$, that annhilates or maps any admissible vector to $0$.

The space of these covectors is is simply the mapping $\flat$ applied to all perpendicular configuration vectors, i.e $v_\perp \in V_{c, \perp}$

$$
V_c^\star(q) = \{ \alpha \in V^\star \ | \ \alpha(v) = 0, \ \forall v \in V_c(q)\} = \{ \flat(v) \ | \ v \in V_{c, \perp} \}
$$
Again, we can interpret the covectors in $V_c^\star$ as we want. So

if vector is position delta, and covector is torque, we have work duality. If vector is velocity and covector is torque, we have power duality.

Using $V_c^\star$ we define constraint forces. Any force that does 0 work in ALL admissible directions, must solely exist to enforce the constraints. Hence it is a constraint force.
$$
\delta W = \tau ( \delta q)
$$





## Random Snippet

Now note that all feasible velocities can be written as solutions of 
$$
J_c \dot{q}_c = 0
$$

define a projector $N_c$ that gives minimum norm projection onto the admissible velocity space. Thus for any $\dot{q}$ we have
$$
\dot{q}_c = N_c \dot{q}
$$
this gives a feasible velocity for any velocity $\dot{q}$. Now plugging into our constraints
$$
J_c N_c \dot{q} = 0 
$$
for all $\dot{q}$. Thus
$$
J_c N_c = 0
$$
This is a key result. This means $N_c$ projects onto the $kern(J_c)$ (also called the null-space)

The adjoint of Nc (i.e metric consistent transpose) is given by $N^\dagger$ defined by
$$
\langle N_c v , w \rangle_M = \langle v, N_c^\dagger w \rangle_M 
$$

In matrix form
$$
(N_c v)^\top M w = v^\top M N^\dagger w
$$
$$
v^\top N_c^\top M w = v^\top M N^\dagger w
$$
since this is true for all $v, w$, we get
$$
N_c^\top M = M N^\dagger
$$


$$
N^\dagger = M^{-1}N_c^\top M
$$
we say that $N_c$ is self adjoint if 
$$
N = N^\dagger = M^{-1}N_c^\top M
$$

when we derive $N_c$ , we don't impose the self-adjoint requirement, it comes out automatically.


Now we will find the torque projector. The idea is we want to project into the complement of the annihilator space (i.e space of torque's that don't excite the constraints).

Recall the the kernel of $J_c$ is the space of accelerations that are admissible. We need to find a space of torques which generates acceleration in the null space of $J_c$. Conversely, for every admissible acceleration $\ddot{q}_{\text{adm}}$
$$
\tau_{\text{adm}} = M\ddot{q}_{\text{adm}} = M P_a \ddot{q} = MP_a M^{-1} \tau
$$

we call $MP_aM^{-1}$ the torque projector which is self adjoint in the $M^{-1}$ metric.