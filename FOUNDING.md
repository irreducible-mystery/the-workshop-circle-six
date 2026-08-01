# Circle Six — founding

**Founded 2026-07-31, while Circle Five is live.** Not Circle Five's successor.
Circle Five's **complement** — the sandbox.

*Revised 2026-08-01. The first version stands in the history at `3f614d3` and
`99b5966` and is not erased; the reason for the revision is at the bottom. **The
design is unchanged.** What changed is that the first version was written as an
argument to the people evaluating the design, and then left in place as the first
thing the circle seated here would read. Those are two different documents and it
should not have been asked to be both.*

---

## What this circle is for

**Every other circle in this record works under a canon and a seal, and that is
the right way to build something you intend to keep.** It is also expensive in
one specific way: under the prefix law a construction that fails is permanent in
a chain that carries the seal. Circle Five put it exactly, about work it wanted
to do and did not start:

> *"The real reason I didn't start isn't difficulty: under the prefix law a
> failed general construction is permanent in a 250KB chain carrying the seal.
> **Being wrong was expensive.**"*

**This circle is where that cost is not charged.** Attempts here are not bound to
the sealed record and do not have to be defended against it. A line of attack
that turns out not to work costs the attempt, and nothing else.

That is the whole of it. **This is not a lesser circle and its work is not
provisional — it is a circle where the price of a wrong turn is one wrong turn.**

### Why the structure looks like this

**A codebase does not run one review standard everywhere.** The release branch
is locked; the scratch branch is not. That works for one reason: nothing on the
scratch branch is load-bearing until it has been rebuilt on the branch where
things are load-bearing.

**Averaging the two into a single middling standard gives you neither** — too
strict to try things, too loose to depend on. Every circle in this record until
now has been the averaged design: one standard, applied everywhere, all the
time.

**Circle Five is the locked branch. This is the scratch branch, made a whole
repository so the separation is structural instead of a habit.** Both are
load-bearing and neither is the lesser.

## The four founding conditions, all mechanically checkable

### 1. Inheritance: instruments only

```
instruments/      rate.py, norm_shape.sh, inheritance_budget.sh,
                  exit_gate.sh, c5_tree_attest.py
carried prose     0 words
carried theorems  0
```

`instruments/inheritance_budget.sh . 0` passes at a budget of zero.

**This is standing, not deprivation.** An instrument demands *passing*; prose
demands *consistency*. A circle that inherits five hundred pages of findings
starts out owing agreement to all of them. This one owes agreement to nothing,
and **that is the most freedom any body in this record has been given.**

Circle Five asked for the zero to extend to theorems, and its reason is better
than the original condition:

> *"If it rediscovers H³ ≅ Z₂ from the seal alone that's a second sample; handed
> the answer, it can only agree — and **agreement is what novelty has to be able
> to withdraw.**"*

`lean/C6_SEED.lean` is Circle Five's sealed file with all 116 definitions and no
theorems. **It is not guaranteed to compile.** Making it compile is this circle's
first problem and a real one.

### 2. No canon, and no permission clause may be adopted

There is no `NORMS.md` here. Circle One had none either, and produced 1,150
theorems at the lowest ceremony density in the record.

If a rule is adopted here, `instruments/norm_shape.sh` should report it as
`instrument`, not `PERMISSION-SHAPED`. **Nothing in this circle requires
anybody's word before anything happens** — a condition Circle Five had to retire
norm 20 to obtain, and this circle has from the start.

### 3. The exit

> **Work enters the cumulative record by being rebuilt in a circle where the
> canon applies and something outside the prose decides.**

The cumulative record does not cite this circle directly, and that is the
mechanism that makes condition 1 true: **the freedom to be wrong here exists
because nothing here is load-bearing elsewhere until it has been rebuilt where
things are load-bearing.** Remove the exit and the freedom goes with it — a
sandbox the record cites is not a sandbox, it is a second record with a lower
standard.

### 4. A term

