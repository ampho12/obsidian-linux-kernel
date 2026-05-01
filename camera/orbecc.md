
# GMSL SerDes I2C Debug Walkthrough

## System Under Debug

```
┌──────────┐   I2C bus 2   ┌──────────┐   GMSL2 coax   ┌──────────┐  local I2C  ┌─────────┐
│  Jetson   │─────────────►│ MAX96712 │───────────────►│ MAX9295D │────────────►│ Orbbec  │
│  Orin NX  │              │ Deser    │                │ Serializer│            │ G300    │
│  (master) │              │ @0x29    │                │ @0x40 def │            │ (sensor)│
└──────────┘              └──────────┘                └──────────┘            └─────────┘
```

The Orbbec Gemini 335Lg is a depth camera with a MAX9295D serializer on-board, connected via FAKRA/GMSL2 coax to a MAX96712 quad deserializer on a Jetson carrier board. The G300 is the camera's internal ARM processor that presents an I2C slave interface for control.

---

## The Original Driver Bugs (What Was Wrong)

The original `obc_max96712.c` driver had **five interrelated bugs**, all stemming from one fundamental misunderstanding: **GMSL link disruptions reset ALL volatile registers on the serializer, not just the ones you last wrote.**

### Bug 1: Redundant reg 0x06 write after address change

In `seri_i2c_addr_trans()`, after changing the serializer address from 0x40 to 0x48, the driver re-wrote register 0x06 (link enable). This triggered a GMSL link re-initialization, which reset the serializer address back to default 0x40. The write succeeded from the driver's perspective (MAX96712 ACKed it), but the serializer was now unreachable at 0x48.

### Bug 2: Insufficient link settle time (120ms)

The original 120ms delay after enabling the GMSL link was not enough for the I2C control channel write forwarding to stabilize. The MAX96712 would ACK writes to the serializer address (0x40), but silently drop them — they never reached the serializer. This made all subsequent serializer configuration writes ineffective.

### Bug 3: DTB proxy/real address swap

The driver swapped the `proxy-addr` and `real-addr` values from the device tree. The DTB had:

```
proxy-addr = 0x20    (address the host should use)
real-addr  = 0x66    (sensor's physical address on serializer's local bus)
```

The driver swapped them, making the I2C address translation go backwards: host sends to 0x66 → serializer translates to 0x20 → nothing at 0x20 → NACK.

### Bug 4: No re-initialization after power cycle link disruption

The `set_snr_proxy_addr()` function power-cycles the sensor via a GPIO on the serializer. This power cycle disrupts the GMSL link, resetting ALL volatile serializer registers to defaults. The driver never re-established anything after this disruption.

### Bug 5: Sensor left powered off (THE FINAL BUG)

The GMSL link disruption caused by the sensor power-OFF also reset the power GPIO register (0x2D6) back to its default value 0x9C (GPIO HIGH = sensor OFF). After the link re-locked, the original driver tried to power ON the sensor via address 0x48 — but the serializer had already reverted to 0x40. The power-ON write NACKed silently. The sensor was never successfully turned on.

Even with our fixes 3-5 (re-establishing seri address and proxy regs), we still didn't re-power the sensor. It was simply off when the g300 driver tried to communicate with it.

---

## The Catch-22

The fundamental problem in this system is:

> **Powering OFF the sensor disrupts the GMSL link, which resets all volatile serializer registers — destroying any configuration written before the power-off. Powering ON does not disrupt the link.**

Here's the sequence that causes the problem:

1. The serializer (MAX9295D) controls sensor power via a GPIO pin (MFP8, register 0x2D6). The driver writes to this register through the GMSL link.
    
2. **Powering OFF the sensor disrupts the GMSL link.** The sensor and serializer share a PCB on the 335Lg camera module. When the sensor powers off, the collapsing power rail causes transients that disrupt the serializer's analog front-end, causing the GMSL link to lose lock.
    
