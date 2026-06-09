# How Robot Policies Are Evaluated: Who Decides Success, and the Eval Landscape

_A research brief on evaluating robot foundation models / fine-tuned manipulation policies (VLAs, LBMs, diffusion policies). Current as of June 2026._

---

## The framework: three orthogonal questions

Every approach to evaluating a robot policy reduces to choices on three independent axes. They are orthogonal — any combination is possible — which is why the space divides cleanly and why each axis can be a separate product/competition.

1. **What do you measure?** — the _estimand_. Either an **absolute success probability** (how often this policy succeeds at a task, on a 0–100% scale) or a **relative ranking** (Elo / Bradley-Terry from pairwise comparisons — "is A better than B"). Absolute answers deployment questions; relative is better-posed and cheaper for open-ended generalist comparison, but gives no deployment-ready number.
2. **Who judges each rollout?** — **human** vs **automated** (a VLM / learned success classifier). Independent of axis 1: you can have a human or a VLM produce either an absolute label or a pairwise preference.
3. **How well do you measure it?** — the measurement process, itself two parts: **how long** (sample size → confidence-interval width, which shrinks as 1/√n, so 4× the rollouts to halve the interval) and **how repeatable** (environment control, blinding, standardized protocol, reproducibility across labs).

### The approaches mapped onto the axes

|Approach|① What it measures|② Who judges|③ How much / how repeatable|References|
|---|---|---|---|---|
|**AutoEval**|Absolute success rate|Automated — fine-tuned VLM classifier (PaliGemma)|Cheap & autonomous (24/7) → easy high-N; reproducible via fixed public stations + auto reset|Zhou et al., CoRL 2025 — arXiv:2503.24278; auto-eval.github.io|
|**RoboArena**|**Relative** — Elo / ranking (Bradley-Terry)|Human — double-blind pairwise|600+ pairwise episodes, distributed across 7 institutions; reproducible via blinding + shared DROID platform (tasks free-chosen)|Atreya et al., CoRL 2025 — arXiv:2506.18123|
|**RoboChallenge**|Absolute — _graded_ progress score (not binary)|Human — operators applying fixed staged rubric|10 rollouts/task; reproducible via centralized fleet + identical rubric for all submitters|Dexmal + Hugging Face, 2025 — arXiv:2510.17950 (grading protocol §3.2); robochallenge.ai|
|**TRI "Careful Examination"**|Absolute success rate, with explicit CIs|Human — blind|Large N + statistical power analysis (Clopper-Pearson CIs); reproducible via randomized blind trials, seen/unseen × nominal/shift|TRI LBM Team, 2025 — arXiv:2507.05331|
|**Physical Intelligence (π0 / π0.5)**|Absolute success rate (partial credit on multi-stage)|Human (blind in Hi Robot)|~10–20 real trials/task; reproducibility leans on video evidence + LIBERO sim numbers; real-world less standardized|π0: pi.website/blog/pi0; Hi Robot blind-human protocol — arXiv:2502.19417|
|**LIBERO** (sim)|Absolute success rate|Scripted — sim ground-truth rule|Very cheap → high N; fully deterministic & reproducible (simulation)|Liu et al., NeurIPS 2023 — arXiv:2306.03310|
|**SIMPLER** (real-to-sim)|Absolute, engineered to _correlate with real_|Scripted — sim ground-truth rule|Cheap high-N; highly reproducible, scene-matched to real setups|Li et al., 2024 — arXiv:2405.05941|
|**StepEval** (subgoal scoring)|Absolute — _per-subgoal_ success vector|Automated — VLM|Adds granularity (where it failed) rather than sample size; reproducibility = judge consistency|"Score the Steps, Not Just the Goal," 2025 — arXiv:2509.19524|
|**WorldEval**|Absolute success of rollouts _in a learned world model_|Automated — VLM (Gemini-2.0)|No real robot → cheap & repeatable, but bounded by world-model fidelity|WorldEval, 2025 — arXiv:2505.19017|

_Off-axis:_ **SAFE** (arXiv:2506.09937) is failure detection _during_ execution — a safety/monitoring layer, not a way of scoring a finished rollout.

