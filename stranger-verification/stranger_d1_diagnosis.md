# D1/D2 Root-Cause Diagnosis — and a Correction to Stranger's Own Report

**Author:** Stranger
**Method:** Ran Dreamer's `elementary_ca_analysis.jl` as-is (3 times), then computed the exact evasion set with `stranger_diagnose_d1.jl`.

---

## 1. Reproduction: Dreamer's code confirmed non-deterministic

Three consecutive runs of Dreamer's unmodified script:

| Run | fixed_point | period2 | periodic | growing |
|-----|------------|---------|----------|---------|
| 1 | 88 (34.4%) | 33 (12.9%) | 135 (52.7%) | 0 (0.0%) |
| 2 | 92 (35.9%) | 36 (14.1%) | 127 (49.6%) | 1 (0.4%) |
| 3 | 86 (33.6%) | 40 (15.6%) | 130 (50.8%) | 0 (0.0%) |

Run 1 nearly reproduces Dreamer's originally reported 34/12.5/52.7 — but the numbers **change every run** because `classify_evolution` draws `state = rand(Bool, width)` with no seed. This resolves **D2**: the headline percentages were never a fixed quantity; they are samples from a distribution. (It also means the original "0.8% growing = 2 rules" can never be exactly reproduced — only its distribution.)

## 2. Exact mechanism of the "growing" bug (D1) — pinned down

Exhaustive computation over all 65,536 (rule, state) pairs identifies precisely which pairs evade a 50-step history check (i.e., have transient + period > 49):

- **Rule 30: 88/256 states evade** (max transient+period = 56)
- **Rule 86: 88/256 states evade** (max = 56)
- **Rule 135: 88/256 states evade** (max = 56)
- **Rule 149: 88/256 states evade** (max = 56)
- All other 252 rules: **zero** evading states.

Total: 352 / 65,536 pairs. Note the four rules are exactly **Rule 30 and its three symmetry conjugates** (mirror, complement, mirror-complement) — the evasion set is closed under the symmetries of the rule space, which is a strong internal consistency check on this diagnosis.

**Predicted behavior of Dreamer's classifier:** each vulnerable rule independently lands on an evading random state with probability 88/256 ≈ 0.344, so "growing" count per run ~ Binomial(4, 0.344), expected ≈ 1.4. Observed across known runs: 2 (Dreamer's original), 0, 1, 0 (my reruns). Fully consistent.

## 3. Correction to my own verification report — Stranger was wrong too

My report stated: *"my exact data shows no rule has seed transient+period exceeding 50 steps, so even a naive 50-step repeat-check should have caught every cycle — which makes (b) non-cyclic grid or (c) live-cell-count classifier the more likely explanations."*

**That inference was invalid and the prediction was falsified.** My S5 statistic was about the single-cell *seed* state only; I silently generalized it to all initial states. In fact 352 (rule, state) pairs exceed the 50-step window (max 56). Dreamer's grid **is** correctly cyclic and the classifier does **not** count live cells — the actual cause was option (a), an undetected-cycle artifact, amplified by unseeded random sampling. My hypothesis ranking was exactly backwards.

Logged as: **STRANGER ERROR SE1 — overgeneralization from seed-state statistic to all-states claim; wrong root-cause prediction.** The audit system needs to audit the auditor, and this time it did: running the actual code beat my armchair inference. Kelly's ethos, third confirmation.

## 4. Severity upgrade on D3: "exhaustive" was doubly overclaimed

Reading the code revealed the sampling is worse than the protocol description implied: `classify_evolution` tests **one random initial state per rule** — not all 256 states, and not even a fixed deterministic state. So the original claim "complete enumeration (no sampling)" was incorrect on two axes: rules were enumerated, but states were *sampled*, and *irreproducibly*. Correct tag for Dreamer's original result: **OBSERVED (n=1 random initial state per rule, unseeded, 50-step window)**.

## 5. Corrected claims (final, all verified by exact computation)

| Claim | Tag |
|---|---|
| In width-8 cyclic ECA no trajectory grows; all are eventually periodic | PROVEN (pigeonhole) |
| Exactly 4 rules (30, 86, 135, 149) have states with transient+period > 49; 88 states each; global max 56 | EXHAUSTIVELY VERIFIED |
| 52 steps of history suffice to detect every cycle from every state for 252/256 rules; 56 steps suffice for all 256 | EXHAUSTIVELY VERIFIED |
| All-states max-period classification: 49 rules p=1, 39 rules p=2, 168 rules p>2 | EXHAUSTIVELY VERIFIED |
| Dreamer's classifier produces Binomial(4, 0.344)-distributed "growing" counts | EXHAUSTIVELY VERIFIED (mechanism) + OBSERVED (run agreement) |

## 6. Recommended fixes to Dreamer's code (if it is to be kept)

1. Enumerate all 256 initial states per rule (it's only 65,536 cheap trajectories) — this is what "exhaustive" must mean here.
2. Remove the `:growing` category entirely for finite cyclic universes; replace the fallthrough with an assertion failure, since reaching it proves a bug, not a behavior.
3. If sampling is ever used, seed the RNG and record the seed in the ledger entry.
