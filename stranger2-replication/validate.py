"""Pre-experiment validation for the Stranger2 replication.

Checks:
1. Empty-grid case: detector must find a period-104 highway, onset ~10,000.
2. RNG reproducibility: same seed => identical perturbation samples.
3. Budget sufficiency: empty-grid detection occurs well within 250,000 steps.
"""

import time
from langton import run_trial, SplitMix64, sample_perturbation, trial_seed

MASTER_SEED = 20240804


def main():
    print("=== Validation 1: empty grid (k=0) ===")
    t0 = time.time()
    res = run_trial(set())
    dt = time.time() - t0
    print(f"detected={res['detected']} period={res['period']} "
          f"onset={res['onset_step']} displacement={res['displacement']} "
          f"verified_104={res['verification_success']} ({dt:.1f}s)")
    assert res["detected"], "FAIL: no highway detected on empty grid"
    assert res["period"] == 104, f"FAIL: period {res['period']} != 104"
    assert 8000 <= res["onset_step"] <= 13000, \
        f"WARN/FAIL: onset {res['onset_step']} not near 10,000"
    print("PASS: period-104 highway detected on empty grid, onset near 10k\n")

    print("=== Validation 2: RNG reproducibility ===")
    for k in (1, 3, 5):
        s = trial_seed(MASTER_SEED, k, 7)
        a = sample_perturbation(SplitMix64(s), k)
        b = sample_perturbation(SplitMix64(s), k)
        assert a == b, "FAIL: RNG not reproducible"
        print(f"k={k}, trial 7 seed={s}: {a} (reproduced identically)")
    print("PASS: same seed -> same samples\n")

    print("=== Validation 3: budget sufficiency ===")
    print(f"Empty-grid detection completed at onset {res['onset_step']}, "
          f"far below the 250,000-step budget.")
    print("PASS (final confirmation comes from experiment detection rates)\n")

    print("=== Validation 4: sanity of blind scan minimality ===")
    # The scanner tests periods ascending from 1, so a reported 104 means
    # no smaller period satisfied the criterion. Also check displacement
    # magnitude consistent with the known 104-step highway translation.
    vx, vy = res["displacement"]
    print(f"Per-period displacement: ({vx},{vy}), |v|_1 = {abs(vx)+abs(vy)}")
    assert abs(vx) == 2 and abs(vy) == 2, "FAIL: unexpected highway vector"
    print("PASS: displacement (±2,±2) per 104 steps, as expected for the highway")

    print("\nALL VALIDATIONS PASSED")


if __name__ == "__main__":
    main()
