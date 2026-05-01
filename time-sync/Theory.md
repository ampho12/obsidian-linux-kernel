
To build upto time sync, we need a model to think about clocks.

A machine $i$ has a clock
$$
C_i(t) = a_it + b_i + \epsilon_i(t)
$$

Where
- $t$ is the true time which is not observable
- $a_i$ is clock rate vs true time (frequency scale factor)
- $b_i$ : is clock offset (phase)
- $\epsilon_i (t)$ is noise at time t


The phase error between two clocks is given by

$$
\theta(t) = C_2(t) - C_1(t)
$$
and the frequency error is given by
$$
\delta = a_2 - a_1
$$

Hence, assuming $\epsilon_i(t) = 0$,
$$
\frac{d}{dt} \theta(t) = \delta
$$


Synchronization is a controls problem: we want to drive bot $\theta$ and $\delta$ to 0.  We control both $a_i$ and $b_i$.


## Simple Example

Assume two clocks start with $b = 0$ but $a_2 \neq a_1$.

we can control our clock like this

```python
#!/usr/bin/env python3

import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import numpy as np


class ClockModel:
    def __init__(self, a, b, sigma=None):
        self.a = a
        self.b = b
        self.t = b
        self.sigma = sigma

    def step(self):
        self.t += self.a

    def read(self):
        if self.sigma is not None:
            return self.t + np.random.normal(0, self.sigma)
        return self.t

def main():
    timesource = ClockModel(1, 0)
    master = ClockModel(1.1, 0, 0.1)
    slave = ClockModel(0.9, 0, None)

    print("Time sync experiment: simulating clock drift")
    print("timesource: rate=1.0, master: rate=1.1, slave: rate=0.9")
    print()

    # Collect data for plotting
    steps = []
    timesource_vals = []
    master_vals = []
    slave_vals = []
    slave_errors = []

    num_steps = 500


    last_filtered_err = None
    filtered_err = 0
    sum_err = 0

    kp = 0.2
    kd = 0.1
    ki = 0.1
    alpha = 0.9  # EMA filter coefficient (0-1, lower = more filtering)

    for i in range(num_steps):
        steps.append(i)
        ts_val = timesource.read()
        m_val = master.read()
        s_val = slave.read()

        err = m_val - s_val

        # Apply EMA low-pass filter to error signal first
        filtered_err = alpha * err + (1 - alpha) * filtered_err

        # Then take derivative of filtered error
        d_err = None
        if last_filtered_err is not None:
            d_err = filtered_err - last_filtered_err

        if d_err is not None:
            slave.a += kp * filtered_err + kd * d_err
            # slave.a = kp * err + ki * sum_err

        last_filtered_err = filtered_err
        sum_err += err
        timesource_vals.append(ts_val)
        master_vals.append(m_val)
        slave_vals.append(s_val)
        slave_errors.append(err)
        # print(f"Step {i}: timesource={ts_val:.2f}, master={m_val:.2f}, slave={s_val:.2f}, error={m_val - s_val:.2f}")
        timesource.step()
        master.step()
        slave.step()

    # Plot the results
    plt.figure(figsize=(12, 12))

    # Plot 1: Clock values over time
    plt.subplot(3, 1, 1)
    plt.plot(steps, timesource_vals, label='Timesource (rate=1.0)', linewidth=2)
    plt.plot(steps, master_vals, label='Master (rate=1.1)', linewidth=2)
    plt.plot(steps, slave_vals, label='Slave (rate=0.9)', linewidth=2)
    plt.xlabel('Step')
    plt.ylabel('Clock Value')
    plt.title('Clock Drift Simulation')
    plt.legend()
    plt.grid(True, alpha=0.3)

    # Plot 2: Offset from timesource
    plt.subplot(3, 1, 2)
    master_offset = np.array(master_vals) - np.array(timesource_vals)
    slave_offset = np.array(slave_vals) - np.array(timesource_vals)
    plt.plot(steps, master_offset, label='Master offset from timesource', linewidth=2)
    plt.plot(steps, slave_offset, label='Slave offset from timesource', linewidth=2)
    plt.axhline(y=0, color='k', linestyle='--', alpha=0.3)
    plt.xlabel('Step')
    plt.ylabel('Offset from Timesource')
    plt.title('Clock Offset from Timesource')
    plt.legend()
    plt.grid(True, alpha=0.3)

    # Plot 3: Slave error (relative to master)
    plt.subplot(3, 1, 3)
    plt.plot(steps, slave_errors, label='Slave error (master - slave)', linewidth=2, marker='o', color='red')
    plt.axhline(y=0, color='k', linestyle='--', alpha=0.3)
    plt.xlabel('Step')
    plt.ylabel('Error')
    plt.title('Slave Synchronization Error (relative to Master)')
    plt.legend()
    plt.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.show()


if __name__ == '__main__':
    main()

```





