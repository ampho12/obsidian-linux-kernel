
Close, and steps 1–3 are right. Step 4 has one thing folded into it that’s worth pulling apart.

Your 1–3, confirmed

1. What do I want out? → θ. The thing you’ll report.
2. What situations must it work across? → Ω. Data points, scenarios, time steps, adversarial cases.
3. How do the situations merge into one number? → Φ. Sum, average, worst case.

Nothing to fix there.

Step 4, unfolded

You wrote: u converts each situation into something Φ can eat.

Two different things do that jointly, and separating them is the whole point of the setup:

- F produces the number. F(θ, ω, z) is the score of situation ω, given your global answer θ and the local choice z.
- u supplies the local choice. It’s the auxiliary decision you have to make before F can be evaluated.

So the chain is:

ω  →  u(ω) = z   →   F(θ, ω, z) = a number   →   Φ merges the numbers

       ↑ your choice        ↑ given

Also worth noting: u is optional. Many problems have no local decision at all — the score of a situation is determined once you fix θ:

$$\min_\theta ; \Phi_\omega\big[F(\theta,\omega)\big]$$

That’s plain empirical risk minimization: fit parameters, sum the losses, done. No u, no envelope, no alternation, no ICP.

u appears only when the score of a situation is itself a minimization. In CAD matching, “how badly does measurement i fit at pose T?” isn’t answerable until you pick a footpoint — and the honest answer is the best over all footpoints. The inner choice is forced by the modeling, not added for convenience.

So step 4 is really a question, not a slot

Given θ and one situation ω, do I have a score, or do I still have a decision to make?

- A score → no u. Ordinary optimization.
- A decision → that’s u, with Z as its menu.

And if there’s a u, two follow-ups, which are the only two things that determine whether the problem stays easy:

4a. Can I fill in each situation’s choice independently? Free ⟹ the inner problem splits into one tiny problem per situation, and you never handle the whole assignment at once. Tied (by a shared parametric rule, or by a constraint coupling the situations) ⟹ you must solve for the assignment as one object.

4b. Is the per-situation choice cheap and attained? Cheap ⟹ eliminate it, get an envelope in θ, descend by majorize–minimize. Not cheap ⟹ you’re stuck alternating on the joint problem with no envelope to lean on.

The checklist

1. θ — what I report.
2. Ω — the situations it must serve.
3. Φ — how situations merge.
4. Is a situation’s score a decision? If no, stop; ordinary optimization. If yes:

- Z — the menu for one situation.
- 𝒰 / coupling — can situations be filled in independently?
- cheap and attained? — if yes, eliminate and descend the envelope.

CAD matching: θ = pose, Ω = the N measurements, Φ = sum, score is a decision (which footpoint), Z = the surface, independent, cheap. All the easy branches — which is why the algorithm is two lines.


---

That’s correct. The test in (2) is now doing the work it needs to.

Two small tightenings, then I’d stop:

“Something remains to be pinned” — worth adding for the cost to be a number. Not “for the situation to make sense,” since a determined quantity like a residual also has to be pinned down before the situation makes sense, and it isn’t a decision. The sharp version: fix the shared block, look at one situation — is the cost already a number, or is something still freely open? Free and open is the decision; anything you can compute is not.

“There is something common and something per situation” — as written this asserts both exist. Either can be empty (open-loop control has no shared block; ordinary curve fitting has no per-situation one). “There may be” rather than “there is.”

Final form

1. What are the situations this objective applies across? — Ω
2. What am I choosing? Something shared across all situations, and something within each one. Either may be empty; sometimes one determines the other, which is fine. Test for a per-situation decision: fix the shared part, look at one situation — is the cost a number yet, or is something still freely open?
3. How do the per-situation costs merge into one number? — Φ

Then the two questions that decide the difficulty:

- Can the per-situation decisions be made independently of one another?
- Is one situation’s decision cheap, and is the best actually attained?

Both yes and the per-situation block splits into tiny independent problems, gets eliminated, and leaves you descending a landscape in the shared block alone.

That’s your CAD problem, and the setup now says why it’s easy rather than just asserting it.