
## Frames in URDF
- In URDF, all frames are joint frames. Link's live inside their parent joint frame.
- A joint takes an input frame and produces an output frame by translating and rotating it.
    - The `origin` property defines this transform
- The very first joint is a word joint which doesn't take an input frame.
- A "link frame" is simply the output frame of parent joint. 

Consider this example
```xml
  <joint name="l_hip_pitch" type="revolute">
    <parent link="torso"/> // this joint's input frame is "link frame" of torso
    <child link="l_thigh"/> 
    <origin xyz="0 0.10 0.75" rpy="0 0 0"/> // output frame
    <axis xyz="0 1 0"/>
    <limit effort="200" lower="-2.5" upper="2.5" velocity="10"/>
  </joint>
```

In this case, the input frame is the torso's "link frame" i.e the output frame of torso's parent joint. If torso has no parent joint, it's the world frame.




A link's origin cannot be offset. It is either the origin assigned by the loader (e.g. drake, mujoco etc) or the origin of the parent joint. 

```
(parent link frame)
   └── joint <origin>  →  (child link frame)
                               ├─ visual <origin>      (relative to child link)
                               ├─ collision <origin>   (relative to child link)
                               └─ inertial <origin>    (relative to child link)

```

parent and child relation ships are determined using joints. Consider the a 2 dof leg

```xml
  <joint name="l_hip_pitch" type="revolute">
    <parent link="torso"/>
    <child link="l_thigh"/>
    <origin xyz="0 0.10 0.75" rpy="0 0 0"/>
    <axis xyz="0 1 0"/>
    <limit effort="200" lower="-2.5" upper="2.5" velocity="10"/>
  </joint>
  <joint name="l_knee_pitch" type="revolute">
    <parent link="l_thigh"/>
    <child link="l_shank"/>
    <origin xyz="0 0 -0.40" rpy="0 0 0"/>
    <axis xyz="0 1 0"/>
    <limit effort="200" lower="-2.5" upper="2.5" velocity="10"/>
  </joint>
  <joint name="l_ankle_fixed" type="fixed">
    <parent link="l_shank"/>
    <child link="l_foot"/>
    <origin xyz="0 0 -0.40" rpy="0 0 0"/>
  </joint>
```

origin in the joint is the transform / offset from the parent's link frame to the joint frame. The child's link frame is coincident with the joint frame


# Frames in SE3

An SE3 is a passive transform from base from to target frame. It's essentially a jacobian.

It transforms both orientation and position of input vector so its correctly rexpressed in target frame.

In robotics notation, a transform

$$
^BT_A
$$
which takes input in A expresses in B.
$$
^Bv = ^BT_A ^Av
$$


In pinocchio, we can get
$$
^\text{world}T_\text{frame}
$$
```python

model = pin.buildModelFromUrdf(urdf_file)
data = self.model_pin.createData()

# f = frame
# o = origin (world frame)
# M = SE3 matrix
data.oMf[frame_id] # ^oM_f
```


In drake, the notation for $^BT_A$ is  $X_{BA}$   

|Task|Pinocchio|Drake|
|---|---|---|
|Frame pose in world|`data.oMf[frame_id]`|`plant.CalcRelativeTransform(ctx, world, frame)`|
|Body pose in world|`data.oMi[joint_id]`|`plant.EvalBodyPoseInWorld(ctx, body)`|
|Jacobian (world)|`computeFrameJacobian(..., WORLD)`|`CalcJacobianSpatialVelocity(...)`|
|Forward kinematics|`forwardKinematics(model, data, q)`|`plant.SetPositions(ctx, q)` (auto-updates)|
|Get body by name|`model.getFrameId("name")`|`plant.GetBodyByName("name")`|
|Get frame by name|`model.getFrameId("name")`|`plant.GetFrameByName("name")`|
|World frame|implicit (`o` in `oMf`)|`plant.world_frame()`|
|Body's frame|`model.frames[id]`|`body.body_frame()`|
|Set joint positions|`q` passed to `forwardKinematics()`|`plant.SetPositions(ctx, q)`|
|Get joint positions|`q` (user manages)|`plant.GetPositions(ctx)`|