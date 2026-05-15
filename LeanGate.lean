/-!
# lean-gate

The kernel-typed-evidence pattern that every reasonable-reflection
artifact instantiates. A baseline behavior, a `CE` predicate, and an
`Approval` struct whose constructor type-checks a proof — the gate.

Wand 1998's β-collapse appears as the worked counter-example: the gate
refuses any modification that would break `(id n) = n`. Read top to
bottom.
-/

namespace Gate

abbrev ApplyRule := String → List Nat → Option Nat

/-- Baseline: `"+"` sums; `"id" [n]` is the β-redex `(λx. x) n`. -/
def baseApply : ApplyRule := fun op args =>
  if      op = "+"  then some (args.foldl (· + ·) 0)
  else if op = "id" then args.head?
  else none

/-- Conservative extension: every baseline success is preserved. -/
def CE (old new : ApplyRule) : Prop :=
  ∀ op args v, old op args = some v → new op args = some v

theorem CE_refl  (r : ApplyRule) : CE r r := fun _ _ _ h => h
theorem CE_trans {a b c : ApplyRule} (h₁ : CE a b) (h₂ : CE b c) : CE a c :=
  fun op args v hv => h₂ op args v (h₁ op args v hv)

/-- An `Approval` exists only when the kernel type-checks a CE proof.
The constructor *is* the gate. -/
structure Approval (baseline : ApplyRule) where
  rule  : ApplyRule
  proof : CE baseline rule

def Approval.compose {b : ApplyRule}
    (f : Approval b) (s : Approval f.rule) : Approval b :=
  ⟨s.rule, CE_trans f.proof s.proof⟩

/-! ### Worked admission: `multn` extends the baseline with `*` -/

def multnApply : ApplyRule := fun op args =>
  if op = "*" then some (args.foldl (· * ·) 1) else baseApply op args

theorem multn_CE : CE baseApply multnApply := by
  intro op args v h
  unfold multnApply
  by_cases hstar : op = "*"
  · subst hstar; simp [baseApply] at h
  · simp [hstar, h]

def multnApproval : Approval baseApply := ⟨multnApply, multn_CE⟩

/-! ### Wand 1998: β-equivalence is preserved under any admission

For every approved rule, `(id n) ⇒ n`. The β-redex equation survives
gated modification — *for free*, as a corollary of CE. -/

theorem gated_preserves_beta (a : Approval baseApply) (n : Nat) :
    a.rule "id" [n] = some n :=
  a.proof "id" [n] n rfl

/-! ### The malicious modification cannot be admitted

`malicious` would map `(id 3) ⇒ 42`, breaking β. No `Approval baseApply`
whose rule is `malicious` exists. -/

def malicious : ApplyRule := fun op args =>
  if op = "id" then some 42 else baseApply op args

theorem malicious_not_CE : ¬ CE baseApply malicious := by
  intro h
  have h₁ : malicious "id" [3] = some 3 := h "id" [3] 3 rfl
  simp [malicious] at h₁

/-! ### Runtime -/

def run (a : Approval baseApply) (op : String) (args : List Nat) :=
  a.rule op args

end Gate
