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

The idea is that if constraints are not satisfied, that is either $g(x) > 0$ or $h(x) \neq 0$, then we can turn $\lambda \to \pm \infty$ and or $\nu \to \infty$ to make the corresponding constraint (i.e $\lambda h(x)$ or $\nu g(x)$) tend to $\infty$.

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


# Geometric Interpretation of Lagrangian, Dual, and Primal


Let's consider just inequality constraints. Equality constraints can be distributed into two inequality constraints.

So our problem is 
$$
\inf_{x} \{ f(x) : g(x) \leq 0 \}
$$
Let's take the lagrangian
$$
\mathcal{L(x, \nu)} = f(x) + \nu g(x)
$$

Let's look at what the lagrangian is when we look at points in.
$$
\mathcal{G} = \{(g(x), f(x) )\}
$$

We can interpret the lagrangian as a function that gives y intercepts (along the f(x) axis). For a choice of x and $\nu$, where $\nu \geq 0$ and $-\nu$ is the slope of the line.

Why?, let points in $\mathcal{G}$ be a function of $\nu, \mathcal{L}$
$$
f(x) = \mathcal{L} - \nu g(x)
$$

On the $g(x)-f(x)$ plane, this is like defining each point using a slope $-\nu$ and an intercept $\mathcal{L}$. Not all $\mathcal{L}$ and $-\nu$ would work though. This is okay for us.

Now lets look at what the Primal Means
$$
\inf_x \sup_{\nu \geq 0} f(x) + \nu g(x)
$$

The way to interpret this is as follows
1. Outer gives a particular $x$
2. Inner evaluates the supremum for that $x$ and returns it.
3. Outer takes the min over all returned values.

```python
def infsup(L):
    final = infty
    for x in X:
        ret = max([L(x, nu) for all nu >= 0])
        final = min(final, ret)
    return final
```

If we focus on reach returned value by the inner supremum, we are asking given $x$ and a non-positive slope, what's the maximum y intercept? This is essentially
1. $f(x)$ for all $x \leq 0$
2. $\infty$ for all $x > 0$

If we plot this, we get:
![[primal.png]]

Now same for dual
$$
\sup_{\nu \geq 0} 
\inf_x 
f(x) + \nu g(x)
$$

The way to interpret this is as follows
1. Outer gives a particular slope $\nu$
2. Inner evaluates x such that we have the smallest intercept on y axis in $\mathcal{G}$
3. Outer takes the max over all returned values.

```python
def infsup(L):
    final = -infty
    for all nu:
        ret = min([L(x, nu) for x in X])
        final = max(final, ret)
    return final
```

If we focus on reach returned value by the inner infimum, we are asking "given a slope $\nu$, what's the smallest intercept we can achieve by altering x"? 

To visualize this, we first map our negative slope $-\nu$ to an angle, note the this angle can be $-90 \leq \theta \leq 0$

For each angle, we need an intercept which we obtain by choosing x. We choose x by starting with a vertical line and the leftmost $g(x)$. We pivot our line about this $g(x), f(x)$. At all points it intersects the y axis, we have our required y intercept for this angle. 

As soon as the line intersects with another point, we change our pivot to that point. This will look something like:

![[dual.png]]

If we overlay the two plots,

![[overlay.png]]

We see that the y intercepts of the primal are larger than the y intercepts of the dual for all $x$. This gives some visual backing to weak duality.


Now consider that if the primal solution at $g(x^*) = 0$ is $f(x^*) = p^*$, then we may have the following:

![[overlay0.png]]

We see that the "hull" has changed. Also, choose any slope that passes through the point $(0, p^*)$. Let's call it $\nu^*$.
$$
\mathcal{L}(x, \nu) 
\geq \mathcal{L}(x^*, \nu^*)
$$

Take "sup-inf", i.e

$$
\sup_{\nu \geq 0} 
\inf_x 
\mathcal{L}(x, \nu)
\geq 
\sup_{\nu \geq 0} 
\inf_x 
\mathcal{L}(x^*, \nu^*)
$$

The LHS is the dual, the rhs is simply 
$$
\mathcal{L}(x^*, \nu^*)
=
f(x^*) + \nu^* g(x)
= p^*
$$
i.e the dual is $\geq p^*$. But generally dual $\leq p^*$ by weak duality. Hence, $p^* = d^*$ (strong duality).

The way we reached strong duality, we needed the primal solution to be part of the "hull" in the dual. This is guarenteed by two conditions

1. Some convexity constraints on g, h, etc
2. Slaters conditions.

### Weak Duality (Dual <= Primal)

Note that we have lagrange multipliers $\nu \geq 0$ and $\lambda$. For any primal feasible $x$, $g(x) \le 0$ and $h(x) = 0$, i.e
$$
\mathcal{L}(x, \lambda, \nu) \le f(x)
$$

We can take the $\inf_x$ over both sides.
$$
\inf_x \mathcal{L}(x, \lambda, \nu) \le \inf_x f(x)
$$
We can also take the supremum over the lagrange multipliers. 
$$
\sup_{\nu \ge 0, \lambda} \inf_x \mathcal{L}(x, \lambda, \nu) \le \inf_x f(x)
$$


The RHS is the primal infimum

$$
\sup_{\nu \ge 0, \lambda} \inf_x \mathcal{L}(x, \lambda, \nu)
\le
\inf_x\sup_{\nu \ge 0, \lambda} \mathcal{L}(x, \lambda, \nu)
$$

This gap ( dual <= primal) is called the duality gap.

> Notice how the dual is a maximization problem
### Strong Duality (Dual == Primal)

Note that a finite primal infimum ($x^*$ ) may not exist 
1. If problem is unbounded below, we get $-\infty$.
2. If feasible set is empty ,we get $+\infty$.

If primal infimum is finite, then dual supremum is bounded by the primal infimum. Dual supremum can reach $-\infty$ if the dual function is $-\infty$ everywhere.


To guarantee they are both finite, we need 
1. Primal problem is bounded below: i.e is convex
2. 

2. Convexity: $f, g$ are conves and $h$ is affine
3. Slater's condition: $\exists \bar{x}$ s.t $g(\bar{x}) < 0$ and $h(\bar{x}) = 0$

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
