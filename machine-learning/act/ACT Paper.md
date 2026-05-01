

Imitation learning performs poorly on: fine grained tasks that require high frequency control and closed loop feedback.

small errors in the predicted action can incur large differences in the state. The new state will cause a different action. The error is now compounding (verify this).

## Action Chunking
- Instead of predicting a single action, predict k actions. This means we don't take error from k "drifted states" when predicted k actions. Fewer opportunities for sampling state means fewer decision points and error propagation. 
- Another interesting phenomenon is the markov property of single action prediction
    - A state can have multiple immediate actions that can achieve the same goal
    - If trained with Mean Squared Error loss here, the policy will learn to output the mean of the two actions to minimize MSE. This is undesiriable
    - If policy predicts k steps, and we take MSE across all the k steps, we still choose average trajectory. This is mitigated by the CVAE approach.
- At each observation, we predict a trajectory. Say we have something like this in the training data:
    - the operator pauses for for 5 seconds to think. Then continues.
    - The model sees the exact same input, yet must predict different trajectories. This is called temporally correlated confounding actions.
    - As a result the dataset will contain k-action trajectories that contain both pause and movement.
        - 100% pause and no movement (e.g. long enough pause or small traj length)
        - 80% pause and 20% movement 
        - any other combination. Highly unlikely to get 0% pause but theoretically possible.
    - The model will now learn to predict such trajectories that are composed of waiting and movement.
    - **Takeaway: the confounding decision making still occurs, although reduced k-fold.**
- Predicting k actions can lead to jumpy transitions between each sense -> predict -> action -> sense cycle. Temporal assembling is used to combat this.


## Conditional VAE
In the naive case, without CVAE, the training data looks like
```
(observation1) -> model -> traj1
(observation1) -> model -> traj2
(observation1) -> model -> traj3
(observation1) -> model -> traj4
```

this means model will be trained to produce the average of the four trajectories. 

To combat this, we essentially add a sacrificial variable, z, that is conditioned on the the trajectory
```
traj -> condiotional encoder -> z
```

Then we do this
```
(observation1, z(traj1)) -> model -> traj1
(observation1, z(traj2)) -> model -> traj2
(observation1, z(traj3)) -> model -> traj3
(observation1, z(traj4)) -> model -> traj4

```

The model can now attribute the traj1 to a specific z. This means it will not try to average now. This also benefits temporal confounding as prior information about the trajectory helps the decoder distinguish temporally confounded trajectories (imagine traj1 through 4 were the pause + movement mixed trajectories).

**Takeaway: Action chunking decreases how often we see the confounding decision problem. When it does occur, CVAEs handle it**

Further, during training we try to condition z towards a unit Normal (think about ELBO and how KL divergence term in the ELBO can condition the q(Z|obs) distribution to a unit normal)

During inference, we simply set z to 0. This helps with making sure model is deterministic, this is important for temporal ensembling otherwise, we would end up adding together different strategies/ trajectores. This will degrade determinisim.


## Temporal Ensembling

The policy predicts k timestamps worth of actions. We run the policy at each timestamp.

So we get

```
t0 : a0 a1 a2 a3 a4 a5 ..... ak
t1 :    a0 a1 a2 a3 a4 a5 ..... ak
t2 :       a0 a1 a2 a3 a4 a5 ..... ak
t2 :          a0 a1 a2 a3 a4 a5 ..... ak
```

We sum this up for each timestep with decaying weights
```
t0  : (0.5 * a0) (0.3 * a1) (0.2 * a2) (0.1 * a3)..... ak
t1  :            (0.5 * a0) (0.3 * a1) (0.2 * a2) (0.1 * a3)..... ak
t2  :                       (0.5 * a0) (0.3 * a1) (0.2 * a2) (0.1 * a3)..... ak
-> sum
res : (a0      ) (      a1) (      a2) (      a4) .... 
```

This smooths out the actions at step.

Note that we don't do temporal ensembling for training. During inference, sampling at each timestep does reintroduce per step decision making and opportunities for sampling out of distribution states and propagating errors, but due to the decaying weights these errors average out.

Essentially this is a sort of an average between "predict k steps -> sense -> repeat" and "predict 1 step -> sense -> repeat". Although we are not averaging intra-trajectory but inter-trajectory.



Benefits of leader follower Teleoperation
1. fine manipulation requires operating near singularities. IK frequently fails on 6dof robot with no redundancies
2. weight of leader robot prevents fast movements and dampens small vibrations.
3. Observed better performance on precise tasks with joint space mapping rather than VR + IK.
4. Lower compute and latency

Teleoperation and Data recording at 50Hz.


# Conditional VAE Architecture with Transformers



