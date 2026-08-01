-- Test: Can we compile without classical axioms?

-- Try without importing classical logic
-- import Mathlib.Tactic (commented out)

namespace ConstructiveGapTest

-- Try a simple constructive proof
def simple_constructive_statement : Prop :=
  ∃ x : Nat, x = 0

theorem constructive_proof : simple_constructive_statement := by
  use 0
  rfl

-- Try without excluded middle
example (P : Prop) : (P → False) → ¬P := by
  intro hnp hp
  exact hnp hp

-- This should work constructively
example (n : Nat) : n = n := by
  rfl

end ConstructiveGapTest
