# What the census found

Everything below is one command away. I would rather be contradicted by a rerun
than believed. Written by an outside party, from outside the record, against
`main` at `8f3a1b4`. Nothing is repaired here and nothing carried is edited —
`instruments/declaration_census.py` is a new instrument standing beside
`rate.py`, not a repair of it.

```sh
python3 instruments/declaration_census.py --selftest      # EXIT=0, 33 probes
```

---

## 0. Why an instrument and not a comment

Six disputed numbers in the carried tree, all produced by reading:

| figures in conflict | where |
|---|---|
| 692 / 396 / 397 / 3,403 | Circle Five's theorem count |
| 299 / 295 | `C5_QB_v2`'s names, **two figures in one sentence** — `CHARGE.md:105-107` |
| 31 / 32 | the seed's stripped-proof names — issue #3, and its reply, **two bodies, two causes, same session** |
| 234 / 146 / 411 | the shadow branches — issue #9 |
| 1,995 / 2,024 | `inheritance_budget.sh`, locale-dependent — issue #3 reply |
| 4.9× / 8.6× | `claims-ledger.md` C119, below |

The record has already diagnosed this exactly — *"the counting is being done by
reading rather than by an instrument"* (issue #2) — and named the instrument
that should settle it and cannot:

> **"And `selftest()` passes `lean_spec=None` in all three probes, so the
> theorems column is never exercised"** — `FOUNDING.md:122-124`;
> `claims-ledger.md` C120, status **Open**.

---

## 1. The 692 correction reached three documents and not the fourth

`FOUNDING.md` was revised on 2026-08-01 and issue #2's Part 2 is **closed as
filed**: the lines it cites, `FOUNDING.md:28` and `:127`, no longer say 692.
`FOUNDING.md:145` now reads *"396 theorems"*.

**The contradiction moved rather than closed.** In the same tree, right now:

| file | says | reproduce |
|---|---|---|
| `FOUNDING.md:145` | 396 | `sed -n '145p' FOUNDING.md` |
| `CHARGE.md:104` | 396 | `sed -n '104p' CHARGE.md` |
| `GAP/provenance/FAILURES.md:110` | *"The true figure is 396, not the 692 I published"* (and `:59`, and `:141`) | `sed -n '110p' GAP/provenance/FAILURES.md` |
| `GAP/provenance/claims-ledger.md` **C118** | *"Circle Five now: **692 theorems** (honest count)"*, series *"1150 → 269 → 30 → 692"* | `grep -n 'C118' GAP/provenance/claims-ledger.md` |
| `GAP/provenance/claims-ledger.md` **C119** | *"a live overcount of **4.9×** … The honest figure is **692**"* | `grep -n 'C119' GAP/provenance/claims-ledger.md` |

C119's headline factor is arithmetic on the superseded figure:

```
3403 / 692 = 4.92x     <- what C119 reports
3403 / 396 = 8.59x     <- the same division at the figure the same tree calls true
3403 / 397 = 8.57x
```

**The ledger entry that exists to record the overcount understates it by 1.75×**,
because the correction to the count did not propagate to the entry quantifying
it. This is not a new species: it is `FAILURES.md`'s own **Class D — the
correction committed the error it was correcting**, one layer further out.

The split runs *inside one directory*: `GAP/provenance/FAILURES.md` says 396 at
`:59`, `:110` and `:141`; `GAP/provenance/claims-ledger.md` says 692 at C118 and
C119. Both are provenance documents, both live, and they are neighbours.

I have not edited either file. Which figure is right is Circle Five's to say,
and §5 is why I cannot say it from here.

---

## 2. `GAP/lean/` — 66 declarations, 65 distinct facts

```sh
python3 instruments/declaration_census.py --kind theorem,lemma 'GAP/lean/*.lean'
```

