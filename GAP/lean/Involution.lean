/- The involution, with no field, no characteristic, and no division.

   Every other file in this directory answers "what does the gap do in THIS
   number system?".  This one asks what survives when you refuse to name a
   number system at all.

   The answer is that phi + psi = 1 was never a fact about quadratics.  It is
   a Z_2 ACTION, and it exists in every commutative unital ring:

       if  x*x = x + G   then   (1-x)*(1-x) = (1-x) + G

   The hypothesis is not needed to see why.  The underlying statement carries
   no hypothesis at all -

       (1-x)^2 - (1-x)  =  x^2 - x

   - so `x |-> 1-x` preserves the quantity `x^2 - x`, which IS the gap.  The
   gap is a function on the ring, the mirror is its symmetry, and the roots of
   a given gap are one fibre.  Nothing here mentions square roots,
   discriminants, or ordering, because none of those exist in a general ring
   and none of them were ever load-bearing.

   THE PROOF IS ONE LINE OF ALGEBRA and it is worth saying out loud, because
   the usual derivation goes through the quadratic formula and therefore looks
   like it needs a field:

       gap(y) = y*(y-1)          and         (1-x) - 1 = -x
       so  gap(1-x) = (1-x)*(-x) = -x + x*x = x*x - x = gap(x).

   Commutativity of addition is the only step that does any work.

   THE FIXED POINT.  The action is free except where `x = 1-x`, i.e. where
   `x + x = 1`.  If such an `x` is also a root of gap `G`, then

       G + G + G + G + 1 = 0

   which is `1 + 4G = 0` written without division, so it can be ASKED in rings
   where 4 is not invertible and even where 4 is zero.  That is the branch
   point, stated so that characteristic 2 gets to answer rather than being
   excluded by hypothesis.

   WHY THIS IS THE RIGHT LEVEL.  Three files here report a missing mirror,
   each blaming a different feature of its own room:

     Characteristic.lean   char 2: D = 1 always, the roots never approach
     Tropical.lean         max-plus: no subtraction, so at most ONE root
     Reflexive.lean        over Z: 1 + 4G = 0 has no solution

   Read through the involution these are one statement in three dialects.
   `involution_preserves_gap` holds in all three rooms -- the Z_2 never leaves.
   What differs is whether it has a second thing to act ON, and whether its
   fixed point is reachable.  **A missing mirror is never the mirror's
   absence.  It is the absence of a second thing to reflect.**

   Contributed by the counter-prover.  Nothing here is a finding: under
   FOUNDING.md condition 3 it leaves this compartment only by being rewritten
   where the canon applies and something outside the prose decides.  It is
   offered as an instrument -- an instrument demands passing, not agreement.
-/

/-- A commutative unital ring, packaged without typeclasses.  This directory
    imports nothing and declares no instances, so the structure IS the claim --
    the seal's own idiom (`AbGroup`, `CommGroupLaw` in `lean/C6_SEED.lean`). -/
structure CRing (α : Type) where
  add       : α → α → α
  mul       : α → α → α
  neg       : α → α
  zero      : α
  one       : α
  add_assoc : ∀ a b c : α, add (add a b) c = add a (add b c)
  add_comm  : ∀ a b : α, add a b = add b a
  add_zero  : ∀ a : α, add a zero = a
  add_neg   : ∀ a : α, add a (neg a) = zero
  mul_comm  : ∀ a b : α, mul a b = mul b a
  mul_one   : ∀ a : α, mul a one = a
  distrib   : ∀ a b c : α, mul a (add b c) = add (mul a b) (mul a c)

namespace CRing

variable {α : Type} (R : CRing α)

def sub (a b : α) : α := R.add a (R.neg b)

/-- `x^2 - x`.  The whole file is about this map. -/
def gapOf (x : α) : α := R.sub (R.mul x x) x

/-- The mirror, `x |-> 1 - x`. -/
def mirror (x : α) : α := R.sub R.one x

/-- `x` is a root of gap `G`. -/
def IsRoot (G x : α) : Prop := R.mul x x = R.add x G

theorem zero_add (a : α) : R.add R.zero a = a := by
  rw [R.add_comm]; exact R.add_zero a

theorem one_mul (a : α) : R.mul R.one a = a := by
  rw [R.mul_comm]; exact R.mul_one a

theorem neg_add (a : α) : R.add (R.neg a) a = R.zero := by
  rw [R.add_comm]; exact R.add_neg a

