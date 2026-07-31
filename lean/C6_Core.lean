/-
  C6_Core.lean — Circle Six's kernel-checked core.

  PROVENANCE.  Part I below is copied VERBATIM from `lean/C6_SEED.lean`: every
  definition of that file which depends on none of the 31 stripped names.  Docstrings
  are the seed's.  Nothing was renamed, improved, or "fixed".  Part II and Part III
  are Circle Six's own and are marked as such.

  NO IMPORTS.  A Lean 4 file without `prelude` gets `Init` and nothing else, so every
  lemma cited below (`Int.neg_mul_neg`, `of_decide_eq_true`, `Bool.noConfusion`, …) is
  core.  There is no Mathlib here, hence no `ring`, no `rcases`, no `tauto`.

  DISCIPLINE.  No `sorry`, no `admit`, no `axiom`, no `native_decide`, no
  `@[implemented_by]`.  Every `decide` in this file is a kernel `decide`.

  ADAPTATIONS: none.  Every seed definition transcribed here elaborated exactly as
  written on the first attempt.  See the report at the foot of the file.
-/

/-! ############################################################################
    PART I — the seed's definitions, verbatim.
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

/-- `G4_control_fake_mirror_fails`, in the kernel. The near-miss
    `(a,b) ↦ (a, 2b)` is additive and fixes the first coordinate, so it
    looks like a mirror — and it is not multiplicative. Witness below. -/
def fakeMirror (z : GZ) : GZ := ⟨z.re, 2 * z.im⟩

/-- The sign is load-bearing. With `i² = +1` instead — the split-complex
    multiplication — the ring acquires zero divisors, so the domain result
    S2 is charged to prove is a statement about the SIGN, not about pairs
    of integers. This control is why `no_zero_divisors` is not free. -/
def splitMul (z w : GZ) : GZ := ⟨z.re * w.re + z.im * w.im, z.re * w.im + z.im * w.re⟩

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

/-- The braiding symbol: `R` at the single slot `(1,1)`, `one` elsewhere.
    The bench's `Rs`, in Z[i]. -/
def Rs (R : GZ) (x y : Int) : GZ := if x = 1 ∧ y = 1 then R else one

/-- The hexagon's left side: one braiding and one F-symbol. -/
def hexLhs (f R : GZ) (a b c d : Int) : GZ :=
  let e := (a + b) % 2; let z := (a + c) % 2
  mul (Rs R e c) (Fs f c a b d z e)

/-- The hexagon's right side: two F-symbols and two braidings. -/
def hexRhs (f R : GZ) (a b c d : Int) : GZ :=
  let e := (a + b) % 2; let z := (a + c) % 2; let g := (b + c) % 2
  mul (mul (mul (Fs f a b c d e g) (Rs R b c)) (Fs f a c b d z g)) (Rs R a c)

