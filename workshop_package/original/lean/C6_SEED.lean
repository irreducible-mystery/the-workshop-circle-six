/-
  C6_SEED.lean — the seal's DEFINITIONS, and none of its answers.

  Extracted mechanically from Circle Five's sealed `C5_QA_v8.lean`: every
  `def`, `structure`, `abbrev`, `inductive` and `instance` block with its
  docstring, in file order. **Zero theorems.** Verified with the record's own
  predicate: `^theorem [A-Za-z_0-9].*:` returns nothing in this file.

  This is Circle Five's constraint, not the proposer's, and it is a better
  design than the one it replaced. In its prover's words:

    "Don't let Circle Six read this circle's answer. Give it the seal and the
     charge, not the closing documents or the capstone. If it rediscovers
     H3 = Z2 from the seal alone that's a second sample; handed the answer, it
     can only agree -- and agreement is what novelty has to be able to
     withdraw."

  So the inheritance stays at zero prose, and now zero theorems with it. The
  budget holds even for the true things.

  NOT GUARANTEED TO COMPILE STANDALONE. The definitions were taken without the
  automation set and without whatever else the elaborator wants in support.
  Making it compile is this circle's first problem, and a real one.
-/

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

/-- **THE GAUGE QUOTIENT** — the type of classes the sealed record named
    as not constructed. -/
def GaugeClasses : Type := Classes IsClassifiedSymbol GaugeEquivOnLabels

/-- The two classes, indexed by a two-element type. -/
def classOfBool : Bool → GaugeClasses
  | false => cls ⟨sliceCore one, boson_classified⟩
  | true  => cls ⟨sliceCore (neg one), fermion_classified⟩

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

/-- The units of `Z[i]`.  A subtype, so membership is carried by the
    element and never decided. -/
def Un : Type := { u : GZ // IsUnit u }

def one' : Un := ⟨one, IsUnit_one⟩

def mul' (u v : Un) : Un := ⟨mul u.val v.val, IsUnit_mul _ _ u.property v.property⟩

def inv' (u : Un) : Un := ⟨conj u.val, IsUnit_conj _ u.property⟩

/-- **R7 MET.** `Z[i]^x` is an abelian group, constructed. -/
def unitGroup : AbGroup Un where
  op := Un.mul'
  e := Un.one'
  inv := Un.inv'
  assoc := Un.mul_assoc'
  comm := Un.mul_comm'
  unit := Un.one_mul'
  invl := Un.inv_mul'

/-- **R6 MET.** `Z_2` is an abelian group, constructed. -/
def z2Group : AbGroup Bool where
  op := xor
  e := false
  inv := fun b => b
  assoc := by intro x y z; cases x <;> cases y <;> cases z <;> rfl
  comm := by intro x y; cases x <;> cases y <;> rfl
  unit := by intro x; cases x <;> rfl
  invl := by intro x; cases x <;> rfl

/-- The bridge from the index group to the seal's integer labels. -/
def lab : Bool → Int := fun b => if b then 1 else 0

def Coch1 : Type := Bool → Un

def Coch2 : Type := Bool → Bool → Un

def Coch3 : Type := Bool → Bool → Bool → Un

def Coch4 : Type := Bool → Bool → Bool → Bool → Un

def c2op (g h : Coch2) : Coch2 := fun a b => Un.mul' (g a b) (h a b)

def c2e : Coch2 := fun _ _ => Un.one'

def c2inv (g : Coch2) : Coch2 := fun a b => Un.inv' (g a b)

def c3op (f g : Coch3) : Coch3 := fun a b c => Un.mul' (f a b c) (g a b c)

def c3e : Coch3 := fun _ _ _ => Un.one'

def c3inv (f : Coch3) : Coch3 := fun a b c => Un.inv' (f a b c)

def c4op (f g : Coch4) : Coch4 := fun a b c d => Un.mul' (f a b c d) (g a b c d)

def c4e : Coch4 := fun _ _ _ _ => Un.one'

def c4inv (f : Coch4) : Coch4 := fun a b c d => Un.inv' (f a b c d)

/-- **R1, the groups.** Each grade is an abelian group, pointwise. -/
def coch2Group : AbGroup Coch2 where
  op := c2op
  e := c2e
  inv := c2inv
  assoc := by intro x y z; funext a b; exact Un.mul_assoc' _ _ _
  comm := by intro x y; funext a b; exact Un.mul_comm' _ _
  unit := by intro x; funext a b; exact Un.one_mul' _
  invl := by intro x; funext a b; exact Un.inv_mul' _

def coch3Group : AbGroup Coch3 where
  op := c3op
  e := c3e
  inv := c3inv
  assoc := by intro x y z; funext a b c; exact Un.mul_assoc' _ _ _
  comm := by intro x y; funext a b c; exact Un.mul_comm' _ _
  unit := by intro x; funext a b c; exact Un.one_mul' _
  invl := by intro x; funext a b c; exact Un.inv_mul' _

def coch4Group : AbGroup Coch4 where
  op := c4op
  e := c4e
  inv := c4inv
  assoc := by intro x y z; funext a b c d; exact Un.mul_assoc' _ _ _
  comm := by intro x y; funext a b c d; exact Un.mul_comm' _ _
  unit := by intro x; funext a b c d; exact Un.one_mul' _
  invl := by intro x; funext a b c d; exact Un.inv_mul' _

/-- `d^2 : C^2 -> C^3`. -/
def d2 (g : Coch2) : Coch3 := fun a b c =>
  Un.mul' (Un.mul' (g b c) (Un.inv' (g (xor a b) c)))
          (Un.mul' (g a (xor b c)) (Un.inv' (g a b)))

/-- `d^3 : C^3 -> C^4`. -/
def d3 (f : Coch3) : Coch4 := fun a b c d =>
  Un.mul' (Un.mul' (Un.mul' (f b c d) (Un.inv' (f (xor a b) c d)))
                   (Un.mul' (f a (xor b c) d) (Un.inv' (f a b (xor c d)))))
          (f a b c)

