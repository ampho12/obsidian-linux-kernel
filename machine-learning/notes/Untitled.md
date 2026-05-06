
# Why Normalization Works: Study Notes

## 1. The Core Question

If a sufficiently flexible next layer can learn any transformation, why do we explicitly normalize before feeding it inputs? Why not just let the next layer learn the normalization implicitly?

Short answer: **expressivity ≠ trainability**. A network _could_ learn to normalize its inputs, but with finite data, finite compute, and stochastic gradients, it won't do so efficiently. Explicit normalization changes the geometry of the loss landscape, not just what's representable.

## 2. Expressivity vs Trainability

Three reasons to encode normalization structurally rather than hoping the optimizer rediscovers it:

**Optimization conditioning.** If activation vary across many orders of magnitude, gradients become poorly conditioned. The next layer's weights have to span a huge dynamic range. SGD struggles with this. Normalizing first gives the next layer a well-scaled problem.

**Capacity argument.** Without normalization, the next layer spends some of its weights learning to handle nuisance variables (scale drift, mean shift) before it can solve the actual task. The learnable parameters in normalization (γ, β) are tiny — much cheaper than a full layer rediscovering the same function from gradients alone.

**Inductive bias is the whole game.** Architecture choices _are_ the inductive bias. Convolutions, attention, normalization — all encode prior beliefs about what transformations are useful. A model that has to discover useful structure from scratch needs vastly more data and compute. No-free-lunch theorems formalize this.

## 3. The Depth Problem: Why Scale Compounds

A forward pass through L layers is a chain of matrix multiplies (with nonlinearities between). Each layer has some effective "gain" — the factor by which it amplifies or shrinks the signal. Through L layers, the total gain is the **product** of individual gains.

If gain per layer is g:

- g = 1.1 over 50 layers → 1.1^50 ≈ 117x growth
- g = 0.9 over 50 layers → 0.9^50 ≈ 0.005x collapse
- Same compounding happens to gradients on the backward pass

For training to work without normalization, every layer's effective gain must stay almost exactly at 1, simultaneously, throughout training. This is the **knife-edge problem**.

For PyTorch's default `nn.Linear` with ReLU, two factors shrink signal at each layer:

1. **Default init**: weights uniform in [−√(1/fan_in), √(1/fan_in)], variance = 1/(3·fan_in). Signal variance gets multiplied by 1/3 per layer.
2. **ReLU**: zeros roughly half its inputs, multiplying variance by ~1/2.

Combined per-layer variance multiplier: 1/6. Per-layer std multiplier: 1/√6 ≈ 0.408.

Scaling weights by a constant g changes the std multiplier to g/√6. Breakeven (no growth or decay) is g = √6 ≈ 2.449.

This is fragile: at g = 2 you shrink by (2/2.45)^30 ≈ 0.003x over 30 layers; at g = 3 you grow by (3/2.45)^30 ≈ 720x. A 50% change in gain spans 5 orders of magnitude. He init (variance = 2/fan_in, designed for ReLU) puts you on the breakeven line by construction — which is why it was a big deal pre-normalization.

## 4. How Normalization Resolves the Compounding

**Key fact**: if you multiply a layer's weights by any constant c, the pre-norm activations scale by c, but so do the mean and std they get divided by. Those factors cancel exactly. So post-normalization, the network output is **invariant to the scale of those weights**.

Implication: weight scale becomes a redundant degree of freedom. Many different weight configurations now produce identical outputs. Drift along this dimension _literally cannot affect the loss_. The optimizer is freed from caring about it.

In the dimensions that _do_ still matter (weight directions, plus γ and β), the loss landscape is empirically smoother. Santurkar et al. (2018) showed BN improves Lipschitz bounds on both the loss and its gradient — gradient steps that used to overshoot sharp valleys land on smoother slopes.

### Why isn't the moving normalization unstable?

