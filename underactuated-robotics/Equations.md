

We have some definitions

# Configuration Vector

This is the generalized coordinate vector $\vec{q}$. We will now use $\textbf{q}$


# Control Vector

Any input that we apply, $\textbf{u}$.

# State Vector

We define a state vector 
$$
\textbf{x} = (\textbf{q}, \dot{\textbf{q}})
$$
## Underactuated vs Fully Actuated

The general form of a second-order control dynamical system. 

$$
\ddot{\textbf{q}} = \textbf{f}(\textbf{q}, \dot{\textbf{q}}, \textbf{u}, t)
$$

We can rewrite our  equatoin as 
$$
\textbf{q} = \textbf{f}(\textbf{x}, \textbf{u}, t)
$$

At a given state $\textbf{x}$ and time time $t$, if our map

$$
\ddot{\textbf{q}} = \textbf{f}(\textbf{x}, \textbf{u}, t)
$$
is surjective, then for every $\ddot{\textbf{q}}$ there exists a control vector $\textbf{u}$ that produces the desired response $\ddot{\textbf{q}}$ 

If for a given state and time pair, $\textbf{f}$ is not surjective, then we are underactuated in this space-time.

If the system is underactuated for all $q$ and $\dot{q}$, then the system is called underactuated.


### Key Idea

A system enters an underactuated regime. If all regimes are underactuated, the system is called underactuated. E.g. if you enter a singularity, then we lose a dof and our system becomes underactuated (e.g radial acceleration of a two link arm when the arm is fully stretched out is always 0).



## Affine form

For many robots, we can write $\textbf{f}$ as an affine function in u for a given state and time.
$$
\ddot{\textbf{q}} = 
\textbf{f}_1(\textbf{x}, t)
+
\textbf{f}_2(\textbf{x},  t)\textbf{u},
$$


If 
$$
\textbf{f}_2(\textbf{x},  t)\textbf{u},
$$
is a matrix and is full rank, then we have shown that $\textbf{f}$ is surjective and our system is fully actuated. If the rank is less than full, then we are underactuated.



## Controllability vs Actuated

> Controllability means whether you can achieve a goal or not. It might take a long time but it will happen eventually

> Fully actuated means if you can instantly reach desired acceleration






## Dyanamics


The non-linear dynamics equation
$$
\dot{x} = f(x, u)
$$


$$
\ddot{q} = f(\dot{q}, q, u)
$$


$$
y = g(x)
$$