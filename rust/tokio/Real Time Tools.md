

## Sources of jitter in tokio:
1. new future using timerfd that can also be used for timeouts (likely used timerfd).
2. Fixed order join! so we don't have fairness issues

## Useful tool
1. TimestampedPoll => logs the time taken for poll to return


## Tuning

1. Priority
2. number of threads and controller which tasks go to which thread.




# CPU Tuning

A governor is a kernel policy that decides how aggressively a cpu should ramp and fall its clock when load appears


- **`performance`**
    
    - Immediately sets the CPU to run at its _maximum_ frequency and never scale down.
        
    - Good when you need the absolute lowest latency (e.g. real‐time loops). Drawback: higher power/heat.
        
- **`powersave`** (sometimes called `ondemand` in older kernels)
    
    - Immediately sets the CPU to the _minimum_ frequency and does not scale up automatically. Essentially “park” at low clocks unless a manual change happens.
        
    - Rarely used in practice—more of a niche policy.
        
- **`ondemand`**
    
    - Widely used on many ARM boards. When CPU utilization exceeds a certain threshold (often 80–90%), it tries to ramp up to a higher frequency. When utilization drops, it steps back down after a short delay.
        
    - Seeks to balance performance against power. You’ll often see spikes up to max clocks under load, then drops to a mid‐ or low‐range frequency when idle.
        
- **`schedutil`** (if supported in your kernel)
    
    - A newer governor that ties CPU frequency decisions to the scheduler’s view of task load. It can be faster and more granular about scaling compared to `ondemand`. On some newer Pi OSes, `schedutil` may be the default.
        
- **`userspace`**
    
    - Leaves frequency control entirely up to userland tools. The kernel does not move the frequency up or down automatically; instead, userspace daemons or scripts write directly to `scaling_setspeed` (or other controls) when they think it’s appropriate.



To switch to `performance`

do

```
sudo sh -c 'echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor'
```


for all cores (`cpu0, cpu1, cpu2, cpu3` etc)




# Thermal 
Throttling

```bash
vcgencmd get_throttled -> number of throttles

vcgencmd measure_temp
```



# Inter Processor Interrupts

If the interrupt for a task arrives at a different CPU and the task itself will be run on a different CPU, then we need inter processor interrupts `ipi`.

![[Pasted image 20250607192039.png]]



# Stress Testing and Validation


## Stress-ng

`stress-ng` is a swiss-army knife of stress testing. 


> Note ksoftirq, the kernel's irq handler threads per cpu, have SCHED_OTHER policy and priority of 19. This means any task with realtime priority will prevent the interrupts from running. We need to ensure this doesn't happen. The actual irq's have priority of 90 and real time.


```
(base) dpsh@raspberrypi:~/Documents $ ps -eLo pid,tid,cls,pri,rtprio,cmd \
  | grep -E 'irq|ksoftirqd'
     16      16  TS  19      - [ksoftirqd/0]
     22      22  TS  19      - [ksoftirqd/1]
     27      27  TS  19      - [ksoftirqd/2]
     32      32  TS  19      - [ksoftirqd/3]
     75      75  FF  90     50 [irq/38-aerdrv]
     80      80  FF  90     50 [irq/161-mmc1]
     81      81  FF  90     50 [irq/162-mmc0]
    199     199  FF  90     50 [irq/172-vc4 hdmi hpd connected]
    200     200  FF  90     50 [irq/173-vc4 hdmi hpd disconnected]
    202     202  FF  90     50 [irq/174-vc4 hdmi cec rx]
    203     203  FF  90     50 [irq/175-vc4 hdmi cec tx]
    213     213  FF  90     50 [irq/176-vc4 hdmi hpd connected]
    215     215  FF  90     50 [irq/177-vc4 hdmi hpd disconnected]
    217     217  FF  90     50 [irq/178-vc4 hdmi cec rx]
    218     218  FF  90     50 [irq/179-vc4 hdmi cec tx]
    498     498  FF  90     50 [irq/185-1000800000.codec]
   2369    2369  TS  19      - grep --color=auto -E irq|ksoftirqd
```


Use the following command to hog the cpu on which the task is running

```sh
sudo chrt 40 stress-ng --cpu 1 --taskset 2 --timeout 30s
```

will spawn 1 cpu hog at real time priority 40 on cpu 2

On the RPi, CPU0 handles almost all the interrupts, therefore

```
sudo chrt 40 stress-ng --cpu 1 --taskset 1 --timeout 30s
```

will knock out a lot of interrupt handling.


We also launch our own task with 

```sh
sudo taskset 02 chrt 80 ./my_task
```

so that it runs on cpu 1 with realtime priority 80.

Note that 02 is a mask, i.e

```
01 => CPU 0
02 => CPU 1
04 => CPU 2
08 => CPU 3
```

so we can use any combination of the above to get the desired cpu affiinity.





