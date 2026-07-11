
## Steps and the electrical cycle

- A **step** = moving from one tooth position to the next.

- Each tooth position is reached by setting the current in the coils.

- Assume two coils, A and B, driven in quadrature (`i_A = sin θ`, `i_B = cos θ`):

|θ|i_A = sin θ|i_B = cos θ|tooth|
|---|---|---|---|
|0°|0|1|0|
|90°|1|0|1|
|180°|0|−1|2|
|270°|−1|0|3|
|360°|0|1|4|

- As θ sweeps 0° → 360°, we trace one full sinusoid on each coil. This is **one electrical cycle**.

- Notice: **one electrical cycle contains four steps.**

> This table lands on cardinal positions (one coil full, the other zero) — the **wave-drive** (one-phase-on) scheme. The two-phase-on scheme lands on the 45° diagonals instead. Either way, **4 steps per electrical cycle**.

## Steps per revolution (from the motor)

- Motors are marketed by **steps/rev**.
- Most common: **200 steps/rev** (a 1.8° motor).

## Pulses per revolution (from the driver)

- Drivers are marketed by **pulses/rev**.
- But a driver can't state that number without knowing the motor, so it **assumes a 200-step motor** to state that number.

## General Relationship

```
pulses/rev = steps/rev * pulses/step
```

## Finding true pulses/rev

Because the label assumes 200 steps, first **recover pulses/step** using the driver's own assumption, then re-apply the motor's real steps/rev:

```
pulses/step     = driver_label_pulses_per_rev / 200     # decode (driver's assumption)
true_pulses/rev = pulses/step * actual_steps_per_rev    # re-apply (real motor)
```

