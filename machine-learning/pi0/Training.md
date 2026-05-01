

When kicking off training, check this file

```json
(lerobot) root@C.31182903:/workspace/lerobot$ cat lerobot-manifold/meta/stats.json
{
    "action": {
        "std": [
            0.12118582485414081,
            0.1416883022832728,
            0.2010830453082562,
            1.180107642799657,
            0.7589062583979727,
            0.4234245907171482
        ],
        "count": [
            2147
        ],
    },
    "observation.state": {
        "std": [
            0.12346922610216692,
            0.14408769237308144,
            0.1871545963884218,
            1.060887263250758,
            0.7042571520813683,
            0.42047637778949476
        ],
        "count": [
            2147
        ],
    },
}
```

This is because when normalizing, actions and states are dividied by the standard deviation. A very small standard devision means values will blow up.

A practical sanity check list for stats.json before training:

- No std = 0.0 → would cause NaN (drop that dimension)
- No std < 1e-4 → suspicious, likely near-constant dimension
- q99 - q01 > 0 for all dims → same check for quantile normalization
- state and action stats should be similar order of magnitude → since they're the same space (EE poses).

E.g, when I trained with std less then 1e-4, My loss would be close to 300 and not drop below 30. When I train with std as above, my loss basically starts out at 0.2.

This can happen even if data is good. Consider some trajectories where the left arm is stationary but the right arm is moving. If we train only the left arm, it will have very small std as it is stationary. Right arm has more movement so a manageable std.

Again, if the task is mostly lateral movement, the z-axis might barely change (eg z std=0.004). It's not just a multi-arm problem, always check all 6 dims individually.


## Discontinuity in Data

![[Pasted image 20260212021617.png]]

This is rotation in the x direction for an angle axis representation of rotation. This is discontinuous. The policy however, learns to predict this. This will pollute the data.

We switch to a 6d rotation instead. This is gold standard for VLAs

https://arxiv.org/pdf/1812.07035


It seems though that ACT and Pi0 directly train on joint angles (6-7 angles for actuators) and the end effector angles.

This is a test we should run (ee vs joint angles).



