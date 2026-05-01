# Real-Time Chunking (RTC): Paper vs LeRobot Implementation

---

## Phase 1: The True Algorithm (ΠGDM + σ_d fix)

### Setup

We have a flow-matching VLA that generates action chunks of size H (e.g. 50). Denoising runs for n steps. The paper uses τ ∈ [0,1] where 0 = noise, 1 = clean.

Given:

- `x_τ`: noisy action chunk at denoising time τ
- `v(x_τ, o, τ)`: learned velocity field from the model
- `Y`: previous chunk's tail (inpainting target)
- `W`: soft mask (1 = frozen, decaying = guided, 0 = free)
- `β`: guidance weight clipping parameter
- `σ_d`: assumed prior data standard deviation

### Per-step algorithm

```
for each denoising step (τ going from 0 toward 1):

    # A. Normal flow-matching velocity
    v = model(x_τ, obs, τ)

    # B. Predict clean actions (Tweedie-like estimate)
    Â¹ = x_τ + (1 - τ) * v

    # C. Compute r_τ² (noise-schedule variance, depends on σ_d)
    r² = (1 - τ)² * σ_d² / ((1 - τ)² + σ_d² * τ²)

    # D. Guidance weight with clipping
    raw_weight = (1 - τ) / (τ * r²)
    guidance_weight = min(β, raw_weight)

    # E. Masked error
    err = (Y - Â¹) * W

    # F. FULL Jacobian via backward pass through the model
    J = ∂Â¹/∂x_τ = I + (1 - τ) * ∂v/∂x_τ

    # G. Vector-Jacobian product (correction direction)
    correction = Jᵀ @ err

    # H. Corrected velocity
    v_rtc = v + guidance_weight * correction

    # I. Euler step
    x_{τ+Δτ} = x_τ + Δτ * v_rtc

    # J. Hard-replace frozen prefix
    x_{τ+Δτ}[:d] = Y[:d]
```

### The mask W (paper semantics)

The mask is built relative to the inference delay d:

```
Position:  [0 ... d-1] [d ... d+s-1]  [d+s ... H-1]
Mask W:    [  1.0     ] [ decay→0   ]  [    0.0     ]
Role:       frozen       guided          free

s = ramp width (how many steps of soft blending)
d = inference delay (frozen prefix length)
```

The ramp width `s` is an independent parameter separate from `d`.

### σ_d: the Cobot improvement

The original RTC paper assumes σ_d = 1.0, borrowed from image generation where the unconditional prior p(x) is broad (standard normal over normalized pixels).

For robot actions conditioned on an observation, the distribution p(A|o) is much narrower — given a specific scene, only a small region of action space is plausible.

Effect on guidance weight at mid-denoising (τ = 0.5):

```
σ_d = 1.0:  raw_weight = (0.5 / 0.5) * (0.25 + 0.25) / 0.25  = 2.0
σ_d = 0.2:  raw_weight = (0.5 / 0.5) * (0.25 + 0.04*0.25) / (0.25*0.04) = 26.0
```

~13x stronger guidance. This forces the denoising process to take the inpainting constraint much more seriously throughout the denoising trajectory, not just at early steps.

Recommended: σ_d = 0.2, β = n (number of denoising steps).

### The Jacobian: why it matters

The Jacobian ∂Â¹/∂x_τ captures how the model's nonlinear processing maps changes in noisy inputs to changes in predicted clean outputs. The full Jacobian tells you: "to move the predicted clean output by δ, what direction should I push the noisy input?"

This is more efficient than just pushing in the direction of the error (J=I), because the model may respond differently along different dimensions. Some noisy-space directions have large effects on the output, others have small effects. The Jacobian finds the most efficient correction.

Cost: requires a backward pass through the model at every denoising step, roughly doubling inference time.

---

## Phase 2: What LeRobot Actually Implements

### Time convention

LeRobot uses time ∈ [1, 0] where 1 = noise, 0 = clean (reversed from paper). The code converts: `tau = 1 - time`.

### Per-step algorithm (actual code)

