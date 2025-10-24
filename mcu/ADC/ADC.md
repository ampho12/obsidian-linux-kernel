An analog to digital converter is a peripheral that converts analog signals to a digital number.


We can read analog values by:

1. Trigger the read 
2. The ADC has a small 'sample and hold' capacitor (few picofarads) that temporarily stores the input voltage for some number of ADC cycles (called sampling time)
3. Conversion phase: ADCs are successive approximation registers (SAR) on STM32 for e.g. SAR works by comparing the voltage stored in the capacitor against fractions of a reference voltage in multiple steps. A 12 bit ADC will take 12 steps. Each comparison takes one ADC clock cycle.
4. ADC clock cycles can be made faster: quicker conversion but less time sampling (might have unstable samples). slow cycles means longer sample time (reliable) but slower conversion. The number of sampling cycles can be bumped / configured to bypass this to an extent.


The conversion / approximation happens as follows. 

Take the reference voltage $V_{ref}$ divide it by $2^N$ to get step size voltage $V_{step}$.

We will now successively binary approximate how many $V_{step}$ is needed.

use the following algo

```rust
let V_rem = V_cap;
let V_step = V_ref / 2^N;

let mut res = [0; N]; // this is our bitvector
for i in (0..=N-1).rev():
    let mult = 1 << i;
    if mult * V_step < V_rem: // using a comparator
        res[i] = 1
    V_rem = V_rem - mult * V_step;
```


e.g. for N = 14, V_ref = 12

V_step = $12 / 2^4$ = 0.75

Bit trials (MSB → LSB)

    Trial MSB (bit3): set to 1 → trial code = 1000₂ = 8
    DAC = 8/16×12=6 V8/16×12=6 V.
    Compare: 7.5>6 → keep bit3 = 1.

    Trial bit2: set to 1 → trial code = 1100₂ = 12
    DAC = 12/16×12=9 V12/16×12=9 V.
    Compare: 7.5<9 → clear bit2 = 0.

    Trial bit1: set to 1 → trial code = 1010₂ = 10
    DAC = 10/16×12=7.5 V10/16×12=7.5 V.
    Compare: 7.5≥7.5 → keep bit1 = 1.

    Trial bit0: set to 1 → trial code = 1011₂ = 11
    DAC = 11/16×12=8.25 V11/16×12=8.25 V.
    Compare: 7.5<<8.25 → clear bit0 = 0.

we get $1010_2$ which is 10 * 0.75 = 7.5, perfectly approximates our 7.5 signal


On stm32, the reference is made by doing VDD - GND = 3.3 V (usually) but might be different.
# What is the ADC reference on STM32F3?

* **VREF+ ≡ VDDA** (typically 2.0–3.6 V depending on the part; most designs use \~3.3 V).
* **VREF− ≡ VSSA** (analog ground).
* Full-scale code corresponds to **(VDDA – 1 LSB)**, so the ADC LSB size is:

  $$
  \text{LSB} = \frac{\text{VDDA}}{2^{N}}
  $$

  (e.g., for 12-bit, $\text{LSB} = \text{VDDA}/4096$).

If your board powers VDDA from the same 3.3 V as VDD (very common), then **3.3 V is your reference**—subject to whatever tolerance/noise that rail has. This is why good analog decoupling and a clean VDDA net matter.

# How to *know* the actual reference value at runtime

Even if you *intend* VDDA = 3.3 V, the real board might be 3.27 V, 3.34 V, etc. You can measure it from inside the MCU using the **internal band-gap reference channel** (**VREFINT**):

1. **Enable the VREFINT channel** (it’s an internal ADC channel).
2. Use a **long sampling time** and **average multiple samples** (VREFINT is a high-impedance source).
3. Read the factory calibration constant for VREFINT (provided in system memory; HAL/LL usually expose a symbol or macro, e.g., `VREFINT_CAL`, and its corresponding voltage constant, typically around **1.20–1.21 V**).

Then compute:

$$
\text{VDDA} \approx \frac{V_{\text{REFINT, cal}} \times (2^{N})}{\text{ADC\_reading}(V_{\text{REFINT}})}
$$

**Example (12-bit):**

* Factory says $V_{\text{REFINT, cal}} = 1.210\ \text{V}$ (value given with the chip at a known supply when calibrated).
* You measure `ADC_VREFINT = 1480` counts.
* $\text{VDDA} \approx \frac{1.210 \times 4096}{1480} \approx 3.35\ \text{V}$.

Now you can convert any ADC code to volts using that **measured** VDDA, not an assumed 3.300 V.

# Quick checklist

* **If your part has no dedicated VREF+ pin** (most F3): the ADC reference is **VDDA**.
* **Keep VDDA clean:** separate analog decoupling (e.g., 100 nF close to VDDA pin + bulk cap), ferrite bead from VDD if recommended in the datasheet.
* **Use VREFINT** to calibrate measurements in software if you need tighter accuracy.
* **Formula for converting a raw code to volts:**

  $$
  V_{\text{in}} \approx \frac{\text{Code}}{2^{N}-1} \times \text{VDDA}
  $$

  (Use your measured VDDA.)

If you tell me your exact STM32F3 part number (e.g., STM32F303RE) I can point you to the exact internal channel number for **VREFINT**, the right HAL calls, and the symbol/addresses for the factory calibration constant on that device.



# Modes


## Channels
An ADC peripheral has multiple physical pins on which it can sense an analog value. Each such pin corresponds to a channel, however, some channels are internal. (.e.g internal temperature of the ADC)

A **scan sequence** in an ADC represents a sequence of channels. When an adc is triggered, it will traverse this list linearly and sample each channel.

A channel is configured by setting
1. A channel number: pin or internal channel
2. Rank: This is the position of the channel in the scan sequence.
3. Sampling TIme: how long the sample-and-hold capacitor is connected to the channel before conversion starts. (longer for higher impedance).
## Conversion Mode

1. Single Conversion Mode: One measurement from configured channel / scan sequence per trigger
2. Continuous Conversion Mode: retriggers as soon as the previous sampling / scan sequence is finished. Keeps data streaming. The value in the data register is overwritten everytime a new value is ready. CPU needs to keep up.
3. Discontinuous Mode: breaks a scan sequence in smaller chunks, each triggered separately.





# STM32F303


Reg dump after init

Using adc::new
```
0.000277 [INFO ] 1 AHBENR=0x107e0017 CFGR2=0x00000101 CCR=0x00000000 CR=0x10000001 ISR=0x00000001
```



Using old adc
```
- [ ] 0.101745 [INFO ] 1 AHBENR=0x107e0017 CFGR2=0x00000101 CCR=0x00000000 CR=0x10000001 ISR=0x00000001
```

Make sure seq 0 is seq1 register is configured correctly. Embassy uses 0 for the first channe