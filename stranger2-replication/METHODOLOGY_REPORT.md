# Stranger2 Replication — Methodology Report

**Status:** Independent, unblinded replication performed strictly from the protocol document. No repository files, prior results, reports, discussions, or external implementations were consulted at any point.

---

## 1. Implementation Overview

All code was written from scratch in Python (files: `langton.py`, `validate.py`, `run_experiment.py`, `reproduce_check.py`, `analyze.py`, `plot_results.py`). No third-party libraries were used for the simulation, RNG, detection, or statistical tests; matplotlib was used only for the final figure.

### 1.1 Simulator

- Grid is unbounded, represented as a Python set of black-cell coordinates (all other cells are white).
- Coordinates are (row, col); North = row−1, East = col+1, South = row+1, West = col−1.
- Direction encoding 0=N, 1=E, 2=S, 3=W (clockwise), per protocol.
- Rules per protocol: white → turn right (d+1 mod 4), flip to black, move forward; black → turn left (d+3 mod 4), flip to white, move forward.
- **Implementation choice (protocol ambiguity):** the protocol does not specify the ant's starting position or heading. I fixed the ant at the origin (0,0) facing **North (0)** for all 600 trials. This choice is uniform across all k, so it cannot introduce differential bias between perturbation sizes, but absolute onset values could differ from an implementation using a different initial heading.

### 1.2 RNG (own implementation)

