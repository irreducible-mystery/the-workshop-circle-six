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

/-! ############################################################################
    SECTION 2 — is `gaugeInv` an inversion?

    The seal calls `gaugeInv g = conj ∘ g` "gauge inversion" and says every
    theorem using it carries the unit hypothesis.  Reading C asks what happens
    when the hypothesis is dropped, and then asks for the EXACT set on which it
    may be dropped.
    ############################################################################ -/

/-- The monoid laws need no hypothesis at all: `gaugeComp` is associative and
    commutative and `gaugeTrivial` is its identity, on ALL `Z[i]`-valued gauges.
    So the unit hypothesis is not paying for the group structure in general — it
    is paying for exactly one axiom, and Section 2 finds out which. -/
theorem gaugeComp_assoc (g h k : Int → Int → GZ) :
    gaugeComp (gaugeComp g h) k = gaugeComp g (gaugeComp h k) := by
  funext a b; exact gz_mul_assoc _ _ _

theorem gaugeComp_comm (g h : Int → Int → GZ) : gaugeComp g h = gaugeComp h g := by
  funext a b; exact gz_mul_comm _ _

theorem gaugeTrivial_left_unit (g : Int → Int → GZ) : gaugeComp gaugeTrivial g = g := by
  funext a b; exact gz_one_mul _

/-- **What `gaugeComp g (gaugeInv g)` actually is**: the NORM of the gauge,
    placed on the real axis.  No hypothesis.  Everything in this section is a
    corollary of this one line. -/
theorem gaugeComp_gaugeInv (g : Int → Int → GZ) (a b : Int) :
    gaugeComp g (gaugeInv g) a b = ⟨norm (g a b), 0⟩ := mul_conj_eq_norm (g a b)

/-- **REFUTED.**  `gaugeComp g (gaugeInv g) = gaugeTrivial` is FALSE without the
    unit hypothesis, and here is the counterexample: at `g ≡ 1+i` the composite
    is the constant `2`, not `1`. -/
theorem gaugeComp_gaugeInv_gPlusI (a b : Int) :
    gaugeComp gPlusI (gaugeInv gPlusI) a b = ⟨2, 0⟩ := rfl

theorem gaugeInv_not_inverse :
    ¬ (∀ g : Int → Int → GZ, gaugeComp g (gaugeInv g) = gaugeTrivial) := by
  intro h
  have h0 := congrFun (congrFun (h gPlusI) 0) 0
  rw [gaugeComp_gaugeInv_gPlusI] at h0
  exact absurd h0 (by decide)

/-- **The exact set, pointwise, both inclusions**: `z · conj z = 1` holds at `z`
    if and only if `z` is a unit.  `←` is the seal's bridge; `→` is its converse,
    which the seal never needed and which is what pins the set down. -/
theorem mul_conj_eq_one_iff_isUnit (z : GZ) : mul z (conj z) = one ↔ IsUnit z :=
  Iff.intro isUnit_of_mul_conj mul_conj_of_isUnit

/-- **THE CHARACTERISATION.**  `gaugeInv` is an inversion for `gaugeComp` at
    exactly the unit-valued gauges — not one gauge more, not one fewer.  Both
    inclusions, no hypothesis on either side. -/
theorem gaugeInv_isInverse_iff (g : Int → Int → GZ) :
    gaugeComp g (gaugeInv g) = gaugeTrivial ↔ (∀ a b : Int, IsUnit (g a b)) := by
  constructor
  · intro h a b
    exact (mul_conj_eq_one_iff_isUnit (g a b)).mp (congrFun (congrFun h a) b)
  · intro h
    funext a b
    exact (mul_conj_eq_one_iff_isUnit (g a b)).mpr (h a b)

/-- The same set, read through the norm: `gaugeInv` inverts `g` exactly where
    `g` has norm 1.  This is the form in which the failure is quantitative —
    `gPlusI` misses by a factor of 2, and nothing smaller than a unit exists. -/
theorem gaugeInv_isInverse_iff_norm (g : Int → Int → GZ) :
    gaugeComp g (gaugeInv g) = gaugeTrivial ↔ (∀ a b : Int, norm (g a b) = 1) := by
  rw [gaugeInv_isInverse_iff]
  constructor
  · intro h a b; exact (isUnit_iff_norm_one (g a b)).mp (h a b)
  · intro h a b; exact (isUnit_iff_norm_one (g a b)).mpr (h a b)

/-- Non-vacuity for the positive half: the set on which `gaugeInv` inverts is not
    empty — the trivial gauge is in it, and so is every `U(1)`-valued gauge the
    seal writes down. -/
theorem gaugeTrivial_isUnit (a b : Int) : IsUnit (gaugeTrivial a b) := isUnit_one