Normalization is part of the computation graph — gradients flow through it via chain rule, so each optimizer step already accounts for how the norm will rescale. The optimizer isn't chasing a moving target; it's optimizing the post-normalization loss directly. And most of the apparent "shifting" happens in the redundant-scale dimensions the optimizer was freed from caring about.

## 5. What Is "Fundamental" in a Neural Network?

There are three flavors of magnitude to distinguish:

|Flavor|What it means|Affected by LN?|
|---|---|---|
|Within-vector pattern (direction)|Relative components of one feature vector|Preserved|
|Within-vector scale (magnitude)|Overall size of one vector|Erased per-input|
|Between-input magnitude|Ratio ‖h_A‖ / ‖h_B‖ at same layer|Erased by LN, preserved by BN|
|Between-layer magnitude|Ratio ‖h_L‖ / ‖h_1‖ across depth|Erased (reset) by all norms|

### The deep symmetry: positive homogeneity

A linear layer without bias satisfies W(cx) = c · Wx. ReLU satisfies ReLU(cx) = c · ReLU(x) for c > 0. So a network of (linear + ReLU) layers without biases is **positively homogeneous**: f(cx; W) = c · f(x; W). The function only "sees" direction; magnitude rides along multiplicatively.

Biases break this exact symmetry, but the structure remains approximately. Normalization explicitly factors out the multiplicative redundancy at each layer.

### The principle

**Direction is where information lives; magnitude is bookkeeping.**

The things that need magnitudes in a "good range" are mechanical, not semantic:

- gradients shouldn't underflow/overflow
- ReLU's threshold needs to bite usefully
- nonlinearities shouldn't saturate

These are constraints on the substrate, not the content. The content lives in direction. Empirical evidence: weight-normalized and direction-only parameterizations work fine, even when magnitude is constrained to be constant.

## 6. The Normalization Zoo

### Three-axis framing

Every normalization picks subsets of three axis types to reduce statistics over:

1. **Batch (N)** — which sample
2. **Sequence (T)** — which position in a sequence (transformers/ViTs only)
3. **Content** — atomic D-vector for transformers, structured C×H×W for CNNs

### Comparison table

✓ = axis is reduced over (averaged into the statistic); blank = preserved as index; — = doesn't exist for this architecture.

|Method|Arch|Batch|Sequence|Content reduced|Content preserved|# (μ, σ)|Inductive bias|
|---|---|:-:|:-:|---|---|:-:|---|
|**BatchNorm**|CNN|✓|—|H, W|C|C|feature distributions stable across batch+space; between-example magnitude per channel carries info|
|**InstanceNorm**|CNN||—|H, W|C|N·C|each (image, channel) is its own norm unit; channel statistics encode style, spatial pattern encodes content|
|**GroupNorm**|CNN||—|H, W, channels-in-group|G groups|N·G|channels within a group share scale; batch-size independent|
|**LayerNorm** (classical)|CNN||—|C, H, W|—|N|each image's full content normalized as one unit|
|**LayerNorm** (transformer)|Transformer / ViT|||D|—|N·T|each token's content lives in direction; per-token magnitude is irrelevant|
|**RMSNorm**|Transformer|||D (no centering)|—|N·T|only magnitude needs taming; mean shifts carry information|

### Reading the table

