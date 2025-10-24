




# Lyapunov Stability

Consider the system $\dot{x}=f(x)$ with equilibrium $x^\star$ (i.e., $f(x^\star)=0$).
We say that $x^\star$ is \emph{(Lyapunov) stable} if

$$
\forall\,\varepsilon>0\;\; \exists\,\delta=\delta(\varepsilon)>0
\;\;\text{such that}\;\;
\|x(0)-x^\star\|<\delta \;\Rightarrow\; \|x(t)-x^\star\|<\varepsilon
\quad \forall\, t\ge 0.
$$

That is,
Say we want to bound that our system never leaves some $\epsilon$ Neighborhood in state space.


if for every $\epsilon \ge 0$, we have a bound 
$$
|| x(t) - x^*|| \leq \epsilon
$$

which says that the system stays within this bound forever.

We claim that for every such $\epsilon$ there is a $\delta(\epsilon) \ge 0$ such that the system must have started out within the $\delta$ neighborhood 

$$
||x(0) - x^*|| \leq \delta(\epsilon)
$$

Another way to look at lyapunov is to define an Energy-like function $V(q)$. It must be

1. Positive semidefinite $V(q) \ge 0$.
2. zero only at equilibirium regions $$V(q) = 0 <=> q \in \text{Stability Region}$$



Let the system be given by $\dot{q} = f(q)$.

then if we have $\frac{dV}{dt} \le 0$ for all system trajectories (i.e)

$$
\frac{dV}{dt} = \frac{\partial V}{\partial q} \cdot \frac{dq}{dt}
$$
for system trajectories, $\frac{dq}{dt} = \dot{q} = f(q)$
$$
\frac{dV}{dt}(q) = \frac{\partial V}{\partial q} f(q)
$$

This essentially says that at every state $q$, the lyapynov is being minimized automatically by the system dynamics. 


# Attractive Stability

The system converges to a point


# Asymptotic 




