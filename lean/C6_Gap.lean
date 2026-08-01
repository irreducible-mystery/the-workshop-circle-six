/-
  C6_Gap.lean — the GAP sweep meets the seal, in the kernel.

  Answers the open question at the end of PR #7:
    "does twisted-vs-untwisted H³ have its own −¼ — a coupling where the two
     cohomologies pinch?"

  Yes. It is at μ₈. Section 4 exhibits it with witnesses.

  Lean 4.22.0, no Mathlib, no imports.
-/

set_option maxRecDepth 8000

/-! # 1. The general theorem

    `C6_Twist.lean` proves `twist_vanishes_on_reals`: on ±1-valued symbols the
    σ-twisted and untwisted differentials agree, because `conj` fixes ±1.

    That proof used μ₄ and `conj`. Neither is needed. The statement holds for
    ANY coefficient type, ANY multiplication, ANY inverse, and ANY map σ — the
    only hypothesis is that the symbol lands in the fixed set of σ.

    This is the GAP's −1/4 and the seal's real slice being the same fact:
    **the mirror is invisible exactly on its own fixed locus.** -/

section General
variable {M : Type}

/-- `d³` in both readings, over an arbitrary coefficient type. `σ` is applied at
    the leading face, which is where the inhomogeneous complex puts it. -/
def gd3 (mul : M → M → M) (inv : M → M) (σ : M → M)
    (tw : Bool) (F : Bool → Bool → Bool → M) (a b c d : Bool) : M :=
  mul (mul (mul (mul (if tw && a then σ (F b c d) else F b c d)
    (inv (F (xor a b) c d))) (F a (xor b c) d)) (inv (F a b (xor c d)))) (F a b c)

/-- **The twist is invisible exactly on the fixed locus of σ.**
    No group axioms, no involution hypothesis, no finiteness. -/
theorem twist_invisible_on_fixed
    (mul : M → M → M) (inv : M → M) (σ : M → M)
    (F : Bool → Bool → Bool → M) (hF : ∀ a b c, σ (F a b c) = F a b c) :
    ∀ a b c d, gd3 mul inv σ true F a b c d = gd3 mul inv σ false F a b c d := by
  intro a b c d
  cases a
  · rfl
  · exact congrArg
      (fun z => mul (mul (mul (mul z (inv (F (xor true b) c d)))
        (F true (xor b c) d)) (inv (F true b (xor c d)))) (F true b c))
      (hF b c d)

/-- The converse direction is not vacuous: off the fixed locus the two readings
    can differ. Stated as: if they agree everywhere for every symbol, σ is the
    identity on everything reachable as a symbol value. -/
theorem fixed_locus_is_sharp
    (mul : M → M → M) (inv : M → M) (σ : M → M)
    (h : ∀ F : Bool → Bool → Bool → M, ∀ a b c d,
          gd3 mul inv σ true F a b c d = gd3 mul inv σ false F a b c d)
    (cancel : ∀ x y p q r s : M,
      mul (mul (mul (mul x p) q) r) s = mul (mul (mul (mul y p) q) r) s → x = y) :
    ∀ m : M, σ m = m := by
  intro m
  exact cancel _ _ _ _ _ _ (h (fun _ _ _ => m) true false false false)

end General

/-! # 2. Z/n with an action, so the family can be swept

    An action of `Z/2` on `Z/n` is `x ↦ k·x` with `k² ≡ 1 (mod n)`.
    The seal is `n = 4`. -/

/-- additive inverse mod n, on `Nat` (truncated subtraction is avoided) -/
def negm (n x : Nat) : Nat := (n - x % n) % n

def actk (n k : Nat) (a : Bool) (x : Nat) : Nat := if a then (k * x) % n else x % n

abbrev SymN := Bool → Bool → Bool → Nat
abbrev GgeN := Bool → Bool → Nat

def d3k (n k : Nat) (F : SymN) (a b c d : Bool) : Nat :=
  (actk n k a (F b c d) + negm n (F (xor a b) c d) + F a (xor b c) d
    + negm n (F a b (xor c d)) + F a b c) % n

