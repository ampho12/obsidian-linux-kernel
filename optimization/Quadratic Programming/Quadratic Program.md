
# Unconstrained
A quadratic program is of the following form
$$
\min_x \frac12 Q_{ij}x^ix^j + c_ix^i
$$

We can differentiate this w.r.t $x^k$.
$$
\frac12 Q_{ij}\frac{dx^i}{dx^k}x^j 
+
\frac12 Q_{ij}x^i\frac{dx^j}{dx^k}
+ 
c_i \frac{dx^i}{dx^k}
$$


Using 
$$
\frac12 Q_{ij}\delta^i_k x^j 
+
\frac12 Q_{ij}x^i\delta^j_k
+ 
c_i \delta^i_k
$$

We get
$$
\frac12 Q_{kj}x^j 
+
\frac12 Q_{ik}x^i
+ 
c_k
= 0
$$
In matrix vector form
$$
Qx + c = 0
$$
