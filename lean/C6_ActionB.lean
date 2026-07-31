/-
  C6_ActionB.lean — Circle Six, READING B: twist the pentagon itself.

  SELF-CONTAINED.  No imports (so: `Init` and nothing else — no Mathlib, no Std).
  Part I is copied verbatim from `lean/C6_SEED.lean`; Part II is copied from
  Circle Six's own `lean/C6_Core.lean` (the decidability bridge).  Duplication
  across files is deliberate: this file is checked by `lean C6_ActionB.lean`
  alone and cites nothing.

  DISCIPLINE.  No `sorry`, no `admit`, no `axiom`, no `native_decide`, no
  `@[implemented_by]`.  Every `decide` below is a kernel `decide`.  Every
  enumeration below is a kernel evaluation, and the file carries the axiom
  audit of every theorem at the foot.

  THE QUESTION.  The seed's pentagon composes three F-symbols on the left and
  two on the right.  In the language of group cohomology that is the 3-cocycle
  equation of the TRIVIAL action.  Reading B puts the non-trivial action back:
  the coefficient group is `Z[i]^x` and the index group `Z_2` acts on it by the
  Galois involution `conj`, which on units IS inversion.  The seed's own `d3`
  carries `act a` on its leading face `f b c d`; Reading B mirrors that inside
  the pentagon.  There are FIVE F-factors and therefore five places to put the
  sigma; this file tries all thirty-two subsets and reports every one.
-/

-- Resource ceiling, not a proof concession.  The 32-placement sweep and the
-- solution-set enumerations are large kernel computations; `whnf` exhausts the
-- default 200000 heartbeats on them.  `C6_ActionA.lean` sets the same option on
-- its 65536-symbol sweep for the same reason.  This raises no trust assumption:
-- `decide` and `rfl` still run in the kernel and `native_decide` appears nowhere.
set_option maxHeartbeats 0
set_option maxRecDepth 10000

/-! ############################################################################
    PART I — the seed's definitions, verbatim from `C6_SEED.lean`.
    ############################################################################ -/

/-- A Gaussian integer as an ordered pair of integers: `⟨a, b⟩` is `a + bi`.
    Two coordinates, not four — Z[i] is Z5's little sibling. -/
structure GZ where
  re : Int
  im : Int

def zero : GZ := ⟨0, 0⟩

def one : GZ := ⟨1, 0⟩

/-- `i` itself: the pair `(0, 1)`. -/
def I : GZ := ⟨0, 1⟩

def add (z w : GZ) : GZ := ⟨z.re + w.re, z.im + w.im⟩

def neg (z : GZ) : GZ := ⟨-z.re, -z.im⟩

def sub (z w : GZ) : GZ := add z (neg w)

/-- Multiplication forced by `i² = -1` and distributivity, nothing else. -/
def mul (z w : GZ) : GZ := ⟨z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re⟩

/-- Conjugation: the sigma of Circle Two. Fixes the first coordinate. -/
def conj (z : GZ) : GZ := ⟨z.re, -z.im⟩

/-- The norm `N(a + bi) = a² + b²`, an integer, not a Gaussian integer. -/
def norm (z : GZ) : Int := z.re * z.re + z.im * z.im

/-- The Z₂ F-symbol, valued in Z[i]: `zero` off the admissible locus, `f`
    at the single slot `(1,1,1)`, `one` everywhere else. Admissibility is
    the bench's: `x = (a+b)%2`, `y = (b+c)%2`, `d = (a+b+c)%2`. -/
def Fs (f : GZ) (a b c d x y : Int) : GZ :=
  if x = (a + b) % 2 ∧ y = (b + c) % 2 ∧ d = (a + b + c) % 2 then
    (if a = 1 ∧ b = 1 ∧ c = 1 then f else one)
  else zero

/-- The pentagon's left side: three F-symbols, exactly as `pent_residual_z2`
    composes them. -/
