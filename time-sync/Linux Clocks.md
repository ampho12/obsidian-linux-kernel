
### Three Linux clocks, conceptually

Assume an ideal (unobservable) true time $t$, and an underlying hardware counter that the kernel reads.
Model the raw kernel time as:
$$R(t) = \alpha t + \beta + \epsilon(t)$$
where $\alpha$ is oscillator drift, $\beta$ is an arbitrary epoch (usually tied to boot), and $\epsilon(t)$ is noise.

---

**1) CLOCK_MONOTONIC_RAW**
- Closest user-visible view of the hardware counter.
- Not disciplined by NTP/PTP (no slewing), and never steps.
- Conceptually:
  $$C_{\text{raw}}(t) \approx R(t)$$
- Good for “pure elapsed time since boot,” but different machines’ RAW clocks drift apart.

---

**2) CLOCK_MONOTONIC**
- A monotonic clock derived from the same base as RAW, but *frequency-disciplined*.
- NTP/PTP adjusts the rate smoothly so drift shrinks over time; it never jumps.
- Conceptually:
  $$C_{\text{mono}}(t) = s(R(t)) = a(t)\, t + \beta + \epsilon_{\text{mono}}(t)$$
  where $a(t)$ varies slowly due to slewing.
- Best for measuring intervals robustly over long runs when time sync is active.

---

**3) CLOCK_REALTIME**
- Wall clock meant to represent UTC.
- Shares the *same disciplined rate* as CLOCK_MONOTONIC, but adds a wall-time offset.
- That offset can *step* (jump) when time is set or a sync daemon decides a correction.
- Conceptually:
  $$C_{\text{real}}(t) = C_{\text{mono}}(t) + \Delta(t)$$
  where $\Delta(t)$ is the UTC offset that may jump, while $C_{\text{mono}}$ keeps time running smoothly.
- Best for timestamps that need to align with real-world calendar time.

---

Summary intuition:
- RAW = “what the hardware says, uncorrected.”
- MONO = “hardware clock with smooth rate corrections.”
- REALTIME = “MONO plus a UTC offset that can jump.”