/-- The `d^2` coboundary written in the seal's own label arithmetic, so it
    can be compared with `gaugePhi` without any translation layer. -/
def d2raw (g : Int → Int → GZ) (a b c : Int) : GZ :=
  mul (mul (g b c) (conj (g ((a + b) % 2) c))) (mul (g a ((b + c) % 2)) (conj (g a b)))

/-- **R3 MET.** The 3-cocycles: the kernel of `d^3`. -/
def IsCocycle3 (f : Coch3) : Prop := d3 f = c4e

def face1 (g : Coch2) : Coch3 := fun _ b c => g b c

def face2 (g : Coch2) : Coch3 := fun a b c => g (xor a b) c

def face3 (g : Coch2) : Coch3 := fun a b c => g a (xor b c)

def face4 (g : Coch2) : Coch3 := fun a b _ => g a b

/-- The 3-coboundaries: the image of `d^2`. -/
def IsCoboundary3 (f : Coch3) : Prop := ∃ g : Coch2, d2 g = f

/-- The cocycle group, as a subtype carrying its membership. -/
def Z3 : Type := { f : Coch3 // IsCocycle3 f }

/-- Two cocycles are cohomologous when they differ by a coboundary — the
    subgroup relation, not an arbitrary equivalence. -/
def CohomRel (x y : Z3) : Prop := IsCoboundary3 (c3op x.val (c3inv y.val))

/-- **R4 MET.**  `H^3` — the quotient of the cocycle group by the
    coboundary subgroup.  A group is quotiented, and it is quotiented BY a
    subgroup: the relation is membership of the difference in the image of
    `d^2`, and `coboundary_one`, `coboundary_mul` and `coboundary_inv` are
    what make that a subgroup rather than a set of elements. -/
def H3 : Type := Quot CohomRel

/-- The class map. -/
def cohomClass (x : Z3) : H3 := Quot.mk CohomRel x

/-- The label decoder: `Int` to `Bool`, inverse to `lab` on the labels. -/
def boolOf (i : Int) : Bool := if i = 1 then true else false

/-- A 3-cochain, extended to a symbol on all of `Int³` through the
    decoder.  Off the labels it repeats boundary values; the sealed
    pentagon never looks there. -/
def symbolOf (f : Coch3) : Int → Int → Int → GZ :=
  fun a b c => (f (boolOf a) (boolOf b) (boolOf c)).val

/-- **THE MAP** — cocycles to the sealed record's gauge classes. -/
def classOfCocycle (x : Z3) : GaugeClasses :=
  cls ⟨symbolOf x.val, symbolOf_classified x.property⟩

/-- The fermion cochain: `−1` on the top cell, `1` elsewhere — the
    cochain whose symbol is the sealed fermion representative. -/
def fermionCochain : Coch3 :=
  fun a b c => cond (a && b && c) ⟨neg one, ⟨neg one, negOne_sq⟩⟩ Un.one'

/-- A `Bool`-indexed 2-cochain, read as an `Int`-indexed gauge.

    **NAMED CAREFULLY.**  The seal already has a `gaugeOf` at
    `Zi.lean:1668` which does something different — it extracts a gauge
    from a SYMBOL, by cases on two label pairs.  This one goes from a
    2-cochain.  The first draft of this section called it `gaugeOf` and
    collided with the sealed name; the collision is recorded because a
    seat grepping `gaugeOf` will find two unrelated constructions. -/
def gaugeFromCochain (G : Coch2) : Int → Int → GZ :=
  fun i j => (G (boolOf i) (boolOf j)).val

/-- An `Int`-indexed unit-valued gauge, read as a 2-cochain. -/
def cochainOfGauge (g : Int → Int → GZ) (hg : ∀ i j, IsUnit (g i j)) : Coch2 :=
  fun a b => ⟨g (lab a) (lab b), hg (lab a) (lab b)⟩

/-- The map, descended to the quotient. -/
def h3ToGaugeClasses : H3 → GaugeClasses :=
  Quot.lift classOfCocycle (fun _ _ h => classOfCocycle_descends h)

def z3op (x y : Z3) : Z3 := ⟨c3op x.val y.val, cocycle_mul x.property y.property⟩

def z3e : Z3 := ⟨c3e, cocycle_one⟩

def z3inv (x : Z3) : Z3 := ⟨c3inv x.val, cocycle_inv x.property⟩

/-- **`Z^3` is an abelian group.**  Every axiom is the cochain group's
    axiom carried across the subtype. -/
def z3Group : AbGroup Z3 where
  op := z3op
  e := z3e
  inv := z3inv
  assoc := by intro x y z; refine z3ext ?_; funext a b c; exact Un.mul_assoc' _ _ _
  comm := by intro x y; refine z3ext ?_; funext a b c; exact Un.mul_comm' _ _
  unit := by intro x; refine z3ext ?_; funext a b c; exact Un.one_mul' _
  invl := by intro x; refine z3ext ?_; funext a b c; exact Un.inv_mul' _

def h3op : H3 → H3 → H3 :=
  Quot.lift
    (fun x : Z3 =>
      Quot.lift (fun y : Z3 => cohomClass (z3op x y))
        (fun _ _ hy => Quot.sound (cohomRel_mul (cohomRel_refl x) hy)))
    (fun x x' hx => by
      funext p
      induction p using Quot.ind with
      | mk y => exact Quot.sound (cohomRel_mul hx (cohomRel_refl y)))

def h3e : H3 := cohomClass z3e

def h3inv : H3 → H3 :=
  Quot.lift (fun x : Z3 => cohomClass (z3inv x))
    (fun _ _ h => Quot.sound (cohomRel_inv h))

/-- **`H^3` IS AN ABELIAN GROUP.**  The quotient of the cocycle group by
    the coboundary subgroup, with the law the class map carries.

    Every axiom is proved by lifting to representatives and using the
    cochain group's corresponding axiom — which is available only because
    `coboundary_is_cocycle` put the coboundaries inside the cocycles, and
    that in turn needed `d3_d2`, the complex.  **The group law on `H^3` is
    the last thing the complex buys, and it could not have been built
    before it.** -/
def h3Group : AbGroup H3 where
  op := h3op
  e := h3e
  inv := h3inv
  assoc := by
    intro p q r
    induction p using Quot.ind with
    | mk x =>
      induction q using Quot.ind with
      | mk y =>
        induction r using Quot.ind with
        | mk z =>
          show h3op (h3op (cohomClass x) (cohomClass y)) (cohomClass z)
              = h3op (cohomClass x) (h3op (cohomClass y) (cohomClass z))
          rw [cohomClass_mul, cohomClass_mul, cohomClass_mul, cohomClass_mul]
          refine cohomClass_congr ?_
          funext a b c
          exact Un.mul_assoc' _ _ _
  comm := by
    intro p q
    induction p using Quot.ind with
    | mk x =>
      induction q using Quot.ind with
      | mk y =>
        show h3op (cohomClass x) (cohomClass y) = h3op (cohomClass y) (cohomClass x)
        rw [cohomClass_mul, cohomClass_mul]
        refine cohomClass_congr ?_
        funext a b c
        exact Un.mul_comm' _ _
  unit := by
    intro p
    induction p using Quot.ind with
    | mk x =>
      show h3op h3e (cohomClass x) = cohomClass x
      rw [cohomClass_one, cohomClass_mul]
      refine cohomClass_congr ?_
      funext a b c
      exact Un.one_mul' _
  invl := by
    intro p
    induction p using Quot.ind with
    | mk x =>
      show h3op (h3inv (cohomClass x)) (cohomClass x) = h3e
      rw [cohomClass_inv, cohomClass_mul, cohomClass_one]
      refine cohomClass_congr ?_
      funext a b c
      exact Un.inv_mul' _

def z3OfBool : Bool → Z3
  | false => z3e
  | true  => ⟨fermionCochain, fermion_cocycle⟩

/-- The map from the index group into the cohomology: the vacuum class and
    the fermion class. -/
def h3OfBool (b : Bool) : H3 := cohomClass (z3OfBool b)

/-- Pointwise product of symbols — the multiplication the coefficient
    ring already carries, lifted to symbols one label triple at a time. -/
def symMul (F G : Int → Int → Int → GZ) : Int → Int → Int → GZ :=
  fun a b c => mul (F a b c) (G a b c)

/-- The product on the classified domain. -/
def symMulDom
    (x y : Dom (Int → Int → Int → GZ) IsClassifiedSymbol) :
    Dom (Int → Int → Int → GZ) IsClassifiedSymbol :=
  ⟨symMul x.val y.val, IsClassifiedSymbol_mul x.property y.property⟩

/-- Multiplication by a fixed classified symbol, descended to classes in
    the second argument. -/
def classMulAux (x : Dom (Int → Int → Int → GZ) IsClassifiedSymbol) :
    GaugeClasses → GaugeClasses :=
  Quot.lift (fun y => (cls (symMulDom x y) : GaugeClasses))
    (fun _ _ hy => Quot.sound
      (gaugeEquivOnLabels_mul (gaugeEquivOnLabels_refl x.val) hy))

/-- **THE GROUP LAW ON THE CLASSES**, by descent: `Quot.lift` twice, with
    the congruence discharging both obligations.  No representative is
    chosen and no class membership is decided. -/
def classMul : GaugeClasses → GaugeClasses → GaugeClasses :=
  Quot.lift classMulAux (fun _ _ hx => classMulAux_congr hx)

/-- The vacuum class — the identity the symbols themselves single out. -/
def clsOne : GaugeClasses := cls ⟨sliceCore one, boson_classified⟩

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

/-- **QB's first clause, answered: the class set carries a group law this
    record constructs.**  Inversion is the identity map, because every
    class squares to the vacuum class. -/
def gaugeClassesGroupLaw : CommGroupLaw GaugeClasses where
  op       := classMul
  unit     := clsOne
  inv      := fun q => q
  op_assoc := classMul_assoc
  op_comm  := classMul_comm
  unit_op  := classMul_one
  inv_op   := classMul_self

def abGroupOfCommGroupLaw {α : Type} (G : CommGroupLaw α) : AbGroup α where
  op    := G.op
  e     := G.unit
  inv   := G.inv
  assoc := G.op_assoc
  comm  := G.op_comm
  unit  := G.unit_op
  invl  := G.inv_op

def commGroupLawOfAbGroup {α : Type} (G : AbGroup α) : CommGroupLaw α where
  op       := G.op
  unit     := G.e
  inv      := G.inv
  op_assoc := G.assoc
  op_comm  := G.comm
  unit_op  := G.unit
  inv_op   := G.invl

/-- **The sealed gauge classes, as an `AbGroup`** — the structure the other
    two objects of the headline are bundled in.  Nothing new is proved
    here: `classMul_assoc`, `classMul_comm`, `classMul_one` and
    `classMul_self` are the builder's, through `gaugeClassesGroupLaw`. This
    only puts them where the claim can cite them. -/
def gaugeClassesGroup : AbGroup GaugeClasses :=
  abGroupOfCommGroupLaw gaugeClassesGroupLaw
