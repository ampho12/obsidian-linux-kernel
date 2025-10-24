The idea behind optimization is to use an objective to produce a constraint that further narrows our search space for the optimal point.
# Duality

## Primal
In general, an optimization problem is minimize $f(x)$ subject to constraints 
$$
h(x) = 0
$$
$$
g(x) \le 0
$$

We call this the **Primal** problem. We can rewrite this using lagrange multipliers

$$
L(x, \lambda, \nu) = f(x) + \lambda^\top h(x) + \nu^\top g(x)
$$

where $\nu \ge 0$ and $\lambda, \nu \in \mathbb{R}$.

We will show the geometric and analytical intuition behind this
### Analytical

Consider the minimization problem
$$
p^* = \inf_x \left( \sup_{\nu \ge 0, \lambda} \mathcal{L}(x, \lambda, \nu) \right)
$$

> Even without the parenthesis, the infinimum is taken after the supremum.

The idea is that if constraints are not satisfied, that is either $g(x) > 0$ or $h(x) \neq 0$, then we can turn $\lambda \to \infty$ and or $\nu \to \infty$

This makes the supremum term go to infinity irrespective of $x$, so the outer infinimum must also tend to $\infty$. Thus x must be feasible, in which case,

$h(x) = 0$ and $\lambda$ doesn't matter
$g(x) \le 0$, and thus $\nu = 0$ for inner supremum.

i.e for feasible $x$,
$$
\sup_{\nu \ge 0, \lambda} \mathcal{L}(x, \lambda, \nu) = f(x)
$$
and
$$
\inf_x \sup_{\nu \ge 0, \lambda} \mathcal{L}(x, \lambda, \nu) = \inf_x f(x)
$$
which is the original problem. 

### Geometric
> TODO

## Dual

The dual problem is simply flipping the supremum and infinimum to get a maximization problem
$$
\sup_{\nu \ge 0, \lambda} \left( \inf_x \mathcal{L}(x, \lambda, \nu) \right)
$$

### Weak Duality (Dual <= Primal)
Notice that, for any primal feasible $x$, $g(x) \le 0$ and $h(x) = 0$. Thus, for all dual feasible $\lambda$ and $\nu \ge 0$, 
$$
\mathcal{L}(x, \lambda, \nu) \le f(x)
$$

We can take the $\inf_x$ over both sides. This x must be feasible as we have shown in the primal case
$$
\inf_x \mathcal{L}(x, \lambda, \nu) \le \inf_x f(x)
$$
Thus we get 
$$
\sup_{\nu \ge 0, \lambda} \inf_x \mathcal{L}(x, \lambda, \nu) \le \inf_x f(x)
$$

> Notice how the dual is a maximization problem


where the RHS is the primal infinimum

$$
\sup_{\nu \ge 0, \lambda} \inf_x \mathcal{L}(x, \lambda, \nu)
\le
\inf_x\sup_{\nu \ge 0, \lambda} \mathcal{L}(x, \lambda, \nu)
$$
### Strong Duality (Dual == Primal)

Note that a finite primal infinimum ($x^*$ ) may not exist (tend to either positive or negative infinity). Similarly, a the dual supremum $\lambda^*, \nu^*$ may not be finite.

To guarantee they are both finite, we need 

1. Convexity: $f, g$ are conves and $h$ is affine
2. Slater's condition: $\exists \bar{x}$ s.t $g(\bar{x}) < 0$ and $h(\bar{x}) = 0$

these guarantee that a finite saddle point will exist where supremum of the dual and the infimum of the primal will meet.

At the saddle point the following conditions hold

1. Zero duality gap
2. Finite saddle point


## Conditions for Optimality
### Karush-Kuhn-Tucker Conditions

The KKT conditions are a set of first-order optimality equations for a constrained optimization problem.

> TODO
> 1. What is a first-order optimality equation

* primal feasibility $g(x^\star)\le 0,\ h(x^\star)=0$
* dual feasibility $\lambda^\star\ge 0$
* stationarity $\nabla_x \mathcal L(x^\star,\lambda^\star,\nu^\star)=0$
* complementary slackness $\lambda_i^\star g_i(x^\star)=0$.

## Slater's Condition

Strict feasibility

## Constraint Qualifications (CQ)

> TODO


# Conditions Summary

|                                                                              | **Convex** (f, gᵢ convex; h affine)                                                                                                                                                                                              | **Non-convex**                                                                                                                                                                    |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **KKT without CQ**                                                           | • May **fail to exist** even at an optimal point (dual unattained, multipliers unbounded).<br>• Optimality can hold **without** any KKT multipliers.<br>• No guarantee of **saddle point** or **strong duality**.                | • KKT may hold at some points, but gives **no guarantee** at local minima; can fail to exist.<br>• Even if satisfied, they’re **not sufficient**; no global saddle/duality claim. |
| **KKT with CQ** (e.g., LICQ/MFCQ/Abadie; for convex often Slater or similar) | • **Necessary & sufficient** for optimality (together with convexity).<br>• Existence of finite multipliers ⇒ **saddle point** and **strong duality** (p*=d*).<br>• Complementary slackness pins **active constraints**.         | • **Necessary** at **local minima** only (first-order).<br>• **Not sufficient** (need 2nd-order conditions).<br>• No guarantee of global saddle point or zero duality gap.        |
| **Slater** (strict feasibility)                                              | • Guarantees **strong duality** and **dual attainment** (finite λ*, ν*).<br>• Ensures **existence of KKT multipliers** for any primal minimizer.<br>• Helps bound multipliers; with primal attainment ⇒ **saddle point exists**. | • Not applicable as a sufficiency notion for non-convex programs; strict feasibility **doesn’t** imply strong duality, saddle points, or KKT sufficiency.                         |

quick takeaways:

* **Convex + CQ/Slater:** KKT ⇔ saddle ⇔ optimality, with strong duality and finite multipliers.
* **Convex without CQ:** can have an optimum **without** KKT or saddle; dual may be unattained.
* **Non-convex:** KKT (with a CQ) are **necessary local** conditions only; you need 2nd-order tests for sufficiency, and duality/saddle claims generally fail.