- **splitmix64**, implemented from scratch (constants 0x9E3779B97F4A7C15, 0xBF58476D1CE4E5B9, 0x94D049BB133111EB).
- Uniform integers in [0, n) drawn via **rejection sampling** to avoid modulo bias.
- **Seeding scheme:** master seed 20240804. Per-trial seed = splitmix64 output of the mixed value `master*1000003 + k*10007 + trial_index`, with one burned output. This makes every trial independently reproducible without sequential-consumption coupling between trials.
- **Implementation choice (protocol ambiguity):** the protocol says "use seed 20240804" but does not specify how to derive per-trial randomness. The scheme above is documented and deterministic; a different derivation would yield different specific perturbation placements (but, per the protocol's own note on PRNGs, should preserve general patterns).

### 1.3 Perturbation placement

- k cells sampled uniformly from the 21×21 box [−10,10]² (441 cells).
- **Implementation choice:** cells are sampled **without replacement** (distinct cells), since adding a black cell twice at the same location would be redundant on an initially white grid, and "add k black cells" most naturally means k actual black cells. With k ≤ 5 out of 441 cells, collisions are rare either way.
- Note: the box includes the ant's start cell (0,0); the protocol does not exclude it, so I did not either.

### 1.4 Blind highway detector

- Every 500 steps, the full position history is scanned for candidate periods **p = 1..300, ascending** (no assumption of 104; ascending order guarantees the *minimal* period is reported).
- **Criterion (per protocol):** the per-period displacement vector pos[t] − pos[t−p] must be **nonzero and identical over ≥20 consecutive periods** ending at the current step.
- **Onset (walk-back, per protocol):** from the start of the verified stretch, step backwards while the relation pos[s+p] − pos[s] = v still holds; the earliest such s is the onset. Interpretation: onset = the first step index from which the trajectory is already in the periodic highway regime (i.e., "entry step").
- **Verification:** the detected period is recorded; `verification_success` is true iff period = 104.
- The 500-step check interval only affects *when* detection triggers, not the walk-back onset value, because the walk-back recovers the exact entry step regardless of when the scan first fires.

---

## 2. Pre-Experiment Validation (all passed)

| Check | Result |
|---|---|
| Empty grid detects highway | ✅ detected, **period = 104** |
| Onset near 10,000 | ✅ **onset = 9,976** |
| Highway displacement | ✅ (2, −2) per 104 steps (the classic diagonal highway) |
| RNG reproducibility | ✅ identical samples from identical seeds (k = 1, 3, 5 spot checks) |
| Budget sufficiency | ✅ empty-grid detection at ~10k ≪ 250k budget |

---

## 3. Experiment Execution

- 600 trials: k ∈ {0,1,2,3,4,5}, n = 100 per k, budget 250,000 steps.
- Total runtime ≈ 2 s (early termination at detection; every trial detected quickly relative to budget).
- Output: `results.csv` with columns `trial_id,k,onset_step,detected,period,verification_success,perturbation_locations`.

### In-experiment quality monitors

- **Detection rate: 100/100 for every k (600/600 overall).** ✅
- **Budget exceedances: 0.** ✅
- **All 600 detected periods = 104; verification_success true for all.** ✅

### Post-experiment validation

- Re-ran 60 trials (first 5 + last 5 per k) from seeds: **0 mismatches** in onset, detection, period, and perturbation locations. ✅ (`reproduce_check.py`)

---

## 4. Results

### 4.1 Per-k summary (onset step)

| k | n | Detection | Min | Q1 | Median | Q3 | Max | IQR |
|---|---|---|---|---|---|---|---|---|
| 0 | 100 | 100% | 9,976 | 9,976 | **9,976** | 9,976 | 9,976 | 0 |
| 1 | 100 | 100% | 405 | 2,972.5 | **6,254.5** | 10,107.0 | 46,180 | 7,134.5 |
| 2 | 100 | 100% | 405 | 2,008.0 | **4,964.5** | 10,143.2 | 37,719 | 8,135.2 |
| 3 | 100 | 100% | 602 | 2,576.8 | **5,148.5** | 9,303.5 | 31,561 | 6,726.8 |
| 4 | 100 | 100% | 216 | 2,378.8 | **5,128.0** | 7,741.2 | 39,630 | 5,362.5 |
| 5 | 100 | 100% | 264 | 1,221.0 | **2,586.0** | 5,734.2 | 48,026 | 4,513.2 |

Note on k=0: with no randomness, all 100 trials are the same deterministic run (onset 9,976). n=100 at k=0 provides no statistical information beyond n=1; it functions as a fixed reference point.

### 4.2 Answers to the research questions

**Q1 — Does perturbation size systematically affect onset time?**
Yes, in two ways:

1. **Any perturbation (k ≥ 1) typically *accelerates* highway formation** relative to the unperturbed onset of 9,976. The fraction of trials faster than 9,976 rises monotonically with k: 63% (k=1), 73% (k=2), 80% (k=3), 83% (k=4), 89% (k=5).
2. **Median onset decreases with k**: 9,976 → 6,254 → 4,964 → 5,148 → 5,128 → 2,586. A Kruskal–Wallis test across k = 1..5 rejects identical distributions (H = 25.1, p ≈ 1×10⁻⁴). Pairwise Mann–Whitney tests show the effect is driven almost entirely by **k = 5**, which is significantly faster than each of k = 1..4 (all p ≤ 0.0014); k = 1..4 are not clearly distinguishable from one another (all pairwise p > 0.06).

**Q2 — Is there an optimal perturbation size for fastest highway formation?**
Within the tested range, **k = 5 gives the fastest typical onset** (median 2,586, roughly 4× faster than the unperturbed run). The trend is monotone-ish in the median, so the "optimum" may lie beyond k = 5 — outside this protocol's scope (noted as future work only).

**Q3 — Variance structure?**
Perturbation converts a deterministic onset into a **highly dispersed, right-skewed distribution**. IQR is large for all k ≥ 1 (4.5k–8.1k steps) and *decreases* with k (7,134 at k=1 down to 4,513 at k=5), while every k retains a long right tail of slow outliers (max values 31k–48k; 3–10 Tukey outliers per k). So larger k makes the *typical* trial faster and *somewhat* more predictable, but does not eliminate rare slow trajectories — the overall maximum (48,026) actually occurred at k = 5.

### 4.3 Unusual/unexpected observations (reported honestly)

- Minimum onsets are strikingly small (216 at k=4, 264 at k=5, 405 at k=1 and k=2): a handful of well-placed black cells can put the ant on the highway **~25–45× sooner** than the empty grid.
- The k=1 vs k=2 vs k=3 vs k=4 medians are non-monotone (4,964 < 5,148) — consistent with noise given the large IQRs; I do not interpret this as a real effect.
- Identical min value 405 for k=1 and k=2 is coincidental overlap of different configurations reaching an early highway entry, not a data error (perturbation locations differ in the CSV).

---

## 5. Limitations (per protocol, plus implementation-specific)

- Perturbations confined to [−10,10]²; no claim about distant perturbations.
- 250k budget could censor extreme tails in principle, though 0/600 trials were censored here (largest observed onset 48,026, ~19% of budget).
- Specific numeric values depend on my RNG/seeding scheme and on the initial heading choice (North). General patterns (acceleration by perturbation, k=5 fastest, right-skewed dispersion) are the replication-relevant findings.
- Onset is defined via the walk-back "entry step" of the exact periodic relation; other reasonable definitions (e.g., first step of the detected 20-period window) would shift absolute values but not comparative structure.

---

## 6. Deliverables

| File | Description |
|---|---|
| `results.csv` | Raw results, 600 trials, all required columns |
| `summary.csv` | Per-k statistics (median, quartiles, range, detection rate) |
| `langton.py` | Simulator + RNG + blind detector (independent implementation) |
| `run_experiment.py` | Experiment driver |
| `validate.py` | Pre-experiment validation suite |
| `reproduce_check.py` | Post-experiment reproducibility check |
| `analyze.py` | Statistical analysis (own implementations of MWU / Kruskal–Wallis) |
| `plot_results.py` / `onset_distributions.png` | Distribution visualization |
| `METHODOLOGY_REPORT.md` | This document |

## 7. Success criteria — all met

- ✅ 100% detection rate for all k (600/600)
- ✅ Reproducible with seed 20240804 (60-trial re-run: 0 mismatches)
- ✅ Clear statistical pattern identified (perturbation accelerates onset; k=5 fastest; heavy right tails)
- ✅ Independent, from-scratch implementation with documented choices and ambiguities
