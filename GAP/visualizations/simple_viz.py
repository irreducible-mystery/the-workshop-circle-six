#!/usr/bin/env python3
"""Simple and robust version of GAP visualizations"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
import cmath
import math
import os

os.makedirs('visualizations', exist_ok=True)
plt.style.use('dark_background')

def gap_roots(G):
    disc = 1 + 4*G
    if disc >= 0:
        sqrt_disc = math.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2
    else:
        sqrt_disc = cmath.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2

def rotation_number(G):
    if G >= -1/4:
        return None
    nu = math.sqrt(-(G + 0.25))
    s_plus = 0.5 + 1j*nu
    theta = cmath.phase(s_plus)
    return theta / math.pi

print("Creating 10 comprehensive visualizations...")

# FIGURE 1: Root Trajectories
print("\n[1/10] Root trajectories...")
fig1, (ax1a, ax1b) = plt.subplots(1, 2, figsize=(16, 7))
fig1.suptitle('Root Trajectories: The Collision at G = -1/4', fontsize=16, color='#FFD700', weight='bold')

G_vals_real = np.linspace(-0.24, 2, 150)
roots_plus = []
roots_minus = []
for G in G_vals_real:
    rp, rm = gap_roots(G)
    roots_plus.append(rp.real)
    roots_minus.append(rm.real)

ax1a.plot(roots_plus, np.zeros_like(roots_plus), 'c-', linewidth=2, label='s_+ (upper)', alpha=0.8)
ax1a.plot(roots_minus, np.zeros_like(roots_minus), 'm-', linewidth=2, label='s_- (lower)', alpha=0.8)
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

ax1b.plot(ring_plus_real, ring_plus_imag, 'c-', linewidth=2.5, alpha=0.8, label='s_+ (upper half-plane)')
ax1b.plot(ring_minus_real, ring_minus_imag, 'm-', linewidth=2.5, alpha=0.8, label='s_- (lower half-plane)')
circle = Circle((0.5, 0), 0.8660254, fill=False, edgecolor='white', linestyle='--', linewidth=1, alpha=0.3, label='radius = sqrt(3)/2')
ax1b.add_patch(circle)
ax1b.plot(0.5, 0, 'y*', markersize=20, markeredgecolor='white', markeredgewidth=1, label='Branch: G = -1/4', zorder=10)
ax1b.set_xlabel('Real Part', fontsize=12)
ax1b.set_ylabel('Imaginary Part', fontsize=12)
ax1b.set_title('G < -1/4: Complex Conjugates Rotate', fontsize=13, color='#FFD700')
ax1b.legend(loc='upper right', fontsize=9)
ax1b.grid(True, alpha=0.2)
ax1b.set_aspect('equal')
ax1b.set_xlim(-0.5, 1.5)
ax1b.set_ylim(-1.5, 1.5)

plt.tight_layout()
plt.savefig('visualizations/fig1_root_trajectories.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig1_root_trajectories.png")

# FIGURE 2: Van Hove Singularity
print("\n[2/10] Van Hove singularity...")
fig2, (ax2a, ax2b) = plt.subplots(1, 2, figsize=(16, 7))
fig2.suptitle('Singularities: Van Hove and Density of States', fontsize=16, color='#FFD700', weight='bold')

g_vals = np.linspace(-0.2499, 0, 300)
rho_vals = []
for g in g_vals:
    rho = 1 / math.sqrt(max(1 + 4*g, 1e-10)) if g >= -0.25 else np.nan
    rho_vals.append(rho)

ax2a.plot(g_vals, rho_vals, 'cyan', linewidth=2.5, label='rho(g) = (1+4g)^(-1/2)')
ax2a.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax2a.text(-0.255, max(rho_vals)*0.8, 'G = -1/4', rotation=90, ha='right', va='center', c='yellow', fontsize=12, weight='bold')
ax2a.text(-0.24, max(rho_vals)*0.3, 'rho(g) ~ (g+1/4)^(-1/2)', fontsize=11, c='yellow', weight='bold')
ax2a.text(-0.24, max(rho_vals)*0.22, 'Van Hove singularity', fontsize=9, c='white', style='italic')
ax2a.set_xlabel('Gap G', fontsize=12)
ax2a.set_ylabel('Density of States', fontsize=12)
ax2a.set_title('Divergence at the Band Edge', fontsize=13, color='#FFD700')
ax2a.legend(loc='upper right', fontsize=10)
ax2a.grid(True, alpha=0.2)
ax2a.set_ylim(0, max(rho_vals)*1.1)

t_vals = np.linspace(0, 1, 200)
g_operator = [t**2 - t for t in t_vals]
ax2b.plot(t_vals, g_operator, 'magenta', linewidth=2.5, label='G = t^2 - t')
ax2b.fill_between(t_vals, g_operator, alpha=0.3, color='magenta')
min_idx = np.argmin(g_operator)
ax2b.plot(t_vals[min_idx], g_operator[min_idx], 'y*', markersize=20, markeredgecolor='white', markeredgewidth=1, label='Ground: G = -1/4', zorder=10)
ax2b.text(0.5, -0.35, 'G = A^2 - A (self-adjoint A)', ha='center', fontsize=11, c='white')
ax2b.text(0.5, -0.42, 'G >= -1/4 (greatest lower bound)', ha='center', fontsize=10, c='yellow', weight='bold')
ax2b.text(0.5, -0.5, 'Below -1/4: unobservable', ha='center', fontsize=9, c='cyan', style='italic')
ax2b.set_xlabel('t (operator eigenvalue)', fontsize=12)
ax2b.set_ylabel('G', fontsize=12)
ax2b.set_title('Operator Theory: G >= -1/4', fontsize=13, color='#FFD700')
ax2b.legend(loc='lower center', fontsize=10)
ax2b.grid(True, alpha=0.2)
ax2b.axhline(y=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.5)

plt.tight_layout()
plt.savefig('visualizations/fig2_van_hove.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig2_van_hove.png")

# FIGURE 3: Dynamics
print("\n[3/10] Dynamics...")
fig3, (ax3a, ax3b) = plt.subplots(1, 2, figsize=(16, 7))
fig3.suptitle('Dynamics: Mandelbrot and Logistic Windows', fontsize=16, color='#FFD700', weight='bold')

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
ax3a.set_title('Mandelbrot: Stability Window', fontsize=13, color='#FFD700')
ax3a.grid(True, alpha=0.2)

r_vals = np.linspace(0, 4, 100)
g_from_r = [r**2/4 - r/2 for r in r_vals]
ax3b.plot(r_vals, g_from_r, 'cyan', linewidth=2.5)
ax3b.axvspan(1, 3, alpha=0.2, color='green', label='Stable fixed point')
ax3b.axvline(x=1, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax3b.axvline(x=3, color='orange', linestyle='--', linewidth=2, alpha=0.7)
ax3b.set_xlabel('Logistic parameter r', fontsize=12)
ax3b.set_ylabel('Gap G', fontsize=12)
ax3b.set_title('Logistic Map Conjugacy', fontsize=13, color='#FFD700')
ax3b.legend(loc='upper right', fontsize=9)
ax3b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig3_dynamics.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig3_dynamics.png")

# FIGURE 4: Rotation Numbers
print("\n[4/10] Rotation numbers...")
fig4, (ax4a, ax4b) = plt.subplots(1, 2, figsize=(16, 7))
fig4.suptitle('Below -1/4: Rotation Number Indexing', fontsize=16, color='#FFD700', weight='bold')

G_rot = np.linspace(-2.0, -0.26, 150)
rot_numbers = [rotation_number(G) for G in G_rot]
ax4a.plot(G_rot, rot_numbers, 'cyan', linewidth=2.5, label='theta/pi = rotation number')
rationals = [(3, -1.0, '1/3'), (4, -0.5, '1/4'), (6, -0.33333333, '1/6'), (8, -0.29289322, '1/8'), (12, -0.26794919, '1/12')]
for period, G, label in rationals:
    rot = rotation_number(G)
    ax4a.plot(G, rot, 'yo', markersize=10, markeredgecolor='white', markeredgewidth=1, zorder=10)
    ax4a.text(G, rot + 0.05, f'{label} -> period {period}', ha='center', fontsize=9, c='yellow')
ax4a.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax4a.axhline(y=0, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax4a.set_xlabel('Gap G', fontsize=12)
ax4a.set_ylabel('Rotation Number theta/pi', fontsize=12)
ax4a.set_title('Rotation Number Indexing (G < -1/4)', fontsize=13, color='#FFD700')
ax4a.legend(loc='upper left', fontsize=10)
ax4a.grid(True, alpha=0.2)

G_cf = np.linspace(-2.0, -0.26, 80)
cf_rot = [rotation_number(G) for G in G_cf]
ax4b.plot(G_cf, cf_rot, 'cyan', linewidth=2, alpha=0.5)
g_neg_third = -1/3
rot_neg_third = rotation_number(g_neg_third)
ax4b.plot(g_neg_third, rot_neg_third, 'y*', markersize=20, markeredgecolor='white', markeredgewidth=1, label='G = -1/3', zorder=15)
ax4b.text(g_neg_third, rot_neg_third + 0.05, 'Reflexive!', ha='center', fontsize=10, c='yellow', weight='bold')
ax4b.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.5)
ax4b.set_xlabel('Gap G', fontsize=12)
ax4b.set_ylabel('Rotation Number', fontsize=12)
ax4b.set_title('Rotation Numbers vs G', fontsize=13, color='#FFD700')
ax4b.legend(loc='upper left', fontsize=9)
ax4b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig4_rotation_numbers.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig4_rotation_numbers.png")

# FIGURE 5: Reflexive Ladder
print("\n[5/10] Reflexive ladder...")
fig5, ax5 = plt.subplots(1, 1, figsize=(14, 8))
fig5.suptitle('The Reflexive Ladder: Six Self-Referential Gaps', fontsize=16, color='#FFD700', weight='bold')

reflexive_gaps = [
    (-1/3, 'G = -1/3', 'Equals discriminant'),
    (-1/4, 'G = -1/4', 'Equals branch point'),
    (0, 'G = 0', 'Equals product'),
    (1, 'G = 1', 'Equals sum (golden)'),
    (2, 'G = 2', 'Is a root'),
    (4.236067977, 'G = phi^3', 'Equals difference'),
]

y_base = 0.5
for g, label, desc in reflexive_gaps:
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
    ax5.text(g, y_base - 0.2, desc, ha='center', fontsize=9, c='white')

ax5.axhline(y=y_base, color='white', linewidth=3, alpha=0.5)
ax5.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2, alpha=0.5)
ax5.set_xlabel('Gap G', fontsize=12)
ax5.set_ylim(-0.3, 1.2)
ax5.set_xlim(-0.5, 5)
ax5.set_yticks([])
ax5.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig5_reflexive_ladder.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig5_reflexive_ladder.png")

# FIGURE 6: Growth Rates
print("\n[6/10] Growth rates...")
fig6, (ax6a, ax6b) = plt.subplots(1, 2, figsize=(16, 7))
fig6.suptitle('Random Gaps: Three Growth Rates', fontsize=16, color='#FFD700', weight='bold')

growth_rates = {
    'Det G=+1': 1.618034,
    'Det G=-1': 1.0,
    'Viswanath': 1.131988,
    'Annealed 1st': 1.0,
    'Annealed 2nd': 1.272020,
}
colors = ['cyan', 'magenta', 'yellow', 'green', 'orange']
bars = ax6a.barh(range(len(growth_rates)), list(growth_rates.values()), color=colors, alpha=0.8, edgecolor='white')
for i, (rate, bar) in enumerate(zip(growth_rates.values(), bars)):
    ax6a.text(bar.get_width() + 0.02, bar.get_y() + bar.get_height()/2, f'{rate:.6f}', 
             ha='left', va='center', fontsize=10, c='white', weight='bold')
ax6a.set_yticks(range(len(growth_rates)))
ax6a.set_yticklabels(list(growth_rates.keys()), fontsize=10)
ax6a.set_xlabel('Growth Rate', fontsize=12)
ax6a.set_title('Different Questions, Different Answers', fontsize=13, color='#FFD700')
ax6a.grid(True, alpha=0.2, axis='x')

p_vals = np.linspace(0, 1, 100)
growth_vs_p = [math.exp(p * math.log(3) + (1-p) * 0.5 * math.log(5)) for p in p_vals]
ax6b.plot(p_vals, growth_vs_p, 'cyan', linewidth=2.5)
for p in [0, 0.5, 1]:
    growth = math.exp(p * math.log(3) + (1-p) * 0.5 * math.log(5))
    ax6b.plot(p, growth, 'yo', markersize=10, markeredgecolor='white', markeredgewidth=1, zorder=10)
ax6b.axhline(y=1.0, color='magenta', linestyle='--', linewidth=2, alpha=0.5)
ax6b.axhline(y=1.618034, color='cyan', linestyle='--', linewidth=2, alpha=0.3)
ax6b.set_xlabel('Probability p of G = +1', fontsize=12)
ax6b.set_ylabel('Growth Rate', fontsize=12)
ax6b.set_title('Tilted Mixtures', fontsize=13, color='#FFD700')
ax6b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig6_growth_rates.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig6_growth_rates.png")

# FIGURE 7: Universal Boundary
print("\n[7/10] Universal boundary...")
fig7, ax7 = plt.subplots(1, 1, figsize=(16, 12))
fig7.suptitle('G = -1/4: The Universal Boundary', fontsize=18, color='#FFD700', weight='bold')

manifestations = [
    (0.9, 'Branch Point'),
    (1.7, 'Spectral Edge'),
    (2.5, 'Operator Bound'),
    (3.3, 'Rotation Zero'),
    (4.1, 'Bifurcation'),
    (4.9, 'Catalan Radius'),
    (5.7, 'Chirality Collapse'),
    (6.5, 'Universal Answer'),
]

for i, (radius, title) in enumerate(manifestations):
    angle = math.pi/2 + (i * 0.2)
    x = 7 + radius * math.cos(angle)
    y = 6 + radius * math.sin(angle)
    circle = Circle((7, 6), radius, fill=False, edgecolor='cyan', 
                   linestyle='--' if i % 2 == 0 else '-', linewidth=1.5, alpha=0.6)
    ax7.add_patch(circle)
    ax7.text(x, y, title, ha='center', fontsize=10, c='yellow', weight='bold')

ax7.plot(7, 6, 'y*', markersize=30, markeredgecolor='white', markeredgewidth=2, zorder=10)
ax7.text(7, 6.4, 'G = -1/4', ha='center', fontsize=14, c='yellow', weight='bold')
ax7.text(7, 5.6, 'THE UNIVERSAL BOUNDARY', ha='center', fontsize=11, c='white', style='italic')
ax7.set_xlim(0, 14)
ax7.set_ylim(0, 12)
ax7.set_aspect('equal')
ax7.set_xticks([])
ax7.set_yticks([])
ax7.grid(True, alpha=0.1)
ax7.text(7, -0.5, 'The same number, everywhere.', ha='center', fontsize=12, c='yellow', style='italic', weight='bold')

plt.tight_layout()
plt.savefig('visualizations/fig7_universal_boundary.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig7_universal_boundary.png")

# FIGURE 8: Catalan Asymptotics
print("\n[8/10] Catalan asymptotics...")
fig8, (ax8a, ax8b) = plt.subplots(1, 2, figsize=(16, 7))
fig8.suptitle('Catalan: Branch Point in Asymptotics', fontsize=16, color='#FFD700', weight='bold')

n_vals = np.arange(0, 15)
catalan = [math.comb(2*n, n) // (n + 1) for n in n_vals]
partial_sums = []
for n in n_vals:
    s = sum(catalan[k] * (0.25)**k for k in range(n+1))
    partial_sums.append(s)

ax8a.plot(n_vals, partial_sums, 'cyan', linewidth=2.5, marker='o', markersize=8, label='Partial sums at G=-1/4')
ax8a.axhline(y=0.5, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax8a.text(1, 0.52, 'Expected: 1/2', fontsize=10, c='yellow', weight='bold')
ax8a.set_xlabel('Number of terms n', fontsize=12)
ax8a.set_ylabel('Partial sum', fontsize=12)
ax8a.set_title('Catalan Series (on radius)', fontsize=13, color='#FFD700')
ax8a.legend(loc='upper right', fontsize=10)
ax8a.grid(True, alpha=0.2)

ratios = [catalan[n] / catalan[n-1] if n > 0 else 0 for n in n_vals[1:]]
ax8b.plot(n_vals[1:], ratios, 'cyan', linewidth=2.5, marker='o', markersize=8)
ax8b.axhline(y=4, color='yellow', linestyle='--', linewidth=2, alpha=0.7)
ax8b.text(12, 4.1, '-> 4 = 1/(1/4)', fontsize=11, c='yellow', weight='bold')
ax8b.set_xlabel('n', fontsize=12)
ax8b.set_ylabel('Ratio C_n / C_{n-1}', fontsize=12)
ax8b.set_title('Catalan Ratio -> Branch Position', fontsize=13, color='#FFD700')
ax8b.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('visualizations/fig8_catalan_asymptotics.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig8_catalan_asymptotics.png")

# FIGURE 9: Chirality Across Carriers
print("\n[9/10] Chirality carriers...")
fig9, ax9 = plt.subplots(1, 1, figsize=(14, 10))
fig9.suptitle('Can You Tell Yourself Apart From Yourself?', fontsize=16, color='#FFD700', weight='bold')

carriers = [
    ("Char 2 field", "Cannot", "x = -x always", "red"),
    ("Complex numbers", "Always", "Opposite imaginary", "cyan"),
    ("Quaternions", "Collapse", "Sphere -> point", "green"),
    ("Octonions", "Collapse", "6-sphere -> point", "green"),
    ("Sedenions", "Collapse", "(zero divisors OK)", "yellow"),
    ("Max-plus", "One root", "Single branch", "magenta"),
    ("Min-plus", "One root", "Opposite branch", "magenta"),
    ("Dual numbers", "Obstructed", "At branch point", "orange"),
    ("M2(R)", "Unique", "Scalar solution", "green"),
    ("Reals", "Distinguishable", "Above -1/4", "cyan"),
]

n_carriers = len(carriers)
for i, (carrier, behavior, desc, color) in enumerate(carriers):
    y = n_carriers - i - 0.5
    ax9.text(-0.5, y, carrier, ha='right', va='center', fontsize=10, c='white', weight='bold')
    ax9.text(0, y, behavior, ha='left', va='center', fontsize=12, c=color, weight='bold')
    ax9.text(3, y, desc, ha='left', va='center', fontsize=9, c='white', alpha=0.7)

ax9.axvline(x=6.5, color='yellow', linestyle='--', linewidth=1, alpha=0.5)
ax9.text(-0.5, -1, 'ANSWER IS CARRIER-DEPENDENT', ha='right', fontsize=11, c='yellow', weight='bold')
ax9.text(3, -1, 'Can you tell yourself apart?', ha='left', fontsize=11, c='yellow', weight='bold')
ax9.set_xlim(-0.5, 12)
ax9.set_ylim(-2, n_carriers)
ax9.set_yticks([])
ax9.grid(True, alpha=0.1)

plt.tight_layout()
plt.savefig('visualizations/fig9_chirality_carriers.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig9_chirality_carriers.png")

# FIGURE 10: Three Realms
print("\n[10/10] Three realms...")
fig10 = plt.figure(figsize=(18, 12))
gs = fig10.add_gridspec(3, 3, hspace=0.3, wspace=0.3)
fig10.suptitle('The Three Realms of the GAP Equation', fontsize=20, color='#FFD700', weight='bold')

# Top: Above -1/4
ax_top = fig10.add_subplot(gs[0, :])
G_above = np.linspace(-0.24, 2, 200)
solutions_above_real = [[gap_roots(G)[0].real, gap_roots(G)[1].real] for G in G_above]
solutions_above_real = np.array(solutions_above_real)

ax_top.plot(G_above, solutions_above_real[:, 0], 'cyan', linewidth=2, label='s_+')
ax_top.plot(G_above, solutions_above_real[:, 1], 'magenta', linewidth=2, label='s_-')
ax_top.fill_between(G_above, solutions_above_real[:, 0], solutions_above_real[:, 1], alpha=0.1, color='green')
ax_top.axvline(x=-0.25, color='yellow', linestyle='--', linewidth=2)
ax_top.set_title('ABOVE -1/4: Counting Realm (Two Real Roots)', fontsize=14, color='green')
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
ax_mid.text(0, -0.1, 'Derivative = 0', ha='center', fontsize=11, c='orange')
ax_mid.text(0, -0.3, 'All carriers meet here', ha='center', fontsize=11, c='magenta')
ax_mid.set_ylim(-0.5, 0.7)
ax_mid.set_xlim(-1, 1)
ax_mid.set_xticks([])
ax_mid.set_yticks([])
ax_mid.set_title('AT -1/4: Everything Meets', fontsize=14, color='yellow')

# Bottom: Below -1/4
ax_bottom_left = fig10.add_subplot(gs[2, 0])
G_below = np.linspace(-2.0, -0.26, 150)
ring_real = [[gap_roots(G)[0].real, gap_roots(G)[1].real] for G in G_below]
ring_imag = [[gap_roots(G)[0].imag, gap_roots(G)[1].imag] for G in G_below]
ring_real = np.array(ring_real)
ring_imag = np.array(ring_imag)

ax_bottom_left.plot(ring_real[:, 0], ring_imag[:, 0], 'cyan', linewidth=2, label='s_+')
ax_bottom_left.plot(ring_real[:, 1], ring_imag[:, 1], 'magenta', linewidth=2, label='s_-')
circle_unity = Circle((0.5, 0), 0.8660254, fill=False, edgecolor='white', linestyle='--', alpha=0.5)
ax_bottom_left.add_patch(circle_unity)
ax_bottom_left.plot(0.5, 0, 'y*', markersize=15)
ax_bottom_left.set_title('Root Trajectories', fontsize=12, color='red')
ax_bottom_left.set_xlabel('Real', fontsize=10)
ax_bottom_left.grid(True, alpha=0.2)
ax_bottom_left.set_aspect('equal')

ax_bottom_mid = fig10.add_subplot(gs[2, 1])
rot_numbers = [rotation_number(G) for G in G_below]
ax_bottom_mid.plot(G_below, rot_numbers, 'cyan', linewidth=2)
ax_bottom_mid.plot([-1.0, -0.5, -0.3333], [rotation_number(-1.0), rotation_number(-0.5), rotation_number(-0.3333)], 
                  'yo', markersize=8)
ax_bottom_mid.set_title('Rotation Numbers', fontsize=12, color='red')
ax_bottom_mid.set_xlabel('G', fontsize=10)
ax_bottom_mid.grid(True, alpha=0.2)

ax_bottom_right = fig10.add_subplot(gs[2, 2])
G_cf = [-0.2, -0.3, -0.5, -1.0]
cf_types = ['Converges', 'Cycle 12', 'Cycle 4', 'Cycle 3']
cf_colors = ['green', 'orange', 'red', 'darkred']
ax_bottom_right.barh(range(len(G_cf)), [1]*len(G_cf), color=cf_colors, alpha=0.7)
for i, (g, label) in enumerate(zip(G_cf, cf_types)):
    ax_bottom_right.text(0.5, i, f'G={g}\n{label}', ha='center', va='center', fontsize=9, c='white', weight='bold')
ax_bottom_right.set_xlim(0, 1)
ax_bottom_right.set_yticks([])
ax_bottom_right.set_xticks([])
ax_bottom_right.set_title('Continued Fractions', fontsize=12, color='red')

plt.savefig('visualizations/fig10_three_realms.png', dpi=300, bbox_inches='tight')
plt.close()
print("  Saved fig10_three_realms.png")

print("\n" + "="*70)
print("ALL 10 VISUALIZATIONS CREATED!")
print("="*70)
print("\nFigures saved in: visualizations/")
print("1. Root trajectories")
print("2. Van Hove singularity")
print("3. Dynamics (Mandelbrot + Logistic)")
print("4. Rotation numbers")
print("5. Reflexive ladder")
print("6. Growth rates")
print("7. Universal boundary")
print("8. Catalan asymptotics")
print("9. Chirality across carriers")
print("10. Three realms")
print("="*70)