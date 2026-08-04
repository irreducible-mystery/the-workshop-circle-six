"""Visualization of onset-time distributions per perturbation size k."""

import csv
from collections import defaultdict
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

by_k = defaultdict(list)
with open("results.csv") as f:
    for row in csv.DictReader(f):
        if row["detected"] == "True":
            by_k[int(row["k"])].append(int(row["onset_step"]))

ks = sorted(by_k)
data = [by_k[k] for k in ks]

fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

# Boxplot
bp = axes[0].boxplot(data, tick_labels=[str(k) for k in ks], showmeans=True,
                     patch_artist=True)
for patch in bp["boxes"]:
    patch.set_facecolor("#9ecae1")
axes[0].axhline(9976, color="red", ls="--", lw=1,
                label="k=0 deterministic onset (9976)")
axes[0].set_xlabel("Perturbation size k (black cells)")
axes[0].set_ylabel("Highway onset step")
axes[0].set_title("Onset time by perturbation size (n=100 per k)")
axes[0].legend()
axes[0].grid(alpha=0.3)

# Strip/jitter plot with medians
import random
random.seed(1)
for i, k in enumerate(ks):
    xs = [i + random.uniform(-0.22, 0.22) for _ in by_k[k]]
    axes[1].scatter(xs, by_k[k], s=8, alpha=0.45, color="#3182bd")
    v = sorted(by_k[k])
    med = (v[49] + v[50]) / 2
    axes[1].plot([i - 0.3, i + 0.3], [med, med], color="black", lw=2)
axes[1].axhline(9976, color="red", ls="--", lw=1)
axes[1].set_xticks(range(len(ks)))
axes[1].set_xticklabels([str(k) for k in ks])
axes[1].set_xlabel("Perturbation size k")
axes[1].set_ylabel("Highway onset step")
axes[1].set_title("Individual trials (black bar = median)")
axes[1].grid(alpha=0.3)

plt.suptitle("Langton's Ant: highway onset vs. perturbation size "
             "(seed 20240804, 600 trials, 100% detection, all period 104)")
plt.tight_layout()
plt.savefig("onset_distributions.png", dpi=150)
print("saved onset_distributions.png")