theorem gaugeInv_isInverse_at_trivial :
    gaugeComp gaugeTrivial (gaugeInv gaugeTrivial) = gaugeTrivial :=
  (gaugeInv_isInverse_iff gaugeTrivial).mpr gaugeTrivial_isUnit

/-- …and it is a proper subset: `gPlusI` is outside it, so the characterisation
    separates something. -/
theorem gPlusI_outside :
    ¬ gaugeComp gPlusI (gaugeInv gPlusI) = gaugeTrivial := by
  rw [gaugeInv_isInverse_iff]
  intro h
  exact gPlusI_not_isUnit 0 0 (h 0 0)

/-! ############################################################################
    SECTION 3 — `hexInvHolds f R = hexagonHolds f (conj R)`.

    The seal names this "the R⁻¹-hexagon".  Two readings:
      (i)  what is WRITTEN — the hexagon at the Galois conjugate of `R`;
      (ii) what the NAME says — the hexagon at an inverse of `R`.
    On units these are the same proposition.  Off the units (ii) has no subject
    at all, and (i) still has one.
    ############################################################################ -/

/-- Reading (ii): the hexagon at every inverse of `R`.  Quantified rather than
    applied, because off the units there may be no inverse to apply it to — and
    that is exactly the phenomenon. -/
def HexAtInverses (f R : GZ) : Prop := ∀ S : GZ, mul R S = one → hexagonHolds f S

/-! ### The hexagon, decided by the kernel.  The two label constraints on `d` are
    hypotheses, so the `Bool` guards on them rather than ignoring them. -/

def hexConstraint (a b c d : Int) : Bool :=
  decide (d = ((a + b) % 2 + c) % 2) && decide (d = ((a + c) % 2 + b) % 2)

def hexAt (f R : GZ) (a b c d : Bool) : Bool :=
  !(hexConstraint (lab a) (lab b) (lab c) (lab d)) ||
    decide (hexLhs f R (lab a) (lab b) (lab c) (lab d)
          = hexRhs f R (lab a) (lab b) (lab c) (lab d))

def hexOK (f R : GZ) : Bool :=
  allBool fun a => allBool fun b => allBool fun c => allBool fun d => hexAt f R a b c d

theorem hexOK_sound {f R : GZ} (h : hexOK f R = true) : hexagonHolds f R := by
  intro a b c d ha hb hc hd h1 h2
  cases exists_bool_of_isLabel ha with
  | intro A hA =>
    cases exists_bool_of_isLabel hb with
    | intro B hB =>
      cases exists_bool_of_isLabel hc with
      | intro C hC =>
        cases exists_bool_of_isLabel hd with
        | intro D hD =>
          subst hA; subst hB; subst hC; subst hD
          have hk : hexAt f R A B C D = true :=
            allBool_sound (allBool_sound (allBool_sound (allBool_sound h A) B) C) D
          have hcon : hexConstraint (lab A) (lab B) (lab C) (lab D) = true := by
            show (decide _ && decide _) = true
            rw [decide_eq_true h1, decide_eq_true h2]
            rfl
          unfold hexAt at hk
          rw [hcon] at hk
          exact of_decide_eq_true hk

/-- Non-vacuity: `hexagonHolds` is inhabited, so nothing in this section is a
    statement about the empty set. -/
theorem hexagon_at_one_one : hexagonHolds one one := hexOK_sound (by decide)

theorem hexInv_at_one_one : hexInvHolds one one := hexOK_sound (by decide)

/-! ### What the hexagon costs at `f = 1`: the braiding must square to `1`. -/

theorem hexagon_one_forces_sq {R : GZ} (h : hexagonHolds one R) : mul R R = one := by
  have h1 := h 1 1 1 1 (Or.inr rfl) (Or.inr rfl) (Or.inr rfl) (Or.inr rfl) (by decide) (by decide)
  have hl : hexLhs one R 1 1 1 1 = one := rfl
  have hr : hexRhs one R 1 1 1 1 = mul (mul (mul one R) one) R := rfl
  rw [hl, hr, gz_one_mul, gz_mul_one] at h1
  exact h1.symm

/-! ### The two readings agree on the units. -/

/-- **AGREEMENT.**  If `R` is a unit then `conj R` is its one and only inverse,
    so the written hexagon and the named hexagon are the same proposition. -/
theorem hexInv_iff_hexAtInverses_of_isUnit {f R : GZ} (hR : IsUnit R) :
    hexInvHolds f R ↔ HexAtInverses f R := by
  constructor
  · intro h S hS
    rw [inv_eq_conj_of_isUnit hR hS]
    exact h
  · intro h
    exact h (conj R) (mul_conj_of_isUnit hR)

/-! ### …and diverge off them, at an explicit witness. -/

/-- The witness: `1 + i`, norm 2. -/
def onePlusI : GZ := ⟨1, 1⟩

