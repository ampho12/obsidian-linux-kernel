
- Collision constrained workspace
- Singularity Analysis
    - Another convex hull for spaces where det(Jacobian) = 0
    - "a concentration of singularity hotspot"
    - like FEA: high fidelity near intended workspace
    - 
- Blind spots -- not where you can reach
- Do arms separately, don't mix -- squares the complexity, doesn't add much
- Dexterity Evaluation
    - Points of interest in your workspace
    - Intended Trajectories
        - Does it work
        - How many actuators we engage to get to the point -- focus long term




Sources of imprecision
- Unit testing -- e.g. protractors on follower and leader
- make sure zeros match
- source of error in the leader arm + follower arm
    - some sort of optics or just right angle for now
    - characterize the tolerance
- Incrementally characterize errors as more dofs are engaged for a motion


What Mech E's want
- Dexterity - orientation cone + position