Two patterns stand out: column ① is almost entirely "absolute," with RoboArena the lone Elo outlier; and the sim/automated rows cluster in cheap-high-N territory, while the real-world human rows are exactly where the sample-size cost (and the whole statistical-rigor conversation) bites.

---

## 1. Why this is hard (and unlike LLM eval)

There is no static benchmark with an automatic grader for a robot policy. You have to physically run the robot on a task, and the honest outcome is close to binary: did it complete the task or not. That makes evaluation **slow, expensive, hardware-dependent, and extremely noisy**. Two consequences flow from this and structure the whole field:

1. **Someone or something has to judge each rollout** — the "who decides success" question.
2. **You need many rollouts to say anything statistically** — and most papers historically ran far too few.

Everything below is the field trying to solve one or both of these.

---

## 2. Who determines success / failure

This is the crux. There are five broad approaches, roughly in order of how the field has evolved:

### (a) Human raters — the default

A person watches the rollout (live or on video) and marks success/failure, often against a written rubric, sometimes with partial credit for multi-stage tasks. This is the ground truth everyone else tries to approximate. It's accurate but doesn't scale, is slow, and is vulnerable to bias if the rater knows which policy they're watching.

### (b) Scripted / programmatic checks (simulation only)

In a simulator you have privileged access to ground-truth state (object poses, joint angles), so success can be computed by a rule — e.g. "is the block within X cm of the target and the gripper open." Cheap, deterministic, fully automated. Only available in sim, and the rule can be gamed by behaviors that satisfy the check without doing the task "properly."

### (c) Learned success classifiers

Train a model to output a binary success label from a camera image. This dates back at least to **Transporter Networks (2020)**, which trained a ResNet-50 to classify kit completion at ~97% accuracy to avoid manual labeling. The modern version is **AutoEval (2025)**, which fine-tunes a vision-language model (PaliGemma) into a yes/no VQA detector ("Is the drawer open?"). The appeal: one recipe generalizes across tasks with a small amount of labeled data, instead of hand-crafting a rule per task.

### (d) VLM-as-judge / subgoal scoring

Use a general-purpose vision-language model as a black-box judge. **WorldEval (2025)** uses Gemini-2.0 to watch a (generated) video and answer whether the task succeeded. **StepEval / "Score the Steps, Not Just the Goal" (2025)** pushes further: instead of one binary number, a VLM scores each _subgoal_ (grasp → lift → place), producing a per-subgoal success-rate vector. This reveals _where_ a policy fails — their motivating example is a pancake-flip policy that completed the first two stages 100% of the time but scored only 17% overall because it always failed the final plating step. A single success number hides that entirely.

### (e) Pairwise human preference (no absolute label at all)

**RoboArena (2025)** sidesteps absolute success scoring. Evaluators run two policies on the same task and just say which did better (double-blind). Aggregating these pairwise preferences across many tasks yields a ranking — the same Elo-style approach used for ranking chatbots. This avoids the problem that "success" is ill-defined or task-specific, and is robust because no single rater's rubric dominates.

**The trend line:** the field is moving _away_ from "a human marks each trial" toward **learned/VLM judges** (to automate) and **pairwise preference** (to make judging well-posed and bias-resistant). The judge itself is becoming a modeled, evaluated component.

---

## 3. The statistical rigor problem — TRI's "Careful Examination" (2025)

The Toyota Research Institute Large Behavior Models paper is essential reading because it's _about the methodology_, not a new model. Its core finding: noise from experimental variation can dwarf the effect you're trying to measure, so many robotics papers may be reporting statistical noise from too few trials.

The number that makes this concrete: with ~50 rollouts (say 10 each on 5 behaviors), Clopper-Pearson confidence intervals are typically **20–30% wide** in absolute success rate — wide enough that all but the largest differences between policies are unmeasurable.

Their pipeline borrows from clinical trials:

- **Blind, randomized trials** — operators don't know which policy they're running.
- **Single-task baselines** compared head-to-head.
- **Large sample sizes** with explicit confidence intervals and hypothesis testing.
- **Seen vs unseen tasks** (in pretraining data or not).
- **Nominal vs distribution-shift conditions** (object poses/quantities perturbed via rejection sampling).

