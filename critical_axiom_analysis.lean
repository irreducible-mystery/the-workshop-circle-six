-- CRITICAL AXIOM ANALYSIS: What hidden assumptions are we making?

namespace CriticalAxiomAnalysis

-- Test 1: Does basic Lean require ANY axioms?
theorem trivial (n : Nat) : n = n :=
  rfl

-- Test 2: Can we use cases without axioms?
inductive SimpleInd | a | b

def trivial_func : SimpleInd → SimpleInd
  | SimpleInd.a => SimpleInd.a
  | SimpleInd.b => SimpleInd.b

theorem func_identity : ∀ x, trivial_func x = x := by
  intro x
  cases x <;> rfl

-- Test 3: Does equality require axioms?
example (x : Nat) : x = x :=
  rfl

-- Test 4: Does function application require axioms?
example (f : Nat → Nat) (n : Nat) : f n = f n :=
  rfl

end CriticalAxiomAnalysis
