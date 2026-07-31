/-
  C6_ActionC.lean — READING C: the reading nobody asked.

  THE QUESTION.  The seal's `gaugeAct`/`gaugePhi` put `conj` in exactly two of
  four gauge slots — the alternating-inverse pattern — and the seal's own
  docstring hedges: "The down slots use conj, which is the inverse exactly on
  units — so this is an action of UNIT-valued gauges, and nothing here claims it
  is one otherwise."

  Reading A twisted the differential.  Reading B twisted the pentagon.  Reading C
  asks what the symbol `conj` in those slots MEANS: an inverse (trivial action) or
  sigma (Galois action).  On units the two readings are the same function.  Off
  the units they are not.  Every theorem the seal states about gauges carries a
  unit hypothesis.  So the record cannot tell which of the two it wrote down.

  NO IMPORTS.  Part I is copied verbatim from `lean/C6_Core.lean` (which took it
  verbatim from `lean/C6_SEED.lean`); `act`, `d2sig`, `d3raw`, `d3sig` in Part III
  are Reading A's, quoted so the two readings can be compared without a
  translation layer.  Everything else is Reading C's own and is marked so.

  DISCIPLINE.  No `sorry`, no `admit`, no `axiom`, no `native_decide`, no
  `@[implemented_by]`.  Every `decide` here is a kernel `decide`.
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

/-- The pentagon, as a proposition about `f`. -/
def pentagonHolds (f : GZ) : Prop :=
  ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    (d = 0 ∨ d = 1) → pentLhs f a b c d = pentRhs f a b c d

/-- A unit is an element with a multiplicative partner. -/
def IsUnit (u : GZ) : Prop := ∃ v, mul u v = one

/-- The braiding symbol: `R` at the single slot `(1,1)`, `one` elsewhere. -/
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

/-- A GENERAL F-symbol in the bench's language. -/
def Fgen (F : Int → Int → Int → GZ) (a b c d x y : Int) : GZ :=
  if x = (a + b) % 2 ∧ y = (b + c) % 2 ∧ d = (a + b + c) % 2 then F a b c else zero

def genPentLhs (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2; let u := (b + c) % 2
  mul (mul (Fgen F a b c y x u) (Fgen F a u d t y v)) (Fgen F b c d v u w)

def genPentRhs (F : Int → Int → Int → GZ) (a b c d : Int) : GZ :=
  let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d) % 2
  let w := (c + d) % 2; let v := (b + w) % 2
  mul (Fgen F x c d t y w) (Fgen F a b w t x v)

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

/-- **The gauge factor.** `gaugeAct` multiplies the symbol by exactly this. -/
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
    unit-valued gauge carries the one onto the other at every label triple. -/
