"""Stranger2 replication: main experiment runner.

600 trials: k in {0..5}, n=100 per k, budget 250,000 steps each.
Master seed 20240804; per-trial seeds derived deterministically.
Outputs results.csv with the protocol-required columns.
"""

import csv
import sys
import time
from langton import run_trial, SplitMix64, sample_perturbation, trial_seed

MASTER_SEED = 20240804
N_TRIALS = 100
KS = (0, 1, 2, 3, 4, 5)
BUDGET = 250000


def fmt_locs(locs):
    return ";".join(f"({r},{c})" for r, c in locs)


def main(outfile="results.csv"):
    t_start = time.time()
    rows = []
    trial_id = 0
    for k in KS:
        det_count = 0
        for i in range(N_TRIALS):
            s = trial_seed(MASTER_SEED, k, i)
            locs = sample_perturbation(SplitMix64(s), k) if k > 0 else []
            res = run_trial(set(locs), budget=BUDGET)
            rows.append({
                "trial_id": trial_id,
                "k": k,
                "onset_step": res["onset_step"] if res["detected"] else "",
                "detected": res["detected"],
                "period": res["period"] if res["detected"] else "",
                "verification_success": res["verification_success"],
                "perturbation_locations": fmt_locs(locs),
            })
            det_count += res["detected"]
            trial_id += 1
        print(f"k={k}: {det_count}/{N_TRIALS} detected "
              f"({time.time()-t_start:.0f}s elapsed)", flush=True)

    with open(outfile, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=[
            "trial_id", "k", "onset_step", "detected", "period",
            "verification_success", "perturbation_locations"])
        w.writeheader()
        w.writerows(rows)
    print(f"Wrote {len(rows)} rows to {outfile} "
          f"in {time.time()-t_start:.0f}s total")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "results.csv")