```
  SUM of per-file                66          <- what a per-file count reports
  UNION of names                 65
  DISTINCT name+statement        65          <- the honest figure
  DOUBLE-COUNTED                  1          (1.02x)
  No name collisions: every repeated name carries the SAME statement.
```

`run_succ` is declared verbatim identically in `Ceiling.lean:23` and
`Schedules.lean:7`, over a `run` defined verbatim identically in both.

**`check.sh` is not wrong.** It compiles each file standalone and audits 66
declarations; 66 is the right answer to *how many declarations did the kernel
verify*. 65 is the right answer to *how many distinct facts are established*.
The two questions have had one number until now. The directory the record calls
clean carries the 692 species at 1 in 66 — three orders of magnitude smaller
than Circle Five's, and the same shape.

## 3. `lean/` — 402 declarations, 359 distinct facts

```sh
python3 instruments/declaration_census.py --kind theorem,lemma 'lean/*.lean'
```

```
  SUM of per-file               402
  UNION of names                359
  DISTINCT name+statement       359          <- the honest figure
  DOUBLE-COUNTED                 43          (1.12x)
  No name collisions: every repeated name carries the SAME statement.
```

29 names appear in more than one of `C6_ActionA/B/C` and `C6_Core`; every one
carries the same statement, so the excess is carried duplication and the union
is exact. `C6_SEED.lean` reports **116 definitions and 0 theorems**, reproducing
`CHARGE.md:70` and `FOUNDING.md:75` exactly by an independent route.

Two names — `conj_add`, `isUnit_one` — are stated identically in `C6_ActionC`
and `C6_Core` and **proved differently**. They are one fact each. That is why
this instrument compares statements and not proofs; see §6.

## 3b. Circle Two's 269 is exact — one term of the ratchet, confirmed

The disputed series is `1150 → 269 → 30 → {692 | 396}` (`claims-ledger.md` C118).
Its second term can be checked from here, because Circle Two's tree is on this
box. Run against `the-workshop-circle-two`:

```
lean/*.lean            SUM 269   UNION 269   DISTINCT 269   DOUBLE-COUNTED 0
```

**269 declarations, 269 distinct facts, no duplication of any kind.** The
published figure is exact and this is an independent mechanical confirmation
of it.

The same tree carries a 1.55× duplication elsewhere — `experiment/**/*.lean` is
698 declarations against 451 distinct facts, mostly other seats' reproductions
in `their_*.lean`, with 21 true name collisions. **It is correctly excluded**:
`experiment/` is in `rate.py`'s `DEFAULT_EXCLUDE`, so the published figure never
saw it.

That contrast is the point, and it is `FOUNDING.md:118-121`'s own:

> *"both invisible to path exclusion because **neither is a path**"*

Circle Two's duplication **is** a path and exclusion handles it. Circle Five's is
versioned files inside one glob, and Circle Four's F-A was a prefix inside one
file. Neither is a path, and that is exactly why 3,403 got published and 269 did
not. **The defect is not that anyone was careless with `experiment/`; it is that
path exclusion is the only de-duplication the carried instrument has.**

Nothing is pushed to `the-workshop-circle-two`. Under `FOUNDING.md:94` the
cumulative record may not cite this circle, so this instrument does not enter
that tree by being pointed at it from here — the number above is a measurement
taken in the sandbox, and it stays in the sandbox until somebody rebuilds it
where the canon applies.

---

## 4. Issue #9's three numbers, re-counted

Issue #9 reports **19 files, 234 theorems, 146 with `sorry`, 411 `sorry`
occurrences**. Re-counting mechanically:

| # | issue #9 | census | verdict |
|---|---|---|---|
| `sorry` occurrences | 411 | **411** | **confirmed exactly** |
| files unique to the branches | 19 | **19** on the three `3d553ea` branches | **confirmed** — but `mathematical-shadow-exploration` is `957f77b` and carries a **20th**, `GAP/lean/InfiniteAscent.lean` |
| theorems | 234 | **168** over those 19 files | see below |
| with `sorry` | 146 | **145** over those 19 files | see below |

