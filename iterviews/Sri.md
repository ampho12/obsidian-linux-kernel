

Has some idea of projection, can relate it to PCA after some digging.  This is a theme, but he can get through the paper and relate it back to the model and training.

Has good intuition but makes claims based on intuition without precise 

Wrist camera is really important. 
1. Domain gap: same sensor input.


latency experiments:
- observed but not RCA, not run latency experiments.


velocity is not accurate: use a position based reward: 


domain rednomization for noisy sensors



use rotation to traing grasping



will never get clean data; add noise from guassian distribitution

u noise vs gaussian noise

masking for latency and perfect inputs


system design

you have 5 streams of data

3 are cameras 
1 is leader feedback
1 is follower feedback

there are just concatenated into a file as bytes. Design a training pipeline to ingest this data. Assume you have enough to drop data points that are not "great". (candidate should define great at this point).

given deep mimic -- sparse rewards for joint positions -- deep mimic reference for body joint angle.

did break down.



rl based training:

1. good termination logic
    1. good replay buffer -- no garbage states so your terminations logic
    2. domain randomization -- start with no randomization and then add
    3. regularization: tiny penalities on action and joint vels
2. reward functions
    1. penalty on axis tilt
    2. found in practice -- pose penality allows state where robot's state is completely of. (this is similar to the pid spring based movement)
    3. height base penalty 

wanna make sure that everything is defined before adding more complexity. 

sysid: big bonus
- do sysid before you go into RL
- 


-- 
given

say r
    


4. do standard augmentations -- why
5. get a prior policy
    1. asked the candidate how would you design the pytorch dataloader
        1. candidate: definitely want to normalize data.
6. do a sim / real world rl 
    1. roll out policy
    2. run RL
    3. on-policy correction: if you run on policy collection



