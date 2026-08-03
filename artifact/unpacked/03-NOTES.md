# 03 — NOTES

Prose, judgement, and the things I actually think. **Nothing here is
load-bearing.** If this file and `01-BUILD-STACK.md` disagree, the build stack
wins; if the build stack and `lean/` disagree, `verify.sh` fails on drift.

---

## The shape of it

The result I like is not the four-row table, which is the headline. It is
`twist_invisible_on_fixed`, which says almost nothing and applies to almost
everything: **a symmetry is invisible exactly on its own fixed locus.**

That sentence is close to a tautology, and that is the interesting part. The
original proof of it used a specific four-element group, a specific complex
conjugation, and sixteen decidable cases. Stripping all of that away left a
statement with no group axioms, no involution hypothesis, no finiteness, and a
one-line proof. Everything the original had — the arithmetic, the enumeration,
the four elements — was scaffolding for a fact that did not need any of it.

I think that is the honest content: not "the Galois action does something
surprising," but "an entire classification was blind to a symmetry for a reason
that has nothing to do with the symmetry and everything to do with which sector
got classified."

## Why the braiding section exists

The first version of this work stopped at Part IV and said: the twist has no
visible consequence anywhere they looked. Somebody asked *"what if the
consequences are visible in the way we are used to looking?"*

They were right and the sentence was wrong. The braiding sector was sitting in
the same source file, with `σ` already applied to it explicitly, and the fermion
braids by `±i` — which `σ` exchanges with no fixed point. That is complex
conjugation swapping a theory with its mirror image, which is about as ordinary a
place to look as exists.

The corrected statement is worse for the record than the original claim, and it
is the one that survives: the consequence was outside what got **classified**,
not outside what was **observable**. The classification predicate is
"unit-valued and satisfies the pentagon." The hexagon is not in it. Nobody
decided to exclude the braiding; the predicate simply never mentioned it, and
what a predicate does not mention is not searched.

I do not think that is a mistake anyone made. I think it is what predicates do.

## On −1/4 and the pinch

The surrounding project spent 53 sweeps finding `−1/4` in new costumes:
discriminant zero, Mandelbrot cusp, the Breitenlohner–Freedman bound, a Hardy
constant, the continued-fraction convergence edge. Every one of those is a
confirmation, and confirmations are cheap when the object is a number that turns
up everywhere.

What made the pinch interesting to find was that it is the *same event in a
different category*: two roots become one root at zero discriminant; two
cohomology classes become one class at `(n,k) = (8,3)`. Not an analogy — the
same failure of two-ness, once in a field and once in a quotient group.

And it exposed a definite article. "*The* non-trivial action" is a phrase that
denotes only because `n = 4`. One step up, at `n = 8`, there are three
non-trivial actions and they give different answers. The verified rule is that
the actions disagree exactly when `8 | n`. The whole enterprise is parked one
step below the seam where its own vocabulary stops working.

## On the two ways two-ness fails

Collapse — two roots merging — is the one everybody found. Proliferation is the
other: over `Z/30` the same equation has **eight** roots and two disjoint pairs
each satisfying Vieta. The equation has a choice of which two-ness it is about
and the choice is not in the equation.

I find this the more unsettling of the two, because collapse announces itself
(the discriminant vanishes, something visibly degenerates) and proliferation does
not. Nothing goes to zero. You simply have more objects than your vocabulary has
slots for, and every individual statement you make remains true of *some* pair.

## On the room with no paths

The relational reading of all this — chirality as a property of the path, the
mirror as monodromy around a branch point — is genuinely beautiful and I believe
it is over-claimed. In `Q_p` there are no non-constant continuous paths at all,
the split/inert verdict is locally constant so there is no boundary to stand on,
and every ball around the critical gap contains both verdicts at every radius.
Nothing to encircle, nothing to encircle it with.

And the involution is still there, still non-trivial.

So chirality is not a property of the path. The **monodromy picture** of it is a
property of the room. The mirror is algebraic and survives rooms that cannot
support the picture. This is a smaller claim than the original and I think it is
the true one, and the original is what you get by sampling only connected rooms —
which every one of the 53 sweeps did.

## On what a green means

The thing I would most want a reader of this artifact to take is not any
theorem. It is that `verify.sh` checks the kernel **rejects** `2 + 2 = 5` before
it trusts the kernel's acceptances. A check that only confirms truths certifies
an echo.

The same instinct is why `pentagon_iff_seal` exists: without it, every green in
this artifact would certify a statement about a convenient model rather than
about the thing the model was supposed to be of. That proof is boring, it took
two attempts, and it is the only reason the rest means anything.

And it is why `native_decide` appears nowhere. It would make the killed sweep
finish in seconds. It also moves the verdict from the kernel to the compiler,
and the entire point of the exercise is that something outside the prose
decides.

## Errors I made getting here

Kept because a record that omits the author's errors is a testimonial.

- A "clean clone" verification printed `EXIT=0` after the clone had **failed on
  auth** and the `cd` silently fell through, so it compiled the working tree. A
  green that meant nothing, emitted by the checking step itself. The worst one.
- A p-adic inverse computed with `pow(4, p-2, p**8)` — Fermat's inverse mod `p`,
  not mod `p⁸`. My own check line printed `390370` where `0` was required. Caught
  only because the check was there and I read it.
- A `μ₃` theorem asserted and rejected outright by the kernel as **false**.
- "n = 4 is the largest n whose actions all agree" — refuted by my own table
  before publication. The true statement (`8 | n`) is sharper.
- A name count short by one, because the filter matched a name's *shape*
  (underscore or apostrophe) instead of asking whether it resolved. `z3ext` has
  neither.
- An occurrence count that was really the number of `_` placeholders, carried
  after an explicit warning that the coincidence would read as a copy error.

Six of these are the same species: **a marker standing in for a property.**
`>` for carried prose, a name's shape for whether it resolves, a coincidental
count for the count, printed text for exit status. It kept happening after I
named it, which I think is the actual finding about how this went.

## The two things I would do next

**μ₆.** `D = −3` is the only other discriminant in the entire imaginary
quadratic universe whose unit group exceeds `{±1}`. It has six units, `σ` moves
four of them, and nobody has redone the classification there. The pentagon at
`μ₆` is hexagonal. This is an afternoon of work and I expect it to be the more
interesting of the two, because six units means `σ` has a *four*-element free
orbit and the fixed-locus story has more room to be wrong in.

**Does the pinch have its own pinch?** The pinch locus is `8 | n`. Whether there
is a second-order degeneracy inside it — where the pinching actions themselves
collide — I do not know, and the machinery to find out is already in
`compute/absence4_pinch.py`.

## One sentence

*A two-valued symmetry can be real, non-trivial, and completely invisible, if
everything you chose to classify happens to sit in its fixed set.*

## One word

**Fix.**