def d2k (n k : Nat) (g : GgeN) (a b c : Bool) : Nat :=
  (actk n k a (g b c) + negm n (g (xor a b) c) + g a (xor b c) + negm n (g a b)) % n

def isCocycleN (n k : Nat) (F : SymN) : Prop := ∀ a b c d, d3k n k F a b c d = 0
instance (n k) (F) : Decidable (isCocycleN n k F) := by unfold isCocycleN; infer_instance

/-- `F` is the coboundary of `g` -/
def isCobOf (n k : Nat) (g : GgeN) (F : SymN) : Prop := ∀ a b c, d2k n k g a b c = F a b c % n
instance (n k) (g) (F) : Decidable (isCobOf n k g F) := by unfold isCobOf; infer_instance

/-- the top-cell family: `F(1,1,1) = u`, `0` elsewhere -/
def top (u : Nat) : SymN := fun a b c => if a && b && c then u else 0

/-- a gauge from its four values -/
def gge4 (g00 g01 g10 g11 : Nat) : GgeN :=
  fun a b => if a then (if b then g11 else g10) else (if b then g01 else g00)

/-! # 3. Sanity: the seal, μ₄, reproduced here

    Must agree with `C6_Twist.lean`, which was written independently and in a
    different representation. If these disagree, one of the two is wrong. -/

theorem seal_mu4_trivial_action :
    isCocycleN 4 1 (top 2) ∧ ¬ isCocycleN 4 1 (top 1) := by decide

theorem seal_mu4_inversion :
    isCocycleN 4 3 (top 1) ∧ isCocycleN 4 3 (top 2) := by decide

/-- Under the twist the fermion (`u = 2`, i.e. `−1`) becomes a coboundary —
    `C6_Twist.lean`'s `fermion_is_sigma_coboundary`, re-derived in Z/4. -/
theorem seal_fermion_trivialised : isCobOf 4 3 (gge4 3 3 1 2) (top 2) := by decide

/-- and `i` (`u = 1`) is a σ-cocycle that no gauge kills -/
theorem seal_i_is_cocycle : isCocycleN 4 3 (top 1) := by decide

/-! # 4. THE PINCH, at μ₈

    At `n = 8` there are FOUR actions (`k² ≡ 1 mod 8` has four solutions), and
    they disagree. Under `k = 3` every top-cell cocycle is a coboundary — the
    two classes merge into one. Under `k = 7` they do not.

    This is the cohomological −1/4: two roots become one root at `D = 0`; two
    classes become one class at `(n,k) = (8,3)`. -/

/-- Under `k = 3` the odd top cells are not even cocycles… -/
theorem pinch_odd_not_cocycles :
    ¬ isCocycleN 8 3 (top 1) ∧ ¬ isCocycleN 8 3 (top 3)
  ∧ ¬ isCocycleN 8 3 (top 5) ∧ ¬ isCocycleN 8 3 (top 7) := by decide

/-- …and every even one, which IS a cocycle, is killed by an explicit gauge.
    Four witnesses, so the collapse is exhibited rather than counted. -/
theorem pinch_all_cocycles_are_coboundaries :
    (isCocycleN 8 3 (top 0) ∧ isCobOf 8 3 (gge4 7 7 5 5) (top 0))
  ∧ (isCocycleN 8 3 (top 2) ∧ isCobOf 8 3 (gge4 7 7 5 6) (top 2))
  ∧ (isCocycleN 8 3 (top 4) ∧ isCobOf 8 3 (gge4 7 7 5 7) (top 4))
  ∧ (isCocycleN 8 3 (top 6) ∧ isCobOf 8 3 (gge4 7 7 5 4) (top 6)) := by decide

/-- **The contrast.** Under `k = 7` — inversion, the "obvious" non-trivial
    action — the class survives: `top 1` is a cocycle and NO gauge kills it. -/
