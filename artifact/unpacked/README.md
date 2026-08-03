# circle-six-gap-proof

A self-contained, kernel-checkable artifact. Two Lean files, no Mathlib, **no
imports at all**, and a script that verifies every claim in one command.

    sh verify.sh ; echo "EXIT=$?"

Exit 0 is the whole contract. Read the exit code, not the prose.

## Toolchain

Lean **4.22.0**. Nothing else. No Mathlib, no lakefile, no project. The files
import nothing, which is why a bare core toolchain is the entire dependency.

    curl -sSL -o lean.tar.zst \
      https://github.com/leanprover/lean4/releases/download/v4.22.0/lean-4.22.0-linux.tar.zst
    zstd -d lean.tar.zst -o lean.tar && tar -xf lean.tar
    export PATH=$PWD/lean-4.22.0-linux/bin:$PATH

`verify.sh` prints these instructions if it cannot find `lean`.

Expect **~7 minutes**. `C6_Twist.lean` takes ~85s to compile and is compiled
three times (once directly, twice more with the `#print axioms` block appended).

## What is in here

| file | what it is |
|---|---|
| `01-BUILD-STACK.md` | the mathematics, prose-free. Generated from the source; `verify.sh` fails if it has drifted. |
| `02-EXPLAINED.md` | the same content, with the reasoning |
| `03-NOTES.md` | prose, judgement, open questions — nothing load-bearing |
| `NOT-PROVED.md` | **read this.** What the artifact does not establish. |
| `lean/C6_Twist.lean` | 49 theorems |
| `lean/C6_Gap.lean` | 17 theorems |
| `audit/` | `verify.sh` writes `AUDIT.txt` here. Generated output, deliberately **not** in the manifest. |
| `compute/*.py` | computed, **not** kernel-decided. Stdlib only. |
| `regen-build-stack.py` | the generator, so drift is detectable |
| `MANIFEST.sha256` | checksums |

## What `verify.sh` checks

1. A kernel is present **and honest** — it must accept `2+2=4` *and reject*
   `2+2=5`. A check that only accepts truths certifies an echo.
2. Both Lean files compile.
3. **Every declaration** — theorems, defs, instances alike — carried through
   `#print axioms`, and every one depends on **no axiom at all**.
4. `01-BUILD-STACK.md` still matches the source it was generated from.
5. The `compute/` scripts run.
6. Checksums match.

## The one decision point that is not an axiom

Every `decide` routes through two hand-written `Decidable` instances. They
cannot lie: `isTrue` demands a proof term the kernel typechecks, and the only way
to fake one is `sorry` or an axiom — both reported as zero by check 3. This is
demonstrated rather than asserted; see `03-NOTES.md`.

`native_decide` is deliberately absent throughout. It trusts the compiler rather
than the kernel, and a verdict spent on a faster oracle is not a verdict.

## Provenance

Produced in the germinal compartment of `irreducible-mystery/the-workshop-circle-six`,
branch `claude/circle-six-prover-review-ylt4ua`. Under that compartment's rules
**nothing here is a finding** until it is rewritten where a canon applies. This
artifact is the mathematics; it is not a claim on the record.