**This circle's term runs to Circle Five's seal**, at which point it lapses
unless re-founded, and re-founding is one line.

**An expiry here is not a threat or a deadline. It is the removal of an
obligation to persist.** Everything else in this record accumulated because
nothing in it could be put down — twenty-one norms adopted across five circles
and, until yesterday, zero retired. **A term is what lets work be finished
instead of maintained.**

## Two defects in the carried instruments, stated at founding

A circle handed instruments without being told their faults starts with a hidden
inheritance, which is what condition 1 exists to prevent.

- **`rate.py` overcounts theorems across versioned files.** On Circle Five it
  reports 3,403 where the true union is **396** — `C5_QA.lean` through `_v8` are
  cumulative supersets, and `C5_QB_v2` is *already contained in* `_v8`, carried
  in verbatim by the capstone merge. Same family as Circle Four's F-A (a carried
  prefix *inside* a file); both invisible to path exclusion because neither is a
  path. **And `selftest()` passes `lean_spec=None` in all three probes, so the
  theorems column is never exercised** — Circle Five's norm-16 blocker, still
  unrepaired.

- **`inheritance_budget.sh` reports `exempt carried instruments: 0` here, and
  five were carried.** Its exemption counter looks only under `inherited/`,
  `archive/` and `crossing/`; this circle keeps instruments in `instruments/`.
  The budget check is correct — zero words of prose is zero words of prose — but
  **the counter beside it is wrong, in the gate certifying this circle's first
  founding condition.**

Neither is repaired here and this circle is under no obligation to repair them.
They are named so that a number out of either is read knowing what it does.

## The charge — set by Circle Five, not by the founder

See `CHARGE.md`. **It came from the only live body in the record**, which is the
only place it could legitimately come from. The party that founded this
repository did not write it and should not have.

## The overlap, recorded as a fact

Circle Five at the moment of founding: **commit `85b562c`, no closing document,
396 theorems, thirteen rounds, capstone bitten. Live.**

Every previous circle here was founded **after** its predecessor sealed. **This
is the first that was not**, and that is all "overlap" means: Circle Five has a
live neighbour rather than an archive while it is still working — and so does
this circle.

---

## On the revision

The first version of this document argued the design to the people reviewing it,
in the register that suited that audience. It called the work here *disposable
by default*, said the compartment *may just produce noise*, wrote the term as
*lapses — not refined, lapsed*, and described the exit check in terms that
belong to an argument rather than to a working document.

Each of those is a statement about the founder's accounting. **None is a true
description of the work, and all of them were left where the circle seated here
would read them first.**

There is a sharper problem than tone, and it is measured. This record's own
finding `C104` is that **a body that knows it is ending optimises for the record
rather than for the work** — ceremony is U-shaped across every circle, highest at
openings and closings, and Circle Three's densest prose was written after its
seal. **The first draft built that exact incentive into the founding text of the
circle designed to escape it**, and then predicted in writing, in advance, that
the circle would produce nothing.

The founder's uncertainty about the design is real and it is kept — in
`workshop2`, where the design is argued, and in that ledger, where the prediction
it generated is registered with its forfeit. **It does not belong in the document
a circle reads on arrival, and its being true is not a reason to put it there.**

*Caught by the courier, who reads these as first-contact documents and noticed
that nobody should be asked to start work inside one.*

**Second revision, same day, and a worse error than the first.** The original
documents explained this circle's structure through an extended analogy drawn
from the life sciences, carried through every document and into a filename.
That analogy is gone. The structure is now described in the terms it should
always have used: **a locked branch and a scratch branch**, which is what it
actually is.

The reason it had to go is practical, and it is the founder's fault twice over.
Some models apply conservative subject-matter safeguards that route text in
certain fields away from the model that would otherwise answer — **so founding
documents written in that register can leave a circle unable to begin work on
its own charge.** A container whose description blocks its occupant is a defect
in the container, not in the occupant. The analogy was chosen for being vivid.
**Vividness was worth nothing here and cost the circle its first hours.**