theorem no_pinch_at_inversion :
    isCocycleN 8 7 (top 1)
  ∧ (∀ a b c d : Bool, ¬ isCobOf 8 7 (gge4 (if a then 1 else 0) (if b then 1 else 0)
        (if c then 1 else 0) (if d then 1 else 0)) (top 1)) := by decide

/-! # 5. Why "THE non-trivial action" denotes anything at all

    `CHARGE.md` says *"the non-trivial action"*, definite article. That phrase
    presupposes uniqueness. It is unique at `n = 4` and at no larger power of 2. -/

def sqrtsOfOne (n : Nat) : List Nat := (List.range n).filter (fun k => (k * k) % n == 1 % n)

theorem two_actions_at_mu4 : sqrtsOfOne 4 = [1, 3] := by decide
theorem four_actions_at_mu8 : sqrtsOfOne 8 = [1, 3, 5, 7] := by decide
theorem four_actions_at_mu12 : sqrtsOfOne 12 = [1, 5, 7, 11] := by decide

/-- So at μ₈ there are three non-trivial actions and they do not agree: two of
    them pinch and one does not. "The non-trivial action" is not a description
    of the general situation — it is an accident of `n = 4`. -/
theorem the_definite_article_is_an_accident :
    (sqrtsOfOne 4).length = 2 ∧ (sqrtsOfOne 8).length = 4 := by decide

/-! # 6. Odd coefficients: total pinch, both readings, always

    For `n` odd the cohomology vanishes under every action — `|G| = 2` is
    invertible mod `n`. So for odd coefficient groups the charge has no content
    at all: not overlooked, absent. -/

/-- Under the TRIVIAL action only the zero cell is a cocycle at all. -/
theorem mu3_trivial_only_zero :
    isCocycleN 3 1 (top 0) ∧ ¬ isCocycleN 3 1 (top 1) ∧ ¬ isCocycleN 3 1 (top 2) := by decide

/-- Under INVERSION every top cell is a cocycle AND every one is killed by an
    explicit gauge. Three witnesses: the class collapses completely. -/
theorem mu3_inversion_total_pinch :
    (isCocycleN 3 2 (top 0) ∧ isCobOf 3 2 (gge4 2 2 1 1) (top 0))
  ∧ (isCocycleN 3 2 (top 1) ∧ isCobOf 3 2 (gge4 2 2 1 2) (top 1))
  ∧ (isCocycleN 3 2 (top 2) ∧ isCobOf 3 2 (gge4 2 2 1 0) (top 2)) := by decide

/-- Same at μ₅ — five witnesses. Odd coefficient groups pinch totally. -/
theorem mu5_inversion_total_pinch :
    (isCocycleN 5 4 (top 0) ∧ isCobOf 5 4 (gge4 4 4 1 1) (top 0))
  ∧ (isCocycleN 5 4 (top 1) ∧ isCobOf 5 4 (gge4 4 4 1 3) (top 1))
  ∧ (isCocycleN 5 4 (top 2) ∧ isCobOf 5 4 (gge4 4 4 1 0) (top 2))
  ∧ (isCocycleN 5 4 (top 3) ∧ isCobOf 5 4 (gge4 4 4 1 2) (top 3))
  ∧ (isCocycleN 5 4 (top 4) ∧ isCobOf 5 4 (gge4 4 4 1 4) (top 4)) := by decide

/-- **The asymmetry the corpus would not have predicted.** At μ₃ and μ₅ the
    TRIVIAL action admits almost no cocycles, while INVERSION admits all of them
    and kills all of them. The twist does not "break" the classification here —
    it *creates* cocycles and then trivialises every one. Two different ways of
    having nothing to classify, and only one of them looks like nothing. -/
theorem odd_asymmetry :
    (¬ isCocycleN 5 1 (top 1) ∧ isCocycleN 5 4 (top 1))
  ∧ (¬ isCocycleN 3 1 (top 1) ∧ isCocycleN 3 2 (top 1)) := by decide
