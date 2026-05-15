import Lake
open Lake DSL

package «lean-gate» where
  leanOptions := #[⟨`autoImplicit, false⟩]

@[default_target]
lean_lib «LeanGate» where
  srcDir := "."

lean_exe «smoke» where
  root := `Smoke