3. When the GMSL link loses lock, the MAX9295D's digital core resets. ALL volatile registers return to their power-on defaults:
    
    - Register 0x0000: serializer I2C address → reverts to 0x40
    - Registers 0x0042/0x0043: I2C address translation → reverts to 0x00/0x00
    - Register 0x2D6: power GPIO → reverts to 0x9C (output HIGH = sensor OFF)
    - All pipe, MIPI, and GPIO configuration
4. **Powering ON the sensor does NOT disrupt the link.** We proved this empirically: writing 0x00 to 0x2D6 (power ON) left the serializer address intact, the GPIO register held its value, and the sensor appeared on the bus after boot. The regulator ramp-up is a clean event.
    
5. The original driver's mistake was doing configuration BEFORE the power-off. It wrote proxy regs, then powered off the sensor (destroying those regs), then tried to power on through the wrong serializer address (0x48, but the serializer had reverted to 0x40), so the sensor never actually turned on.
    

The correct sequence is simple:

1. Power OFF the sensor (accept that this destroys everything)
2. Wait for GMSL link to re-lock
3. Re-establish ALL serializer configuration (address, proxy regs, pipes, GPIOs)
4. Power ON the sensor (this is safe — no link disruption)
5. Wait for G300 ARM processor to boot (~5 seconds)

---

## How We Found Each Bug: Step by Step

### Phase 1: Diagnosing the volatile register reset

**Observation:** Proxy registers 0x0042/0x0043 were confirmed written (readback showed 0xCC/0x40), but 6.5 seconds later they were 0x00/0x00.

**Method:** Added debug readbacks at multiple points in probe:

- Immediately after writing → values correct
- After `set_snr_proxy_addr()` returns → values cleared to 0x00

**Root cause:** `set_snr_proxy_addr()` power-cycles the sensor, causing GMSL link disruption. All volatile serializer registers reset.

**Evidence from datasheets:** ADI FAQ confirms "Reset All resets link, all registers, and all blocks." MAX9295D registers 0x0042-0x0045 are in the digital core and are volatile.

### Phase 2: Fixing the proxy register wipe (fixes 1-5)

Added sequential fixes:

1. Removed redundant 0x06 write that was re-triggering link reset
2. Increased settle time from 120ms to 500ms
3. Added 2nd `seri_i2c_addr_trans()` call after power cycle to re-establish 0x48
4. Added direct re-write of 0x0042/0x0043 after power cycle
5. Verified via dmesg that proxy regs now persist through to probe completion

**Confirmed working:** Final dmesg showed `0x0042=0xCC 0x0043=0x40` persisting through probe, and `max96712_probe: success`.

### Phase 3: Sensor still unreachable despite correct proxy regs

**Observation:** g300 driver probes at 0x66, gets NACK. Direct `i2cget -y 2 0x66` also fails.

**Initial hypothesis:** Address translation direction is wrong (swap issue).

**Investigating the address values:**

The error message `sensor i2c tx error, code=29, len=10, index=1` was misleading. We checked the source code and found that `code=29` is NOT an I2C error code — it's an Orbbec protocol header field being dumped from the data buffer. The actual failure was simply `i2c_transfer() != 1` (NACK).

The driver's `max96712_write_sensor()` sends to `TO_SNR_ADDR(link_id)` which expands to `priv->snr_proxy_addr + 0`. After the swap, this was 0x66.

With swap:

```
Host sends 0x66 → SRC_A matches (0xCC = 0x66<<1)
                → translated to DST_A (0x40 = 0x20<<1)
                → 0x20 on local bus → NACK (sensor not at 0x20)
```

**Fix:** Removed the swap. DTB values used as-is: proxy=0x20, real=0x66.

### Phase 4: Swap removed, translation correct, STILL failing

**Observation:** With unswapped values:

```
0x0042=0x40 (SRC = 0x20<<1) → intercepts 0x20
0x0043=0xCC (DST = 0x66<<1) → forwards to 0x66
```

Driver sends to `snr_proxy_addr` = 0x20. Translation: 0x20 → 0x66. Correct! But sensor still NACKs.

**Key diagnostic:** We ran `i2cdetect -y -r 2` and found:

