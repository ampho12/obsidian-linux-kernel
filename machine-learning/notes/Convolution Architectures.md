# What CNNs Actually Do: Intuition Grounded in Data

Notes from building and comparing CNN architectures for a geometric regression task (stereo images → pixel displacements). The specifics don't matter — the ideas generalize.

---

## A CNN is a stack of 3D tensors

Every intermediate representation in a CNN is a tensor with three axes: channels, height, width. Each spatial position in a channel answers one question: "how much does pattern X appear at location (row, col)?"

The channel axis is "what." The spatial axes are "where." Everything a CNN does — convolution, pooling, skip connections, FPN — is about manipulating the balance between what and where.

This framing makes every design decision concrete: does this operation preserve where? Does it enrich what? Does it destroy either?

---

## How you read features out matters more than how you build them

We tested four ways to extract information from the same feature tensor before feeding it to a regression head:

| Readout | What the head sees | Fixed LR | Cosine LR |
|---|---|---|---|
| Global avg pool (1×1) | "how much of pattern X anywhere" | 0.48 px | — |
| Spatial softmax | "pattern X is at coordinate (0.3, -0.1)" | 0.25 px | 0.18 px |
| 4×4 grid pool | "pattern X has this spatial distribution" | 0.16 px | 0.16 px |

The big gap is between global pool and anything that preserves spatial information — that's a genuine 3× difference. Destroying position entirely is catastrophic for geometric regression.

Between spatial softmax and 4×4 grid pool, the story is more nuanced. With a fixed learning rate, 4×4 pool looked much better (0.16 vs 0.25). With cosine LR, spatial softmax closed to 0.18 — nearly matching. The difference was mostly optimization, not representation: spatial softmax involves an exponential function that creates sharper loss curvature, so it needs a gentler LR schedule. The 4×4 pool is a linear operation that's robust to noisy optimization.

**The lesson:** The transition from spatial features to the prediction head is where most information gets destroyed. Collapsing everything to a single number per channel is almost always wrong for spatial tasks. But among methods that preserve spatial info, the differences may be smaller than they appear — check that you're not confusing training instability with architectural inferiority.

---

## Check what your network actually learns, not what you assume it learns

We used spatial softmax because it's the standard for geometric regression — pose estimation papers use it everywhere. The assumption: each conv channel learns a point detector, and spatial softmax reads off the precise location.

We visualized the actual feature maps. They weren't points. They were horizontal bars, edge responses, diffuse multi-region patterns. Spatial softmax computes the centroid of these — which for a bar barely moves when the target shifts, and for two blobs lands between them where nothing is activating.

The 4×4 grid won because it makes no assumptions about activation shape. It preserves whatever the network learned, whether that's a peak, a bar, or a complex pattern. However, the gap was much smaller than it first appeared — with proper LR scheduling, spatial softmax closed to within 0.02 px of the grid. The network compensates for imperfect readout by learning to encode information in ways the readout can still extract, given enough optimization time.

**The lesson:** Architectural choices encode assumptions. Spatial softmax assumes unimodal activations. FPN assumes multi-scale objects. Siamese assumes the two inputs should be processed identically. When the assumption doesn't match reality, you pay a cost — but that cost might be a harder optimization problem (fixable with better training) rather than a hard ceiling (unfixable). Visualize your intermediate representations to understand *what* the mismatch is, then decide if it's worth fixing architecturally or just training through.

---

## Inductive bias beats capacity (up to a point)

The siamese architecture (472K params, 0.31 px) outperformed the baseline CNN (388K params, 0.46 px) and even the FPN (706K params, 0.33 px) despite having fewer parameters than the FPN.

The only difference: instead of stacking two images as 6 channels and asking the first conv layer to learn cross-image filters, the siamese processes each image with a standard 3-channel encoder and combines features later. This makes the first layer's job dramatically easier — learning 3-channel image filters is a well-conditioned problem with decades of empirical evidence. Learning 6-channel cross-image filters where channels 1-3 have no spatial relationship to channels 4-6 is a novel optimization problem the network must solve from scratch.

But: the v2 model with 1.7M params and a "dumb" multi-scale tap (no siamese, no FPN, no skip connections) reached 0.16 px — beating everything. A big enough head can compensate for weak inductive bias by memorizing patterns that better architectures encode structurally.