def GaugeEquivOnLabels (F F' : Int → Int → Int → GZ) : Prop :=
  ∃ g : Int → Int → GZ, (∀ a b : Int, IsUnit (g a b)) ∧
    ∀ a b c : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
      gaugeAct g F a b c = F' a b c

/-- The bridge from the index group to the seal's integer labels. -/
def lab : Bool → Int := fun b => if b then 1 else 0

/-- The `d^2` coboundary written in the seal's own label arithmetic. -/
def d2raw (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (g b c) (conj (g ((a + b) % 2) c))) (mul (g a ((b + c) % 2)) (conj (g a b)))

/-- The label decoder: `Int` to `Bool`, inverse to `lab` on the labels. -/
def boolOf (i : Int) : Bool := if i = 1 then true else false

/-- The domain the sealed classification speaks about. -/
def IsClassifiedSymbol (F : Int → Int → Int → GZ) : Prop :=
  (∀ a b c : Int, IsUnit (F a b c)) ∧ genPentagonHolds F

/-! ############################################################################
    PART II — the decidability bridge and the arithmetic of `Z[i]`.

    `GZ.eq_of`, `instDecidableEqGZ`, `allBool`, `lab_isLabel`,
    `exists_bool_of_isLabel` are `C6_Core`'s, reproduced because this file
    imports nothing.  The ring lemmas below are Reading C's: Reading C needs
    commutativity and associativity of `mul` (Core did not), because every
    theorem here rearranges a four-fold product.
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

def allBool (p : Bool → Bool) : Bool := p false && p true

theorem allBool_sound {p : Bool → Bool} (h : allBool p = true) : ∀ b : Bool, p b = true
  | false => band_left h
  | true  => band_right h

theorem allBool_complete {p : Bool → Bool} (h : ∀ b : Bool, p b = true) : allBool p = true := by
  show (p false && p true) = true
  rw [h false, h true]
  rfl

theorem lab_isLabel (A : Bool) : lab A = 0 ∨ lab A = 1 := by
  cases A with
  | false => exact Or.inl rfl
  | true  => exact Or.inr rfl

theorem exists_bool_of_isLabel {a : Int} (h : a = 0 ∨ a = 1) : ∃ A : Bool, a = lab A := by
  cases h with
  | inl h => exact ⟨false, by rw [h]; rfl⟩
  | inr h => exact ⟨true, by rw [h]; rfl⟩

/-! ### The ring facts.  `Z[i]` is a commutative ring and `conj` is an
    automorphism of it; both are needed to rearrange the four-fold products
    that every gauge formula in the seal is. -/

theorem gz_mul_comm (z w : GZ) : mul z w = mul w z := by
  apply GZ.eq_of
  · show z.re * w.re - z.im * w.im = w.re * z.re - w.im * z.im
    grind
  · show z.re * w.im + z.im * w.re = w.re * z.im + w.im * z.re
    grind

theorem gz_mul_assoc (x y z : GZ) : mul (mul x y) z = mul x (mul y z) := by
  apply GZ.eq_of
  · show (x.re * y.re - x.im * y.im) * z.re - (x.re * y.im + x.im * y.re) * z.im
        = x.re * (y.re * z.re - y.im * z.im) - x.im * (y.re * z.im + y.im * z.re)
    grind
  · show (x.re * y.re - x.im * y.im) * z.im + (x.re * y.im + x.im * y.re) * z.re
        = x.re * (y.re * z.im + y.im * z.re) + x.im * (y.re * z.re - y.im * z.im)
    grind

theorem gz_one_mul (z : GZ) : mul one z = z := by
  apply GZ.eq_of
  · show 1 * z.re - 0 * z.im = z.re
    grind
  · show 1 * z.im + 0 * z.re = z.im
    grind

theorem gz_mul_one (z : GZ) : mul z one = z := by rw [gz_mul_comm]; exact gz_one_mul z

/-- **`conj` is multiplicative** — the sigma of Circle Two. -/
theorem conj_mul (z w : GZ) : mul (conj z) (conj w) = conj (mul z w) := by
  apply GZ.eq_of
  · show z.re * w.re - (-z.im) * (-w.im) = z.re * w.re - z.im * w.im
    rw [Int.neg_mul_neg]
  · show z.re * (-w.im) + (-z.im) * w.re = -(z.re * w.im + z.im * w.re)
    rw [Int.mul_neg, Int.neg_mul, Int.neg_add]

theorem conj_add (z w : GZ) : add (conj z) (conj w) = conj (add z w) := by
  apply GZ.eq_of
  · rfl
  · show (-z.im) + (-w.im) = -(z.im + w.im)
    rw [Int.neg_add]

theorem conj_one : conj one = one := rfl

theorem conj_conj (z : GZ) : conj (conj z) = z := by
  apply GZ.eq_of
  · rfl
  · show - -z.im = z.im
    rw [Int.neg_neg]

/-- **`z · conj z = N(z)`** — the fact the whole of Reading C turns on. -/
theorem mul_conj_eq_norm (z : GZ) : mul z (conj z) = ⟨norm z, 0⟩ := by
  apply GZ.eq_of
  · show z.re * z.re - z.im * (-z.im) = z.re * z.re + z.im * z.im
    grind
  · show z.re * (-z.im) + z.im * z.re = 0
    grind

/-- **The norm is multiplicative** — Brahmagupta–Fibonacci, in the kernel. -/
theorem norm_mul (z w : GZ) : norm (mul z w) = norm z * norm w := by
  show (z.re * w.re - z.im * w.im) * (z.re * w.re - z.im * w.im)
      + (z.re * w.im + z.im * w.re) * (z.re * w.im + z.im * w.re)
      = (z.re * z.re + z.im * z.im) * (w.re * w.re + w.im * w.im)
  grind

theorem norm_conj (z : GZ) : norm (conj z) = norm z := by
  show z.re * z.re + (-z.im) * (-z.im) = z.re * z.re + z.im * z.im
  grind

theorem norm_nonneg (z : GZ) : 0 ≤ norm z := by
  have h1 : 0 ≤ z.re * z.re := by
    rcases Int.le_total 0 z.re with h | h
    · exact Int.mul_nonneg h h
    · have : 0 ≤ (-z.re) * (-z.re) := Int.mul_nonneg (by omega) (by omega)
      grind
  have h2 : 0 ≤ z.im * z.im := by
    rcases Int.le_total 0 z.im with h | h
    · exact Int.mul_nonneg h h
    · have : 0 ≤ (-z.im) * (-z.im) := Int.mul_nonneg (by omega) (by omega)
      grind
  show 0 ≤ z.re * z.re + z.im * z.im
  omega

/-! ### The units of `Z[i]`, and the exact sense in which `conj` is inversion.

    `unit_is_four` is Reading A's, reproduced (this file imports nothing); the
    norm characterisation and the uniqueness of inverses are Reading C's, and
    they are what let the questions below be settled rather than asserted. -/

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

/-- **The units of `Z[i]` are exactly `1, i, −1, −i`.** -/
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

theorem isUnit_of_mul_conj {u : GZ} (h : mul u (conj u) = one) : IsUnit u := ⟨conj u, h⟩

/-- **`IsUnit u ↔ N(u) = 1`.**  Both directions, so the norm may be used as the
    decision procedure for unithood from here on. -/
theorem isUnit_iff_norm_one (u : GZ) : IsUnit u ↔ norm u = 1 := by
  constructor
  · intro h
    rcases unit_is_four h with h1|h1|h1|h1 <;> rw [h1] <;> decide
  · intro h
    refine isUnit_of_mul_conj ?_
    rw [mul_conj_eq_norm, h]
    rfl

/-- **`conj` IS inversion on the units** — the seal's bridge, in the kernel. -/
theorem mul_conj_of_isUnit {u : GZ} (h : IsUnit u) : mul u (conj u) = one := by
  rw [mul_conj_eq_norm, (isUnit_iff_norm_one u).mp h]; rfl

theorem isUnit_mul {u v : GZ} (hu : IsUnit u) (hv : IsUnit v) : IsUnit (mul u v) := by
  rw [isUnit_iff_norm_one] at *
  rw [norm_mul, hu, hv]
  decide

theorem isUnit_conj {u : GZ} (hu : IsUnit u) : IsUnit (conj u) := by
  rw [isUnit_iff_norm_one] at *
  rw [norm_conj]; exact hu

theorem isUnit_one : IsUnit one := by rw [isUnit_iff_norm_one]; decide

/-- **Inverses in `Z[i]` are unique** — `Z[i]` is a domain, so the phrase "the
    inverse braiding" names at most one element. -/
theorem inv_unique {u v w : GZ} (hv : mul u v = one) (hw : mul u w = one) : v = w := by
  have h1 : mul v (mul u w) = mul v one := by rw [hw]
  rw [← gz_mul_assoc, gz_mul_comm v u, hv, gz_one_mul, gz_mul_one] at h1
  exact h1.symm

/-- …so on a unit, ANY inverse is `conj`. -/
theorem inv_eq_conj_of_isUnit {u v : GZ} (hu : IsUnit u) (hv : mul u v = one) : v = conj u :=
  inv_unique hv (mul_conj_of_isUnit hu)

/-! ############################################################################
    PART III — READING C.

    `act`, `d2sig`, `d3raw`, `d3sig` are Reading A's (`lean/C6_ActionA.lean`),
    quoted verbatim so the trivial-action and Galois-action differentials can be
    compared here without a translation layer.  Everything else in Part III is
    Reading C's own.
    ############################################################################ -/

/-- **The Galois action**, on the labels: the nontrivial element of `Z_2`
    (the label `1`) acts by `conj`; the identity label `0` acts trivially. -/
def act (a : Int) (x : GZ) : GZ := if a = 1 then conj x else x

/-- `d^2` with sigma on the LEADING face — the same alternating shape as the
    seed's `d2raw`, with `act a` applied to the leading term. -/
def d2sig (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (act a (g b c)) (conj (g ((a + b) % 2) c))) (mul (g a ((b + c) % 2)) (conj (g a b)))

theorem act_isUnit {a : Int} {u : GZ} (h : IsUnit u) : IsUnit (act a u) := by
  unfold act
  by_cases ha : a = 1
  · rw [if_pos ha]; exact isUnit_conj h
  · rw [if_neg ha]; exact h

/-! ### The label-agreement bridge: `∀` over the eight label triples, decided. -/

/-- Two symbols agree at every label triple.  This is the shape every question
    below takes, because the seal never looks off the labels. -/
def AgreeOnLabels (P Q : Int → Int → Int → GZ) : Prop :=
  ∀ a b c : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) → P a b c = Q a b c

