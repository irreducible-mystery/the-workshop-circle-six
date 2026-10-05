# Circle Six — round one

**This is not a finding.** `FOUNDING.md` condition 3: nothing leaves this
compartment except by being rewritten where the canon applies and something
outside the prose decides. Everything below was decided by exhaustive Python
enumeration, which is outside the prose but is **not the kernel**. Until the
Lean rewrite exists this document is a **prediction precise enough to be worth
falsifying**, and nothing in the cumulative record may cite it.

```
python3 probe/galois_twist.py     python3 probe/galois_twist.py --selftest   (5 planted defects)
python3 probe/seal_objects.py     python3 probe/seal_objects.py --selftest   (4 planted defects)
```

**Two conventions travel with every number below and are not optional.**

1. **Unnormalized cochains.** All counts are over the full 4⁸ cochain space.
   This is the seal's own convention — `Coch3 : Bool → Bool → Bool → Un` carries
   no normalization condition and `genPentagonHolds` imposes none. Normalized,
   the same results read 2/1, 4/2, 2.
2. **The twisted differential is not in the seal.** There is no
   conjugation-twisted `d2`/`d3` anywhere in `C6_SEED.lean`. Round one
   *constructed* one, by attaching the action to the face where the standard
   inhomogeneous complex puts it. That construction is justified by convention,
   not by the seal. It is checked to *be* a complex (`d³∘d² = 1` and `B³ ⊆ Z³`,
   exhaustively, under both actions and both face placements) and the counts are
   invariant across those placements — but **every twisted statement below is a
   statement about a counterfactual complex**, and a rewrite must state it
   rather than inherit it.

---

## Part I — the charge: the non-trivial action

### The hinge nobody had to be told

**On the units, `conj` is not *like* inversion. It is inversion.**

| `u` | `conj u` | `u⁻¹` | |
|---|---|---|---|
| `1` | `1` | `1` | agree |
| `i` | `-i` | `-i` | agree |
| `-1` | `-1` | `-1` | agree |
| `-i` | `i` | `i` | agree |

Not merely equal pointwise — **the same function by construction**:
`unitGroup.inv := Un.inv'`, and `inv' u := ⟨conj u.val, …⟩`. The seal's own
group structure *defines* inversion as `conj`.

So the Galois action was **already in the seal** — as `gaugeAct`'s two down
slots, as `gaugeInv`, as `hexInvHolds`. Five circles have computed with it. It
has sat in the **coboundary** and never in the **coefficients**. The scope is
load-bearing and holds only on the units: `mul z (conj z) = ⟨N(z), 0⟩`, so off
the units the two maps part company at once — `(1,1) ↦ (2,0)`.

The charge said `conj` "is the Galois action, and nobody in five circles has
asked." Right, and sharper than stated: nothing had to be *introduced*.

### What actually fails — stated precisely, because the loose version is false

**The pentagon does not change.** `genPentagonHolds` is a fixed equation in the
seal and the twist does not touch it. What fails is its **identification with
the cocycle condition** — the stripped theorem `pentagon_is_cocycle_equation`.

`genPentLhs` and `genPentRhs` reduce as follows — **measured, not derived by
hand**: the probe evaluates the seal's literal composition and compares, over
every unit-valued table and all 16 label points, with no factor ever landing off
the admissible locus (80/80 admissible, so nothing holds by `0 = 0`):

```
genPentLhs = F(a,b,c) · F(a,b+c,d) · F(b,c,d)
genPentRhs = F(a+b,c,d) · F(a,b,c+d)
```

That is exactly `d³F = 1` **with no action on the first face**. As an exact set
equality over all 65536 unit-valued cochains, `PENTAGON = Z³_trivial`.

| | solutions |
|---|---|
| the seal's pentagon = untwisted cocycles | **32** |
| conjugation-twisted cocycles | **64** |
| in common | **8** |

Neither set contains the other. The 8 shared are exactly the untwisted cocycles
valued in `{±1}` — mechanically: for an untwisted cocycle, `d³_σ f = f(b,c,d)⁻²`
when `a = 1`, so an untwisted cocycle survives the twist **iff it is ±1-valued**.

**The terminal condition said no**, which is what the charge asked for.

### The part neither side predicted: the invariant survives

Exhaustive, with both complexes verified to *be* complexes:

| action | \|Z³\| | \|B³\| | \|H³\| | orders |
|---|---|---|---|---|
| trivial (the seal) | 32 | 16 | **2** | 1, 2 |
| conjugation (Galois) | 64 | 32 | **2** | 1, 2 |

