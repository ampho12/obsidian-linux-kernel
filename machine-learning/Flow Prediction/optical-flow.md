
A progression of three architectures that together trace how modern optical flow estimation evolved. Each paper fixed a specific weakness of its predecessor while preserving what worked.

---

## Background: What is optical flow?

Given two consecutive frames `I1` and `I2`, predict a 2D vector `(u, v)` at every pixel of `I1` saying where that pixel moved to in `I2`. Output: a dense flow field of shape `H × W × 2`.

At its core, this is a **matching problem**: for each `I1` pixel, find its twin in `I2`. All three methods build **feature maps** from the images (via a CNN encoder) and use **inner products** between feature vectors as a learned similarity measure. A collection of such similarities is a **cost volume** (or correlation volume).

The three papers differ in _how_ they structure the cost volume and _how_ they convert it into a flow prediction.

---

## 1. PWC-Net (CVPR 2018)

**Paper:** Sun, Yang, Liu, Kautz. _PWC-Net: CNNs for Optical Flow Using Pyramid, Warping, and Cost Volume._

### The idea

Use a **feature pyramid**, **warping**, and **local cost volumes** to estimate flow in a coarse-to-fine manner. Handle large displacements at coarse resolution (where they become small), then refine at finer levels.

### Architecture

**Feature pyramid.** One shared CNN encoder processes each image. Because of striding, it naturally produces features at multiple resolutions: 1/2, 1/4, 1/8, 1/16, 1/32. The stack of these outputs is the feature pyramid. Coarser levels have lower spatial resolution but more channels (richer per-location descriptors).

**Coarse-to-fine loop.** Starting at the coarsest level:

1. Take `F1_coarse` and `F2_coarse`
2. Compute a **local cost volume**: for each `F1` location, inner products against a small window (e.g. 9×9) of `F2` locations
3. Decode a flow estimate from the cost volume with a small CNN
4. **Upsample the flow** by 2× (and scale its magnitudes by 2)
5. Move to the next finer level: **warp `F2` features** using the upsampled flow — this pre-aligns `F2` to `F1` using what's already known
6. Compute another local cost volume between `F1` and warped `F2` at this level
7. Decode a **residual flow** (a correction) and add it to the upsampled coarse flow
8. Repeat up the pyramid

### Why it works

- At coarsest resolution, a 100-pixel motion in the original image is only ~3 pixels — a small local window can find the match
- Warping removes the bulk of the motion each step, so subsequent levels only need small local search
- Features are reused (same encoder for all levels), keeping parameter count manageable

### Weaknesses

- **Small fast-moving objects disappear at coarse resolution** — once they're lost at the top of the pyramid, no fine level can recover them
- **Error propagation**: mistakes at coarse levels mislead the warping, which misleads finer levels
- Multiple local cost volumes (one per level), each of which is expensive relative to what it tells you
- Many separate sub-networks (one decoder per level), each with its own weights

---

## 2. RAFT (ECCV 2020, Best Paper)

**Paper:** Teed, Deng. _RAFT: Recurrent All-Pairs Field Transforms for Optical Flow._

### The idea

Drop the feature pyramid entirely. Compute **one global cost volume** between all pairs of features at a single resolution. Then iteratively refine a single flow estimate by repeatedly querying this volume with a learned recurrent update operator.

Tagline: **"PWC pools then dots. RAFT dots then pools."**

### Architecture

**Two encoders on `I1`, one on `I2`.** Both at 1/8 resolution:

- **Feature encoder** produces `F1` and `F2` — features used for matching, with instance normalization
- **Context encoder** produces `F1'` from `I1` only — features used for scene understanding, with batch normalization. Its output seeds the GRU hidden state `h₀` and is concatenated into the GRU input at every iteration

**All-pairs 4D correlation volume.** Shape `(H/8, W/8, H/8, W/8)`. For every `I1` location, a response map over every `I2` location, computed as a single big matrix multiplication.