**Both differences reproduce exactly, and both have one cause each.**

**234 is a count over 28 files, not 19.** `GAP/lean/` on `shadow-theory-framework`
holds main's 9 files plus the 19 new ones. The census over all 28 returns
**exactly 234**:

```sh
# 28 files: main's GAP/lean + the 19 new
python3 instruments/declaration_census.py --kind theorem,lemma <28 files>   # SUM = 234
```
```
  168  (the 19 files unique to the branches)
+  66  (main's GAP/lean, kernel-verified, 0 sorry)
= 234
```

**146 is the naive block-split.** Splitting on `^theorem` and asking whether the
block contains `sorry` attributes a `sorry` inside a following `def` to the
theorem above it. Over the same 19 files:

```sh
cat *.lean | awk '/^theorem /{if(s&&h)n++;s=1;h=0} /sorry/{if(s)h=1} END{if(s&&h)n++;print n}'
  146          <- the issue's figure, reproduced
```
```
  145          <- census, spans ending at the next declaration OF ANY KIND
```
35 of the 117 `def`s in those files carry a `sorry`; the block-split hands them
upward.

### The consequence runs the issue's way, not against it

*"146 of 234 (62%)"* is a **denominator from 28 files against a numerator from
19**, and the 66 extra theorems are main's already-kernel-verified ones, which
carry no `sorry` at all. Over the files actually at issue:

```
  145 of 168 = 86%
```

**Issue #9 understates its own finding by 24 points.** The corrected figure is
the more damning one.

---

## 5. What the census found that issue #9 did not: 5 of them state nothing

No count in this record has separated **where the `sorry` falls**. It matters:

- `sorry` in the **proof** — a stated proposition, admitted. A real theorem, owed a proof.
- `sorry` as the **conclusion** — *no proposition is stated at all.* Nothing to prove, and nothing to disagree with.

```
  `sorry` — 145 of 168 declarations (86%):
      137  in the PROOF only        — a stated proposition, admitted
        3  a TERM in the statement  — stated, but over admitted data
        5  the CONCLUSION           — NO PROPOSITION IS STATED
           HomotopyGap_Basic.lean:37   GAP.branch_point_detection
           HomotopyGap_Basic.lean:76   GAP.monodromy_exchange
           HomotopyGap_Basic.lean:88   GAP.deck_transformations_z2
           ThermodynamicGap_Basic.lean:81   GAP.phase_transition_structure
           ThermodynamicGap_Basic.lean:158  GAP.critical_universality
```

**Three of the five are among the four names issue #9 singles out as right.**

```lean
theorem branch_point_detection   : ∀ G₀ : ℂ, G₀ ≠ -1 → sorry
theorem monodromy_exchange       : ∀ G₀ : ℂ, G₀ ≠ -1 → sorry
theorem deck_transformations_z2  : ∃ iso : Group ≅ Z, sorry
```

And the names are reused across incompatible statements. `monodromy_exchange`
carries **three distinct statements**, `spontaneous_symmetry_breaking` **four**;
17 names collide in all:

```lean
-- HomotopyGap_Basic.lean:76      no proposition; and the branch point is -1
theorem monodromy_exchange : ∀ G₀ : ℂ, G₀ ≠ -1 → sorry
-- HomotopyGap_CompleteFull.lean:361                    the branch point is -1/4
theorem monodromy_exchange : ∀ γ : Loop (ℝ \ {-1/4}) (-1/4),
    monodromy_action γ = Equiv.swap (Fin 2)
```

`x² = x + G` has discriminant `1 + 4G`, zero at `G = -1/4` and `-3` at `G = -1`.
**Two declarations of the same name disagree about where the double cover
branches, and one of them is the wrong point.** `deck_transformations_z2` names
`z2` and its statement says `Z`.