With full fine tune and binary actions, we see loss plateau around 0.009
```
INFO 2026-02-15 02:39:27 ot_train.py:423 step:800 smpl:26K ep:61 epch:1.20 loss:0.038 grdn:1.058 lr:2.4e-05 updt_s:2.023 data_s:0.009
INFO 2026-02-15 02:46:14 ot_train.py:423 step:1K smpl:32K ep:77 epch:1.51 loss:0.033 grdn:0.973 lr:2.3e-05 updt_s:2.026 data_s:0.004
INFO 2026-02-15 02:46:14 ot_train.py:443 Checkpoint policy after step 1000
INFO 2026-02-15 02:53:33 ot_train.py:423 step:1K smpl:38K ep:92 epch:1.81 loss:0.030 grdn:1.002 lr:2.2e-05 updt_s:2.019 data_s:0.003
INFO 2026-02-15 03:00:19 ot_train.py:423 step:1K smpl:45K ep:108 epch:2.11 loss:0.026 grdn:0.888 lr:2.1e-05 updt_s:2.021 data_s:0.008
INFO 2026-02-15 03:03:43 ot_train.py:443 Checkpoint policy after step 1500
INFO 2026-02-15 03:07:51 ot_train.py:423 step:2K smpl:51K ep:123 epch:2.41 loss:0.023 grdn:0.877 lr:2.0e-05 updt_s:2.032 data_s:0.004
INFO 2026-02-15 03:14:37 ot_train.py:423 step:2K smpl:58K ep:138 epch:2.71 loss:0.020 grdn:0.811 lr:1.9e-05 updt_s:2.027 data_s:0.003
INFO 2026-02-15 03:21:25 ot_train.py:423 step:2K smpl:64K ep:154 epch:3.01 loss:0.019 grdn:0.790 lr:1.8e-05 updt_s:2.028 data_s:0.009
INFO 2026-02-15 03:21:25 ot_train.py:443 Checkpoint policy after step 2000
INFO 2026-02-15 03:28:44 ot_train.py:423 step:2K smpl:70K ep:169 epch:3.31 loss:0.017 grdn:0.749 lr:1.7e-05 updt_s:2.021 data_s:0.003
INFO 2026-02-15 03:35:29 ot_train.py:423 step:2K smpl:77K ep:184 epch:3.61 loss:0.015 grdn:0.740 lr:1.5e-05 updt_s:2.023 data_s:0.003
INFO 2026-02-15 03:38:52 ot_train.py:443 Checkpoint policy after step 2500
INFO 2026-02-15 03:42:45 ot_train.py:423 step:3K smpl:83K ep:200 epch:3.92 loss:0.014 grdn:0.701 lr:1.4e-05 updt_s:2.027 data_s:0.003
INFO 2026-02-15 03:49:33 ot_train.py:423 step:3K smpl:90K ep:215 epch:4.22 loss:0.013 grdn:0.695 lr:1.2e-05 updt_s:2.027 data_s:0.009
INFO 2026-02-15 03:56:20 ot_train.py:423 step:3K smpl:96K ep:230 epch:4.52 loss:0.012 grdn:0.673 lr:1.1e-05 updt_s:2.025 data_s:0.003
INFO 2026-02-15 03:56:20 ot_train.py:443 Checkpoint policy after step 3000
INFO 2026-02-15 04:03:33 ot_train.py:423 step:3K smpl:102K ep:246 epch:4.82 loss:0.011 grdn:0.662 lr:9.6e-06 updt_s:2.024 data_s:0.003
INFO 2026-02-15 04:10:21 ot_train.py:423 step:3K smpl:109K ep:261 epch:5.12 loss:0.010 grdn:0.639 lr:8.3e-06 updt_s:2.026 data_s:0.008
INFO 2026-02-15 04:13:44 ot_train.py:443 Checkpoint policy after step 3500
INFO 2026-02-15 04:17:34 ot_train.py:423 step:4K smpl:115K ep:277 epch:5.42 loss:0.009 grdn:0.623 lr:7.1e-06 updt_s:2.023 data_s:0.003
INFO 2026-02-15 04:24:19 ot_train.py:423 step:4K smpl:122K ep:292 epch:5.72 loss:0.009 grdn:0.602 lr:6.1e-06 updt_s:2.019 data_s:0.003
INFO 2026-02-15 04:31:06 ot_train.py:423 step:4K smpl:128K ep:307 epch:6.02 loss:0.009 grdn:0.597 lr:5.1e-06 updt_s:2.025 data_s:0.009
INFO 2026-02-15 04:31:06 ot_train.py:443 Checkpoint policy after step 4000
```

without binary actions, I got sometign like 0.02




Without full fine tune loss usually plateaus around 0.03






## Block Cycling
### PI05

