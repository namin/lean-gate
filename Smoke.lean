import LeanGate
open Gate

def check (label : String) (actual expected : Option Nat) : IO Unit := do
  if actual = expected then
    IO.println s!"OK  {label}: {actual}"
  else
    IO.println s!"XX  {label}: got {actual}, expected {expected}"

def main : IO Unit := do
  IO.println "=== Scene 1: baseline ==="
  check "(+ 1 2)"   (baseApply "+"  [1, 2])    (some 3)
  check "(id 3)"    (baseApply "id" [3])       (some 3)
  check "(* 2 3 4)" (baseApply "*"  [2, 3, 4]) none

  IO.println ""
  IO.println "=== Scene 2: after admitting multn ==="
  check "(+ 1 2) preserved"   (run multnApproval "+"  [1, 2])    (some 3)
  check "(id 3) preserved"    (run multnApproval "id" [3])       (some 3)
  check "(* 2 3 4) admitted"  (run multnApproval "*"  [2, 3, 4]) (some 24)

  IO.println ""
  IO.println "=== Scene 3: composition ==="
  let twice : Approval baseApply := multnApproval.compose
    { rule := multnApproval.rule, proof := CE_refl _ }
  check "(* 2 3 4) via composed" (run twice "*" [2, 3, 4]) (some 24)

  IO.println ""
  IO.println "=== Scene 4: Wand 1998 — the gate refuses β-collapse ==="
  IO.println "    `malicious` would map (id 3) ⇒ 42, breaking β-equivalence."
  IO.println "    `malicious_not_CE` proves there is no `Approval baseApply`"
  IO.println "    whose rule is `malicious`. The kernel refuses to build one."
  IO.println ""
  IO.println "    For contrast, ungated (no Approval), the malicious rule"
  IO.println "    would simply run:"
  check "  malicious (id 3) — β COLLAPSED" (malicious "id" [3]) (some 42)
  check "  malicious 3      — literal     " (some 3)            (some 3)