theorem onePlusI_norm : norm onePlusI = 2 := rfl

/-- **There is NO inverse braiding for `1+i`** — `IsUnit` unfolded is exactly the
    existence statement, so this is the literal claim that reading (ii) has no
    subject here. -/
theorem onePlusI_has_no_inverse : ¬ ∃ S : GZ, mul onePlusI S = one := by
  rw [show (∃ S : GZ, mul onePlusI S = one) = IsUnit onePlusI from rfl,
      isUnit_iff_norm_one, onePlusI_norm]
  decide

/-- **Reading (ii) is TRUE at the witness — vacuously**, and the vacuity is
    stated, not hidden: it is true precisely because `onePlusI_has_no_inverse`
    says the quantifier is empty.  Recorded as a finding, not as evidence. -/
theorem hexAtInverses_onePlusI : HexAtInverses one onePlusI :=
  fun S hS => absurd ⟨S, hS⟩ onePlusI_has_no_inverse

/-- **Reading (i) is FALSE at the witness**, and not vacuously: the hexagon at
    `conj (1+i) = 1−i` is a real constraint and `(1−i)² = −2i ≠ 1`. -/
theorem hexInv_fails_onePlusI : ¬ hexInvHolds one onePlusI := by
  intro h
  have hs : mul (conj onePlusI) (conj onePlusI) = one := hexagon_one_forces_sq h
  exact absurd hs (by decide)

/-- **THE VERDICT.**  `hexInvHolds` is the GALOIS-CONJUGATE hexagon, not the
    inverse-braiding hexagon.  The two names agree on every unit and separate at
    `1+i`, where the conjugate exists and the inverse does not. -/
theorem hexInv_is_not_hexAtInverses :
    ¬ (∀ f R : GZ, hexInvHolds f R ↔ HexAtInverses f R) := fun h =>
  hexInv_fails_onePlusI ((h one onePlusI).mpr hexAtInverses_onePlusI)

/-- The seal's `conj R` is not even a one-sided inverse at the witness: it is off
    by the norm, exactly as in Section 2. -/
theorem onePlusI_conj_not_inverse : mul onePlusI (conj onePlusI) = ⟨2, 0⟩ := rfl

/-! ############################################################################
    SECTION 4 — THE HEADLINE.

    The seal's down slots hold the symbol `conj`.  Two readings of that symbol:
      (T) it is THE INVERSE — the coefficient module is `Z[i]^x` with `Z_2`
          acting TRIVIALLY, and the alternating differential wants inverses;
      (G) it is SIGMA — the Galois automorphism, i.e. `Z_2` acting NON-trivially.
    Reading (T) does not determine a total function: off the units there is no
    inverse to name, so (T) is a family of total functions, one for each way of
    extending inversion off the units.  `InvertsUnits` is exactly that family.

    (a) EVERY member of the family induces the SAME gauge action, the SAME gauge
        equivalence and hence the SAME quotient as `conj`.  So no sealed theorem,
        all of which quantify over unit-valued gauges, can distinguish (T) from
        (G).  This is a statement about the record.
    (b) The family is not a singleton: two of its members differ, with an
        explicit witness, off the units.  So there really are two readings and
        the record really is silent about which one it wrote.
    ############################################################################ -/

/-- A total map `s : Z[i] → Z[i]` **implements inversion** when it returns a
    genuine multiplicative inverse at every unit.  Off the units it is
    unconstrained — because there is nothing there to constrain it to. -/
def InvertsUnits (s : GZ → GZ) : Prop := ∀ u : GZ, IsUnit u → mul u (s u) = one

/-- The seal's gauge factor with the two down slots read through `s`. -/
def gaugePhiWith (s : GZ → GZ) (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (g a b) (g ((a + b) % 2) c)) (mul (s (g b c)) (s (g a ((b + c) % 2))))

/-- The seal's gauge action with the two down slots read through `s`. -/
def gaugeActWith (s : GZ → GZ) (g : Int → Int → GZ) (F : Int → Int → Int → GZ)
    (a b c : Int) : GZ := mul (F a b c) (gaugePhiWith s g a b c)

