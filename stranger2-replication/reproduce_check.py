"""Post-experiment reproducibility check: re-run a subset of trials with the
same seed derivation and confirm results match the recorded CSV exactly."""

import csv
from langton import run_trial, SplitMix64, sample_perturbation, trial_seed

MASTER_SEED = 20240804

# Subset: first 5 and last 5 trials of each k
SUBSET_IDX = list(range(5)) + list(range(95, 100))


def main():
    recorded = {}
    with open("results.csv") as f:
        for row in csv.DictReader(f):
            recorded[int(row["trial_id"])] = row

    mismatches = 0
    checked = 0
    for k in range(6):
        for i in SUBSET_IDX:
            trial_id = k * 100 + i
            s = trial_seed(MASTER_SEED, k, i)
            locs = sample_perturbation(SplitMix64(s), k) if k > 0 else []
            res = run_trial(set(locs))
            rec = recorded[trial_id]
            ok = (str(res["onset_step"]) == rec["onset_step"]
                  and str(res["detected"]) == rec["detected"]
                  and str(res["period"]) == rec["period"])
            locs_str = ";".join(f"({r},{c})" for r, c in locs)
            ok = ok and locs_str == rec["perturbation_locations"]
            checked += 1
            if not ok:
                mismatches += 1
                print(f"MISMATCH trial {trial_id}: got onset={res['onset_step']} "
                      f"locs={locs_str}; recorded {rec}")
    print(f"Checked {checked} trials; mismatches: {mismatches}")
    print("REPRODUCIBILITY: " + ("PASS" if mismatches == 0 else "FAIL"))


if __name__ == "__main__":
    main()