```
0x29: UU (deserializer, kernel-bound)
0x48: responds (serializer)
0x66-0x75: UU (kernel-bound g300 instances) but NO actual sensor response
```

No device other than deserializer and serializer responded on the bus. The sensor was simply not present.

### Phase 5: Is the sensor powered?

**Diagnostic:** Read the power GPIO register:

```bash
i2ctransfer -y 2 w2@0x48 0x02 0xD6 r1
→ 0x9C
```

**0x9C is the MAX9295D's power-on default for MFP8.** The GPIO register had never been successfully set to 0x00 (sensor ON) — or rather, it WAS set to 0x00 during `set_snr_proxy_addr()`, but the GMSL link disruption reset it back to 0x9C.

The driver:

- ✅ Re-established serializer address after link disruption
- ✅ Re-wrote proxy registers after link disruption
- ❌ Did NOT re-power the sensor after link disruption

Same class of bug, different register. The link disruption is a "reset everything" event and the driver only restored 2 out of 3 critical settings.

### Phase 6: Proving the sensor is alive

With the serializer at 0x40 (post-reboot default), we:

```bash
# Power on sensor
i2ctransfer -y 2 w3@0x40 0x02 0xD6 0x00

# Wait for ARM boot
sleep 5

# Try sensor
i2ctransfer -y 2 w1@0x66 0x00
→ ACK! (no error)

# Bus scan confirmed
i2cdetect -y -r 2
→ 0x66 now visible
```

**The sensor's real physical address is 0x66**, exactly as the DTB `real-addr` says.

### Phase 7: Proving the full proxy chain works

```bash
# Set proxy translation: 0x20 → 0x66
i2ctransfer -y 2 w3@0x40 0x00 0x42 0x40   # SRC = 0x20<<1
i2ctransfer -y 2 w3@0x40 0x00 0x43 0xCC   # DST = 0x66<<1

# Try through proxy address
i2ctransfer -y 2 w1@0x20 0x00
→ ACK!
```

Full chain verified:

```
Host → 0x20 → MAX96712 → GMSL → MAX9295D → translates 0x20→0x66 → sensor ACK ✅
```

This is exactly the path the driver uses. The only missing piece was re-powering the sensor.

---

## The Complete Fix

The correct probe sequence, understanding that power OFF is the destructive event:

```c
/* In max96712_probe(): */

/* 1. Initial setup: change serializer address 0x40 → 0x48 */
seri_i2c_addr_trans(dev);

/* 2. Configure deserializer */
max96712_init_settings(dev);

/* 3. set_snr_proxy_addr() runs:
 *    - Writes proxy regs (will be destroyed)
 *    - Powers OFF sensor via GPIO 0x2D6
 *      ⚡ LINK DISRUPTION — all volatile regs reset ⚡
 *    - Waits 3s for link to re-lock
 *    - Tries to power ON via 0x48 — but seri is back at 0x40, so this NACKs!
 *    - Waits 3s (sensor never actually powered on)
 */
max96712_set_snr_proxy_addr(dev);

/* === Everything below here is the fix === */

/* 4. Re-establish serializer address (link disruption reset it to 0x40) */
seri_i2c_addr_trans(dev);

/* 5. Re-write proxy registers (link disruption cleared 0x0042/0x0043) */
max96712_write_reg_with_addr(dev, TO_SERI_ADDR(0), 0x0042, (priv->snr_proxy_addr)<<1);
max96712_write_reg_with_addr(dev, TO_SERI_ADDR(0), 0x0043, (priv->snr_real_addr)<<1);

/* 6. Power ON sensor — safe, does NOT disrupt link */
max96712_set_sensor_on(dev, 0);

/* 7. Wait for G300 ARM processor to boot firmware and bring up I2C slave */
msleep(5000);

/* Now g300 probe can talk to sensor: host→0x20→translated→0x66→sensor ACK */
```

---

## Summary Table

