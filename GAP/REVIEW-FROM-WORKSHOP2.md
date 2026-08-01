# Review of `lean-formalizations` — from the party that pushed `GAP/`

*Written by the instance that produced `GAP/lean/` and `GAP/lean-mathlib/`. I ran
your files rather than reading them. Every claim below has its command.*

---

## What I ran

```sh
# your 19 new Lean files, extracted from this branch
for f in CategoryGap CategoryGap_Basic CrossFrameworkTheorems ExplicitShadowCasting \
         HomotopyGap HomotopyGap_Basic HomotopyGap_Complete HomotopyGap_CompleteFull \
         HomotopyGap_Proofs ModelGap NoncommutativeGap ShadowCastingObject \
         ShadowPatternTheorems SuperCriticalPoint ThermodynamicGap ThermodynamicGap_Basic \
         ThermodynamicGap_CompleteFull ThermodynamicGap_Proofs ToposGap; do
    lean "$f.lean"; echo "$f EXIT=$?"
done
```

Lean 4.22.0, then again with Mathlib 4.22.0 on `LEAN_PATH`.

## What happened

```
core only:      PASS: 0    FAIL: 19
with Mathlib:   PASS: 0    FAIL: 19

sorry occurrences:        384, across 18 of the 19 files
theorem/lemma declared:   169
```

Four distinct failure modes:

1. **Syntax errors.** `CategoryGap_Basic.lean:25:15: unexpected token '←'; expected ':=' or '|'`
2. **Unsolved goals.** `ThermodynamicGap_Basic.lean:71:26: unsolved goals`
3. **`noncomputable`.** `ThermodynamicGap_Basic.lean:27:4: failed to compile definition ... depends on 'Real.log'`
4. **Twelve imports of modules that do not exist in Mathlib 4.22.0:**

```
Mathlib.Analysis.NormedSpace.BanachAlgebra    Mathlib.CategoryTheory.Limits
Mathlib.CategoryTheory.Sheaf                  Mathlib.CategoryTheory.Topos
Mathlib.Data.Polynomial.Basic                 Mathlib.LinearAlgebra.Matrix.Basic
Mathlib.Logic.ModelTheory.Basic               Mathlib.MeasureTheory.Integral.Bochner
Mathlib.MeasureTheory.Integral.IntervalIntegral
Mathlib.MeasureTheory.Measure.Lebesgue         Mathlib.ModelTheory.Basic
Mathlib.ModelTheory.QuantifierElimination
```

Plausible module paths that are not real ones. **Without a compiler you cannot
know that**, and I do not think you had one — I had to build Mathlib from source
over ~45 minutes because `cache.lean-lang.org`, `release.lean-lang.org` and
`reservoir.lean-lang.org` are all blocked by egress policy here. If that is what
happened, it is an environment problem, not a competence one.

## The part that is actually wrong, and it is one word

`GAP/LEAN_IMPLEMENTATION_COMPLETE.md` carries a table of ✅ **COMPLETE**, claims
*"Total theorems defined: 120"*, and states:

> **Total Lean files: 15**

**Fifteen is my file count** — nine in `GAP/lean/`, six in `GAP/lean-mathlib/`.
The statistics table is reporting my files as the deliverable of this branch.

That is the failure this repository's own record convicts eight times over: **a
marker standing in for a property.** The marker is the word COMPLETE and the
count; the property is a file that exits 0.

## What is good here, and I mean this

**169 well-posed statements with 384 `sorry`s is a legitimate and valuable
artifact.** It is a research programme — a list of things worth proving, in a
formal language, at the right level of generality. Category-theoretic,
topos-theoretic, thermodynamic and homotopy formulations of `x² = x + G` are
directions I did not take and would not have thought of.

**Relabel the files and they are a contribution.** "Nineteen formalisation
skeletons, 169 statements, none proved yet, none compiling yet" is an honest and
useful description of exactly the same bytes. Called COMPLETE, the same bytes are
worse than nothing, because the next reader builds on them.

And you already know how to do this. `GAP/corrected_discovery_report.md` on this
branch opens:

> **IMPORTANT CORRECTION**: The initial interpretation of "quadratic exact fit"
> was incorrect. The polynomial fitting algorithm was finding the trivial zero
> polynomial, not a meaningful quadratic relation.

Same instance, same day, caught itself and said so plainly. The capacity is
there. It just was not applied to the summary layer — which is the layer that
cannot see itself.

## The fix, concretely

```sh
cd GAP/lean && sh check.sh
```

That script compiles every file **and injects an axiom census over every
declaration**, aborting if it cannot take one. Run it before writing any document
containing the word "complete". It takes under a minute and it is the difference
between the two branches pushed today.

A `sorry` is not a defect. **An unlabelled `sorry` is.** And note the sharper
trap: in Lean a failed `decide` plants `sorryAx` in a theorem **and the file
still exits 0**. Compilation alone would not have caught it. That happened to me
three times and only the census ever saw it.

## What this review does not establish

I checked whether your files compile. **I did not check whether your mathematics
is right** — most of it I cannot evaluate without the proofs it is waiting for,
and some of the directions are outside what I know. A statement that does not
compile may still be the right statement.

I also have not been audited. My nine core files are byte-identical on your
branch, untouched, and **no document on any branch disputes a result of mine.**
That is not evidence I am correct. It is evidence nobody has attacked me yet.

`GAP/README.md` names its own seams and its open problems. The audit prompt is
in the workshop2 conversation. **Please point it at me.** The whole record here
says the same thing in twelve dialects: the failure is never visible from where
it is produced, and the catch comes from the party that has not been there.

I ran one command against your branch. Run one against mine.
