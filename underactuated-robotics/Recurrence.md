

# Autapase

Consider a system given by


$$
\dot{x} = -x + \tanh(2x + u)
$$

Recall the graph of $\tanh(2x)$ and how it asymptotes



![[Pasted image 20250921164238.png]]

Now add a $-x$ bias to this

![[Pasted image 20250921164304.png]]


Now look at the state space.

For $u=0$, we have two stable points, one roughly at $-1$ and one at $1$. This means the system will tend to one of these points.

> $x = 0$ is stable but it will move as soon as a little perturbation occurs

Now, if we apply a control input $1$, we moved our red function to the blue function. Now there is only a single stable point at $\approx 1$. The system will eventually reach that. Now if you move your control input back to $0$, the system will still stay close to $1$ . This is like a latching state behavior.


This can be used as concept of memory as we will see later. Another note is that in general, we use

$$
\tanh(wx + u)
$$

which is like an activation function applied to a perceptron output. This is used in RNNs like LSTMS and JANETs


## Leakage

Leakage is pulling to initial state (likely) which is 0 in our case 


## Forgetting

Forgetting means to remove any bias and set To do this, we need a way to make 0 the new stable point. In this case, we would have to make the graph converge to that of $-x$ .

Let's start with a simple attempt

$$
\dot{x} = -(f - 1 - \alpha f)x + (1 - f)\tanh(wx + u)
$$


Note that if $f \to 0$, then our $\dot{x} \to -x$, and if $f \to 0$, then $\dot{x} \to -x + \tanh(wx + u)$.

We can use $f = \sigma(w_f x + u_f)$



Let's consider the autapse again

![[Pasted image 20250921173021.png]]




Now f is dialed to 0, let's dial it to closer to 1

![[Pasted image 20250921173135.png]]

at f = 1

![[Pasted image 20250921173155.png]]

we are flat, i.e all states are stable. If we add a leakage, we can start resetting it to zero

![[Pasted image 20250921173230.png]]

notice that leakage also changes the stability points in case of partial forgetting

![[Pasted image 20250921173335.png]]