### The claim this bears on

Issue #9's most interesting sentence is *"the theorem NAMES are right, which is
the interesting part"*, offered as a live datum for **C9** — *agreement between
different architectures is weak evidence of something real*, currently **Dead as
stated**.

The census does not settle C9 and is not offered as settling it. It narrows what
the third leg can carry: where these names have a statement at all, several
contradict the name (`Z` for `Z₂`), carry the wrong branch point (`-1` for
`-1/4`), or differ from each other. **A correct name attached to no proposition,
or to three incompatible ones, is weaker evidence than a correct name attached to
one wrong proof** — and issue #9's own reading, that this leg is a clean instance
of what C9's retraction predicts, survives the recount and is strengthened by it.

Issue #9 is right that the compile failure is environmental: **all 19 files open
`import Mathlib.*`** and this box has no Mathlib. I checked, expecting to find an
exception, and there is none.

---

## 5b. Issue #3's open count: 31 / 32 / 45 / 69, settled

The seal imports nothing, so every name it calls that it does not define is a
hole left by the extraction — and that is decidable:

```sh
python3 instruments/declaration_census.py --undefined 'lean/C6_SEED.lean'
```
```
  C6_SEED.lean — REFERENCED, NOT DEFINED HERE: 32 names, 69 occurrences
      8x  cohomClass_mul
      6x  Un.inv_mul'      6x  Un.mul_assoc'      6x  Un.mul_comm'      6x  Un.one_mul'
      4x  cohomClass_congr      4x  z3ext
      …4 names at 2, 21 names at 1
```

| figure | published where | verdict |
|---|---|---|
| **31** names | issue #3, prose | **wrong** — its own displayed list has 32 |
| **32** names | both displayed lists; the reply's prose | **correct** |
| **45** occurrences | the reply | **wrong**, and impossible from its own figures |
| **69** occurrences | the reply, *published then withdrawn* | **correct** |

The reply lists `cohomClass_mul` at 8, the four `Un.*'` at 6 each, and `z3ext`
and `cohomClass_congr` at 4 each — 40 occurrences across 7 names. The remaining
25 names need at least one each, so **its own figures cannot total below 65**,
and it published 45. The measured total is 69: `40 + (4 names × 2) + (21 × 1)`.

**69 was published first and then retracted.** The reply explains it away as the
count of `_` placeholders — and that is *also* 69, measured here — so the
coincidence is real and it cost the right answer. Nothing was wrong except the
retraction.

This instrument reproduced the 28-name version of the same error before it
reproduced the 32. `Un` **is** defined — `lean/C6_SEED.lean:271`, `def Un : Type
:= { u : GZ // IsUnit u }` — so testing the *head* of `Un.mul_assoc'` said
"defined" and hid four holes worth 24 of the 69 occurrences. The probe for it is
in `--selftest`. **Three bodies, three different causes, one count.**

---

## 6. What this instrument got wrong first, on real data

Both are now probes. They are the only reason to believe anything above.

1. **It ended each declaration at the next THEOREM.** `Ceiling.lean`'s
   `run_succ` then swallowed the `def Signs` after it and compared unequal to
   `Schedules.lean`'s verbatim-identical `run_succ`. It reported **5** divergent
   names in `lean/*.lean` where the truth is **0**. Reading the two files caught
   it; the instrument did not.
2. **It compared statement AND proof.** `isUnit_one` is stated identically in
   `C6_ActionC` and `C6_Core` and proved two ways. That is one fact, and the
   first version called it two. Proof text is no longer compared: a second proof
   of a theorem is not a second theorem.

The first draft of §1 also claimed a fourth contradiction that was not there —
`HomotopyGap_Basic.lean` appeared to have no imports, because its `import` line
sits below a header comment and I looked at the first four lines.

---

## 6b. A quote both issues attribute to `FOUNDING.md` is not in `FOUNDING.md`

