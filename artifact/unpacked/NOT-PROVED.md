# NOT PROVED

Read this before quoting anything from this artifact.

## 1. The 65536-symbol sweep is NOT kernel-decided

These numbers appear in the surrounding literature and are **compiler-checked
only** (`#eval`), never verified by the kernel:

    |Z3| = 32  (untwisted)      |Z3| = 64  (conjugation-twisted)
    shared    = 8
    pentagon <-> untwisted-cocycle, as a set identity over all 4^8 symbols

Two kernel runs at the full sweep size were killed by a container restart about
three minutes into a ten-minute job. **No theorem in `lean/` depends on any of
them.** They are not in the build stack.

The engineering note, because it cost hours: the obvious unary recursion
`countUpTo p (n+1)` **aborts the kernel (SIGABRT, exit 134) at 16384**. That is
the kernel's *stack*, not its heartbeat. `set_option maxHeartbeats` does not
affect it and never will. The fix is a logarithmic-depth recursion shape:

    sweep (d+1) lo = add (sweep d lo) (sweep d (lo + 2^d))

Depth 16 instead of 65536. Depth 12 kernel-decides in ~37s.

## 2. The counterfactual complex

There is **no** conjugation-twisted `d2`/`d3` in the sealed source this work
studies. It was *constructed* here, by attaching the action to the leading face,
which is where the standard inhomogeneous complex puts it. That is justified by
convention, not by the source.

Mitigations, all in the artifact: the constructed operator is checked to *be* a
complex; the counts are invariant across both natural face placements; and the
general theorem (`twist_invisible_on_fixed`) holds for **any** map `σ`, so it
does not depend on the choice.

Every twisted statement is a statement about a counterfactual complex. It must
travel with that label.

## 3. Unnormalised cochains

All counts are over the full cochain space with no normalisation condition —
the source's own convention. Normalised, the same results read differently. The
word "unnormalised" travels with every count.

## 4. What `compute/` establishes

Nothing, in the kernel's sense. The p-adic results, the root-proliferation
counts, the unit-group sweep and the pinch landscape are exhaustive over finite
ranges and correct as computations, but they are Python. They are *evidence and
specification*, not proof. The pinch itself IS kernel-decided, with explicit
witnesses; its surrounding landscape is not.

## 5. What a green exit code means

`verify.sh` exiting 0 means: the kernel accepted every proof, and no proof rests
on any axiom. It does **not** mean the theorems say what their names suggest.
That is what `01-BUILD-STACK.md` is for — it prints the statements, extracted
from the source, so a reader can check the names against the content.

One guard against the worst version of this is inside the proofs themselves:
`pentagon_iff_seal` proves that the object being swept **is** the source's own
pentagon, guard and integer label arithmetic included. Without it a green would
certify a statement about a model rather than about the thing.
