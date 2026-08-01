#!/usr/bin/env python3
"""
Visualizations of New Shadow Relationships
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def gap_roots(G):
    """Calculate roots of the GAP equation x² = x + G"""
    disc = 1 + 4*G
    if disc >= 0:
        sqrt_disc = np.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2
    else:
        sqrt_disc = np.sqrt(disc + 0j)  # Complex sqrt
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2

# Create figure with multiple subplots
fig = plt.figure(figsize=(16, 12))
gs = GridSpec(3, 3, figure=fig)

# ======================================================
# Subplot 1: Thermodynamic Phase Transition
# ======================================================
ax1 = fig.add_subplot(gs[0, 0])

G_values = np.linspace(-0.5, 0.5, 200)
beta = 1.0
entropies = []
free_energies = []

for G in G_values:
    s_plus, s_minus = gap_roots(G)
    E1 = abs(s_plus)
    E2 = abs(s_minus)
    
    Z = np.exp(-beta * E1) + np.exp(-beta * E2)
    F = -(1/beta) * np.log(Z)
    
    p1 = np.exp(-beta * E1) / Z
    p2 = np.exp(-beta * E2) / Z
    
    S = -p1 * np.log(p1) if p1 > 0 else 0
    S -= p2 * np.log(p2) if p2 > 0 else 0
    
    entropies.append(S)
    free_energies.append(F)

ax1.plot(G_values, entropies, 'b-', linewidth=2, label='Entropy S')
ax1.axvline(x=-0.25, color='r', linestyle='--', linewidth=2, label='G = -1/4')
ax1.set_xlabel('G', fontsize=12)
ax1.set_ylabel('Entropy S', fontsize=12)
ax1.set_title('Shadow 15: Thermodynamic Phase Transition', fontsize=14, fontweight='bold')
ax1.legend()
ax1.grid(True, alpha=0.3)

# ======================================================
# Subplot 2: Statistical Distribution of Roots
# ======================================================
ax2 = fig.add_subplot(gs[0, 1])

# Generate random G values
np.random.seed(42)
G_random = np.random.uniform(-10, 10, 5000)
s_plus_abs = []
s_minus_abs = []

for G in G_random:
    s_plus, s_minus = gap_roots(G)
    s_plus_abs.append(abs(s_plus))
    s_minus_abs.append(abs(s_minus))

ax2.hist(s_plus_abs, bins=50, alpha=0.7, label='|s₊|', color='blue', edgecolor='black')
ax2.hist(s_minus_abs, bins=50, alpha=0.7, label='|s₋|', color='red', edgecolor='black')
ax2.set_xlabel('Root Magnitude', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Shadow 18: Statistical Distribution', fontsize=14, fontweight='bold')
ax2.legend()
ax2.grid(True, alpha=0.3)

# ======================================================
# Subplot 3: Complex Root Phase Angles
# ======================================================
ax3 = fig.add_subplot(gs[0, 2])

G_complex = np.linspace(-2, -0.26, 100)
phases = []

for G in G_complex:
    s_plus, s_minus = gap_roots(G)
    if isinstance(s_plus, complex):
        phase = np.angle(s_plus)
        phases.append(np.degrees(phase))
    else:
        phases.append(0)

ax3.plot(G_complex, phases, 'g-', linewidth=2, label='Phase angle')
ax3.axhline(y=90, color='r', linestyle='--', linewidth=2, label='90° (pure imaginary)')
ax3.axvline(x=-0.25, color='r', linestyle='--', linewidth=2, label='G = -1/4')
ax3.set_xlabel('G', fontsize=12)
ax3.set_ylabel('Phase Angle (degrees)', fontsize=12)
ax3.set_title('Shadow 19: Complex Root Phases', fontsize=14, fontweight='bold')
ax3.legend()
ax3.grid(True, alpha=0.3)

# ======================================================
# Subplot 4: Free Energy Landscape
# ======================================================
ax4 = fig.add_subplot(gs[1, 0])

ax4.plot(G_values, free_energies, 'purple', linewidth=2, label='Free Energy F')
ax4.axvline(x=-0.25, color='r', linestyle='--', linewidth=2, label='G = -1/4')
ax4.set_xlabel('G', fontsize=12)
ax4.set_ylabel('Free Energy F', fontsize=12)
ax4.set_title('Shadow 15: Free Energy Landscape', fontsize=14, fontweight='bold')
ax4.legend()
ax4.grid(True, alpha=0.3)

# ======================================================
# Subplot 5: Correlation Analysis
# ======================================================
ax5 = fig.add_subplot(gs[1, 1])

# Calculate correlation for different ranges
ranges = [(-10, -5), (-5, -1), (-1, 0), (0, 1), (1, 5), (5, 10)]
correlations = []
range_labels = []

for G_min, G_max in ranges:
    G_range = np.random.uniform(G_min, G_max, 1000)
    s_plus_range = []
    s_minus_range = []
    
    for G in G_range:
        s_plus, s_minus = gap_roots(G)
        s_plus_range.append(abs(s_plus))
        s_minus_range.append(abs(s_minus))
    
    corr = np.corrcoef(s_plus_range, s_minus_range)[0, 1]
    correlations.append(corr)
    range_labels.append(f'{G_min}:{G_max}')

x_pos = np.arange(len(range_labels))
ax5.bar(x_pos, correlations, color='orange', edgecolor='black')
ax5.set_xlabel('G Range', fontsize=12)
ax5.set_ylabel('Correlation', fontsize=12)
ax5.set_title('Shadow 18: Root Correlation by G Range', fontsize=14, fontweight='bold')
ax5.set_xticks(x_pos)
ax5.set_xticklabels(range_labels, rotation=45, ha='right')
ax5.grid(True, alpha=0.3)

# ======================================================
# Subplot 6: Energy Level Splitting
# ======================================================
ax6 = fig.add_subplot(gs[1, 2])

G_split = np.linspace(-0.5, 2.0, 100)
energy_diff = []

for G in G_split:
    s_plus, s_minus = gap_roots(G)
    E1 = abs(s_plus)
    E2 = abs(s_minus)
    energy_diff.append(abs(E1 - E2))

ax6.plot(G_split, energy_diff, 'brown', linewidth=2, label='|E₁ - E₂|')
ax6.axvline(x=-0.25, color='r', linestyle='--', linewidth=2, label='G = -1/4 (collision)')
ax6.set_xlabel('G', fontsize=12)
ax6.set_ylabel('Energy Difference', fontsize=12)
ax6.set_title('Shadow 15: Energy Level Splitting', fontsize=14, fontweight='bold')
ax6.legend()
ax6.grid(True, alpha=0.3)

# ======================================================
# Subplot 7: Geometric Ratio Evolution
# ======================================================
ax7 = fig.add_subplot(gs[2, 0])

G_ratio = np.linspace(-2, 3, 100, dtype=complex)
ratios = []

for G in G_ratio:
    s_plus, s_minus = gap_roots(G.real)
    if abs(s_minus) > 1e-10:
        ratio = s_plus / s_minus
        ratios.append(ratio)
    else:
        ratios.append(np.nan)

ratios = np.array(ratios)
real_part = np.real(ratios)
imag_part = np.imag(ratios)

valid_mask = ~np.isnan(ratios) & ~np.isinf(ratios)
real_part = real_part[valid_mask]
imag_part = imag_part[valid_mask]
G_plot = G_ratio.real[:len(real_part)]

ax7.plot(G_plot, real_part, 'b-', linewidth=2, label='Re(s₊/s₋)')
ax7.plot(G_plot, imag_part, 'r--', linewidth=2, label='Im(s₊/s₋)')
ax7.axvline(x=-0.25, color='k', linestyle='--', linewidth=2, label='G = -1/4')
ax7.axvline(x=1.0, color='g', linestyle=':', linewidth=2, label='G = 1 (golden)')
ax7.axvline(x=2.0, color='m', linestyle=':', linewidth=2, label='G = 2 (self-ref)')
ax7.set_xlabel('G', fontsize=12)
ax7.set_ylabel('Ratio s₊/s₋', fontsize=12)
ax7.set_title('Shadow 19: Geometric Ratio Evolution', fontsize=14, fontweight='bold')
ax7.legend()
ax7.grid(True, alpha=0.3)

# ======================================================
# Subplot 8: Phase Space Trajectory
# ======================================================
ax8 = fig.add_subplot(gs[2, 1])

# Create phase space: (s₊, s₋) for different G values
G_phase = np.linspace(-2, 3, 500)
t_real = []
t_imag = []

for G in G_phase:
    s_plus, s_minus = gap_roots(G)
    t_real.append(s_plus.real)
    t_imag.append(s_minus.real)

# Color code by G
scatter = ax8.scatter(t_real, t_imag, c=G_phase, cmap='viridis', s=20, alpha=0.6)
ax8.set_xlabel('Re(s₊)', fontsize=12)
ax8.set_ylabel('Re(s₋)', fontsize=12)
ax8.set_title('Shadow 19: Phase Space Trajectory', fontsize=14, fontweight='bold')
ax8.axhline(y=0.5, color='r', linestyle='--', linewidth=1, alpha=0.5)
ax8.axvline(x=0.5, color='r', linestyle='--', linewidth=1, alpha=0.5)
ax8.grid(True, alpha=0.3)
plt.colorbar(scatter, ax=ax8, label='G')

# ======================================================
# Subplot 9: Information Theoretic Coupling
# ======================================================
ax9 = fig.add_subplot(gs[2, 2])

# Demonstrate perfect coupling
G_test = np.linspace(-1, 2, 100)
s_plus_vals = []
s_minus_actual = []
s_minus_pred_1 = []  # Prediction from s_plus
prediction_errors = []

for G in G_test:
    s_plus, s_minus = gap_roots(G)
    s_plus_vals.append(s_plus)
    s_minus_actual.append(s_minus)
    s_minus_pred_1.append(1 - s_plus)  # Perfect coupling formula
    prediction_errors.append(abs((1 - s_plus) - s_minus))

# Since errors should be zero (or numerical precision), we show a zoomed view
ax9.semilogy(G_test, [max(err, 1e-15) for err in prediction_errors], 'black', linewidth=2, label='|prediction error|')
ax9.axhline(y=1e-15, color='r', linestyle='--', linewidth=2, label='Numerical precision')
ax9.set_xlabel('G', fontsize=12)
ax9.set_ylabel('Prediction Error (log scale)', fontsize=12)
ax9.set_title('Shadow 14: Perfect Information Coupling', fontsize=14, fontweight='bold')
ax9.legend()
ax9.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('new_shadows_visualization.png', dpi=300, bbox_inches='tight')
print("New shadows visualization saved as 'new_shadows_visualization.png'")
plt.show()