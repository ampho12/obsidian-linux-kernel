
# From Pairwise Interactions to Transformers

A constructive derivation of the transformer attention block, starting from the most general pairwise operation and arriving at the standard architecture through a sequence of efficiency-motivated factoring choices.

---

## Level 1: General Pairwise Interaction

For each position $i$ in a sequence, compute an output by considering all pairwise interactions:

$$
\text{output}_i = \sum_j \text{score}(x_i, x_j) \cdot \text{combine}(x_i, x_j)
$$

Every pair of positions produces a scalar score and a vector. The output at each position is the score-weighted sum of these vectors. This is maximally expressive but computationally expensive — both the score function and the combination function are arbitrary.

---

## Level 2: Bilinear Score, Linear Combination

Factor the pairwise operation into efficient components:

**Score:** Replace the general score function with a bilinear form:

$$
\text{score}(x_i, x_j) = \text{softmax}_j\left( x_i^\top W_s \, x_j \right)
$$

**Combination:** Replace the general combination function with a linear mixture:

$$
\text{combine}(x_i, x_j) = W_1 x_i + W_2 x_j
$$

**Nonlinearity:** Defer all nonlinear processing to a feedforward network (FFN) applied after the summation.

The output at position $i$ becomes:

$$
\text{output}_i = \sum_j \text{score}(i,j) \cdot \left( W_1 x_i + W_2 x_j \right)
$$

---

## Level 3: Recovering the Transformer

Make two specific parameter choices and one factoring decision.

**Notation.** We distinguish weight matrices $W_Q, W_K, W_V, W_O$ from the projected vectors they produce. Given input $x_i$, the projections are $q_i = W_Q x_i$, $k_i = W_K x_i$, $v_i = W_V x_i$. In standard usage, $Q, K, V$ refer to the matrices of all projected vectors (i.e. $Q = XW_Q$), not to the weight matrices themselves.

### Step 1: Set $W_1 = I$

$$
\sum_j \text{score}(i,j) \cdot \left( x_i + W_2 x_j \right)
$$

Since $x_i$ does not depend on $j$, and the softmax scores sum to one:

$$
= x_i + \sum_j \text{score}(i,j) \cdot W_2 x_j
$$

The residual connection emerges naturally — it is not an ad hoc training trick, but a direct consequence of setting $W_1 = I$ in the pairwise combination.

### Step 2: Set $W_2 = W_O \cdot W_V$

$$
= x_i + W_O \sum_j \text{score}(i,j) \cdot W_V x_j
$$

This gives the value projection $W_V$ applied inside the sum (producing $v_j = W_V x_j$), and the output projection $W_O$ applied outside.

### Step 3: Factor the score through $W_Q$ and $W_K$

Replace the full bilinear score $x_i^\top W_s \, x_j$ with a low-rank factorization through separate query and key projections:

$$
\text{score}(i,j) = \text{softmax}_j\!\left( \frac{(W_Q x_i)^\top (W_K x_j)}{\sqrt{d}} \right) = \text{softmax}_j\!\left( \frac{q_i^\top k_j}{\sqrt{d}} \right)
$$

This is a rank-bottlenecked bilinear form — instead of a full $d_{\text{model}} \times d_{\text{model}}$ matrix $W_s$, the interaction passes through a $d_{\text{head}}$-dimensional bottleneck, which is much cheaper.

### Result: Single-Head Attention with Residual

Combining all three choices:

$$
a_i = x_i \;+\; W_O \sum_j \text{softmax}_j\!\left( \frac{q_i^\top k_j}{\sqrt{d}} \right) v_j
$$

where $q_i = W_Q x_i$, $k_j = W_K x_j$, $v_j = W_V x_j$. This is exactly the standard single-head self-attention with residual connection.

### Step 4: Apply FFN

The nonlinearity deferred from Level 2 is realized as a feedforward network with its own residual connection:

$$
x_i' = a_i + \text{FFN}(a_i)
$$

where $\text{FFN}(x) = \text{ReLU}(x W_{\text{ff1}} + b_1) W_{\text{ff2}} + b_2$ with a hidden dimension typically $4 \times d_{\text{model}}$.

This completes one transformer block. The output $x_i'$ is fed into the next block.

---

## Multi-Head Attention