```
INFO 2026-02-16 16:51:47 ot_train.py:393 Start offline training on a fixed dataset, with effective batch size: 32
INFO 2026-02-16 17:00:13 ot_train.py:423 step:200 smpl:6K ep:1 epch:0.34 loss:0.100 grdn:1.603 lr:1.5e-05 updt_s:2.510 data_s:0.012
INFO 2026-02-16 17:08:37 ot_train.py:423 step:400 smpl:13K ep:3 epch:0.67 loss:0.039 grdn:0.828 lr:2.5e-05 updt_s:2.500 data_s:0.007
INFO 2026-02-16 17:16:59 ot_train.py:423 step:600 smpl:19K ep:4 epch:1.01 loss:0.027 grdn:0.584 lr:2.4e-05 updt_s:2.492 data_s:0.012
INFO 2026-02-16 17:25:22 ot_train.py:423 step:800 smpl:26K ep:5 epch:1.34 loss:0.021 grdn:0.459 lr:2.4e-05 updt_s:2.496 data_s:0.008
INFO 2026-02-16 17:33:45 ot_train.py:423 step:1K smpl:32K ep:7 epch:1.68 loss:0.018 grdn:0.442 lr:2.3e-05 updt_s:2.499 data_s:0.007
INFO 2026-02-16 17:33:45 ot_train.py:443 Checkpoint policy after step 1000
INFO 2026-02-16 17:42:39 ot_train.py:423 step:1K smpl:38K ep:8 epch:2.02 loss:0.015 grdn:0.383 lr:2.2e-05 updt_s:2.492 data_s:0.012
INFO 2026-02-16 17:51:02 ot_train.py:423 step:1K smpl:45K ep:9 epch:2.35 loss:0.013 grdn:0.359 lr:2.1e-05 updt_s:2.498 data_s:0.007
INFO 2026-02-16 17:59:25 ot_train.py:423 step:2K smpl:51K ep:11 epch:2.69 loss:0.013 grdn:0.349 lr:2.0e-05 updt_s:2.498 data_s:0.007
INFO 2026-02-16 18:07:47 ot_train.py:423 step:2K smpl:58K ep:12 epch:3.02 loss:0.011 grdn:0.339 lr:1.9e-05 updt_s:2.489 data_s:0.011
INFO 2026-02-16 18:16:10 ot_train.py:423 step:2K smpl:64K ep:13 epch:3.36 loss:0.010 grdn:0.325 lr:1.8e-05 updt_s:2.496 data_s:0.007
INFO 2026-02-16 18:16:10 ot_train.py:443 Checkpoint policy after step 2000
INFO 2026-02-16 18:25:04 ot_train.py:423 step:2K smpl:70K ep:15 epch:3.70 loss:0.009 grdn:0.314 lr:1.7e-05 updt_s:2.495 data_s:0.007
INFO 2026-02-16 18:33:26 ot_train.py:423 step:2K smpl:77K ep:16 epch:4.03 loss:0.009 grdn:0.317 lr:1.5e-05 updt_s:2.493 data_s:0.011
INFO 2026-02-16 18:41:49 ot_train.py:423 step:3K smpl:83K ep:17 epch:4.37 loss:0.008 grdn:0.312 lr:1.4e-05 updt_s:2.498 data_s:0.007
INFO 2026-02-16 18:50:12 ot_train.py:423 step:3K smpl:90K ep:19 epch:4.70 loss:0.008 grdn:0.322 lr:1.2e-05 updt_s:2.498 data_s:0.007
INFO 2026-02-16 18:58:35 ot_train.py:423 step:3K smpl:96K ep:20 epch:5.04 loss:0.007 grdn:0.314 lr:1.1e-05 updt_s:2.492 data_s:0.011
INFO 2026-02-16 18:58:35 ot_train.py:443 Checkpoint policy after step 3000
INFO 2026-02-16 19:07:29 ot_train.py:423 step:3K smpl:102K ep:22 epch:5.38 loss:0.006 grdn:0.309 lr:9.6e-06 updt_s:2.498 data_s:0.007
INFO 2026-02-16 19:15:52 ot_train.py:423 step:3K smpl:109K ep:23 epch:5.71 loss:0.006 grdn:0.319 lr:8.3e-06 updt_s:2.496 data_s:0.007
INFO 2026-02-16 19:24:14 ot_train.py:423 step:4K smpl:115K ep:24 epch:6.05 loss:0.006 grdn:0.306 lr:7.1e-06 updt_s:2.487 data_s:0.011
INFO 2026-02-16 19:32:36 ot_train.py:423 step:4K smpl:122K ep:26 epch:6.38 loss:0.005 grdn:0.296 lr:6.1e-06 updt_s:2.495 data_s:0.007
INFO 2026-02-16 19:40:59 ot_train.py:423 step:4K smpl:128K ep:27 epch:6.72 loss:0.005 grdn:0.306 lr:5.1e-06 updt_s:2.496 data_s:0.007
INFO 2026-02-16 19:40:59 ot_train.py:443 Checkpoint policy after step 4000
INFO 2026-02-16 19:49:53 ot_train.py:423 step:4K smpl:134K ep:28 epch:7.06 loss:0.005 grdn:0.311 lr:4.3e-06 updt_s:2.490 data_s:0.011
INFO 2026-02-16 19:58:17 ot_train.py:423 step:4K smpl:141K ep:30 epch:7.39 loss:0.005 grdn:0.314 lr:3.6e-06 updt_s:2.502 data_s:0.007
INFO 2026-02-16 20:06:40 ot_train.py:423 step:5K smpl:147K ep:31 epch:7.73 loss:0.005 grdn:0.314 lr:3.1e-06 updt_s:2.498 data_s:0.007
INFO 2026-02-16 20:15:02 ot_train.py:423 step:5K smpl:154K ep:32 epch:8.06 loss:0.005 grdn:0.317 lr:2.7e-06 updt_s:2.489 data_s:0.011
INFO 2026-02-16 20:23:24 ot_train.py:423 step:5K smpl:160K ep:34 epch:8.40 loss:0.005 grdn:0.320 lr:2.5e-06 updt_s:2.496 data_s:0.007
INFO 2026-02-16 20:23:24 ot_train.py:443 Checkpoint policy after step 5000
INFO 2026-02-16 20:23:54 ot_train.py:514 End of training
```

