
A reference frame is an orientation and origin in space.


1. `world_frame`: an arbitrary fixed global reference
2. `body_frame`: a frame fixed to a rigid body link.


## Notation

Drake uses the following notation

$$
X_{AB}
$$
is pose of $B$ measured in $A$, concretely it means:

1. $p^{F}_{FM_o}$ is the vector from F's origin to M's origin expressed in F
2. $R_{FM}$ is the axes of $M$ expressed in $F$. (i.e column's of M expressed in F's basis).

# Bodies


To think about building bodies, first say we have a rigid body. This body will have a center of mass or $CM$. The CM is fixed in space.

We then choose another point that is rigidly fixed to the body but may not coincide with the CM. We call this frame the body frame and the point is called body origin.  The only way drake knows the body origin is because we provide the quantity `p_BoBcm_B` which is the position vector of the Body CM from the body origin in the body frame.

Now we simply describe the inertia and the geometry of the body using this reference frame as our anchor.

The spatial inertia in drake is defined by 

```cpp
SpatialInertia<double>::MakeFromCentralInertia(
    mass, /* mass */
    p_BoBcm_B, /* position of CoM from body origin in the body frame */
    I_Bcm_B /* Inertia Tensor about the center of mass in the body frame */
)
```


where we specify the position of the COM from the body origin and the moment of inertia about about the COM. Both are expressed in the body frame.

# Joint

A joint is a kinematic constraint that defines how one frame moves relative to another frame.

It is done by introducing a new frame called the joint frame.

the joint frame is defined by two pose transforms

1. Fixed pose transform of joint frame F in the parent body frame `X_PF`
2. Fixed pose transform of joint frame M in child body frame B `X_BM`
3. Since F and M coincide, we can define a coincidental transform between the two. This transform can vary over time.


drake computes a pose transform `X_FM(\theta)`. This is a transform from F to M in F's reference frame and parameterized by `\theta`.


# Jacobian

Drake's jacobian API works like this


The generalized coordinates are frame free

There are three frames

1. Body Frame: usually denoted by `B`. This is the frame on which our point of interest lives on and is expressed in. `p_BoBi` is the position vector in `B` from body origin `Bo` to point of interest `Bi`
2. Measurement Frame, usually denoted by `A`. This the frame w.r.t whose origin which we measure the velocity of `p_BoBi` in frame `B`
3. Expression Frame, usually denoted by `E`. This is the frame in which we express the final jacobian. i.e $Jq = v_p^E$

The generalized coordinates themselves have mixed reference frames, and sometimes no reference frames. (e.g. free body coordinates are w.r.t to the world, but the generalized joint coordinates don't have a reference frame)


We can express it as

$$
V^E_{AB_p}
$$

I.e the velocity of point B_p fixed in B, measured in A, but expressed in E.

1. `frame_B`: this defines the frame on which the point lives on. This is usually the body frame and an offset from the Body origin is specified.
2. `frame_A`: this the frame in which we measure the motion 
3. `frame_E`: we finally express the measured motion in this frame

```python
Jq = plant.CalcJacobianTranslationalVelocity(
    context=plant_ctx,
    with_respect_to=JacobianWrtVariable.kv, # different from kQdot
    frame_B=link2_tip,
    p_BoBi_B=p_BoBi_B,
    frame_A=W,
    frame_E=W,
)
```

Similary, we can get the full bias term

$\dot{J} v$ directly

Jdotv = plant.CalcBiasTranslationalVelocity(
    context=plant_ctx,
    with_respect_to=JacobianWrtVariable.kv, # different from kQdot
    frame_B=link2_tip,
    p_BoBi_B=p_BoBi_B,
    frame_A=W,
    frame_E=W,
)


## Contact Jacobian

Usually we want to find a contact jacobian that can convert the contact force at a point $C$ into a generalized force for use with dynamics

$$
Q = J^T F
$$



# Kinematics


## Forward Kinematics

## Inverse Kinematics