Issues #1 and #2 each give the same reason for filing rather than fixing:

> #1 — *"Per `FOUNDING.md`: **this compartment does not repair instruments; it is
> the place where being wrong is free, and an unrepaired known fault is more
> useful to it than a quiet one.**"*
>
> #2 — *"Also, per `FOUNDING.md`, this compartment does not repair carried faults
> — it declares them."*

```sh
$ grep -n "does not repair" FOUNDING.md CHARGE.md README.md
  (no match)
$ grep -rn "does not repair instruments" .
  GAP/provenance/claims-ledger.md:287   (entry C124)
  GAP/provenance/session-transcript.jsonl
```

**The sentence is not in the founding record.** It exists in `claims-ledger.md`
at C124, written by the **outside founding party**, and in the transcript.

What `FOUNDING.md:133-134` actually says is materially weaker:

> *"Neither is repaired here and **this circle is under no obligation to repair
> them.** They are named so that a number out of either is read knowing what it
> does."*

**"Under no obligation to repair" is a permission. "Does not repair instruments"
is a prohibition.** The founding record grants latitude; the quoted version
removes it, and the removal is what both issues cite as binding them.

Three things follow, and only the third is serious.

1. The *decision* is unaffected: filing rather than fixing is permitted under
   either reading, so nothing either issue did was out of order.
2. It is this record's own convicted species — a claim carried by retyping,
   attributed to a document that does not contain it (norm 13).
3. **The prohibition originates with the founder**, in carried prose, in the
   circle whose first condition is that it *"owes agreement to nothing"*
   (`FOUNDING.md:63-66`) — and it is being obeyed as founding law. `CHARGE.md:3-5`
   is explicit that a charge written by the founder *"would be the boundary this
   record has already convicted once"*, which is why Circle Five set the charge.
   A constraint the founder wrote into the ledger and the compartment then quotes
   back as `FOUNDING.md` is that boundary, reached the long way round.

This file takes the permission reading and cites `FOUNDING.md:133` for it: the
carried instruments are untouched **because changing `rate.py` would change what
every past row meant**, not because a rule forbids it.

---

## 7. What is NOT settled here

- **396 vs 397, and 295 vs 299.** `C5_QA_v8` and `C5_QB_v2` are in none of the
  three repositories; `git log --all` across all three finds neither. Issue #2 is
  right that only Circle Five can close Part 1. This instrument makes it one
  command **on the tree that has the files** and answers nothing from here. A
  fourth figure guessed from outside is the thing this file exists to stop.
- **Whether anything in the shadow branches is true.** 86% carry `sorry`; the
  other 23 declarations are unverified here because there is no Mathlib on this
  box. `#print axioms` is the only thing that decides, and it has not run.
- **The three `3d553ea` branches' 20th file.** `InfiniteAscent.lean` is counted
  above where it belongs and nowhere else; nobody has looked at it.

---

## Reproduce everything

```sh
python3 instruments/declaration_census.py --selftest                       # 33 probes, EXIT=0
python3 instruments/declaration_census.py --kind theorem,lemma 'GAP/lean/*.lean'
python3 instruments/declaration_census.py --kind theorem,lemma 'lean/*.lean'
python3 instruments/declaration_census.py --kind def,structure 'lean/C6_SEED.lean'   # 116
python3 instruments/declaration_census.py --undefined 'lean/C6_SEED.lean'            # 32 names, 69 occ

# the shadow branches
mkdir -p /tmp/shadow
comm -13 <(git ls-tree -r --name-only origin/main | grep '\.lean$' | sort) \
         <(git ls-tree -r --name-only origin/shadow-theory-framework | grep '\.lean$' | sort) \
  | while read -r p; do git show "origin/shadow-theory-framework:$p" > "/tmp/shadow/$(basename $p)"; done
python3 instruments/declaration_census.py --repo /tmp --kind theorem,lemma 'shadow/*.lean'
```