- **Batch column**: ✓ ties statistics to batch composition (BN's classic problem with small batches); blank makes each example self-contained.
- **Sequence column**: only meaningful for transformers; always blank in standard usage. Position info is preserved and added separately via positional encodings.
- **Content columns**: how much of one example's content gets pooled per (μ, σ). Atomic content (D) is always normalized whole. Structured content (C×H×W) admits multiple partitionings.
- **# stats column**: more statistics = finer-grained normalization but noisier per-statistic estimates.

### Useful comparisons

**BN vs IN** — both reduce H×W within content; differ only in whether batch is also reduced. BN: one (μ, σ) per channel, shared across batch. IN: one per (sample, channel). BN's stats are more stable (more numbers averaged), but couple to batch composition. IN's stats are noisier but example-independent.

**LN vs RMSNorm** — both per-token in transformers, both reduce only over D. RMSNorm skips mean subtraction, dividing only by RMS. Often equivalent in practice; RMSNorm is cheaper and used in LLaMA, PaLM, modern open LLMs.

## 7. Why CNN-Land Has Many Norms and Transformer-Land Has One

CNN content per example is **structured** (C × H × W) — high-dimensional, with multiple meaningful subdivisions (channels vs space, groups within channels). So multiple partitionings are sensible: BN, IN, GN all express different reasonable inductive biases.

Transformer content per token is **atomic** (D) — just a vector. There's nothing to partition. You normalize it whole, which collapses the design space to LN/RMSNorm.

ViTs inherit transformer-style content by chunking images into patches and treating each as a token. The whole CNN-norm-zoo problem dissolves — one of the smaller-but-real reasons the field shifted toward ViTs.

### VLM norm choices

- **Modern VLMs** (CLIP, LLaVA, BLIP, GPT-4V, Qwen-VL, etc.): both vision and language stacks are transformers, both use LayerNorm or RMSNorm. Same inductive bias on both sides.
- **Hybrid VLMs** (CNN visual backbone + transformer LM): mixed BN (vision) + LN (language). Interface needs careful handling — typically LN applied to projected visual features before they enter the language stack.
- **Normalizer-free vision** (NFNets): replaces BN with weight standardization + scaled residuals. Niche but illustrates that structural choices can substitute for explicit norms.

## 8. Hands-On Experiments to Verify the Theory

Three experiments worth running in PyTorch:

**Scale invariance.** Build an MLP with optional LayerNorm. Multiply fc1 weights by 100x. With LN, output should be unchanged (~1e-7, float noise). Without LN, output explodes proportionally.

**Gradient Lipschitz.** Estimate L by probing ‖∇f(w+δ) − ∇f(w)‖ / ‖δ‖ at random δ. The LN version gives noticeably smaller ratios — this is the smoothness Santurkar et al. quantified.

**Depth propagation.** Stack 30 layers of `Linear(d, d) → ReLU` with weights scaled by gain g. Without norm, activation std follows roughly (g/√6)^L — vanishing for g < √6, exploding for g > √6, with a narrow viable band around g ≈ 2.45. With LN, std stays ~constant regardless of g or depth.

The third experiment is the most viscerally educational — try gain=2.0, 2.5, 3.0 and watch the magnitude swing across orders of magnitude with no normalization, while LN absorbs it without effort.

## 9. Summary

- Architecture is inductive bias; inductive bias is what makes finite-data learning tractable.
- Without normalization, deep networks live on a knife edge: tiny per-layer gain errors compound exponentially.
- Normalization makes the network function **invariant to weight scale**, eliminating an entire redundant dimension of weight space and smoothing the loss landscape (provably lower L → larger learning rates → faster training).
- The deep claim baked into modern architectures: **direction carries information, magnitude is bookkeeping**.
- Different normalizations differ in _which axes they reduce statistics over_; the reduce/preserve choice IS the inductive bias.
- The field has converged on per-token LN/RMSNorm because transformer-style atomic content has only one sensible normalization — and because the "direction is content" prior happens to work across both vision and language.

## Further Reading

- Santurkar et al. (2018), _How Does Batch Normalization Help Optimization?_ — the smoothness story
- Ba, Kiros, Hinton (2016), _Layer Normalization_ — the LN paper
- Wu & He (2018), _Group Normalization_ — GN, motivation for batch-size-independent norms
- Zhang & Sennrich (2019), _Root Mean Square Layer Normalization_ — RMSNorm
- Nesterov, _Introductory Lectures on Convex Optimization_ — for the descent lemma and convergence theory
- Bubeck, _Convex Optimization: Algorithms and Complexity_ (free online) — shorter alternative