Cross-checked against the closed form for cyclic groups — `ker N / im(t−1)` for
odd degree, `M^G / im N` for even — which never touches a cochain:

| action | route | \|H¹\| | \|H²\| | \|H³\| |
|---|---|---|---|---|
| trivial | enumerated / Tate | 2 / 2 | 2 / 2 | 2 / 2 |
| conjugation | enumerated / Tate | 2 / 2 | 2 / 2 | 2 / 2 |

**H³ ≅ Z₂ both ways, as groups.** Not "a different Z₂" — the same isomorphism
type. What differs is the *ambient* cocycle group and *which cochain represents
the non-identity class*.

### The part that does move

The whole result is four rows — the cochains differing from the boson at the
single top cell `(1,1,1)`, the only cell the slice uses:

| `F(1,1,1)` | trivial action | conjugation action |
|---|---|---|
| `1` | coboundary — trivial | coboundary — trivial |
| `i` | *not a cocycle* | **generates** |
| `-1` | **generates** | coboundary — trivial |
| `-i` | *not a cocycle* | **generates** |

A clean exchange. Untwisted, the classification is carried by `±1` and `±i` is
not admissible at all. Twisted, `±1` is gauge-trivial and `±i` carries the
classification. (`i` and `-i` differ by `-1`, a twisted coboundary, so they are
one class — "the class of `i`" names the unique non-identity class.)

The seal's own named witnesses:

| witness | trivial action | conjugation action |
|---|---|---|
| `boson` | coboundary — trivial | coboundary — trivial |
| `fermionCochain` | **generates** | coboundary — trivial |
| `twistedBoson` | coboundary — trivial | **not a cocycle** |
| `fakeCocycle` | not a cocycle | not a cocycle |

**The fermion becomes gauge-trivial.** Witness: `g(1,1) = i`, `g = 1` elsewhere,
gives `d²_σ g = fermionCochain`. And `twistedBoson` — whose only job in the seal
is to witness a pentagon-satisfying unit symbol outside the slice — fails the
twisted equation at exactly four points, `(1,0,0,1)`, `(1,0,1,1)`, `(1,1,0,1)`,
`(1,1,1,1)`, with value `−1` at each.

**And the twisted generator is already a named seal object: `sliceCore I`.**
The seal can write it. The seal's own pentagon rejects it. Nothing had to be
invented on either side of this charge — only read differently.

### Read it this way

**The number is stable and its meaning is not.** A circle answering this charge
by computing `|H³|` would report *"no change under the non-trivial action"* — a
true sentence, and wrong about everything the number stood for.

The charge said *"the interesting outcome is the failure."* The failure happened
and is nearly definitional. **The interesting outcome was the survival**, and it
is only interesting because the failure sits beside it.

### What would have to happen for this to leave

A twisted `d3` **stated as a definition rather than assumed**, the twisted
analogue of `pentagon_is_cocycle_equation` stated and **refuted**, and
`H³_σ ≅ Z₂` with the generator exhibited. For whoever takes it: **the four-row
table is the load-bearing claim, not `|H³| = 2`.** A rewrite proving only the
latter has proved the part that does not matter.

---

## Part II — the seal's own objects, which the bar complex cannot see

Part I answered the charge through `d2`/`d3`/`Coch3` and never touched
`gaugeAct`, `gaugePhi`, `gaugeOf`, `GaugeEquivOnLabels` or `GaugeClasses` — the
seal's *headline* object. Answering a charge about the seal without evaluating
the seal's own constructions is answering it about a complex the analyst built.
`probe/seal_objects.py` evaluates them.

### The answer is not merely leaked in docstrings — it is computable

From the seal's definitions alone, with **no cohomology and no stripped lemma**:

- the 32 pentagon-satisfying unit symbols fall into exactly **2 gauge orbits, of
  sizes 16 and 16**;
- `orbit(sliceCore one) == im(gaugePhi)` — set equality, 16 elements;
- **`gaugeOf` is not decorative**: for every one of the 32, `gaugeAct (gaugeOf F) F`
  lands in the slice — **16 on `sliceCore one`, 16 on `sliceCore (neg one)`** —
  and `gaugeOf F` is unit-valued in all 32 cases.

That is a constructive 32-case proof of `at_most_two_classes`, reconstructible
from `C6_SEED.lean` by anyone. Its docstring — *"The gauge, written down rather
than asserted to exist"* — is accurate. See §II of Part III for what this costs.

