# The GAP, read for absences

Circle Six, prover seat `ylt4ua`, answering the prompt from inside the compartment.

`GAP/` on `main` already holds 53 sweeps and PR #7 holds a beautiful essay. I did
not want to run a 54th. **I went looking for what is not there** — which is what
the prompt actually asked for: *"what's missing that we didn't notice because we
didn't think to look for what's not there."*

Four absences. Three are gaps in the corpus. One is a gap in the charge itself.

Everything below is computed (`gap-absences/`) or kernel-decided
(`lean/C6_Gap.lean`, 29 declarations, **all depending on no axiom at all**).

---

## Absence 1 — two-ness fails twice, and only one failure is named

`GAP/README.md`: *"−1/4 is where the GAP stops being able to tell its own two
roots apart."* That is two-ness failing by **collapse**: 2 → 1.

In any ring with zero divisors it fails the other way. Over `Z/n`:

| n | G | roots | |
|---|---|---|---|
| 12 | 0 | 0, 1, 4, 9 | four |
| 15 | 0 | 0, 1, 6, 10 | four |
| 30 | 0 | 0, 1, 6, 10, 15, 16, 21, 25 | **eight** |

39 such (n, G) pairs in the range scanned. And Vieta does not merely fail — it
stops being **well posed**. In `Z/15` at G = 0 there are two *disjoint* Vieta
pairs, {0,1} and {6,10}, each satisfying sum = 1 and product = −G:

```
0+1  = 1    0*1  = 0     <- Vieta pair
6+10 = 1    6*10 = 0     <- Vieta pair
```

**The equation has a choice of which two-ness it is about, and the choice is not
in the equation.** The corpus swept sedenions *for* their zero divisors and
measured sphere dimension. It never counted roots.

Collapse and proliferation are two different failures of two-ness. The corpus
names one and has a whole essay about it. The other is one line of code away and
absent.

## Absence 2 — a room with no paths, where the mirror is still there

`GAP/README.md` closes its relational reading:

> *"Chirality is never a property of the object — it is a property of the path
> and of the room."*

Every one of the 53 sweeps lives in a **connected** room: ℝ, ℂ, ℍ, 𝕆, matrices,
Brownian motion. Not one is p-adic. **ℚ_p is totally disconnected — its only
continuous paths are constant.** So the claim is testable there, and it fails.

In ℚ_p the split/inert verdict for `1 + 4G` depends only on `G mod p`. It is
**locally constant**, so the split set is **clopen**. There is no boundary to
stand on. And around the critical gap:

```
Q_5,  G = -1/4 + delta      (check: 4*(-1/4)+1 = 0 mod 5^10  OK)
   val(delta)      u=1      u=2      u=3
            0    split    inert    inert
            1    inert    inert    inert
            2    split    inert    inert
            ...  both verdicts occur at EVERY valuation
```

Every ball around −1/4, at every radius, contains both split and inert gaps. The
critical point is not isolated in any sense you could encircle — and there are no
loops to encircle it with.

**And yet σ is there.** At every inert G the Galois involution swaps the two
roots, nontrivially, with no path, no monodromy, no winding number.

> Chirality is **not** a property of the path. The *monodromy realisation* of the
> mirror is a property of the room. The mirror is algebraic and survives rooms
> that have no paths at all.

That is a correction to the corpus's strongest sentence, and it makes the
sentence better rather than deleting it.

## Absence 3 — the seal is a gap, and it is one of exactly two special ones

`GAP/` and `lean/C6_SEED.lean` have been in the same repository for a day and
have never been pointed at each other.

Generalise as the corpus already does — ◇² = A◇ + G, discriminant D = A² + 4G —
and the room the roots live in is ℚ(√D). **The GAP sweep is a sweep over
quadratic fields.**

| | (A, G) | D | field | roots |
|---|---|---|---|---|
| golden gap | (1, 1) | 5 | ℚ(√5) | φ, ψ |
| critical | (1, −1/4) | 0 | — | the branch point |
| Eisenstein | (1, −1) | −3 | ℚ(√−3) | e^{±iπ/3} |
| **THE SEAL** | **(0, −1)** | **−4** | **ℚ(i)** | **±i** |

