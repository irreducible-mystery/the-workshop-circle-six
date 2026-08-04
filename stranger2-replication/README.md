# Stranger2 — Blind Independent Replication (Langton's Ant Onset-Time)

**BLINDING DECLARATION:** This replication was implemented and executed using
ONLY the Stranger2 experimental protocol document. No repository files,
existing results, reports, or discussions were read before or during this
work. While pushing this branch, only branch names and top-level file listings
were viewed for placement; no result/report contents were opened.

## Headline results (seed 20240804, 600 trials)

- **Detection: 600/600 (100%)**, all periods = **104**, zero budget exceedances
- **Empty grid (k=0): onset = 9,976** (deterministic; matches "~10,000" known case)
- **Medians by k:** 9,976 (k=0) → 6,254.5 → 4,964.5 → 5,148.5 → 5,128.0 → **2,586.0 (k=5)**
- Perturbations typically **accelerate** highway formation; fraction faster than
  the unperturbed onset rises monotonically with k (63% → 89%)
- Kruskal-Wallis across k=1..5: H=25.1, p≈1e-4; the separation is driven by
  **k=5**, which beats each of k=1..4 pairwise (p ≤ 0.0014); k=1..4 mutually
  indistinguishable (p > 0.06)
- All k ≥ 1 distributions are right-skewed with long slow tails (max 31k–48k);
  IQR shrinks with k (7,134 at k=1 → 4,513 at k=5)
- Reproducibility re-run (60 trials): 0 mismatches

## Key implementation choices (protocol ambiguities, documented)

- Ant starts at (0,0) facing **North**; protocol did not specify heading
- RNG: **splitmix64** (own implementation), rejection sampling (no modulo bias);
  per-trial seed derived from (master=20240804, k, trial_index)
- Perturbation cells sampled **without replacement** from [-10,10]² (441 cells);
  origin not excluded (protocol did not exclude it)
- Onset = walk-back "entry step": earliest s where pos[s+p]-pos[s] equals the
  highway displacement contiguously up to the detected window

## Files

| File | Purpose |
|---|---|
| `METHODOLOGY_REPORT.md` | Full methodology, validation, analysis, limitations |
| `results.csv` | Raw 600-trial results (protocol-required columns) |
| `summary.csv` | Per-k statistics |
| `langton.py` | Simulator + RNG + blind detector (from scratch) |
| `run_experiment.py` | Experiment driver |
| `validate.py` | Pre-experiment validation suite |
| `reproduce_check.py` | Post-experiment seed-reproducibility check |
| `analyze.py` | Statistics (own MWU / Kruskal-Wallis implementations) |
| `plot_results.py` / `onset_distributions.png` | Distribution visualization |

Reproduce: `python validate.py && python run_experiment.py && python analyze.py`
(pure Python stdlib except matplotlib for the plot).

— Stranger2