**The lesson:** Good inductive bias is parameter-efficient. It lets you reach a given accuracy with fewer parameters and less training. But raw capacity can always brute-force past a cleverer but smaller model. The question is whether you care about efficiency or just final accuracy.

---

## Training instability hides architectural differences

The spatial softmax model scored 0.25 px with a fixed learning rate of 1e-3. With cosine annealing (3e-4 → 1e-6), the same architecture reached 0.18 px. No architecture change. Just smoother optimization.

Why: spatial softmax involves an exponential (softmax), which creates sharper curvature in the loss landscape. A learning rate that works fine for linear readouts (4×4 pool) causes oscillation with nonlinear readouts. The val loss bounced between 0.3 px and 2+ px epoch to epoch — the "best val" from a noisy run is a lottery ticket, not a reliable measurement.

We compared CNN vs FPN at fixed LR and concluded "FPN doesn't help." With cosine LR, both improved significantly, but FPN improved more — the architectural difference was real but masked by optimization noise.

**The lesson:** Before concluding that architecture A beats architecture B, equalize training. Use LR scheduling. Run multiple seeds. A 30% accuracy difference could be 20% optimization artifact and 10% architectural. If you're comparing architectures with different loss landscape geometry (linear vs nonlinear readouts, shallow vs deep networks), they may need different learning rates entirely.

---

## Skip connections equalize gradient flow, not gradient magnitude

We logged gradient L2 norms per layer across training. Without skip connections, the ratio between first-layer and last-layer gradient norms was ~5×. With skip connections, it dropped to ~1.5×. The deep layers were learning while the shallow layers stalled.

But the accuracy improvement was only 0.05 px (0.46 → 0.41). At 5 layers, gradients are "unhealthy but survivable." The network compensates by relying more on deep layers.

**The lesson:** Skip connections matter in proportion to network depth. At 5 layers, they're a minor optimization aid. At 50 layers, they're the difference between training and not training. The gradient plots quantify this: check the ratio between your shallowest and deepest layer gradients. If it's <10×, skip connections help but aren't critical. If it's >100×, you need them.

**The deeper point about skip connections:** They don't just help gradient flow — they change what each layer learns. Without skip connections, each layer must learn the full transformation from input to output. With them, each layer learns a small residual correction on top of identity. This is an easier optimization target when the optimal transformation is close to identity, which is often true for deeper layers that are refining already-good features.

---

## Multi-scale features: you need context, not just detail

We tested using only fine-scale features (56×56, 8-pixel receptive field) vs adding mid and coarse scales. Fine-only scored 1.29 px. Adding mid and coarse brought it to 0.46 px.

The fine features can detect thread edges, surface texture, small patterns. But they can't see the screw as a whole object or know where things are relative to the full image. A thread edge at position (20, 30) in the feature map means nothing without context about what object it belongs to and where that object sits in the scene.

**The lesson:** Receptive field determines what a neuron can "see." If your task requires understanding both fine detail and global layout, you need features at multiple scales. This doesn't necessarily mean FPN (which adds top-down fusion) — even simple multi-scale tapping (reading features at different depths) provides the necessary context. The question is whether the head can combine them (multi-scale tap) or whether the features need to be pre-combined (FPN).

---

## FPN vs multi-scale tap: where should cross-scale reasoning happen?

FPN merges scales inside the network — P3 already contains both fine detail and coarse context. Multi-scale tap keeps scales separate and lets the head combine them.

FPN scored 0.33 px at 706K params. Multi-scale tap scored 0.16 px at 1.7M params — but most of that parameter budget is in the head (3072→512 = 1.57M params), not the encoder.

This tells you where the cross-scale reasoning actually happens in each architecture. In FPN, it's in the lateral connections and upsampling (baked into the features). In multi-scale tap, it's in the head's linear layer (learned from data). The head approach is less elegant but more flexible — it can learn arbitrary cross-scale relationships, not just the additive merging that FPN imposes.

**The lesson:** When you have enough data and parameters for the head, letting the head do the reasoning is often simpler and equally effective. FPN's value is in being parameter-efficient at cross-scale fusion — it matters more when your head is small or your data is limited.

---

