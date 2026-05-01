# Pose Estimation: A Unified View

---

## The Fundamental Problem

A camera pixel $(u, v)$ gives you a **ray**, not a point.
Depth is lost in projection. You cannot recover a 3D point from one pixel alone.

```
    camera
       o
        \
         \   ← the ray. Point could be anywhere along it.
          *
           \
            *
             \
              * ...
```

Every pose estimation method is an answer to the same question:

> **What additional constraint pins the depth along each ray?**

---

## The Unifying Idea

You have a rigid object. Its points have **known 3D relationships** to each other
(from measurement, CAD, or just the plane equation).

If you can see $N$ rays (from $N$ detected pixels), and you know how the corresponding
3D points relate to each other, you can solve for the one rigid pose $(R, t)$ that
places all 3D points consistently on their rays.

```
        cam
         o
        /|\
       / | \
      /  |  \
     *   *   *   ← 3D points, constrained to land on their rays
      \  |  /      AND to maintain their known 3D relationships
       \ | /
        [object frame]
```

The known 3D relationships are the constraint that removes the depth ambiguity.


# Camera Intrinsic Matrix

How do we express the ray-point duality?

The axis are:
1. Z axis as the principal / optical axis. Direction camera is pointing towards.
2. X to the right.
3. Y down.

![[Pasted image 20260402000251.png]]



Consider image plane at $Z = z$. We need only find the intersection of the plane at $Z = z$ and the line segment between the origin and  $X, Y, Z$ .

This gives
$$
(X, Y, Z) \cdot \frac{z}{Z} =
(\frac{X}{Z}z, \frac{Y}{Z}z, z)
$$

We have one focal length in our pinhole camera model, $f$ which is in meters, therefore.
$$
(\frac{X}{Z} f, \frac{Y}{Z} f, f)
$$

Some older cameras have rectangular pixels. $ps_x$ and $ps_y$ define the sizes. 

Now the pixel along the X axis is given by
$$
u = \frac{X}{Z} 
\frac{f}{ps_x}
$$
And for $Y$ axis as
$$
v = \frac{Y}{Z} \frac{f}{ps_y}
$$

We use
$$
\begin{align*}
f_x &= \frac{f}{ps_x} \\
f_y &= \frac{f}{ps_y}
\end{align*}
$$

Which gives us a pixel mapping
$$
\begin{align*}
u = f_x \cdot \frac{X}{Z} \\
v = f_y \cdot \frac{Y}{Z}
\end{align*}
$$

What about $Z$ mapping? We assume pixels along $Z$ are basically of length $f$, the focal length. This is fixed for the camera, just like $ps_x$ and $ps_y$. So our Z pixel always shows as $1$. In reality there is no grid of pixels along the $Z$ dimension, this is just mathematical convenience.

This gives
$$
\begin{bmatrix}
u \\
v \\
1
\end{bmatrix}
=
\begin{bmatrix}
f_x \cdot \frac{X}{Z} \\
f_y \cdot \frac{Y}{Z} \\
1
\end{bmatrix}
$$

While we can simplify the third row of this equation away, there is a way to use it for homogeneous coordinates. Recall that in image space the origin is shifted by $(-c_x, -c_y)$

Therefore,
$$
\begin{bmatrix}
u - c_x\\
v - c_y\\
1
\end{bmatrix}
=
\begin{bmatrix}
f_x \cdot \frac{X}{Z} \\
f_y \cdot \frac{Y}{Z} \\
1
\end{bmatrix}
$$

We can club this all in one equation
$$
\begin{bmatrix}
u \\
v \\
1
\end{bmatrix}
=
\begin{bmatrix}
f_x & 0 & c_x \\
0 & f_y & c_y \\
0 & 0 & 1
\end{bmatrix}
\begin{bmatrix}
\frac{X}{Z} \\
\frac{Y}{Z} \\
1
\end{bmatrix}
$$
We found the intrinsic matrix $K$ which converts from dimensionless coordinates to pixels
$$
K = 
\begin{bmatrix}
f_x & 0 & c_x \\
0 & f_y & c_y \\
0 & 0 & 1
\end{bmatrix}
$$
and our equation becomes
$$
Z \begin{bmatrix}
u \\
v \\
1
\end{bmatrix}
=
K
\begin{bmatrix}
X \\
Y \\
Z
\end{bmatrix}
$$
where we have multiplied both sized with Z. One more note, folks usually write Z on the LHS as $\lambda$ to indicate intent that $Z$ doesn't exist.
$$
\lambda \begin{bmatrix}
u \\
v \\
1
\end{bmatrix}
=
K
\begin{bmatrix}
X \\
Y \\
Z
\end{bmatrix}
$$