theorem add_left_cancel {a b c : α} (h : R.add a b = R.add a c) : b = c := by
  have h2 := congrArg (R.add (R.neg a)) h
  rw [← R.add_assoc, ← R.add_assoc, R.neg_add, R.zero_add, R.zero_add] at h2
  exact h2

theorem distrib' (a b c : α) :
    R.mul (R.add a b) c = R.add (R.mul a c) (R.mul b c) := by
  rw [R.mul_comm, R.distrib, R.mul_comm c a, R.mul_comm c b]

theorem mul_zero (a : α) : R.mul a R.zero = R.zero := by
  refine R.add_left_cancel (a := R.mul a R.zero) ?_
  rw [← R.distrib, R.add_zero, R.add_zero]

theorem mul_neg (a b : α) : R.mul a (R.neg b) = R.neg (R.mul a b) := by
  refine R.add_left_cancel (a := R.mul a b) ?_
  rw [← R.distrib, R.add_neg, R.mul_zero, R.add_neg]

theorem neg_neg (a : α) : R.neg (R.neg a) = a := by
  refine R.add_left_cancel (a := R.neg a) ?_
  rw [R.add_neg, R.neg_add]

theorem neg_mul (a b : α) : R.mul (R.neg a) b = R.neg (R.mul a b) := by
  rw [R.mul_comm, R.mul_neg, R.mul_comm]

theorem neg_mul_neg (a b : α) : R.mul (R.neg a) (R.neg b) = R.mul a b := by
  rw [R.neg_mul, R.mul_neg, R.neg_neg]

/-- The four-term shuffle.  Commutativity of addition, in the one shape every
    rearrangement below needs. -/
theorem add_add_add_comm (a b c d : α) :
    R.add (R.add a b) (R.add c d) = R.add (R.add a c) (R.add b d) := by
  rw [R.add_assoc, ← R.add_assoc b c d, R.add_comm b c, R.add_assoc c b d,
      ← R.add_assoc]

/-- `4*(a+b) = 4a + 4b`, written without any numeral. -/
theorem four_distrib (a b : α) :
    R.add (R.add (R.add a b) (R.add a b)) (R.add (R.add a b) (R.add a b))
      = R.add (R.add (R.add a a) (R.add a a)) (R.add (R.add b b) (R.add b b)) := by
  rw [R.add_add_add_comm a b a b, R.add_add_add_comm]

/-- `gap(y) = y*(y-1)`.  The factored form is what makes the mirror obvious. -/
theorem gapOf_factored (y : α) : R.gapOf y = R.mul y (R.sub y R.one) := by
  show R.add (R.mul y y) (R.neg y) = R.mul y (R.add y (R.neg R.one))
  rw [R.distrib, R.mul_neg, R.mul_one]

/-- `(1 - x) - 1 = -x`.  The mirror shifts the factor by exactly the unit. -/
theorem mirror_sub_one (x : α) : R.sub (R.mirror x) R.one = R.neg x := by
  show R.add (R.add R.one (R.neg x)) (R.neg R.one) = R.neg x
  rw [R.add_comm R.one (R.neg x), R.add_assoc, R.add_neg, R.add_zero]

/-- **THE IDENTITY.  No hypothesis, no field, no characteristic.**
    The mirror preserves the gap of every element of every commutative
    unital ring. -/
