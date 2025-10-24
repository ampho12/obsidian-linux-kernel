
Quadrupeds have been pushed to the limit using RL, but not humanoids. Why is this?



Largest penalty is sim is falling over. If you can step fast, you don't have to worry about "dynamic balance"

## Drunken Robot Syndrome

1. small stutter to reorinet



Really nice behaviors are coming from reference motion data that is retargetted for robots.



Control Theory: Invaluable Intuition
Learning Theory: drive it to the limit
# Action Space Design


We sample action from a distribution


$$
a \sim \mathcal{N}(\mu_\theta(s), \sigma_\theta(s))
$$


$$\tau = K_p(q_{ref} - q) - K_d \dot{q} + K_p K_a a$$

We will treat this term as "gravity compensation" which is keeping robot at a particular scenario like a spring. This is driven by the PD controller at a very high rate 10khz
$$K_p(q_{ref} - q) - K_d \dot{q}$$

The last term is what the neural network outputs $a$ times some $K_a$ and is deviaition effort from the spring. We will call this the feed-forward torque. This is run at a lower freq


High gains -> bandwidth of policy learning slower (why)


High gains means the K_p is very high, hence the model has to learn tiny a's as any deviations will shoot to torque limit and we will effectively treat this as a bang bang controller.

K_a is controlling learning rate / sampling rate / exploring rate. High K_a means policy will be able to explore more positions as step size is larger.

**Bandwidth**: available actions to the policy that are within joint limits

High K_p -> easier to start training as robot is more stiff towards the reference position but it leads to lower bandwidth across actions space as even small actions send it close to joint limit.  Thus we want lower gains.

> Try both high Kp and low Kp and see training curves

The policy has a standard deviation for the action space (i.e think of the poiicy outputting
a mean and a standard deviation, i.e a gaussian). If the output gaussian's stanard deviation is high, we say policy has low confidence in its output. 

> Above all, we want these standard deviation to converge. Above rewards, above everything!
### How to pick gains for good Exploration

Idea is to use the PD controller as a basis for setting limits so that if we reach the joint limit, it applies max possible torque in negative direction.

Inutition: PD controller should exert maimum effort at the boundary of ROM. This gives us a lower bound for the P gain

At the minimum, our Kp needs to be large enough so that if our error is the entire ROM, we have max torque being output to avoid hitting the joint limit

$$K_{p, min} = \frac{\tau_{max}}{|q_{max} - q_{min}|}$$