The third row of the equation still comes out to be $\lambda = Z$, so equations hold. Lambda just signals intent.



---

## The Spectrum of Methods

Everything below is a point on one axis:

```
← how you supply the 3D constraint →

Explicit 3D coords          Plane equation only          No geometry at all
(PnP)                       (Homography)                 (fails — underdetermined)

    │                              │
    │                              │
    ▼                              ▼
  sparse                  sparse ──→ dense
  (keypoints)             (keypoints → photometric)
```

"Dense" is orthogonal — it means using all pixels instead of a few keypoints.
The geometry is identical either way.

---

## Level 1: PnP (Explicit 3D)

### Idea

You supply the 3D coordinates of $N$ points in the object frame directly.
Each detected pixel gives a ray. Find the pose that places each 3D point on its ray.

The pose is described by rotation + translation. $(R, t)$

### Inputs

- Object frame coords: $P_i = [X_i, Y_i, Z_i]^\top$ — from CAD / measurement. We convert them to camera frame coords: $P_{i, \text{cam}} = RP_i + t$.
- Detected pixels: $p_i = [u_i, v_i]^\top$ — from your detector
- Camera intrinsics: $K$

### The Constraint (per point)

$$\lambda_i \begin{pmatrix} u_i \\ v_i \\ 1 \end{pmatrix} = K \begin{pmatrix} X_i \\ Y_i \\ Z_i \end{pmatrix}_\text{cam}, \qquad \text{where} \quad [X_i,Y_i,Z_i]_\text{cam} = R P_i + t$$

$\lambda_i = Z_i$ is the unknown depth — it drops out when you divide $u$ and $v$ by it.
Two scalar equations per point. Six unknowns total $(R, t)$.
Minimum: 3 points (P3P). Stable: 4+ points (least squares).

### What provides the depth constraint?

The known distance between points in the object frame.
If point $A$ and point $B$ are 5 cm apart in the model, the pose must place them
5 cm apart in 3D — this fixes the scale and depth.

---

## Level 2: Homography (Plane Constraint)

### Idea

All points lie on a plane, we add this to the constraints. Let $(n_x, n_y, n_z, d)$ be the unknown for the plane in the object frame. All constraints are 

We have $N$ object-frame points $P_i$ and their detected pixels $p_i$. The constraint is:

$$\lambda_i \begin{pmatrix} u_i \\ v_i \\ 1 \end{pmatrix} = K \left[ R \mid t \right] \begin{pmatrix} X_i \\ Y_i \\ Z_i \\ 1 \end{pmatrix}$$

Write out the $3 \times 4$ matrix $[R \mid t]$ using the columns of $R = [r_1 \; r_2 \; r_3]$:

$$\lambda_i \begin{pmatrix} u_i \\ v_i \\ 1 \end{pmatrix} = K \begin{bmatrix} r_1 & r_2 & r_3 & t \end{bmatrix} \begin{pmatrix} X_i \\ Y_i \\ Z_i \\ 1 \end{pmatrix}$$
Expand the right side:

$$\lambda_i \begin{pmatrix} u_i \\ v_i \\ 1 \end{pmatrix} = K \left( r_1 X_i + r_2 Y_i + r_3 Z_i + t \right)$$

Now we introduce the plane constraint. All points satisfy a plane equation: $n_x X_i + n_y Y_i + n_z Z_i = d$. Solve for $Z_i$:

$$Z_i = \frac{d - n_x X_i - n_y Y_i}{n_z}$$
Replace $Z_i$ in the expanded form:

$$\lambda_i \begin{pmatrix} u_i \\ v_i \\ 1 \end{pmatrix} = K \left( r_1 X_i + r_2 Y_i + r_3 \cdot \frac{d - n_x X_i - n_y Y_i}{n_z} + t \right)$$

Collect terms by $X_i$, $Y_i$, and the constant:

$$= K \left[ \left(r_1 - \frac{n_x}{n_z} r_3\right) X_i + \left(r_2 - \frac{n_y}{n_z} r_3\right) Y_i + \left(\frac{d}{n_z} r_3 + t\right) \right]$$

## The homography falls out

