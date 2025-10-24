
In dynamics, generalized positions, velocities and accelerations all live in the same vector space called configuration space. The same vector can be a position, velocity or accel, depending on interpretation.

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



## Constrained Equations

The standard dynamics equations can be written as

$$
M(q)\ddot{q} + C(q, \dot{q})\dot{q} + \tau_g = \tau
$$

where the rightmost term is all non-conservative forces and $\tau_g$ are conservative forces. Derivation can be found in [[Controls]].


Now we know that if we have holonomic constriants $\phi(q) = c$, then we have constraint jacobian
$$
J_c \delta q = 0
$$

the constraints can be put into the main equation using the lagrangian derivation
$$
M(q)\ddot{q} + C(q, \dot{q})\dot{q} + \tau_g = \tau + J_c^\top \lambda
$$


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


## TODO: add variable transform q = q(\eps)








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








