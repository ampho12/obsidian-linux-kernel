# Background

This document grounds the framework's core concepts. The template for pitch construction sits on top of this — these are the conceptual building blocks every section of a pitch refers back to.

---

## 1. Risk and Tiered Classification

Risk is the amount of work remaining before returns. As work is completed, risk decreases. The risk curve is always decreasing — what differs across fields is where on the curve they currently sit and how rapidly they move down it.

The three tiers classify position on the curve:

**Tier 1 — Research (one of a kind)**
- Substantial work remaining before any commercial return.
- No commercial precedent. Feasibility itself is the open question.
- Examples: fusion before NIF's net-gain demonstration; early CRISPR; large-scale quantum computing.

**Tier 2 — Deep Tech (N of a kind)**
- Significant engineering work remaining, but feasibility is established.
- A small number of commercial or proximal demonstrations exist.
- The science is done; the engineering is hard.
- Examples: Varda re-entry, K2 high-power satellites, autonomous SMRs.

**Tier 3 — Execution (multiple of a kind)**
- Returns are immediate; remaining work is competitive iteration.
- Many commercial precedents; the category is established.
- Examples: SaaS, modern automotive, e-commerce, consumer electronics manufacturing.

A field's tier is not fixed. It moves down the curve as work gets done. Today's tier 2 was tier 1 some years ago; today's tier 3 was tier 2 not long before. Risk decay over time is what causes tier transitions.

---

## 2. Premise: Why a Field is in Tier 2

A premise establishes which tier a field currently occupies — and specifically why it is in tier 2 rather than tier 1 (work is unbounded) or tier 3 (work is competitive iteration).

A premise takes one of three forms; they can stack:

**Trend** — observable past and present change in the world that has moved a field from tier 1 down to tier 2.
- Launch costs fell 20x in a decade (Varda — brings orbital manufacturing from tier 1 to tier 2).

**Pattern** — historical induction from a different field that previously made the same tier transition, suggesting this field will follow the same arc.
- Language models followed research → deep tech → execution (n-gram → LSTM → GPT-2/3 → today). The same arc applies to other fields where the underlying science has crossed similar thresholds.
- Every successful surgical robotics company combined new vision modality + robotics; the pattern repeats with new modalities.

**Cross-domain analogy** — structural similarity to another field already in tier 3 that suggests the same dynamic will play out here.
- Data centers won on Earth by having the most power; the same dynamic will play out in orbit (K2).

The premise must justify the specific classification. Pointing to past breakthroughs argues "not tier 1." Pointing to remaining work argues "not tier 3." 

---

## 3. Vision

Vision is a hypothesis about the tier 3 endpoint of the field — a claim about what the field will look like once the work is done. 

**Vision and the category being created are the same object.** Vision is a region of multiple outcomes. Different companies that enter the region occupy different points within it — and their entry establishes the category in the market.

When the vision is realized, a new category exists in the market. While the vision is still a hypothesis, the category is still a proposed one. There is no separate "category creation" step — the category comes into being as the vision is realized.


Examples:
- Varda: orbital manufacturing as a routine industrial process; physical goods from orbit at scale.
- K2: highest power in orbit drives the orbital economy the way data centers drove the terrestrial one.

The vision appears inside a thesis, it must lean on the premise: the trends, patterns, or analogies that make the vision plausible. A thesis with a vision unsupported by premise reads as fantasy; a thesis with a vision grounded in premise reads as a fundable bet.

---

## 4. Thesis

A thesis states the vision and identifies the specific risks that, when resolved, leave the company powerful and defensible at the moment the category is established.

Form:

> **Vision:** [tier 3 endpoint of the field]
>
> **If we solve risks X, Y, Z**, we will be [N years ahead / cornered-resource holders / dominant in category / etc.] **when the category is established.**

When a category is established, the field has entered tier 3 and many companies are competing in it. The thesis makes a dual claim: by solving the named tier-2 risks before anyone else, the company will be the big fish (dominant player) when the pond is created (the category is established). 

The thesis is conditional. It commits to specific risks and specific consequences. It is not a declaration that the future will happen — it is a wager on what becomes true if specific tier-2 engineering challenges are resolved.

The named risks should be:

- **Tier 2 in nature** — engineering challenges, not research uncertainty. If a risk would push the bet back into tier 1, the thesis is misclassified.
- **Specifically identified** — not "the technology will work" but concrete claims like "non-metal actuators will function in MRI fields" or "re-entry capsules will survive at commercial cadence."
- **Mapped to team capability** — each risk has a specific team member or group positioned to resolve it.

A thesis without named risks is the "risk minimizer" failure mode — it asserts the future rather than wagering on it. Investors discount this heavily because it signals the founder hasn't thought through what could kill the bet. Pairing named risks with the consequences of their resolution is what makes the thesis credible.

---

## 5. Non-Linear Returns

For a deep tech company to reach venture-scale returns, revenue must scale non-linearly at some point along the path to the vision. Three patterns produce non-linearity. Any one is sufficient; combinations stack.

