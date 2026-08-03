# 01 — BUILD STACK

Generated from `lean/*.lean`. Every line below is extracted from the source, in
source order. If the source changes and this file is not regenerated,
`verify.sh` fails on drift.

Notation: `[]` = depends on no axiom. `dec` = closed by kernel evaluation
(`decide`). `trm` = closed by an explicit proof term.

---


## `lean/C6_Twist.lean`

    structure GZ                                 where re : Int
    def       one                                : GZ := ⟨1, 0⟩
    def       mul                                (z w : GZ) : GZ := ⟨z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re⟩
    def       conj                               (z : GZ) : GZ := ⟨z.re, -z.im⟩
    inductive U                                  | u1 | ui | um1 | umi
    def       toGZ                               : U → GZ | u1 => ⟨1,0⟩ | ui => ⟨0,1⟩ | um1 => ⟨-1,0⟩ | umi => ⟨0,-1⟩
    def       mul                                : U → U → U
    def       conj                               : U → U | u1 => u1 | ui => umi | um1 => um1 | umi => ui
    def       inv                                : U → U | u1 => u1 | ui => umi | um1 => um1 | umi => ui
    instance  decAllU                            (p : U → Prop) [DecidablePred p] : Decidable (∀ a, p a) := if h1 : p .u1 then if h2 : p .ui then if h3 : p .um
    instance  decAllBool                         (p : Bool → Prop) [DecidablePred p] : Decidable (∀ b, p b) := if h1 : p false then

### The bridge: `U` is the seal's units under the seal's arithmetic

    THEOREM   toGZ_mul                           [dec] []   ∀ a b : U, (U.mul a b).toGZ = GZ.mul a.toGZ b.toGZ
    THEOREM   toGZ_conj                          [dec] []   ∀ a : U, (U.conj a).toGZ = GZ.conj a.toGZ
    THEOREM   toGZ_inj                           [dec] []   ∀ a b : U, a.toGZ = b.toGZ → a = b
    THEOREM   is_unit                            [dec] []   ∀ a : U, GZ.mul a.toGZ (U.inv a).toGZ = GZ.one

### CHECK 1 — `conj` IS inversion on the units

    THEOREM   conj_eq_inv                        [dec] []   ∀ a : U, U.conj a = U.inv a
    THEOREM   conj_is_the_inverse                [dec] []   ∀ a : U, GZ.mul a.toGZ (GZ.conj a.toGZ) = GZ.one
    THEOREM   conj_not_inv_off_units             [dec] []   GZ.mul ⟨1,1⟩ (GZ.conj ⟨1,1⟩) ≠ GZ.one
    THEOREM   sigma_ne_id                        [dec] []   ∃ a : U, U.conj a ≠ a