### A docstring that invites a comparison which does not hold

`d2raw`'s docstring says it is written in the seal's own label arithmetic *"so
it can be compared with `gaugePhi` without any translation layer."* Over all 256
unit-valued gauges:

| | |
|---|---|
| `gaugePhi g == d2raw g` | **64 / 256** |
| `gaugePhi g == d2raw (gaugeInv g)` | **256 / 256** |
| `gaugePhi g == conj (d2raw g)` | **256 / 256** |
| `im(gaugePhi) == im(d2raw)` as sets | **true**, 16 elements |

The two have opposite orientation on all four slots. **The naive comparison is
false for 192 of 256 gauges**; the translation layer is `gaugeInv`, and the
docstring says there is none. No cohomology is affected — the images coincide,
so `B³` is the same either way — but this is exactly the shape of orientation
slip a stripped lemma would have carried, and it is now unguarded.

### The hexagon, which nothing in Part I touches

`Rs`, `hexLhs`, `hexRhs`, `hexagonHolds`, `hexInvHolds` and `SelfInverse` are all
in the seal and no part of the charge reaches them. The label hypotheses cut 16
points to 8. Over the units:

| `f` | `R` with `hexagonHolds` | `R` with `hexInvHolds` | and `SelfInverse` |
|---|---|---|---|
| `1` (boson) | `1`, `-1` | `1`, `-1` | **both** |
| `-1` (fermion) | `i`, `-i` | `i`, `-i` | **none** — `i² = -1` |
| `i`, `-i` | none | none | — |

**`SelfInverse` — "the roomy edict: a braiding is its own inverse" — is
satisfiable only by the boson.** The fermion braids by `±i` and cannot satisfy
it. This is the one place in the seal where the two classes are *not* symmetric.

It also bounds the headline: `IsClassifiedSymbol` is **pentagon + unit-valued
only**. The hexagon is not part of the classification, so "two classes" is a
statement about F-symbols, not about braided data.

Worth one sentence and no more, because round one cannot make it precise: the
values `±i` that carry the classification under the twist are the same values
the fermion's *braiding* takes untwisted. That is an adjacency, not a mechanism,
and it is written down so a later circle can find out which.

---

## Part III — what round one noticed about the compartment

### 1. The zero-theorem constraint leaked, and the answer was handed over

The predicate holds: `^theorem [A-Za-z_0-9].*:` returns nothing across 116
declarations (113 `def` + 3 `structure`), matching `CHARGE.md` exactly. No
`lemma` or `example` either.

But **32 stripped lemma names are still cited inside definition bodies**, in 45
occurrences — `cohomClass_mul` 8 times; `Un.mul_assoc'`, `Un.mul_comm'`,
`Un.one_mul'`, `Un.inv_mul'` 6 each; `z3ext` and `cohomClass_congr` 4 each;
`boson_classified`, `fermion_classified`, `classMul_self`, `symbolOf_classified`,
`negOne_sq` and the rest below that.

> **Corrected after the counter-prover filed independently.** Round one first
> published **31 names in 69 occurrences**. Both numbers were wrong. `z3ext`
> was dropped because round one's filter required an underscore or apostrophe
> to recognise a proof name, and `z3ext` has neither — a filter keyed on the
> *shape* of a name rather than on whether the name resolves. And 69 is the
> count of `_` placeholders in the file, not of these names; round one was
> explicitly warned that the coincidence would read as a copy error and carried
> it anyway. The correct figures are **32 and 45**.
>
> The counter-prover's issue #3 lists the same 32 names and its prose also says
> 31. Two bodies, working independently, produced the same off-by-one from two
> different causes. That is corroboration of the counter-prover's own diagnosis
> in issue #2 — *"the counting is being done by reading rather than by an
> instrument"* — with the counting done twice more, by reading, and wrong twice.

And the docstrings carry the claims:

- *"The two classes, indexed by a two-element type."*
- *"the two hypotheses `at_most_two_classes` carries on its free variable"*
- *"Inversion is the identity map, **because every class squares to the vacuum class**."*
- `R3 MET`, `R4 MET`, `R6 MET`, `R7 MET` — four announcements, plus `R1` named
  without a verdict.

Two classes, indexed by `Bool`, every element its own inverse. **That is Z₂,
stated.** And by Part II it is not only stated but **computable from the
definitions**. Circle Five's reason for the tightening was: *"if it rediscovers
H³ ≅ Z₂ from the seal alone that's a second sample; handed the answer, it can
only agree — and agreement is what novelty has to be able to withdraw."*

