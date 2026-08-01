-- AXIOM MINIMIZATION TEST: Can we eliminate hidden assumptions?

namespace MinimalAxiomTest

-- Test 1: Without deriving DecidableEq
inductive F4_minimal | z | o | a | b

-- Can we still define operations without DecidableEq?
def add_minimal : F4_minimal → F4_minimal → F4_minimal
  | z, y => y      | y, z => y
  | o, o => z      | o, a => b      | o, b => a
  | a, o => b      | a, a => z      | a, b => o
  | b, o => a      | b, a => o      | b, b => z

-- Can we prove basic things without axioms?
theorem zero_identity_left (x : F4_minimal) : add_minimal z x = x := by
  cases x <;> rfl

-- Does this compile without "deriving DecidableEq"?
example (x y : F4_minimal) : x = y ∨ x ≠ y := by
  -- This would require excluded middle!
  sorry

end MinimalAxiomTest