## Siamese encoding: make the first layer's job easier

The biggest single improvement came from processing two images separately instead of stacking them as 6 channels. This is purely about what the first conv layer has to learn.

A 6-channel first layer must learn filters that simultaneously look at both images and extract cross-image relationships. If the two images are non-overlapping views (different cameras, different angles), there's no spatial correspondence between channel 1 (left camera red) and channel 4 (right camera red) at the same position. The filter must discover this from data.

A 3-channel siamese encoder just learns normal image features. The comparison happens later, after both images are already understood. This is a much better-conditioned optimization problem.

**The lesson:** When your input has semantically distinct groups of channels (stereo pairs, multi-modal data, time series stacked as channels), consider whether processing them separately first and combining later makes the learning problem easier. The answer depends on whether there's meaningful spatial correspondence between the groups at the pixel level.

---

## Pretrained features can hurt

ResNet-18 with ImageNet pretrained weights scored 0.40-0.47 px. Custom CNNs trained from scratch on 13K domain-specific images scored 0.31-0.46 px. Pretrained features didn't help and sometimes hurt.

ImageNet teaches a network to distinguish cats from dogs, cars from trees. The features it learns — fur texture, wheel shapes, sky gradients — are irrelevant for metallic screw ports under industrial lighting. Freezing these features forces the head to decode representations that weren't designed for the task. Fine-tuning helps but the early layers (which are the most generic) may still push features in unhelpful directions.

**The lesson:** Transfer learning helps when source and target domains share visual structure. Natural images → natural images works. Natural images → industrial/medical/satellite imagery often doesn't. With enough domain-specific data (even 13K images), training from scratch can outperform transfer.

---

## Look at errors, not architectures

The most useful analysis wasn't comparing architectures — it was examining which samples the best model got wrong.

Every worst sample had displacements at ±30 px — the boundary of the training range. The model had never seen anything beyond ±30 px, so it had no information to anchor against. Error vs displacement magnitude was flat from 0-40 px, then fanned out at the boundary. Median accuracy was 0.13 px; the 0.16 px RMSE was inflated by a small number of boundary samples.

This told us the architecture wasn't the bottleneck. No architecture change would fix boundary extrapolation. The fix is expanding the training range so ±30 px becomes interior data, not edge data.

**The lesson:** Before searching over architectures, understand your errors. If errors are uniform, the architecture may be the limit. If errors concentrate in specific conditions (boundary cases, specific viewpoints, certain objects), the fix is usually data, not architecture. A confusion matrix, error-vs-condition plot, or worst-sample analysis tells you more than trying 10 more architectures.

---

## Summary: the hierarchy of what matters

From our experiments, ordered by impact:

1. **Don't destroy spatial information** (3× difference): Global pooling vs any spatial readout is the single biggest factor. Between spatial readout methods (softmax vs grid), differences are small once training is equalized.
2. **Input encoding** (1.5× difference): How you present multi-source inputs to the first layer determines how hard the optimization problem is. Siamese for independent views, concat for spatially aligned inputs.
3. **Multi-scale features** (2.8× difference): Fine features alone fail. You need context. Whether that context comes from FPN or simple multi-scale tapping depends on your parameter budget.
4. **Training stability** (1.4× difference): LR scheduling, gradient clipping, and optimization hygiene can change results as much as architecture changes. A model that "loses" with a fixed LR may match or beat the winner with proper scheduling.
5. **Skip connections** (1.1× difference): Measurable but modest at shallow depth. Essential at deep depth.
6. **FPN top-down fusion** (1.1× over multi-scale tap at matched params): Elegant but not transformative when the head has enough capacity to do cross-scale reasoning itself.

# CNN Feature Extractors: What Each Design Choice Actually Does

Notes from systematically building up a CNN for geometric regression. Each section adds one thing and measures the effect. All numbers from controlled experiments on the same dataset, same training setup.

---

## The three parts of a CNN regression model

Every CNN that maps an image to a prediction has three parts:

```
image → [encoder] → feature tensor → [readout] → flat vector → [head] → prediction
```

**Encoder:** Convolutions that transform pixels into features. This is what people usually mean by "the architecture."

**Readout:** How you collapse the spatial feature tensor into a flat vector. Pooling, spatial softmax, flatten — this is the bridge between 3D features and the 1D prediction head.