```python
def denoise_step(self, x_t, prev_chunk_left_over, inference_delay, 
                 time, original_denoise_step_partial, execution_horizon):
    tau = 1 - time

    # A. Normal velocity (model forward pass)
    v_t = original_denoise_step_partial(x_t)

    # B. Enable grad AFTER model runs (v_t is now a detached constant)
    x_t.requires_grad_(True)

    # C. Predicted clean actions
    x1_t = x_t - time * v_t        # equivalent to Â¹ = x_τ + (1-τ)*v

    # D. Masked error
    err = (prev_chunk_left_over - x1_t) * weights

    # E. "Jacobian" computation — but J = I because v_t is detached
    correction = torch.autograd.grad(x1_t, x_t, grad_outputs=err)[0]
    # Since x1_t = x_t - time * constant:
    #   ∂x1_t/∂x_t = I
    #   correction = I @ err = err

    # F. Guidance weight (σ_d = 1.0 hardcoded)
    squared_one_minus_tau = (1 - tau) ** 2
    inv_r2 = (squared_one_minus_tau + tau ** 2) / squared_one_minus_tau
    c = (1 - tau) / tau
    guidance_weight = min(c * inv_r2, max_guidance_weight)

    # G. Corrected velocity
    result = v_t - guidance_weight * correction

    return result
```

Which simplifies to:

```python
v_t = model(x_t, obs, time)
x1_t = x_t - time * v_t
err = (prev - x1_t) * weights
guidance_weight = min(β, (1-τ)/τ * ((1-τ)² + τ²)/(1-τ)²)
v_corrected = v_t - guidance_weight * err
x_t = x_t + dt * v_corrected
```

No Jacobian. No hard replacement. Just: compute error, scale it, add to velocity.

### The mask W (LeRobot semantics — DIFFERENT from paper)

```python
get_prefix_weights(start=inference_delay, end=execution_horizon, total=H)
```

Both `start` and `end` are **absolute indices**, not relative:

```
If inference_delay=4, execution_horizon=10, total=50:

Position:  [0  1  2  3] [4  5  6  7  8  9] [10 ... 49]
Mask W:    [   1.0     ] [   ramp 1→0      ] [   0.0   ]
                          ← only 6 steps! →

Ramp width = execution_horizon - inference_delay = 6
```

Compare to the paper's semantics where execution_horizon would be the ramp width itself:

```
Paper (d=4, s=10):

Position:  [0  1  2  3] [4 ... 13]  [14 ... 49]
Mask W:    [   1.0     ] [ramp 1→0] [   0.0    ]
                          ← 10 steps →
```

This means if you set inference_delay=8, execution_horizon=10, you only get a 2-step ramp. Easy to accidentally make the ramp too short.

### The outer loop

```python
# In PI0Pytorch.sample_actions:
dt = -1.0 / num_steps
x_t = noise

for step in range(num_steps):
    time = 1.0 + step * dt

    v_t = rtc_processor.denoise_step(
        x_t, prev_chunk_left_over, inference_delay,
        time, denoise_step_callable, execution_horizon
    )

    x_t = x_t + dt * v_t
    # No hard replacement of frozen prefix here
```

---

## Phase 3: Issues and Fixes

### Issue 1: Jacobian approximated as identity

**What the paper does:** Full backward pass through the model to compute ∂Â¹/∂x_τ, which captures how the model's nonlinear processing routes corrections from noisy space to clean space.

**What LeRobot does:** Sets requires_grad after the model forward pass, so the Jacobian collapses to identity. correction = err.

**Why it's done this way:** Avoids a backward pass through the full transformer at every denoising step. With n=10 denoising steps, this saves 10 backward passes per inference call — roughly halving latency.

**Impact:** The correction direction is less optimal. Instead of following the model's gradient landscape to find the most efficient fix, it just pushes directly in the error direction. For small errors this is fine (first-order approximation), but for large errors it's suboptimal.

**Fix options:**

Option A — Full Jacobian (accurate but slow):

```python
# Enable grad BEFORE model runs
x_t = x_t.requires_grad_(True)
v_t = original_denoise_step_partial(x_t)
x1_t = x_t - time * v_t
err = (prev_chunk_left_over - x1_t) * weights
correction = torch.autograd.grad(x1_t, x_t, grad_outputs=err)[0]
# Now correction includes model gradient: (I - time * ∂v/∂x_t)ᵀ @ err
```

Option B — Keep identity approximation, compensate with stronger σ_d: This is the recommended approach. The identity Jacobian is directionally correct (it just pushes toward the target), so making the push stronger via smaller σ_d compensates for the less efficient direction.

### Issue 2: No hard replacement of frozen prefix

**What the paper does:** After each Euler step, hard-overwrite the first d actions: `x_t[:, :d, :] = Y[:, :d, :]`

