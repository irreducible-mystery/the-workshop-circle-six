-- AXIOM ANALYSIS: Can we compile without hidden assumptions?

namespace AxiomTest

-- Test 1: Minimal constructive logic
theorem constructive_basic (n : Nat) : n = n :=
  rfl

-- Test 2: Existence without choice
example : ∃ x : Nat, x = 0 :=
  ⟨0, rfl⟩

-- Test 3: Without excluded middle
example (P Q : Prop) : (P ∧ Q) → P := by
  intro h
  exact h.left

-- Test 4: Negation constructively
example (P : Prop) : (P → False) → ¬P :=
  fun hnp hp => hnp hp

end AxiomTest
