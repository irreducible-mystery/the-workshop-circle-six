# 02 — EXPLAINED

The same content as `01-BUILD-STACK.md`, with the reasoning. Statements here are
paraphrase; the source is `lean/`, and `01-BUILD-STACK.md` is generated from it.

---

## The setting

A group `G = Z/2`. A coefficient group `M`. A 3-cochain is a function
`M`-valued on `G³`. There are two things one can do with the group element in
the leading position of the coboundary formula: ignore it (the **trivial**
action) or let it act on the coefficient (a **non-trivial** action). The whole
artifact is about the difference.

Concretely, for `M = Z[i]^×= {1, i, −1, −i}`:

    d³_tw F (a,b,c,d) = σ^[tw·a](F b c d) · F(ab,c,d)⁻¹ · F(a,bc,d) · F(a,b,cd)⁻¹ · F(a,b,c)

with `σ = conj`. `tw = false` recovers the untwisted complex.

## Part I — the two maps that turn out to be one map

**`conj` is inversion on the units.** Not analogous to it — *equal* to it, and
equal by construction: the group structure on the units defines inversion as
`conj`. On all four units the two functions agree.

    conj_eq_inv,  conj_is_the_inverse

The scope is load-bearing and is proved separately: **off** the units they part
company immediately, since `z · conj z = ⟨N(z), 0⟩`, so `1+i ↦ (2,0) ≠ 1`.

    conj_not_inv_off_units

Consequence: a Galois action was present in this material all along, sitting in
the *coboundary* (as the inverse) and never in the *coefficients*. Nothing had
to be introduced to ask what the non-trivial action does.

`sigma_ne_id` records that `σ` really moves something, so nothing downstream is
vacuous.

## Part II — the object being studied is the source's object

The pentagon equation, in the form the sweep uses, is a three-factor product
equal to a two-factor product. The *source's* pentagon is written with an
admissibility guard and integer label arithmetic, and looks quite different.

    pentagon_iff_seal

proves they are the same proposition. This is the load-bearing fidelity step.
Without it every later result would be a fact about a convenient model rather
than about the thing. The proof works by case-splitting all 16 label points and
showing the guard never fires — the "off-locus" branch is unreachable.

## Part III — the four-row table

Take the cochains that differ from the identity at a single top cell. Ask, for
each of the four unit values, whether it is a cocycle and whether it is a
coboundary, under each reading:

| top-cell value | trivial action | conjugation action |
|---|---|---|
| `1` | coboundary — trivial class | coboundary — trivial class |
| `i` | *not a cocycle* | **generates** |
| `−1` | **generates** | coboundary — trivial class |
| `−i` | *not a cocycle* | **generates** |

    row_one_*, row_i_*, row_neg1_*, row_negi_*

A clean exchange. Untwisted, the classification is carried by `±1` and `±i` is
not admissible at all. Twisted, `±1` is gauge-trivial and `±i` carries the
classification.

The collapse of `−1` is not merely counted — the gauge that does it is written
down and checked:

    fermion_is_sigma_coboundary        with the explicit gauge g(1,1) = i

And `i`, which the source's own pentagon rejects, is a cocycle under the twist
that no gauge kills:

    sliceI_fails_pentagon, sliceI_is_sigma_cocycle, sliceI_not_sigma_coboundary

So the twisted generator was always nameable in the source's own vocabulary.
Nothing was invented on either side of the question — only read differently.

## Part IV — why the difference was invisible

    twist_vanishes_on_reals

On symbols valued in `{1, −1}` the two readings are **identically equal**,
because `conj` fixes `±1`. The representatives that the surrounding literature
actually computes with are all real-valued. So the two actions could not be
told apart anywhere those computations looked.

This is not "nobody asked." It is "the question had no consequence in the sector
being examined."

## Part V — but it was visible next door

The same source also carries a braiding (hexagon) sector, and applies `σ` there
explicitly. Asking which braidings are admitted:

| symbol | braidings `R` | `σ` acts | self-inverse? |
|---|---|---|---|
| `1` | `1`, `−1` — **real** | fixes each | holds for both |
| `−1` | `i`, `−i` — **imaginary** | **exchanges them, no fixed point** | **fails** (`i² = −1`) |

    boson_braids_real, fermion_braids_imaginary,
    sigma_fixes_boson_braidings, sigma_swaps_fermion_braidings,
    edict_boson, edict_fermion_fails

with `hexagonHolds_iff` bridging the source's integer-label statement to the
enumerated form, so these are about the source's hexagon and not a model of it.

So the corrected statement is: **`σ` is invisible in the pentagon sector and
visibly a fixed-point-free exchange in the braiding sector**, and the
classification predicate is defined so that only the first sector is examined.
The consequence was outside what got *classified*, not outside what was
*observable*.

## Part VI — the generalisation

Part IV's proof used a specific four-element group and a specific map. Neither is
needed:

    twist_invisible_on_fixed
      (mul : M → M → M) (inv : M → M) (σ : M → M)
      (F : Bool → Bool → Bool → M) (hF : ∀ a b c, σ (F a b c) = F a b c) :
      ∀ a b c d, gd3 mul inv σ true F ... = gd3 mul inv σ false F ...

Any type. Any multiplication. Any inverse. Any `σ` — not even an involution. No
finiteness. **The only hypothesis is that the symbol lands in the fixed set of
`σ`.**

    fixed_locus_is_sharp

gives the converse under a cancellation hypothesis, so the fixed locus is not
merely sufficient for invisibility — it is the whole of it.

The reading: **the mirror is invisible exactly on its own fixed locus.**

## Part VII — sweeping the coefficient group

Replace `Z[i]^×` by `Z/n`. An action of `Z/2` on `Z/n` is `x ↦ kx` with
`k² ≡ 1 (mod n)`. Now both the coefficients and the action are parameters.

**The number of actions is not always two.**

    two_actions_at_mu4    : {1, 3}
    four_actions_at_mu8   : {1, 3, 5, 7}
    four_actions_at_mu12  : {1, 5, 7, 11}
    the_definite_article_is_an_accident

At `n = 4` there are exactly two, so "*the* non-trivial action" denotes. At
`n = 8` there are four, three of them non-trivial, and **they disagree**.

**The pinch.** At `(n, k) = (8, 3)` every cocycle in the top-cell family is a
coboundary — the two classes merge into one:

    pinch_odd_not_cocycles              the odd cells are not cocycles at all
    pinch_all_cocycles_are_coboundaries four explicit gauges, one per even cell

and the contrast, so this is not an artifact of the family:

    no_pinch_at_inversion               at k = 7 the class survives

**Odd coefficients pinch totally**, and asymmetrically:

    mu3_trivial_only_zero        trivial action: almost nothing is a cocycle
    mu3_inversion_total_pinch    inversion: everything is, and everything dies
    mu5_inversion_total_pinch    five explicit witnesses
    odd_asymmetry

The twist does not "break" the classification for odd coefficients. It *creates*
cocycles and then trivialises every one. Two different ways of having nothing to
classify, and only one of them looks like nothing.

## What the whole thing says

A two-valued symmetry can be present, genuinely non-trivial, and completely
invisible — if everything you examine happens to lie in its fixed set. Whether
that happens is a property of the sector you chose to classify, not of the
symmetry.

And the size of the coefficient group decides whether the question has content
at all: at `n = 4` there is exactly one non-trivial action and it does something;
at `n = 8` there are three and they disagree; at odd `n` there is nothing to see
under any of them.