### PI0
```
INFO 2026-02-16 10:55:02 ot_train.py:393 Start offline training on a fixed dataset, with effective batch size: 32
INFO 2026-02-16 11:01:52 ot_train.py:423 step:200 smpl:6K ep:1 epch:0.34 loss:0.188 grdn:4.558 lr:1.5e-05 updt_s:2.038 data_s:0.007
INFO 2026-02-16 11:08:40 ot_train.py:423 step:400 smpl:13K ep:3 epch:0.67 loss:0.072 grdn:1.935 lr:2.5e-05 updt_s:2.032 data_s:0.003
INFO 2026-02-16 11:15:28 ot_train.py:423 step:600 smpl:19K ep:4 epch:1.01 loss:0.052 grdn:1.506 lr:2.4e-05 updt_s:2.024 data_s:0.009
INFO 2026-02-16 11:22:14 ot_train.py:423 step:800 smpl:26K ep:5 epch:1.34 loss:0.039 grdn:1.242 lr:2.4e-05 updt_s:2.022 data_s:0.003
INFO 2026-02-16 11:28:59 ot_train.py:423 step:1K smpl:32K ep:7 epch:1.68 loss:0.032 grdn:1.092 lr:2.3e-05 updt_s:2.024 data_s:0.003
INFO 2026-02-16 11:28:59 ot_train.py:443 Checkpoint policy after step 1000
INFO 2026-02-16 11:36:15 ot_train.py:423 step:1K smpl:38K ep:8 epch:2.02 loss:0.028 grdn:0.970 lr:2.2e-05 updt_s:2.023 data_s:0.008
INFO 2026-02-16 11:43:02 ot_train.py:423 step:1K smpl:45K ep:9 epch:2.35 loss:0.025 grdn:0.902 lr:2.1e-05 updt_s:2.029 data_s:0.003
INFO 2026-02-16 11:49:49 ot_train.py:423 step:2K smpl:51K ep:11 epch:2.69 loss:0.022 grdn:0.862 lr:2.0e-05 updt_s:2.026 data_s:0.003
INFO 2026-02-16 11:56:37 ot_train.py:423 step:2K smpl:58K ep:12 epch:3.02 loss:0.019 grdn:0.813 lr:1.9e-05 updt_s:2.027 data_s:0.007
INFO 2026-02-16 12:03:24 ot_train.py:423 step:2K smpl:64K ep:13 epch:3.36 loss:0.017 grdn:0.762 lr:1.8e-05 updt_s:2.028 data_s:0.004
INFO 2026-02-16 12:03:24 ot_train.py:443 Checkpoint policy after step 2000
INFO 2026-02-16 12:10:40 ot_train.py:423 step:2K smpl:70K ep:15 epch:3.70 loss:0.016 grdn:0.726 lr:1.7e-05 updt_s:2.027 data_s:0.003
INFO 2026-02-16 12:17:25 ot_train.py:423 step:2K smpl:77K ep:16 epch:4.03 loss:0.014 grdn:0.687 lr:1.5e-05 updt_s:2.015 data_s:0.008
INFO 2026-02-16 12:24:10 ot_train.py:423 step:3K smpl:83K ep:17 epch:4.37 loss:0.012 grdn:0.653 lr:1.4e-05 updt_s:2.022 data_s:0.003
INFO 2026-02-16 12:30:56 ot_train.py:423 step:3K smpl:90K ep:19 epch:4.70 loss:0.012 grdn:0.662 lr:1.2e-05 updt_s:2.021 data_s:0.003
INFO 2026-02-16 12:37:41 ot_train.py:423 step:3K smpl:96K ep:20 epch:5.04 loss:0.011 grdn:0.646 lr:1.1e-05 updt_s:2.014 data_s:0.007
INFO 2026-02-16 12:37:41 ot_train.py:443 Checkpoint policy after step 3000
INFO 2026-02-16 12:44:56 ot_train.py:423 step:3K smpl:102K ep:22 epch:5.38 loss:0.010 grdn:0.607 lr:9.6e-06 updt_s:2.021 data_s:0.003
INFO 2026-02-16 12:51:42 ot_train.py:423 step:3K smpl:109K ep:23 epch:5.71 loss:0.009 grdn:0.588 lr:8.3e-06 updt_s:2.023 data_s:0.003
INFO 2026-02-16 12:58:30 ot_train.py:423 step:4K smpl:115K ep:24 epch:6.05 loss:0.009 grdn:0.583 lr:7.1e-06 updt_s:2.024 data_s:0.008
INFO 2026-02-16 13:05:16 ot_train.py:423 step:4K smpl:122K ep:26 epch:6.38 loss:0.008 grdn:0.550 lr:6.1e-06 updt_s:2.022 data_s:0.003
INFO 2026-02-16 13:12:00 ot_train.py:423 step:4K smpl:128K ep:27 epch:6.72 loss:0.008 grdn:0.541 lr:5.1e-06 updt_s:2.017 data_s:0.003
INFO 2026-02-16 13:12:00 ot_train.py:443 Checkpoint policy after step 4000
INFO 2026-02-16 13:19:13 ot_train.py:423 step:4K smpl:134K ep:28 epch:7.06 loss:0.007 grdn:0.536 lr:4.3e-06 updt_s:2.010 data_s:0.006
INFO 2026-02-16 13:25:58 ot_train.py:423 step:4K smpl:141K ep:30 epch:7.39 loss:0.007 grdn:0.531 lr:3.6e-06 updt_s:2.018 data_s:0.003
INFO 2026-02-16 13:32:42 ot_train.py:423 step:5K smpl:147K ep:31 epch:7.73 loss:0.007 grdn:0.514 lr:3.1e-06 updt_s:2.018 data_s:0.003
INFO 2026-02-16 13:39:27 ot_train.py:423 step:5K smpl:154K ep:32 epch:8.06 loss:0.007 grdn:0.507 lr:2.7e-06 updt_s:2.014 data_s:0.006
INFO 2026-02-16 13:46:12 ot_train.py:423 step:5K smpl:160K ep:34 epch:8.40 loss:0.007 grdn:0.506 lr:2.5e-06 updt_s:2.017 data_s:0.003
INFO 2026-02-16 13:46:12 ot_train.py:443 Checkpoint policy after step 5000
INFO 2026-02-16 13:46:42 ot_train.py:514 End of training
```