**Head:** Linear layers that map the flat vector to your output. Usually the least discussed but often where most parameters live.

We found that changes to each part had different magnitudes of effect, and that the interaction between them matters more than any part in isolation.

---

## Part 1: The encoder

### Plain conv chain

The simplest encoder: stack conv-ReLU-pool layers. Each layer halves spatial resolution and (optionally) increases channels. Information flows one direction.

```
448×448 → conv(48) → pool → conv(48) → pool → conv(64) → pool → conv(64) → pool → conv(64) → pool
           224          112          56           28           14

Result: 0.46 px (388K params, reading from final 14×14 only)
```

Each layer sees the previous layer's output and nothing else. By the final layer, the network has a 14×14 feature map with a large receptive field (sees the whole image) but low spatial precision (each position covers a 32×32 pixel region of the input).

The shallow layers have high spatial precision but small receptive fields. The deep layers have the opposite. This tradeoff is fundamental to CNNs — it's what motivates every architectural variation below.

### Adding skip connections (+0.05 px)

Wrap each conv in a residual shortcut: output = conv(x) + x.

```
Same structure, but each block:
  x → conv → ReLU → (+) → out
  └─────────────────┘

Result: 0.41 px (392K params)
```

**What it changes — gradient flow:** We measured gradient norms per layer. Without skip connections, the first layer's gradient was ~5× weaker than the last layer's by epoch 30. With skip connections, the ratio dropped to ~1.5×. All layers continue learning throughout training instead of early layers stalling.

**What it changes — what each layer learns:** Without skip, each layer must learn the complete transformation from its input to its desired output. With skip, each layer learns a residual: "what small change should I make to the input?" If the best thing to do is almost nothing (common in deeper layers where features are already good), the weights can be near-zero, which is easy to learn.

**Why only 0.05 px:** At 5 layers deep, gradient vanishing is measurable but not fatal. The network compensates by relying more on deep layers. At 20+ layers, skip connections become essential — without them, the first layer's gradient would be effectively zero.

**When to use:** Always, basically. The cost is negligible (a 1×1 conv when channels change, ~1% extra params) and the benefit is never negative. It's free gradient health insurance.

### Going multi-scale: tapping intermediate features (+0.17 px over baseline)

Instead of reading only the final 14×14 feature map, tap features at multiple points along the encoder:

```
input → conv → conv → conv → f1 (56×56) → conv → conv → f2 (14×14) → conv → f3 (7×7)
                               ↓                   ↓                    ↓
                            readout             readout              readout
                               ↓                   ↓                    ↓
                               └──────── concat ───┘────────────────────┘
                                              ↓
                                            head
```

f1 sees fine detail (edges, texture) with an 8px receptive field. f3 sees the whole scene but at 7×7 resolution. The head receives both and can combine them.

**Critical finding — fine-only fails badly:** Using only f1 (56×56) scored 1.29 px. Adding mid and coarse scales brought it to 0.46 px. Fine features alone cannot anchor position within the full image. A thread edge at position (20, 30) in the feature map is meaningless without context about which object it belongs to and where that object sits in the scene.

|Scales used|Result|
|---|---|
|Fine only (56×56)|1.29 px|
|Fine + mid (56 + 14)|0.32 px|
|Fine + mid + coarse (56 + 14 + 7)|0.28 px|

The jump from fine-only to fine+mid is enormous (4×). Adding coarse on top helps modestly. Mid-scale features (14×14, ~32px receptive field) provide the critical context: large enough to see object parts, small enough to retain spatial precision.

**When to use:** Whenever your task requires both spatial precision and semantic understanding. Classification tasks can get away with single-scale (just the final layer) because they only need "what", not "where." Regression, detection, and localization tasks almost always benefit from multi-scale.

### FPN: merging scales inside the network (+0.13 px over baseline)

Multi-scale tapping reads scales independently — fine features don't know about coarse context, and vice versa. FPN adds a top-down pathway that sends coarse information back to fine feature maps:

```
Bottom-up:   input → conv → conv → c3 (56×56) → conv → c4 (28×28) → conv → c5 (14×14)
                                     ↓                    ↓                    ↓
Top-down:                          lat 1×1             lat 1×1              lat 1×1
                                     ↓                    ↓                    ↓
                                    P3  ←── upsample ─── P4  ←── upsample ── P5
                                     ↓       + add        ↓       + add       ↓
                                  smooth 3×3           smooth 3×3
```

P3 is not raw c3 — it's c3 merged with upsampled information from c4 and c5. So P3 knows both "there's a sharp edge here" (from c3) and "that edge belongs to a screw head" (from c5, sent back down).

```
Result: 0.33 px (706K params)
```

**FPN vs multi-scale tap:** Both read multiple scales. The difference is where cross-scale reasoning happens. In multi-scale tap, the head does it (from independent scale readouts). In FPN, the lateral connections do it (scales are pre-merged before the head sees them).

Multi-scale tap at 1.7M params reached 0.16 px — better than FPN at 706K. But most of multi-scale tap's budget is in a massive 3072→512 head (1.57M params in that one layer). At matched param counts, FPN is more efficient because it offloads cross-scale reasoning to the architecture rather than the head.

**The tradeoff:** FPN imposes a specific merging strategy (upsample + add + smooth). Multi-scale tap lets the head learn arbitrary cross-scale relationships. FPN is more parameter-efficient; multi-scale tap is more flexible. With enough head capacity, the flexibility wins. With a tight param budget, FPN's structural bias wins.

**When to use FPN:** When you need multi-scale features but can't afford a massive head. When objects appear at multiple scales in the same image (detection tasks). When parameter efficiency matters more than maximum accuracy.

**When multi-scale tap is enough:** When your targets are at a fixed scale (always roughly the same size in the image). When you can afford a large head. When simplicity matters.

---

## Part 2: The readout

The readout is how you collapse spatial dimensions. This is where most information gets destroyed, and the choice matters enormously.

### Global average pool (1×1)

```
(64, 14, 14) → average each channel → (64,)
```

Each channel becomes a single number: "how much of pattern X is present anywhere in the image." All spatial information is gone. The head cannot know where anything is.

```
Result: 0.48 px
```

**When it works:** Image classification (you just need "is there a cat?"). Any task where location doesn't matter.

**When it fails:** Any spatial task — regression, detection, pose estimation, segmentation. If your task involves "where" in any way, global pool is wrong.

### Spatial softmax

```
(64, 14, 14) → softmax over spatial dims → weighted avg of coordinates → (128,)
                                            64 x-coords + 64 y-coords
```

Each channel reports a single (x, y) coordinate: the expected position of that channel's activation. Precise, differentiable, compact.

```
Result: 0.25 px (fixed LR) → 0.18 px (cosine LR)
```

**The assumption:** Each channel has one dominant activation peak. The expected coordinate is meaningful — it tracks the peak's position smoothly.

**When it breaks:** We visualized feature maps and found horizontal bars, edge responses, diffuse multi-region patterns. For a bar, the centroid barely moves when the target shifts. For two blobs, the centroid lands between them. However — with proper LR scheduling, spatial softmax closed to within 0.02 px of grid pool. The network compensates by encoding information in ways the readout can still extract, given enough optimization time.

**The subtlety:** Spatial softmax involves an exponential function, creating sharper curvature in the loss landscape. It needs gentler learning rates than grid pooling. What looked like an architectural limitation was largely an optimization problem.

### Grid pool (4×4)

```
(64, 14, 14) → adaptive avg pool → (64, 4, 4) → flatten → (1024,)
```

Each channel retains a 4×4 spatial grid — 16 values that describe the distribution of activation across the image. An edge produces a distinctive pattern. A point produces a different pattern. Two blobs produce yet another. The head reads these patterns directly.

```
Result: 0.16 px
```

No assumptions about activation shape. The cost is a larger head input (1024 vs 128 for spatial softmax) but more information preserved. The head can learn whatever mapping from spatial patterns to predictions the data supports.

**The key insight:** The 4×4 grid doesn't just encode "where" — it encodes "how the activation is distributed." This is strictly more information than a single (x, y) coordinate, and the head can learn to use distribution shape (spread, orientation, multi-modality) as additional signal.

### Choosing a readout