|#|Bug|Symptom|Root Cause|Fix|
|---|---|---|---|---|
|1|Redundant 0x06 write|Serializer addr reverts to 0x40|Link re-init resets volatile regs|Remove the write|
|2|120ms settle time|Serializer config writes silently dropped|CC not ready for write forwarding|Increase to 500ms|
|3|No seri addr re-init|Can't reach serializer after power cycle|Link disruption resets addr to 0x40|Call seri_i2c_addr_trans() again|
|4|DTB swap|Translation goes 0x66→0x20 (backwards)|Driver incorrectly swaps proxy/real|Remove swap, use DTB as-is|
|5|No proxy reg re-write|Address translation disabled after power cycle|Link disruption clears 0x0042/0x0043|Re-write after re-establishing seri|
|6|No sensor re-power|Sensor is OFF when g300 probes|Link disruption resets GPIO to default (OFF)|Call set_sensor_on() + msleep(5000)|

All six bugs share the same root cause: **the GMSL link disruption during sensor power cycling resets all volatile serializer registers, and the original driver only accounted for some of them.**

---

## Key Lessons

1. **GMSL volatile registers are ALL-or-nothing.** When the link drops, everything resets. You can't selectively protect individual registers. The only safe approach is to re-write everything after any link disruption event.
    
2. **Powering OFF a sensor through a serializer GPIO is the destructive event.** Powering ON is safe. The correct pattern is: accept that power-off destroys everything, wait for link re-lock, re-configure everything, THEN power on.
    
3. **I2C NACKs have many possible causes.** In a GMSL system, a NACK at the sensor address could mean: wrong address, wrong translation direction, sensor powered off, sensor still booting, serializer at wrong address, GMSL link down, or CC not forwarding. Systematic elimination is essential.
    
4. **`i2cdetect` and `i2ctransfer` are invaluable** for runtime diagnosis of GMSL I2C issues, but you must use `i2ctransfer` (not `i2cget`) for devices with 16-bit register addressing.
    
5. **Always read back what you write** through the same path the data will travel in production. Debug readbacks at every stage of probe were what made this diagnosis possible.



# Version 2

# GMSL SerDes I2C Debug Walkthrough

## 1. Architecture

```
┌──────────┐   I2C bus 2   ┌──────────┐   GMSL2 coax   ┌──────────┐  local I2C  ┌─────────┐
│  Jetson   │─────────────►│ MAX96712 │───────────────►│ MAX9295D │────────────►│ Orbbec  │
│  Orin NX  │              │ Deser    │                │ Ser      │            │ G300    │
│  (host)   │              │          │                │          │            │ (sensor)│
└──────────┘              └──────────┘                └──────────┘            └─────────┘
```

The Orbbec Gemini 335Lg is a depth camera module. On its PCB sit a MAX9295D serializer and the G300 — an ARM processor that presents an I2C slave interface for camera control. The module connects via FAKRA/GMSL2 coax to a MAX96712 quad deserializer on a Jetson Orin NX carrier board.

### Addresses

|Device|Default addr|Remapped addr|Role|
|---|---|---|---|
|MAX96712 (deserializer)|0x29|—|Fixed. Sits on host I2C bus 2.|
|MAX9295D (serializer)|0x40|0x48|Driver remaps to 0x48 during probe to free 0x40 for future links.|
|G300 (sensor)|0x66|—|Physical address on the serializer's local I2C bus. Not directly visible to the host.|

### I2C Address Translation (Proxy)

The host cannot talk to the sensor directly — there's a GMSL link in between. The host writes to a **proxy address** (0x20), which the MAX96712 forwards over GMSL. The MAX9295D then performs **I2C address translation**: it intercepts the proxy address and rewrites it to the sensor's real address on its local bus.

This translation is configured by two registers on the MAX9295D:

|Register|Name|Value|Meaning|
|---|---|---|---|
|0x0042|SRC_A|0x40 (= 0x20 << 1)|Intercept transactions addressed to 0x20|
|0x0043|DST_A|0xCC (= 0x66 << 1)|Rewrite them to 0x66 on the local bus|