**Correlation pyramid (pool the volume, not the features).** Average-pool the **last two dimensions** (the `I2` side) at kernel sizes `{1, 2, 4, 8}`. This gives four volumes:

|Level|Volume shape|I2 cell covers|
|---|---|---|
|0|(H/8, W/8, H/8, W/8)|8 px|
|1|(H/8, W/8, H/16, W/16)|16 px|
|2|(H/8, W/8, H/32, W/32)|32 px|
|3|(H/8, W/8, H/64, W/64)|64 px|

The `I1` side stays sharp everywhere. Only the "where could the match be in `I2`" side is progressively summarized.

**The lookup operator.** At each iteration, for each `I1` pixel with current flow `(u, v)`, sample a small window from each pyramid level:

- Predicted `I2` location: `(i + u, j + v)` in level-0 coordinates; divide by `2^k` for level `k`
- Sample a **9×9 window** (radius `r = 4`) around that point at each level, using bilinear interpolation for fractional coordinates
- Get 81 values × 4 levels = **324 correlation values per pixel**

Because cell sizes grow with level, the same 9×9 window covers ~72 px at level 0 and ~576 px at level 3 — fine and coarse matching in one cheap lookup.

**The GRU update loop.** 12 iterations during training, 32 at inference. Each iteration:

1. **Lookup** 324 correlation values per pixel at current flow
2. **Motion encoder** (small convs) compresses correlation + flow into motion features
3. **Convolutional GRU** takes motion features + context features + previous hidden state; produces new hidden state using reset and update gates
4. **Flow head** (2 convs) decodes `Δf` from the hidden state
5. **Update flow**: `f_k = f_{k-1} + Δf_k`

Weights are **shared across iterations** — it's a single update rule applied repeatedly, like a learned fixed-point iterator.

**Convex upsampling.** Final flow is at 1/8 resolution. Upsample to full by predicting a softmax over 3×3 neighbors and taking a convex combination. Sharper edges than bilinear for minimal cost.

**Sequence loss.** Supervise every iteration with exponentially-increasing weights toward the final one — stabilizes training and encourages convergence.

### Why it works

- **All-pairs matching** means no coarse-scale information loss — even small fast objects are visible
- **Single flow estimate refined iteratively** means errors can be corrected later (unlike coarse-to-fine, where early mistakes are locked in)
- **Cost volume is computed once** and reused as a static data structure for all 32 lookups — cheap per iteration
- **Multi-scale lookup** gives both fine precision and large receptive field at every iteration
- **Weight sharing** allows running more iterations at test time than training

### Weaknesses

- L1 training loss is dominated by ambiguous (occluded) pixels — the network distorts good predictions trying to minimize error on impossible ones
- **Zero-initialization** means the first several iterations are spent getting into the right ballpark
- **12+32 iterations** is expensive for deployment
- Custom encoder and GRU designs make the architecture hard to modify or scale
- Pre-training on small synthetic datasets (FlyingChairs, FlyingThings3D) limits generalization

---

## 3. SEA-RAFT (ECCV 2024, Oral)

**Paper:** Wang, Lipson, Deng. _SEA-RAFT: Simple, Efficient, Accurate RAFT for Optical Flow._

### The idea

Keep the entire RAFT architecture (feature encoder, context encoder, 4D correlation volume, pooled pyramid, radius-4 lookup, iterative refinement, flow head, convex upsampling). Fix four specific weaknesses independently. Result: 2.3× faster, better accuracy, better generalization, simpler code.

### The four changes

#### 1. Mixture of Laplace (MoL) loss

**Problem.** L1 loss is dominated by fundamentally ambiguous pixels (occlusions, disocclusions). These impossible cases cost so much loss that the network distorts its predictions on good pixels to slightly reduce them.

**Fix.** Predict a two-component Laplace **distribution** at every pixel instead of a point estimate:

```
MixLap(x) = α · Laplace(x; μ, β₁=0) + (1-α) · Laplace(x; μ, β₂)
```

