
Here are the links and a clean experiment list.

**Papers**

1. **Do Foundation Models Know Geometry?** (the 2026 frozen-feature probing study) — https://arxiv.org/abs/2603.06459 — probes frozen features of 14 models for continuous geometric quantities; finds training objective—not architecture—determines geometric accuracy, with attention pooling helping and geometry being spatially task-dependent. This is the methodology for your probe.
    
2. **FeatUp** (feature upsampling) — paper https://arxiv.org/abs/2403.10516, code https://github.com/mhamilton723/FeatUp. It restores spatial resolution lost because models aggressively pool information over large areas, as a drop-in (`torch.hub.load`), model-agnostic so it works on your ConvNeXt.
    
    - **AnyUp** (newer, encoder-agnostic successor) — https://arxiv.org/abs/2510.12764, project page https://wimmerth.github.io/anyup/.
    - **Sub-mm with frozen DINOv3 + AnyUp on 48 images** (almost your exact regime) — https://arxiv.org/abs/2604.16758. They found the native grid too coarse for our sub-millimeter localization and fixed it with guided upsampling.
3. **RoMa** (coarse-frozen + fine-ConvNet hybrid) — https://arxiv.org/abs/2305.15404 — uses a frozen DINOv2 coarse encoder plus a dedicated ConvNet for fine features because DINOv2 in dense feature matching is still complicated due to the lack of fine features, which are needed for refinement, and separate specialization beats joint training.
    
4. **DINO-VO** — https://arxiv.org/abs/2507.13145 — same hybrid: it complements DINOv2's robust-semantic features with fine-grained geometric features for more localizable representations, and its ablation shows DINOv2-alone is better on heavily-disturbed sequences (robustness) while the FinerCNN adds the localization — exactly your coarse-robust vs fine-precise tradeoff.
    
5. **For the reference-image route (when you get to it):** DINOBot — https://arxiv.org/abs/2402.13181 (frozen-DINO dense correspondence + alignment against a stored target), and Bateux et al., _Visual Servoing from Deep Neural Networks_ — https://arxiv.org/abs/1705.08940 (Siamese current-vs-target difference regression, sub-mm).
    

**Experiments**

1. **Probe (run first — fast, decisive).** Linear then MLP probe on the _unpooled_ stage-4 map → z and y separately; report per-axis R²/MAE. Tells you whether z exists in the features and its ceiling. While there, test attention pooling vs avg pooling (per paper 1).
    
2. **Hybrid coarse-DINO + fine-scratch fusion (main bet).** Frozen DINO for the robust/coarse path + your scratch CNN for fine features, fused with the firewall gate. This is the RoMa/DINO-VO architecture and your original plan. Since z is the broken axis, the fine path only has to fix z.
    
3. **FeatUp/AnyUp before the spatial head.** Upsample the 28×28 features (guided by the 896px RGB), then your spatial SimCC head. Directly attacks the resolution ceiling that capped the spatial run.
    
4. **Real partial fine-tune.** Remove the `no_grad`, unfreeze the last ConvNeXt stage (or LoRA/BitFit), retest. You tried unfreezing before, but the `no_grad` wrapper may have nullified it — LoRA is the cheaper, cleaner retry, and paper 4's ablation suggests last-stage adaptation is where localization gets added.
    
5. **Reference-image / relative ceiling (later, on your cue).** Current-vs-target via Siamese difference (Bateux) or DINOBot-style correspondence. Establishes the achievable ceiling.
    

Run 1 before building anything in 2–4 — it tells you whether z is recoverable at all, which decides how much the hybrid and upsampling can buy you.




# Log

Average Pool can only let information passthrough as magintude. Therefore, the network before average pool must encode information as magnitude.

Soft-argmax can average bimodal or multimodal distribution

Later pixels have larger receptive field, but diluted / compres

![[Pasted image 20260605181053.png]]