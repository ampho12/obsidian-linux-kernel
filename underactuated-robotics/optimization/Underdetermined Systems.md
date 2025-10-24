
An under-determined system has fewer equations than unknowns. Alas, there are infinitely many solutions.

For now, consider

$$
Ax = b
$$
How do we choose one solution? Usually, there are two ways

1. Regularize by adding $I \epsilon$ and solve a relaxed system $\left(A + I\epsilon\right)x = b$
2. Make an optimization problem as shown below
minimize
$$
\frac12 xWx^\top
$$
under constraint $Ax = b$.

putting the constraints in the lagrangian, we get

$$
\mathcal{L}(x, \nu) = 
\frac12 xWx^\top + \nu^\top(Ax - b)
$$

differentiating w.r.t x

$$
Wx + A^\top \nu = 0 \implies x = -W^{-1}A^\top\nu
$$

from the constraint,
$$
Ax = b \implies AW^{-1}A^\top\nu = -b
$$

This equation may also not be fully determined, depending on $W^{-1}$, but if so we simply try again using regularization for this equation.

we define 
$$\Lambda = 
\left( 
A W^{-1}A^\top 
\right)
$$
and $\Lambda_\epsilon = \Lambda + I\epsilon$ if regularization is needed. We define $\Lambda^+ = \Lambda_\epsilon^{-1}$

finally we get $\nu = -A^+b$

plugging back into 
$$
x = -W^{-1}A^\top\nu
$$
$$
x = W^{-1}A^\top A^+b
$$
# Projection

Notice that underdetermined systems have general solutions of the form
$$
x = x_p + \mathcal{N}(A)
$$
where $x_p$ is a particular solution and $\mathcal{N}(\cdot)$ specifies the nullspace of A.

We define 
$$
x = x_p + N_c(v - x_p)
$$

where $v$ is any vector from which we want to project 

Using the optimization or regularization based methods, we can find a particular solution $x_p$
$$
x_p = W^{-1}A^\top A^+b
$$
Now notice

$$
x - x_p \in \mathcal{N}(A)
$$
For any vector $x$ that satisfies


$$
x = W^{-1}A^\top A^+b + N_Ay
$$

Not that $Ax = b$,
$$
x = W^{-1}A^\top A^+Ax + N_Ay
$$
i.e
$$
\left( I - W^{-1}A^\top A^+A \right)x =  N_Ay
$$


