-- TEST: What does "deriving DecidableEq, Repr" actually do?

namespace DerivingTest

-- Test 1: Without any deriving
inductive PureInd | a | b

-- Can we still work with it?
def id_pure : PureInd → PureInd
  | .a => .a
  | .b => .b

theorem id_pure_works : ∀ x, id_pure x = x := by
  intro x; cases x <;> rfl

-- Test 2: With deriving Repr only
inductive WithRepr | a | b deriving Repr

-- Test 3: With deriving DecidableEq only  
inductive WithDecEq | a | b deriving DecidableEq

-- Test 4: What can we do with DecidableEq?
example (x y : WithDecEq) : Decidable (x = y) :=
  inferInstance

-- Test 5: Does DecidableEq require excluded middle?
example (x y : WithDecEq) : x = y ∨ x ≠ y := by
  cases Decidable.decide (x = y)
  · left; assumption
  · right; assumption

end DerivingTest