**Pattern 1: Capture a percentage of a rapidly growing market.**
The market itself scales super-linearly. Constant share gives super-linear revenue without expanding into other markets.
- Fusion captures share of a growing electricity market.
- Autonomous nuclear captures share of growing clean baseload demand.

**Pattern 2: Resell the same tech cheaply to other markets.**
Tech, capability, IP, or platform built for one market is monetized in others at near-zero marginal cost relative to the original investment.
- K2: satellite buses → orbital data centers → vertical comms (same core IP across verticals).
- Stripe: payments → identity → capital → tax (same merchants across financial services).
- Amazon: internal infrastructure → AWS as external product.
- SpaceX: launch capability → Starlink.
- Varda: re-entry services → pharma royalties from microgravity formulations.

**Pattern 3: Data or tech network effects across uses.**
Data, operational improvements, or learned capabilities from one application compound across others.
- Tesla: deployed cars produce autopilot data → improves all cars.
- Foundation models: training data from any task → improves all tasks.

A thesis that satisfies no pattern cannot reach venture scale. Vertical farming is the canonical case — produce demand isn't rapidly growing, vertical-farming tech doesn't usefully resell, and crop optimization data doesn't compound across sites. The thesis fails the non-linearity test; the market eventually confirms it.

---

## 6. Compounding Power

A deep tech bet must produce defensibility that competitors cannot replicate quickly. Hamilton Helmer's seven powers are the canonical framework. Audit the bet against each:

| Power | Definition |
|---|---|
| **Scale Economies** | Per-unit cost falls with volume; larger competitor wins price war profitably. |
| **Network Economies** | Value grows with users or nodes; late entrants face cold-start problem. |
| **Counter-Positioning** | New business model the incumbent cannot copy without cannibalizing existing business. |
| **Switching Costs** | Customers face real cost to leave (time, money, risk, data, integration). |
| **Branding** | Durable trust premium; customers pay more for objectively similar product. |
| **Cornered Resource** | Preferential access to coveted asset (patent, talent cluster, regulatory contract, data deposit). |
| **Process Power** | Embedded organizational know-how competitors cannot replicate quickly even with full visibility. |

Run the table. For each power, mark hit, miss, or partial.

A strong deep tech bet typically hits two or three powers cleanly. Hitting none means there is no moat — the bet may capture short-term revenue but will not produce a defensible tier-3 position. Hitting all seven usually means overclaiming.

Power compounds over time. The founder chooses which power to build by choosing what to accumulate — volume for scale, users for network economies, IP or talent for cornered resource, embedded process for process power. The accumulated lead at the moment of tier-3 entry is what makes the company defensible. Competitors entering the category later have to traverse the same path from a standing start.

---

## 7. Talent Magnet

Top engineers have more options than capital does. They join when the company is a credibly asymmetric personal bet — meaning both the expected upside of the vision and the concrete reality of the short-term work are strong enough to make joining the right choice over their alternatives.

Talent magnet has two components, both required:

**Expected value of the vision region.** The vision's expected value to a recruit must be high enough that joining is a personal asymmetric bet. Engineers earning at FAANG accept equity over salary based on the expected value of the long-term outcome they're betting on — so the vision they're betting on must be ambitious enough and credible enough to clear that bar.

**Concrete short-term reality.** Real customers, real partners, real near-term revenue. The pragmatic adjacent business that pays the bills and shows the thesis is operational, not theoretical.

Vision alone looks like a research project — interesting problems, no company. Short-term alone looks like a contract shop — steady work, no asymmetric upside. The simultaneous presence of both is what makes the company a real recruiting magnet.

The six-month hiring test is the direct observable for talent magnet quality. If a company cannot hire three to four exceptional people in six months post-funding, the failure points back at the substance — either the vision's expected value isn't credible, or the short-term reality is too thin, or both. Failed-recruit conversations are free diagnostic information on which component is weak.

---

## 8. Stress Test

Running the framework against several deep tech theses to test whether it produces useful diagnostics. The framework should: fit cleanly for canonical successes, produce visible strain on borderline cases, and predict failure where the substance doesn't support the bet.

### Varda

| Element | Assessment |
|---|---|
| Tier | 2 — Dragon and Corona established re-entry physics; commercial engineering remains. |
| Premise | **Trend:** launch costs fell 20x in a decade — brings orbital manufacturing from tier 1 to tier 2. |
| Vision | Orbital manufacturing as routine industrial process; physical goods from orbit at scale. |
| Thesis | If commercial re-entry + microgravity manufacturing solved, capture physical-goods-from-orbit category — both create the pond and hold the dominant position. |
| Non-linearity | **Pattern 2** strong: re-entry services → pharma royalties from microgravity formulations. |
| Powers hit | Cornered Resource (Dragon-architecture team + drug IP), Process Power (re-entry know-how). |
| Talent magnet | Vision (LEO economy) + short-term reality (government and commercial re-entry contracts). |