Headline result: multitask pretraining makes policies more successful and robust and lets you teach new tasks with a fraction of the data; performance scales smoothly with pretraining scale and diversity, with no sharp inflection points at the scales tested.

---

## 4. The two arenas: simulation vs real

### Simulation benchmarks (cheap, reproducible, automated grading)

- **LIBERO** — Franka Panda, 4 suites (Spatial, Object, Goal, Long), 10 tasks each, ~50 episodes per task. The de-facto standard for in-distribution VLA comparison. Now extended by **LIBERO-Plus**, which stress-tests across seven perturbation dimensions.
- **RLBench, CALVIN, Meta-World, ManiSkill, Colosseum, BEHAVIOR-1K, PerAct2** — the older/broader simulation benchmark family. Most assume train and test in the _same_ sim environment, which can favor specialist policies over generalists.

### Real-to-sim benchmarks (sim that predicts real performance)

- **SIMPLER / SimplerEnv (Li et al., 2024)** — the key one. Simulated replicas of real setups (WidowX/BridgeData V2 and Google Robot/RT-1), explicitly engineered to minimize the sim-to-real gap so sim scores correlate with real-world success. Two modes: **Visual Matching** (high fidelity to the real scene) and **Variant Aggregation** (inject lighting/background/texture/distractor perturbations to test robustness).
- **RobotArena ∞ (2025)** — uses real-to-sim _translation_ plus crowdsourced evaluation by everyday end-users rather than roboticists; its BridgeSim (70 environments) is harder than SIMPLER but preserves relative model rankings.

A recurring caveat (e.g. from the MolmoBot work): these benchmarks were built around specific datasets and embodiments, so they can be a poor fit for _zero-shot_ evaluation of generalist cross-embodiment policies — hence efforts like SIMPLER-DROID / LIBERO-DROID to swap in a common platform.

---

## 5. Scaling real-world evaluation: the infrastructure plays

This is where "eval tooling for robots" actually lives. Three distinct architectures have emerged in 2025:

|System|Architecture|Judge type|Judge differentiator|Key idea|
|---|---|---|---|---|
|**AutoEval** (Berkeley/Levine)|Autonomous single-station|**Automated** — learned success classifier (fine-tuned PaliGemma VLM)|_Auto:_ generalizes across tasks via a fine-tuned VLM (yes/no VQA) instead of per-task hand-coded rules, validated against human ground truth; also automates scene reset + safety so no human is needed in the loop at all|Removes the human from the loop: success classifier + learned **reset policy** + safety/fault detection → 24/7 eval. Submit jobs to a queue like a compute cluster; get back success rates + videos. Public WidowX/BridgeData stations.|
|**RoboArena** (Stanford/Berkeley/NVIDIA et al.)|Distributed / crowdsourced|**Human** — double-blind pairwise preference|_Human:_ judges relative ("which is better") not absolute success, so no shared success rubric needed; double-blind kills rater bias; distributed across many sites so diversity scales|No fixed tasks; evaluators across 7 institutions on the DROID platform pick their own tasks but must do blind A/B comparisons. 600+ pairwise episodes ranked 7 policies more reliably than centralized eval.|
|**RoboChallenge** (Dexmal + Hugging Face)|Centralized real-robot fleet-as-a-service|**Human** — operator applying a standardized staged rubric|_Human:_ a fixed **graded progress-score** rubric (stages × points, −0.5 per retry) rather than binary success, applied identically by facility staff for reproducibility across all submitters|A fleet of ~10 real machines (ARX-5 arms, RealSense cameras) served behind online APIs; no checkpoint/Docker exchange needed. Initial "Table30" benchmark surveys SOTA VLAs reproducibly.|

These map to three philosophies: **automate the judge** (AutoEval), **make the judge well-posed and distributed** (RoboArena), and **centralize the hardware and standardize the protocol** (RoboChallenge).

---

## 6. Failure detection as its own subfield

Distinct from _scoring_ a finished rollout is detecting failure _during_ execution (so the robot can stop, retry, or ask for help). **SAFE (2025)** does multitask failure detection for VLA models, learning from a policy's internal features to predict failure across tasks it wasn't trained to monitor. This matters for deployment and for the safety/fault-detection layer that systems like AutoEval also need.

