# lean-gate

The kernel-typed-evidence pattern that every [reasonable-reflection](https://github.com/namin/reasonable-reflection) artifact instantiates, in ~80 lines (47 of code), every theorem kernel-checked. Wand 1998's β-collapse is the worked counter-example.

## What it is

This is *the gate*, abstracted away from the reflective tower it usually guards. The portfolio's bigger artifacts (lean-sage, climber, defeater, reviser) each instantiate this pattern over different substrates and different evidence-kinds; `lean-gate` is the pattern itself.

| Element                              | In `LeanGate.lean` |
|--------------------------------------|--------------------|
| Substrate (a function value)         | `ApplyRule`, `baseApply` (handles `"+"` and `"id"`) |
| The evidence predicate               | `CE`, `CE_refl`, `CE_trans` |
| The proof-bearing admission          | `Approval` — the constructor *is* the gate |
| Compositionality of admissions       | `Approval.compose` |
| Worked admission                     | `multnApply`, `multn_CE`, `multnApproval` |
| β preservation under any admission   | `gated_preserves_beta` |
| Wand 1998 — β cannot collapse        | `malicious`, `malicious_not_CE` |
| Runtime                              | `run` |

**The point.** The constructor for `Approval` requires a `CE` proof. The Lean kernel type-checks the proof or refuses to build the term. There is no separate enforcement code — *the type checker is the gate*. The portfolio's bigger artifacts (lean-sage's `ApprovedModification`, climber's axiom-schema certificates, reviser's AGM-postulate bundles) are all this same pattern with richer substrates and richer evidence predicates.

**The Wand defeat.** `baseApply "id"` returns its single argument — that's the β-redex `(λx. x) n`. `gated_preserves_beta` proves that under *any* `Approval baseApply`, `(id n) ⇒ n` — β survives gated modification as a one-line corollary of `CE`. The malicious rule that would map `(id 3) ⇒ 42` is refused by `malicious_not_CE`; ungated, the same rule simply runs and β collapses (Scene 4 demonstrates the collapse for contrast).

## What this is *not*

- Not reflective. Nothing mutates; there is no level shift, no causal connection, no tower. It's the *gate* from a reflective tower, not the tower itself.
- Not a worked instance of any specific reflective system. For that, see lean-sage / lean-emerald.

## Build & run

```bash
lake build       # type-check the library + executable
lake exe smoke   # four scenes; expect only `OK` lines
```

Toolchain: `leanprover/lean4:v4.29.1`.

## Where the pattern is instantiated

- [lean-sage](https://github.com/namin/lean-sage) `ApprovedModification` — the gate over `set! base-apply` in a multi-level reflective tower with a real heap.
- [lean-emerald](https://github.com/namin/lean-emerald) — sage's substrate rebuilt 5× smaller; same gate.
- [climber](https://github.com/namin/climber) — the gate over axiom-schema extensions (Beklemishev-shaped).
- [defeater](https://github.com/namin/defeater) — the gate over sound exception schemas.
- [reviser](https://github.com/namin/reviser) — the gate over AGM-rationality of belief-revision operators.

## Where the Wand defeat is mechanized in the substrate

- [lean-emerald](https://github.com/namin/lean-emerald) `wand_beta_gate_indep_keynote` — `evalProgram 10 ((λx. x) 0) G = evalProgram 10 0 G` for any `Gate G`.
- [lean-sage](https://github.com/namin/lean-sage) `wand_defeated_existential_gated_beta` — gated β-equivalence under `approvedPolicy approvals` for any approval list.
- [lean-green](https://github.com/namin/lean-green) `LeanBlack/Wand.lean` — value-level existential defeat in the real heap/closure substrate.