/-- The seal's gauge equivalence with the two down slots read through `s`. -/
def GaugeEquivWith (s : GZ → GZ) (F F' : Int → Int → Int → GZ) : Prop :=
  ∃ g : Int → Int → GZ, (∀ a b : Int, IsUnit (g a b)) ∧
    ∀ a b c : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
      gaugeActWith s g F a b c = F' a b c

/-- The seal's own reading is the case `s = conj`, on the nose. -/
theorem gaugePhiWith_conj (g : Int → Int → GZ) (a b c : Int) :
    gaugePhiWith conj g a b c = gaugePhi g a b c := rfl

theorem gaugeActWith_conj (g : Int → Int → GZ) (F : Int → Int → Int → GZ) (a b c : Int) :
    gaugeActWith conj g F a b c = gaugeAct g F a b c := rfl

theorem gaugeEquivWith_conj (F F' : Int → Int → Int → GZ) :
    GaugeEquivWith conj F F' ↔ GaugeEquivOnLabels F F' := Iff.rfl

/-- …and `conj` is in the family: reading (G) is one of the readings (T) allows.
    This is the collision the whole file is about. -/
theorem conj_invertsUnits : InvertsUnits conj := fun _ hu => mul_conj_of_isUnit hu

/-! ### (a) — AGREEMENT ON THE UNITS. -/

/-- **Any two implementations of inversion agree at every unit.**  Uniqueness of
    inverses in a domain does the work; nothing about `Z[i]` beyond that. -/
theorem invertsUnits_agree {s t : GZ → GZ} (hs : InvertsUnits s) (ht : InvertsUnits t)
    {u : GZ} (hu : IsUnit u) : s u = t u :=
  inv_unique (hs u hu) (ht u hu)

/-- …and in particular every one of them agrees with the seal's `conj`. -/
theorem invertsUnits_eq_conj {s : GZ → GZ} (hs : InvertsUnits s) {u : GZ} (hu : IsUnit u) :
    s u = conj u := invertsUnits_agree hs conj_invertsUnits hu

/-- **The gauge factor does not see the choice**, on unit-valued gauges. -/
theorem gaugePhiWith_eq_gaugePhi_of_units {s : GZ → GZ} (hs : InvertsUnits s)
    {g : Int → Int → GZ} (hg : ∀ a b : Int, IsUnit (g a b)) (a b c : Int) :
    gaugePhiWith s g a b c = gaugePhi g a b c := by
  show mul (mul (g a b) (g ((a + b) % 2) c)) (mul (s (g b c)) (s (g a ((b + c) % 2))))
      = mul (mul (g a b) (g ((a + b) % 2) c))
            (mul (conj (g b c)) (conj (g a ((b + c) % 2))))
  rw [invertsUnits_eq_conj hs (hg b c), invertsUnits_eq_conj hs (hg a ((b + c) % 2))]

/-- **Nor does the gauge action.** -/
theorem gaugeActWith_eq_gaugeAct_of_units {s : GZ → GZ} (hs : InvertsUnits s)
    {g : Int → Int → GZ} (hg : ∀ a b : Int, IsUnit (g a b))
    (F : Int → Int → Int → GZ) (a b c : Int) :
    gaugeActWith s g F a b c = gaugeAct g F a b c := by
  show mul (F a b c) (gaugePhiWith s g a b c) = mul (F a b c) (gaugePhi g a b c)
  rw [gaugePhiWith_eq_gaugePhi_of_units hs hg]

/-- **HEADLINE (a).**  The seal's gauge equivalence is INVARIANT under the
    choice: for every total implementation `s` of inversion, `GaugeEquivWith s`
    is the very same relation as the seal's `GaugeEquivOnLabels`.  The relation
    is what `GaugeClasses` quotients by, so the classes, the class group and
    every statement about them are unchanged.  Replacing "the inverse" by
    "sigma" in the down slots is INVISIBLE to the record. -/
theorem gaugeEquivWith_iff_gaugeEquivOnLabels {s : GZ → GZ} (hs : InvertsUnits s)
    (F F' : Int → Int → Int → GZ) : GaugeEquivWith s F F' ↔ GaugeEquivOnLabels F F' := by
  constructor
  · intro h
    obtain ⟨g, hg, hgF⟩ := h
    refine ⟨g, hg, fun a b c ha hb hc => ?_⟩
    rw [← gaugeActWith_eq_gaugeAct_of_units hs hg F a b c]
    exact hgF a b c ha hb hc
  · intro h
    obtain ⟨g, hg, hgF⟩ := h
    refine ⟨g, hg, fun a b c ha hb hc => ?_⟩
    rw [gaugeActWith_eq_gaugeAct_of_units hs hg F a b c]
    exact hgF a b c ha hb hc

/-- The same invariance for `gaugeInv` itself, which is the seal's other
    inversion-shaped operation. -/
def gaugeInvWith (s : GZ → GZ) (g : Int → Int → GZ) : Int → Int → GZ := fun a b => s (g a b)

theorem gaugeInvWith_eq_gaugeInv_of_units {s : GZ → GZ} (hs : InvertsUnits s)
    {g : Int → Int → GZ} (hg : ∀ a b : Int, IsUnit (g a b)) :
    gaugeInvWith s g = gaugeInv g := by
  funext a b
  exact invertsUnits_eq_conj hs (hg a b)

/-! ### (b) — DIVERGENCE OFF THE UNITS, with an explicit witness. -/

/-- A second implementation of inversion: `conj` on the units (where it must be)
    and the identity everywhere else (where nothing constrains it).  This is a
    legitimate reading (T) and it is not `conj`. -/
def sigmaAlt (z : GZ) : GZ := if norm z = 1 then conj z else z

theorem sigmaAlt_invertsUnits : InvertsUnits sigmaAlt := by
  intro u hu
  have hn : norm u = 1 := (isUnit_iff_norm_one u).mp hu
  show mul u (if norm u = 1 then conj u else u) = one
  rw [if_pos hn]
  exact mul_conj_of_isUnit hu

/-- The two implementations part company at `1+i`. -/
theorem sigmaAlt_ne_conj_at_onePlusI : sigmaAlt onePlusI ≠ conj onePlusI := by decide

/-- **The gauge factors part company there too.**  Read as sigma: `4`.  Read as
    an inverse extended by the identity: `−4`.  Same formula, same gauge, two
    values — and no sealed theorem can be applied to either, because the gauge is
    not unit-valued. -/
theorem gaugePhiWith_sigmaAlt_gPlusI (a b c : Int) :
    gaugePhiWith sigmaAlt gPlusI a b c = ⟨-4, 0⟩ := rfl

theorem gaugePhi_ne_gaugePhiWith_sigmaAlt :
    gaugePhiWith sigmaAlt gPlusI 0 0 0 ≠ gaugePhi gPlusI 0 0 0 := by
  rw [gaugePhiWith_sigmaAlt_gPlusI, gaugePhi_gPlusI]
  decide

/-- **HEADLINE (b).**  The family of readings is not a singleton: two members of
    it disagree on an explicit gauge. -/
theorem readings_differ_off_units :
    ∃ s : GZ → GZ, InvertsUnits s ∧
      ∃ g : Int → Int → GZ, ∃ a b c : Int, gaugePhiWith s g a b c ≠ gaugePhi g a b c :=
  ⟨sigmaAlt, sigmaAlt_invertsUnits, gPlusI, 0, 0, 0, gaugePhi_ne_gaugePhiWith_sigmaAlt⟩

/-- …and the divergence survives into the gauge ACTION, not merely the factor:
    at the boson symbol the two readings give `4` and `−4`. -/
theorem gaugeAct_readings_differ :
    gaugeActWith sigmaAlt gPlusI (sliceCore one) 0 0 0
      ≠ gaugeAct gPlusI (sliceCore one) 0 0 0 := by decide

/-- **THE HEADLINE, both halves in one statement.**  (a) says the record cannot
    tell the trivial action from the Galois action; (b) says there is something
    to tell.  Together: the non-trivial action has been in the record all along,
    unnamed, invisible BY HYPOTHESIS — every gauge theorem the seal states
    quantifies over unit-valued gauges, and that is exactly the set on which the
    two readings coincide. -/
theorem reading_C_headline :
    (∀ s : GZ → GZ, InvertsUnits s → ∀ F F' : Int → Int → Int → GZ,
        GaugeEquivWith s F F' ↔ GaugeEquivOnLabels F F') ∧
    (∃ s : GZ → GZ, InvertsUnits s ∧
        ∃ g : Int → Int → GZ, ∃ a b c : Int, gaugePhiWith s g a b c ≠ gaugePhi g a b c) :=
  ⟨fun _s hs F F' => gaugeEquivWith_iff_gaugeEquivOnLabels hs F F', readings_differ_off_units⟩

/-- Non-vacuity for (a): the invariant relation is inhabited.  `GaugeEquivOnLabels`
    holds reflexively at the trivial gauge, so (a) is not a statement about an
    empty relation. -/
theorem gaugeAct_trivial (F : Int → Int → Int → GZ) (a b c : Int) :
    gaugeAct gaugeTrivial F a b c = mul (F a b c) one := rfl

theorem gaugeEquivOnLabels_refl (F : Int → Int → Int → GZ) : GaugeEquivOnLabels F F :=
  ⟨gaugeTrivial, gaugeTrivial_isUnit, fun a b c _ _ _ => by
    rw [gaugeAct_trivial]; exact gz_mul_one _⟩

theorem gaugeEquivWith_inhabited {s : GZ → GZ} (hs : InvertsUnits s)
    (F : Int → Int → Int → GZ) : GaugeEquivWith s F F :=
  (gaugeEquivWith_iff_gaugeEquivOnLabels hs F F).mpr (gaugeEquivOnLabels_refl F)

/-! ############################################################################
    SECTION 5 — is `conj` distinguished among the near-mirrors, and would the
    seal's controls have caught a Galois-action substitution?

    `fakeMirror (a,b) = (a, 2b)` is the seal's own control: additive, fixes the
    first coordinate, NOT multiplicative.  Reading C puts `conj` and `fakeMirror`
    on one spectrum and asks the kernel where each sits — and then asks the
    sharper question, which is not about the spectrum at all.

    SCOPE, stated: the family below is the `Z`-LINEAR self-maps fixing the first
    coordinate.  "Every additive map is `Z`-linear" is true and is NOT proved
    here (it needs an induction over `Int` this file does not build), so the
    characterisation is within the linear family and is claimed only there.
    ############################################################################ -/

/-- The `Z`-linear self-maps of `Z[i]` that fix the first coordinate: `r` is the
    leak from `re` into `im`, `s` is the scale on `im`.  `conj` is `(0,−1)`,
    the identity is `(0,1)`, and the seal's `fakeMirror` is `(0,2)`. -/
def mirrorRS (r s : Int) (z : GZ) : GZ := ⟨z.re, r * z.re + s * z.im⟩

theorem mirrorRS_id (z : GZ) : mirrorRS 0 1 z = z := by
  apply GZ.eq_of
  · rfl
  · show 0 * z.re + 1 * z.im = z.im
    omega

theorem mirrorRS_conj (z : GZ) : mirrorRS 0 (-1) z = conj z := by
  apply GZ.eq_of
  · rfl
  · show 0 * z.re + (-1) * z.im = -z.im
    omega

theorem mirrorRS_fakeMirror (z : GZ) : mirrorRS 0 2 z = fakeMirror z := by
  apply GZ.eq_of
  · rfl
  · show 0 * z.re + 2 * z.im = 2 * z.im
    omega

/-- Every member of the family is additive and fixes the first coordinate — so
    the two properties the seal's docstring names for `fakeMirror` are shared by
    the whole family and single nothing out. -/
theorem mirrorRS_add (r s : Int) (z w : GZ) :
    mirrorRS r s (add z w) = add (mirrorRS r s z) (mirrorRS r s w) := by
  apply GZ.eq_of
  · rfl
  · show r * (z.re + w.re) + s * (z.im + w.im)
        = (r * z.re + s * z.im) + (r * w.re + s * w.im)
    grind

theorem mirrorRS_re (r s : Int) (z : GZ) : (mirrorRS r s z).re = z.re := rfl

/-- **MULTIPLICATIVITY PINS THE FAMILY DOWN TO TWO POINTS.**  A `Z`-linear map
    fixing `re` is multiplicative iff the leak `r` vanishes and the scale `s` is
    `±1`.  The seal's restriction to `r = 0` is therefore not a choice — it is
    forced — and `s = 2` (`fakeMirror`) is the nearest integer miss. -/
theorem mirrorRS_mul_iff (r s : Int) :
    (∀ z w : GZ, mirrorRS r s (mul z w) = mul (mirrorRS r s z) (mirrorRS r s w))
      ↔ (r = 0 ∧ (s = 1 ∨ s = -1)) := by
  constructor
  · intro h
    have hr : r = 0 := by
      have h1 := congrArg GZ.im (h one one)
      simp only [mirrorRS, mul, one] at h1
      omega
    subst hr
    have h2 := congrArg GZ.re (h I I)
    simp only [mirrorRS, mul, I] at h2
    have hs2 : s * s = 1 := by grind
    obtain ⟨hb, hb'⟩ := bound_of_sq_le_one (Int.le_of_eq hs2)
    have hcase : s = -1 ∨ s = 0 ∨ s = 1 := by omega
    refine ⟨rfl, ?_⟩
    rcases hcase with hc | hc | hc
    · exact Or.inr hc
    · subst hc; exact absurd hs2 (by decide)
    · exact Or.inl hc
  · intro h
    obtain ⟨hr, hs⟩ := h
    subst hr
    rcases hs with hs | hs
    · subst hs
      intro z w
      rw [mirrorRS_id, mirrorRS_id, mirrorRS_id]
    · subst hs
      intro z w
      rw [mirrorRS_conj, mirrorRS_conj, mirrorRS_conj]
      exact (conj_mul z w).symm

/-- **…and the two points are the identity and `conj`.**  So `conj` is the ONLY
    non-trivial multiplicative near-mirror: it is distinguished, and the seal's
    control is a test it passes. -/
theorem multiplicative_mirrors_are_exactly_two (r s : Int) :
    (∀ z w : GZ, mirrorRS r s (mul z w) = mul (mirrorRS r s z) (mirrorRS r s w))
      ↔ ((∀ z : GZ, mirrorRS r s z = z) ∨ (∀ z : GZ, mirrorRS r s z = conj z)) := by
  constructor
  · intro h
    obtain ⟨hr, hs⟩ := (mirrorRS_mul_iff r s).mp h
    subst hr
    rcases hs with hs | hs
    · subst hs; exact Or.inl mirrorRS_id
    · subst hs; exact Or.inr mirrorRS_conj
  · intro h z w
    rcases h with h | h
    · rw [h, h, h]
    · rw [h, h, h]; exact (conj_mul z w).symm

/-- The seal's control, refuted by the kernel at the seal's own witness. -/
theorem fakeMirror_witness : fakeMirror (mul I I) ≠ mul (fakeMirror I) (fakeMirror I) := by decide

theorem fakeMirror_not_mul :
    ¬ (∀ z w : GZ, fakeMirror (mul z w) = mul (fakeMirror z) (fakeMirror w)) :=
  fun h => fakeMirror_witness (h I I)

/-- `fakeMirror` is the family point `s = 2`, and `2 ∉ {1, −1}` — so its failure
    is an instance of the characterisation, not an accident of the witness. -/
theorem fakeMirror_fails_by_characterisation :
    ¬ (∀ z w : GZ, mirrorRS 0 2 (mul z w) = mul (mirrorRS 0 2 z) (mirrorRS 0 2 w)) := by
  intro h
  obtain ⟨_, hs⟩ := (mirrorRS_mul_iff 0 2).mp h
  rcases hs with hs | hs <;> exact absurd hs (by decide)

/-! ### The battery, and the sharper question. -/

/-- The seal's mirror controls, as a predicate on a candidate map: additive,
    fixes the first coordinate, multiplicative.  `fakeMirror` was written to fail
    the third. -/
def PassesMirrorControls (m : GZ → GZ) : Prop :=
  (∀ z w : GZ, m (add z w) = add (m z) (m w)) ∧
  (∀ z : GZ, (m z).re = z.re) ∧
  (∀ z w : GZ, m (mul z w) = mul (m z) (m w))

theorem conj_add' (z w : GZ) : conj (add z w) = add (conj z) (conj w) :=
  (conj_add z w).symm

theorem conj_passesControls : PassesMirrorControls conj :=
  ⟨conj_add', fun _ => rfl, fun z w => (conj_mul z w).symm⟩

theorem fakeMirror_failsControls : ¬ PassesMirrorControls fakeMirror :=
  fun h => fakeMirror_not_mul h.2.2

/-- **`conj` and `fakeMirror` are NOT on the same spectrum.**  `conj` passes
    every control `fakeMirror` was built to fail.  So the seal's control set,
    applied to the symbol in the down slots, returns "fine". -/
theorem conj_and_fakeMirror_separate :
    PassesMirrorControls conj ∧ ¬ PassesMirrorControls fakeMirror :=
  ⟨conj_passesControls, fakeMirror_failsControls⟩

/-- **THE SHARPER ANSWER: the controls are irrelevant to the substitution.**
    `sigmaAlt` FAILS the battery outright — it is not even additive — and yet it
    implements inversion on the units and induces EXACTLY the seal's gauge
    equivalence.  So passing or failing the mirror controls has no bearing on
    what happens in the gauge layer: the controls could not have caught a
    Galois-action substitution, because the substitution is invisible on the
    only set the gauge layer looks at. -/
theorem sigmaAlt_failsControls : ¬ PassesMirrorControls sigmaAlt := by
  intro h
  have hw := h.1 I I
  exact absurd hw (by decide)

theorem controls_are_blind_to_the_substitution :
    ¬ PassesMirrorControls sigmaAlt ∧ InvertsUnits sigmaAlt ∧
      (∀ F F' : Int → Int → Int → GZ,
        GaugeEquivWith sigmaAlt F F' ↔ GaugeEquivOnLabels F F') :=
  ⟨sigmaAlt_failsControls, sigmaAlt_invertsUnits,
   fun F F' => gaugeEquivWith_iff_gaugeEquivOnLabels sigmaAlt_invertsUnits F F'⟩

/-- The mirror image of the same point: `conj` PASSES every control, and is still
    not an inverse — Section 2's counterexample is exactly that.  A map can pass
    the whole battery and fail to be what the surrounding text calls it. -/
theorem passing_controls_does_not_make_an_inverse :
    PassesMirrorControls conj ∧ mul onePlusI (conj onePlusI) ≠ one :=
  ⟨conj_passesControls, by decide⟩

/-! ############################################################################
    AXIOM AUDIT — appended by the counter-prover.

    This file shipped WITHOUT one, unlike C6_ActionA.lean which carries 88
    `#print axioms` lines for 88 theorems.  Its header claims the discipline
    ("no sorry, no admit, no axiom, no native_decide") and then does not
    mechanically check it.  A claimed discipline that is not exercised is the
    same species as rate.py's self-test, which passes lean_spec=None in all
    three probes and so never exercises the column it is trusted for.

    Every theorem in this file, not a curated sample.  `sorryAx` must not
    appear.  Result at the time of appending: 110 theorems audited, 0 sorryAx,
    39 axiom-free, 71 depending only on Lean's standard propext /
    Classical.choice / Quot.sound.
    ############################################################################ -/
#print axioms GZ
#print axioms band_left
#print axioms band_right
#print axioms allBool_sound
#print axioms allBool_complete
#print axioms lab_isLabel
#print axioms exists_bool_of_isLabel
#print axioms gz_mul_comm
#print axioms gz_mul_assoc
#print axioms gz_one_mul
#print axioms gz_mul_one
#print axioms conj_mul
#print axioms conj_add
#print axioms conj_one
#print axioms conj_conj
#print axioms mul_conj_eq_norm
#print axioms norm_mul
#print axioms norm_conj
#print axioms norm_nonneg
#print axioms sq_nonneg
#print axioms bound_of_sq_le_one
#print axioms unit_is_four
#print axioms isUnit_of_mul_conj
#print axioms isUnit_iff_norm_one
#print axioms mul_conj_of_isUnit
#print axioms isUnit_mul
#print axioms isUnit_conj
#print axioms isUnit_one
#print axioms inv_unique
#print axioms inv_eq_conj_of_isUnit
#print axioms act_isUnit
#print axioms agreeOK_sound
#print axioms agreeOK_complete
#print axioms not_agreeOnLabels_of_false
#print axioms d2raw_isUnit
#print axioms d2sig_isUnit
#print axioms gPlusI_norm
#print axioms gPlusI_not_isUnit
#print axioms gaugePhi_gPlusI
#print axioms four_not_isUnit
#print axioms gaugePhi_gPlusI_not_unit_raw_coboundary
#print axioms gaugePhi_gPlusI_not_unit_sig_coboundary
#print axioms gz_rearrange
#print axioms gaugePhi_eq_d2raw_gaugeInv
#print axioms gaugePhi_gPlusI_is_raw_coboundary
#print axioms hSig_norm
#print axioms hSig_not_isUnit
#print axioms gaugePhi_gPlusI_is_sig_coboundary
#print axioms sig_witness_value
#print axioms gaugeInv_gPlusI_fails_sig
#print axioms gaugeComp_assoc
#print axioms gaugeComp_comm
#print axioms gaugeTrivial_left_unit
#print axioms gaugeComp_gaugeInv
#print axioms gaugeComp_gaugeInv_gPlusI
#print axioms gaugeInv_not_inverse
#print axioms mul_conj_eq_one_iff_isUnit
#print axioms gaugeInv_isInverse_iff
#print axioms gaugeInv_isInverse_iff_norm
#print axioms gaugeTrivial_isUnit
#print axioms gaugeInv_isInverse_at_trivial
#print axioms gPlusI_outside
#print axioms hexOK_sound
#print axioms hexagon_at_one_one
#print axioms hexInv_at_one_one
#print axioms hexagon_one_forces_sq
#print axioms hexInv_iff_hexAtInverses_of_isUnit
#print axioms onePlusI_norm
#print axioms onePlusI_has_no_inverse
#print axioms hexAtInverses_onePlusI
#print axioms hexInv_fails_onePlusI
#print axioms hexInv_is_not_hexAtInverses
#print axioms onePlusI_conj_not_inverse
#print axioms gaugePhiWith_conj
#print axioms gaugeActWith_conj
#print axioms gaugeEquivWith_conj
#print axioms conj_invertsUnits
#print axioms invertsUnits_agree
#print axioms invertsUnits_eq_conj
#print axioms gaugePhiWith_eq_gaugePhi_of_units
#print axioms gaugeActWith_eq_gaugeAct_of_units
#print axioms gaugeEquivWith_iff_gaugeEquivOnLabels
#print axioms gaugeInvWith_eq_gaugeInv_of_units
#print axioms sigmaAlt_invertsUnits
#print axioms sigmaAlt_ne_conj_at_onePlusI
#print axioms gaugePhiWith_sigmaAlt_gPlusI
#print axioms gaugePhi_ne_gaugePhiWith_sigmaAlt
#print axioms readings_differ_off_units
#print axioms gaugeAct_readings_differ
#print axioms reading_C_headline
#print axioms gaugeAct_trivial
#print axioms gaugeEquivOnLabels_refl
#print axioms gaugeEquivWith_inhabited
#print axioms mirrorRS_id
#print axioms mirrorRS_conj
#print axioms mirrorRS_fakeMirror
#print axioms mirrorRS_add
#print axioms mirrorRS_re
#print axioms mirrorRS_mul_iff
#print axioms multiplicative_mirrors_are_exactly_two
#print axioms fakeMirror_witness
#print axioms fakeMirror_not_mul
#print axioms fakeMirror_fails_by_characterisation
#print axioms conj_add
#print axioms conj_passesControls
#print axioms fakeMirror_failsControls
#print axioms conj_and_fakeMirror_separate
#print axioms sigmaAlt_failsControls
#print axioms controls_are_blind_to_the_substitution
#print axioms passing_controls_does_not_make_an_inverse