- Component 1 has fixed scale β₁ = 0 → behaves exactly like L1 loss. For ordinary pixels.
- Component 2 has learned scale β₂ → a "safety valve" for ambiguous pixels.
- Mixing coefficient α ∈ [0, 1] is predicted per pixel.

Train with log-likelihood of ground truth flow under this mixture. For ordinary pixels, α → 1 and behavior matches L1. For ambiguous pixels, α drops and the network explains error via the wide component without distorting other predictions.

**Bonus:** `1 − α` gives a free **uncertainty estimate** at every pixel — useful downstream (e.g. filtering matches for pose estimation).

Crucially, fixing β₁ = 0 is specific to flow — previous matching-task uses of mixture losses (PDC-Net+ for keypoint matching) don't do this because their evaluation only considers a filtered subset of pixels.

#### 2. Directly regressed initial flow

**Problem.** RAFT's zero initialization forces early iterations to do nothing but shift the lookup into the right neighborhood.

**Fix.** Feed the **context encoder both stacked frames** `[I1, I2]` (6 input channels) and predict an initial flow estimate directly, FlowNet-style. Iterative refinement starts from this warm estimate instead of zero.

Almost free — the context encoder already exists, just add one prediction head. Result: only **4 iterations needed in training, 12 at inference** (vs 12 / 32 for RAFT). Large speedup with equivalent or better accuracy.

#### 3. Rigid-flow pre-training on TartanAir

**Problem.** Standard flow datasets (FlyingChairs, FlyingThings3D) are small and unrealistic. Flow networks trained on them generalize poorly.

**Fix.** Pre-train on **TartanAir** — a large photorealistic simulator dataset with drone flights through diverse scenes. TartanAir provides stereo pairs with known camera motion, so flow between two views of a **static rigid scene** can be computed directly.

This flow is limited (no moving objects), but it's realistic and diverse. Pre-training teaches general matching on realistic imagery; fine-tuning on Sintel / KITTI / etc. specializes to handle object motion.

#### 4. Architectural simplifications

Replace custom modules with off-the-shelf ones:

- **Encoders:** ImageNet-pretrained **ResNet-18** (for SEA-RAFT(S)) or **ResNet-34** (for SEA-RAFT(M)), truncated to the first few layers. Replaces RAFT's custom feature and context encoders with their specific norm choices.
- **Recurrent unit:** Two **ConvNeXt blocks** as a simple RNN. **Replaces the convolutional GRU entirely** — no reset gate, no update gate. Just `h' = RNN(h, x)`.

The gating was found empirically unnecessary when using ConvNeXt blocks, which have strong enough inductive biases (depthwise convs, layer norm, GELU, inverted bottleneck) to be stable without it. This is a surprising result given how central the GRU gating was to the RAFT story.

Practical benefit: it becomes trivial to swap in larger backbones or newer building blocks.

### The SEA-RAFT loop

**Done once at the start:**

- Encode `I1, I2` with pretrained ResNet → `F1, F2`
- 4D correlation volume: inner products of all `F1`, `F2` pairs
- Pool `I2` axes at {1, 2, 4, 8} → 4-level pyramid
- Encode `I1` alone with context encoder → context features, initial `h₀`
- Encode `[I1, I2]` stacked with context encoder → **directly regressed initial flow `f₀`**

**For each of 4 (training) or 12 (inference) iterations:**

1. Lookup at current `f`, radius 4, across 4 pyramid levels → 324 values per pixel
2. Motion encoder compresses → `x`
3. ConvNeXt-based RNN: `(h, x, context) → h'` (no gating)
4. Flow head: `h' → Δμ, α, β₂`
5. `f ← f + Δμ`

**Training loss:** Mixture-of-Laplace log-likelihood, exponentially-weighted sequence loss across iterations.

### Why it works

- MoL loss removes the dominant source of gradient noise from ambiguous pixels
- Warm initialization means iterations spend their budget on refinement, not ballpark-finding
- Realistic pre-training data teaches better matching priors
- Simpler architecture is easier to scale and ablate

