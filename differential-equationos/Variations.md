



# Functionals

A functional takes a function as an input and assigns a real number as its output.

$$
J[y] = \int F(x, y, y', y'', \ldots) dx
$$

# Variations

Suppose the configuration space is some manifold M which could be finite dimensional or infinite dimensional.

A configuration is a point in this manifold, this could be $q$ if it is finite or a function $y$ if it's infinite.

A **perturbation** is a test. It is not the actual change, but a test change. It can be along any admissible direction. It can also coincide with the actual change.

e.g. the first variation of $f(q)$ checks how f changes if we change q in any admissible direction. even if q evolves as $q^*(t)$, we are free to test any admissible direction which may also coincide with $q^*(t)$.


We can pick an admissible perturbation as

$$
q_\epsilon = q + \epsilon \eta
$$

The first variation of a functional $F: Q \to \mathbb{R}$ , is defined as a directional derivative

$$
\delta F(q)[\eta] = \frac{d}{d \epsilon} F(q + \epsilon \eta) \Bigg|_{\epsilon=0}
$$

This is geometrically the slope of F along a tangent perturbation $\eta$.


The second variation is defined similarly,

$$
\delta ^2F(q)[\eta, \zeta] = \frac{d^2}{d \epsilon d \mu} F(q + \epsilon \eta + \mu \zeta) \Bigg|_{\epsilon=\mu=0}
$$
Now we are testing how the slope of F along the tangent $\eta$ change when moving along another direction $\zeta$. if $\zeta$ coincides with $\eta$, then we have the "curvature". 

> Some authors may include a factor of 1/2 in the second variation itself, but most textbooks keep 1/2 outside the second variation

Let us complete this picture by introducing the general directional taylor expansion. Now if we had actual displacement along a direction $h$, recall that the directional taylor series is given by
$$
F(q + h) = F(q) + DF(q)[h] + \frac12 DF(q)[h, h] + O(||h||^3)
$$

It's variational analog (i.e when instead of actual displacement, we use a test perturbation), we get

$$
F(q + h) = F(q) + \delta F(q)[h] + \frac12 \delta^2F(q)[h, h] + O(||h||^3)
$$


We can also represent $h = \sum_i \epsilon_i \eta^{(i)}$. This is used to track how the function changes if we move in each independent direction.

Plugging that into the single direction expansion gives mixed terms:

$$
F\left(q + \sum_i \epsilon_i \eta^{(i)} \right) 
=
F(q)
+
\delta F(q)\left[ \sum_i \epsilon_i \eta^{(i)}\right]
+
\frac12
\delta^2 F(q)
\left[ \sum_i \epsilon_i \eta^{(i)}, \sum_j \epsilon_j \eta^{(j)}\right]
+
O(||h||^3)
$$

Since $\delta F(q)$ is linear, and $\delta^2 F(q)$ is bilinear, we get

$$
F\left(q + \sum_i \epsilon_i \eta^{(i)} \right) 
=
F(q)
+
\sum_i \epsilon_i \delta F(q)\left[\eta^{(i)}\right]
+
\frac12
\sum_i \sum_j \epsilon_i \epsilon_j
\delta^2 F(q)
\left[\eta^{(i)}, \eta^{(j)}\right]
+
O(||h||^3)
$$

which is the general taylor expansion

Let us see an example where we use the concept of variations

## Principle of Virtual Work



Let q be a configuration of a system and $q \in R^n$.

If we want to find an equilibrium configuration $q*$, it must be that net work done by any external or internal force be zero for all admissible changes of configuration.

Consider any force $F_i$ and corresponding displacement be $r_i(q)$. This would capture the work done by moments too as the displacement due to the moments will be capture in $r_i$.

Thus, we get virtual work for a set of virtual displacements, $\{ \delta r_i: i \in \mathbb{N} \}$ for a configuration $q$ as
$$
\delta W = \sum_i F_i^T \delta r_i(q)
$$
For a choice of general coordinates, we get canonical generalized forces
$$
\delta W = \sum_i F_i^T \delta r_i(q)
$$
$$
\delta W = \sum_i F_i^T \left( \sum_j\frac{\partial r_i}{\partial q_j} \delta q_j \right)
$$
$$
\delta W = \sum_j \left( \sum_i F_i^T \frac{\partial r_i}{\partial q_j} \right) \delta q_j
$$

We have generalized forces
$$
Q_j := \sum_i F_i^T \frac{\partial r_i}{\partial q_j}
$$
Notice that $i$ was unbounded, in that we can have ten's of thousands of forces, but $Q_j$ is bounded in that there are as many forces as elements in $q$.

Notice that we can write a transform from basis to generalized coordinates in a matrix form

Thus, we can write

$$
\delta W = \sum_j Q_j \delta q_j = Q^T \delta q
$$

Now let the residual generalized force $R(q)$ be the result of all external and internal forces. If the system is in equilibrium then R(q) must be zero, otherwise there is a net force. Consider
$$
\delta W = R(q)^T \delta q
$$
if work $\delta W$ is zero for all admissible $\delta q$, then $R(q)$ is zero. If $R(q)$ is zero then $\delta W$ is zero for all admissible $\delta q$.

Note that if we consider reaction forces in the residual, then the corresponding constraint no longer applies. e.g. if we are constraint to move along x axis due to a normal force, then if we include the normal force in R, we are now free to use virtual displacements in y. If we don't include reaction forces, then virtual displacements are admissible only along x.

Internal forces refer to forces between parts of a system 'i.e between two links of a joint'. External forces are those by loads, gravity, tractions etc (but not reaction / constraint forces).

# Euler Lagrange Equation

We will now attempt to derive the formulation for a lagrangian. We start with an important theorem

## D'Alembert Principle
TODO

## Lagrangian


We can include dynamics into our forces by D'Alembert principle to obtain zero virtual work

$$
\sum_i(F_i - m_i \ddot{r_i})^T \delta r_i(q) = 0
$$
expanding

$$

\sum_j Q_j \delta q_j
=
\sum_i m_i \ddot{r_i}^T \sum_j \frac{\partial r_i(q)}{\partial q_j} \delta q_j
$$
$$
\sum_j Q_j \delta q_j
=
\sum_j \left(\sum_i m_i \ddot{r_i}^T \frac{\partial r_i(q)}{\partial q_j} \right) \delta q_j
$$

Since $\delta q_j$ is arbitrary, we have 

$$
Q_j = 
\sum_i m_i \ddot{r_i}^T \frac{\partial r_i(q)}{\partial q_j}
$$
Note the Q_j is sum of all types of forces conservative and non conservative.  (why?)


Now consider
$$
T = \frac12 \sum_i m_i \dot{r_i}^T \dot{r_i}
$$
And also consider
$$
\frac{d}{dt}\frac{\partial T}{\partial \dot{q}} - \frac{\partial T}{\partial q}
$$

This yields for a given $q_j$
$$
\frac{d}{dt} \sum_i m_i \ddot{r_i}^T \frac{\partial r_i}{\partial q_j}
$$

but this equals $Q_j$. Hence

$$
\frac{d}{dt}\frac{\partial T}{\partial \dot{q_j}} - \frac{\partial T}{\partial q_j} = Q_j
$$
This Q_j has both conservative and non conservative forces, we can split this

$$
\frac{d}{dt}\frac{\partial T}{\partial \dot{q_j}} - \frac{\partial T}{\partial q_j} = Q_j (\text{cons}) + Q_j(\text{non-cons})
$$

The conservative portion can be written as
$$
-\frac{\partial V}{\partial q_j}
$$

Thus
$$
\frac{d}{dt}\frac{\partial T}{\partial \dot{q_j}} - \frac{\partial T}{\partial q_j} - \left(-\frac{\partial V}{\partial q_j} \right) = Q_j(\text{non-cons})
$$

Noting that $\frac{\partial V}{\partial \dot{q}_j} = 0$, we can write
$$
\frac{d}{dt}\frac{\partial L}{\partial \dot{q_j}} - \frac{\partial L}{\partial q_j} = Q_j(\text{non-cons})
$$

which is the euler lagrange equatoin for $L = T - V$.

Essentially using D'Alembert principle and newtonian mechanics, we have derived lagrange's equation. 
