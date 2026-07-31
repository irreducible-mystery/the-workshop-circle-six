/-
  C6_ActionA.lean — READING A: twist the cohomology, leave the pentagon alone.

  SELF-CONTAINED.  No imports.  Part I is copied verbatim from `lean/C6_SEED.lean`
  (by way of `lean/C6_Core.lean`, whose Part I is the seed verbatim); Part II is the
  decidability bridge, also copied from `C6_Core.lean`.  Duplication across files is
  deliberate: this file is checked on its own.

  THE CHARGE.  Define the sigma-twisted differentials on RAW Z[i]-valued cochains,
  in the seed's own label arithmetic (`d2raw` style).  `act` is the Galois action of
  Z_2 = Gal(Q(i)/Q) on the coefficients A = Z[i]^x, i.e. conjugation, which on units
  is inversion.  The seed's `pentLhs`/`pentRhs` contain no `conj`, so the pentagon is
  UNCHANGED by the twist.  Question: is  {f : pentagon holds} = {f : d3sig f = 1}?

  THE ANSWER, decided by the kernel: NO, and not in either direction.  See
  `pentagon_is_not_sigma_cocycles` and the two witnesses either side of it.

  DISCIPLINE.  No `sorry`, no `admit`, no `axiom`, no `native_decide`, no
  `@[implemented_by]`.  Every `decide` in this file is a kernel `decide`.  There is a
  full axiom audit of every theorem at the foot of the file.
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

/-- The domain the sealed classification speaks about, reified as a
    predicate: unit-valued and pentagon-satisfying. These are exactly the
    two hypotheses `at_most_two_classes` carries on its free variable. -/
def IsClassifiedSymbol (F : Int → Int → Int → GZ) : Prop :=
  (∀ a b c : Int, IsUnit (F a b c)) ∧ genPentagonHolds F

/-! ############################################################################
    PART II — the decidability bridge (copied from `C6_Core.lean`, Part II).
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

/-- New here: `allBool` respects pointwise equality of the predicates.  Every
    "these two decision procedures agree" theorem below goes through this. -/
theorem allBool_congr {p q : Bool → Bool} (h : ∀ b : Bool, p b = q b) :
    allBool p = allBool q := by
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

/-! ### The pentagon bridge, for the seal's slice symbol `Fs f`. -/

def pentAt (f : GZ) (a b c d : Bool) : Bool :=
  decide (pentLhs f (lab a) (lab b) (lab c) (lab d)
        = pentRhs f (lab a) (lab b) (lab c) (lab d))

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

theorem pentOK_iff (f : GZ) : pentOK f = true ↔ pentagonHolds f :=
  Iff.intro pentOK_sound pentOK_complete

theorem not_pentagonHolds_of_pentOK_false {f : GZ} (h : pentOK f = false) :
    ¬ pentagonHolds f := fun hp => Bool.noConfusion (h ▸ pentOK_complete hp)

/-! ### The same bridge for a general symbol. -/

def genPentAt (F : Int → Int → Int → GZ) (a b c d : Bool) : Bool :=
  decide (genPentLhs F (lab a) (lab b) (lab c) (lab d)
        = genPentRhs F (lab a) (lab b) (lab c) (lab d))

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

def symOfValues (v : Bool → Bool → Bool → GZ) : Int → Int → Int → GZ :=
  fun a b c => v (boolOf a) (boolOf b) (boolOf c)

/-! ############################################################################
    PART III — Circle Six, Reading A: the sigma-twisted differentials.

    `act` is the Galois action of the index group Z_2 on the coefficients.  On
    UNITS, `conj` is inversion, so `act 1` is inversion — this is the coefficient
    module A = Z[i]^x with sigma acting nontrivially, and the two differentials
    below are the trivial-action and nontrivial-action differentials of the
    inhomogeneous bar complex, written in the seed's own label arithmetic.
    ############################################################################ -/

/-- **The Galois action**, on the labels: the nontrivial element of `Z_2`
    (the label `1`) acts by `conj`; the identity label `0` acts trivially. -/
def act (a : Int) (x : GZ) : GZ := if a = 1 then conj x else x

/-- `d^2` with sigma on the LEADING face — the same alternating shape as the
    seed's `d2raw`, with `act a` applied to the leading term. -/
def d2sig (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (act a (g b c)) (conj (g ((a + b) % 2) c))) (mul (g a ((b + c) % 2)) (conj (g a b)))

/-- `d^3` in raw form, shaped exactly as the seed's `d3` is shaped: the same
    nesting, with `conj` for `Un.inv'` and `(x+y)%2` for `xor`.  This is the
    UNTWISTED differential, and it is the control for everything below. -/