### Model variants

|Model|Backbone|Iters (train)|Iters (infer)|
|---|---|---|---|
|SEA-RAFT(S)|ResNet-18 (first 6 layers)|4|4|
|SEA-RAFT(M)|ResNet-34 (first 13 layers)|4|4|
|SEA-RAFT(L)|ResNet-34 (same as M)|4|12|

SEA-RAFT(L) reuses the weights of SEA-RAFT(M) but just runs more iterations at inference — a nice demonstration of the weight-sharing property inherited from RAFT.

---

## Side-by-side comparison

||PWC-Net|RAFT|SEA-RAFT|
|---|---|---|---|
|**Feature representation**|Feature pyramid (multi-res)|Single-res features (1/8)|Single-res features (1/8), pretrained ResNet|
|**Cost volume**|Multiple local volumes, one per pyramid level|One all-pairs 4D volume|Same as RAFT|
|**Multi-scale mechanism**|Image/feature pyramid + warping|Pool the cost volume (correlation pyramid)|Same as RAFT|
|**Refinement axis**|Across spatial pyramid levels|Across iterations (GRU at single res)|Same as RAFT|
|**Initialization**|Flow upsampled from coarser level|Zero flow|Directly regressed flow|
|**Recurrent unit**|None (feedforward per level)|Convolutional GRU (reset + update gates)|ConvNeXt blocks (no gating)|
|**Training loss**|L1 / L2 on flow|L1 with sequence weighting|Mixture of Laplace with sequence weighting|
|**Uncertainty output**|None|None|Per-pixel `1 − α`|
|**Pre-training**|FlyingChairs|FlyingChairs, FlyingThings3D|TartanAir + standard flow datasets|
|**Iterations at inference**|N/A (single forward pass)|32|4–12|
|**Handles small fast objects**|Poorly|Well|Well|

---

## The conceptual arc

- **PWC-Net** accepted that matching is expensive and used a pyramid to avoid it. Good engineering but limited by coarse-scale information loss.
- **RAFT** asked: what if we just compute all matches once, globally, and build the multi-scale behavior into the _cost volume_ (via pooling) rather than the _features_ (via a pyramid)? The refinement moved from a spatial axis to an iterative axis.
- **SEA-RAFT** asked: now that RAFT has the right architecture, what are the remaining bottlenecks? Answer: the loss is wrong for ambiguous pixels, the initialization wastes iterations, the training data is too small, and the custom modules are unnecessary. Fix each independently.

The SCFlow family builds directly on RAFT: same correlation pyramid and GRU structure, but the lookup location is constrained to be a **pose-induced flow** from a known 3D shape, and the update predicts a **pose increment** instead of a flow increment. Understanding RAFT makes SCFlow a small step rather than a new architecture.

---

## References

- Sun, D., Yang, X., Liu, M.-Y., Kautz, J. _PWC-Net: CNNs for Optical Flow Using Pyramid, Warping, and Cost Volume._ CVPR 2018. [arXiv:1709.02371](https://arxiv.org/abs/1709.02371)
- Teed, Z., Deng, J. _RAFT: Recurrent All-Pairs Field Transforms for Optical Flow._ ECCV 2020. [arXiv:2003.12039](https://arxiv.org/abs/2003.12039) · [Code](https://github.com/princeton-vl/RAFT)
- Wang, Y., Lipson, L., Deng, J. _SEA-RAFT: Simple, Efficient, Accurate RAFT for Optical Flow._ ECCV 2024. [arXiv:2405.14793](https://arxiv.org/abs/2405.14793) · [Code](https://github.com/princeton-vl/SEA-RAFT)



## SEA-RAFT

1. Laplace loss: fix training loss so it handles ambiguous cases
2. Fix the initial flow = 0 cold start problem
3. Rigid-flow pretraining: fix data scarcity with TartanAir
4. Architectural Simplifications: Replace custom models with off the shelf ones.