**What LeRobot does:** Only soft guidance via weights=1.0 in the frozen region. The guidance pushes toward Y[:d] but doesn't guarantee exact match.

**Impact:** The first d actions of the new chunk may not exactly equal the previous chunk's values at those positions. When you discard stale actions on the client side and start executing from action d, there can be a small discontinuity between the last executed old-chunk action and the first executed new-chunk action.

**Fix (in PI0Pytorch.sample_actions, inside the denoising loop):**

```python
x_t = x_t + dt * v_t

# Add hard replacement after each Euler step
if (prev_chunk_left_over is not None 
    and inference_delay is not None 
    and inference_delay > 0):
    x_t[:, :inference_delay, :] = prev_chunk_left_over[:, :inference_delay, :]
```

### Issue 3: σ_d hardcoded to 1.0

**What the paper does:** Assumes σ_d = 1.0 (reasonable for image generation).

**What should be done for robots:** σ_d ≈ 0.2 (narrow action distribution conditioned on observation).

**Impact:** Guidance weight is ~13-25x weaker than it should be at mid-denoising. The inpainting constraint is too soft, leading to visible discontinuities at chunk boundaries.

**Fix in RTCConfig (configuration_rtc.py):**

```python
@dataclass
class RTCConfig:
    # ... existing fields ...
    sigma_d: float = 0.2    # ADD THIS
```

**Fix in RTCProcessor.denoise_step (modeling_rtc.py):**

```python
# Replace:
inv_r2 = (squared_one_minus_tau + tau_tensor**2) / (squared_one_minus_tau)

# With:
sigma_d_sq = self.rtc_config.sigma_d ** 2
inv_r2 = (squared_one_minus_tau + sigma_d_sq * tau_tensor**2) / (squared_one_minus_tau * sigma_d_sq)
```

### Issue 4: Mask semantics (absolute vs relative)

**What might be expected:** execution_horizon = ramp width. Setting execution_horizon=10 gives a 10-step ramp after the frozen prefix.

**What actually happens:** execution_horizon = absolute end index. Setting execution_horizon=10 with inference_delay=4 gives a 6-step ramp. Setting execution_horizon=10 with inference_delay=8 gives a 2-step ramp.

**Impact:** If inference_delay is close to execution_horizon, the ramp is very short and transitions are abrupt.

**Fix:** Either:

- (A) Always set execution_horizon = inference_delay + desired_ramp_width
- (B) Modify the code to treat execution_horizon as relative ramp width

Option A (no code change):

```python
desired_ramp = 10
RTCConfig(
    execution_horizon=inference_delay + desired_ramp,  # e.g. 4+10=14
)
```

### Summary: priority of fixes

|Fix|Impact|Effort|Recommendation|
|---|---|---|---|
|Add σ_d = 0.2|High|2 lines|Do first|
|Hard-replace prefix|Medium|3 lines|Do second|
|Set β = n|Medium|Config only|Do third|
|Fix mask semantics|Low-Med|Config math|Adjust execution_horizon|
|Full Jacobian|Low-Med|Expensive|Skip unless still bumpy|

### Complete minimal patch

```python
# ──── configuration_rtc.py ────
@dataclass
class RTCConfig:
    enabled: bool = True
    execution_horizon: int = 10
    max_guidance_weight: float = 10.0   # set to n (num denoising steps)
    prefix_attention_schedule: RTCAttentionSchedule = RTCAttentionSchedule.EXP
    sigma_d: float = 0.2               # ← NEW
    debug: bool = False
    debug_maxlen: int = 50


# ──── modeling_rtc.py (in denoise_step) ────
# Replace the inv_r2 line:

sigma_d_sq = self.rtc_config.sigma_d ** 2
inv_r2 = (squared_one_minus_tau + sigma_d_sq * tau_tensor**2) / (squared_one_minus_tau * sigma_d_sq)


# ──── modeling_pi0.py (in sample_actions, inside the denoising loop) ────
# After: x_t = x_t + dt * v_t
# Add:

prev_chunk_left_over = kwargs.get("prev_chunk_left_over")
inference_delay = kwargs.get("inference_delay")
if (prev_chunk_left_over is not None 
    and inference_delay is not None 
    and inference_delay > 0):
    d = min(inference_delay, x_t.shape[1])
    prev = prev_chunk_left_over
    if prev.shape[1] >= d:
        x_t = x_t.clone()
        x_t[:, :d, :prev.shape[2]] = prev[:, :d, :]
```