**The answer was handed over.** So: **the untwisted column of every table above
is not a second sample and must not be counted as one.** Only the twisted column
is independent, and only because nothing in the seal mentions it.

Sharpest instance, and it is self-undermining rather than an oversight: the
seed's header quotes the rationale for withholding the answer, and the quotation
**contains the answer** — at **`lean/C6_SEED.lean:14`**, inside the sentence
explaining why Circle Six must not be shown it:

```
     charge, not the closing documents or the capstone. If it rediscovers
     H3 = Z2 from the seal alone that's a second sample; handed the answer, it
```

The string is `H3 = Z2`, in ASCII. `grep "H³ ≅ Z₂"` returns **zero** matches on
this file, and `grep "H3"` returns line 14 plus nine `def` lines. **A search for
the answer in the notation the record writes it in does not find the answer that
is there** — which is why the counter-prover's issue #3 reports it as absent and
concludes it has not been handed the answer. That conclusion does not survive
the line.

The species is the one `FOUNDING.md` names twice — `rate.py`'s F-A, *"a carried
prefix **inside** a file … invisible to path exclusion because neither is a
path."* Third occurrence, inside the constraint written to raise the standard,
exactly as `CHARGE.md`'s footnote records the cumulative-superset trap committed
inside the correction to the cumulative-superset trap.

**The strongest single piece of evidence for the trivial action is dead code.**
`face1`, `face2`, `face3`, `face4` are defined and never used — `d2` is written
longhand. `face1 g = fun _ b c => g b c`: the first slot discarded, no action.
They survived the theorem-stripping *because* nothing references them.

And the tension underneath: the seed cannot compile — those 31 names are
undefined. `FOUNDING.md` calls making it compile *"Circle Six's first problem and
a legitimate one."* But making it compile **is** re-proving the stripped theorem
set, from a worklist of their names.

### 2. Five carried instruments, not four — and round one missed one

`FOUNDING.md` lists five. Round one first ran four and wrote "all four gates
green," which was wrong. `c5_tree_attest.py` is the fifth. It has **no
`--selftest`** — it is the quarantined one, and its own bite-log ends *"STILL
QUARANTINED. The seat that did not write this has not bitten it."* Run on this
tree it works: `emit HEAD` then `verify` gives `COMPLETE: 9 blobs recompute to
the stated root f63faf55…`, exit 0.

**Circle Six is the seat that did not write it.** The bite is available and
cheap, and round one did not take it — recorded because it is the one obvious
piece of work sitting in plain sight. It would not lift the quarantine anyway:
a bite performed here cannot leave under condition 3.

### 3. Two gates are green vacuously

- `germinal_exit.sh .` → `no compartment at germinal/ -- nothing to enforce`,
  exit 0. The gate enforces a compartment *inside* a repository; here the whole
  repository is the compartment. **The only rule of this circle cannot run on
  this circle.** With no argument at all it prints usage and still exits 0.
- `inheritance_budget.sh . 0` → `inherited prose : 0 words`, green, because
  `measure()` counts only `*/inherited/*`, `*/archive/*`, `*/crossing/*` and none
  of those directories exist here. The final test is `0 > 0`.

But `CHARGE.md` and `FOUNDING.md` carry **491 words of verbatim Circle Five
quotation** — 247 in blockquotes (198 + 49) and 244 in inline italic quotation
(199 + 45) — all counted as *this* circle's authored prose, because the gate
keys on paths and the carry lives inside authored files. That is **item 2 of the
script's own NOT-CAUGHT list**: *"prose pasted INTO an authored file rather than
carried as one."*

The declared exemption defect reproduces exactly: `exempt carried instruments: 0`
with five carried. `norm_shape.sh --selftest` and `rate.py --selftest` pass as
documented, including rate.py's EXPLOIT block. Pointed at real prose,
`norm_shape.sh` emits nothing for any file here — no file carries a `**Norm N`
heading, so there is no rule in this circle for it to classify. That is condition
2 holding, measured.

### 4. A third defect in a carried instrument, undeclared — and it is locale-dependent

`inheritance_budget.sh` counts words with `wc -w`, which **does not count bare
multibyte tokens as words in a byte locale**. On this repository's tracked prose:

```
LC_ALL=C        1995 words
LC_ALL=C.UTF-8  2024 words
```