This is a $3 \times 3$ matrix times $[X_i, Y_i, 1]^T$:

$$\lambda_i \begin{pmatrix} u_i \\ v_i \\ 1 \end{pmatrix} = \underbrace{K \begin{bmatrix} r_1 - \frac{n_x}{n_z} r_3 & r_2 - \frac{n_y}{n_z} r_3 & \frac{d}{n_z} r_3 + t \end{bmatrix}}_{H} \begin{pmatrix} X_i \\ Y_i \\ 1 \end{pmatrix}$$

That's $H$, for a general plane.

This hasn't simplified the problem however, dependending on the problem:

If you know the plane on the object AND you know $(X_i, Y_i)$ for each point, you can just compute $Z_i$ from the plane equation and run PnP directly. Homography buys you nothing there.

Homography is useful when you don't know the individual point coordinates at all. You have two images of the same plane, and you can match pixels between them: $p_i^* \leftrightarrow p_i$. That's purely 2D-to-2D. No object frame coordinates needed.

The $H$ matrix maps pixels in one image directly to pixels in the other:

$$p_i \sim H , p_i^*$$

You estimate $H$ from the pixel correspondences alone. Then if you know $K$ and the plane $(n, d)$, you decompose $H$ to get $(R, t)$.

So the use cases split like this:

- **You have a 3D model** (know each point's coordinates): use PnP. The plane doesn't help.
- **You have two views of a flat thing** (know it's a plane, but don't know where individual points are in 3D): use homography. Match features between images, estimate $H$, decompose.

The common example: you're tracking a textured flat surface like a poster or a floor. You can match hundreds of feature points between frames, but you never measured their 3D positions. You just know they're coplanar. That's where homography shines.

This hasn't really helped the solutions or reduced the number of unknowns. 

## Sanity check: the $Z = 0$ plane

Set $n = (0, 0, 1)$, $d = 0$ (the $Z = 0$ plane). Then $n_x = 0$, $n_y = 0$, $n_z = 1$:

$$H = K \begin{bmatrix} r_1 & r_2 & t \end{bmatrix}$$

Recovers the well-known simple case exactly.

## What happened

The plane constraint let us write $Z_i$ as a linear function of $X_i$ and $Y_i$. That collapsed the 4-component vector $(X_i, Y_i, Z_i, 1)$ into a 3-component vector $(X_i, Y_i, 1)$, and the $3 \times 4$ PnP matrix into a $3 \times 3$ homography.

The plane normal $(n_x, n_y, n_z)$ controls how $r_3$ gets absorbed into the other columns.

## What happened to the unknowns?

In full PnP, you solve for all 3 columns of $R$ plus $t$ — that's the $3 \times 4$ matrix with 12 entries (constrained to 6 DOF by $R \in SO(3)$).

On the plane, $r_3$ dropped out. But you haven't lost it — once you know $r_1$ and $r_2$, the third column is forced: $r_3 = r_1 \times r_2$ (because $R$ is a rotation matrix, its columns are orthonormal). The plane constraint eliminated 3 parameters for free.

So the DLT system shrinks from $2N \times 12$ to $2N \times 9$, and minimum correspondences go from 3 to 4 (since $H$ has 8 DOF — nine entries minus one for scale).

Sure. Here's the setup.

**What you have:**

- A **reference image** $I^*$ — a photo of the plane taken from some initial position. This is your "model."
- A **current image** $I$ — a photo of the same plane from a new position. You want the pose of this camera relative to the reference camera.
- **Camera intrinsics** $K$ — from calibration. Same camera, or known for both.
- **Plane parameters** $(n, d)$ — you know the plane's normal and distance, defined in the reference camera's frame.
- **Pixel correspondences** — feature matches between the two images: "pixel $p_i^_$ in $I^_$ corresponds to pixel $p_i$ in $I$." You get these from a feature matcher (SIFT, ORB, etc.)

**What you want:**

$(R, t)$ — the rotation and translation of the current camera relative to the reference camera.

**What you solve:**

Step 1: From the pixel correspondences, estimate $H$ using DLT:

$$p_i \sim H , p_i^*$$

This is purely 2D-to-2D. No 3D coordinates, no depth. Just pixels in one image mapped to pixels in the other. Need at least 4 correspondences.

Step 2: Decompose $H$ into $(R, t)$ using $K$ and $(n, d)$:

$$\tilde{H} = K^{-1} H K = R + \frac{t n^\top}{d}$$

**Compare to PnP setup:**

- PnP has: one image, a 3D model with known point coordinates, $K$.
- PnP gives: absolute pose of the camera in the object frame.
- Homography has: two images, a known plane, $K$, pixel correspondences.
- Homography gives: relative pose between the two cameras.

The reference image is doing the job of the 3D model. It implicitly labels every point on the plane by its pixel coordinate, instead of by $(X_i, Y_i, Z_i)$.

### The Missing Transform (explicit)

$$\mathbf{x}^* \xrightarrow{K^{-1}} \text{ray} \xrightarrow{\text{plane}} P \xrightarrow{R,t} P_\text{cam} \xrightarrow{K} \mathbf{x}$$

Step by step:

1. **Unproject** reference pixel to ray: $\quad r = K^{-1} \mathbf{x}^*$
2. **Intersect** ray with plane $(n, d)$: $\quad P = \dfrac{d}{n^\top r} \, r \qquad \leftarrow$ this is the depth along the ray
3. **Rigid transform**: $\quad P_\text{cam} = R P + t$
4. **Project**: $\quad \mathbf{x} = K \, P_\text{cam} \,/\, P_{\text{cam},z}$

### The Shortcut: $H$

Steps 1–4 compose into a single $3\times3$ matrix:

$$\mathbf{x} \;\sim\; \underbrace{K\!\left(R + \frac{t n^\top}{d}\right)\!K^{-1}}_{H} \mathbf{x}^*$$

$H$ encodes $(R, t, n, d)$ all at once.

### What provides the depth constraint?

The plane equation $(n, d)$. This is the implicit 3D model — instead of knowing
$[X, Y, Z]$ for each point explicitly, you know they all satisfy $n^\top P = d$.

### Decompose $H \to (R, t)$

Given $K$ and $(n, d)$:

$$\tilde{H} = K^{-1} H K = R + \frac{t n^\top}{d}$$

From $\tilde{H}$ via SVD, recover $R$ and $t$. `cv2.decomposeHomographyMat` returns
2–4 candidate $(R, t, n)$ solutions. Disambiguate by: depth must be positive,
$n$ must point toward the camera.

### Relationship to PnP

|  | PnP | Homography |
|---|---|---|
| 3D model | explicit $[X,Y,Z]$ per point | implicit: plane $(n,d)$ |
| 2D→3D step | you supply the coords | automated via ray-plane intersect |
| Needs $K$ to estimate? | yes | no (projective $H$ works without $K$) |
| Generalises to non-planar? | yes | no |
| Min correspondences | 3 | 4 |

Homography is a special case where the geometry is planar.
It is not a special case of PnP in implementation — you never write down
3D coordinates; the plane does that work for you.

---

## Level 3: Dense / Photometric (All Pixels)

### Idea

Same geometry as homography. The only change: instead of matching a few
keypoints to estimate $H$, you minimise the pixel intensity difference over
**every pixel** to find $H$ (or directly $(R, t)$).

### The Error

$$e(\mathbf{x}^*) = I_\text{current}\!\left(W(\mathbf{x}^*;\, p)\right) - I^*(\mathbf{x}^*)$$

where $W(\mathbf{x}^*; p) = H \mathbf{x}^*$ for a planar warp, and $p$ are the pose parameters.

### Solve Iteratively (Gauss-Newton)

$$\Delta p = -\left(J^\top J\right)^{-1} J^\top r, \qquad J(\mathbf{x}^*) = \nabla I^*(\mathbf{x}^*) \cdot \frac{\partial W}{\partial p}$$

where $r(\mathbf{x}^*) = I_\text{current}(W(\mathbf{x}^*;p)) - I^*(\mathbf{x}^*)$ is the residual image,
$\nabla I^*$ is the image gradient (edges), and $\partial W / \partial p$ is how the warp changes with pose.

Repeat until $\|r\|$ stops decreasing.

### What pixels contribute?

Only pixels with $\nabla I^* \neq 0$ — i.e. edges and texture.
Flat uniform regions have zero gradient and don't constrain the pose.

---

## The Full Picture

```
Question:  where is the object?
Answer:    find (R,t) such that known 3D points land on observed rays.

                    ┌─────────────────────────────────────────┐
                    │  How do you know the 3D points?         │
                    └─────────────────────────────────────────┘
                              │                    │
                    Explicit [X,Y,Z]         Plane (n,d) only
                    from model/CAD           (implicit model)
                              │                    │
                             PnP              Homography
                              │                    │
                           sparse            sparse → dense
                        (keypoints)       (keypoints → photometric)


                    ┌─────────────────────────────────────────┐
                    │  How many points?                       │
                    └─────────────────────────────────────────┘
                              │                    │
                           sparse                dense
                        (4 corners)          (all pixels)
                              │                    │
                    same geometry,          same geometry,
                    less data              more data, nonconvex
```

---

# Equations Step by Step

---

## 1. The Projection Model

A 3D point $P = [X, Y, Z]^\top$ in the **camera frame** projects to pixel $p = [u, v]^\top$ via:

$$u = f_x \frac{X}{Z} + c_x, \qquad v = f_y \frac{Y}{Z} + c_y$$

In homogeneous form, absorb the division into a scale factor $\lambda = Z$:

$$\lambda \begin{pmatrix} u \\ v \\ 1 \end{pmatrix} = \underbrace{\begin{pmatrix} f_x & 0 & c_x \\ 0 & f_y & c_y \\ 0 & 0 & 1 \end{pmatrix}}_{K} \begin{pmatrix} X \\ Y \\ Z \end{pmatrix} = K \, P_\text{cam}$$

$K$ is the known camera intrinsic matrix. $\lambda = Z$ is the depth — unknown, and the thing we want to recover.

### The Ray

Given pixel $p = [u, v]^\top$, invert $K$ to get the ray direction:

$$r = K^{-1} \begin{pmatrix} u \\ v \\ 1 \end{pmatrix}, \qquad K^{-1} = \begin{pmatrix} 1/f_x & 0 & -c_x/f_x \\ 0 & 1/f_y & -c_y/f_y \\ 0 & 0 & 1 \end{pmatrix}$$

Any 3D point on this ray is $P_\text{cam} = \lambda \, r$ for some $\lambda > 0$.
**Depth $\lambda$ is the one thing the image cannot tell you alone.**

```
cam
 o──────────────────────→  r = K⁻¹p  (ray direction)
          λ=0.3m
            *   ← P could be here
                    λ=0.8m
                      *   ← or here
                              λ=2m
                                *   ← or here
```

---

## 2. Rigid Body Transform: Object Frame → Camera Frame

The object has its own coordinate frame. Its 3D points are defined there.
The pose $(R, t)$ transforms object-frame points into camera-frame points:

$$P_\text{cam} = R \, P_\text{obj} + t, \qquad R \in SO(3),\quad t \in \mathbb{R}^3 \quad (6 \text{ DOF total})$$

Full projection from object frame to pixel:

$$\lambda \begin{pmatrix} u \\ v \\ 1 \end{pmatrix} = K \underbrace{\begin{bmatrix} R & t \end{bmatrix}}_{3\times4} \begin{pmatrix} X \\ Y \\ Z \\ 1 \end{pmatrix}_\text{obj}$$

The $3\times4$ camera matrix is $M = K[R \mid t]$.

---

## 3. PnP: Solving for $(R, t)$

### Setup

You have $N$ correspondences: known 3D points $\{P_i\}$ in object frame,
detected pixels $\{p_i\}$ in image. For each $i$:

$$\lambda_i \begin{pmatrix} u_i \\ v_i \\ 1 \end{pmatrix} = K [R \mid t] \begin{pmatrix} X_i \\ Y_i \\ Z_i \\ 1 \end{pmatrix}$$

Eliminate $\lambda_i$ by crossing both sides with $p_i$ (cross product with a parallel vector is zero):

$$p_i \times \left(K[R \mid t] P_i\right) = 0$$

This gives 2 independent equations per point (the third row is redundant).

### The Linear System (DLT)

Write $m = \text{vec}([R \mid t])$ as a 12-vector. Each point pair contributes 2 rows to a matrix $A$:

$$A \, m = 0, \qquad A \in \mathbb{R}^{2N \times 12}, \quad m \in \mathbb{R}^{12}$$

Solve with SVD: $m$ = last right singular vector of $A$.
Reshape to $3\times4$, recover $R$ by projecting onto $SO(3)$ (SVD again), extract $t$.
This is the **Direct Linear Transform (DLT)** — a closed-form linear solve.

### Nonlinear Refinement

DLT gives an algebraic solution. Refine it by minimising the **reprojection error**:

$$\min_{R,\,t} \sum_i \left\| p_i - \pi(R P_i + t) \right\|^2, \qquad \pi\!\left(\begin{bmatrix}X\\Y\\Z\end{bmatrix}\right) = \begin{bmatrix} f_x X/Z + c_x \\ f_y Y/Z + c_y \end{bmatrix}$$

Nonlinear least squares, solved with Levenberg-Marquardt. `cv2.solvePnP` does DLT + refinement internally.

### Why $N = 3$ is the Minimum

- $N=3$: 6 equations, 6 unknowns — exactly determined (P3P, up to 4 solutions)
- $N \geq 4$: overdetermined — least squares, more stable

---

## 4. Homography: The Planar Special Case

### The Plane Constraint

All object points lie on a plane. Define the plane in the **reference camera frame**:

$$n^\top P = d, \qquad n \in \mathbb{R}^3 \text{ (unit normal)}, \quad d \in \mathbb{R} \text{ (distance)}$$

This gives the identity $1 = n^\top P / d$, which can be substituted into the projection.

### Derivation of $H$

A reference camera pixel $p^*$ back-projects to ray $r = K^{-1} p^*$.
That ray hits the plane at:

$$P = \frac{d}{n^\top r} \, r$$

Transform $P$ into the current camera (relative pose $R$, $t$) and project:

$$P_\text{cam} = R P + t = \frac{d}{n^\top r}\,Rr + t = \frac{1}{n^\top r}\!\left(Rd + t\,n^\top\right) r$$

The scalar $\frac{1}{n^\top r}$ drops out as the homogeneous scale, leaving:

$$p \;\sim\; K\!\left(R + \frac{t n^\top}{d}\right)\!K^{-1}\, p^* \;=\; H \, p^*$$

### What $H$ Contains

$$\boxed{H = K\!\left(R + \frac{t n^\top}{d}\right)\!K^{-1}}$$

| Factor | Role |
|---|---|
| $K^{-1}$ | unproject $p^*$ to a ray |
| $R + tn^\top/d$ | 3D rigid motion + plane constraint (all the geometry) |
| $K$ | re-project to current pixel |

This $3\times3$ matrix encodes all 6-DOF rigid motion **plus** the plane geometry in one shot.
Only possible because the plane collapses 3D structure to 2D — each point on the plane
is parameterised by its 2D position on the plane, not a free $[X,Y,Z]$.

### Estimating $H$ (DLT)

Each 2D $\leftrightarrow$ 2D correspondence $p^* \leftrightarrow p$ gives:

$$p \sim H p^*, \qquad p \times (H p^*) = 0 \quad \Rightarrow \quad 2 \text{ equations}$$

Stack $N \geq 4$ pairs into $A \, h = 0$ (same DLT structure as PnP, now $2N \times 9$, solve for $h \in \mathbb{R}^9$).
`cv2.findHomography` does this with RANSAC for robustness.

### Decomposing $H \to (R, t)$

$$\tilde{H} = K^{-1} H K = R + \frac{t n^\top}{d}$$

From $\tilde{H}$ via SVD, recover $R$ (project to $SO(3)$) and $t$ (requires knowing $n$, $d$).
`cv2.decomposeHomographyMat` returns 2–4 candidate $(R, t, n)$ triples.
Disambiguate: depth must be positive, $n$ must point toward the camera.

---

## 5. PnP vs Homography: The Exact Relationship

When all object points lie on the $Z=0$ plane in the object frame, $P_i = [X_i, Y_i, 0]^\top$, the PnP projection becomes:

$$\lambda_i \, p_i = K [R \mid t] \begin{pmatrix} X_i \\ Y_i \\ 0 \\ 1 \end{pmatrix} = K \begin{bmatrix} r_1 & r_2 & t \end{bmatrix} \begin{pmatrix} X_i \\ Y_i \\ 1 \end{pmatrix}$$

The $3\times3$ matrix $K[r_1 \mid r_2 \mid t]$ is exactly $H$ (up to scale).

So:

$$H = K \begin{bmatrix} r_1 & r_2 & t \end{bmatrix} \quad \text{when the plane is } Z=0 \text{ in object frame}$$

Homography is PnP restricted to a plane. The simplification is exact: instead of
solving a $2N \times 12$ system (DLT for PnP), you solve a $2N \times 9$ one (DLT for $H$).
The plane constraint eliminates 3 unknowns (the third column of $[R \mid t]$).

---

## Next

- Photometric: the warp Jacobian, steepest descent images, Gauss-Newton in detail