### The complex

    abbrev    Sym                                := Bool → Bool → Bool → U
    abbrev    Gge                                := Bool → Bool → U
    def       act                                (tw a : Bool) (x : U) : U := if tw && a then U.conj x else x
    def       d3                                 (tw : Bool) (F : Sym) (a b c d : Bool) : U := U.mul (U.mul (U.mul (U.mul (act tw a (F b c d)) (U.inv (F (xor a
    def       d2                                 (tw : Bool) (g : Gge) (a b c : Bool) : U := U.mul (U.mul (act tw a (g b c)) (U.inv (g (xor a b) c)))
    def       isCocycle                          (tw : Bool) (F : Sym) : Prop := ∀ a b c d, d3 tw F a b c d = .u1
    def       pentagon                           (F : Sym) : Prop := ∀ a b c d, U.mul (U.mul (F a b c) (F a (xor b c) d)) (F b c d)

### Gauges, enumerated by code, for the coboundary question

    def       decU                               : Nat → U | 0 => .u1 | 1 => .ui | 2 => .um1 | _ => .umi
    def       gge                                (n : Nat) : Gge := fun a b =>
    def       eqSym                              (F G : Sym) : Bool := decide (∀ a b c, F a b c = G a b c)
    def       cobAux                             (tw : Bool) (F : Sym) : Nat → Bool
    def       isCoboundary                       (tw : Bool) (F : Sym) : Bool := cobAux tw F 256

### Fidelity: the reduced pentagon IS the seal's `genPentagonHolds`.

    def       GZ                                 .zero : GZ := ⟨0, 0⟩
    def       boolOf                             (i : Int) : Bool := if i = 1 then true else false
    def       lab                                (b : Bool) : Int := if b then 1 else 0
    def       Fint                               (F : Sym) : Int → Int → Int → GZ := fun i j k => (F (boolOf i) (boolOf j) (boolOf k)).toGZ
    def       Fgen                               (F : Int → Int → Int → GZ) (a b c d x y : Int) : GZ := if x = (a + b) % 2 ∧ y = (b + c) % 2 ∧ d = (a + b + c) 
    def       genPentLhs                         (F : Int → Int → Int → GZ) (a b c d : Int) : GZ := let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d
    def       genPentRhs                         (F : Int → Int → Int → GZ) (a b c d : Int) : GZ := let x := (a + b) % 2; let y := (x + c) % 2; let t := (y + d
    THEOREM   lhs_reduces                        [trm] []   (F : Sym) (a b c d : Bool) : genPentLhs (Fint F) (lab a) (lab b) (lab c) (lab d) = GZ.mul (GZ.mul (F a b c).toGZ (F a (x
    THEOREM   rhs_reduces                        [trm] []   (F : Sym) (a b c d : Bool) : genPentRhs (Fint F) (lab a) (lab b) (lab c) (lab d) = GZ.mul (F (xor a b) c d).toGZ (F a b 
    THEOREM   lhs_reduces_U                      [trm] []   (F : Sym) (a b c d : Bool) : genPentLhs (Fint F) (lab a) (lab b) (lab c) (lab d) = (U.mul (U.mul (F a b c) (F a (xor b c
    THEOREM   rhs_reduces_U                      [trm] []   (F : Sym) (a b c d : Bool) : genPentRhs (Fint F) (lab a) (lab b) (lab c) (lab d) = (U.mul (F (xor a b) c d) (F a b (xor 
    THEOREM   pentagon_iff_seal                  [trm] []   (F : Sym) : pentagon F ↔ ∀ a b c d : Bool, genPentLhs (Fint F) (lab a) (lab b) (lab c) (lab d) = genPentRhs (Fint F) (la

### The symbols the seal names

    def       topCell                            (u : U) : Sym := fun a b c => if a && b && c then u else .u1
    def       boson                              : Sym := topCell .u1              -- sliceCore one
    def       fermion                            : Sym := topCell .um1             -- fermionCochain / sliceCore (neg one)
    def       sliceI                             : Sym := topCell .ui              -- sliceCore I
    def       twistedBoson                       : Sym := fun _ b c => if c then (if b then .ui else .umi) else .u1
    def       fakeCocycle                        : Sym := fun a b c => if !a && !b && c then .ui else .u1

### RESULT 1 — the four-row table, in the kernel.

    THEOREM   row_one_untwisted                  [dec] []   isCocycle false boson ∧ isCoboundary false boson = true
    THEOREM   row_one_twisted                    [dec] []   isCocycle true boson ∧ isCoboundary true boson = true
    THEOREM   row_i_untwisted                    [dec] []   ¬ isCocycle false sliceI
    THEOREM   row_i_twisted                      [dec] []   isCocycle true sliceI ∧ isCoboundary true sliceI = false
    THEOREM   row_neg1_untwisted                 [dec] []   isCocycle false fermion ∧ isCoboundary false fermion = false
    THEOREM   row_neg1_twisted                   [dec] []   isCocycle true fermion ∧ isCoboundary true fermion = true
    THEOREM   row_negi_untwisted                 [dec] []   ¬ isCocycle false (topCell .umi)
    THEOREM   row_negi_twisted                   [dec] []   isCocycle true (topCell .umi) ∧ isCoboundary true (topCell .umi) = false

### RESULT 2 — the fermion becomes gauge-trivial, with the witness written down

    def       gFermion                           : Gge := fun a b => if a && b then .ui else .u1
    THEOREM   fermion_is_sigma_coboundary        [dec] []   ∀ a b c, d2 true gFermion a b c = fermion a b c
    THEOREM   fermion_not_untwisted_coboundary   [dec] []   isCoboundary false fermion = false

### RESULT 3 — twistedBoson: a pentagon solution that is not a σ-cocycle

    THEOREM   twistedBoson_pentagon              [dec] []   pentagon twistedBoson
    THEOREM   twistedBoson_not_sigma_cocycle     [dec] []   ¬ isCocycle true twistedBoson
    THEOREM   twistedBoson_untwisted_cocycle     [dec] []   isCocycle false twistedBoson
    THEOREM   twistedBoson_gauge_trivial         [dec] []   isCoboundary false twistedBoson = true

### RESULT 4 — sliceCore I: the σ-generator the seal can already name,

    THEOREM   sliceI_fails_pentagon              [dec] []   ¬ pentagon sliceI
    THEOREM   sliceI_is_sigma_cocycle            [dec] []   isCocycle true sliceI
    THEOREM   sliceI_not_sigma_coboundary        [dec] []   isCoboundary true sliceI = false

### RESULT 5 — the seal's negative control still behaves

    THEOREM   fakeCocycle_fails_both             [dec] []   ¬ pentagon fakeCocycle ∧ ¬ isCocycle true fakeCocycle

### RESULT 6 — why five circles never saw it.

    def       isReal                             (u : U) : Bool := u == .u1 || u == .um1
    THEOREM   conj_fixes_reals                   [dec] []   ∀ u : U, isReal u = true → U.conj u = u
    THEOREM   twist_vanishes_on_reals            [trm] []   (F : Sym) (h : ∀ a b c, isReal (F a b c) = true) : ∀ a b c d, d3 true F a b c d = d3 false F a b c d
    THEOREM   boson_real                         [dec] []   ∀ a b c, isReal (boson a b c) = true
    THEOREM   fermion_real                       [dec] []   ∀ a b c, isReal (fermion a b c) = true

### |B³| by enumeration: count gauges whose coboundary is not already

    def       gaugeEq                            (g h : Gge) : Bool := decide (∀ a b, g a b = h a b)
    def       symEq                              (F G : Sym) : Bool := decide (∀ a b c, F a b c = G a b c)
    def       seenBefore                         (tw : Bool) (n : Nat) : Nat → Bool
    def       countB                             : Bool → Nat → Nat
    def       countKer                           : Bool → Nat → Nat
    def       cobAreCocycles                     (tw : Bool) : Nat → Bool
    THEOREM   B3_untwisted                       [dec] []   countB false 256 = 16
    THEOREM   B3_twisted                         [dec] []   countB true 256 = 32
    THEOREM   ker_untwisted                      [dec] []   countKer false 256 = 16
    THEOREM   ker_twisted                        [dec] []   countKer true 256 = 8
    THEOREM   cob_subset_cocycles_untwisted      [dec] []   cobAreCocycles false 256 = true
    THEOREM   cob_subset_cocycles_twisted        [dec] []   cobAreCocycles true 256 = true

### Is the twist really invisible? The braiding says no.

    def       Fs                                 (f : GZ) (a b c d x y : Int) : GZ := if x = (a + b) % 2 ∧ y = (b + c) % 2 ∧ d = (a + b + c) % 2 then
    def       Rs                                 (R : GZ) (x y : Int) : GZ := if x = 1 ∧ y = 1 then R else GZ.one
    def       hexLhs                             (f R : GZ) (a b c d : Int) : GZ := let e := (a + b) % 2; let z := (a + c) % 2
    def       hexRhs                             (f R : GZ) (a b c d : Int) : GZ := let e := (a + b) % 2; let z := (a + c) % 2; let g := (b + c) % 2
    def       hexagonHolds                       (f R : GZ) : Prop := ∀ a b c d : Int, (a = 0 ∨ a = 1) → (b = 0 ∨ b = 1) → (c = 0 ∨ c = 1) →
    def       hexInvHolds                        (f R : GZ) : Prop := hexagonHolds f (GZ.conj R)
    def       SelfInverse                        (R : GZ) : Prop := GZ.mul R R = GZ.one
    THEOREM   intBool                            [trm] []   (P : Int → Prop) : (∀ i : Int, (i = 0 ∨ i = 1) → P i) ↔ (∀ b : Bool, P (lab b))
    def       hexB                               (f R : GZ) : Bool := decide (∀ a b c d : Bool, lab d = ((lab a + lab b) % 2 + lab c) % 2 →
    THEOREM   hexagonHolds_iff                   [trm] []   (f R : GZ) : hexagonHolds f R ↔ hexB f R = true

### The answer: the boson braids REAL, the fermion braids IMAGINARY.

    THEOREM   boson_braids_real                  [dec] []   hexB GZ.one ⟨1,0⟩ = true ∧ hexB GZ.one ⟨-1,0⟩ = true ∧ hexB GZ.one ⟨0,1⟩ = false ∧ hexB GZ.one ⟨0,-1⟩ = false
    THEOREM   fermion_braids_imaginary           [dec] []   hexB ⟨-1,0⟩ ⟨0,1⟩ = true ∧ hexB ⟨-1,0⟩ ⟨0,-1⟩ = true ∧ hexB ⟨-1,0⟩ ⟨1,0⟩ = false ∧ hexB ⟨-1,0⟩ ⟨-1,0⟩ = false
    THEOREM   sigma_fixes_boson_braidings        [dec] []   GZ.conj ⟨1,0⟩ = (⟨1,0⟩ : GZ) ∧ GZ.conj ⟨-1,0⟩ = (⟨-1,0⟩ : GZ)
    THEOREM   sigma_swaps_fermion_braidings      [dec] []   GZ.conj ⟨0,1⟩ = (⟨0,-1⟩ : GZ) ∧ GZ.conj ⟨0,-1⟩ = (⟨0,1⟩ : GZ) ∧ GZ.conj ⟨0,1⟩ ≠ (⟨0,1⟩ : GZ) ∧ GZ.conj ⟨0,-1⟩ ≠ (⟨0,-1⟩ 
    THEOREM   edict_boson                        [dec] []   SelfInverse ⟨1,0⟩ ∧ SelfInverse ⟨-1,0⟩
    THEOREM   edict_fermion_fails                [dec] []   ¬ SelfInverse ⟨0,1⟩ ∧ ¬ SelfInverse ⟨0,-1⟩

## `lean/C6_Gap.lean`


### 1. The general theorem

    def       gd3                                (mul : M → M → M) (inv : M → M) (σ : M → M)
    THEOREM   twist_invisible_on_fixed           [trm] []   (mul : M → M → M) (inv : M → M) (σ : M → M) (F : Bool → Bool → Bool → M) (hF : ∀ a b c, σ (F a b c) = F a b c) : ∀ a b c
    THEOREM   fixed_locus_is_sharp               [trm] []   (mul : M → M → M) (inv : M → M) (σ : M → M) (h : ∀ F : Bool → Bool → Bool → M, ∀ a b c d, gd3 mul inv σ true F a b c d =

### 2. Z/n with an action, so the family can be swept

    def       negm                               (n x : Nat) : Nat := (n - x % n) % n
    def       actk                               (n k : Nat) (a : Bool) (x : Nat) : Nat := if a then (k * x) % n else x % n
    abbrev    SymN                               := Bool → Bool → Bool → Nat
    abbrev    GgeN                               := Bool → Bool → Nat
    def       d3k                                (n k : Nat) (F : SymN) (a b c d : Bool) : Nat := (actk n k a (F b c d) + negm n (F (xor a b) c d) + F a (xor b
    def       d2k                                (n k : Nat) (g : GgeN) (a b c : Bool) : Nat := (actk n k a (g b c) + negm n (g (xor a b) c) + g a (xor b c) + 
    def       isCocycleN                         (n k : Nat) (F : SymN) : Prop := ∀ a b c d, d3k n k F a b c d = 0
    def       isCobOf                            (n k : Nat) (g : GgeN) (F : SymN) : Prop := ∀ a b c, d2k n k g a b c = F a b c % n
    def       top                                (u : Nat) : SymN := fun a b c => if a && b && c then u else 0
    def       gge4                               (g00 g01 g10 g11 : Nat) : GgeN := fun a b => if a then (if b then g11 else g10) else (if b then g01 else g00)

### 3. Sanity: the seal, μ₄, reproduced here

    THEOREM   seal_mu4_trivial_action            [dec] []   isCocycleN 4 1 (top 2) ∧ ¬ isCocycleN 4 1 (top 1)
    THEOREM   seal_mu4_inversion                 [dec] []   isCocycleN 4 3 (top 1) ∧ isCocycleN 4 3 (top 2)
    THEOREM   seal_fermion_trivialised           [dec] []   isCobOf 4 3 (gge4 3 3 1 2) (top 2)
    THEOREM   seal_i_is_cocycle                  [dec] []   isCocycleN 4 3 (top 1)

### 4. THE PINCH, at μ₈

    THEOREM   pinch_odd_not_cocycles             [dec] []   ¬ isCocycleN 8 3 (top 1) ∧ ¬ isCocycleN 8 3 (top 3) ∧ ¬ isCocycleN 8 3 (top 5) ∧ ¬ isCocycleN 8 3 (top 7)
    THEOREM   pinch_all_cocycles_are_coboundaries [dec] []   (isCocycleN 8 3 (top 0) ∧ isCobOf 8 3 (gge4 7 7 5 5) (top 0)) ∧ (isCocycleN 8 3 (top 2) ∧ isCobOf 8 3 (gge4 7 7 5 6) (to
    THEOREM   no_pinch_at_inversion              [dec] []   isCocycleN 8 7 (top 1) ∧ (∀ a b c d : Bool, ¬ isCobOf 8 7 (gge4 (if a then 1 else 0) (if b then 1 else 0) (if c then 1 e

### 5. Why "THE non-trivial action" denotes anything at all

    def       sqrtsOfOne                         (n : Nat) : List Nat := (List.range n).filter (fun k => (k * k) % n == 1 % n)
    THEOREM   two_actions_at_mu4                 [dec] []   sqrtsOfOne 4 = [1, 3]
    THEOREM   four_actions_at_mu8                [dec] []   sqrtsOfOne 8 = [1, 3, 5, 7]
    THEOREM   four_actions_at_mu12               [dec] []   sqrtsOfOne 12 = [1, 5, 7, 11]
    THEOREM   the_definite_article_is_an_accident [dec] []   (sqrtsOfOne 4).length = 2 ∧ (sqrtsOfOne 8).length = 4

### 6. Odd coefficients: total pinch, both readings, always

    THEOREM   mu3_trivial_only_zero              [dec] []   isCocycleN 3 1 (top 0) ∧ ¬ isCocycleN 3 1 (top 1) ∧ ¬ isCocycleN 3 1 (top 2)
    THEOREM   mu3_inversion_total_pinch          [dec] []   (isCocycleN 3 2 (top 0) ∧ isCobOf 3 2 (gge4 2 2 1 1) (top 0)) ∧ (isCocycleN 3 2 (top 1) ∧ isCobOf 3 2 (gge4 2 2 1 2) (to
    THEOREM   mu5_inversion_total_pinch          [dec] []   (isCocycleN 5 4 (top 0) ∧ isCobOf 5 4 (gge4 4 4 1 1) (top 0)) ∧ (isCocycleN 5 4 (top 1) ∧ isCobOf 5 4 (gge4 4 4 1 3) (to
    THEOREM   odd_asymmetry                      [dec] []   (¬ isCocycleN 5 1 (top 1) ∧ isCocycleN 5 4 (top 1)) ∧ (¬ isCocycleN 3 1 (top 1) ∧ isCocycleN 3 2 (top 1))
