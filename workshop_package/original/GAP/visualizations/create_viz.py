#!/usr/bin/env python3
"""
Comprehensive Visualization Suite for GAP Equation Boundaries
Creates 10 deep visualizations exploring the boundary at G = -1/4
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
import cmath
import math
import sys

# Ensure visualizations directory exists
import os
os.makedirs('visualizations', exist_ok=True)

# Set up the figure style
plt.style.use('dark_background')

def gap_roots(G):
    """Return the two roots of x^2 = x + G"""
    disc = 1 + 4*G
    if disc >= 0:
        sqrt_disc = math.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2
    else:
        sqrt_disc = cmath.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2

def rotation_number(G):
    """Return rotation number for G < -1/4"""
    if G >= -1/4:
        return None
    nu = math.sqrt(-(G + 0.25))
    s_plus = 0.5 + 1j*nu
    theta = cmath.phase(s_plus)
    return theta / math.pi

print("="*70)
print("Creating GAP Equation Boundary Visualizations")
print("="*70)

# =============================================================================
# FIGURE 1: Root Trajectories in Complex Plane
# =============================================================================

print("\n[1/10] Creating root trajectories visualization...")

fig1, (ax1a, ax1b) = plt.subplots(1, 2, figsize=(16, 7))
fig1.suptitle('Root Trajectories: The Collision at G = -1/4', fontsize=16, color='#FFD700', weight='bold')

# Panel 1a: Real roots (G > -1/4)
G_vals_real = np.linspace(-0.24, 2, 150)
roots_plus = []
roots_minus = []

for G in G_vals_real:
    rp, rm = gap_roots(G)
    roots_plus.append(rp.real)
    roots_minus.append(rm.real)

ax1a.plot(roots_plus, np.zeros_like(roots_plus), 'c-', linewidth=2, label=r'$s_+ = (1+\sqrt{1+4G})/2$', alpha=0.8)
ax1a.plot(roots_minus, np.zeros_like(roots_minus), 'm-', linewidth=2, label=r'$s_- = (1-\sqrt{1+4G})/2$', alpha=0.8)
ax1a.plot(0.5, 0, 'y*', markersize=20, markeredgecolor='white', markeredgewidth=1, label='Collision: G = -1/4', zorder=10)
ax1a.axhline(y=0, color='white', linewidth=0.5, alpha=0.3)
ax1a.axvline(x=0.5, color='yellow', linestyle='--', linewidth=1.5, alpha=0.5)
ax1a.set_xlabel('Root Value', fontsize=12)
ax1a.set_ylabel('Imaginary Part', fontsize=12)
ax1a.set_title('G > -1/4: Two Real Roots Collide at x = 1/2', fontsize=13, color='#FFD700')
ax1a.legend(loc='upper left', fontsize=10)
ax1a.grid(True, alpha=0.2)
ax1a.set_ylim(-0.2, 0.3)
ax1a.set_xlim(-0.5, 2)

# Panel 1b: Complex conjugate roots (G < -1/4)
G_vals_complex = np.linspace(-2.1, -0.26, 120)
ring_plus_real = []
ring_plus_imag = []
ring_minus_real = []
ring_minus_imag = []

for G in G_vals_complex:
    rp, rm = gap_roots(G)
    ring_plus_real.append(rp.real)
    ring_plus_imag.append(rp.imag)
    ring_minus_real.append(rm.real)
    ring_minus_imag.append(rm.imag)

ax1b.plot(ring_plus_real, ring_plus_imag, 'c-', linewidth=2.5, alpha=0.8, label=r'$s_+$ (upper half-plane)')
ax1b.plot(ring_minus_real, ring_minus_imag, 'm-', linewidth=2.5, alpha=0.8, label=r'$s_-$ (lower half-plane)')
circle = Circle((0.5, 0), 0.8660254, fill=False, edgecolor='white', linestyle='--', linewidth=1, alpha=0.3, label='|radius| = √3/2 (G=-1)')
ax1b.add_patch(circle)
ax1b.plot(0.5, 0, 'y*', markersize=20, markeredgecolor='white', markeredgewidth=1, label='Branch point: G = -1/4', zorder=10)
ax1b.set_xlabel('Real Part', fontsize=12)
ax1b.set_ylabel('Imaginary Part', fontsize=12)
ax1b.set_title('G < -1/4: Complex Conjugates Rotate with Equal Modulus', fontsize=13, color='#FFD700')
ax1b.legend(loc='upper right', fontsize=9)
ax1b.grid(True, alpha=0.2)
ax1b.set_aspect('equal')
ax1b.set_xlim(-0.5, 1.5)
ax1b.set_ylim(-1.5, 1.5)

plt.tight_layout()
plt.savefig('visualizations/fig1_root_trajectories.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig1_root_trajectories.png")

# =============================================================================
# FIGURE 2: Van Hove Singularity and Density of States
# =============================================================================

print("\n[2/10] Creating van Hove singularity visualization...")

fig2, (ax2a, ax2b) = plt.subplots(1, 2, figsize=(16, 7))
fig2.suptitle('Singularities: Van Hove and Density of States', fontsize=16, color='#FFD700', weight='bold')

# Panel 2a: Density of states divergence
g_vals = np.linspace(-0.2499, 0, 300)
rho_vals = []

for g in g_vals:
    rho = 1 / math.sqrt(max(1 + 4*g, 1e-10)) if g >= -0.25 else np.nan
    rho_vals.append(rho)

ax2a.plot(g_vals, rho_vals, 'cyan', linewidth=2.5, label=r'$\\rho(g) = (1+4g)^{-1/2}$')
ax2a.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax2a.text(-0.25, max(rho_vals)*0.8, r'$G = -1/4$', rotation=90, ha='right', va='center', c='yellow', fontsize=12, weight='bold')
text_y = max(rho_vals) * 0.3
ax2a.text(-0.24, text_y, r'$\\rho(g) \\sim (g + 1/4)^{-1/2}$', fontsize=11, c='yellow', weight='bold')
ax2a.text(-0.24, text_y * 0.7, 'Standard 1D van Hove singularity', fontsize=9, c='white', style='italic')
ax2a.set_xlabel('Gap G', fontsize=12)
ax2a.set_ylabel('Density of States ρ(G)', fontsize=12)
ax2a.set_title('Divergence at the Band Edge: States Pile Up', fontsize=13, color='#FFD700')
ax2a.legend(loc='upper right', fontsize=10)
ax2a.grid(True, alpha=0.2)
ax2a.set_ylim(0, max(rho_vals)*1.1)

# Panel 2b: Operator bound visualization
t_vals = np.linspace(0, 1, 200)
g_operator = [t**2 - t for t in t_vals]

ax2b.plot(t_vals, g_operator, 'magenta', linewidth=2.5, label=r'$G = t^2 - t$')
ax2b.fill_between(t_vals, g_operator, alpha=0.3, color='magenta')
min_idx = np.argmin(g_operator)
ax2b.plot(t_vals[min_idx], g_operator[min_idx], 'y*', markersize=20, markeredgecolor='white', markeredgewidth=1, label='Ground state: G = -1/4', zorder=10)
ax2b.text(0.5, -0.35, 'For self-adjoint A: G = A² - A', ha='center', fontsize=11, c='white')
ax2b.text(0.5, -0.42, r'$G \\geq -\\frac{1}{4}I$  (greatest lower bound)', ha='center', fontsize=10, c='yellow', weight='bold')
ax2b.text(0.5, -0.5, 'Below -1/4 → eigenvalues leave ℝ → unobservable', ha='center', fontsize=9, c='cyan', style='italic')
ax2b.set_xlabel('t (multiplication operator eigenvalue)', fontsize=12)
ax2b.set_ylabel('G', fontsize=12)
ax2b.set_title('Operator Theory: G = A² - A ≥ -1/4', fontsize=13, color='#FFD700')
ax2b.legend(loc='lower center', fontsize=10)
ax2b.grid(True, alpha=0.2)
ax2b.axhline(y=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.5)

plt.tight_layout()
plt.savefig('visualizations/fig2_van_hove.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig2_van_hove.png")

# =============================================================================
# FIGURE 3: Dynamics (Mandelbrot and Logistic Map)
# =============================================================================

print("\n[3/10] Creating dynamics visualization...")

fig3, (ax3a, ax3b) = plt.subplots(1, 2, figsize=(16, 7))
fig3.suptitle('Dynamics: Mandelbrot and Logistic Stability Windows', fontsize=16, color='#FFD700', weight='bold')

# Panel 3a: Stability window concept
c_vals = np.linspace(0.25, -0.8, 80)
stability = []
for c in c_vals:
    z = 0
    max_it = 50
    for _ in range(max_it):
        z = z**2 + c
        if abs(z) > 2:
            stability.append(0)
            break
    else:
        stability.append(1)

g_from_c = [-c for c in c_vals]
colors = ['red' if s == 0 else 'green' for s in stability]
ax3a.scatter(g_from_c, c_vals, c=colors, s=50, alpha=0.7, edgecolors='none')
ax3a.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax3a.axvline(x=0.75, color='orange', linestyle='--', linewidth=2, alpha=0.7)
ax3a.axvspan(-0.25, 0.75, alpha=0.2, color='green')
ax3a.set_xlabel('Gap G = -c', fontsize=12)
ax3a.set_ylabel('Mandelbrot c', fontsize=12)
ax3a.set_title('Fixed Points of z² + c: Stability Window', fontsize=13, color='#FFD700')
ax3a.text(0.25, -0.6, 'UNSTABLE\n(period doubling)', ha='center', c='red', fontsize=9)
ax3a.text(0, 0.05, 'STABLE\n(main cardioid)', ha='center', c='green', fontsize=9, weight='bold')
ax3a.text(-0.5, 0.4, 'ESCAPES\nto infinity', ha='center', c='red', fontsize=9)
ax3a.grid(True, alpha=0.2)

# Panel 3b: Logistic map conjugacy
r_vals = np.linspace(0, 4, 100)
g_from_r = [r**2/4 - r/2 for r in r_vals]
ax3b.plot(r_vals, g_from_r, 'cyan', linewidth=2.5, label=r'$G = r^2/4 - r/2$')
ax3b.axvspan(1, 3, alpha=0.2, color='green', label='Stable fixed point')
ax3b.axvline(x=1, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax3b.axvline(x=3, color='orange', linestyle='--', linewidth=2, alpha=0.7)
golden_r_plus = 1 + math.sqrt(5)
ax3b.plot([golden_r_plus, 1 - math.sqrt(5)], [1, 1], 'y*', markersize=12, markeredgecolor='white', markeredgewidth=1, label='G=1 (golden) outside window', zorder=10)
ax3b.text(0.5, -0.8, 'r < 1: x=0 is only attractor', ha='center', c='white', fontsize=9)
ax3b.text(2, 0.8, '1 < r < 3: stable non-zero fixed point', ha='center', c='green', fontsize=9, weight='bold')
ax3b.text(3.5, 2.5, 'r > 3: period-doubling cascade', ha='center', c='red', fontsize=9)
ax3b.set_xlabel('Logistic map parameter r', fontsize=12)
ax3b.set_ylabel('Gap G', fontsize=12)
ax3b.set_title('Logistic Map x → rx(1-x): Conjugacy to Gap', fontsize=13, color='#FFD700')
ax3b.legend(loc='upper right', fontsize=9)
ax3b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig3_dynamics.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig3_dynamics.png")

# =============================================================================
# FIGURE 4: Rotation Numbers
# =============================================================================

print("\n[4/10] Creating rotation number visualization...")

fig4, (ax4a, ax4b) = plt.subplots(1, 2, figsize=(16, 7))
fig4.suptitle('Below -1/4: Rotation Number Indexing of Gaps', fontsize=16, color='#FFD700', weight='bold')

# Panel 4a: Rotation number vs G
G_rot = np.linspace(-2.0, -0.26, 150)
rot_numbers = []
for G in G_rot:
    rot = rotation_number(G)
    rot_numbers.append(rot)

ax4a.plot(G_rot, rot_numbers, 'cyan', linewidth=2.5, label=r'$\\theta/\\pi = rotation number$')
rationals = [(3, -1.0, '1/3'), (4, -0.5, '1/4'), (5, -0.38196601, '1/5'), (6, -0.33333333, '1/6'), (8, -0.29289322, '1/8'), (12, -0.26794919, '1/12')]
for period, G, label in rationals:
    rot = rotation_number(G)
    ax4a.plot(G, rot, 'yo', markersize=10, markeredgecolor='white', markeredgewidth=1, zorder=10)
    ax4a.text(G, rot + 0.05, f'{label} → period {period}', ha='center', fontsize=9, c='yellow')
ax4a.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax4a.axhline(y=0, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax4a.text(-0.5, 0.8, 'Rational rotation → periodic continued fraction', ha='center', c='green', fontsize=10)
ax4a.text(-1.5, 0.8, 'Irrational rotation → fill the circle', ha='center', c='cyan', fontsize=10)
ax4a.set_xlabel('Gap G', fontsize=12)
ax4a.set_ylabel('Rotation Number θ/π', fontsize=12)
ax4a.set_title('Rotation Number Indexing G < -1/4', fontsize=13, color='#FFD700')
ax4a.legend(loc='upper left', fontsize=10)
ax4a.grid(True, alpha=0.2)

# Panel 4b: Continued fraction convergence
G_cf = np.linspace(-2.0, -0.26, 80)
cf_rot = [rotation_number(G) for G in G_cf]
ax4b.plot(G_cf, cf_rot, 'cyan', linewidth=2, alpha=0.5)
g_neg_third = -1/3
rot_neg_third = rotation_number(g_neg_third)
ax4b.plot(g_neg_third, rot_neg_third, 'y*', markersize=20, markeredgecolor='white', markeredgewidth=1, label=r'$G = -1/3$: reflexive & rotation 6', zorder=15)
ax4b.text(g_neg_third, rot_neg_third + 0.05, 'Reflexive!', ha='center', fontsize=10, c='yellow', weight='bold')
ax4b.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.5)
ax4b.set_xlabel('Gap G', fontsize=12)
ax4b.set_ylabel('Rotation Number θ/π', fontsize=12)
ax4b.set_title('Rotation Numbers ↔ Continued Fraction Convergence', fontsize=13, color='#FFD700')
ax4b.legend(loc='upper left', fontsize=9)
ax4b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig4_rotation_numbers.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig4_rotation_numbers.png")

# =============================================================================
# FIGURE 5: Reflexive Ladder
# =============================================================================

print("\n[5/10] Creating reflexive ladder visualization...")

fig5, ax5 = plt.subplots(1, 1, figsize=(14, 8))
fig5.suptitle('The Reflexive Ladder: Six Self-Referential Gaps', fontsize=16, color='#FFD700', weight='bold')

reflexive_gaps = [
    (-1/3, 'G = -1/3', 'G equals its own', 'discriminant'),
    (-1/4, 'G = -1/4', 'G equals its own', 'branch point'),
    (0, 'G = 0', 'G equals the', 'product of its roots'),
    (1, 'G = 1 (golden)', 'G equals the', 'sum of its roots'),
    (2, 'G = 2', 'G is one of its', 'own roots'),
    (4.236067977, 'G = φ^3', 'G equals the', 'difference of its roots'),
]

y_base = 0.5
for g, label, line1, line2 in reflexive_gaps:
    if g < -0.25:
        color = 'red'
    elif g == -0.25:
        color = 'yellow'
    elif 0 <= g <= 1:
        color = 'green'
    else:
        color = 'cyan'
    ax5.plot(g, y_base, 'o', markersize=15, color=color, markeredgecolor='white', markeredgewidth=2, zorder=10)
    ax5.text(g, y_base + 0.2, label, ha='center', fontsize=11, c=color, weight='bold')
    ax5.text(g, y_base - 0.15, line1, ha='center', fontsize=9, c='white')
    ax5.text(g, y_base - 0.3, line2, ha='center', fontsize=9, c='white')

ax5.axhline(y=y_base, color='white', linewidth=3, alpha=0.5)
ax5.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.5)
ax5.text(-0.25, y_base + 0.5, 'G = -1/4', rotation=90, ha='right', va='center', c='yellow', fontsize=12, weight='bold')
ax5.text(-0.5, y_base + 0.7, 'Complex region', ha='center', c='red', fontsize=10)
ax5.text(0.5, y_base + 0.7, 'Real counting region', ha='center', c='green', fontsize=10)
ax5.text(3, y_base + 0.7, 'Beyond stability window', ha='center', c='orange', fontsize=10)
for i in range(len(reflexive_gaps) - 1):
    g1 = reflexive_gaps[i][0]
    g2 = reflexive_gaps[i + 1][0]
    ax5.plot([g1, g2], [y_base - 0.5, y_base - 0.5], 'w-', alpha=0.3, linewidth=1)
ax5.set_xlabel('Gap G', fontsize=12)
ax5.set_ylim(-0.6, 1.2)
ax5.set_xlim(-0.5, 5)
ax5.set_xticks([])
ax5.set_yticks([])
ax5.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig5_reflexive_ladder.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig5_reflexive_ladder.png")

# =============================================================================
# FIGURE 6: Growth Rates
# =============================================================================

print("\n[6/10] Creating growth rates visualization...")

fig6, (ax6a, ax6b) = plt.subplots(1, 2, figsize=(16, 7))
fig6.suptitle('Random Gaps: Three Growth Rates for One System', fontsize=16, color='#FFD700', weight='bold')

growth_rates = {
    'Deterministic G = +1': 1.618034,
    'Deterministic G = -1': 1.0,
    'Viswanath (mixed G in {±1})': 1.131988,
    'Annealed 1st moment': 1.0,
    'Annealed 2nd moment': 1.272020,
}
colors = ['cyan', 'magenta', 'yellow', 'green', 'orange']
bars = ax6a.barh(range(len(growth_rates)), list(growth_rates.values()), color=colors, alpha=0.8, edgecolor='white')
for i, (rate, bar) in enumerate(zip(growth_rates.values(), bars)):
    width = bar.get_width()
    ax6a.text(width + 0.02, bar.get_y() + bar.get_height()/2, f'{rate:.6f}', ha='left', va='center', fontsize=10, c='white', weight='bold')
ax6a.set_yticks(range(len(growth_rates)))
ax6a.set_yticklabels(list(growth_rates.keys()), fontsize=10)
ax6a.set_xlabel('Growth Rate', fontsize=12)
ax6a.set_title('Different Questions, Different Answers', fontsize=13, color='#FFD700')
ax6a.grid(True, alpha=0.2, axis='x')

p_vals = np.linspace(0, 1, 100)
growth_vs_p = [math.exp(p * math.log(3) + (1-p) * 0.5 * math.log(5)) for p in p_vals]
ax6b.plot(p_vals, growth_vs_p, 'cyan', linewidth=2.5, label=r'$\lambda(p) = p\log(3) + (1-p)\frac{1}{2}\log(5)$')
for p in [0, 0.5, 1]:
    growth = math.exp(p * math.log(3) + (1-p) * 0.5 * math.log(5))
    ax6b.plot(p, growth, 'yo', markersize=10, markeredgecolor='white', markeredgewidth=1, zorder=10)
ax6b.axhline(y=1.0, color='magenta', linestyle='--', linewidth=2, alpha=0.5)
ax6b.axhline(y=1.618034, color='cyan', linestyle='--', linewidth=2, alpha=0.3)
ax6b.set_xlabel('Probability p of G = +1', fontsize=12)
ax6b.set_ylabel('Growth Rate', fontsize=12)
ax6b.set_title('Tilted Mixtures: Growth as Function of Bias', fontsize=13, color='#FFD700')
ax6b.legend(loc='upper left', fontsize=10)
ax6b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig6_growth_rates.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig6_growth_rates.png")

# =============================================================================
# FIGURE 7: Universal Boundary Summary
# =============================================================================

print("\n[7/10] Creating universal boundary visualization...")

fig7, ax7 = plt.subplots(1, 1, figsize=(16, 12))
fig7.suptitle('G = -1/4: The Universal Boundary', fontsize=18, color='#FFD700', weight='bold')

manifestations = [
    (0.9, 'Branch Point', 'Discriminant vanishes roots collide'),
    (1.7, 'Spectral Edge', 'Van Hove singularity'),
    (2.5, 'Operator Bound', 'G = A² - A ≥ -¼·I'),
    (3.3, 'Rotation Zero', 'Parabolic point'),
    (4.1, 'Bifurcation', 'Tangent bifurcation'),
    (4.9, 'Catalan Radius', 'Convergence radius = ¼'),
    (5.7, 'Chirality Collapse', 'Sphere dimensions 2^n-2 to point'),
    (6.5, 'Universal Answer', 'Everything meets at -1/4'),
]

for i, (radius, title, description) in enumerate(manifestations):
    angle = math.pi/2 + (i * 0.2)
    x = 7 + radius * math.cos(angle)
    y = 6 + radius * math.sin(angle)
    circle = Circle((7, 6), radius, fill=False, edgecolor='cyan', linestyle='--' if i % 2 == 0 else '-', linewidth=1.5, alpha=0.6)
    ax7.add_patch(circle)
    ax7.text(x, y + radius*0.08, title, ha='center', fontsize=9, c='yellow', weight='bold')
    ax7.text(x, y - radius*0.08, description, ha='center', fontsize=7, c='white', alpha=0.8)

ax7.plot(7, 6, 'y*', markersize=30, markeredgecolor='white', markeredgewidth=2, zorder=10)
ax7.text(7, 6.4, 'G = -1/4', ha='center', fontsize=14, c='yellow', weight='bold')
ax7.text(7, 5.6, 'THE UNIVERSAL BOUNDARY', ha='center', fontsize=11, c='white', style='italic')
ax7.set_xlim(0, 14)
ax7.set_ylim(0, 12)
ax7.set_aspect('equal')
ax7.grid(True, alpha=0.1)
ax7.set_xticks([])
ax7.set_yticks([])
ax7.text(7, -0.5, 'The same number, everywhere.', ha='center', fontsize=12, c='yellow', style='italic', weight='bold')

plt.tight_layout()
plt.savefig('visualizations/fig7_universal_boundary.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig7_universal_boundary.png")

# =============================================================================
# FIGURE 8: Catalan Asymptotics
# =============================================================================

print("\n[8/10] Creating Catalan asymptotics visualization...")

fig8, (ax8a, ax8b) = plt.subplots(1, 2, figsize=(16, 7))
fig8.suptitle('Catalan Numbers: Branch Point Encoded in Asymptotics', fontsize=16, color='#FFD700', weight='bold')

n_vals = np.arange(0, 15)
catalan = [math.comb(2*n, n) // (n + 1) for n in n_vals]
partial_sums = []
for n in n_vals:
    s = sum(catalan[k] * (0.25)**k for k in range(n+1))
    partial_sums.append(s)

ax8a.plot(n_vals, partial_sums, 'cyan', linewidth=2.5, marker='o', markersize=8, label='Partial sums at G = -1/4')
ax8a.axhline(y=0.5, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax8a.text(1, 0.52, 'Expected: 1/2', fontsize=10, c='yellow', weight='bold')
ax8a.text(8, 1.6, 'Slow convergence (on radius)', fontsize=9, c='white', ha='center')
ax8a.set_xlabel('Number of terms n', fontsize=12)
ax8a.set_ylabel('Partial sum', fontsize=12)
ax8a.set_title('Catalan Series at G = -1/4: Converges But Just Barely', fontsize=13, color='#FFD700')
ax8a.legend(loc='upper right', fontsize=10)
ax8a.grid(True, alpha=0.2)

ratios = [catalan[n] / catalan[n-1] if n > 0 else 0 for n in n_vals[1:]]
ax8b.plot(n_vals[1:], ratios, 'cyan', linewidth=2.5, marker='o', markersize=8, label=r'$C_n/C_{n-1}$')
ax8b.axhline(y=4, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax8b.text(12, 4.1, '→ 4 = 1/(1/4)', fontsize=11, c='yellow', weight='bold')
ax8b.text(8, 3.2, 'Approaches 4 with n^(-3/2) correction', fontsize=9, c='white', ha='center')
ax8b.set_xlabel('n', fontsize=12)
ax8b.set_ylabel(r'Ratio $C_n/C_{n-1}$', fontsize=12)
ax8b.set_title('Catalan Coefficient Ratios → Branch Position', fontsize=13, color='#FFD700')
ax8b.legend(loc='lower right', fontsize=10)
ax8b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig8_catalan_asymptotics.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig8_catalan_asymptotics.png")

# =============================================================================
# FIGURE 9: Chirality Across Carriers
# =============================================================================

print("\n[9/10] Creating chirality across carriers visualization...")

fig9, ax9 = plt.subplots(1, 1, figsize=(14, 10))
fig9.suptitle('Can You Tell Yourself Apart From Yourself? Fourteen Carriers', fontsize=16, color='#FFD700', weight='bold')

carriers = [
    ("Characteristic 2 field", "X X", "Roots equal (in char 2, x = -x always)", "red"),
    ("Complex numbers ℂ", "√  √", "Always distinguishable (opposite imaginary parts)", "cyan"),
    ("Quaternions ℍ", "○", "Sphere S² collapses to point at G=-1/4", "green"),
    ("Octonions 𝕆", "○", "6-sphere collapses to point at G=-1/4", "green"),
    ("Sedenions S", "○", "14-sphere collapses (zero divisors harmless)", "yellow"),
    ("Max-plus semiring", "X √", "Exactly one root (on one branch only)", "magenta"),
    ("Min-plus semiring", "√ X", "Exactly one root (on opposite branch)", "magenta"),
    ("Dual numbers", "X X", "Obstruction at branch point", "orange"),
    ("M₂(ℝ) matrices", "√  √", "Unique scalar solution", "green"),
    ("ℝ (real numbers)", "√  √", "Distinguishable above -1/4", "cyan"),
    ("GF(4) field", "X √", "Halved gaps reachable", "orange"),
    ("Char 5 field", "√ X", "Branch at G≡1(mod 5)", "orange"),
    ("Char 3 field", "√ X", "Branch at G≡1(mod 3)", "orange"),
    ("Char 17 field", "√ X", "Branch at G≡4(mod 17)", "orange"),
]

n_carriers = len(carriers)
for i, (carrier, behavior, description, color) in enumerate(carriers):
    y = n_carriers - i - 0.5
    ax9.text(-0.5, y, carrier, ha='right', va='center', fontsize=10, c='white', weight='bold')
    if "√" in behavior:
        ax9.text(0, y, behavior, ha='left', va='center', fontsize=14, c='cyan', weight='bold')
    elif "○" in behavior:
        ax9.text(0, y, behavior, ha='left', va='center', fontsize=14, c='green', weight='bold')
    elif "X" in behavior:
        ax9.text(0, y, behavior, ha='left', va='center', fontsize=14, c='red', weight='bold')
    ax9.text(2, y, description, ha='left', va='center', fontsize=9, c='white', alpha=0.7)

ax9.axvline(x=6.5, color='yellow', linestyle='--', linewidth=1, alpha=0.5)
ax9.text(-0.5, -1, 'THE ANSWER IS CARRIER-DEPENDENT', ha='right', fontsize=11, c='yellow', weight='bold')
ax9.text(2, -1, 'Can you tell yourself apart from yourself?', ha='left', fontsize=11, c='yellow', weight='bold')
ax9.text(6.5, -1.5, 'UNIVERSAL ANSWER: It depends on the gap', ha='left', fontsize=10, c='white', style='italic')
ax9.set_xlim(-0.5, 14)
ax9.set_ylim(-2, n_carriers)
ax9.set_xticks([])
ax9.set_yticks([])
ax9.grid(True, alpha=0.1)
ax9.text(-0.5, -2.5, 'G = -1/4: everywhere meets', ha='right', fontsize=9, c='yellow', style='italic')

plt.tight_layout()
plt.savefig('visualizations/fig9_chirality_carriers.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig9_chirality_carriers.png")

# =============================================================================
# FIGURE 10: Three Realms Summary
# =============================================================================

print("\n[10/10] Creating three realms visualization...")

fig10 = plt.figure(figsize=(18, 12))
gs = fig10.add_gridspec(3, 3, hspace=0.3, wspace=0.3)
fig10.suptitle('The Three Realms of the GAP Equation', fontsize=20, color='#FFD700', weight='bold')

# Top: Above -1/4
ax_top = fig10.add_subplot(gs[0, :])
G_above = np.linspace(-0.24, 2, 200)
solutions_above_real = []
solutions_above_imag = []
for G in G_above:
    rp, rm = gap_roots(G)
    solutions_above_real.append([rp.real, rm.real])
    solutions_above_imag.append([rp.imag, rm.imag])
solutions_above_real = np.array(solutions_above_real)
solutions_above_imag = np.array(solutions_above_imag)

ax_top.plot(G_above, solutions_above_real[:, 0], 'cyan', linewidth=2, label='s_+')
ax_top.plot(G_above, solutions_above_real[:, 1], 'magenta', linewidth=2, label='s_-')
ax_top.fill_between(G_above, solutions_above_real[:, 0], solutions_above_real[:, 1], alpha=0.1, color='green')
ax_top.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2)
ax_top.set_title('ABOVE -1/4: The Counting Realm (Two Real Roots)', fontsize=14, color='green')
ax_top.set_xlabel('Gap G', fontsize=11)
ax_top.set_ylabel('Root Value', fontsize=11)
ax_top.legend()
ax_top.grid(True, alpha=0.2)

# Middle: At -1/4
ax_mid = fig10.add_subplot(gs[1, :])
ax_mid.axvline(x=0, color='yellow', linewidth=3, alpha=0.5)
ax_mid.text(0, 0.5, 'G = -1/4', ha='center', fontsize=20, c='yellow', weight='bold')
ax_mid.text(0, 0.3, 'THE UNIVERSAL BOUNDARY', ha='center', fontsize=14, c='white', style='italic')
ax_mid.text(0, 0.1, 'Roots collide: x = 1/2', ha='center', fontsize=11, c='cyan')
ax_mid.text(0, -0.1, 'Derivative = 0 (cannot deform)', ha='center', fontsize=11, c='orange')
ax_mid.text(0, -0.3, 'All carriers meet here', ha='center', fontsize=11, c='magenta')
ax_mid.set_ylim(-0.5, 0.7)
ax_mid.set_xlim(-1, 1)
ax_mid.set_xticks([])
ax_mid.set_yticks([])
ax_mid.set_title('AT -1/4: The Boundary (Everything Meets)', fontsize=14, color='yellow')

# Bottom: Below -1/4 in three panels
ax_bottom_left = fig10.add_subplot(gs[2, 0])
G_below = np.linspace(-2.0, -0.26, 150)
ring_real = []
ring_imag = []
for G in G_below:
    rp, rm = gap_roots(G)
    ring_real.append([rp.real, rm.real])
    ring_imag.append([rp.imag, rm.imag])
ring_real = np.array(ring_real)
ring_imag = np.array(ring_imag)

ax_bottom_left.plot(ring_real[:, 0], ring_imag[:, 0], 'cyan', linewidth=2, label='s_+ (upper)')
ax_bottom_left.plot(ring_real[:, 1], ring_imag[:, 1], 'magenta', linewidth=2, label='s_- (lower)')
circle_unity = Circle((0.5, 0), 0.8660254, fill=False, edgecolor='white', linestyle='--', alpha=0.5)
ax_bottom_left.add_patch(circle_unity)
ax_bottom_left.plot(0.5, 0, 'y*', markersize=15)
ax_bottom_left.set_title('Root Trajectories', fontsize=12, color='red')
ax_bottom_left.set_xlabel('Real', fontsize=10)
ax_bottom_left.set_ylabel('Imaginary', fontsize=10)
ax_bottom_left.legend(fontsize=8, loc='upper right')
ax_bottom_left.grid(True, alpha=0.2)
ax_bottom_left.set_aspect('equal')

ax_bottom_mid = fig10.add_subplot(gs[2, 1])
rot_numbers = [rotation_number(G) for G in G_below]
ax_bottom_mid.plot(G_below, rot_numbers, 'cyan', linewidth=2)
ax_bottom_mid.plot([-1.0, -0.5, -0.3333], [rotation_number(-1.0), rotation_number(-0.5), rotation_number(-0.3333)], 'yo', markersize=8, label='Rational rotations')
ax_bottom_mid.axvline(x=-0.3333, color='yellow', linestyle='--', alpha=0.5)
ax_bottom_mid.text(-0.35, 0.6, 'Reflexive!', fontsize=8, c='yellow', weight='bold')
ax_bottom_mid.set_title('Rotation Numbers', fontsize=12, color='red')
ax_bottom_mid.set_xlabel('G', fontsize=10)
ax_bottom_mid.set_ylabel('θ/π', fontsize=10)
ax_bottom_mid.legend(fontsize=8)
ax_bottom_mid.grid(True, alpha=0.2)

ax_bottom_right = fig10.add_subplot(gs[2, 2])
G_cf = [-0.2, -0.3, -0.5, -1.0]
cf_types = ['Converges', 'Cycle 12', 'Cycle 4', 'Cycle 3']
cf_colors = ['green', 'orange', 'red', 'darkred']
bars = ax_bottom_right.barh(range(len(G_cf)), [1]*len(G_cf), color=cf_colors, alpha=0.7)
for i, (bar, g, label) in enumerate(zip(bars, G_cf, cf_types)):
    ax_bottom_right.text(0.5, i, f'G={g}\n{label}', ha='center', va='center', fontsize=9, c='white', weight='bold')
ax_bottom_right.set_yticks(range(len(G_cf)))
ax_bottom_right.set_yticks([])
ax_bottom_right.set_xlim(0, 1)
ax_bottom_right.set_xticks([])
ax_bottom_right.set_title('Continued Fractions', fontsize=12, color='red')
ax_bottom_right.text(0.5, -1.3, 'BELOW -1/4: Rotating', ha='center', fontsize=12, c='red', weight='bold')

plt.savefig('visualizations/fig10_three_realms.png', dpi=300, bbox_inches='tight')
plt.close()
print("  ✓ Saved: fig10_three_realms.png")

print("\n" + "="*70)
print("ALL VISUALIZATIONS CREATED SUCCESSFULLY!")
print("="*70)
print("\nGenerated 10 comprehensive figures:")
print("1. Root Trajectories (complex plane)")
print("2. Van Hove Singularity (density of states)")
print("3. Dynamics (Mandelbrot + Logistic map)")
print("4. Rotation Numbers (indexing gaps)")
print("5. Reflexive Ladder (self-referential gaps)")
print("6. Growth Rates (random gaps)")
print("7. Universal Boundary Summary")
print("8. Catalan Asymptotics")
print("9. Chirality Across Carriers")
print("10. Three Realms (above/at/below -1/4)")
print("\nAll figures saved to: visualizations/ directory")
print("="*70)