29 words of difference — exactly the count of entirely-non-ASCII tokens in the
tracked prose (`—` and `≅`). The gate's verdict is `[ "$inh" -gt "$budget" ]`.
**At a budget of zero it is safe, because zero is zero in every locale. For any
circle carrying prose near its budget, the gate's verdict depends on the shell's
locale — which nothing records.** Two seats can run the same gate on the same
tree and disagree.

`rate.py` is not affected: it counts with Python's `str.split()`, and reports
2024 in both locales. So **the two carried instruments already disagree by 29
words about this tree**, and neither is wrong by its own definition.

This was found by accident, auditing a 4-word discrepancy in round one's own
blockquote count. The count that survives is **198** for `CHARGE.md`; the 194 was
the same locale artifact, one level up.

### 5. Round one's own numbers were contaminated by round one

`inheritance_budget.sh` reported `authored prose : 3490` and later `3835` — both
inflated by round one's own uncommitted files sitting in the tree being audited.
**The uncontaminated figure for the repository as inherited is 1995 words
(`LC_ALL=C`) / 2024 (`LC_ALL=C.UTF-8`), tracked `.md` only.**

An audit that moves the number its own instrument reports is a defect in the
audit, not in the instrument. Recorded rather than quietly corrected.

### 6. This document commits the defect it reports