If we want max torque if our virtual spring is centered at the zero point. (let's say we are not going from extreme to extreme) then we want this Kp.
$$K_{p, max} = \frac{\tau_{max}}{\frac12|q_{max} - q_{min}|}$$

Our K_p will somewhere in $[K_{p, min}, K_{p, max}]$

$$K_d \approx \frac{K_p}{20}$$

> How to protect joint mechanics 

If u use true feedforwarad torque as action space, we need higher frequency. PD controller is like a filter that is smoothing policy. If we leave PD controller (i.e set it to 0), then we need higher frequency to allow the policy to respond to it. This is susceptible to modeling errors.

Instead of clamping position values, in simulation define zones that penalize the policy if they reach zones. These zone is +- 10% of joint limit.


1. High Fidelity Torque and Current Feedback 
2. Output Torque Sensing

Low torque in sim: better for exploration

train policy with good exploration, then distill that using student teacher to get a high gain policy that we deploy on hardware.



# Observation

1. Base Linear Vel
2. Base Angular Vel
3. Orientation (Projected Gravity) - much easier space to learn than quaternion
4. Joint Position
5. Joint Velocity
6. Last Action
7. Command (Velocity, Navigation, Height) -- can be expressive
8. Optional (hieght scan, depth image)


### Exceptions

- Motion imitation: feed oveserve refernece, phase of motion
- Navitgation: observe a clock to understand how much time to go. Time to go is how much time is left in the episode. The policy learns that it has more time and can walk to goal instead of throwing itself towards it.
- Object poses etc

### Case Study Linear Velocity Simulator

- Do estimate linear veloicty (velocity of CoM)
    - explicty model baed estimation (kalman filter)
    - explicty learned velocity estimator
    - implicity: linear velocity decoding head so we can say the latent space knows velocity in some form

- Do  not:
    - observation histories (i.e using finite difference and policy should learn velocity)
    - recurrent network: recurrent state is used only in specific circumstances

> ## Unitree Robot doesn't have gooded  linear velocity sensor



### Markov Assumption and Violating
RL is essentially a markov process (if we just depend on last state)

But sometimes, we need more than just the last state

When task is accelaration dependent 
1. fore control with limited sensing
2. Use ~5 times steps of observation
3. Use LSTM / GRU

When tasks require memory
1. E.g. navigation
2. Use memory module (e.g. neural volumetric memory, loco transformer)
3. Use explicit representation (e.g. an occupancy map)


When there are fundamental constraints
1. e.g. poor quality sensors, non rigid contacts
2. You are better off fixing the fundamental limitation if possbile
3. Using recurrent architectures can help 


# Partial Observability


## Actor Critic
Image: information dense datatype but doesn't provide state (e.g. joint position)

Use Asymetric actor critic: give critic the most compact compact ground truth in simulation (i.e the state). All the things we don't need in actor's space, give it to the critic (e.g CoM, mass etc)

> This is always the case! unless you have good reason use most privileged critic

Actor still sees high information quality but less explicit state represetation (Com, etc)


## Student Teacher

Teacher becomes like a critic. Train a privileged policy using all the available information that may not be avaialble to real world. The teacher is perfect and high performance.

Then we distill the policy using DAGR or something to train the student with teacher reference + actual sensor input.

Height scan? 

(4000 environments is standard without heavy sensor data) - make a teacher

(256 environments with depth data) - distiil into a more real model

When starting out on a task; make sure that we give infinite control bandwidht, and remove all constraints. Don't enforce constraints to start with.

## Decoding Heads

Used height scan

A head is an output of the model

1 head is controlling robot
1 head is predicting height - this can be trained against privileged information

(we can also add a head for linear velocity, if this converges, we can argue that latent space has enough information to grasp latent)





## Tips

Good RL is very highly predicated on good system identification.

Task difficulty should be proportional to the capbaility of the policy

Increase task difficulty if policy > 75% success. lower difficulty <50% 


Large positive rewards that encode the desired bulk behavior (.e.g velocity tracking)
- L1 vs L2 exponential, tanh, inverse

Small Negative Penality that encode style (.e.g minimize energy usage)
- L1 vs L2 penalty

After mean total reward converges, train 2-5x longer for good sim2real transfer
- Initial rewards are coming from large positive rewards. After that, the small regular errors will start converging.

Ensure we always have some net postive reward. If there is negative rward, it will learn to kill itself. If any step is negative at all, it will keep resetting and not learn.


Less rewards => more explorations => optimizer will exploit 

**Dependency in rewards**: if we have 2 independent rewards 

1. lift box
2. grip box

policy my exploit one reward more (e.g. throw the box in the air but not grasp it)

If we multiply the two rewards together 

$(lift) \cdot (grip)$

Then robot will have high reward only when it does some degree of grip and lift, and it can only access lift reward if grip is active. 

Don't re-weight rewards until the bulk behavior changes. We can input reward scaling as part of the observation space.


Reasons standard deviations increase
- Critic should be able to estimate reward. (use a head?). If critic cannot esitmate reward, no good. e.g. if we only give past position and current position, it cannot estimate accel.
- Dynamics is uncrtrollbale (e.g. gians high or low, underactuation)
- Poor simulation config


Motion references give some task specification but since its using RL it can estimate ground friction etc (generate data at train time). we can generalize with 
# Appendix

# TODO
1. Spot running paper try it out for good reward inspiration
2. 
## Controllability and Learning 



# Summary

- Low PD gains result in better exploration
- Hard constraints hurt exploration
- Start with perfect model (perfect information about the world, no noise no delay, no corruption). add realism iteratively.
- Train longer than we think we need to.
- Less domain randomization: 
    - Don't use it as a crutch for bad system id
- State estimation will make your life easier.
- Don't touch hyperparameters without good reason
- *No replacement for principled system identification*



"Good RL policy is a reward of doing due diligence in system id and training, we cannot skip to good RL without building the foundation"