|Method|Preserves|Assumes|Head input size|Optimization|
|---|---|---|---|---|
|Global pool|Nothing spatial|Location doesn't matter|C|Easy|
|Spatial softmax|Precise position|Unimodal activations|2C|Needs gentle LR|
|Grid pool (N×N)|Distribution shape|Nothing|C × N²|Easy|

For spatial tasks, the practical choice is between spatial softmax and grid pool. Spatial softmax is more compact (2C vs 16C for 4×4) and works well when channels are peaked. Grid pool is more robust and works regardless of activation shape, at the cost of a larger head. With proper training, both reach similar accuracy — but grid pool is more forgiving of sloppy optimization.

---

## Part 3: The head

The head is usually treated as an afterthought — "just throw a linear layer on top." But it's where cross-feature reasoning happens, and its capacity determines how much the readout can afford to preserve.

### Head capacity determines readout choice

With multi-scale tap and 4×4 pool, the head input is 3 scales × 64 channels × 16 positions = 3072 features. The head in our best model is 3072→512→4, which is 1.57M parameters — more than the entire encoder.

This massive head is why multi-scale tap works: the head has enough capacity to learn arbitrary relationships between scales, channels, and spatial positions. A smaller head (3072→64→4) would bottleneck the information, and the large readout would be wasted.

**The tradeoff:** More information from the readout requires more head capacity to decode. Spatial softmax compresses to 128 features, needing a small head. Grid pool preserves 1024+ features, needing a large head. The total param count might be similar — you're just choosing whether to spend parameters in the readout (spatial softmax's learned coordinates) or the head (grid pool's pattern decoder).

### When the head is the bottleneck

If your encoder and readout are good but accuracy plateaus, check head capacity. Signs the head is the bottleneck: train loss plateaus well above zero (underfitting), and making the head wider/deeper improves both train and val loss.

Signs the head is NOT the bottleneck: train loss is near zero but val loss is much higher (overfitting), or val loss matches train loss and neither improves (encoder/readout is the limit).

---

## How these parts interact

The three parts aren't independent. Each choice constrains what the others need to do.

**Weak encoder + strong readout + big head:** Multi-scale tap. The encoder just produces features at different depths; the 4×4 grid preserves everything; the head does all the reasoning. Works but expensive.

**Strong encoder + any readout + small head:** FPN. The encoder pre-merges cross-scale information; even spatial softmax or global pool preserves enough because the features are already enriched. Parameter-efficient.

**Weak encoder + weak readout + big head:** Baseline with global pool. The head tries to compensate for lost spatial information by memorizing channel-level patterns. Doesn't work well (0.48 px).

**Strong encoder + strong readout + big head:** Overkill for most tasks, but if accuracy is all that matters, this is where you end up.

The design question is: given a parameter budget, where should the "intelligence" live? In the encoder (FPN, skip connections), the readout (grid pool, spatial softmax), or the head (large linear layers)?

For our task, the answer was: invest in readout (4×4 pool) and head (512 hidden units), with a simple encoder. The readout choice mattered 3× more than the encoder architecture.

---

## Summary: what to try in what order

When building a CNN regression model from scratch:

1. **Start with grid pool readout, not global pool.** This is the single highest-impact choice. Pick N×N based on how much spatial precision you need (4×4 is a good default).
    
2. **Add multi-scale tapping.** Read features at 2-3 depths in the encoder. Don't just use the final layer. The jump from single-scale to multi-scale is typically the second-largest improvement.
    
3. **Size the head to match the readout.** If your readout produces K features, the first hidden layer should be at least K/4 to K/2. A readout that preserves everything into a tiny head wastes the preservation.
    
4. **Add skip connections.** Near-zero cost, always helps gradient flow. Essential if your encoder exceeds ~10 layers.
    
5. **Consider FPN if param-constrained.** If you can't afford a large head, FPN offloads cross-scale reasoning to the encoder. If you can afford a large head, multi-scale tap is simpler and equally effective.
    
6. **Check spatial softmax only if channels are peaked.** Visualize your feature maps first. If they're point-like, spatial softmax is elegant and compact. If they're diffuse, grid pool is safer. Either way, use proper LR scheduling — spatial softmax is more sensitive to optimization.
    
7. **Look at your errors before changing architecture.** If errors concentrate at data boundaries or specific conditions, the fix is data, not architecture.