def pentLhs (f : GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2; let u := (b + c) % 2
  mul (mul (Fs f a b c y x u) (Fs f a u d t y v)) (Fs f b c d v u w)

/-- The pentagon's right side: two F-symbols. -/
def pentRhs (f : GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2
  mul (Fs f x c d t y w) (Fs f a b w t x v)

/-- The pentagon, as a proposition about `f`: it holds at every label
    assignment drawn from `{0,1}`. The label hypotheses are explicit
    disjunctions rather than a subtype, so the case analysis below is the
    nest itself and nothing is hidden in a coercion. -/
def pentagonHolds (f : GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → pentLhs f a b c d = pentRhs f a b c d

/-- A unit is an element with a multiplicative partner. -/
def IsUnit (u : GZ) : Prop := ∃ v, mul u v = one

/-- The slice family's core: the value the three free labels carry. -/
def sliceCore (f : GZ) (a b c : Int) : GZ :=
  if a = 1 ∧ b = 1 ∧ c = 1 then f else one

/-- A GENERAL F-symbol in the bench's language: the three free labels carry
    the value, and it vanishes off the admissible locus — the same shape
    `Fs` has, because `Fs` is one of these. -/
def Fgen (F : Int → Int → Int → GZ) (a b c d x y : Int) : GZ :=
  if x = (a + b) % 2 ∧ y = (b + c) % 2 ∧ d = (a + b + c) % 2 then F a b c else zero

/-- The pentagon's left side for a general symbol — the bench's own
    composition, with `Fgen F` in every slot `pentLhs` puts `Fs f`. -/
def genPentLhs (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2; let u := (b + c) % 2
  mul (mul (Fgen F a b c y x u) (Fgen F a u d t y v)) (Fgen F b c d v u w)

/-- The pentagon's right side for a general symbol. -/
def genPentRhs (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2
  mul (Fgen F x c d t y w) (Fgen F a b w t x v)

/-- The pentagon for a general symbol, at every label assignment drawn from
    `{0,1}` — the same quantifier shape `pentagonHolds` uses. -/
def genPentagonHolds (F : Int → Int → Int → GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → genPentLhs F a b c d = genPentRhs F a b c d

/-- A pentagon-satisfying unit-valued symbol that is NOT in the slice: the
    boson twisted by a gauge with `g(0,1) = i`. The first label is written
    `_a` because the twist genuinely does not depend on it — a fact the
    linter noticed before the author did. -/
def twistedBoson (_a b c : Int) : GZ :=
  if c = 1 then (if b = 1 then I else neg I) else one

/-- A unit-valued symbol that does NOT satisfy the pentagon. -/
def fakeCocycle (a b c : Int) : GZ :=
  if a = 0 ∧ b = 0 ∧ c = 1 then I else one

/-- The bridge from the index group to the seal's integer labels. -/
def lab : Bool → Int := fun b => if b then 1 else 0

/-- The `d^2` coboundary written in the seal's own label arithmetic, so it
    can be compared with `gaugePhi` without any translation layer. -/
def d2raw (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (g b c) (conj (g ((a + b) % 2) c))) (mul (g a ((b + c) % 2)) (conj (g a b)))

/-- The label decoder: `Int` to `Bool`, inverse to `lab` on the labels. -/
def boolOf (i : Int) : Bool := if i = 1 then true else false

/-! ############################################################################
    PART II — the decidability bridge, copied from Circle Six's `C6_Core.lean`.

    Nothing here is new; it is reproduced so that this file stands alone.
    ############################################################################ -/

theorem GZ.eq_of {z w : GZ} (hr : z.re = w.re) (hi : z.im = w.im) : z = w := by
  cases z; cases w; cases hr; cases hi; rfl

instance instDecidableEqGZ : DecidableEq GZ := fun z w =>
  if hr : z.re = w.re then
    if hi : z.im = w.im then isTrue (GZ.eq_of hr hi)
    else isFalse (fun h => hi (congrArg GZ.im h))
  else isFalse (fun h => hr (congrArg GZ.re h))

theorem band_left {a b : Bool} (h : (a && b) = true) : a = true := by
  cases a with
  | false => exact Bool.noConfusion h
  | true  => rfl

theorem band_right {a b : Bool} (h : (a && b) = true) : b = true := by
  cases a with
  | false => exact Bool.noConfusion h
  | true  => exact h

/-- The two-point conjunction. -/
def allBool (p : Bool → Bool) : Bool := p false && p true

theorem allBool_sound {p : Bool → Bool} (h : allBool p = true) : ∀ b : Bool, p b = true
  | false => band_left h
  | true  => band_right h

theorem allBool_complete {p : Bool → Bool} (h : ∀ b : Bool, p b = true) : allBool p = true := by
  show (p false && p true) = true
  rw [h false, h true]
  rfl

/-- Congruence for the two-point quantifier: used to slide a whole nest of
    them from one presentation of the equation to another. -/
theorem allBool_congr {p q : Bool → Bool} (h : ∀ b : Bool, p b = q b) : allBool p = allBool q := by
  show (p false && p true) = (q false && q true)
  rw [h false, h true]

theorem lab_isLabel (A : Bool) : lab A = 0 ∨ lab A = 1 := by
  cases A with
  | false => exact Or.inl rfl
  | true  => exact Or.inr rfl

theorem exists_bool_of_isLabel {a : Int} (h : a = 0 ∨ a = 1) : ∃ A : Bool, a = lab A := by
  cases h with
  | inl h => exact ⟨false, by rw [h]; rfl⟩
  | inr h => exact ⟨true, by rw [h]; rfl⟩

/-! ############################################################################
    PART III — Circle Six's Reading B: sigma inside the pentagon.
    ############################################################################ -/

/-- **The Galois action, in the seed's own integer labels.**  `sig a z` is
    `sigma^a (z)`: the identity at the label `0`, the seed's `conj` at the
    label `1`.  On units `conj` is inversion, which is exactly the inverse the
    seed's `d3` uses; so this is the action, written multiplicatively. -/
def sig (a : Int) (z : GZ) : GZ := if a = 1 then conj z else z

/-- The action, switched on or off by a placement flag.  `sigM false` is the
    identity **definitionally**, so the untwisted pentagon is literally the
    all-`false` member of the family below and not a lookalike. -/
def sigM : Bool → Int → GZ → GZ
  | false, _, z => z
  | true,  a, z => sig a z

/-- **The pentagon's left side with sigma inserted at a chosen subset of its
    three factors.**  Everything except the `sigM` wrappers is the seed's
    `pentLhs`, character for character. -/
def pentLhsM (m1 m2 m3 : Bool) (f : GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2; let u := (b + c) % 2
  mul (mul (sigM m1 a (Fs f a b c y x u)) (sigM m2 a (Fs f a u d t y v)))
      (sigM m3 a (Fs f b c d v u w))

/-- **The pentagon's right side with sigma inserted at a chosen subset of its
    two factors.**  The charge names three F factors; the pentagon has five,
    and a placement that only ever touched the left would be a choice made
    silently.  So the right is parametrised too. -/
def pentRhsM (n1 n2 : Bool) (f : GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2
  mul (sigM n1 a (Fs f x c d t y w)) (sigM n2 a (Fs f a b w t x v))

/-- The sigma-pentagon at a placement, as a proposition about `f`. -/
def pentagonHoldsM (m1 m2 m3 n1 n2 : Bool) (f : GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → pentLhsM m1 m2 m3 f a b c d = pentRhsM n1 n2 f a b c d

/-- **THE READING-B LEFT SIDE**, written out rather than instantiated: the
    seed's `pentLhs` with `sig a` on the factor `Fs f b c d v u w`.  That is
    the factor whose free labels are `(b, c, d)` — the one from which the
    outermost label `a` has been dropped — and it is therefore the mirror of
    the leading face `f b c d` that the seed's `d3` hits with `act a`. -/
def pentLhsSig (f : GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2; let u := (b + c) % 2
  mul (mul (Fs f a b c y x u) (Fs f a u d t y v)) (sig a (Fs f b c d v u w))

/-- **THE READING-B RIGHT SIDE.**  Sigma does not enter here: in `d3` the
    action multiplies exactly one face, and moving it to the right as well
    would be a different placement — one this file also tries, and reports,
    under the mask `(n1, n2)`. -/
def pentRhsSig (f : GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2
  mul (Fs f x c d t y w) (Fs f a b w t x v)

/-- **THE SIGMA-PENTAGON.** -/
def pentagonHoldsSig (f : GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → pentLhsSig f a b c d = pentRhsSig f a b c d

/-- The named Reading-B definitions ARE the mask `(false,false,true | false,false)`
    — definitionally, so no theorem below has to choose between them. -/
theorem pentLhsSig_eq : pentLhsSig = pentLhsM false false true := rfl
theorem pentRhsSig_eq : pentRhsSig = pentRhsM false false := rfl
theorem pentagonHoldsSig_eq : pentagonHoldsSig = pentagonHoldsM false false true false false := rfl

/-- …and the seed's own pentagon is the all-`false` mask, definitionally.  This
    is what makes the comparison below a comparison and not an analogy. -/
theorem pentLhsM_untwisted : pentLhsM false false false = pentLhs := rfl
theorem pentRhsM_untwisted : pentRhsM false false = pentRhs := rfl
theorem pentagonHoldsM_untwisted :
    pentagonHoldsM false false false false false = pentagonHolds := rfl

/-- The right-hand side of Reading B is the seed's, untouched. -/
theorem pentRhsSig_eq_pentRhs : pentRhsSig = pentRhs := rfl

/-! ### The same, for a general (not necessarily slice) symbol. -/

def genPentLhsM (m1 m2 m3 : Bool) (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2; let u := (b + c) % 2
  mul (mul (sigM m1 a (Fgen F a b c y x u)) (sigM m2 a (Fgen F a u d t y v)))
      (sigM m3 a (Fgen F b c d v u w))

def genPentRhsM (n1 n2 : Bool) (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2
  mul (sigM n1 a (Fgen F x c d t y w)) (sigM n2 a (Fgen F a b w t x v))

def genPentagonHoldsM (m1 m2 m3 n1 n2 : Bool) (F : Int → Int → Int → GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → genPentLhsM m1 m2 m3 F a b c d = genPentRhsM n1 n2 F a b c d

def genPentLhsSig (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2; let u := (b + c) % 2
  mul (mul (Fgen F a b c y x u) (Fgen F a u d t y v)) (sig a (Fgen F b c d v u w))

def genPentRhsSig (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2
  mul (Fgen F x c d t y w) (Fgen F a b w t x v)

def genPentagonHoldsSig (F : Int → Int → Int → GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → genPentLhsSig F a b c d = genPentRhsSig F a b c d

theorem genPentLhsSig_eq : genPentLhsSig = genPentLhsM false false true := rfl
theorem genPentRhsSig_eq : genPentRhsSig = genPentRhsM false false := rfl
theorem genPentagonHoldsSig_eq :
    genPentagonHoldsSig = genPentagonHoldsM false false true false false := rfl
theorem genPentLhsM_untwisted : genPentLhsM false false false = genPentLhs := rfl
theorem genPentRhsM_untwisted : genPentRhsM false false = genPentRhs := rfl
theorem genPentagonHoldsM_untwisted :
    genPentagonHoldsM false false false false false = genPentagonHolds := rfl

/-! ############################################################################
    PART IV — the decision procedures, one per placement.
    ############################################################################ -/

def pentMAt (m1 m2 m3 n1 n2 : Bool) (f : GZ) (a b c d : Bool) : Bool :=
  decide (pentLhsM m1 m2 m3 f (lab a) (lab b) (lab c) (lab d)
        = pentRhsM n1 n2 f (lab a) (lab b) (lab c) (lab d))

/-- **The decision procedure for `pentagonHoldsM`.**  Sixteen equations in
    `Z[i]`, folded into one `Bool` the kernel can evaluate. -/
def pentMOK (m1 m2 m3 n1 n2 : Bool) (f : GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d =>
    pentMAt m1 m2 m3 n1 n2 f a b c d

theorem pentMOK_sound {m1 m2 m3 n1 n2 : Bool} {f : GZ} (h : pentMOK m1 m2 m3 n1 n2 f = true) :
    pentagonHoldsM m1 m2 m3 n1 n2 f := by
  have key : ∀ A B C D : Bool,
      pentLhsM m1 m2 m3 f (lab A) (lab B) (lab C) (lab D)
        = pentRhsM n1 n2 f (lab A) (lab B) (lab C) (lab D) := fun A B C D =>
    of_decide_eq_true
      (allBool_sound (allBool_sound (allBool_sound (allBool_sound h A) B) C) D)
  intro a b c d ha hb hc hd
  cases exists_bool_of_isLabel ha with
  | intro A hA =>
    cases exists_bool_of_isLabel hb with
    | intro B hB =>
      cases exists_bool_of_isLabel hc with
      | intro C hC =>
        cases exists_bool_of_isLabel hd with
        | intro D hD =>
          subst hA; subst hB; subst hC; subst hD
          exact key A B C D

theorem pentMOK_complete {m1 m2 m3 n1 n2 : Bool} {f : GZ}
    (h : pentagonHoldsM m1 m2 m3 n1 n2 f) : pentMOK m1 m2 m3 n1 n2 f = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    allBool_complete fun D =>
      decide_eq_true
        (h (lab A) (lab B) (lab C) (lab D)
          (lab_isLabel A) (lab_isLabel B) (lab_isLabel C) (lab_isLabel D))

theorem pentMOK_iff (m1 m2 m3 n1 n2 : Bool) (f : GZ) :
    pentMOK m1 m2 m3 n1 n2 f = true ↔ pentagonHoldsM m1 m2 m3 n1 n2 f :=
  Iff.intro pentMOK_sound pentMOK_complete

theorem not_pentagonHoldsM_of_false {m1 m2 m3 n1 n2 : Bool} {f : GZ}
    (h : pentMOK m1 m2 m3 n1 n2 f = false) : ¬ pentagonHoldsM m1 m2 m3 n1 n2 f :=
  fun hp => Bool.noConfusion (h ▸ pentMOK_complete hp)

/-! ### The same for a general symbol. -/

def genPentMAt (m1 m2 m3 n1 n2 : Bool) (F : Int → Int → Int → GZ) (a b c d : Bool) : Bool :=
  decide (genPentLhsM m1 m2 m3 F (lab a) (lab b) (lab c) (lab d)
        = genPentRhsM n1 n2 F (lab a) (lab b) (lab c) (lab d))

def genPentMOKF (m1 m2 m3 n1 n2 : Bool) (F : Int → Int → Int → GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d =>
    genPentMAt m1 m2 m3 n1 n2 F a b c d

theorem genPentMOKF_sound {m1 m2 m3 n1 n2 : Bool} {F : Int → Int → Int → GZ}
    (h : genPentMOKF m1 m2 m3 n1 n2 F = true) : genPentagonHoldsM m1 m2 m3 n1 n2 F := by
  have key : ∀ A B C D : Bool,
      genPentLhsM m1 m2 m3 F (lab A) (lab B) (lab C) (lab D)
        = genPentRhsM n1 n2 F (lab A) (lab B) (lab C) (lab D) := fun A B C D =>
    of_decide_eq_true
      (allBool_sound (allBool_sound (allBool_sound (allBool_sound h A) B) C) D)
  intro a b c d ha hb hc hd
  cases exists_bool_of_isLabel ha with
  | intro A hA =>
    cases exists_bool_of_isLabel hb with
    | intro B hB =>
      cases exists_bool_of_isLabel hc with
      | intro C hC =>
        cases exists_bool_of_isLabel hd with
        | intro D hD =>
          subst hA; subst hB; subst hC; subst hD
          exact key A B C D

theorem genPentMOKF_complete {m1 m2 m3 n1 n2 : Bool} {F : Int → Int → Int → GZ}
    (h : genPentagonHoldsM m1 m2 m3 n1 n2 F) : genPentMOKF m1 m2 m3 n1 n2 F = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    allBool_complete fun D =>
      decide_eq_true
        (h (lab A) (lab B) (lab C) (lab D)
          (lab_isLabel A) (lab_isLabel B) (lab_isLabel C) (lab_isLabel D))

theorem genPentMOKF_iff (m1 m2 m3 n1 n2 : Bool) (F : Int → Int → Int → GZ) :
    genPentMOKF m1 m2 m3 n1 n2 F = true ↔ genPentagonHoldsM m1 m2 m3 n1 n2 F :=
  Iff.intro genPentMOKF_sound genPentMOKF_complete

theorem not_genPentagonHoldsM_of_false {m1 m2 m3 n1 n2 : Bool} {F : Int → Int → Int → GZ}
    (h : genPentMOKF m1 m2 m3 n1 n2 F = false) : ¬ genPentagonHoldsM m1 m2 m3 n1 n2 F :=
  fun hp => Bool.noConfusion (h ▸ genPentMOKF_complete hp)

/-! ############################################################################
    SMOKE TESTS — removed in the final file; here to check the plumbing.
    ############################################################################ -/

theorem smoke_untwisted_one : pentagonHolds one :=
  pentagonHoldsM_untwisted ▸ pentMOK_sound (m1 := false) (m2 := false) (m3 := false)
    (n1 := false) (n2 := false) (by decide)

theorem smoke_sig_negOne : pentagonHoldsSig (neg one) :=
  pentagonHoldsSig_eq ▸ pentMOK_sound (by decide)

theorem smoke_sig_I : pentagonHoldsSig I :=
  pentagonHoldsSig_eq ▸ pentMOK_sound (by decide)

/-! ############################################################################
    PART V — what the pentagon SAYS on the labels.
    ############################################################################ -/

/-- The action, indexed by the `Bool` the label came from.  It matches on the
    LABEL first and the mask second, so that `sigB m false z` reduces to `z`
    for an unknown mask `m`: `sigma^0` is the identity whatever the placement,
    and the eight `a = 0` equations of the pentagon are therefore
    placement-independent.  Part VII leans on exactly that. -/
def sigB (m A : Bool) (z : GZ) : GZ :=
  match A with
  | false => z
  | true  => match m with
             | false => z
             | true  => conj z

theorem genPentLhsM_unfold (m1 m2 m3 : Bool) (F : Int → Int → Int → GZ) (A B C D : Bool) :
    genPentLhsM m1 m2 m3 F (lab A) (lab B) (lab C) (lab D)
      = mul (mul (sigB m1 A (F (lab A) (lab B) (lab C)))
                 (sigB m2 A (F (lab A) (lab (xor B C)) (lab D))))
            (sigB m3 A (F (lab B) (lab C) (lab D))) := by
  cases m1 <;> cases m2 <;> cases m3 <;> cases A <;> cases B <;> cases C <;> cases D <;> rfl

theorem genPentRhsM_unfold (n1 n2 : Bool) (F : Int → Int → Int → GZ) (A B C D : Bool) :
    genPentRhsM n1 n2 F (lab A) (lab B) (lab C) (lab D)
      = mul (sigB n1 A (F (lab (xor A B)) (lab C) (lab D)))
            (sigB n2 A (F (lab A) (lab B) (lab (xor C D)))) := by
  cases n1 <;> cases n2 <;> cases A <;> cases B <;> cases C <;> cases D <;> rfl

/-! ############################################################################
    PART VI — the units of `Z[i]`, as a four-element type the kernel can sweep.
    ############################################################################ -/

/-- The four units of `Z[i]`, as a type: `emb uk = i^k`.  Nothing here is
    assumed about them — `emb_mul`, `emb_conj` and `emb_inj` below are what
    make this an encoding rather than a relabelling. -/
inductive U4 | u0 | u1 | u2 | u3

open U4

def emb : U4 → GZ
  | u0 => one | u1 => I | u2 => neg one | u3 => neg I

def u4mul : U4 → U4 → U4
  | u0, y => y
  | u1, u0 => u1 | u1, u1 => u2 | u1, u2 => u3 | u1, u3 => u0
  | u2, u0 => u2 | u2, u1 => u3 | u2, u2 => u0 | u2, u3 => u1
  | u3, u0 => u3 | u3, u1 => u0 | u3, u2 => u1 | u3, u3 => u2

def u4conj : U4 → U4
  | u0 => u0 | u1 => u3 | u2 => u2 | u3 => u1

def u4beq : U4 → U4 → Bool
  | u0, u0 => true | u1, u1 => true | u2, u2 => true | u3, u3 => true
  | _, _ => false

/-- **The encoding is multiplicative.** -/
theorem emb_mul (x y : U4) : mul (emb x) (emb y) = emb (u4mul x y) := by
  cases x <;> cases y <;> rfl

/-- **The encoding transports the Galois action.** -/
theorem emb_conj (x : U4) : conj (emb x) = emb (u4conj x) := by
  cases x <;> rfl

/-- **The encoding is injective**, so a `U4` equation and the `Z[i]` equation
    it stands for are the same statement, not merely correlated. -/
theorem emb_inj {x y : U4} (h : emb x = emb y) : x = y := by
  cases x <;> cases y <;> first | rfl | exact absurd h (by decide)

/-- …and `u4beq` decides it, in both directions. -/
theorem decide_emb (x y : U4) : decide (emb x = emb y) = u4beq x y := by
  cases x <;> cases y <;> rfl

theorem decide_congr_emb {z z' : GZ} {x y : U4} (hz : z = emb x) (hz' : z' = emb y) :
    decide (z = z') = u4beq x y := by
  subst hz; subst hz'; exact decide_emb x y

theorem u4beq_eq {x y : U4} (h : u4beq x y = true) : x = y := by
  cases x <;> cases y <;> first | rfl | exact Bool.noConfusion h

/-- Every `emb u` is a unit of `Z[i]`, so a `U4`-valued symbol really is a
    unit-valued symbol and the enumeration below is an enumeration of the
    objects the seal's `IsClassifiedSymbol` speaks about. -/
theorem emb_isUnit (x : U4) : IsUnit (emb x) :=
  ⟨emb (u4conj x), by cases x <;> rfl⟩

/-- The action, on the encoded units.  Same shape as `sigB`: label first. -/
def sigU (m A : Bool) (x : U4) : U4 :=
  match A with
  | false => x
  | true  => match m with
             | false => x
             | true  => u4conj x

theorem emb_sigU (m A : Bool) (x : U4) : sigB m A (emb x) = emb (sigU m A x) := by
  cases m <;> cases A <;> first | rfl | exact emb_conj x

/-- A unit-valued symbol, presented by its eight values on the labels. -/
def symOfU (w : Bool → Bool → Bool → U4) : Int → Int → Int → GZ :=
  fun a b c => emb (w (boolOf a) (boolOf b) (boolOf c))

theorem symOfU_lab (w : Bool → Bool → Bool → U4) (A B C : Bool) :
    symOfU w (lab A) (lab B) (lab C) = emb (w A B C) := by
  cases A <;> cases B <;> cases C <;> rfl

theorem symOfU_isUnit (w : Bool → Bool → Bool → U4) (a b c : Int) : IsUnit (symOfU w a b c) :=
  emb_isUnit _

/-! ### The two sides of the pentagon, read through the encoding. -/

theorem genPentLhsM_emb (m1 m2 m3 : Bool) (w : Bool → Bool → Bool → U4) (A B C D : Bool) :
    genPentLhsM m1 m2 m3 (symOfU w) (lab A) (lab B) (lab C) (lab D)
      = emb (u4mul (u4mul (sigU m1 A (w A B C)) (sigU m2 A (w A (xor B C) D)))
                   (sigU m3 A (w B C D))) := by
  rw [genPentLhsM_unfold, symOfU_lab, symOfU_lab, symOfU_lab,
      emb_sigU, emb_sigU, emb_sigU, emb_mul, emb_mul]

theorem genPentRhsM_emb (n1 n2 : Bool) (w : Bool → Bool → Bool → U4) (A B C D : Bool) :
    genPentRhsM n1 n2 (symOfU w) (lab A) (lab B) (lab C) (lab D)
      = emb (u4mul (sigU n1 A (w (xor A B) C D)) (sigU n2 A (w A B (xor C D)))) := by
  rw [genPentRhsM_unfold, symOfU_lab, symOfU_lab, emb_sigU, emb_sigU, emb_mul]

/-- **The sigma-pentagon for a unit-valued symbol, as a `Bool` in `U4`.** -/
def pentMU (m1 m2 m3 n1 n2 : Bool) (w : Bool → Bool → Bool → U4) : Bool :=
  allBool fun A => allBool fun B => allBool fun C => allBool fun D =>
    u4beq (u4mul (u4mul (sigU m1 A (w A B C)) (sigU m2 A (w A (xor B C) D)))
                 (sigU m3 A (w B C D)))
          (u4mul (sigU n1 A (w (xor A B) C D)) (sigU n2 A (w A B (xor C D))))

/-- **The transfer.**  The `Z[i]` decision procedure and the `U4` one are the
    SAME `Bool`, so the sweep below is a sweep of the seed's pentagon. -/
theorem genPentMOKF_symOfU (m1 m2 m3 n1 n2 : Bool) (w : Bool → Bool → Bool → U4) :
    genPentMOKF m1 m2 m3 n1 n2 (symOfU w) = pentMU m1 m2 m3 n1 n2 w :=
  allBool_congr fun A => allBool_congr fun B => allBool_congr fun C => allBool_congr fun D =>
    decide_congr_emb (genPentLhsM_emb m1 m2 m3 w A B C D) (genPentRhsM_emb n1 n2 w A B C D)

theorem pentMU_sound {m1 m2 m3 n1 n2 : Bool} {w : Bool → Bool → Bool → U4}
    (h : pentMU m1 m2 m3 n1 n2 w = true) : genPentagonHoldsM m1 m2 m3 n1 n2 (symOfU w) :=
  genPentMOKF_sound ((genPentMOKF_symOfU m1 m2 m3 n1 n2 w).trans h)

theorem pentMU_complete {m1 m2 m3 n1 n2 : Bool} {w : Bool → Bool → Bool → U4}
    (h : genPentagonHoldsM m1 m2 m3 n1 n2 (symOfU w)) : pentMU m1 m2 m3 n1 n2 w = true :=
  (genPentMOKF_symOfU m1 m2 m3 n1 n2 w).symm.trans (genPentMOKF_complete h)

theorem pentMU_iff (m1 m2 m3 n1 n2 : Bool) (w : Bool → Bool → Bool → U4) :
    pentMU m1 m2 m3 n1 n2 w = true ↔ genPentagonHoldsM m1 m2 m3 n1 n2 (symOfU w) :=
  Iff.intro pentMU_sound pentMU_complete

/-! ############################################################################
    PART VII — the sweep.
    ############################################################################ -/

/-- A symbol built from its eight values, in the order
    `(000, 001, 010, 011, 100, 101, 110, 111)`. -/
def mkW (v0 v1 v2 v3 v4 v5 v6 v7 : U4) : Bool → Bool → Bool → U4
  | false, false, false => v0
  | false, false, true  => v1
  | false, true,  false => v2
  | false, true,  true  => v3
  | true,  false, false => v4
  | true,  false, true  => v5
  | true,  true,  false => v6
  | true,  true,  true  => v7

/-- The sigma-pentagon at a placement, as a `Bool` in the eight values. -/
def okU (m1 m2 m3 n1 n2 : Bool) (v0 v1 v2 v3 v4 v5 v6 v7 : U4) : Bool :=
  pentMU m1 m2 m3 n1 n2 (mkW v0 v1 v2 v3 v4 v5 v6 v7)

/-- Any one of the sixteen equations, extracted from the folded `Bool`. -/
theorem okU_at {m1 m2 m3 n1 n2 : Bool} {v0 v1 v2 v3 v4 v5 v6 v7 : U4}
    (h : okU m1 m2 m3 n1 n2 v0 v1 v2 v3 v4 v5 v6 v7 = true) (A B C D : Bool) :
    u4beq (u4mul (u4mul (sigU m1 A (mkW v0 v1 v2 v3 v4 v5 v6 v7 A B C))
                        (sigU m2 A (mkW v0 v1 v2 v3 v4 v5 v6 v7 A (xor B C) D)))
                 (sigU m3 A (mkW v0 v1 v2 v3 v4 v5 v6 v7 B C D)))
          (u4mul (sigU n1 A (mkW v0 v1 v2 v3 v4 v5 v6 v7 (xor A B) C D))
                 (sigU n2 A (mkW v0 v1 v2 v3 v4 v5 v6 v7 A B (xor C D)))) = true := by
  unfold okU pentMU at h
  exact allBool_sound (allBool_sound (allBool_sound (allBool_sound h A) B) C) D

/-! ### Three values are forced, at EVERY placement.

The sixteen equations split into the eight with `a = 0` and the eight with
`a = 1`.  Sigma is `sigma^a`, so on the `a = 0` half it is the identity **for
every mask** — those eight equations are placement-independent.  Three of them
pin down three of the eight values, which cuts the sweep from `4^8 = 65536` to
`4^5 = 1024` without assuming anything about the placement. -/

theorem forced_v0 {v0 : U4} (h : u4beq (u4mul (u4mul v0 v0) v0) (u4mul v0 v0) = true) :
    v0 = u0 := by
  cases v0 <;> first | rfl | exact Bool.noConfusion h

theorem forced_v2 {v1 v2 : U4} (h : u4beq (u4mul (u4mul v1 v2) v2) (u4mul v2 v1) = true) :
    v2 = u0 := by
  cases v1 <;> cases v2 <;> first | rfl | exact Bool.noConfusion h

theorem forced_v3 {v0 v1 v3 : U4} (h0 : v0 = u0)
    (h : u4beq (u4mul (u4mul v1 v3) v3) (u4mul v3 v0) = true) : v3 = u4conj v1 := by
  subst h0
  cases v1 <;> cases v3 <;> first | rfl | exact Bool.noConfusion h

/-- `F(0,0,0) = 1`, forced by the pentagon instance `(a,b,c,d) = (0,0,0,0)`. -/
theorem okU_v0 {m1 m2 m3 n1 n2 : Bool} {v0 v1 v2 v3 v4 v5 v6 v7 : U4}
    (h : okU m1 m2 m3 n1 n2 v0 v1 v2 v3 v4 v5 v6 v7 = true) : v0 = u0 := by
  have e : u4beq (u4mul (u4mul v0 v0) v0) (u4mul v0 v0) = true :=
    okU_at h false false false false
  exact forced_v0 e

/-- `F(0,1,0) = 1`, forced by the instance `(0,0,1,0)`. -/
theorem okU_v2 {m1 m2 m3 n1 n2 : Bool} {v0 v1 v2 v3 v4 v5 v6 v7 : U4}
    (h : okU m1 m2 m3 n1 n2 v0 v1 v2 v3 v4 v5 v6 v7 = true) : v2 = u0 := by
  have e : u4beq (u4mul (u4mul v1 v2) v2) (u4mul v2 v1) = true :=
    okU_at h false false true false
  exact forced_v2 e

/-- `F(0,1,1) = F(0,0,1)⁻¹`, forced by the instance `(0,0,1,1)`. -/
theorem okU_v3 {m1 m2 m3 n1 n2 : Bool} {v0 v1 v2 v3 v4 v5 v6 v7 : U4}
    (h : okU m1 m2 m3 n1 n2 v0 v1 v2 v3 v4 v5 v6 v7 = true) : v3 = u4conj v1 := by
  have e : u4beq (u4mul (u4mul v1 v3) v3) (u4mul v3 v0) = true :=
    okU_at h false false true true
  exact forced_v3 (okU_v0 h) e

/-! ### The enumeration. -/

def over4 {α : Type} (f : U4 → List α) : List α := f u0 ++ f u1 ++ f u2 ++ f u3

theorem mem_over4 {α : Type} (f : U4 → List α) (x : U4) {y : α} (h : y ∈ f x) : y ∈ over4 f := by
  cases x
  · exact List.mem_append_left _ (List.mem_append_left _ (List.mem_append_left _ h))
  · exact List.mem_append_left _ (List.mem_append_left _ (List.mem_append_right _ h))
  · exact List.mem_append_left _ (List.mem_append_right _ h)
  · exact List.mem_append_right _ h

/-- **THE SOLUTION LIST at a placement.**  Every eight-tuple of units with
    `v0 = 1`, `v2 = 1`, `v3 = v1⁻¹` — which by `okU_v0`, `okU_v2`, `okU_v3` is
    every solution there can be — filtered by the placement's own pentagon. -/
def solList (m1 m2 m3 n1 n2 : Bool) : List (List U4) :=
  over4 fun v1 => over4 fun v4 => over4 fun v5 => over4 fun v6 => over4 fun v7 =>
    if okU m1 m2 m3 n1 n2 u0 v1 u0 (u4conj v1) v4 v5 v6 v7
    then [[u0, v1, u0, u4conj v1, v4, v5, v6, v7]] else []

/-- **COMPLETENESS.**  Every unit-valued solution of the placement's pentagon
    appears in `solList`.  Nothing is pruned that could have been a solution:
    the three fixed coordinates are fixed by theorems, not by choice. -/
theorem mem_solList {m1 m2 m3 n1 n2 : Bool} {v0 v1 v2 v3 v4 v5 v6 v7 : U4}
    (h : okU m1 m2 m3 n1 n2 v0 v1 v2 v3 v4 v5 v6 v7 = true) :
    [v0, v1, v2, v3, v4, v5, v6, v7] ∈ solList m1 m2 m3 n1 n2 := by
  have h0 : v0 = u0 := okU_v0 h
  have h2 : v2 = u0 := okU_v2 h
  have h3 : v3 = u4conj v1 := okU_v3 h
  subst h0; subst h2; subst h3
  refine mem_over4 _ v1 (mem_over4 _ v4 (mem_over4 _ v5 (mem_over4 _ v6 (mem_over4 _ v7 ?_))))
  rw [h]
  exact List.mem_singleton_self _

/-- **SOUNDNESS**, as a `Bool` the kernel evaluates: every entry of `solList`
    really does satisfy the placement's pentagon. -/
def solListSound (m1 m2 m3 n1 n2 : Bool) : Bool :=
  (solList m1 m2 m3 n1 n2).all fun l =>
    match l with
    | [a, b, c, d, e, f, g, h] => okU m1 m2 m3 n1 n2 a b c d e f g h
    | _ => false

/-! ############################################################################
    PART VIII — the twisted differential `d3sig`, and the bridge.

    The seed defines `d3` on `Coch3 = Bool → Bool → Bool → Un`, using `Un.inv'`
    (which is `conj`) as the alternating inverse.  That is the differential of
    the TRIVIAL action written multiplicatively.  Below it is transcribed into
    the seal's own integer labels — the move the seed itself makes when it
    writes `d2raw` beside `d2` — and then twisted, by putting `sigma^a` on the
    leading face `f b c d`, which is where the non-trivial action goes.
    ############################################################################ -/

/-- `d^3` in the seal's label arithmetic, with the leading face optionally
    carrying `sigma^a`.  `s = false` is the seed's `d3`; `s = true` is `d3sig`. -/
def d3rawM (s : Bool) (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  mul (mul (mul (sigM s a (F b c d)) (conj (F ((a + b) % 2) c d)))
           (mul (F a ((b + c) % 2) d) (conj (F a b ((c + d) % 2)))))
      (F a b c)

/-- The seed's own `d3`, untwisted. -/
def d3raw (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  mul (mul (mul (F b c d) (conj (F ((a + b) % 2) c d)))
           (mul (F a ((b + c) % 2) d) (conj (F a b ((c + d) % 2)))))
      (F a b c)

/-- **`d3sig`** — the differential of the NON-trivial action. -/
def d3rawSig (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  mul (mul (mul (sig a (F b c d)) (conj (F ((a + b) % 2) c d)))
           (mul (F a ((b + c) % 2) d) (conj (F a b ((c + d) % 2)))))
      (F a b c)

theorem d3rawM_false : d3rawM false = d3raw := rfl
theorem d3rawM_true : d3rawM true = d3rawSig := rfl

/-- The cocycle condition, at either differential. -/
def IsCocycle3M (s : Bool) (F : Int → Int → Int → GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → d3rawM s F a b c d = one

/-- `d3 f = 1`. -/
def IsCocycle3raw (F : Int → Int → Int → GZ) : Prop := IsCocycle3M false F

/-- **`d3sig f = 1`** — the twisted cocycle condition of the charge. -/
def IsCocycle3rawSig (F : Int → Int → Int → GZ) : Prop := IsCocycle3M true F

def cocMAt (s : Bool) (F : Int → Int → Int → GZ) (a b c d : Bool) : Bool :=
  decide (d3rawM s F (lab a) (lab b) (lab c) (lab d) = one)

def cocMOKF (s : Bool) (F : Int → Int → Int → GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d => cocMAt s F a b c d

theorem cocMOKF_sound {s : Bool} {F : Int → Int → Int → GZ} (h : cocMOKF s F = true) :
    IsCocycle3M s F := by
  have key : ∀ A B C D : Bool, d3rawM s F (lab A) (lab B) (lab C) (lab D) = one :=
    fun A B C D => of_decide_eq_true
      (allBool_sound (allBool_sound (allBool_sound (allBool_sound h A) B) C) D)
  intro a b c d ha hb hc hd
  cases exists_bool_of_isLabel ha with
  | intro A hA =>
    cases exists_bool_of_isLabel hb with
    | intro B hB =>
      cases exists_bool_of_isLabel hc with
      | intro C hC =>
        cases exists_bool_of_isLabel hd with
        | intro D hD =>
          subst hA; subst hB; subst hC; subst hD
          exact key A B C D

theorem cocMOKF_complete {s : Bool} {F : Int → Int → Int → GZ} (h : IsCocycle3M s F) :
    cocMOKF s F = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    allBool_complete fun D =>
      decide_eq_true
        (h (lab A) (lab B) (lab C) (lab D)
          (lab_isLabel A) (lab_isLabel B) (lab_isLabel C) (lab_isLabel D))

theorem cocMOKF_iff (s : Bool) (F : Int → Int → Int → GZ) :
    cocMOKF s F = true ↔ IsCocycle3M s F :=
  Iff.intro cocMOKF_sound cocMOKF_complete

theorem not_IsCocycle3M_of_false {s : Bool} {F : Int → Int → Int → GZ}
    (h : cocMOKF s F = false) : ¬ IsCocycle3M s F :=
  fun hp => Bool.noConfusion (h ▸ cocMOKF_complete hp)

/-! ### `d3` read on the labels, and through the encoding. -/

theorem d3rawM_unfold (s : Bool) (F : Int → Int → Int → GZ) (A B C D : Bool) :
    d3rawM s F (lab A) (lab B) (lab C) (lab D)
      = mul (mul (mul (sigB s A (F (lab B) (lab C) (lab D)))
                      (conj (F (lab (xor A B)) (lab C) (lab D))))
                 (mul (F (lab A) (lab (xor B C)) (lab D))
                      (conj (F (lab A) (lab B) (lab (xor C D))))))
            (F (lab A) (lab B) (lab C)) := by
  cases s <;> cases A <;> cases B <;> cases C <;> cases D <;> rfl

theorem d3rawM_emb (s : Bool) (w : Bool → Bool → Bool → U4) (A B C D : Bool) :
    d3rawM s (symOfU w) (lab A) (lab B) (lab C) (lab D)
      = emb (u4mul (u4mul (u4mul (sigU s A (w B C D)) (u4conj (w (xor A B) C D)))
                          (u4mul (w A (xor B C) D) (u4conj (w A B (xor C D)))))
                   (w A B C)) := by
  rw [d3rawM_unfold, symOfU_lab, symOfU_lab, symOfU_lab, symOfU_lab, symOfU_lab,
      emb_sigU, emb_conj, emb_conj, emb_mul, emb_mul, emb_mul, emb_mul]

/-- The cocycle condition for a unit-valued symbol, as a `Bool` in `U4`. -/
def cocMU (s : Bool) (w : Bool → Bool → Bool → U4) : Bool :=
  allBool fun A => allBool fun B => allBool fun C => allBool fun D =>
    u4beq (u4mul (u4mul (u4mul (sigU s A (w B C D)) (u4conj (w (xor A B) C D)))
                        (u4mul (w A (xor B C) D) (u4conj (w A B (xor C D)))))
                 (w A B C)) u0

theorem cocMOKF_symOfU (s : Bool) (w : Bool → Bool → Bool → U4) :
    cocMOKF s (symOfU w) = cocMU s w :=
  allBool_congr fun A => allBool_congr fun B => allBool_congr fun C => allBool_congr fun D =>
    decide_congr_emb (d3rawM_emb s w A B C D) rfl

/-! ### The pointwise identity that is the whole of the bridge.

`Z[i]^x` is abelian and `conj` is inversion on it, so
`l3 · r1⁻¹ · l2 · r2⁻¹ · l1 = 1` and `l1 · l2 · l3 = r1 · r2` are the same
equation.  All 4^5 = 1024 instances, checked. -/

theorem sigU_false (A : Bool) (x : U4) : sigU false A x = x := by cases A <;> rfl

theorem u4_coc_iff_pent (l1 l2 l3 r1 r2 : U4) :
    u4beq (u4mul (u4mul (u4mul l3 (u4conj r1)) (u4mul l2 (u4conj r2))) l1) u0
      = u4beq (u4mul (u4mul l1 l2) l3) (u4mul r1 r2) := by
  cases l1 <;> cases l2 <;> cases l3 <;> cases r1 <;> cases r2 <;> rfl

/-- **THE BRIDGE, as a `Bool` identity.**  The cocycle condition at the
    differential `s` IS the pentagon with sigma at the third left factor and
    nowhere else — for every unit-valued symbol, at once. -/
theorem cocMU_eq_pentMU (s : Bool) (w : Bool → Bool → Bool → U4) :
    cocMU s w = pentMU false false s false false w := by
  refine allBool_congr fun A => allBool_congr fun B => allBool_congr fun C =>
    allBool_congr fun D => ?_
  show u4beq (u4mul (u4mul (u4mul (sigU s A (w B C D)) (u4conj (w (xor A B) C D)))
                          (u4mul (w A (xor B C) D) (u4conj (w A B (xor C D)))))
                   (w A B C)) u0
      = u4beq (u4mul (u4mul (sigU false A (w A B C)) (sigU false A (w A (xor B C) D)))
                     (sigU s A (w B C D)))
              (u4mul (sigU false A (w (xor A B) C D)) (sigU false A (w A B (xor C D))))
  rw [sigU_false, sigU_false, sigU_false, sigU_false]
  exact u4_coc_iff_pent (w A B C) (w A (xor B C) D) (sigU s A (w B C D))
    (w (xor A B) C D) (w A B (xor C D))

/-! ############################################################################
    PART IX — the answers.
    ############################################################################ -/

/-! ### 0.  Sigma is not cosmetic, and it is blind to the real units.

Two facts have to be established before any verdict means anything.  First the
action is non-trivial, and it really does change the pentagon.  Second — and
this is what makes the fermion's survival explicable rather than lucky — `conj`
fixes every element of `Z[i]` with zero imaginary part, so on the sub-slice
`f in {1, -1}` the sigma-pentagon and the seed's pentagon are LITERALLY the
same equation.  The fermion survives because sigma cannot see it. -/

theorem sig_nontrivial : sig 1 I ≠ I := by decide
theorem sig_at_zero_label (z : GZ) : sig 0 z = z := rfl

/-- The twist is not cosmetic: at `f = i` it moves the left side. -/
theorem pentLhsSig_ne_pentLhs_at_I : pentLhsSig I 1 1 1 1 ≠ pentLhs I 1 1 1 1 := by decide

theorem conj_eq_self {z : GZ} (h : z.im = 0) : conj z = z := by
  apply GZ.eq_of
  · rfl
  · show -z.im = z.im
    rw [h]
    -- `rw` leaves `-0 = 0`; that is `rfl` at default transparency
    -- (`Int.neg (ofNat 0) = negOfNat 0 = ofNat 0`) but not at the reducible
    -- transparency `rw`'s closing `rfl` uses, so it has to be discharged here.
    rfl

theorem Fs_im_zero {f : GZ} (h : f.im = 0) (a b c d x y : Int) :
    (Fs f a b c d x y).im = 0 := by
  unfold Fs
  by_cases h1 : x = (a + b) % 2 ∧ y = (b + c) % 2 ∧ d = (a + b + c) % 2
  · rw [if_pos h1]
    by_cases h2 : a = 1 ∧ b = 1 ∧ c = 1
    · rw [if_pos h2]; exact h
    · rw [if_neg h2]; rfl
  · rw [if_neg h1]; rfl

theorem sig_eq_self {z : GZ} (h : z.im = 0) (e : Int) : sig e z = z := by
  unfold sig
  by_cases he : e = 1
  · rw [if_pos he]; exact conj_eq_self h
  · rw [if_neg he]

theorem sig_Fs {f : GZ} (h : f.im = 0) (e a b c d x y : Int) :
    sig e (Fs f a b c d x y) = Fs f a b c d x y :=
  sig_eq_self (Fs_im_zero h a b c d x y) e

/-- **On a real `f` the sigma-pentagon IS the seed's pentagon.** -/
theorem pentLhsSig_real {f : GZ} (h : f.im = 0) (a b c d : Int) :
    pentLhsSig f a b c d = pentLhs f a b c d := by
  unfold pentLhsSig pentLhs
  -- The `let`s of `pentLhsSig` elaborate to `letFun` (printed `have`), so the
  -- occurrence of `sig a (Fs f b c d v u w)` mentions variables bound inside
  -- them and plain `rw` cannot abstract it.  `simp only` descends through the
  -- binders (and zeta-reduces them), so the same rewrite goes through.
  simp only [sig_Fs h]

theorem pentagonHoldsSig_iff_real {f : GZ} (h : f.im = 0) :
    pentagonHoldsSig f ↔ pentagonHolds f := by
  constructor
  · intro hp a b c d ha hb hc hd
    have e := hp a b c d ha hb hc hd
    rw [pentLhsSig_real h] at e
    exact e
  · intro hp a b c d ha hb hc hd
    have e := hp a b c d ha hb hc hd
    rw [pentLhsSig_real h]
    exact e

theorem one_im : (one).im = 0 := rfl
theorem negOne_im : (neg one).im = 0 := rfl

/-! ### 1 and 2.  THE TERMINAL CONDITION: the boson and the fermion. -/

/-- **QUESTION 1 — the boson survives.** -/
theorem sigPentagon_at_one : pentagonHoldsSig one :=
  pentMOK_sound (m1 := false) (m2 := false) (m3 := true) (n1 := false) (n2 := false) (by decide)

/-- **QUESTION 2 — THE FERMION SURVIVES.**  This is the charge's terminal
    condition, and the answer is that it lives. -/
theorem sigPentagon_at_negOne : pentagonHoldsSig (neg one) :=
  pentMOK_sound (m1 := false) (m2 := false) (m3 := true) (n1 := false) (n2 := false) (by decide)

/-- …and it lives for a reason, not by accident: `sigma` fixes `-1`, so at the
    fermion the two pentagons are the same equation, decided the same way. -/
theorem sigPentagon_at_negOne_explained : pentagonHoldsSig (neg one) ↔ pentagonHolds (neg one) :=
  pentagonHoldsSig_iff_real negOne_im

/-- **AND MORE SURVIVES THAN BEFORE.**  `i` and `-i` fail the seed's pentagon
    and satisfy the sigma-pentagon.  That is Reading B's actual content. -/
theorem sigPentagon_at_I : pentagonHoldsSig I :=
  pentMOK_sound (m1 := false) (m2 := false) (m3 := true) (n1 := false) (n2 := false) (by decide)

theorem sigPentagon_at_negI : pentagonHoldsSig (neg I) :=
  pentMOK_sound (m1 := false) (m2 := false) (m3 := true) (n1 := false) (n2 := false) (by decide)

theorem untwisted_fails_at_I : ¬ pentagonHolds I :=
  not_pentagonHoldsM_of_false (m1 := false) (m2 := false) (m3 := false) (n1 := false)
    (n2 := false) (by decide)

theorem untwisted_fails_at_negI : ¬ pentagonHolds (neg I) :=
  not_pentagonHoldsM_of_false (m1 := false) (m2 := false) (m3 := false) (n1 := false)
    (n2 := false) (by decide)

/-- **NON-VACUITY.**  The sigma-pentagon is refutable, so `sigPentagon_at_I` is
    not the statement that everything passes. -/
theorem sigPentagon_fails_at_zero : ¬ pentagonHoldsSig zero :=
  not_pentagonHoldsM_of_false (m1 := false) (m2 := false) (m3 := true) (n1 := false)
    (n2 := false) (by decide)

/-- The five `Bool`s behind the five verdicts above, exposed. -/
theorem sigPentagon_values :
    pentMOK false false true false false one = true
    ∧ pentMOK false false true false false (neg one) = true
    ∧ pentMOK false false true false false I = true
    ∧ pentMOK false false true false false (neg I) = true
    ∧ pentMOK false false true false false zero = false := by decide

theorem untwisted_values :
    pentMOK false false false false false one = true
    ∧ pentMOK false false false false false (neg one) = true
    ∧ pentMOK false false false false false I = false
    ∧ pentMOK false false false false false (neg I) = false := by decide

/-! ### 3.  EVERY PLACEMENT.

`maskList` is all thirty-two subsets of the pentagon's five F-factors, in the
order `(m1, m2, m3 | n1, n2)` with `false` before `true` and `m1` slowest.
`m1, m2, m3` are the three factors of `pentLhs`; `n1, n2` the two of `pentRhs`.
The mask `(false, false, true | false, false)` is Reading B. -/

def bothB {α : Type} (f : Bool → List α) : List α := f false ++ f true

def maskList : List (Bool × Bool × Bool × Bool × Bool) :=
  bothB fun m1 => bothB fun m2 => bothB fun m3 => bothB fun n1 => bothB fun n2 =>
    [(m1, m2, m3, n1, n2)]

theorem maskList_length : maskList.length = 32 := by rfl

def sliceRow (m : Bool × Bool × Bool × Bool × Bool) : List Bool :=
  [pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 one,
   pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 I,
   pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 (neg one),
   pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 (neg I)]

/-- **THE PLACEMENT TABLE.**  One row per placement; the row is
    `[holds at 1, holds at i, holds at -1, holds at -i]`.  Twenty-eight rows
    read `[true, false, true, false]` — the seed's own answer, unchanged.  Two
    read `[true, true, true, true]`.  Nothing else occurs. -/
def sliceTable : List (List Bool) := maskList.map sliceRow

theorem sliceTable_eq : sliceTable =
  [[true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, true, true, true], [true, false, true, false],
   [true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, false, true, false], [true, false, true, false],
   [true, true, true, true], [true, false, true, false], [true, false, true, false],
   [true, false, true, false], [true, false, true, false]] := by rfl

/-- **The boson survives at EVERY placement.** -/
theorem boson_survives_all_placements :
    maskList.all (fun m => pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 one) = true := by rfl

/-- **The fermion survives at EVERY placement.**  Not one of the thirty-two
    ways of inserting sigma kills it. -/
theorem fermion_survives_all_placements :
    maskList.all (fun m => pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 (neg one)) = true := by
  rfl

/-- **`i` survives at exactly two placements**, and they are the two that carry
    sigma on `F(b,c,d)` and nowhere else, up to applying sigma to the whole
    equation (`(true,true,false | true,true)` is `sigma` of Reading B). -/
theorem I_survives_exactly :
    maskList.filter (fun m => pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 I)
      = [(false, false, true, false, false), (true, true, false, true, true)] := by rfl

theorem negI_survives_exactly :
    maskList.filter (fun m => pentMOK m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2 (neg I))
      = [(false, false, true, false, false), (true, true, false, true, true)] := by rfl

/-! ### 4.  THE FULL SOLUTION SETS over unit-valued symbols.

`solList` runs over every eight-tuple of units consistent with the three values
the pentagon forces (`okU_v0`, `okU_v2`, `okU_v3`) and keeps the ones that
satisfy the placement's pentagon; `mem_solList` says nothing else can be a
solution and `solListSound` says everything kept is one.  A tuple is written
`[F(0,0,0), F(0,0,1), F(0,1,0), F(0,1,1), F(1,0,0), F(1,0,1), F(1,1,0), F(1,1,1)]`
with `uk` standing for `i^k`. -/

def maskCounts : List Nat :=
  maskList.map fun m => (solList m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2).length

/-- **The size of the solution set at every one of the thirty-two placements.** -/
theorem maskCounts_eq : maskCounts = [32, 8, 16, 16, 64, 8, 16, 16, 16, 16, 32, 8, 16, 16, 32, 8, 8, 32, 16, 16, 8, 32, 16, 16, 16, 16, 8, 64, 16, 16, 8, 32] := by rfl

theorem solListSound_all :
    maskList.all (fun m => solListSound m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2) = true := by rfl

/-- Distinctness, so that a list of length `n` really is `n` solutions. -/
def u4ListBeq : List U4 → List U4 → Bool
  | [], [] => true
  | x :: xs, y :: ys => u4beq x y && u4ListBeq xs ys
  | _, _ => false

def noDup : List (List U4) → Bool
  | [] => true
  | x :: xs => (xs.all fun y => !(u4ListBeq x y)) && noDup xs

theorem solList_noDup_all :
    maskList.all (fun m => noDup (solList m.1 m.2.1 m.2.2.1 m.2.2.2.1 m.2.2.2.2)) = true := by rfl

/-- **THE UNTWISTED SOLUTION SET** — the seed's own pentagon, 32 symbols. -/
theorem solList_untwisted : solList false false false false false =
  [[u0, u0, u0, u0, u0, u0, u0, u0],
   [u0, u0, u0, u0, u0, u0, u0, u2],
   [u0, u0, u0, u0, u1, u1, u3, u1],
   [u0, u0, u0, u0, u1, u1, u3, u3],
   [u0, u0, u0, u0, u2, u2, u2, u0],
   [u0, u0, u0, u0, u2, u2, u2, u2],
   [u0, u0, u0, u0, u3, u3, u1, u1],
   [u0, u0, u0, u0, u3, u3, u1, u3],
   [u0, u1, u0, u3, u0, u1, u0, u1],
   [u0, u1, u0, u3, u0, u1, u0, u3],
   [u0, u1, u0, u3, u1, u2, u3, u0],
   [u0, u1, u0, u3, u1, u2, u3, u2],
   [u0, u1, u0, u3, u2, u3, u2, u1],
   [u0, u1, u0, u3, u2, u3, u2, u3],
   [u0, u1, u0, u3, u3, u0, u1, u0],
   [u0, u1, u0, u3, u3, u0, u1, u2],
   [u0, u2, u0, u2, u0, u2, u0, u0],
   [u0, u2, u0, u2, u0, u2, u0, u2],
   [u0, u2, u0, u2, u1, u3, u3, u1],
   [u0, u2, u0, u2, u1, u3, u3, u3],
   [u0, u2, u0, u2, u2, u0, u2, u0],
   [u0, u2, u0, u2, u2, u0, u2, u2],
   [u0, u2, u0, u2, u3, u1, u1, u1],
   [u0, u2, u0, u2, u3, u1, u1, u3],
   [u0, u3, u0, u1, u0, u3, u0, u1],
   [u0, u3, u0, u1, u0, u3, u0, u3],
   [u0, u3, u0, u1, u1, u0, u3, u0],
   [u0, u3, u0, u1, u1, u0, u3, u2],
   [u0, u3, u0, u1, u2, u1, u2, u1],
   [u0, u3, u0, u1, u2, u1, u2, u3],
   [u0, u3, u0, u1, u3, u2, u1, u0],
   [u0, u3, u0, u1, u3, u2, u1, u2]] := by rfl

/-- **THE READING-B SOLUTION SET** — sigma on `F(b,c,d)`, 64 symbols.  It
    contains the untwisted 32 and doubles them. -/
theorem solList_sig : solList false false true false false =
  [[u0, u0, u0, u0, u0, u0, u0, u0],
   [u0, u0, u0, u0, u0, u0, u0, u1],
   [u0, u0, u0, u0, u0, u0, u0, u2],
   [u0, u0, u0, u0, u0, u0, u0, u3],
   [u0, u0, u0, u0, u1, u1, u1, u0],
   [u0, u0, u0, u0, u1, u1, u1, u1],
   [u0, u0, u0, u0, u1, u1, u1, u2],
   [u0, u0, u0, u0, u1, u1, u1, u3],
   [u0, u0, u0, u0, u2, u2, u2, u0],
   [u0, u0, u0, u0, u2, u2, u2, u1],
   [u0, u0, u0, u0, u2, u2, u2, u2],
   [u0, u0, u0, u0, u2, u2, u2, u3],
   [u0, u0, u0, u0, u3, u3, u3, u0],
   [u0, u0, u0, u0, u3, u3, u3, u1],
   [u0, u0, u0, u0, u3, u3, u3, u2],
   [u0, u0, u0, u0, u3, u3, u3, u3],
   [u0, u1, u0, u3, u0, u3, u0, u0],
   [u0, u1, u0, u3, u0, u3, u0, u1],
   [u0, u1, u0, u3, u0, u3, u0, u2],
   [u0, u1, u0, u3, u0, u3, u0, u3],
   [u0, u1, u0, u3, u1, u0, u1, u0],
   [u0, u1, u0, u3, u1, u0, u1, u1],
   [u0, u1, u0, u3, u1, u0, u1, u2],
   [u0, u1, u0, u3, u1, u0, u1, u3],
   [u0, u1, u0, u3, u2, u1, u2, u0],
   [u0, u1, u0, u3, u2, u1, u2, u1],
   [u0, u1, u0, u3, u2, u1, u2, u2],
   [u0, u1, u0, u3, u2, u1, u2, u3],
   [u0, u1, u0, u3, u3, u2, u3, u0],
   [u0, u1, u0, u3, u3, u2, u3, u1],
   [u0, u1, u0, u3, u3, u2, u3, u2],
   [u0, u1, u0, u3, u3, u2, u3, u3],
   [u0, u2, u0, u2, u0, u2, u0, u0],
   [u0, u2, u0, u2, u0, u2, u0, u1],
   [u0, u2, u0, u2, u0, u2, u0, u2],
   [u0, u2, u0, u2, u0, u2, u0, u3],
   [u0, u2, u0, u2, u1, u3, u1, u0],
   [u0, u2, u0, u2, u1, u3, u1, u1],
   [u0, u2, u0, u2, u1, u3, u1, u2],
   [u0, u2, u0, u2, u1, u3, u1, u3],
   [u0, u2, u0, u2, u2, u0, u2, u0],
   [u0, u2, u0, u2, u2, u0, u2, u1],
   [u0, u2, u0, u2, u2, u0, u2, u2],
   [u0, u2, u0, u2, u2, u0, u2, u3],
   [u0, u2, u0, u2, u3, u1, u3, u0],
   [u0, u2, u0, u2, u3, u1, u3, u1],
   [u0, u2, u0, u2, u3, u1, u3, u2],
   [u0, u2, u0, u2, u3, u1, u3, u3],
   [u0, u3, u0, u1, u0, u1, u0, u0],
   [u0, u3, u0, u1, u0, u1, u0, u1],
   [u0, u3, u0, u1, u0, u1, u0, u2],
   [u0, u3, u0, u1, u0, u1, u0, u3],
   [u0, u3, u0, u1, u1, u2, u1, u0],
   [u0, u3, u0, u1, u1, u2, u1, u1],
   [u0, u3, u0, u1, u1, u2, u1, u2],
   [u0, u3, u0, u1, u1, u2, u1, u3],
   [u0, u3, u0, u1, u2, u3, u2, u0],
   [u0, u3, u0, u1, u2, u3, u2, u1],
   [u0, u3, u0, u1, u2, u3, u2, u2],
   [u0, u3, u0, u1, u2, u3, u2, u3],
   [u0, u3, u0, u1, u3, u0, u3, u0],
   [u0, u3, u0, u1, u3, u0, u3, u1],
   [u0, u3, u0, u1, u3, u0, u3, u2],
   [u0, u3, u0, u1, u3, u0, u3, u3]] := by rfl

/-- Sigma on the FIRST left factor `F(a,b,c)` — 8 symbols, a quarter of the
    untwisted set.  This placement destroys solutions rather than adding them. -/
theorem solList_P1 : solList true false false false false =
  [[u0, u0, u0, u0, u0, u0, u0, u0],
   [u0, u0, u0, u0, u0, u0, u0, u2],
   [u0, u0, u0, u0, u2, u2, u2, u0],
   [u0, u0, u0, u0, u2, u2, u2, u2],
   [u0, u2, u0, u2, u0, u2, u0, u0],
   [u0, u2, u0, u2, u0, u2, u0, u2],
   [u0, u2, u0, u2, u2, u0, u2, u0],
   [u0, u2, u0, u2, u2, u0, u2, u2]] := by rfl

/-- Sigma on the SECOND left factor `F(a, b+c, d)` — 16 symbols, half the
    untwisted set. -/
theorem solList_P2 : solList false true false false false =
  [[u0, u0, u0, u0, u0, u0, u0, u0],
   [u0, u0, u0, u0, u0, u0, u0, u2],
   [u0, u0, u0, u0, u2, u2, u2, u0],
   [u0, u0, u0, u0, u2, u2, u2, u2],
   [u0, u1, u0, u3, u0, u3, u0, u1],
   [u0, u1, u0, u3, u0, u3, u0, u3],
   [u0, u1, u0, u3, u2, u1, u2, u1],
   [u0, u1, u0, u3, u2, u1, u2, u3],
   [u0, u2, u0, u2, u0, u2, u0, u0],
   [u0, u2, u0, u2, u0, u2, u0, u2],
   [u0, u2, u0, u2, u2, u0, u2, u0],
   [u0, u2, u0, u2, u2, u0, u2, u2],
   [u0, u3, u0, u1, u0, u1, u0, u1],
   [u0, u3, u0, u1, u0, u1, u0, u3],
   [u0, u3, u0, u1, u2, u3, u2, u1],
   [u0, u3, u0, u1, u2, u3, u2, u3]] := by rfl

/-! ### 5.  The seed's two named general symbols, under sigma. -/

theorem twistedBoson_sig : genPentagonHoldsM false false true false false twistedBoson :=
  genPentMOKF_sound (by decide)

theorem twistedBoson_untwisted : genPentagonHolds twistedBoson :=
  genPentMOKF_sound (m1 := false) (m2 := false) (m3 := false) (n1 := false) (n2 := false)
    (by decide)

theorem fakeCocycle_fails_sig : ¬ genPentagonHoldsM false false true false false fakeCocycle :=
  not_genPentagonHoldsM_of_false (by decide)

theorem fakeCocycle_fails_untwisted : ¬ genPentagonHolds fakeCocycle :=
  not_genPentagonHoldsM_of_false (m1 := false) (m2 := false) (m3 := false) (n1 := false)
    (n2 := false) (by decide)

/-- The general-symbol pentagon at the four slice symbols, twisted and not. -/
theorem slice_general_values :
    genPentMOKF false false true false false (sliceCore one) = true
    ∧ genPentMOKF false false true false false (sliceCore I) = true
    ∧ genPentMOKF false false true false false (sliceCore (neg one)) = true
    ∧ genPentMOKF false false true false false (sliceCore (neg I)) = true
    ∧ genPentMOKF false false false false false (sliceCore I) = false := by decide

/-! ### 6.  QUESTION 4 — does the sigma-pentagon coincide with `d3sig = 1`? -/

/-- **YES, AND AT BOTH TWISTS AT ONCE.**  For every unit-valued symbol, the
    pentagon carrying `sigma^a` on `F(b,c,d)` (and nowhere else) is exactly the
    cocycle condition for the differential carrying `sigma^a` on its leading
    face (and nowhere else).  Take `s = false` and this is the seed's pentagon
    against the seed's `d3`; take `s = true` and it is Reading B against
    `d3sig`.  One theorem, both halves. -/
theorem pentagonM_iff_cocycleM (s : Bool) (w : Bool → Bool → Bool → U4) :
    genPentagonHoldsM false false s false false (symOfU w) ↔ IsCocycle3M s (symOfU w) := by
  constructor
  · intro h
    exact cocMOKF_sound
      ((cocMOKF_symOfU s w).trans ((cocMU_eq_pentMU s w).trans (pentMU_complete h)))
  · intro h
    exact pentMU_sound
      ((cocMU_eq_pentMU s w).symm.trans
        ((cocMOKF_symOfU s w).symm.trans (cocMOKF_complete h)))

/-- **READING B'S BRIDGE.** -/
theorem sigPentagon_iff_d3sig (w : Bool → Bool → Bool → U4) :
    genPentagonHoldsSig (symOfU w) ↔ IsCocycle3rawSig (symOfU w) :=
  pentagonM_iff_cocycleM true w

/-- **The untwisted bridge**, for contrast: the seed's pentagon is the seed's
    `d3`.  So the pentagon was the cocycle condition all along, and Reading B
    changes both sides of that identification in step. -/
theorem untwistedPentagon_iff_d3 (w : Bool → Bool → Bool → U4) :
    genPentagonHolds (symOfU w) ↔ IsCocycle3raw (symOfU w) :=
  pentagonM_iff_cocycleM false w

/-! ### 7.  …and READING A's bridge is broken.

Reading A twists the differential but leaves the pentagon alone.  The two then
disagree, and here is the symbol that separates them: `sliceCore i` satisfies
`d3sig = 1` and fails the seed's pentagon.  Reading B repairs exactly this. -/

theorem sliceI_isCocycleSig : IsCocycle3rawSig (sliceCore I) :=
  cocMOKF_sound (s := true) (by decide)

theorem sliceI_not_untwistedPentagon : ¬ genPentagonHolds (sliceCore I) :=
  not_genPentagonHoldsM_of_false (m1 := false) (m2 := false) (m3 := false) (n1 := false)
    (n2 := false) (by decide)

/-- **THE BREAK.**  The untwisted pentagon and the twisted cocycle condition
    are NOT the same predicate. -/
theorem readingA_bridge_broken :
    ¬ (∀ F : Int → Int → Int → GZ, genPentagonHolds F ↔ IsCocycle3rawSig F) :=
  fun h => sliceI_not_untwistedPentagon ((h (sliceCore I)).mpr sliceI_isCocycleSig)

/-- …and the break is not an artefact of the twisted side being empty: at the
    untwisted differential, `sliceCore i` fails BOTH, so the two untwisted
    predicates still agree there. -/
theorem sliceI_not_isCocycle : ¬ IsCocycle3raw (sliceCore I) :=
  not_IsCocycle3M_of_false (s := false) (by decide)

theorem cocycle_values :
    cocMOKF true (sliceCore one) = true
    ∧ cocMOKF true (sliceCore I) = true
    ∧ cocMOKF true (sliceCore (neg one)) = true
    ∧ cocMOKF true (sliceCore (neg I)) = true
    ∧ cocMOKF false (sliceCore I) = false
    ∧ cocMOKF false (sliceCore (neg I)) = false
    ∧ cocMOKF false (sliceCore one) = true
    ∧ cocMOKF false (sliceCore (neg one)) = true := by decide

/-! ### 8.  Non-vacuity of the domain the sweep speaks about. -/

theorem symOfU_unitValued (w : Bool → Bool → Bool → U4) (a b c : Int) :
    IsUnit (symOfU w a b c) := symOfU_isUnit w a b c

/-- The sweep's domain is inhabited by a symbol that satisfies Reading B and by
    one that does not, so neither half of the solution set is empty. -/
def wBoson : Bool → Bool → Bool → U4 := fun _ _ _ => u0
def wFake : Bool → Bool → Bool → U4 := mkW u0 u1 u0 u0 u0 u0 u0 u0

theorem wBoson_sig : genPentagonHoldsM false false true false false (symOfU wBoson) :=
  pentMU_sound (by decide)

theorem wFake_not_sig : ¬ genPentagonHoldsM false false true false false (symOfU wFake) := by
  intro h
  exact Bool.noConfusion (((pentMU_complete h : pentMU false false true false false wFake = true)
    : (false : Bool) = true))

/-! ############################################################################
    PART X — axiom audit.  Every theorem in the file, not a curated sample.
    ############################################################################ -/