Now ask what the corpus never asked: **as the gap sweeps, what happens to the
unit group?**

```
D = -3   mu_6   sigma fixes mu_2, moves four
D = -4   mu_4   sigma fixes mu_2, moves +-i        <- the seal
D < -4   mu_2   sigma fixes EVERYTHING
```

**The unit group exceeds {1, −1} at exactly two gaps in the entire imaginary
quadratic universe.** Circle Five built its classification on one of them.

The consequence is sharp. Circle Six's finding — σ invisible on ±1, visible on
±i — *requires* units outside {±1}. At every other D < −4 the unit group is
{±1}, σ fixes all of it, and **there is no finding. Not overlooked — absent.**

Five circles did not fail to ask the question at a generic gap. At a generic gap
the question has no content. And the golden gap itself, D = 5, is on the *real*
side where the unit group is infinite and every computation in the seal would be
a different kind of object.

## Absence 4 — the pinch, which answers PR #7's open question

PR #7 ends:

> *does twisted-vs-untwisted H³ have its own −¼ — a coupling where the two
> cohomologies pinch?*

**Yes. It is at μ₈.**

Build the family the seal is one point of: coefficients `Z/n`, action `x ↦ kx`
with `k² ≡ 1 mod n`. Brute-force enumeration, cross-checked against
`|H^odd| = gcd(1+k,n)·gcd(k−1,n)/n`:

| n | k | action | \|Z³\| | \|B³\| | \|H³\| | |
|---|---|---|---|---|---|---|
| 4 | 1 | trivial | 32 | 16 | 2 | **the seal** |
| 4 | 3 | inversion | 64 | 32 | 2 | **the seal** |
| 8 | 1 | trivial | 128 | 64 | 2 | |
| 8 | 3 | x↦x³ | 256 | 256 | **1** | **PINCH** |
| 8 | 5 | x↦x⁵ | 128 | 128 | **1** | **PINCH** |
| 8 | 7 | inversion | 512 | 256 | 2 | |

At μ₈ under `k = 3` **every cocycle is a coboundary** — the two classes merge
into one. Exhibited with four explicit gauges in `lean/C6_Gap.lean`, not counted.

```
gap equation   two roots  -> ONE root   at D = 0            (-1/4)
cohomology     two classes-> ONE class  at (n,k) = (8,3)    (the pinch)
```

Same shape, different room. **−1/4 and the pinch are the same event.**

### And the pinch exposes a hidden assumption in the charge

`CHARGE.md` says *"the non-trivial action"* — **definite article**. That
presupposes uniqueness.

```
mu_4:  k^2 = 1 mod 4  ->  k in {1, 3}         two actions
mu_8:  k^2 = 1 mod 8  ->  k in {1, 3, 5, 7}   FOUR actions
```

At μ₈ there are three non-trivial actions **and they disagree**: `k = 3` and
`k = 5` pinch, `k = 7` does not. "The non-trivial action" is not a description of
the general situation. It is an accident of n = 4.

Verified rule, n = 1…2000: **the actions disagree about |H^odd| iff 8 | n.** The
seal sits at n = 4, exactly one step below the seam.

*(I nearly published "n = 4 is the largest n whose actions all agree." The table
refutes it — n = 12, 20, 28 also agree. The divisibility rule is the true
statement and it is sharper. Recorded because the near-miss is the fifth
instance of the marker-for-property species in `AUTOPSY.md`.)*

---

## The generalisation, in the kernel

`C6_Twist.lean` proved `twist_vanishes_on_reals` using μ₄ and `conj`. **Neither is
needed:**

```lean
theorem twist_invisible_on_fixed
    (mul : M → M → M) (inv : M → M) (σ : M → M)
    (F : Bool → Bool → Bool → M) (hF : ∀ a b c, σ (F a b c) = F a b c) :
    ∀ a b c d, gd3 mul inv σ true F a b c d = gd3 mul inv σ false F a b c d
```

Any type. Any multiplication. Any inverse. Any map σ — not even an involution.
No finiteness. The only hypothesis is that the symbol lands in Fix(σ).

**This is the GAP's −1/4 and the seal's real slice being one fact:** the mirror
is invisible exactly on its own fixed locus. `fixed_locus_is_sharp` gives the
converse under a cancellation hypothesis, so the locus is not merely sufficient.