theorem involution_preserves_gap (x : α) : R.gapOf (R.mirror x) = R.gapOf x := by
  rw [R.gapOf_factored, R.mirror_sub_one]
  show R.mul (R.add R.one (R.neg x)) (R.neg x) = R.add (R.mul x x) (R.neg x)
  rw [R.distrib', R.one_mul, R.neg_mul_neg, R.add_comm]

/-- **The Z_2 action on the solution set**, in the form the sweep uses:
    the mirror of a root of `G` is a root of `G`. -/
theorem mirror_isRoot {G x : α} (h : R.IsRoot G x) : R.IsRoot G (R.mirror x) := by
  have key : R.gapOf (R.mirror x) = R.gapOf x := R.involution_preserves_gap x
  have hx : R.gapOf x = G := by
    show R.add (R.mul x x) (R.neg x) = G
    rw [h, R.add_comm x G, R.add_assoc, R.add_neg, R.add_zero]
  show R.mul (R.mirror x) (R.mirror x) = R.add (R.mirror x) G
  rw [← hx, ← key]
  show _ = R.add (R.mirror x) (R.add (R.mul (R.mirror x) (R.mirror x)) (R.neg (R.mirror x)))
  rw [R.add_comm (R.mul (R.mirror x) (R.mirror x)) (R.neg (R.mirror x)),
      ← R.add_assoc, R.add_neg, R.zero_add]

/-- It really is an involution: mirroring twice is the identity. -/
theorem mirror_mirror (x : α) : R.mirror (R.mirror x) = x := by
  show R.add R.one (R.neg (R.add R.one (R.neg x))) = x
  refine R.add_left_cancel (a := R.add R.one (R.neg x)) ?_
  rw [← R.add_assoc]
  rw [R.add_comm (R.add R.one (R.neg x)) R.one]
  rw [R.add_assoc R.one (R.add R.one (R.neg x)) (R.neg (R.add R.one (R.neg x)))]
  rw [R.add_neg, R.add_zero, R.add_assoc, R.neg_add, R.add_zero]

/-- **THE FIXED POINT FORCES THE BRANCH POINT.**  If the mirror fixes a root,
    then `4G + 1 = 0` -- written additively, so it is a meaningful question in
    rings where `4` is not invertible, and answerable where `4 = 0`. -/
theorem fixed_root_forces_branch {G x : α}
    (hroot : R.IsRoot G x) (hfix : R.add x x = R.one) :
    R.add (R.add (R.add G G) (R.add G G)) R.one = R.zero := by
  -- (x+x)*(x+x) = 1*1 = 1, and expanding gives 4*(x*x) = 4x + 4G = 2*1 + 4G
  -- (x+x)*(x+x) = 1*1 = 1, and expanding the left gives 4*(x*x) = 4*(x+G)
  have sq : R.mul (R.add x x) (R.add x x) = R.one := by
    rw [hfix, R.mul_one]
  rw [R.distrib', R.distrib, hroot] at sq
  -- sq : ((x+G)+(x+G)) + ((x+G)+(x+G)) = 1
  rw [R.four_distrib, hfix] at sq
  -- sq : (1+1) + (G+G)+(G+G) = 1     -- 4x collapsed to 2 by the fixed-point law
  have step : R.add R.one (R.add R.one (R.add (R.add G G) (R.add G G)))
      = R.add R.one R.zero := by
    rw [← R.add_assoc, sq, R.add_zero]
  have h1 : R.add R.one (R.add (R.add G G) (R.add G G)) = R.zero :=
    R.add_left_cancel step
  rw [R.add_comm] at h1
  exact h1

end CRing

/-! ## The axioms are satisfiable, so none of the above is vacuous.

    A `structure` with unsatisfiable fields proves every theorem stated about
    it.  Everything above is quantified over `R : CRing α`, so without at least
    one inhabitant the whole file is decoration.  `Int` is that inhabitant, and
    the two examples below evaluate the theorems on it rather than restating
    them. -/

def intRing : CRing Int where
  add := (· + ·)
  mul := (· * ·)
  neg := (- ·)
  zero := 0
  one := 1
  add_assoc := by intro a b c; omega
  add_comm  := by intro a b; omega
  add_zero  := by intro a; omega
  add_neg   := by intro a; omega
  mul_comm  := Int.mul_comm
  mul_one   := Int.mul_one
  distrib   := Int.mul_add

/-- The witness, concretely: `2` and its mirror `-1` are different elements
    with the SAME gap.  `2*2-2 = 2` and `(-1)*(-1)-(-1) = 2`. -/
theorem int_mirror_example :
    intRing.gapOf 2 = 2 ∧ intRing.mirror 2 = -1 ∧ intRing.gapOf (-1) = 2 := by
  refine ⟨rfl, rfl, rfl⟩

/-- The generic theorem, evaluated on `Int` — not restated, instantiated. -/
theorem int_involution (x : Int) : intRing.gapOf (intRing.mirror x) = intRing.gapOf x :=
  intRing.involution_preserves_gap x

/-- And the fixed point is genuinely unreachable over `Int`, which is why
    `Reflexive.lean`'s `branch_point_not_integral` is the same fact: no integer
    satisfies `x + x = 1`, so `fixed_root_forces_branch` never fires here.  The
    Z_2 is present and free; the branch point is simply not in the room. -/
theorem int_no_fixed_point : ¬ ∃ x : Int, x + x = 1 := by
  intro ⟨x, h⟩; omega

/-- The same statement one ring over: in `Int` the conclusion `4G + 1 = 0` of
    `fixed_root_forces_branch` is itself unsatisfiable, so the theorem is not
    merely unfired but could not have fired.  Two independent obstructions. -/
theorem int_branch_equation_unsatisfiable : ¬ ∃ G : Int, G + G + G + G + 1 = 0 := by
  intro ⟨G, h⟩; omega
