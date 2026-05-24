# WALKTHROUGH — read it in full, then demo it in full

`lean-gate` is 82 lines (47 of code). Unlike a big artifact, the move
here isn't "navigate to the interesting part" — it's *the whole file is
the interesting part*. So this doc does double duty:

1. A **reading map** — the seven landmarks, in order, with line links.
2. A **demo-script skeleton** — the same seven landmarks staged as a live
   sequence you can run end-to-end on screen.

Stage directions only; the words are yours.

> Everything below lives in [`LeanGate.lean`](LeanGate.lean) (the library)
> and [`Smoke.lean`](Smoke.lean) (four runnable scenes). Build + run:
> `lake build && lake exe smoke`.

---

## The one idea, in 30 seconds

A modification to an interpreter's apply rule is admitted only if it
carries a proof that it conservatively extends the baseline — and the
proof *is* the admission certificate:

→ [`Approval`](LeanGate.lean#L33) is a struct with a `proof : CE baseline
rule` field. No value of this type exists unless the Lean kernel
type-checks the proof. **There is no enforcement code. The type checker
is the gate.**

That's the whole talk on one slide. The other 80 lines make it honest.

---

## The seven landmarks (reading order = demo order)

| # | Where | What it is |
|---|-------|------------|
| 1 | [`baseApply`](LeanGate.lean#L18) | The substrate — a 3-line apply rule. `"+"` sums; `"id" [n]` is the β-redex `(λx.x) n`. |
| 2 | [`CE`](LeanGate.lean#L24) | The evidence predicate: "every baseline success is preserved." One line. ([`CE_refl`](LeanGate.lean#L27) / [`CE_trans`](LeanGate.lean#L28) make it a preorder.) |
| 3 | [`Approval`](LeanGate.lean#L33) | **The gate.** The `proof` field is the kernel admission point. |
| 4 | [`multnApproval`](LeanGate.lean#L53) | The admit — [`multnApply`](LeanGate.lean#L43) extends the baseline, [`multn_CE`](LeanGate.lean#L46) proves it's CE, the approval bundles them. |
| 5 | [`malicious_not_CE`](LeanGate.lean#L72) | The refuse — [`malicious`](LeanGate.lean#L69) would map `(id 3) ⇒ 42`; *no* `Approval baseApply` for it can exist. |
| 6 | [`gated_preserves_beta`](LeanGate.lean#L60) | Wand 1998 defeated *for free*: for **any** approved rule, `(id n) ⇒ n` — a one-line corollary of the `CE` field. |
| 7 | [`Approval.compose`](LeanGate.lean#L37) | Admissions chain: `CE_trans` of the two proofs. The guarantee is transitive. |

---

## Demo-script skeleton

Each beat = what's on screen / what you do / the point it lands. Times are
a sketch for a ~6-minute slot.

**Beat 1 — the substrate (0:30).**
On screen: [`baseApply`](LeanGate.lean#L18).
Point: the system we're going to let modify itself is *just this
function*. `"id"` is secretly the β-redex — remember it.

**Beat 2 — what a change must prove (0:45).**
On screen: [`CE`](LeanGate.lean#L24).
Point: a modification is "reasonable" iff it preserves every baseline
answer. That's the only contract.

**Beat 3 — the gate (1:00).** ← the slide everyone remembers
On screen: [`Approval`](LeanGate.lean#L33), highlight the `proof` field.
Point: the certificate carries its own proof. The kernel builds the term
or it doesn't. No runtime checks, no enforcement code — propositions-as-types
*is* the gate.

**Beat 4 — admit (1:00).**
On screen: [`multnApproval`](LeanGate.lean#L53); then run
[Scene 2](Smoke.lean#L17) (`lake exe smoke`).
Output: `(+ 1 2)` preserved, `(* 2 3 4) ⇒ 24` admitted.
Point: a real extension goes through — *because* it carried a proof.

**Beat 5 — refuse (1:30).** ← the Wand beat
*(Optional live moment, highest impact:)* type
`def bad : Approval baseApply := ⟨malicious, ?_⟩` and let the proof
obligation fail to close — the kernel won't build it.
On screen: [`malicious`](LeanGate.lean#L69) +
[`malicious_not_CE`](LeanGate.lean#L72); then run
[Scene 4](Smoke.lean#L29).
Output: ungated, `(id 3) ⇒ 42` — β has collapsed (this is Wand 1998).
Gated, no `Approval` exists, so it never runs.
Then reveal [`gated_preserves_beta`](LeanGate.lean#L60): for *any* approved
rule, `(id n) ⇒ n`, in one line. β-equivalence survives every admission,
as a corollary of `CE`.

**Beat 6 — compose (0:45).**
On screen: [`Approval.compose`](LeanGate.lean#L37); run
[Scene 3](Smoke.lean#L23).
Point: chain admissions and the guarantee is transitive — `CE_trans` of
the two proofs. The global property is preserved across the sequence.

**Beat 7 — bridge to the real thing (0:30).**
Point (verbal, no code): everything here is the gate *in isolation* —
nothing mutated, no level shift. Now let that apply rule be modified
**from inside a running tower**, via `set!` through a reflective shift —
that's lean-sage, and the certificate it demands is exactly this
`Approval`. (See [lean-sage](https://github.com/namin/lean-sage) and its
`WALKTHROUGH.md`.)

---

## Honest framing (don't get caught out)

- **lean-gate is deliberately *not* reflective** — no tower, no `set!`, no
  causal connection. It's the gate lifted out of the reflective tower. The
  README says so up front. Beat 7 is where you own that.
- **The example here is `(* 2 3 4) ⇒ 24`** (adding a `*` operator), not the
  abstract's `(2 3 4) ⇒ 24` (a number applied as a function). If the live
  demo is lean-gate, realign `multnApply` to the number-as-function form
  so the demo and the abstract tell the same story.
- Every theorem is kernel-checked; `lake exe smoke` prints only `OK`
  lines. Nothing here is staged.