Rather than running a single pairwise interaction, run $H$ independent heads in parallel, each with its own $W_Q^h, W_K^h, W_V^h$ projecting from $d_{\text{model}}$ to $d_{\text{head}}$:

$$
\text{head}_h = \sum_j \text{softmax}_j\!\left( \frac{(W_Q^h x_i)^\top (W_K^h x_j)}{\sqrt{d_{\text{head}}}} \right) W_V^h x_j
$$

Concatenate all heads and apply a single output projection:

$$
a_i = x_i \;+\; W_O \begin{bmatrix} \text{head}_1 \\ \text{head}_2 \\ \vdots \\ \text{head}_H \end{bmatrix}
$$

where $W_O \in \mathbb{R}^{d_{\text{model}} \times (H \cdot d_{\text{head}})}$ maps the concatenated heads back to $d_{\text{model}}$.

In the pairwise framework:

- $W_1 = I$ still (same residual story)
- $W_2 = W_O \cdot [W_V^1; W_V^2; \ldots; W_V^H]$, but each $W_V^h$ operates within its own head's attention pattern
- The score is factored independently per head, each through its own low-rank $W_Q^h, W_K^h$ bottleneck

Each head learns a different pairwise interaction pattern, and $W_O$ learns how to recombine them.

---

## Cross-Attention

In an encoder–decoder transformer, the decoder must attend to a *different* sequence (the encoder output) rather than to itself. Let $y$ denote the decoder sequence and $z$ denote the encoder output. The standard cross-attention formulas are [1][2][3]:

$$
q_i = W_Q \, y_i, \quad k_j = W_K \, z_j, \quad v_j = W_V \, z_j
$$

$$
\text{CrossAttn}(y_i, z) = W_O \sum_j \text{softmax}_j\!\left( \frac{q_i^\top k_j}{\sqrt{d}} \right) v_j
$$

with a residual connection around the sub-layer [1]:

$$
a_i = y_i + \text{CrossAttn}(y_i, z)
$$

### Derivation from the Pairwise Framework

The pairwise interaction is now between two different sequences:

$$
\sum_j \text{score}(y_i, z_j) \cdot \left( W_1 \, y_i + W_2 \, z_j \right)
$$

The same factoring choices apply:

**Set $W_1 = I$:**

$$
\sum_j \text{score}(y_i, z_j) \cdot y_i \;+\; \sum_j \text{score}(y_i, z_j) \cdot W_2 \, z_j
$$

Since $y_i$ does not depend on $j$ and scores sum to one:

$$
= y_i + \sum_j \text{score}(y_i, z_j) \cdot W_2 \, z_j
$$

**Set $W_2 = W_O \cdot W_V$:**

$$
= y_i + W_O \sum_j \text{score}(y_i, z_j) \cdot W_V \, z_j
$$

**Factor the score through $W_Q$ and $W_K$:**

$$
a_i = y_i \;+\; W_O \sum_j \text{softmax}_j\!\left( \frac{(W_Q \, y_i)^\top (W_K \, z_j)}{\sqrt{d}} \right) W_V \, z_j
$$

This matches the standard cross-attention formula with residual. The algebraic structure is identical to self-attention — the only difference is that $W_Q$ projects from the decoder sequence while $W_K$ and $W_V$ project from the encoder sequence. The $W_1 = I$ residual still falls out because $y_i$ does not depend on the summation index $j$.

---

## Summary of Design Choices

| Component | General Form (Level 2) | Transformer Choice (Level 3) |
|---|---|---|
| $W_1$ (self term) | Learned matrix | $I$ (identity) → gives residual |
| $W_2$ (context term) | Learned matrix | $W_O \cdot W_V$ → value + output projection |
| Score | Full bilinear $x_i^\top W_s x_j$ | Low-rank via $W_Q, W_K$: $q_i^\top k_j/\sqrt{d}$ |
| Nonlinearity | Inside the pairwise op | Deferred to FFN after summation |

The framework applies uniformly to self-attention (both inputs from the same sequence) and cross-attention (query from decoder, keys/values from encoder).

---

## Architectures Where $W_1 \neq I$

The transformer's choice of $W_1 = I$ is not universal. Other architectures keep $W_1$ as a learned parameter:

| Architecture | $W_1$ | $W_2$ | Note |
|---|---|---|---|
| **Standard Transformer** | $I$ | $W_O \cdot W_V$ | Residual from identity |
| **GAT** [5] | $a_1^\top W$ | $a_2^\top W$ | Same $W$ both sides (static attention) |
| **GATv2** [6] | $W_l$ | $W_r$ | Independent projections (dynamic attention) |
| **GLU Attention** [7] | Gated / nonlinear | $W_O \cdot W_V$ | Learned gate on self term |

The GAT → GATv2 fix is precisely about making $W_1$ and $W_2$ independent so that the attention ranking can depend on the query node.

---

## Further Variants

Several other attention variants fit the framework with minimal or no modification:

**Causal (masked) self-attention.** The summation is restricted to $j \leq i$, but softmax is applied over the unmasked set, so scores still sum to one. The $W_1 = I$ residual is unaffected — only the $W_2$ term's summation range changes.

**Multi-query attention (MQA) and grouped-query attention (GQA).** All heads share a single $W_K, W_V$ (MQA) or heads are grouped with shared $W_K^g, W_V^g$ per group (GQA). These are parameter-tying constraints on general multi-head attention. The pairwise structure and residual derivation are unchanged.

**Linear attention (normalized).** Softmax is replaced by a kernel: $\text{score}(i,j) = \phi(q_i)^\top \phi(k_j) / \sum_l \phi(q_i)^\top \phi(k_l)$. Scores still sum to one, so $W_1 = I$ gives the residual as before. The only change is computational — the kernel factorization enables reordering from $(\phi(Q)\phi(K)^\top)V$ to $\phi(Q)(\phi(K)^\top V)$, reducing complexity from $O(N^2 d)$ to $O(Nd^2)$.

**Linear attention (unnormalized).** Some variants drop the denominator, so scores no longer sum to one. The pairwise structure still holds, but the residual must be added externally rather than derived from $W_1 = I$.

**Relative position encodings (RoPE, ALiBi).** These modify the score function (rotating $q_i, k_j$ or adding a position-dependent bias) but leave the combination side untouched. The $W_1 = I$ residual is unaffected.

---

## References

[1] Vaswani, A., Shazeer, N., Parmar, N., Uszkoreit, J., Jones, L., Gomez, A. N., Kaiser, L., & Polosukhin, I. (2017). *Attention Is All You Need.* Advances in Neural Information Processing Systems, 30. https://arxiv.org/abs/1706.03762 — Defines scaled dot-product attention as $\text{Attention}(Q,K,V) = \text{softmax}(QK^\top / \sqrt{d_k})\,V$, with residual connections around each sub-layer and the encoder–decoder cross-attention mechanism (Section 3.1, 3.2.3).

[2] Brenndoerfer, M. (2025). *Cross-Attention: Connecting Encoder and Decoder in Transformers.* https://mbrenndoerfer.com/writing/cross-attention-encoder-decoder-transformers — Gives the explicit cross-attention formulas: $Q = X_{\text{dec}} W^Q$, $K = X_{\text{enc}} W^K$, $V = X_{\text{enc}} W^V$, with residual connections around the sub-layer.

[3] Jurafsky, D. & Martin, J. H. (2025). *Speech and Language Processing* (3rd ed. draft), Chapter 10. https://web.stanford.edu/~jurafsky/slp3/ — Describes the encoder–decoder architecture where the final encoder output $H_{\text{enc}}$ provides the $K$ and $V$ inputs to the cross-attention layer in each decoder block.

[4] Wikipedia. *Transformer (deep learning).* https://en.wikipedia.org/wiki/Transformer_(deep_learning) — Notes that each decoder layer contains cross-attention for incorporating encoder output and self-attention for mixing decoder tokens, both with residual connections and layer normalization.

[5] Veličković, P., Cucurull, G., Casanova, A., Romero, A., Liò, P., & Bengio, Y. (2018). *Graph Attention Networks.* ICLR 2018. https://arxiv.org/abs/1710.10903

[6] Brody, S., Alon, U., & Yahav, E. (2022). *How Attentive are Graph Attention Networks?* ICLR 2022. https://arxiv.org/abs/2105.14491 — Shows that GAT uses static attention (ranking unconditioned on query) and introduces GATv2 with separate $W_l, W_r$ projections for dynamic attention.

[7] Shazeer, N. (2020). *GLU Variants Improve Transformer.* https://arxiv.org/abs/2002.05202
