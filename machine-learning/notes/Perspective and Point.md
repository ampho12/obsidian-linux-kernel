
 What Each Approach Measures

  Reality:  3D object at pose (R, t) relative to camera
                ↓
           Camera (K) projects it
                ↓
           You see a 2D image

  PnP:         sparse 3D↔2D point pairs    →  solve for (R,t)
  Homography:  dense  2D↔2D pixel pairs    →  solve for H  →  decompose to (R,t)
  Photometric: raw pixel intensities       →  minimize ‖I−I*‖  →  get (R,t)


# PnP

  What you need: the 3D coordinates of N specific points, and where those same points appear in the image.

  Known:  Pᵢ = [Xᵢ, Yᵢ, Zᵢ]   in object frame   (from your CAD model)
  Measured: pᵢ = [uᵢ, vᵢ]        in image          (from your detector)

  Solve: find (R, t) such that  pᵢ ≈ π(K, R, t, Pᵢ)  for all i

  where π is the projection:
           ⎡X'⎤         ⎡X⎤
  λ·p  =  K·⎢Y'⎥,   where ⎢Y⎥ = R·Pᵢ + t
           ⎣Z'⎦         ⎣Z⎦

  x' = X'/Z',  y' = Y'/Z',  u = fx·x' + cx,  v = fy·y' + cy

  You have 2 equations per point (u, v), 6 unknowns (R, t). Minimum 3 points (P3P), 4 for a stable least-squares
  solution.

  What you're doing geometrically: each detected 2D point defines a ray from the camera. The constraint is that the 3D
  point must lie on that ray. You're finding the unique (R, t) that places all 3D points on their respective rays
  simultaneously.

      cam
       o
      /|\
     / | \
    /  |  \
   P₁  P₂  P₃    ← known 3D positions, must land on the rays through p₁,p₂,p₃

  Requires: knowing 3D coordinates explicitly in object. Fails if your model (CAD etc) is wrong.






This is the PnP problem.

If I know my camera instrinsics and I have some known points at a pose in the 3d world, then if the points move and I can reliable match those points to known points, then I can find the new pose.


i.e

Given: Known points (A, B, C, ...) and transform between points 

