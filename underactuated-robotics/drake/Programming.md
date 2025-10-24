

Programming in drake looks like this

1. Everything is a *System* (plants, sensors, controllers)
2. *Systems* are composed into *Diagrams*
3. A *Simulator* advances a diagram using a *Context*.
4. *Context* is just state + params.






# Systems

Systems are components that manage parts of the whole diagram and have inputs and outputs to talk to other systems.


## MultibodyPlant

Owns the bodies, joints, actuators and their reference frames. 


computes time derivatives (forward dynamics)

Exposes ports to integrate with `SceneGraph`

- *Outputs* poses of regisetred frames
- Inputs a `QueryObject` from `SceneGraph` to query contact forces.


## SceneGraph

It stores a tree of frames anchored to the world frame and geometries attached to those frames.

At each time step:
1. Consumes poses of frames (from a plane e.g. `MultibodyPlant`)
2. Computes contact/collision forces which can be consumed by others (e.g. consumed by `MultibodyPlant`)
3. Renders poses

It needs to be connected to consumer of geometry related forces and a producer of frame poses. It stores `SourceId` for produces of reference frame updates. Each `(source_id, frame_id)` tuple is consumed by the scenegraph.


### Example with MultibodyPlant
```cpp
plant.RegisterAsSourceForSceneGraph(&scene_graph);
```

Gives the `plant` a `SourceId` inside `scene_graph` and `scene_graph` will query it for frame updates.

Each drake body inside a plant has a scenegraph `FrameId`. This is managed internally once the plant is registered with the scenegraph.

Now, we can add a new geometry by


```cpp
plant.ReigsterVisualGeometry(body, X_BG, shape, name, color);
```

The plant calls the `scene_graph` internally with its own `(source_id, frame_id)` tuple.

The plant computes this and forwards this to scenegraph for every registerd frame using a `FramePoseVector`.

Since these systems must live in a diagram, we see this

```cpp
DiagramBuilder<double> builder;

auto& scene_graph = *builder.AddSystem<SceneGraph>();
auto& plant = *builder.AddSystem<MultibodyPlant<double>>(/* time_step */ 0.0);
plant.RegisterAsSourceForSceneGraph(&scene_graph);

// ... add bodies/joints/geometry on plant ...
// Wire geometry poses and queries:
builder.Connect(
  plant.get_geometry_poses_output_port(),
  scene_graph.get_source_pose_port(plant.get_source_id().value()));
builder.Connect(
  scene_graph.get_query_output_port(),
  plant.get_geometry_query_input_port());

plant.Finalize();

auto diagram = builder.Build();
Simulator<double> sim(*diagram);
sim.Initialize();
sim.AdvanceTo(…);

```

Or more succintly

```cpp
// cpp
DiagramBuilder<double> builder;
MultibodyPlant<double>* plant{};
SceneGraph<double>* scene_graph{};
std::tie(plant, scene_graph) = AddMultibodyPlantSceneGraph(&builder, 0.0);

// … add model(s) to *plant …
plant->Finalize();

auto diagram = builder.Build();
Simulator<double> sim(*diagram);
```

```python
#python
builder = DiagramBuilder()
plant, scene_graph = AddMultibodyPlantSceneGraph(builder, time_step=0.0)
```


### Adding Bodies

We can register new geometry for a given frame using

```python
slider_initial_pos = np.array([1.0, 0.0, -0.1]).reshape((3,1))

slider_unit_I = UnitInertia.SolidBox(*eps_box)
slider_I = SpatialInertia(
    mass=eps_mass, 
    p_PScm_E=[0.0, 0.0, 0.0],
    # p_PScm_E=slider_initial_pos,
    G_SP_E=slider_unit_I
)

slider_body = plant.AddRigidBody("slider", slider_I)

color = np.array([0.2, 0.7, 0.3, 1.0]).reshape(4, 1)  # (r,g,b,a) as (4,1)

plant.RegisterVisualGeometry(
    slider_body,
    RigidTransform(),
    Box(*eps_box),
    "slider_visual",
    color
)
```


# URDF


This is a simple way to add a URDF

```python
builder = DiagramBuilder()
plant, scene = AddMultibodyPlantSceneGraph(builder, time_step=0.001)
urdf_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "urdf", "biped_minimal.urdf"))

parser = Parser(plant)
models = parser.AddModelsFromUrl("file://" + urdf_path)
model_instance = models[0]

```


## URDF details


In urdf origin property is a pose transform (offset + rotation) from parent from to current frame expressed in parent frame.


A joint's origin is transform from parent's frame 

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











