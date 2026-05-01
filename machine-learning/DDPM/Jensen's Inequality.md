
This is about how a curved function interacts with averaging.


## Intuition

For simplicity consider three equally spaced points. 
$$
1, 2, 3$$

Now let a concave function, something that curves up, be $f(x) = x^2$.

Note that the mean of our data is 2 and the square of that is 4.

If we square first and then take the mean, i.e take the mean of 1, 4, 9, we get ~ 4.66.

The idea is that since f curves upwards (is convex) and expectation is a linear function, there is always some positive error if we try to approximation $E[f(X)]$ using $f(E[X])$.


This is basically the idea behind jensen's equality.

A function $f$ is convex iff it lies above all its tangents:




Consider a distribution with expection $E[X]$.

I will reparametize each $X_i$ as $E[X] + a_i$. where the probability of sampling $a_i$ is same as that of sampling $X_i$. Also note that $E[a] = 0$.

Now,

$$
f(E[E[X] + a]) = f(E[X])
$$
Now also note
$$
E[f(E[X] + a)]
$$
if we take the taylor expansion of f about $E[X]$.

$$
f(E[X] + a) = f(E[X]) + f'(E[X])a + \frac{1}{2}f''(E[X])  a^2 + O(f''')
$$

Now taking the expection.
$$
E[f(E[X] + a)] = 
E\left[ f(E[X]) \right] 
+ 
E\left[f'(E[X])a \right] 
+ 
\frac{1}{2}E\left[f''(E[X])  a^2 \right]
+ O(f''')
$$

Since f is convex, $f'' \geq 0$, also note
$$
E[f(E[X])] = f(E[X])
$$
$$
E[a] = 0
$$
$$
E[a^2] \geq 0
$$
TODO we still need some way to bound the remainder :( but the higher order terms cannot change the sign of the main error, only nudge it a bit.

Hence we get something like 
$$
E(f(X)) \approx f(E[X]) + \frac12 f''(E[X])E(a^2) \geq f(E[X])
$$