```
● Here's what you're seeing:

  - Green square — desired corner positions (square centred in frame, no rotation, 0.5m away)
  - Orange square — current (detected) corners — slightly offset right/up and perspective-warped due to the 10°/−8°
  tilt
  - Cyan arrows — the pixel error e = s − s*, pointing from desired → current for each corner

  A few things to notice:
  - The orange square is not axis-aligned — the perspective warp from the tilt is visible (the corners don't form a
  perfect rectangle in pixels)
  - All 4 arrows point in roughly the same direction (up-right), meaning the dominant error is a lateral translation
  - The arrows are slightly different lengths/angles per corner — that's the rotational component bleeding in

  The IBVS controller would use exactly those arrows as its error signal and generate a corrective (vx, vy, vz, wx, wy,
   wz) to drive them all to zero. Want to add that loop next?

❯ So IBVS is a control scheme. Can we walk through the equations first? Also if instead of detecting points, I
  have the full plane, I should have practically infinite points right? is there a plane to plane error I can
  calculate?

● Great questions. Let me walk through both properly.

  ---
  IBVS Equations

  Step 1: Features and error

  You pick features s — for N point pairs, that's a 2N-vector:
  s = [u₁, v₁, u₂, v₂, ..., uN, vN]ᵀ

  e = s − s*          ← pixel error, what you want → 0

  Step 2: How do features move when the camera moves?

  The camera has a 6-DOF velocity: vc = [vx, vy, vz, ωx, ωy, ωz]ᵀ

  The key relationship is:

  ṡ = Ls · vc

  Ls is the interaction matrix (image Jacobian), shape (2N × 6). For each point (x, y) in normalized image coords
  x=(u−cx)/fx at depth Z, its 2×6 block is:

           vx    vy    vz       ωx         ωy       ωz
  Lp = [ -1/Z    0    x/Z      xy    -(1+x²)     y  ]
       [   0   -1/Z   y/Z   1+y²      -xy       -x  ]

  Where does this come from? A fixed 3D point P=[X,Y,Z] in the camera frame moves as:
  Ṗ = −v − ω × P     (camera moves, point is fixed)
  Differentiate x = X/Z, substitute Ṗ, simplify — you get exactly the rows above. Each column tells you: "if I move in
  this DOF, how fast does this pixel move?"

  Step 3: Control law

  You want ė = −λe (exponential decay to zero). Since ė = Ls·vc, set:

  vc = −λ · Ls⁺ · e

  Ls⁺ is the Moore-Penrose pseudoinverse of Ls. This is optimal in a least-squares sense — it finds the minimum-norm
  camera velocity that corrects the error.

  Step 4: Which Ls to use?

  - Ls at current pose: works but can be unstable far from desired
  - Ls* at desired pose: stable near the goal but poor far away
  - Average (Ls + Ls*)/2: best practical choice, used in most implementations

  ---
  Plane-to-Plane: Yes, You Have More Options

  You're right — if you see the full plane, you're not limited to sparse points. Three approaches, from least to most
  dense:

  Option A: Homography (best for your case)

  For any two views of the same planar surface, there exists a 3×3 matrix H such that every point on the plane maps as:

  λ [u', v', 1]ᵀ = H · [u, v, 1]ᵀ

  H encodes the full relative pose between the two views for that plane. OpenCV can decompose it:

  H = K (R + t·nᵀ/d) K⁻¹

  where n is the plane normal and d is the distance. You get (R, t) back — that's your 6-DOF error. This is what
  ArUco/AprilTag markers use internally, just with a known pattern to make H robust.

  Key advantage: you use every pixel for computing H, so it's very robust to noise on any individual feature.

  Option B: Photometric (dense IBVS)

  Use raw pixel intensities as features directly:
  s = [I(u₁,v₁), I(u₂,v₂), ..., I(uN,vN)]ᵀ

  e = Icurrent − Idesired     ← per-pixel intensity difference

  The interaction matrix per pixel:
  LI = ∇I · Lp

  where ∇I = [∂I/∂u, ∂I/∂v] is the image gradient. So a pixel with a strong edge contributes a lot; a flat uniform
  region contributes almost nothing.

  Pros: maximal information, no feature detection needed
  Cons: non-convex (lots of local minima if you start far away), sensitive to lighting

  Option C: Moment-based

  Compute area a, centroid (xg, yg), and orientation from the visible plane region. Compact, rotation-invariant, good
  for approach control. But you lose some pose information (doesn't give all 6 DOF cleanly).

  ---
  Summary: What to Use for Port Alignment
  ┌─────────────┬───────────────────────┬──────────────┬───────────────────────────┐
  │  Approach   │      Robustness       │  Info Used   │           Needs           │
  ├─────────────┼───────────────────────┼──────────────┼───────────────────────────┤
  │ Point PnP   │ medium                │ corners only │ reliable corner detection │
  ├─────────────┼───────────────────────┼──────────────┼───────────────────────────┤
  │ Homography  │ high                  │ all pixels   │ any texture on the plane  │
  ├─────────────┼───────────────────────┼──────────────┼───────────────────────────┤
  │ Photometric │ very high (but local) │ all pixels   │ good initial alignment    │
  ├─────────────┼───────────────────────┼──────────────┼───────────────────────────┤
  │ Moments     │ medium                │ region shape │ segmentation              │
  └─────────────┴───────────────────────┴──────────────┴───────────────────────────┘
  For a port, homography is probably your sweet spot: you get the robustness of dense matching without the
  non-convexity of photometric. If your port has any texture or edges, cv2.findHomography + decomposeHomographyMat
  gives you a clean 6-DOF error. Want to see that path next?

✻ Crunched for 1m 6s

❯ let's leave IBVS out of the equation. Help me understand. Pose and Point (pnp), homography, and photometry
  (dense ibvs)

● Good framing. These are three different answers to the same question: "given what I see in my image, where is the
  object?"

  ---
  What Each Approach Measures

  Reality:  3D object at pose (R, t) relative to camera
                ↓
           Camera (K) projects it
                ↓
           You see a 2D image

  PnP:         sparse 3D↔2D point pairs    →  solve for (R,t)
  Homography:  dense  2D↔2D pixel pairs    →  solve for H  →  decompose to (R,t)
  Photometric: raw pixel intensities       →  minimize ‖I−I*‖  →  get (R,t)

  ---
  PnP

  What you need: the 3D coordinates of N specific points, and where those same points appear in the image.

  Known:  Pᵢ = [Xᵢ, Yᵢ, Zᵢ]   in object frame   (from your CAD model)
  Measured: pᵢ = [uᵢ, vᵢ]        in image          (from your detector)

  Solve: find (R, t) such that  pᵢ ≈ π(K, R, t, Pᵢ)  for all i

  where π is the projection:
           ⎡X'⎤         ⎡X⎤
  λ·p  =  K·⎢Y'⎥,   where ⎢Y⎥ = R·Pᵢ + t
           ⎣Z'⎦         ⎣Z⎦

  x' = X'/Z',  y' = Y'/Z',  u = fx·x' + cx,  v = fy·y' + cy

  You have 2 equations per point (u, v), 6 unknowns (R, t). Minimum 3 points (P3P), 4 for a stable least-squares
  solution.

  What you're doing geometrically: each detected 2D point defines a ray from the camera. The constraint is that the 3D
  point must lie on that ray. You're finding the unique (R, t) that places all 3D points on their respective rays
  simultaneously.

      cam
       o
      /|\
     / | \
    /  |  \
   P₁  P₂  P₃    ← known 3D positions, must land on the rays through p₁,p₂,p₃

  Requires: knowing 3D coordinates explicitly. Fails if your model is wrong.

  ---
  Homography

  What you need: 4+ pixel correspondences between your current image and a reference image, plus the assumption that
  all points lie on a plane.

  Known:  reference image I*  (taken from desired pose, or synthesized)
  Measured: corresponding pixels  p ↔ p*  on the plane

  Solve: find H (3×3) such that  p ≈ H · p*   for all correspondences

  H is found by least squares from the correspondences (DLT algorithm, cv2.findHomography). Then:

  H = K · (R + t·nᵀ/d) · K⁻¹

  where n is the plane normal, d is the distance to the plane. Decompose H to get (R, t).

  The key insight: for any two cameras viewing the same plane, every point on that plane maps through a fixed 3×3
  matrix. This is a stronger constraint than PnP — you don't need to know 3D coordinates at all, just that everything
  is coplanar.

  View 1 (desired):     View 2 (current):
    *---*                  *----*
    |   |        H         |    |    (perspective-warped)
    *---*    ------→        *----*

  Every pixel on the plane transforms by the same H.

  Requires: the plane assumption to hold. Breaks down if points are off-plane (depth variation). Also H decomposition
  gives 2 or 4 candidate solutions — you need extra info (e.g. depth must be positive) to pick the right one.

  ---
  Photometric

  What you need: a reference image I* from the desired pose, and a warp model (how pixels move as pose changes).

  Warp W(x; p):  maps pixel x in reference to pixel location in current image
                 p is the pose parameter (6-DOF or just the homography entries)

  Error:   e(x) = I_current(W(x; p)) − I*(x)      ← per-pixel intensity difference

  Minimize:   Σₓ  e(x)²   over p

  This is the Lucas-Kanade / ESM framework. You solve it iteratively:

  1. Warp current image to align with reference using current p estimate
  2. Compute residual image  r = I_warped − I*
  3. Compute image gradient  ∇I  (where edges are)
  4. Update:  Δp = −(JᵀJ)⁻¹ · Jᵀ · r    (Gauss-Newton step)
              J = ∇I · ∂W/∂p              (steepest descent images)
  5. Repeat until ‖r‖ is small

  What you're doing geometrically: you're asking "what warp makes the current image look most like the reference?" No
  feature detection, no point matching — just raw pixel values.

  I* (desired):    I_current:        residual r:

  ████░░██████     ████░░██████      ···00000···
  ████░░██████     ████░░██████      ···00000···     ← aligned
  ████░░██████     ████░░██████      ···00000···

  ████░░██████     ██████░░████      +++00000---     ← misaligned
  ████░░██████     ██████░░████      +++00000---

  Requires: good initial alignment (small basin of convergence), consistent lighting (intensity must mean the same
  thing in both images), and texture — flat uniform regions have zero gradient and contribute nothing.

  ---
  Side by Side
  ┌─────────────────────────┬───────────────────┬───────────────────────────┬──────────────────────────┐
  │                         │        PnP        │        Homography         │       Photometric        │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Input                   │ 3D↔2D point       │ 2D↔2D point pairs         │ raw pixel intensities    │
  │                         │ pairs             │                           │                          │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Needs 3D model?         │ yes               │ no                        │ no                       │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Needs feature detector? │ yes               │ yes (for correspondences) │ no                       │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Plane assumption?       │ no                │ yes                       │ depends on warp model    │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Basin of convergence    │ large             │ large                     │ small                    │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Sensitive to lighting?  │ low               │ low                       │ high                     │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Sensitive to noise?     │ per-corner        │ averaged over many pts    │ averaged over all pixels │
  ├─────────────────────────┼───────────────────┼───────────────────────────┼──────────────────────────┤
  │ Info used               │ N corners         │ ~dozens of pts            │ every pixel              │
  └─────────────────────────┴───────────────────┴───────────────────────────┴──────────────────────────┘
  For your port:
  - PnP: detect the 4 corners, match to CAD. Simple, brittle.
  - Homography: match any texture on the port face to a reference photo. No 3D model needed, robust.
  - Photometric: compare the whole port image patch to a template. Maximum info, but needs to already be roughly
  aligned — good as a refinement step after homography gets you close.

✻ Crunched for 1m 10s
```