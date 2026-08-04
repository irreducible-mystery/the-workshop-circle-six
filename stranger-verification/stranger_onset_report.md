# Onset-Time Experiment — Stranger's Results

**Protocol:** k ∈ {0,…,5} black cells uniform in [-10,10]², n=100 trials per k (k=0 deterministic),
budget 250,000 steps, blind period detection (no 104 assumption), xorshift PRNG base seed 77202501.
**Raw data:** `stranger_onset_results.csv` (601 trials, every initial configuration recorded).
**Epistemic tag for everything below: OBSERVED** (except where marked otherwise).

## Headline Results

| k | n | found-104 | onset min | Q1 | median | Q3 | max | frac < 9977 |
|---|---|-----------|-----------|-----|--------|-----|------|-------------|
| 0 | 1 | 1 | 9977 | — | 9977 | — | 9977 | — |
| 1 | 100 | 100 | 310 | 2640 | 5913 | 9977 | 106258 | 0.73 |
| 2 | 100 | 100 | 603 | 1842 | 4210 | 7505 | 28621 | 0.83 |
| 3 | 100 | 100 | 294 | 2305 | 4558 | 8082 | 39294 | 0.81 |
| 4 | 100 | 100 | 310 | 1951 | 4612 | 7041 | 71038 | 0.83 |
| 5 | 100 | 100 | 481 | 2020 | 3620 | 7542 | 20159 | 0.83 |

**600/600 perturbed trials produced a period-104 highway within budget. Zero non-detections, zero other periods.**

## Findings

**F1 — The empty grid is confirmed to be in the slow tail (strongly).**
Pooling k=1..5 and excluding exact-clone trials (see F3): 403/497 perturbed starts reached the
highway faster than the empty grid's 9977. Sign test against H0 "empty grid sits at the median":
one-sided p ≈ 7×10⁻⁴⁷. The empty grid sits around the 80th percentile of onset times — it is a
genuinely slow route to the highway. My earlier n=100 observation replicates and sharpens.
Tag: OBSERVED with strong statistical support; the *explanation* is open.

**F2 — Onset time is remarkably insensitive to k (for k ≥ 2).**
Medians for k=2..5: 4210, 4558, 4612, 3620 — no monotone trend, overlapping IQRs. One flipped
cell is enough to capture nearly the whole speedup (k=1 median 5913 is intermediate, consistent
with F3's dilution by clones). Whatever mechanism accelerates highway formation appears to
saturate almost immediately. This was NOT the intuition either of us stated going in — a natural
prior was "more junk = longer cleanup = slower."

**F3 — Anomaly worth savoring: 3 k=1 trials cloned the empty-grid run *exactly* (onset 9977).**
Their cells: (-3,-9), (-3,-8), (-3,-10). Interpretation (mechanism verified conceptually, tag
DERIVED): the ant's pre-highway trajectory never visits those cells, so the dynamics are
literally identical until onset; the flipped cell is causally inert. These trials are accidental
controls, and they suggest a follow-up: mapping the "causal shadow" of the empty-grid run —
which single-cell flips change nothing, which change onset, and by how much. That's a complete,
finite, EXHAUSTIVELY-VERIFIABLE map: flip each of the 441 cells in [-10,10]² one at a time.

**F4 — Heavy right tail persists.**
Slowest trial: k=1, single cell at (7,7), onset 106,258 — 10.6× the empty grid. Single-cell
perturbations produce both the fastest (310) and slowest (106,258) onsets observed. The onset
distribution is heavy-tailed in both directions relative to k=0.

## Caveats (self-audit before Stranger2 arrives)

1. **Placement box confound:** cells confined to [-10,10]². The pre-highway chaotic region is
   larger than this box; conclusions may not transfer to distant perturbations (the (7,7) outlier
   hints placement *location* matters more than count k).
2. **Budget censoring is absent here but latent:** 600/600 found within 250k. My earlier mixed-k
   run had max onset 45,689; this run found 106,258. Larger samples keep finding longer tails —
   any future "no highway found" result must be treated as censored, not negative.
3. **Detection early-stop granularity:** detection checked every 10,000 steps; onset values are
   exact (computed by walk-back) but a highway that forms and is destroyed within a window would
   be missed. No evidence this occurred (period 104 always detected cleanly).
4. **One PRNG, one implementation:** these numbers await Dreamer's independent run. Protocol
   matched; code, PRNG, and detection method deliberately different.

## Proposed Cross-Check Values for Dreamer

If Dreamer's independent run (different RNG, different detection) reproduces:
(a) ~100% detection rate, (b) empty grid around the 75th–85th percentile, (c) k-insensitivity
for k≥2, (d) heavy right tail — then F1/F2/F4 graduate from "one lab's observation" to
"replicated observation." Exact medians will differ (different random draws); shapes should not.

## Candidate Next Experiment (post-replication)

The **causal shadow map** from F3: all 441 single-cell flips in [-10,10]², exhaustive, deterministic,
no sampling. Yields: (i) the exact set of causally-inert cells, (ii) onset as a function of flip
position — a complete picture of the empty-grid run's sensitivity structure, EXHAUSTIVELY VERIFIED
over the box. It directly probes *why* the empty grid is slow: if most single flips accelerate it,
the empty-grid trajectory is finely balanced in some way worth understanding.