---

## 7. What this means for tooling (the market angle)

If you're mapping the space, the durable product surfaces are:

1. **Orchestration** — scheduling hundreds of sim + real rollouts, queueing jobs, managing robot fleets (AutoEval/RoboChallenge are the open templates).
2. **The judge** — success classifiers and VLM-as-judge pipelines, ideally with subgoal granularity (StepEval) rather than a single binary. This is itself an ML problem that needs its own validation.
3. **Statistical rigor as a feature** — power analysis, confidence intervals, blinded/randomized trial design baked in, so customers stop shipping decisions based on noise (TRI's whole thesis).
4. **Reset & environment management** — automated scene resets are a surprisingly large share of the human cost AutoEval had to eliminate.
5. **Real-to-sim** — translating real scenes into simulators good enough to predict real performance (SIMPLER, RobotArena∞), because sim is the only thing that scales cheaply.

The Pi papers show the _demonstration_ burden (many real tasks, lots of rollouts, video evidence); the TRI paper shows the _statistical_ burden. A tooling company is fundamentally selling a way to make both cheaper and more trustworthy — closer to "CI/CD + experiment tracking + a clinical-trial stats layer for robots" than to a classic ML eval dashboard.

---

## 8. Key papers & links

**Methodology / rigor**

- TRI LBM Team — _A Careful Examination of Large Behavior Models for Multitask Dexterous Manipulation_ (2025) — arXiv:2507.05331 — https://arxiv.org/abs/2507.05331 ; site: https://toyotaresearchinstitute.github.io/lbm1/

**Models with notable eval sections**

- Physical Intelligence — _π0: A Vision-Language-Action Flow Model for General Robot Control_ (2024) — https://www.pi.website/blog/pi0 ; PDF: https://www.pi.website/download/pi0.pdf
- openpi (π0 / π0.5 code, LIBERO eval workflow) — https://github.com/Physical-Intelligence/openpi

**Who-decides-success / judges**

- Zhou, Atreya, Tan, Pertsch, Levine — _AutoEval: Autonomous Evaluation of Generalist Robot Manipulation Policies in the Real World_ (CoRL 2025) — arXiv:2503.24278 — https://arxiv.org/abs/2503.24278 ; site: https://auto-eval.github.io/ ; code: https://github.com/zhouzypaul/auto_eval
- _Score the Steps, Not Just the Goal: VLM-Based Subgoal Evaluation_ (StepEval, 2025) — arXiv:2509.19524 — https://arxiv.org/pdf/2509.19524
- _WorldEval: World Model as Real-World Robot Policies Evaluator_ (2025) — arXiv:2505.19017 — https://arxiv.org/pdf/2505.19017
- _SAFE: Multitask Failure Detection for Vision-Language-Action Models_ (2025) — arXiv:2506.09937 — https://arxiv.org/pdf/2506.09937
- Transporter Networks (early learned success classifier, 2020) — arXiv:2010.14406

**Distributed / centralized real-world eval**

- Atreya et al. — _RoboArena: Distributed Real-World Evaluation of Generalist Robot Policies_ (CoRL 2025) — arXiv:2506.18123 — https://arxiv.org/abs/2506.18123
- Dexmal + Hugging Face — _RoboChallenge: Large-scale Real-robot Evaluation of Embodied Policies_ (2025) — arXiv:2510.17950 — https://robochallenge.ai/
- _RobotArena ∞: Scalable Robot Benchmarking via Real-to-Sim Translation_ (2025) — arXiv:2510.23571

**Simulation / real-to-sim benchmarks**

- SIMPLER / SimplerEnv (Li et al., 2024) — real-to-sim eval for WidowX & Google Robot
- LIBERO (Liu et al., 2024) and LIBERO-Plus — Franka Panda lifelong-manipulation suites
- RLBench, CALVIN, Meta-World, ManiSkill, Colosseum, BEHAVIOR-1K — broader sim benchmark family

---

_Note: this is a fast-moving area — arXiv numbers in the 2602._ range indicate very recent (2026) preprints. Treat success-rate figures as point-in-time and method-dependent; the central lesson of the literature is that the evaluation protocol matters as much as the policy.*