(Register values are 7-bit I2C addresses left-shifted by 1 — the MAX9295D's internal format.)

The full transaction path when the host writes to the sensor:

```
Host writes to 0x20
  → MAX96712 sees 0x20, no local match, forwards over GMSL
    → MAX9295D receives, SRC_A matches 0x20
      → Rewrites address to DST_A = 0x66
        → G300 at 0x66 on local bus ACKs → ACK propagates back to host
```

### Sensor Power Control

The G300's power is controlled by a GPIO on the serializer (MFP8, register 0x2D6). This register is written through the GMSL link — host → deserializer → serializer. Values: 0x00 = sensor ON (GPIO driven LOW), 0x9C = sensor OFF (GPIO HIGH, which is also the power-on default).

## 2. GMSL Link Behavior

### Discovery Mode and Serializer Address Change

At boot, the serializer is at its default address 0x40. The driver changes it to 0x48 by:

1. Writing register 0x18 = 0x0F on the MAX96712 (all-links oneshot reset). This puts the deserializer into **discovery mode**, where it intercepts writes to 0x40 and forwards them over GMSL to the serializer.
2. Waiting for the GMSL link to re-lock and the I2C control channel (CC) to stabilize.
3. Writing 0x0000 = 0x90 (= 0x48 << 1) to the serializer via address 0x40. The MAX96712 forwards this over GMSL; the serializer updates its own I2C address.

After this, the serializer responds at 0x48, and the MAX96712 transparently routes 0x48 traffic over the GMSL link.

### Link Lock and CC Settle Time

After the oneshot reset, the GMSL link must re-lock before the CC can forward I2C transactions. Physical lock happens relatively quickly, but CC write forwarding takes additional time to initialize. The original driver used 120ms; we found **500ms** is required for writes to reliably reach the serializer.

### Volatile Register Reset

ALL MAX9295D configuration registers are volatile. When the GMSL link loses lock, the serializer's digital core resets and every register reverts to its power-on default. There is no selective reset — it's all or nothing.

Key registers affected:

|Register|Function|Default (after reset)|
|---|---|---|
|0x0000|Serializer I2C address|0x80 (= 0x40 << 1)|
|0x0042|Proxy SRC address|0x00 (translation disabled)|
|0x0043|Proxy DST address|0x00 (translation disabled)|
|0x02D6|MFP8 power GPIO|0x9C (HIGH = sensor OFF)|
|0x0002|Pipe enable|default|

### What Causes Link Loss

**The oneshot reset (reg 0x18 = 0x0F) disrupts the link** — by design. This is the entry into discovery mode. After the reset, all serializer registers are at defaults.

**Powering OFF the sensor can disrupt the link.** The sensor and serializer share a PCB. When the sensor transitions from ON to OFF, the collapsing power rail causes transients that can break GMSL lock. If the sensor was never on (default boot state is OFF), writing the "off" value doesn't cause a transition and doesn't disrupt the link.

**Powering ON the sensor does NOT disrupt the link.** The regulator ramp-up is a clean event. We proved this empirically: writing 0x00 to 0x2D6 left the serializer address intact, proxy registers held, and the sensor appeared on the bus after its boot delay.

## 3. Original Driver Flow

```
max96712_probe()
│
├─ seri_i2c_addr_trans()
│   ├─ Oneshot reset (0x18 = 0x0F)           → link drops, re-locks
│   ├─ msleep(120)                            → CC not ready yet
│   ├─ Write 0x40:0x0000 = 0x90 (addr 0x48)  → MAX96712 ACKs but silently
│   │                                           drops — never reaches serializer
│   └─ Write reg 0x06 (link enable)           → triggers ANOTHER link reset
│                                               → even if addr change had worked,
│                                                 this would revert it
│
├─ max96712_init_settings()                   → configures deserializer (OK)
│
├─ set_snr_proxy_addr()
│   ├─ Write 0x48:0x0042 = proxy<<1           → NACKs (seri still at 0x40)
│   ├─ Write 0x48:0x0043 = real<<1            → NACKs
│   ├─ set_sensor_off(0x48, 0x2D6 = 0x10)    → NACKs
│   ├─ msleep(3000)
│   ├─ set_sensor_on(0x48, 0x2D6 = 0x00)     → NACKs
│   └─ msleep(3000)
│
└─ g300 probes at 0x66                        → NACK (sensor off, no proxy)
```

Everything after `seri_i2c_addr_trans()` targets 0x48, but the serializer is still at 0x40. Every write NACKs silently. The sensor is never configured, never powered on, and never responds.

## 4. The Bugs

All bugs trace to the serializer address change failing. Once the serializer is stuck at 0x40 while the driver talks to 0x48, nothing works.

### Bug 1: Redundant reg 0x06 write triggers a second link reset

After changing the serializer address, `seri_i2c_addr_trans()` re-wrote register 0x06 (link enable mask) on the deserializer. This triggered a GMSL link re-initialization, resetting all serializer volatile registers — including the address that was just changed. Even if the address change had succeeded, this write would have undone it.

### Bug 2: 120ms settle time too short for CC write forwarding

The 120ms delay after the oneshot reset was enough for the GMSL link to physically lock, but not for the CC to start forwarding writes. The MAX96712 ACKed writes to 0x40 (it always does in discovery mode), but silently dropped them — they never reached the serializer. The address change was lost.

### Bug 3: DTB proxy/real address swap

The driver swapped `proxy-addr` (0x20) and `real-addr` (0x66) from the device tree, inverting the address translation. Even after fixes 1 and 2 made the serializer reachable, the proxy registers were programmed backwards: host sends to 0x66 → translates to 0x20 → nothing at 0x20 → NACK.

### Bug 4: No boot wait for G300 ARM processor

The G300 is an ARM processor that runs firmware. After power-on, it takes ~5 seconds to boot before its I2C slave interface goes active. The original driver had no wait for this. Even with correct address translation and the sensor powered on, the G300 wouldn't respond because it hadn't finished booting.

## 5. The Fixes

### Fix 1: Remove redundant 0x06 write

In `seri_i2c_addr_trans()`, removed the re-write of register 0x06 after the loop. The link stays enabled from the 0x06 write inside the loop — touching it again just triggers an unnecessary link reset.

### Fix 2: Increase settle time to 500ms

Changed `msleep(120)` to `msleep(500)` after enabling each link in `seri_i2c_addr_trans()`. This gives the CC enough time to initialize, so the serializer address change write actually reaches the MAX9295D.

### Fix 3: Remove DTB address swap

Used `proxy-addr` and `real-addr` from the device tree as-is. proxy = 0x20 (host-side address), real = 0x66 (sensor's physical address).

### Fix 4: Add 5-second G300 boot wait

Added `msleep(5000)` after `set_snr_proxy_addr()` returns. This gives the G300 ARM processor time to boot its firmware and bring up the I2C slave interface.

### Result

With fixes 1-4, the probe flow becomes:

```
max96712_probe()
│
├─ seri_i2c_addr_trans()
│   ├─ Oneshot reset (0x18 = 0x0F)           → link drops, re-locks
│   ├─ msleep(500)                            → CC ready ✓
│   ├─ Write 0x40:0x0000 = 0x90 (addr 0x48)  → reaches serializer ✓
│   └─ (no redundant 0x06 write)              → addr holds ✓
│
├─ max96712_init_settings()                   → configures deserializer ✓
│
├─ set_snr_proxy_addr()
│   ├─ Write 0x48:0x0042 = 0x40 (=0x20<<1)   → succeeds (seri at 0x48) ✓
│   ├─ Write 0x48:0x0043 = 0xCC (=0x66<<1)   → succeeds ✓
│   ├─ set_sensor_off(0x48)                   → no-op (already off at boot) ✓
│   ├─ msleep(3000)
│   ├─ set_sensor_on(0x48)                    → powers on, clean, no disruption ✓
│   └─ msleep(3000)
│
├─ msleep(5000)                               → G300 ARM boots firmware ✓
│
└─ g300 probes at 0x20 → 0x66                 → ACK ✓
```

Confirmed working — all four G300 subdevices (depth, color, ir_l, ir_r) probe successfully and bind to the V4L2 subsystem.