"""Statistical analysis of Stranger2 replication results."""

import csv
import math
from collections import defaultdict


def quantile(sorted_vals, q):
    """Linear-interpolation quantile (type 7, matches numpy default)."""
    n = len(sorted_vals)
    if n == 1:
        return float(sorted_vals[0])
    h = (n - 1) * q
    lo = math.floor(h)
    hi = math.ceil(h)
    return sorted_vals[lo] + (h - lo) * (sorted_vals[hi] - sorted_vals[lo])


def mannwhitney_u(x, y):
    """Two-sided Mann-Whitney U test with normal approximation and tie
    correction. Implemented from scratch."""
    nx, ny = len(x), len(y)
    combined = sorted([(v, 0) for v in x] + [(v, 1) for v in y])
    ranks = {}
    i = 0
    tie_term = 0.0
    while i < len(combined):
        j = i
        while j < len(combined) and combined[j][0] == combined[i][0]:
            j += 1
        avg_rank = (i + j + 1) / 2.0  # ranks are 1-based
        t = j - i
        if t > 1:
            tie_term += t ** 3 - t
        for m in range(i, j):
            ranks[m] = avg_rank
        i = j
    rank_sum_x = sum(ranks[m] for m in range(len(combined)) if combined[m][1] == 0)
    u_x = rank_sum_x - nx * (nx + 1) / 2.0
    mu = nx * ny / 2.0
    n = nx + ny
    sigma2 = nx * ny / 12.0 * ((n + 1) - tie_term / (n * (n - 1)))
    if sigma2 <= 0:
        return u_x, float("nan")
    z = (u_x - mu) / math.sqrt(sigma2)
    p = math.erfc(abs(z) / math.sqrt(2))  # two-sided
    return u_x, p


def kruskal_wallis(groups):
    """Kruskal-Wallis H with tie correction; chi-square p via Wilson-Hilferty
    approximation. Implemented from scratch."""
    all_vals = []
    for gi, g in enumerate(groups):
        all_vals.extend((v, gi) for v in g)
    all_vals.sort()
    n = len(all_vals)
    ranks = [0.0] * n
    i = 0
    tie_term = 0.0
    while i < n:
        j = i
        while j < n and all_vals[j][0] == all_vals[i][0]:
            j += 1
        avg = (i + j + 1) / 2.0
        t = j - i
        if t > 1:
            tie_term += t ** 3 - t
        for m in range(i, j):
            ranks[m] = avg
        i = j
    rank_sums = defaultdict(float)
    counts = defaultdict(int)
    for m in range(n):
        gi = all_vals[m][1]
        rank_sums[gi] += ranks[m]
        counts[gi] += 1
    h = 12.0 / (n * (n + 1)) * sum(
        rank_sums[gi] ** 2 / counts[gi] for gi in counts) - 3 * (n + 1)
    c = 1 - tie_term / (n ** 3 - n)
    h /= c
    df = len(groups) - 1
    # Wilson-Hilferty chi-square tail approximation
    x = (h / df) ** (1.0 / 3.0)
    mu = 1 - 2.0 / (9 * df)
    sd = math.sqrt(2.0 / (9 * df))
    z = (x - mu) / sd
    p = math.erfc(z / math.sqrt(2)) / 1.0 * 0.5 * 2  # one-sided upper tail
    p = 0.5 * math.erfc(z / math.sqrt(2)) * 2
    return h, min(max(p, 0.0), 1.0)


def main():
    by_k = defaultdict(list)
    n_rows = 0
    bad_period = []
    undetected = []
    with open("results.csv") as f:
        for row in csv.DictReader(f):
            n_rows += 1
            k = int(row["k"])
            if row["detected"] == "True":
                by_k[k].append(int(row["onset_step"]))
                if row["period"] != "104":
                    bad_period.append(row["trial_id"])
            else:
                undetected.append(row["trial_id"])

    print(f"Total trials: {n_rows}")
    print(f"Undetected: {len(undetected)}  Non-104 periods: {len(bad_period)}")
    print()
    header = (f"{'k':>2} {'n':>4} {'det%':>6} {'min':>7} {'Q1':>9} "
              f"{'median':>9} {'Q3':>9} {'max':>7} {'IQR':>8}")
    print(header)
    print("-" * len(header))
    lines = []
    for k in sorted(by_k):
        v = sorted(by_k[k])
        q1 = quantile(v, 0.25)
        med = quantile(v, 0.5)
        q3 = quantile(v, 0.75)
        line = (f"{k:>2} {len(v):>4} {100.0*len(v)/100:>6.1f} {v[0]:>7} "
                f"{q1:>9.1f} {med:>9.1f} {q3:>9.1f} {v[-1]:>7} {q3-q1:>8.1f}")
        print(line)
        lines.append((k, len(v), v[0], q1, med, q3, v[-1]))

    # Save summary CSV
    with open("summary.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["k", "n_detected", "detection_rate_pct", "min", "Q1",
                    "median", "Q3", "max", "IQR"])
        for k, n, mn, q1, med, q3, mx in lines:
            w.writerow([k, n, 100.0 * n / 100, mn, q1, med, q3, mx, q3 - q1])

    print("\n=== Comparative analysis ===")
    # k=0 is a fixed configuration (100 identical trials) — note this.
    v0 = by_k[0]
    print(f"k=0 onset values: unique={sorted(set(v0))} "
          f"(deterministic; all {len(v0)} trials identical, as expected)")

    groups = [by_k[k] for k in (1, 2, 3, 4, 5)]
    h, p = kruskal_wallis(groups)
    print(f"\nKruskal-Wallis across k=1..5: H={h:.3f}, p≈{p:.4f}")

    print("\nPairwise Mann-Whitney U (two-sided), k pairs:")
    ks = [1, 2, 3, 4, 5]
    for a in range(len(ks)):
        for b in range(a + 1, len(ks)):
            u, p = mannwhitney_u(by_k[ks[a]], by_k[ks[b]])
            flag = " *" if p < 0.05 else ""
            print(f"  k={ks[a]} vs k={ks[b]}: U={u:.0f}, p≈{p:.4f}{flag}")

    print("\nEach perturbed k vs k=0 median (9976):")
    for k in ks:
        v = by_k[k]
        below = sum(1 for x in v if x < 9976)
        above = sum(1 for x in v if x > 9976)
        eq = sum(1 for x in v if x == 9976)
        print(f"  k={k}: {below} faster, {eq} equal, {above} slower than k=0")

    print("\nOutliers (Tukey fence, per k):")
    for k in ks:
        v = sorted(by_k[k])
        q1, q3 = quantile(v, 0.25), quantile(v, 0.75)
        iqr = q3 - q1
        lo, hi = q1 - 1.5 * iqr, q3 + 1.5 * iqr
        out = [x for x in v if x < lo or x > hi]
        print(f"  k={k}: {len(out)} outliers "
              f"{sorted(out)[:6]}{'...' if len(out) > 6 else ''}")


if __name__ == "__main__":
    main()