✓ Clean framework fit.

### K2 Space

| Element | Assessment |
|---|---|
| Tier | 2 — high-power satellites are engineering on proven satellite physics. |
| Premise | **Cross-domain analogy:** data centers won on Earth by having the most power; the same dynamic will play out in orbit. |
| Vision | Highest power in orbit drives the orbital economy the way data centers drove the terrestrial one. |
| Thesis | If 10–20 kW satellite buses solved, vertical re-rates into orbital data centers, vertical comms, and other power-intensive applications all flow from the same core IP. |
| Non-linearity | **Pattern 2** strong: same core satellite-bus IP across multiple verticals. |
| Powers hit | Cornered Resource (high-power IP), Scale Economies (eventually). |
| Talent magnet | Vision (orbital economy infrastructure) + short-term (government and commercial satellite-bus sales). |

✓ Clean framework fit.

### Recursion (AI-Driven Drug Discovery — biotech)

| Element | Assessment |
|---|---|
| Tier | 2 — ML and lab automation are engineering on established biology. |
| Premise | **Trend + pattern:** ML model capability matured; lab automation costs fell; genomic data became abundant. The same arc applies to many fields where data + ML have crossed thresholds. |
| Vision | Drug discovery as a productized data science pipeline rather than artisanal lab work. |
| Thesis | If high-throughput experimentation + AI model loop solved, drug pipeline is faster and cheaper than incumbents — a new category of discovery-as-platform. |
| Non-linearity | **Pattern 3** strong: data flywheel — each program adds proprietary data that improves future programs. **Pattern 2** partial: services revenue → owned drug pipeline. |
| Powers hit | Cornered Resource (proprietary data), Scale Economies (platform reuse across programs). |
| Talent magnet | Vision (drug discovery transformed) + short-term (pharma partnership contracts). |

✓ Framework fit. Real-world execution debate is about whether the data flywheel produces enough of a lead, not whether the framework applies.

### Helion / Commonwealth (Nuclear Fusion)

| Element | Assessment |
|---|---|
| Tier | 2 borderline 1 — NIF demonstrated net gain; commercial path is novel; deeply capital-intensive. |
| Premise | **Trend + pattern:** HTS materials matured, ML for plasma control matured, NIF research milestone reached. |
| Vision | Fusion as a baseload power source. |
| Thesis | If commercial net-positive reactor solved, only operator with working commercial fusion at scale — sole occupant of a brand-new category. |
| Non-linearity | **Pattern 1** primary: capture share of growing electricity demand. **Pattern 2** partial: reactor designs as IP, helium-3 by-product. **Pattern 3** weak. |
| Powers hit | Cornered Resource (reactor IP), Process Power, Scale Economies eventually. |
| Talent magnet | Vision (clean energy transformation) + short-term (government contracts, DoE partnerships). |

⚠ Framework strain. Non-linearity is primarily Pattern 1, which depends on market wave rather than structural axis-unlocking. This matches the actual investment reality: some investors love fusion at any TAM, others consider it borderline-uninvestable for exactly this reason.

### Vertical Farming (Plenty, Bowery)

| Element | Assessment |
|---|---|
| Tier | 2 at the time — LED and controlled environment are engineering on established horticulture. |
| Premise | **Trend:** LED costs fell, ML for crop optimization improved. |
| Vision | Urban agriculture replacing or supplementing field farms. |
| Thesis | If cost-per-pound parity with traditional farms solved, capture urban agriculture category. |
| Non-linearity | ✗ **None.** Pattern 1 fails — produce demand grows slowly. Pattern 2 fails — vertical-farming tech doesn't usefully resell. Pattern 3 fails — crop optimization data doesn't compound meaningfully across sites. |
| Powers hit | Brand partial (premium consumers), Scale Economies theoretical (never achieved in practice). |
| Talent magnet | Vision (food transformation) + short-term (high-end produce sales) — both present at the time. |

✗ Framework correctly predicts failure. The thesis fails the non-linearity test; multiple companies have shut down or pivoted.

---

### Summary

| Company | Tier | Premise mode | Non-linearity | Powers hit | Verdict |
|---|---|---|---|---|---|
| Varda | 2 | Trend | Pattern 2 strong | Cornered Resource + Process Power | ✓ |
| K2 Space | 2 | Cross-domain analogy | Pattern 2 strong | Cornered Resource + Scale Economies | ✓ |
| Recursion | 2 | Trend + Pattern | Pattern 3 strong | Cornered Resource + Scale Economies | ✓ |
| Helion / fusion | 2 borderline 1 | Trend + Pattern | Pattern 1 primary | Cornered Resource + Process Power | ⚠ strain |
| Vertical farming | 2 | Trend | None | Weak | ✗ correctly |

The framework holds across the test set: canonical successes fit cleanly, borderline cases produce framework strain that matches market reality, and structural failures are predicted correctly.

---

This is the conceptual foundation. The template that sits on top fills in each section for a specific bet.