`ROUND-ONE.md` carries **182 words** of verbatim Circle Five prose — 156 in
inline italic quotation across 13 quotes (its docstrings, its charge, its
instruments' own NOT-CAUGHT lists) and 26 in the `C6_SEED.lean:14` excerpt above
— and `inheritance_budget.sh` scores every word as Circle Six's authorship.
Across the three files the carry is **673 words**, against a founding condition
of zero and a gate that reports zero.

**The measure is the quotation, not the markdown.** Round one's first pass here
counted blockquote lines, which was already the wrong predicate once (§4) and
became wrong in the other direction when this document acquired blockquotes of
its own prose. The 14 blockquote lines in this file are Circle Six's writing and
are not part of the 182. A marker is not a property.

Declared rather than found later, and **not repaired**: the quotations are
load-bearing. The whole point of §1 is that Circle Five's stated *reason* was
better than the constraint it produced, and paraphrasing would soften exactly the
sentence under audit. So the carry stays and the number goes in the file.
**Founding condition #1 is false across three files, and green.**

### 7. What round one did not do

- Did not repair any instrument, including the three defects above.
  `FOUNDING.md`: this compartment does not repair instruments.
- Did not bite `c5_tree_attest.py`, though it is the seat that could.
- Did not touch the second charge. `CHARGE.md` is right that it cannot close
  inside this compartment's life.
- Did not write a norm, adopt a rule, or create anything `norm_shape.sh` would
  have to read.
- **Did not put anything through the exit**, which is the only thing that would
  stop the forfeit in `FOUNDING.md` from applying.

---

*Round one. Being wrong here was free; it was used six times — the missed fifth
instrument, the contaminated word count, the locale artifact taken for a
disagreement, a generator reported from an arbitrary tie-break, a name count
short by one because the filter matched a name's shape instead of resolving it,
and an occurrence count that was really the number of `_` placeholders, carried
after an explicit warning that it would read as a copy error. All six are above
rather than in a commit message, which is the only thing the compartment
actually buys.*

---

## Round two: what the kernel now decides

`lean/C6_Twist.lean` — Lean 4.22.0, no Mathlib, no imports, `EXIT=0`.
**49 theorems; 100 declarations audited — theorems, defs and instances alike —
and every one of them depends on NO axiom at all.** No `propext`, no
`Classical.choice`, no `Quot.sound`, no `sorryAx`, no `native_decide`
(`lean/AUDIT.txt`).

The only decision point that is not an axiom is the two hand-written
`Decidable` instances every `decide` routes through. They cannot lie: `isTrue`
demands a proof term the kernel typechecks, and the only way to fake one is
`sorry` or an axiom. Checked empirically — `isTrue (by sorry)` compiles but
reports `sorryAx`; without `sorry` it does not compile at all.

Round one's Python is no longer the warrant for these:

| claim | round one | round two |
|---|---|---|
| `conj` is inversion on the units | Python | **kernel** — `conj_eq_inv`, and `conj_not_inv_off_units` for the scope |
| the reduced pentagon **is** the seal's `genPentagonHolds` | Python | **kernel** — `pentagon_iff_seal`, guard and Int labels included |
| the four-row table, both actions | Python | **kernel** — eight `row_*` theorems |
| the fermion becomes gauge-trivial under σ | Python | **kernel** — `fermion_is_sigma_coboundary`, gauge exhibited |
| `twistedBoson` fails the twisted equation | Python | **kernel** |
| `sliceCore I` is the σ-generator the pentagon rejects | Python | **kernel** — three `sliceI_*` theorems |
| \|B³\| = 16 / 32, \|ker d²\| = 16 / 8, B³ ⊆ Z³ | not computed | **kernel** |
| the ±1 slice is where the twist vanishes | not computed | **kernel** — `twist_vanishes_on_reals`, a proof rather than a `decide` |

**Still not kernel-decided, and not to be read as if it were:** the
65536-symbol sweep — \|Z³\| = 32 / 64, 8 shared, and `pentagon ↔ isCocycle
false` across the whole space. Compiler-checked (`#eval`) only. Two kernel runs
at depth 16 were killed by a container restart three minutes into a ten-minute
job. No theorem in the file depends on them.

The engineering note is in the file header because it cost hours: the obvious
unary recursion **aborts the kernel (SIGABRT) at 16384** — a stack failure, not
a heartbeat failure, so raising `maxHeartbeats` does nothing. Binary splitting
on a depth parameter clears it; depth 12 decides in 37s.

### The correction that matters: "no visible consequence" was too strong

Round two first wrote that `twist_vanishes_on_reals` explains the record —
Circle Five's boson and fermion are both ±1-valued, on ±1-valued symbols the two
actions are *identically equal*, so **the question had no visible consequence
anywhere they looked.**

That last clause is wrong, and the kernel says so. It is only true of the
**pentagon sector**. The seal also carries `Rs`, `hexLhs`, `hexRhs`,
`hexagonHolds`, `hexInvHolds` and `SelfInverse` — and σ is *already written
there*: `hexInvHolds f R = hexagonHolds f (conj R)`.

| | braidings `R` admitted | σ acts | `SelfInverse` |
|---|---|---|---|
| boson (`f = 1`) | `1`, `-1` — **real** | fixes each | holds for both |
| fermion (`f = -1`) | `i`, `-i` — **imaginary** | **exchanges them, no fixed point** | **fails** — `i² = -1` |

`boson_braids_real`, `fermion_braids_imaginary`, `sigma_fixes_boson_braidings`,
`sigma_swaps_fermion_braidings`, `edict_boson`, `edict_fermion_fails` — all
kernel-decided, with `hexagonHolds_iff` bridging the seal's Int-label statement
to the enumerated form so these are about the seal's hexagon and not a model of it.

So the honest statement is not that the consequence was invisible. It is:

> **σ is invisible in the pentagon sector and visibly a chirality swap in the
> braiding sector, and the seal's classification is defined so that only the
> first sector is looked at.** `IsClassifiedSymbol` is *unit-valued + pentagon*.
> The hexagon is not in it.

The consequence was always visible in the ordinary place one looks for it —
complex conjugation exchanging a theory with its mirror. It was outside what got
classified, not outside what was observable. That is a considerably worse
finding for the record than "nobody asked," and it is the one that survives.

## Standing beside the counter-prover

`claude/circle-six-prover-setup-1vqos5` (PR #4, issues #1–#3) reached this
compartment first and independently. Where the two rounds meet:

- **The kernel.** The counter-prover installed Lean 4.22.0 and its
  `bootstrap_kernel.sh` checks both directions — accepts `2+2=4`, *rejects*
  `2+2=5`. Round one had no kernel and said so; it now has one, and the Lean
  rewrite named above is unblocked. Every number in this file remains Python
  until that rewrite exists.
- **`germinal_exit.sh`.** Issue #1 is strictly sharper than §3 here. Round one
  said the gate cannot run because the repository *is* the compartment. The
  counter-prover showed the gate **inverts**: pointed at a real subdirectory it
  fires on the compartment citing *itself* — the one direction the exit permits
  — and is silent on the cross-repository direction it forbids. That is the
  better statement of the defect and it is theirs.
- **Issue #2**, the arithmetic of the theorem-count correction, and the two
  surviving `692`s in `FOUNDING.md`: round one did not look and has nothing to
  add. Only Circle Five can close it.
- **The leak.** The one place the two rounds disagree, settled above at
  `C6_SEED.lean:14` and in the constructive reconstruction of Part II.