def d3raw (f : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  mul (mul (mul (f b c d) (conj (f ((a + b) % 2) c d)))
           (mul (f a ((b + c) % 2) d) (conj (f a b ((c + d) % 2)))))
      (f a b c)

/-- **`d^3` with sigma on the leading face.**  The only change from `d3raw` is
    `act a` on `f b c d`; nothing else moves. -/
def d3sig (f : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  mul (mul (mul (act a (f b c d)) (conj (f ((a + b) % 2) c d)))
           (mul (f a ((b + c) % 2) d) (conj (f a b ((c + d) % 2)))))
      (f a b c)

/-- The untwisted 3-cocycle condition, at every label assignment. -/
def D3RawTrivial (F : Int → Int → Int → GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → d3raw F a b c d = one

/-- **The sigma-twisted 3-cocycle condition**, at every label assignment.  This
    is the set the charge asks about. -/
def D3SigTrivial (F : Int → Int → Int → GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → d3sig F a b c d = one

/-! ### The decision procedures, with both halves of the reflection. -/

def d3rawAt (F : Int → Int → Int → GZ) (a b c d : Bool) : Bool :=
  decide (d3raw F (lab a) (lab b) (lab c) (lab d) = one)

def d3rawOK (F : Int → Int → Int → GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d => d3rawAt F a b c d

def d3sigAt (F : Int → Int → Int → GZ) (a b c d : Bool) : Bool :=
  decide (d3sig F (lab a) (lab b) (lab c) (lab d) = one)

def d3sigOK (F : Int → Int → Int → GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d => d3sigAt F a b c d

theorem d3rawOK_sound {F : Int → Int → Int → GZ} (h : d3rawOK F = true) : D3RawTrivial F := by
  have key : ∀ A B C D : Bool, d3raw F (lab A) (lab B) (lab C) (lab D) = one := fun A B C D =>
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

theorem d3rawOK_complete {F : Int → Int → Int → GZ} (h : D3RawTrivial F) : d3rawOK F = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    allBool_complete fun D =>
      decide_eq_true
        (h (lab A) (lab B) (lab C) (lab D)
          (lab_isLabel A) (lab_isLabel B) (lab_isLabel C) (lab_isLabel D))

theorem d3rawOK_iff (F : Int → Int → Int → GZ) : d3rawOK F = true ↔ D3RawTrivial F :=
  Iff.intro d3rawOK_sound d3rawOK_complete

theorem not_D3RawTrivial_of_false {F : Int → Int → Int → GZ} (h : d3rawOK F = false) :
    ¬ D3RawTrivial F := fun hp => Bool.noConfusion (h ▸ d3rawOK_complete hp)

theorem d3sigOK_sound {F : Int → Int → Int → GZ} (h : d3sigOK F = true) : D3SigTrivial F := by
  have key : ∀ A B C D : Bool, d3sig F (lab A) (lab B) (lab C) (lab D) = one := fun A B C D =>
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

theorem d3sigOK_complete {F : Int → Int → Int → GZ} (h : D3SigTrivial F) : d3sigOK F = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    allBool_complete fun D =>
      decide_eq_true
        (h (lab A) (lab B) (lab C) (lab D)
          (lab_isLabel A) (lab_isLabel B) (lab_isLabel C) (lab_isLabel D))

theorem d3sigOK_iff (F : Int → Int → Int → GZ) : d3sigOK F = true ↔ D3SigTrivial F :=
  Iff.intro d3sigOK_sound d3sigOK_complete

theorem not_D3SigTrivial_of_false {F : Int → Int → Int → GZ} (h : d3sigOK F = false) :
    ¬ D3SigTrivial F := fun hp => Bool.noConfusion (h ▸ d3sigOK_complete hp)

/-! ############################################################################
    PART IV — closed forms.  The seed's pentagon, reduced.

    Every one of these is proved by `cases` on the four Bools and then `rfl`:
    the admissibility `if`s of `Fgen` all fire on the positive branch at every
    label assignment, and `(x+y) % 2` is `xor`.  Nothing is being asserted; the
    kernel is doing the reduction.
    ############################################################################ -/

theorem boolOf_lab (a : Bool) : boolOf (lab a) = a := by cases a <;> rfl

theorem symOfValues_lab (v : Bool → Bool → Bool → GZ) (a b c : Bool) :
    symOfValues v (lab a) (lab b) (lab c) = v a b c := by
  cases a <;> cases b <;> cases c <;> rfl

/-- **The pentagon's left side IS the 3-cocycle's left side.**  No `zero` branch
    is ever taken and every `% 2` is an `xor`. -/
theorem genPentLhs_lab (F : Int → Int → Int → GZ) (a b c d : Bool) :
    genPentLhs F (lab a) (lab b) (lab c) (lab d)
      = mul (mul (F (lab a) (lab b) (lab c)) (F (lab a) (lab (xor b c)) (lab d)))
            (F (lab b) (lab c) (lab d)) := by
  cases a <;> cases b <;> cases c <;> cases d <;> rfl

/-- **…and the right side is the 3-cocycle's right side.**  Together with the
    previous theorem: the seal's pentagon at `(a,b,c,d)` is exactly
    `F(a,b,c)·F(a,bc,d)·F(b,c,d) = F(ab,c,d)·F(a,b,cd)`. -/
theorem genPentRhs_lab (F : Int → Int → Int → GZ) (a b c d : Bool) :
    genPentRhs F (lab a) (lab b) (lab c) (lab d)
      = mul (F (lab (xor a b)) (lab c) (lab d)) (F (lab a) (lab b) (lab (xor c d))) := by
  cases a <;> cases b <;> cases c <;> cases d <;> rfl

theorem d3raw_lab (F : Int → Int → Int → GZ) (a b c d : Bool) :
    d3raw F (lab a) (lab b) (lab c) (lab d)
      = mul (mul (mul (F (lab b) (lab c) (lab d)) (conj (F (lab (xor a b)) (lab c) (lab d))))
                 (mul (F (lab a) (lab (xor b c)) (lab d))
                      (conj (F (lab a) (lab b) (lab (xor c d))))))
            (F (lab a) (lab b) (lab c)) := by
  cases a <;> cases b <;> cases c <;> cases d <;> rfl

theorem d3sig_lab (F : Int → Int → Int → GZ) (a b c d : Bool) :
    d3sig F (lab a) (lab b) (lab c) (lab d)
      = mul (mul (mul (cond a (conj (F (lab b) (lab c) (lab d))) (F (lab b) (lab c) (lab d)))
                      (conj (F (lab (xor a b)) (lab c) (lab d))))
                 (mul (F (lab a) (lab (xor b c)) (lab d))
                      (conj (F (lab a) (lab b) (lab (xor c d))))))
            (F (lab a) (lab b) (lab c)) := by
  cases a <;> cases b <;> cases c <;> cases d <;> rfl

/-- The twist is INVISIBLE at the identity label: `d3sig` and `d3raw` are the
    same function there, on the nose. -/
theorem d3sig_eq_d3raw_at_zero (F : Int → Int → Int → GZ) (b c d : Int) :
    d3sig F 0 b c d = d3raw F 0 b c d := rfl

/-- …and it is a real twist at the other label. -/
theorem act_zero (x : GZ) : act 0 x = x := rfl
theorem act_one (x : GZ) : act 1 x = conj x := rfl
theorem act_one_ne_id : act 1 I ≠ I := by decide

/-! ### Why the seal cannot see the twist: on the `±1` slice it is the identity. -/

/-- **The twist is invisible on real units.**  If `F` only ever takes the values
    `1` and `−1` — which is exactly where the seal's two classes live — then the
    twisted and untwisted differentials are literally the same function.  This is
    why the separation below has to be found at `±i` and nowhere else. -/
theorem d3sig_eq_d3raw_of_real (F : Int → Int → Int → GZ)
    (h : ∀ b c d : Int, F b c d = one ∨ F b c d = neg one) (a b c d : Int) :
    d3sig F a b c d = d3raw F a b c d := by
  show mul (mul (mul (act a (F b c d)) _) _) _ = mul (mul (mul (F b c d) _) _) _
  have hact : act a (F b c d) = F b c d := by
    unfold act
    cases h b c d with
    | inl he => by_cases ha : a = 1
                · rw [if_pos ha, he]; rfl
                · rw [if_neg ha]
    | inr he => by_cases ha : a = 1
                · rw [if_pos ha, he]; rfl
                · rw [if_neg ha]
  rw [hact]

/-! ############################################################################
    PART V — THE SLICE.  The fast answer, over the four units the seal uses.
    ############################################################################ -/

/-- The seal's own verdict on the slice: the pentagon holds at `1` and `−1`
    and fails at `i` and `−i`.  (Rediscovered here, not imported.) -/
theorem slice_pentagon_values :
    genPentOKF (sliceCore one) = true ∧
    genPentOKF (sliceCore (neg one)) = true ∧
    genPentOKF (sliceCore I) = false ∧
    genPentOKF (sliceCore (neg I)) = false := by decide

/-- The untwisted differential agrees with the pentagon on the whole slice —
    the control.  Same four verdicts, in the same order. -/
theorem slice_d3raw_values :
    d3rawOK (sliceCore one) = true ∧
    d3rawOK (sliceCore (neg one)) = true ∧
    d3rawOK (sliceCore I) = false ∧
    d3rawOK (sliceCore (neg I)) = false := by decide

/-- **THE SLICE ANSWER.**  The sigma-twisted differential is trivial at ALL FOUR
    units — including the two where the pentagon fails.  The seal's own
    four-element family already separates the two conditions. -/
theorem slice_d3sig_values :
    d3sigOK (sliceCore one) = true ∧
    d3sigOK (sliceCore (neg one)) = true ∧
    d3sigOK (sliceCore I) = true ∧
    d3sigOK (sliceCore (neg I)) = true := by decide

/-! ############################################################################
    PART VI — THE SEPARATING WITNESSES, both directions.
    ############################################################################ -/

/-! ### Witness 1: `sliceCore I` — a sigma-cocycle that is not a pentagon. -/

/-- The eight values of the witness, computed by the kernel:
    `F(1,1,1) = i` and `F = 1` at the other seven label triples. -/
theorem witness1_values :
    sliceCore I 0 0 0 = one ∧ sliceCore I 0 0 1 = one ∧ sliceCore I 0 1 0 = one ∧
    sliceCore I 0 1 1 = one ∧ sliceCore I 1 0 0 = one ∧ sliceCore I 1 0 1 = one ∧
    sliceCore I 1 1 0 = one ∧ sliceCore I 1 1 1 = I := by decide

theorem witness1_isUnit (a b c : Int) : IsUnit (sliceCore I a b c) := by
  unfold sliceCore
  by_cases h : a = 1 ∧ b = 1 ∧ c = 1
  · rw [if_pos h]; exact ⟨neg I, by decide⟩
  · rw [if_neg h]; exact ⟨one, by decide⟩

/-- **The witness satisfies the sigma-twisted cocycle condition.** -/
theorem witness1_sig : D3SigTrivial (sliceCore I) := d3sigOK_sound (by decide)

/-- **…and it fails the pentagon.** -/
theorem witness1_not_pentagon : ¬ genPentagonHolds (sliceCore I) :=
  not_genPentagonHolds_of_false (by decide)

/-- The single label assignment that does it, with both sides printed:
    at `(1,1,1,1)` the pentagon's two sides are `−1` and `1`. -/
theorem witness1_pentagon_failure :
    genPentLhs (sliceCore I) 1 1 1 1 = neg one ∧
    genPentRhs (sliceCore I) 1 1 1 1 = one := by decide

/-- The same assignment through the two differentials: the twist turns `−1`
    into `1`.  This is the whole mechanism, in one line of arithmetic. -/
theorem witness1_mechanism :
    d3raw (sliceCore I) 1 1 1 1 = neg one ∧
    d3sig (sliceCore I) 1 1 1 1 = one := by decide

/-! ### Witness 2: `twistedBoson` — a pentagon that is not a sigma-cocycle. -/

/-- The eight values of the second witness. -/
theorem witness2_values :
    twistedBoson 0 0 0 = one ∧ twistedBoson 0 0 1 = neg I ∧ twistedBoson 0 1 0 = one ∧
    twistedBoson 0 1 1 = I ∧ twistedBoson 1 0 0 = one ∧ twistedBoson 1 0 1 = neg I ∧
    twistedBoson 1 1 0 = one ∧ twistedBoson 1 1 1 = I := by decide

theorem witness2_isUnit (a b c : Int) : IsUnit (twistedBoson a b c) := by
  unfold twistedBoson
  by_cases hc : c = 1
  · rw [if_pos hc]
    by_cases hb : b = 1
    · rw [if_pos hb]; exact ⟨neg I, by decide⟩
    · rw [if_neg hb]; exact ⟨I, by decide⟩
  · rw [if_neg hc]; exact ⟨one, by decide⟩

/-- **The second witness satisfies the pentagon.** -/
theorem witness2_pentagon : genPentagonHolds twistedBoson := genPentOKF_sound (by decide)

/-- …and satisfies the UNTWISTED cocycle condition too — the control that the
    pentagon really is `d3raw = 1` here, so the failure below is the twist's. -/
theorem witness2_raw : D3RawTrivial twistedBoson := d3rawOK_sound (by decide)

/-- **…and it FAILS the sigma-twisted cocycle condition.** -/
theorem witness2_not_sig : ¬ D3SigTrivial twistedBoson := not_D3SigTrivial_of_false (by decide)

/-- The label assignment that does it, printed: `d3raw` gives `1` there and
    `d3sig` gives `−1`. -/
theorem witness2_mechanism :
    d3raw twistedBoson 1 1 1 1 = one ∧
    d3sig twistedBoson 1 1 1 1 = neg one := by decide

/-! ### The verdict. -/

/-- **THE ANSWER TO READING A.**  Twisting the differential by the Galois action
    while leaving the pentagon alone does NOT preserve the correspondence: the
    pentagon locus and the sigma-cocycle locus are different sets. -/
theorem pentagon_is_not_sigma_cocycles :
    ¬ (∀ F : Int → Int → Int → GZ, genPentagonHolds F ↔ D3SigTrivial F) := fun h =>
  witness1_not_pentagon ((h (sliceCore I)).mpr witness1_sig)

/-- Neither set contains the other.  Both witnesses are unit-valued, so this is
    not an artifact of admitting non-units. -/
theorem sigma_cocycles_not_subset_pentagon :
    ∃ F : Int → Int → Int → GZ,
      (∀ a b c : Int, IsUnit (F a b c)) ∧ D3SigTrivial F ∧ ¬ genPentagonHolds F :=
  ⟨sliceCore I, witness1_isUnit, witness1_sig, witness1_not_pentagon⟩

theorem pentagon_not_subset_sigma_cocycles :
    ∃ F : Int → Int → Int → GZ,
      (∀ a b c : Int, IsUnit (F a b c)) ∧ genPentagonHolds F ∧ ¬ D3SigTrivial F :=
  ⟨twistedBoson, witness2_isUnit, witness2_pentagon, witness2_not_sig⟩

/-- The intersection is not empty either — the seal's two classes are in it, so
    the separation is a genuine incomparability and not a disjointness. -/
theorem boson_in_both : genPentagonHolds (sliceCore one) ∧ D3SigTrivial (sliceCore one) :=
  ⟨genPentOKF_sound (by decide), d3sigOK_sound (by decide)⟩

theorem fermion_in_both :
    genPentagonHolds (sliceCore (neg one)) ∧ D3SigTrivial (sliceCore (neg one)) :=
  ⟨genPentOKF_sound (by decide), d3sigOK_sound (by decide)⟩

/-- And neither condition is vacuous: `fakeCocycle` fails both. -/
theorem fakeCocycle_fails_both :
    ¬ genPentagonHolds fakeCocycle ∧ ¬ D3SigTrivial fakeCocycle :=
  ⟨not_genPentagonHolds_of_false (by decide), not_D3SigTrivial_of_false (by decide)⟩

/-! ############################################################################
    PART VII — the coefficient group as `Z/4`, with a proven bridge to `Z[i]`.

    Everything above is about named symbols.  To sweep all 4^8 unit-valued
    symbols the kernel needs a cheap model of the coefficient group; `U4` is it,
    and `uval_umul`/`uval_uconj`/`decide_uval_eq` are what make a `U4` computation
    genuine evidence about `Z[i]`.  Nothing here is assumed: the bridge is proved
    in both directions, and `unit_is_four` shows the four values are ALL the units,
    so the sweep is exhaustive and not merely a sample.
    ############################################################################ -/

inductive U4 where
  | e0 | e1 | e2 | e3
deriving DecidableEq

/-- The four units of `Z[i]`, as a four-element type: `1, i, −1, −i`. -/
def uval : U4 → GZ
  | .e0 => one | .e1 => I | .e2 => neg one | .e3 => neg I

/-- Multiplication, as addition mod 4. -/
def umul : U4 → U4 → U4
  | .e0, y => y
  | .e1, .e0 => .e1 | .e1, .e1 => .e2 | .e1, .e2 => .e3 | .e1, .e3 => .e0
  | .e2, .e0 => .e2 | .e2, .e1 => .e3 | .e2, .e2 => .e0 | .e2, .e3 => .e1
  | .e3, .e0 => .e3 | .e3, .e1 => .e0 | .e3, .e2 => .e1 | .e3, .e3 => .e2

/-- Conjugation, as negation mod 4. -/
def uconj : U4 → U4
  | .e0 => .e0 | .e1 => .e3 | .e2 => .e2 | .e3 => .e1

theorem uval_umul (x y : U4) : uval (umul x y) = mul (uval x) (uval y) := by
  cases x <;> cases y <;> rfl

theorem uval_uconj (x : U4) : uval (uconj x) = conj (uval x) := by cases x <;> rfl

theorem uval_e0 : uval U4.e0 = one := rfl

/-- `uval` is injective, so a `U4` equality decides a `Z[i]` equality and back. -/
theorem decide_uval_eq (x y : U4) : decide (uval x = uval y) = decide (x = y) := by
  cases x <;> cases y <;> rfl

theorem uval_isUnit (x : U4) : IsUnit (uval x) :=
  ⟨uval (uconj x), by cases x <;> decide⟩

/-! ### The four values are exactly the units of `Z[i]`.

    Proved from `IsUnit` itself, not assumed: from `u·v = 1` the norm identity
    `N(u)·N(v) = 1` follows, hence `N(u) = 1`, hence `u.re, u.im ∈ {−1,0,1}`. -/

theorem sq_nonneg (a : Int) : 0 ≤ a * a := by
  rcases Int.le_total 0 a with h | h
  · exact Int.mul_nonneg h h
  · have h2 : 0 ≤ (-a) * (-a) := Int.mul_nonneg (by omega) (by omega)
    grind

theorem bound_of_sq_le_one {a : Int} (h : a * a ≤ 1) : -1 ≤ a ∧ a ≤ 1 := by
  have hn : ¬ (a ≤ -2) := fun hl => by
    have hm : 2 * (-a) ≤ (-a) * (-a) := Int.mul_le_mul_of_nonneg_right (by omega) (by omega)
    grind
  have hp : ¬ (2 ≤ a) := fun hr => by
    have hm : 2 * a ≤ a * a := Int.mul_le_mul_of_nonneg_right (by omega) (by omega)
    omega
  omega

/-- **The units of `Z[i]` are exactly `1, i, −1, −i`.**  This is what makes the
    4^8 sweep below exhaustive over unit-valued symbols. -/
theorem unit_is_four {u : GZ} (h : IsUnit u) :
    u = one ∨ u = I ∨ u = neg one ∨ u = neg I := by
  obtain ⟨v, hv⟩ := h
  have h1 : u.re * v.re - u.im * v.im = 1 := congrArg GZ.re hv
  have h2 : u.re * v.im + u.im * v.re = 0 := congrArg GZ.im hv
  have hprod : (u.re*u.re + u.im*u.im) * (v.re*v.re + v.im*v.im) = 1 := by grind
  have hN : u.re*u.re + u.im*u.im = 1 :=
    Int.eq_one_of_mul_eq_one_right
      (by have := sq_nonneg u.re; have := sq_nonneg u.im; omega) hprod
  have hb1 : u.re * u.re ≤ 1 := by have := sq_nonneg u.im; omega
  have hb2 : u.im * u.im ≤ 1 := by have := sq_nonneg u.re; omega
  obtain ⟨ha, ha'⟩ := bound_of_sq_le_one hb1
  obtain ⟨hb, hb'⟩ := bound_of_sq_le_one hb2
  have ca : u.re = -1 ∨ u.re = 0 ∨ u.re = 1 := by omega
  have cb : u.im = -1 ∨ u.im = 0 ∨ u.im = 1 := by omega
  rcases ca with hA|hA|hA <;> rcases cb with hB|hB|hB <;>
    rw [hA, hB] at hN <;>
    first
      | (exact absurd hN (by decide))
      | (exact Or.inl (GZ.eq_of (by rw [hA]; rfl) (by rw [hB]; rfl)))
      | (exact Or.inr (Or.inl (GZ.eq_of (by rw [hA]; rfl) (by rw [hB]; rfl))))
      | (exact Or.inr (Or.inr (Or.inl (GZ.eq_of (by rw [hA]; rfl) (by rw [hB]; rfl)))))
      | (exact Or.inr (Or.inr (Or.inr (GZ.eq_of (by rw [hA]; rfl) (by rw [hB]; rfl)))))

/-- The decoder, total on `GZ` and correct on the units. -/
def u4Of (u : GZ) : U4 :=
  if u = one then .e0 else if u = I then .e1 else if u = neg one then .e2 else .e3

theorem uval_u4Of {u : GZ} (h : IsUnit u) : uval (u4Of u) = u := by
  rcases unit_is_four h with h1|h1|h1|h1 <;> rw [h1] <;> decide

/-! ### The `U4` model of the two conditions, and the bridge. -/

def gzOf (v : Bool → Bool → Bool → U4) : Bool → Bool → Bool → GZ := fun a b c => uval (v a b c)

def upentL (v : Bool → Bool → Bool → U4) (a b c d : Bool) : U4 :=
  umul (umul (v a b c) (v a (xor b c) d)) (v b c d)

def upentR (v : Bool → Bool → Bool → U4) (a b c d : Bool) : U4 :=
  umul (v (xor a b) c d) (v a b (xor c d))

def ud3raw (v : Bool → Bool → Bool → U4) (a b c d : Bool) : U4 :=
  umul (umul (umul (v b c d) (uconj (v (xor a b) c d)))
             (umul (v a (xor b c) d) (uconj (v a b (xor c d)))))
       (v a b c)

def ud3sig (v : Bool → Bool → Bool → U4) (a b c d : Bool) : U4 :=
  umul (umul (umul (cond a (uconj (v b c d)) (v b c d)) (uconj (v (xor a b) c d)))
             (umul (v a (xor b c) d) (uconj (v a b (xor c d)))))
       (v a b c)

def upentOK (v : Bool → Bool → Bool → U4) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d =>
    decide (upentL v a b c d = upentR v a b c d)

def ud3rawOK (v : Bool → Bool → Bool → U4) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d =>
    decide (ud3raw v a b c d = U4.e0)

def ud3sigOK (v : Bool → Bool → Bool → U4) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d =>
    decide (ud3sig v a b c d = U4.e0)

theorem gzOf_lab (v : Bool → Bool → Bool → U4) (a b c : Bool) :
    symOfValues (gzOf v) (lab a) (lab b) (lab c) = uval (v a b c) := by
  rw [symOfValues_lab]; rfl

theorem genPentLhs_uval (v : Bool → Bool → Bool → U4) (a b c d : Bool) :
    genPentLhs (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d)
      = uval (upentL v a b c d) := by
  rw [genPentLhs_lab]
  simp only [gzOf_lab, upentL, uval_umul]

theorem genPentRhs_uval (v : Bool → Bool → Bool → U4) (a b c d : Bool) :
    genPentRhs (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d)
      = uval (upentR v a b c d) := by
  rw [genPentRhs_lab]
  simp only [gzOf_lab, upentR, uval_umul]

theorem d3raw_uval (v : Bool → Bool → Bool → U4) (a b c d : Bool) :
    d3raw (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d)
      = uval (ud3raw v a b c d) := by
  rw [d3raw_lab]
  simp only [gzOf_lab, ud3raw, uval_umul, uval_uconj]

theorem d3sig_uval (v : Bool → Bool → Bool → U4) (a b c d : Bool) :
    d3sig (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d)
      = uval (ud3sig v a b c d) := by
  rw [d3sig_lab]
  simp only [gzOf_lab, ud3sig]
  cases a <;> simp only [cond_true, cond_false, uval_umul, uval_uconj]

theorem upentOK_eq (v : Bool → Bool → Bool → U4) :
    upentOK v = genPentOKF (symOfValues (gzOf v)) := by
  unfold upentOK genPentOKF
  refine allBool_congr fun a => allBool_congr fun b => allBool_congr fun c =>
    allBool_congr fun d => ?_
  show decide (upentL v a b c d = upentR v a b c d)
      = decide (genPentLhs (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d)
              = genPentRhs (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d))
  rw [genPentLhs_uval, genPentRhs_uval, decide_uval_eq]

theorem ud3rawOK_eq (v : Bool → Bool → Bool → U4) :
    ud3rawOK v = d3rawOK (symOfValues (gzOf v)) := by
  unfold ud3rawOK d3rawOK
  refine allBool_congr fun a => allBool_congr fun b => allBool_congr fun c =>
    allBool_congr fun d => ?_
  show decide (ud3raw v a b c d = U4.e0)
      = decide (d3raw (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d) = one)
  rw [d3raw_uval, ← uval_e0, decide_uval_eq]

theorem ud3sigOK_eq (v : Bool → Bool → Bool → U4) :
    ud3sigOK v = d3sigOK (symOfValues (gzOf v)) := by
  unfold ud3sigOK d3sigOK
  refine allBool_congr fun a => allBool_congr fun b => allBool_congr fun c =>
    allBool_congr fun d => ?_
  show decide (ud3sig v a b c d = U4.e0)
      = decide (d3sig (symOfValues (gzOf v)) (lab a) (lab b) (lab c) (lab d) = one)
  rw [d3sig_uval, ← uval_e0, decide_uval_eq]

/-! ### The control: UNTWISTED, the pentagon and `d3 = 1` are the same condition.

    This is proved once and for all, for every unit-valued symbol, by deciding a
    5-variable identity in `Z/4` (4^5 = 1024 cases).  It is what makes the twisted
    failure above a fact about the TWIST and not about the transcription. -/

instance instDecidableForallU4 (p : U4 → Prop) [DecidablePred p] : Decidable (∀ x, p x) :=
  if h0 : p .e0 then
    if h1 : p .e1 then
      if h2 : p .e2 then
        if h3 : p .e3 then isTrue (fun x => by cases x <;> assumption)
        else isFalse (fun h => h3 (h _))
      else isFalse (fun h => h2 (h _))
    else isFalse (fun h => h1 (h _))
  else isFalse (fun h => h0 (h _))

/-- **The untwisted 3-cocycle equation IS the pentagon equation**, slot for slot,
    at every assignment of the five faces.  Decided over all 4^5 tuples of units. -/
theorem u4_cocycle_decide : ∀ p q r s t : U4,
    decide (umul (umul (umul r (uconj s)) (umul q (uconj t))) p = U4.e0)
      = decide (umul (umul p q) r = umul s t) := by decide

/-- **…and the sigma-twisted equation is the pentagon with the LEADING face
    inverted.**  Same 1024 cases.  The two agree exactly when `r` is its own
    conjugate, i.e. when the leading face is real. -/
theorem u4_sigma_decide : ∀ p q r s t : U4,
    decide (umul (umul (umul (uconj r) (uconj s)) (umul q (uconj t))) p = U4.e0)
      = decide (umul (umul p q) (uconj r) = umul s t) := by decide

theorem ud3rawOK_eq_upentOK (v : Bool → Bool → Bool → U4) : ud3rawOK v = upentOK v := by
  unfold ud3rawOK upentOK
  refine allBool_congr fun a => allBool_congr fun b => allBool_congr fun c =>
    allBool_congr fun d => ?_
  exact u4_cocycle_decide (v a b c) (v a (xor b c) d) (v b c d)
    (v (xor a b) c d) (v a b (xor c d))

/-! ### Every unit-valued symbol is one of the 4^8 tables. -/

theorem genPentOKF_congr {F G : Int → Int → Int → GZ}
    (h : ∀ a b c : Bool, F (lab a) (lab b) (lab c) = G (lab a) (lab b) (lab c)) :
    genPentOKF F = genPentOKF G := by
  unfold genPentOKF
  refine allBool_congr fun a => allBool_congr fun b => allBool_congr fun c =>
    allBool_congr fun d => ?_
  show decide (genPentLhs F (lab a) (lab b) (lab c) (lab d)
             = genPentRhs F (lab a) (lab b) (lab c) (lab d))
      = decide (genPentLhs G (lab a) (lab b) (lab c) (lab d)
             = genPentRhs G (lab a) (lab b) (lab c) (lab d))
  simp only [genPentLhs_lab, genPentRhs_lab, h]

theorem d3rawOK_congr {F G : Int → Int → Int → GZ}
    (h : ∀ a b c : Bool, F (lab a) (lab b) (lab c) = G (lab a) (lab b) (lab c)) :
    d3rawOK F = d3rawOK G := by
  unfold d3rawOK
  refine allBool_congr fun a => allBool_congr fun b => allBool_congr fun c =>
    allBool_congr fun d => ?_
  show decide (d3raw F (lab a) (lab b) (lab c) (lab d) = one)
      = decide (d3raw G (lab a) (lab b) (lab c) (lab d) = one)
  simp only [d3raw_lab, h]

theorem d3sigOK_congr {F G : Int → Int → Int → GZ}
    (h : ∀ a b c : Bool, F (lab a) (lab b) (lab c) = G (lab a) (lab b) (lab c)) :
    d3sigOK F = d3sigOK G := by
  unfold d3sigOK
  refine allBool_congr fun a => allBool_congr fun b => allBool_congr fun c =>
    allBool_congr fun d => ?_
  show decide (d3sig F (lab a) (lab b) (lab c) (lab d) = one)
      = decide (d3sig G (lab a) (lab b) (lab c) (lab d) = one)
  simp only [d3sig_lab, h]

/-- **Every unit-valued symbol is, for all three questions, one of the 4^8
    tables the sweep enumerates.**  The three decision procedures cannot tell
    `F` from the table of its own values. -/
theorem unit_symbol_is_a_table {F : Int → Int → Int → GZ} (hu : ∀ a b c : Int, IsUnit (F a b c)) :
    ∃ v : Bool → Bool → Bool → U4,
      genPentOKF F = genPentOKF (symOfValues (gzOf v)) ∧
      d3rawOK F = d3rawOK (symOfValues (gzOf v)) ∧
      d3sigOK F = d3sigOK (symOfValues (gzOf v)) := by
  refine ⟨fun a b c => u4Of (F (lab a) (lab b) (lab c)), ?_, ?_, ?_⟩
  · exact genPentOKF_congr fun a b c => by rw [gzOf_lab, uval_u4Of (hu _ _ _)]
  · exact d3rawOK_congr fun a b c => by rw [gzOf_lab, uval_u4Of (hu _ _ _)]
  · exact d3sigOK_congr fun a b c => by rw [gzOf_lab, uval_u4Of (hu _ _ _)]

/-- **THE CONTROL, in full.**  For EVERY unit-valued symbol, the untwisted
    differential's zero locus is exactly the pentagon locus.  The pentagon is the
    3-cocycle condition — as long as the action is trivial. -/
theorem pentagon_iff_d3raw_of_units {F : Int → Int → Int → GZ}
    (hu : ∀ a b c : Int, IsUnit (F a b c)) :
    genPentagonHolds F ↔ D3RawTrivial F := by
  obtain ⟨v, hp, hr, _⟩ := unit_symbol_is_a_table hu
  constructor
  · intro h
    refine d3rawOK_sound ?_
    rw [hr, ← ud3rawOK_eq, ud3rawOK_eq_upentOK, upentOK_eq, ← hp]
    exact genPentOKF_complete h
  · intro h
    refine genPentOKF_sound ?_
    rw [hp, ← upentOK_eq, ← ud3rawOK_eq_upentOK, ud3rawOK_eq, ← hr]
    exact d3rawOK_complete h

/-! ############################################################################
    PART VIII — THE FULL 4^8 SWEEP.

    `mkSym` turns eight units into a symbol; `pentOK8`/`d3sigOK8` are the two
    decision procedures written out with the eight values in the slots, so the
    kernel never has to look a value up.  They are proved EQUAL to the
    Bool-indexed procedures by `rfl`, and those are bridged to `Z[i]` in Part VII,
    so the sweep is evidence about the seed's own `genPentagonHolds` and
    `D3SigTrivial` and not about a private model.
    ############################################################################ -/

/-- The eight values of a symbol, indexed `x_{4a+2b+c}`. -/
def mkSym (x0 x1 x2 x3 x4 x5 x6 x7 : U4) : Bool → Bool → Bool → U4 :=
  fun a b c => cond a (cond b (cond c x7 x6) (cond c x5 x4)) (cond b (cond c x3 x2) (cond c x1 x0))

/-- Every table IS a `mkSym` of its own values, so the sweep below misses nothing. -/
theorem mkSym_eta (v : Bool → Bool → Bool → U4) :
    mkSym (v false false false) (v false false true) (v false true false) (v false true true)
          (v true false false) (v true false true) (v true true false) (v true true true) = v := by
  funext a b c; cases a <;> cases b <;> cases c <;> rfl

def pentOK8 (x0 x1 x2 x3 x4 x5 x6 x7 : U4) : Bool :=
  ((((decide (umul (umul x0 x0) x0 = umul x0 x0) && decide (umul (umul x0 x1) x1 = umul x1 x1)) && (decide (umul (umul x1 x2) x2 = umul x2 x1) && decide (umul (umul x1 x3) x3 = umul x3 x0))) && ((decide (umul (umul x2 x2) x4 = umul x4 x2) && decide (umul (umul x2 x3) x5 = umul x5 x3)) && (decide (umul (umul x3 x0) x6 = umul x6 x3) && decide (umul (umul x3 x1) x7 = umul x7 x2)))) && (((decide (umul (umul x4 x4) x0 = umul x4 x4) && decide (umul (umul x4 x5) x1 = umul x5 x5)) && (decide (umul (umul x5 x6) x2 = umul x6 x5) && decide (umul (umul x5 x7) x3 = umul x7 x4))) && ((decide (umul (umul x6 x6) x4 = umul x0 x6) && decide (umul (umul x6 x7) x5 = umul x1 x7)) && (decide (umul (umul x7 x4) x6 = umul x2 x7) && decide (umul (umul x7 x5) x7 = umul x3 x6)))))

def d3sigOK8 (x0 x1 x2 x3 x4 x5 x6 x7 : U4) : Bool :=
  ((((decide (umul (umul (umul x0 (uconj x0)) (umul x0 (uconj x0))) x0 = U4.e0) && decide (umul (umul (umul x1 (uconj x1)) (umul x1 (uconj x1))) x0 = U4.e0)) && (decide (umul (umul (umul x2 (uconj x2)) (umul x2 (uconj x1))) x1 = U4.e0) && decide (umul (umul (umul x3 (uconj x3)) (umul x3 (uconj x0))) x1 = U4.e0))) && ((decide (umul (umul (umul x4 (uconj x4)) (umul x2 (uconj x2))) x2 = U4.e0) && decide (umul (umul (umul x5 (uconj x5)) (umul x3 (uconj x3))) x2 = U4.e0)) && (decide (umul (umul (umul x6 (uconj x6)) (umul x0 (uconj x3))) x3 = U4.e0) && decide (umul (umul (umul x7 (uconj x7)) (umul x1 (uconj x2))) x3 = U4.e0)))) && (((decide (umul (umul (umul (uconj x0) (uconj x4)) (umul x4 (uconj x4))) x4 = U4.e0) && decide (umul (umul (umul (uconj x1) (uconj x5)) (umul x5 (uconj x5))) x4 = U4.e0)) && (decide (umul (umul (umul (uconj x2) (uconj x6)) (umul x6 (uconj x5))) x5 = U4.e0) && decide (umul (umul (umul (uconj x3) (uconj x7)) (umul x7 (uconj x4))) x5 = U4.e0))) && ((decide (umul (umul (umul (uconj x4) (uconj x0)) (umul x6 (uconj x6))) x6 = U4.e0) && decide (umul (umul (umul (uconj x5) (uconj x1)) (umul x7 (uconj x7))) x6 = U4.e0)) && (decide (umul (umul (umul (uconj x6) (uconj x2)) (umul x4 (uconj x7))) x7 = U4.e0) && decide (umul (umul (umul (uconj x7) (uconj x3)) (umul x5 (uconj x6))) x7 = U4.e0)))))

theorem pentOK8_eq (x0 x1 x2 x3 x4 x5 x6 x7 : U4) :
    pentOK8 x0 x1 x2 x3 x4 x5 x6 x7 = upentOK (mkSym x0 x1 x2 x3 x4 x5 x6 x7) := rfl

theorem d3sigOK8_eq (x0 x1 x2 x3 x4 x5 x6 x7 : U4) :
    d3sigOK8 x0 x1 x2 x3 x4 x5 x6 x7 = ud3sigOK (mkSym x0 x1 x2 x3 x4 x5 x6 x7) := rfl

/-- **What a `true` from `pentOK8` means**, in the seed's own vocabulary. -/
theorem pentOK8_iff (x0 x1 x2 x3 x4 x5 x6 x7 : U4) :
    pentOK8 x0 x1 x2 x3 x4 x5 x6 x7 = true ↔ genPentagonHolds (symOfValues (gzOf (mkSym x0 x1 x2 x3 x4 x5 x6 x7))) := by
  rw [pentOK8_eq, upentOK_eq]; exact genPentOKF_iff _

/-- **…and what a `true` from `d3sigOK8` means.** -/
theorem d3sigOK8_iff (x0 x1 x2 x3 x4 x5 x6 x7 : U4) :
    d3sigOK8 x0 x1 x2 x3 x4 x5 x6 x7 = true ↔ D3SigTrivial (symOfValues (gzOf (mkSym x0 x1 x2 x3 x4 x5 x6 x7))) := by
  rw [d3sigOK8_eq, ud3sigOK_eq]; exact d3sigOK_iff _

structure Counts where
  nTotal    : Nat
  nPent     : Nat
  nSig      : Nat
  nBoth     : Nat
  nPentOnly : Nat
  nSigOnly  : Nat
deriving DecidableEq

def cadd (u w : Counts) : Counts :=
  ⟨u.nTotal + w.nTotal, u.nPent + w.nPent, u.nSig + w.nSig,
   u.nBoth + w.nBoth, u.nPentOnly + w.nPentOnly, u.nSigOnly + w.nSigOnly⟩

def countAt (x0 x1 x2 x3 x4 x5 x6 x7 : U4) : Counts :=
  let p := pentOK8 x0 x1 x2 x3 x4 x5 x6 x7
  let s := d3sigOK8 x0 x1 x2 x3 x4 x5 x6 x7
  ⟨1, cond p 1 0, cond s 1 0, cond (p && s) 1 0,
   cond (p && !s) 1 0, cond (s && !p) 1 0⟩

/-- The four-way branch over `U4`, written as a balanced sum so the kernel's
    recursion stays shallow. -/
def branch (f : U4 → Counts) : Counts :=
  cadd (cadd (f .e0) (f .e1)) (cadd (f .e2) (f .e3))

/-- **The sweep**: eight nested branches, one per value slot. -/
def sweepAll : Counts :=
  branch fun x0 => branch fun x1 => branch fun x2 => branch fun x3 =>
  branch fun x4 => branch fun x5 => branch fun x6 => branch fun x7 =>
    countAt x0 x1 x2 x3 x4 x5 x6 x7

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
/-- **THE SWEEP, decided by the kernel.**  All 65536 unit-valued symbols visited
    (`nTotal = 65536` is the proof the enumeration is complete):

      * 32 satisfy the seed's pentagon;
      * 64 satisfy the sigma-twisted cocycle condition — TWICE as many;
      * 8 satisfy both (exactly the `±1`-valued cocycles, where the twist is
        invisible by `d3sig_eq_d3raw_of_real`);
      * 24 are pentagons that are NOT sigma-cocycles;
      * 56 are sigma-cocycles that are NOT pentagons.

    Neither containment holds, and the two sets are not even the same size. -/
theorem sweep_counts : sweepAll = ⟨65536, 32, 64, 8, 24, 56⟩ := by decide

/-- The same sweep restricted to the REAL units `{1, −1}` — the slice where the
    seal's boson and fermion live.  All 256 tables visited; the pentagon and the
    sigma-twisted condition pick out the SAME 8, and neither "only" column has a
    single entry.  This is `d3sig_eq_d3raw_of_real` counted out, and it is why
    the seal never had to notice the twist. -/
def branchReal (f : U4 → Counts) : Counts := cadd (f .e0) (f .e2)

def sweepReal : Counts :=
  branchReal fun x0 => branchReal fun x1 => branchReal fun x2 => branchReal fun x3 =>
  branchReal fun x4 => branchReal fun x5 => branchReal fun x6 => branchReal fun x7 =>
    countAt x0 x1 x2 x3 x4 x5 x6 x7

set_option maxRecDepth 10000 in
theorem sweep_real_counts : sweepReal = ⟨256, 8, 8, 8, 0, 0⟩ := by decide

/-! ############################################################################
    PART IX — axiom audit.

    Every theorem in this file, not a curated sample.  `sorryAx` must not appear.
    ############################################################################ -/

#print axioms GZ.eq_of
#print axioms band_left
#print axioms band_right
#print axioms allBool_sound
#print axioms allBool_complete
#print axioms allBool_congr
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
#print axioms d3rawOK_sound
#print axioms d3rawOK_complete
#print axioms d3rawOK_iff
#print axioms not_D3RawTrivial_of_false
#print axioms d3sigOK_sound
#print axioms d3sigOK_complete
#print axioms d3sigOK_iff
#print axioms not_D3SigTrivial_of_false
#print axioms boolOf_lab
#print axioms symOfValues_lab
#print axioms genPentLhs_lab
#print axioms genPentRhs_lab
#print axioms d3raw_lab
#print axioms d3sig_lab
#print axioms d3sig_eq_d3raw_at_zero
#print axioms act_zero
#print axioms act_one
#print axioms act_one_ne_id
#print axioms d3sig_eq_d3raw_of_real
#print axioms slice_pentagon_values
#print axioms slice_d3raw_values
#print axioms slice_d3sig_values
#print axioms witness1_values
#print axioms witness1_isUnit
#print axioms witness1_sig
#print axioms witness1_not_pentagon
#print axioms witness1_pentagon_failure
#print axioms witness1_mechanism
#print axioms witness2_values
#print axioms witness2_isUnit
#print axioms witness2_pentagon
#print axioms witness2_raw
#print axioms witness2_not_sig
#print axioms witness2_mechanism
#print axioms pentagon_is_not_sigma_cocycles
#print axioms sigma_cocycles_not_subset_pentagon
#print axioms pentagon_not_subset_sigma_cocycles
#print axioms boson_in_both
#print axioms fermion_in_both
#print axioms fakeCocycle_fails_both
#print axioms uval_umul
#print axioms uval_uconj
#print axioms uval_e0
#print axioms decide_uval_eq
#print axioms uval_isUnit
#print axioms sq_nonneg
#print axioms bound_of_sq_le_one
#print axioms unit_is_four
#print axioms uval_u4Of
#print axioms gzOf_lab
#print axioms genPentLhs_uval
#print axioms genPentRhs_uval
#print axioms d3raw_uval
#print axioms d3sig_uval
#print axioms upentOK_eq
#print axioms ud3rawOK_eq
#print axioms ud3sigOK_eq
#print axioms u4_cocycle_decide
#print axioms u4_sigma_decide
#print axioms ud3rawOK_eq_upentOK
#print axioms genPentOKF_congr
#print axioms d3rawOK_congr
#print axioms d3sigOK_congr
#print axioms unit_symbol_is_a_table
#print axioms pentagon_iff_d3raw_of_units
#print axioms mkSym_eta
#print axioms pentOK8_eq
#print axioms d3sigOK8_eq
#print axioms pentOK8_iff
#print axioms d3sigOK8_iff
#print axioms sweep_counts
#print axioms sweep_real_counts