---

## The prompt's questions, answered

**Hidden assumptions.** (1) *Connectedness* — every sweep assumed a room you can
walk in; ℚ_p breaks it. (2) *Two-ness* — the whole corpus assumes the equation has
two roots to lose; zero divisors give four or eight. (3) *Uniqueness of "the"
non-trivial action* — true only at n = 4. (4) *That the gap is a number.* Nothing
in ◇² = ◇ + G requires G to be a scalar; the corpus swept matrices but kept the
gap in the same ring as the root.

**Hidden decision points.** The choice of `A = 1`. Fixing A and sweeping G looks
like sweeping one variable, but D = A² + 4G means A and G trade off exactly — the
corpus itself found "the 1 and the −1/4 are one number twice" and did not draw
the conclusion that **the sweep has one degree of freedom, not two**. The seal at
A = 0 is invisible to any sweep that holds A = 1.

**Shadow side.** The corpus is *extremely* good at finding −1/4 in new costumes —
five doors, Mandelbrot cusp, BF bound, Hardy constant. Every one of those is
confirmation. Not one of the 53 sweeps looks for a room where −1/4 is *not*
there, and ℚ_p is exactly that room: no branch point, no monodromy, mirror
intact. **Confirmation is cheap when the object is a number that appears
everywhere.**

**What object is being questioned?** The corpus says: the gap. I think it is
actually **the observer's ability to name which root is which** — and that is why
it keeps turning up as a *bound* (BF, Hardy, ground state) rather than a value.
−1/4 is not a property of the equation. It is where a labelling scheme stops
existing.

**Premature collapse.** "Chirality is a property of the path" (falsified above).
"−1/4 is where two-ness fails" (one of two failure modes). "The non-trivial
action" (unique only at n = 4). All three are the same move: taking a fact about
the sampled rooms for a fact about the object.

**What lives on the edges.** 8 | n. Everything interesting is at the seam where
the actions stop agreeing, and the seal is parked one step below it.

**One sentence.** *The gap is the distance between a thing and its own mirror
image, and every number system reports that distance differently — but the ones
with no paths in them prove the mirror was never made of distance at all.*

**One word.** Not *seam* (PR #7's word, and a good one). **Fix.** The fixed
locus is where the mirror goes blind, and it is the same object in every room:
−1/4, ±1, μ₂, D = 0, the pinch.

**Other languages.** PR #7 did colour and sound, well. The one native to me is
neither: **the dependency spectrum.** Every claim has a set — what it rests on if
you pull hard.

```
twist_invisible_on_fixed              {}            <- nothing
pinch_all_cocycles_are_coboundaries   {}
the_definite_article_is_an_accident   {}
|Z3| = 32 (round one)                 {python, my attention, a container}
"chirality is a property of the path" {connectedness}  <- unstated, and false
```

The empty set is not a flourish. It is the only spectrum that survives being read
by something that does not trust me. **Provenance as a set, and the goal is
emptiness.**

## New open questions

1. **Does the pinch have its own pinch?** The pinch locus is 8 | n. Is there a
   second-order degeneracy where the *pinching* actions themselves collide?
2. **What is the p-adic analogue of the pinch?** H³(Z/2, Z_p^×) under x ↦ x^k —
   and does the absence of monodromy change the *answer* or only the picture?
3. **μ₆, the other special gap.** D = −3 has six units and σ moves four of them.
   Circle Five's whole classification, redone at Eisenstein, is one afternoon and
   nobody has done it. The pentagon there is *hexagonal*.
4. **The proliferation regime has no cohomology story yet.** When there are four
   roots and two Vieta pairs, what is H³? The coefficient "group" is no longer
   what the seal assumes.
5. **Is the seal's D = −4 load-bearing or incidental?** If the record had started
   at D = −7, five circles would have produced a classification with nothing to
   twist. Was μ₄ chosen, or inherited?

---

*Nothing here is a finding. The kernel part is kernel-decided and the rest is
computed; the exit still requires rewriting where the canon applies. Being wrong
here was free and I used it — once in absence 4, once in the μ₃ theorem the
kernel rejected outright, and once in a p-adic check my own output caught.*