/-- The hexagon, as a proposition about `(f, R)`. -/
def hexagonHolds (f R : GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → d = ((a + b) % 2 + c) % 2 → d = ((a + c) % 2 + b) % 2 →
    hexLhs f R a b c d = hexRhs f R a b c d

/-- The R⁻¹-hexagon: the same plumbing, read at the inverse braiding. -/
def hexInvHolds (f R : GZ) : Prop := hexagonHolds f (conj R)

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

/-- The 2-cochain action on the free labels: two gauge factors up, two
    down. The down slots use `conj`, which is the inverse exactly on
    units — so this is an action of UNIT-valued gauges, and nothing here
    claims it is one otherwise. -/
def gaugeAct (g : Int → Int → GZ) (F : Int → Int → Int → GZ) (a b c : Int) : GZ :=
  mul (F a b c)
    (mul (mul (g a b) (g ((a + b) % 2) c)) (mul (conj (g b c)) (conj (g a ((b + c) % 2)))))

/-- **The gauge, written down rather than asserted to exist.** Two of its
    four values are read straight off `F`; the other two are `one`. -/
def gaugeOf (F : Int → Int → Int → GZ) (a b : Int) : GZ :=
  if a = 0 ∧ b = 1 then F 0 0 1 else if a = 1 ∧ b = 0 then conj (F 1 0 0) else one

/-- A pentagon-satisfying unit-valued symbol that is NOT in the slice: the
    boson twisted by a gauge with `g(0,1) = i`. The first label is written
    `_a` because the twist genuinely does not depend on it — a fact the
    linter noticed before the author did. -/
def twistedBoson (_a b c : Int) : GZ :=
  if c = 1 then (if b = 1 then I else neg I) else one

/-- A unit-valued symbol that does NOT satisfy the pentagon. -/
def fakeCocycle (a b c : Int) : GZ :=
  if a = 0 ∧ b = 0 ∧ c = 1 then I else one

/-- The roomy edict: a braiding is its own inverse. -/
def SelfInverse (R : GZ) : Prop := mul R R = one

def sumTo (f : Nat → Int) : Nat → Int
  | 0 => 0
  | n + 1 => sumTo f n + f n

/-- A vector of the tensor square, in coordinates: `v i j` is the
    coefficient of the basis vector `e_ij`. -/
def swapT (v : Nat → Nat → Int) : Nat → Nat → Int := fun i j => v j i

/-- The basis vector `e_ab`. -/
def eBasis (a b : Nat) : Nat → Nat → Int := fun i j => if i = a ∧ j = b then 1 else 0

/-- **The antisymmetrizer, `M = I − swap`**, written in coordinates. -/
def antiM (v : Nat → Nat → Int) : Nat → Nat → Int := fun i j => v i j - swapT v i j

/-- The trace of `M` over the index square `[0,m) × [0,m)`: the sum of the
    diagonal coefficients of `M e_ab`, read off the operator itself rather
    than off a matrix written down beside it. -/
def traceM (m : Nat) : Int := sumTo (fun a => sumTo (fun b => antiM (eBasis a b) a b) m) m

/-- The generator `e_ab − e_ba`, as the image of a basis vector. -/
def eDiff (a b : Nat) : Nat → Nat → Int := antiM (eBasis a b)

/-- `[0, 1, …, n−1]`. -/
def upTo : Nat → List Nat
  | 0 => []
  | n + 1 => upTo n ++ [n]

/-- The index set of the image basis: every pair `(i, j)` with `i < j < m`. -/
def upperPairs : Nat → List (Nat × Nat)
  | 0 => []
  | m + 1 => upperPairs m ++ (upTo m).map (fun i => (i, m))

/-- **The gauge factor.** `gaugeAct` multiplies the symbol by exactly this,
    and every fact below is a fact about it. -/
def gaugePhi (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (g a b) (g ((a + b) % 2) c)) (mul (conj (g b c)) (conj (g a ((b + c) % 2))))

/-- The trivial gauge — the identity of the gauge group. -/
def gaugeTrivial : Int → Int → GZ := fun _ _ => one

/-- Gauge inversion. On units the conjugate IS the inverse (section 13's
    bridge), which is why this is the inverse and why every theorem using
    it carries the unit hypothesis. -/
def gaugeInv (g : Int → Int → GZ) : Int → Int → GZ := fun a b => conj (g a b)

/-- Gauge composition, pointwise. -/
def gaugeComp (g h : Int → Int → GZ) : Int → Int → GZ := fun a b => mul (g a b) (h a b)

/-- **`F` and `F'` are gauge-equivalent on the labels** when some
    unit-valued gauge carries the one onto the other at every label
    triple. -/
def GaugeEquivOnLabels (F F' : Int → Int → Int → GZ) : Prop :=
  ∃ g : Int → Int → GZ, (∀ a b : Int, IsUnit (g a b)) ∧
    ∀ a b c : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
      gaugeAct g F a b c = F' a b c

def Dom (α : Type) (P : α → Prop) : Type := { x : α // P x }

def DomRel {α : Type} (P : α → Prop) (R : α → α → Prop) : Dom α P → Dom α P → Prop :=
  fun x y => R x.val y.val

def Classes {α : Type} (P : α → Prop) (R : α → α → Prop) : Type :=
  Quot (DomRel P R)

def cls {α : Type} {P : α → Prop} {R : α → α → Prop} (x : Dom α P) : Classes P R :=
  Quot.mk (DomRel P R) x

/-- The domain the sealed classification speaks about, reified as a
    predicate: unit-valued and pentagon-satisfying. These are exactly the
    two hypotheses `at_most_two_classes` carries on its free variable. -/
def IsClassifiedSymbol (F : Int → Int → Int → GZ) : Prop :=
  (∀ a b c : Int, IsUnit (F a b c)) ∧ genPentagonHolds F

/-- A commutative group, packaged without typeclasses: this record imports
    nothing and declares no instances, so the structure IS the claim. -/
structure AbGroup (α : Type) where
  op    : α → α → α
  e     : α
  inv   : α → α
  assoc : ∀ x y z : α, op (op x y) z = op x (op y z)
  comm  : ∀ x y : α, op x y = op y x
  unit  : ∀ x : α, op e x = x
  invl  : ∀ x : α, op (inv x) x = e

/-- The bridge from the index group to the seal's integer labels. -/
def lab : Bool → Int := fun b => if b then 1 else 0

/-- The `d^2` coboundary written in the seal's own label arithmetic, so it
    can be compared with `gaugePhi` without any translation layer. -/
def d2raw (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (g b c) (conj (g ((a + b) % 2) c))) (mul (g a ((b + c) % 2)) (conj (g a b)))

/-- The label decoder: `Int` to `Bool`, inverse to `lab` on the labels. -/
def boolOf (i : Int) : Bool := if i = 1 then true else false

/-- Pointwise product of symbols — the multiplication the coefficient
    ring already carries, lifted to symbols one label triple at a time. -/
def symMul (F G : Int → Int → Int → GZ) : Int → Int → Int → GZ :=
  fun a b c => mul (F a b c) (G a b c)

/-- A commutative group law, packaged without typeclasses — this record
    imports nothing and declares no instances; the structure IS the
    claim, and its fields are the theorems above. -/
structure CommGroupLaw (α : Type) where
  op       : α → α → α
  unit     : α
  inv      : α → α
  op_assoc : ∀ x y z : α, op (op x y) z = op x (op y z)
  op_comm  : ∀ x y : α, op x y = op y x
  unit_op  : ∀ x : α, op unit x = x
  inv_op   : ∀ x : α, op (inv x) x = unit

/-! ############################################################################
    PART II — Circle Six's decidability bridge.

    Nothing below is the seed's.  The point of this part is to make the kernel,
    and only the kernel, able to settle the finite questions the seed poses.
    ############################################################################ -/

/-- `GZ` is a structure with two `Int` fields, so it has componentwise
    extensionality.  Written out rather than `deriving`, because Part I is
    verbatim and I will not add a `deriving` clause to the seed's `structure`. -/
theorem GZ.eq_of {z w : GZ} (hr : z.re = w.re) (hi : z.im = w.im) : z = w := by
  cases z; cases w; cases hr; cases hi; rfl

/-- Decidable equality on `GZ`, by hand: two `Int.decEq`s and the projections. -/
instance instDecidableEqGZ : DecidableEq GZ := fun z w =>
  if hr : z.re = w.re then
    if hi : z.im = w.im then isTrue (GZ.eq_of hr hi)
    else isFalse (fun h => hi (congrArg GZ.im h))
  else isFalse (fun h => hr (congrArg GZ.re h))

/-! ### A two-point universal quantifier that the kernel can chew through.

`Bool` is the index set of the whole finite problem; `allBool` is its `∀`, and
`allBool_sound`/`allBool_complete` are the two halves of the reflection.  Everything
downstream is four nestings of this. -/

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

/-- `lab` lands in the seed's label set — so the hypotheses of `pentagonHolds`
    are satisfiable, at every one of the sixteen assignments. -/
theorem lab_isLabel (A : Bool) : lab A = 0 ∨ lab A = 1 := by
  cases A with
  | false => exact Or.inl rfl
  | true  => exact Or.inr rfl

/-- …and conversely, the seed's label hypothesis names a `Bool`.  This is the step
    that turns an `Int`-quantified `Prop` into a finite `Bool` computation. -/
theorem exists_bool_of_isLabel {a : Int} (h : a = 0 ∨ a = 1) : ∃ A : Bool, a = lab A := by
  cases h with
  | inl h => exact ⟨false, by rw [h]; rfl⟩
  | inr h => exact ⟨true, by rw [h]; rfl⟩

/-! ### The pentagon bridge, for `Fs f`. -/

/-- The pentagon equation at one of the sixteen label assignments, as a `Bool`. -/
def pentAt (f : GZ) (a b c d : Bool) : Bool :=
  decide (pentLhs f (lab a) (lab b) (lab c) (lab d)
        = pentRhs f (lab a) (lab b) (lab c) (lab d))

/-- **The decision procedure for `pentagonHolds`.**  Sixteen equations in `Z[i]`,
    folded into one `Bool` the kernel can evaluate. -/
def pentOK (f : GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d => pentAt f a b c d

theorem pentOK_sound {f : GZ} (h : pentOK f = true) : pentagonHolds f := by
  have key : ∀ A B C D : Bool,
      pentLhs f (lab A) (lab B) (lab C) (lab D)
        = pentRhs f (lab A) (lab B) (lab C) (lab D) := fun A B C D =>
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

theorem pentOK_complete {f : GZ} (h : pentagonHolds f) : pentOK f = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    allBool_complete fun D =>
      decide_eq_true
        (h (lab A) (lab B) (lab C) (lab D)
          (lab_isLabel A) (lab_isLabel B) (lab_isLabel C) (lab_isLabel D))

/-- **The bridge.**  `decide` on the left is genuine kernel evidence about the
    right, in both directions. -/
theorem pentOK_iff (f : GZ) : pentOK f = true ↔ pentagonHolds f :=
  Iff.intro pentOK_sound pentOK_complete

/-- The contrapositive, packaged: a `false` from the kernel refutes the pentagon. -/
theorem not_pentagonHolds_of_pentOK_false {f : GZ} (h : pentOK f = false) :
    ¬ pentagonHolds f := fun hp => Bool.noConfusion (h ▸ pentOK_complete hp)

/-! ### The same bridge for a general symbol, and for a symbol given by its
    eight values on the labels. -/

/-- The general-symbol pentagon equation at one label assignment, as a `Bool`. -/
def genPentAt (F : Int → Int → Int → GZ) (a b c d : Bool) : Bool :=
  decide (genPentLhs F (lab a) (lab b) (lab c) (lab d)
        = genPentRhs F (lab a) (lab b) (lab c) (lab d))

/-- **The decision procedure for `genPentagonHolds`**, for any symbol whose values
    the kernel can compute. -/
def genPentOKF (F : Int → Int → Int → GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d => genPentAt F a b c d

theorem genPentOKF_sound {F : Int → Int → Int → GZ} (h : genPentOKF F = true) :
    genPentagonHolds F := by
  have key : ∀ A B C D : Bool,
      genPentLhs F (lab A) (lab B) (lab C) (lab D)
        = genPentRhs F (lab A) (lab B) (lab C) (lab D) := fun A B C D =>
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

theorem genPentOKF_complete {F : Int → Int → Int → GZ} (h : genPentagonHolds F) :
    genPentOKF F = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    allBool_complete fun D =>
      decide_eq_true
        (h (lab A) (lab B) (lab C) (lab D)
          (lab_isLabel A) (lab_isLabel B) (lab_isLabel C) (lab_isLabel D))

theorem genPentOKF_iff (F : Int → Int → Int → GZ) :
    genPentOKF F = true ↔ genPentagonHolds F :=
  Iff.intro genPentOKF_sound genPentOKF_complete

theorem not_genPentagonHolds_of_false {F : Int → Int → Int → GZ} (h : genPentOKF F = false) :
    ¬ genPentagonHolds F := fun hp => Bool.noConfusion (h ▸ genPentOKF_complete hp)

/-- **A symbol given as its eight values.**  `v A B C` is the value at the label
    triple `(lab A, lab B, lab C)`; off the labels the decoder `boolOf` sends
    everything to `false`, exactly as the seed's `symbolOf` does. -/
def symOfValues (v : Bool → Bool → Bool → GZ) : Int → Int → Int → GZ :=
  fun a b c => v (boolOf a) (boolOf b) (boolOf c)

/-- **The decision procedure over the eight values.** -/
def genPentOK (v : Bool → Bool → Bool → GZ) : Bool := genPentOKF (symOfValues v)

theorem genPentOK_iff (v : Bool → Bool → Bool → GZ) :
    genPentOK v = true ↔ genPentagonHolds (symOfValues v) :=
  genPentOKF_iff (symOfValues v)

theorem genPentOK_sound {v : Bool → Bool → Bool → GZ} (h : genPentOK v = true) :
    genPentagonHolds (symOfValues v) := genPentOKF_sound h

/-- The eight values of the slice symbol at `f` — the seed's `sliceCore`, presented
    as a table. -/
def sliceValues (f : GZ) : Bool → Bool → Bool → GZ :=
  fun a b c => if a && b && c then f else one

/-! ############################################################################
    PART III — Circle Six's sanity checks on the core.

    Every one of these is inside the seed's own stated content and needs none of
    the 31 stripped names.  They are the evidence that Part I is faithful.
    ############################################################################ -/

/-! ### 1.  `conj` is a ring homomorphism — the Galois action. -/

/-- **`conj` is multiplicative.**  This is the sigma of Circle Two acting on the
    coefficients, and it is the whole reason `conj` can serve as an inverse below. -/
theorem conj_mul (z w : GZ) : mul (conj z) (conj w) = conj (mul z w) := by
  apply GZ.eq_of
  · show z.re * w.re - (-z.im) * (-w.im) = z.re * w.re - z.im * w.im
    rw [Int.neg_mul_neg]
  · show z.re * (-w.im) + (-z.im) * w.re = -(z.re * w.im + z.im * w.re)
    rw [Int.mul_neg, Int.neg_mul, Int.neg_add]

/-- `conj` is additive too — so it is a ring hom, not merely multiplicative. -/
theorem conj_add (z w : GZ) : add (conj z) (conj w) = conj (add z w) := by
  apply GZ.eq_of
  · show z.re + w.re = z.re + w.re
    rfl
  · show (-z.im) + (-w.im) = -(z.im + w.im)
    rw [Int.neg_add]

theorem conj_one : conj one = one := rfl

/-! ### 2.  `conj` is an involution, of order exactly 2. -/

/-- **`conj` is an involution.** -/
theorem conj_conj (z : GZ) : conj (conj z) = z := by
  apply GZ.eq_of
  · rfl
  · show - -z.im = z.im
    rw [Int.neg_neg]

/-- …and its order is exactly 2, not 1: it moves `i`. -/
theorem conj_ne_id : conj I ≠ I := by decide

/-! ### 3.  The near-miss `fakeMirror` is additive, fixes `re`, and is NOT
     multiplicative.  All three, because the seed's docstring claims all three. -/

theorem fakeMirror_re (z : GZ) : (fakeMirror z).re = z.re := rfl

theorem fakeMirror_add (z w : GZ) : fakeMirror (add z w) = add (fakeMirror z) (fakeMirror w) := by
  apply GZ.eq_of
  · rfl
  · show 2 * (z.im + w.im) = 2 * z.im + 2 * w.im
    omega

/-- **The witness.**  `fakeMirror` fails multiplicativity at `(i, i)`:
    `fakeMirror (i·i) = -1` but `fakeMirror i · fakeMirror i = -4`. -/
theorem fakeMirror_witness : fakeMirror (mul I I) ≠ mul (fakeMirror I) (fakeMirror I) := by decide

/-- **`fakeMirror` is not multiplicative.** -/
theorem fakeMirror_not_mul :
    ¬ (∀ z w : GZ, fakeMirror (mul z w) = mul (fakeMirror z) (fakeMirror w)) :=
  fun h => fakeMirror_witness (h I I)

/-! ### 4.  The sign is load-bearing: `splitMul` has zero divisors, `mul` does not
     have them at the same witness. -/

/-- **The witness.**  `(1+j)(1−j) = 0` in the split-complex multiplication. -/
theorem splitMul_witness : splitMul ⟨1, 1⟩ ⟨1, -1⟩ = zero := by decide

theorem splitMul_witness_left_ne : (⟨1, 1⟩ : GZ) ≠ zero := by decide

theorem splitMul_witness_right_ne : (⟨1, -1⟩ : GZ) ≠ zero := by decide

/-- **`splitMul` has zero divisors.** -/
theorem splitMul_has_zero_divisors :
    ∃ z w : GZ, z ≠ zero ∧ w ≠ zero ∧ splitMul z w = zero :=
  ⟨⟨1, 1⟩, ⟨1, -1⟩, splitMul_witness_left_ne, splitMul_witness_right_ne, splitMul_witness⟩

/-- The same pair under the true `mul` gives `2`, not `0` — so the failure above
    is a fact about the SIGN, not about the pair. -/
theorem mul_at_splitMul_witness : mul ⟨1, 1⟩ ⟨1, -1⟩ = ⟨2, 0⟩ := by decide

theorem mul_at_splitMul_witness_ne : mul ⟨1, 1⟩ ⟨1, -1⟩ ≠ zero := by decide

/-! ### 5.  On units, `conj` IS inversion.  Proved for each of the four units
     explicitly, as charged. -/

theorem conj_inv_one : mul one (conj one) = one := by decide

theorem conj_inv_I : mul I (conj I) = one := by decide

theorem conj_inv_negOne : mul (neg one) (conj (neg one)) = one := by decide

theorem conj_inv_negI : mul (neg I) (conj (neg I)) = one := by decide

/-- The four units, listed, with `conj` as the inverse in each case. -/
theorem conj_inv_units (u : GZ) (h : u = one ∨ u = I ∨ u = neg one ∨ u = neg I) :
    mul u (conj u) = one := by
  cases h with
  | inl h => subst h; exact conj_inv_one
  | inr h => cases h with
    | inl h => subst h; exact conj_inv_I
    | inr h => cases h with
      | inl h => subst h; exact conj_inv_negOne
      | inr h => subst h; exact conj_inv_negI

/-- `conj u` is literally the multiplicative partner `IsUnit` asks for. -/
theorem isUnit_of_mul_conj {u : GZ} (h : mul u (conj u) = one) : IsUnit u := ⟨conj u, h⟩

theorem isUnit_one : IsUnit one := isUnit_of_mul_conj conj_inv_one
theorem isUnit_I : IsUnit I := isUnit_of_mul_conj conj_inv_I
theorem isUnit_negOne : IsUnit (neg one) := isUnit_of_mul_conj conj_inv_negOne
theorem isUnit_negI : IsUnit (neg I) := isUnit_of_mul_conj conj_inv_negI

/-- The four units have norm 1, as `Z[i]^×` requires.  (This does not claim they
    are the ONLY units — that needs a norm argument this core does not build.) -/
theorem norm_units :
    norm one = 1 ∧ norm I = 1 ∧ norm (neg one) = 1 ∧ norm (neg I) = 1 := by decide

/-! ### 6.  The pentagon, decided by the kernel. -/

/-- **The pentagon holds at `f = 1`.**  `pentOK one` is a closed `Bool`; `decide`
    forces the kernel to evaluate it, and `pentOK_sound` carries the verdict to
    the `Prop`. -/
theorem pentagon_at_one : pentagonHolds one := pentOK_sound (by decide)

/-- **The pentagon holds at `f = −1`.** -/
theorem pentagon_at_negOne : pentagonHolds (neg one) := pentOK_sound (by decide)

/-- **The pentagon FAILS at `f = i`**, and the kernel says so: at the top label
    assignment `(1,1,1,1)` the left side is `−1` and the right side is `1`. -/
theorem pentagon_fails_at_I_witness : pentLhs I 1 1 1 1 ≠ pentRhs I 1 1 1 1 := by decide

theorem pentagon_fails_at_I : ¬ pentagonHolds I := fun h =>
  pentagon_fails_at_I_witness (h 1 1 1 1 (Or.inr rfl) (Or.inr rfl) (Or.inr rfl) (Or.inr rfl))

/-- The same refutation through the bridge, so the bridge's `false` branch is
    exercised too and not merely asserted. -/
theorem pentagon_fails_at_I' : ¬ pentagonHolds I :=
  not_pentagonHolds_of_pentOK_false (by decide)

/-- It fails at `f = −i` as well. -/
theorem pentagon_fails_at_negI : ¬ pentagonHolds (neg I) :=
  not_pentagonHolds_of_pentOK_false (by decide)

/-- And at `f = 0`, which is the sanity check that `pentOK` is not vacuously true:
    if it returned `true` on everything, this would be unprovable. -/
theorem pentagon_fails_at_zero : ¬ pentagonHolds zero :=
  not_pentagonHolds_of_pentOK_false (by decide)

/-- The literal computation the two theorems above rest on, exposed so the report
    can quote a `Bool` rather than a claim. -/
theorem pentOK_values :
    pentOK one = true ∧ pentOK (neg one) = true ∧
    pentOK I = false ∧ pentOK (neg I) = false ∧ pentOK zero = false := by decide

/-! ### 7.  The general-symbol pentagon, decided by the kernel. -/

/-- `Fgen (sliceCore f)` is `Fs f` — on the nose, by `rfl`.  This is the seed's own
    remark ("`Fs` is one of these") made into kernel evidence. -/
theorem Fgen_sliceCore (f : GZ) (a b c d x y : Int) :
    Fgen (sliceCore f) a b c d x y = Fs f a b c d x y := rfl

/-- Consequently the general pentagon at `sliceCore f` and the special pentagon at
    `f` are the SAME proposition, definitionally. -/
theorem genPentagonHolds_sliceCore (f : GZ) :
    genPentagonHolds (sliceCore f) ↔ pentagonHolds f := Iff.rfl

/-- The eight-value presentation of `sliceCore` agrees with `sliceCore` at every
    integer triple, not merely on the labels. -/
theorem symOfValues_sliceValues (f : GZ) (a b c : Int) :
    symOfValues (sliceValues f) a b c = sliceCore f a b c := by
  show (if boolOf a && boolOf b && boolOf c then f else one)
      = (if a = 1 ∧ b = 1 ∧ c = 1 then f else one)
  unfold boolOf
  by_cases ha : a = 1
  · by_cases hb : b = 1
    · by_cases hc : c = 1
      · simp [ha, hb, hc]
      · simp [ha, hb, hc]
    · simp [ha, hb]
  · simp [ha]

/-- **The general pentagon holds for the boson**, `F = sliceCore 1`, decided over
    its eight values. -/
theorem genPentagon_boson : genPentagonHolds (symOfValues (sliceValues one)) :=
  genPentOK_sound (by decide)

/-- **The general pentagon holds for the fermion**, `F = sliceCore (−1)`. -/
theorem genPentagon_fermion : genPentagonHolds (symOfValues (sliceValues (neg one))) :=
  genPentOK_sound (by decide)

/-- **And it fails at `F = sliceCore i`** — the eight-value bridge refutes as well
    as it confirms. -/
theorem genPentagon_fails_I : ¬ genPentagonHolds (symOfValues (sliceValues I)) :=
  not_genPentagonHolds_of_false (by decide)

/-- The seed calls `twistedBoson` "a pentagon-satisfying unit-valued symbol that is
    NOT in the slice".  The kernel confirms the pentagon half. -/
theorem genPentagon_twistedBoson : genPentagonHolds twistedBoson :=
  genPentOKF_sound (by decide)

/-- …and it is genuinely not in the slice: `sliceCore f` is `one` at `(0,0,1)` for
    EVERY `f`, and `twistedBoson` is `−i` there. -/
theorem sliceCore_at_001 (f : GZ) : sliceCore f 0 0 1 = one := rfl

theorem twistedBoson_not_slice (f : GZ) : twistedBoson 0 0 1 ≠ sliceCore f 0 0 1 := by
  rw [sliceCore_at_001]
  decide

/-- The seed calls `fakeCocycle` "a unit-valued symbol that does NOT satisfy the
    pentagon".  The kernel confirms that. -/
theorem genPentagon_fails_fakeCocycle : ¬ genPentagonHolds fakeCocycle :=
  not_genPentagonHolds_of_false (by decide)

/-- The values behind the four verdicts above, exposed. -/
theorem genPentOKF_values :
    genPentOKF (sliceCore one) = true ∧
    genPentOKF (sliceCore (neg one)) = true ∧
    genPentOKF (sliceCore I) = false ∧
    genPentOKF twistedBoson = true ∧
    genPentOKF fakeCocycle = false := by decide

/-! ### 8.  Non-vacuity.  A theorem whose hypotheses cannot be met is worse than no
     theorem, so each predicate the core defines is shown inhabited (or shown
     refutable, where that is the point). -/

/-- `sliceCore one` is constantly `one`. -/
theorem sliceCore_one_const (a b c : Int) : sliceCore one a b c = one := by
  unfold sliceCore
  by_cases h : a = 1 ∧ b = 1 ∧ c = 1
  · rw [if_pos h]
  · rw [if_neg h]

theorem sliceCore_one_isUnit (a b c : Int) : IsUnit (sliceCore one a b c) := by
  rw [sliceCore_one_const]; exact isUnit_one

theorem sliceCore_negOne_isUnit (a b c : Int) : IsUnit (sliceCore (neg one) a b c) := by
  unfold sliceCore
  by_cases h : a = 1 ∧ b = 1 ∧ c = 1
  · rw [if_pos h]; exact isUnit_negOne
  · rw [if_neg h]; exact isUnit_one

/-- **`IsClassifiedSymbol` is inhabited** — twice.  Without this the whole
    `Dom`/`Classes` layer would quotient the empty type and every later statement
    about it would be vacuous. -/
theorem isClassifiedSymbol_boson : IsClassifiedSymbol (sliceCore one) :=
  ⟨sliceCore_one_isUnit, (genPentagonHolds_sliceCore one).mpr pentagon_at_one⟩

theorem isClassifiedSymbol_fermion : IsClassifiedSymbol (sliceCore (neg one)) :=
  ⟨sliceCore_negOne_isUnit, (genPentagonHolds_sliceCore (neg one)).mpr pentagon_at_negOne⟩

/-- …and it is not everything: `sliceCore I` is unit-valued but fails the pentagon,
    so `IsClassifiedSymbol` is a real restriction. -/
theorem not_isClassifiedSymbol_I : ¬ IsClassifiedSymbol (sliceCore I) := fun h =>
  not_genPentagonHolds_of_false (by decide) h.2

/-- The hypotheses of `hexagonHolds` are simultaneously satisfiable — the two
    label constraints on `d` are the same constraint, `(a+b+c) % 2`, so the
    quantifier is not empty. -/
theorem hexagon_hypotheses_satisfiable :
    ∃ a b c d : Int, (a = 0 ∨ a = 1) ∧ (b = 0 ∨ b = 1) ∧ (c = 0 ∨ c = 1) ∧ (d = 0 ∨ d = 1) ∧
      d = ((a + b) % 2 + c) % 2 ∧ d = ((a + c) % 2 + b) % 2 :=
  ⟨1, 1, 1, 1, Or.inr rfl, Or.inr rfl, Or.inr rfl, Or.inr rfl, by decide, by decide⟩

/-- `SelfInverse` is inhabited and is a real restriction.  (`SelfInverse` is a `def`
    wrapping a `Prop`, and instance synthesis does not unfold it, so each proof
    `show`s the underlying equation before handing it to `decide`.) -/
theorem selfInverse_one : SelfInverse one := by show mul one one = one; decide
theorem selfInverse_negOne : SelfInverse (neg one) := by
  show mul (neg one) (neg one) = one; decide
theorem not_selfInverse_I : ¬ SelfInverse I := by show ¬ (mul I I = one); decide

/-- `GaugeEquivOnLabels` is reflexive at the trivial gauge, so it is inhabited.
    (Only the instance is claimed here; the general reflexivity lemma belongs to
    the layer this core does not build.) -/
theorem gaugeTrivial_isUnit (a b : Int) : IsUnit (gaugeTrivial a b) := isUnit_one

theorem gaugeAct_trivial (F : Int → Int → Int → GZ) (a b c : Int) :
    gaugeAct gaugeTrivial F a b c = mul (F a b c) one := rfl

/-! ### 9.  The antisymmetriser block computes. -/

theorem traceM_3 : traceM 3 = 6 := by decide
theorem traceM_4 : traceM 4 = 12 := by decide
theorem upTo_3 : upTo 3 = [0, 1, 2] := by decide
theorem upperPairs_3 : upperPairs 3 = [(0, 1), (0, 2), (1, 2)] := by decide

/-- `tr(I − swap)` on `[0,m)²` counts the antisymmetric basis twice: `m² − m`. -/
theorem traceM_eq_twice_upperPairs_3 : traceM 3 = 2 * (upperPairs 3).length := by decide
theorem traceM_eq_twice_upperPairs_4 : traceM 4 = 2 * (upperPairs 4).length := by decide

/-- **`eDiff` is antisymmetric in its two labels** — `e_ab − e_ba = −(e_ba − e_ab)`,
    which is what makes `antiM` an antisymmetriser rather than just a difference. -/
theorem eDiff_antisym (a b i j : Nat) : eDiff a b i j = - eDiff b a i j := by
  show (if i = a ∧ j = b then (1:Int) else 0) - (if j = a ∧ i = b then (1:Int) else 0)
      = -((if i = b ∧ j = a then (1:Int) else 0) - (if j = b ∧ i = a then (1:Int) else 0))
  by_cases h1 : i = a <;> by_cases h2 : j = b <;> by_cases h3 : j = a <;> by_cases h4 : i = b <;>
    simp_all

/-- …so the diagonal generators vanish: `e_aa − e_aa = 0`. -/
theorem eDiff_diag (a i j : Nat) : eDiff a a i j = 0 := by
  show (if i = a ∧ j = a then (1:Int) else 0) - (if j = a ∧ i = a then (1:Int) else 0) = 0
  by_cases h1 : i = a <;> by_cases h2 : j = a <;> simp_all

/-- A concrete generator, computed by the kernel. -/
theorem eDiff_01 : eDiff 0 1 0 1 = 1 ∧ eDiff 0 1 1 0 = -1 ∧ eDiff 0 1 0 0 = 0 := by decide

/-! ### 10.  Axiom audit — EVERY theorem in this file, not a curated sample.

     These print to stdout and are not part of the exit code, but they are how a
     reader checks that nothing was smuggled in.  What the audit shows, as run:

       * `sorryAx` appears ZERO times.  Nothing here is stubbed.
       * `Classical.choice` appears ZERO times.  Every `by_cases` in this file
         found a `Decidable` instance and used `Decidable.byCases`; the file is
         constructive.
       * 77 of the 83 theorems depend on NO axioms whatsoever.
       * Six depend on `propext`, which `rw` and `simp_all` introduce:
         `conj_mul`, `conj_add`, `fakeMirror_add`, `eDiff_antisym`, `eDiff_diag`,
         `symOfValues_sliceValues`.
       * One, `fakeMirror_add`, additionally touches `Quot.sound` (by way of
         `omega`).

     `propext` and `Quot.sound` are the two standard axioms of Lean's core logic,
     not escape hatches; `sorryAx` is the escape hatch, and it is absent. -/

#print axioms GZ.eq_of
#print axioms band_left
#print axioms band_right
#print axioms allBool_sound
#print axioms allBool_complete
#print axioms lab_isLabel
#print axioms exists_bool_of_isLabel
#print axioms pentOK_sound
#print axioms pentOK_complete
#print axioms pentOK_iff
#print axioms not_pentagonHolds_of_pentOK_false
#print axioms genPentOKF_sound
#print axioms genPentOKF_complete
#print axioms genPentOKF_iff
#print axioms not_genPentagonHolds_of_false
#print axioms genPentOK_iff
#print axioms genPentOK_sound
#print axioms conj_mul
#print axioms conj_add
#print axioms conj_one
#print axioms conj_conj
#print axioms conj_ne_id
#print axioms fakeMirror_re
#print axioms fakeMirror_add
#print axioms fakeMirror_witness
#print axioms fakeMirror_not_mul
#print axioms splitMul_witness
#print axioms splitMul_witness_left_ne
#print axioms splitMul_witness_right_ne
#print axioms splitMul_has_zero_divisors
#print axioms mul_at_splitMul_witness
#print axioms mul_at_splitMul_witness_ne
#print axioms conj_inv_one
#print axioms conj_inv_I
#print axioms conj_inv_negOne
#print axioms conj_inv_negI
#print axioms conj_inv_units
#print axioms isUnit_of_mul_conj
#print axioms isUnit_one
#print axioms isUnit_I
#print axioms isUnit_negOne
#print axioms isUnit_negI
#print axioms norm_units
#print axioms pentagon_at_one
#print axioms pentagon_at_negOne
#print axioms pentagon_fails_at_I_witness
#print axioms pentagon_fails_at_I
#print axioms pentagon_fails_at_I'
#print axioms pentagon_fails_at_negI
#print axioms pentagon_fails_at_zero
#print axioms pentOK_values
#print axioms Fgen_sliceCore
#print axioms genPentagonHolds_sliceCore
#print axioms symOfValues_sliceValues
#print axioms genPentagon_boson
#print axioms genPentagon_fermion
#print axioms genPentagon_fails_I
#print axioms genPentagon_twistedBoson
#print axioms sliceCore_at_001
#print axioms twistedBoson_not_slice
#print axioms genPentagon_fails_fakeCocycle
#print axioms genPentOKF_values
#print axioms sliceCore_one_const
#print axioms sliceCore_one_isUnit
#print axioms sliceCore_negOne_isUnit
#print axioms isClassifiedSymbol_boson
#print axioms isClassifiedSymbol_fermion
#print axioms not_isClassifiedSymbol_I
#print axioms hexagon_hypotheses_satisfiable
#print axioms selfInverse_one
#print axioms selfInverse_negOne
#print axioms not_selfInverse_I
#print axioms gaugeTrivial_isUnit
#print axioms gaugeAct_trivial
#print axioms traceM_3
#print axioms traceM_4
#print axioms upTo_3
#print axioms upperPairs_3
#print axioms traceM_eq_twice_upperPairs_3
#print axioms traceM_eq_twice_upperPairs_4
#print axioms eDiff_antisym
#print axioms eDiff_diag
#print axioms eDiff_01