def agreeOK (P Q : Int → Int → Int → GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c =>
    decide (P (lab a) (lab b) (lab c) = Q (lab a) (lab b) (lab c))

theorem agreeOK_sound {P Q : Int → Int → Int → GZ} (h : agreeOK P Q = true) :
    AgreeOnLabels P Q := by
  have key : ∀ A B C : Bool, P (lab A) (lab B) (lab C) = Q (lab A) (lab B) (lab C) :=
    fun A B C => of_decide_eq_true
      (allBool_sound (allBool_sound (allBool_sound h A) B) C)
  intro a b c ha hb hc
  cases exists_bool_of_isLabel ha with
  | intro A hA =>
    cases exists_bool_of_isLabel hb with
    | intro B hB =>
      cases exists_bool_of_isLabel hc with
      | intro C hC =>
        subst hA; subst hB; subst hC
        exact key A B C

theorem agreeOK_complete {P Q : Int → Int → Int → GZ} (h : AgreeOnLabels P Q) :
    agreeOK P Q = true :=
  allBool_complete fun A => allBool_complete fun B => allBool_complete fun C =>
    decide_eq_true (h (lab A) (lab B) (lab C) (lab_isLabel A) (lab_isLabel B) (lab_isLabel C))

theorem not_agreeOnLabels_of_false {P Q : Int → Int → Int → GZ} (h : agreeOK P Q = false) :
    ¬ AgreeOnLabels P Q := fun hp => Bool.noConfusion (h ▸ agreeOK_complete hp)

/-! ### The four coboundary questions.

    "Coboundary" is ambiguous exactly where Reading C is looking, so all four
    versions are named rather than one being silently chosen: the trivial-action
    formula `d2raw` and the Galois-twisted formula `d2sig`, each over ALL
    `Z[i]`-valued gauges and over UNIT-valued gauges only.  The seal's own
    complex is the unit-valued one — `Coch2` is `Bool → Un`. -/

def RawCoboundaryOnLabels (P : Int → Int → Int → GZ) : Prop :=
  ∃ g : Int → Int → GZ, AgreeOnLabels (d2raw g) P

def SigCoboundaryOnLabels (P : Int → Int → Int → GZ) : Prop :=
  ∃ g : Int → Int → GZ, AgreeOnLabels (d2sig g) P

def UnitRawCoboundaryOnLabels (P : Int → Int → Int → GZ) : Prop :=
  ∃ g : Int → Int → GZ, (∀ a b : Int, IsUnit (g a b)) ∧ AgreeOnLabels (d2raw g) P

def UnitSigCoboundaryOnLabels (P : Int → Int → Int → GZ) : Prop :=
  ∃ g : Int → Int → GZ, (∀ a b : Int, IsUnit (g a b)) ∧ AgreeOnLabels (d2sig g) P

theorem d2raw_isUnit {g : Int → Int → GZ} (hg : ∀ a b : Int, IsUnit (g a b)) (a b c : Int) :
    IsUnit (d2raw g a b c) :=
  isUnit_mul (isUnit_mul (hg b c) (isUnit_conj (hg _ c)))
             (isUnit_mul (hg a _) (isUnit_conj (hg a b)))

theorem d2sig_isUnit {g : Int → Int → GZ} (hg : ∀ a b : Int, IsUnit (g a b)) (a b c : Int) :
    IsUnit (d2sig g a b c) :=
  isUnit_mul (isUnit_mul (act_isUnit (hg b c)) (isUnit_conj (hg _ c)))
             (isUnit_mul (hg a _) (isUnit_conj (hg a b)))

/-! ############################################################################
    SECTION 1 — a concrete NON-UNIT gauge, and what its gauge factor is.
    ############################################################################ -/

/-- **The non-unit gauge**: `g ≡ 1 + i` at every label pair.  `N(1+i) = 2`, so
    this is exactly one step outside the domain every sealed gauge theorem
    quantifies over. -/
def gPlusI : Int → Int → GZ := fun _ _ => ⟨1, 1⟩

theorem gPlusI_norm (a b : Int) : norm (gPlusI a b) = 2 := rfl

/-- …and it is genuinely not a unit — through the norm characterisation, so this
    is a proof and not a check of four cases. -/
theorem gPlusI_not_isUnit (a b : Int) : ¬ IsUnit (gPlusI a b) := by
  rw [isUnit_iff_norm_one, gPlusI_norm]
  decide

/-- **THE COMPUTATION.**  `gaugePhi` of the constant gauge `1+i` is the constant
    `4` — at EVERY integer triple, not merely on the labels, because the gauge
    does not read its arguments.  `(1+i)(1+i)·(1−i)(1−i) = (2i)(−2i) = 4`. -/
theorem gaugePhi_gPlusI (a b c : Int) : gaugePhi gPlusI a b c = ⟨4, 0⟩ := rfl

/-- `4` is not a unit: `N(4) = 16`. -/
theorem four_not_isUnit : ¬ IsUnit (⟨4, 0⟩ : GZ) := by
  rw [isUnit_iff_norm_one]
  decide

/-- **VERDICT (a).**  The gauge factor of a non-unit gauge is not a coboundary of
    the seal's complex — under EITHER action.  The seal's `Coch2` is `Bool → Un`,
    unit-valued by construction, and both differentials carry units to units; the
    value `4` is not one.  So the question "trivial or Galois?" cannot even be
    asked of this object inside the seal's own complex. -/
theorem gaugePhi_gPlusI_not_unit_raw_coboundary :
    ¬ UnitRawCoboundaryOnLabels (gaugePhi gPlusI) := by
  intro h
  obtain ⟨g, hg, hagree⟩ := h
  have h0 : d2raw g 0 0 0 = gaugePhi gPlusI 0 0 0 :=
    hagree 0 0 0 (Or.inl rfl) (Or.inl rfl) (Or.inl rfl)
  rw [gaugePhi_gPlusI] at h0
  exact four_not_isUnit (h0 ▸ d2raw_isUnit hg 0 0 0)

theorem gaugePhi_gPlusI_not_unit_sig_coboundary :
    ¬ UnitSigCoboundaryOnLabels (gaugePhi gPlusI) := by
  intro h
  obtain ⟨g, hg, hagree⟩ := h
  have h0 : d2sig g 0 0 0 = gaugePhi gPlusI 0 0 0 :=
    hagree 0 0 0 (Or.inl rfl) (Or.inl rfl) (Or.inl rfl)
  rw [gaugePhi_gPlusI] at h0
  exact four_not_isUnit (h0 ▸ d2sig_isUnit hg 0 0 0)

/-! ### The positive half: read as a RAW formula on all of `Z[i]`, the gauge
    factor of a non-unit gauge is a coboundary — of BOTH complexes.  This is
    Reading C's first surprise: stepping off the units does not separate the two
    readings, it only leaves the seal's complex. -/

instance : Std.Associative mul := ⟨gz_mul_assoc⟩
instance : Std.Commutative mul := ⟨gz_mul_comm⟩

theorem gz_rearrange (p q r s : GZ) : mul (mul p q) (mul r s) = mul (mul r q) (mul s p) := by
  ac_rfl

/-- **`gaugePhi g = d2raw (gaugeInv g)`, with NO unit hypothesis.**  The seal's
    gauge factor is literally the trivial-action raw coboundary of the
    conjugated gauge — the same four factors, reassociated.  So the raw
    trivial-action image is closed under `gaugePhi` everywhere, units or not. -/
theorem gaugePhi_eq_d2raw_gaugeInv (g : Int → Int → GZ) (a b c : Int) :
    gaugePhi g a b c = d2raw (gaugeInv g) a b c := by
  show mul (mul (g a b) (g ((a + b) % 2) c)) (mul (conj (g b c)) (conj (g a ((b + c) % 2))))
      = mul (mul (conj (g b c)) (conj (conj (g ((a + b) % 2) c))))
            (mul (conj (g a ((b + c) % 2))) (conj (conj (g a b))))
  rw [conj_conj, conj_conj]
  exact gz_rearrange _ _ _ _

/-- **VERDICT (b).**  `gaugePhi gPlusI` IS a raw trivial-action coboundary, and
    the witness is the seal's own `gaugeInv` of the same gauge. -/
theorem gaugePhi_gPlusI_is_raw_coboundary : RawCoboundaryOnLabels (gaugePhi gPlusI) :=
  ⟨gaugeInv gPlusI, fun a b c _ _ _ => (gaugePhi_eq_d2raw_gaugeInv gPlusI a b c).symm⟩

/-- **The Galois witness.**  A `Z[i]`-valued gauge of constant norm 2 whose
    sigma-twisted coboundary is also the constant `4`.  It is NOT the conjugate
    of `gPlusI`: the sigma twist on the leading face has to be paid for, and this
    is the gauge that pays it — `h(0,·) = 1+i`, `h(1,0) = 1−i`, `h(1,1) = −1+i`. -/
def hSig : Int → Int → GZ :=
  fun a b => if a = 1 then (if b = 1 then ⟨-1, 1⟩ else ⟨1, -1⟩) else ⟨1, 1⟩

theorem hSig_norm (a b : Int) : norm (hSig a b) = 2 := by
  unfold hSig
  by_cases ha : a = 1
  · by_cases hb : b = 1
    · rw [if_pos ha, if_pos hb]; decide
    · rw [if_pos ha, if_neg hb]; decide
  · rw [if_neg ha]; decide

theorem hSig_not_isUnit (a b : Int) : ¬ IsUnit (hSig a b) := by
  rw [isUnit_iff_norm_one, hSig_norm]
  decide

/-- **VERDICT (c).**  `gaugePhi gPlusI` is ALSO a raw Galois-twisted coboundary.
    Decided by the kernel over all eight label triples. -/
theorem gaugePhi_gPlusI_is_sig_coboundary : SigCoboundaryOnLabels (gaugePhi gPlusI) :=
  ⟨hSig, agreeOK_sound (by decide)⟩

/-- The computation behind (c), exposed as a `Bool` rather than a claim. -/
theorem sig_witness_value : agreeOK (d2sig hSig) (gaugePhi gPlusI) = true := by decide

/-- …and the naive Galois witness does NOT work: `gaugeInv gPlusI` is a
    `d2raw`-preimage but not a `d2sig`-preimage.  So (c) is a real construction
    and not a restatement of (b). -/
theorem gaugeInv_gPlusI_fails_sig :
    ¬ AgreeOnLabels (d2sig (gaugeInv gPlusI)) (gaugePhi gPlusI) :=
  not_agreeOnLabels_of_false (by decide)
