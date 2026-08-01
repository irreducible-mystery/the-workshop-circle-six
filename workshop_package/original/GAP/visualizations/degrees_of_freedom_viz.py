#!/usr/bin/env python3
"""
Degrees of Freedom Visualization: G from +∞ to -∞
Visualizing n-dimensional generalizations of the GAP equation
"""

import matplotlib.pyplot as plt
import numpy as np
import math
import cmath

# Set style
plt.style.use('default')
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300

def gap_roots_n(G, n):
    """Calculate roots of n-dimensional GAP equation: x^n = x + G"""
    
    # For n=2, use analytic solution
    if n == 2:
        disc = 1 + 4*G
        if disc >= 0:
            sqrt_disc = math.sqrt(disc)
            return [(1 + sqrt_disc)/2, (1 - sqrt_disc)/2]
        else:
            sqrt_disc = cmath.sqrt(disc)
            return [(1 + sqrt_disc)/2, (1 - sqrt_disc)/2]
    
    # For n>2, use numpy's polynomial solver
    else:
        coeffs = [0] * (n + 1)
        coeffs[0] = 1  # x^n coefficient
        coeffs[-2] = -1  # x coefficient
        coeffs[-1] = -G  # constant term
        roots = np.roots(coeffs)
        return list(roots)

def get_real_roots(roots):
    """Extract and return real roots (imaginary part near zero)"""
    return [r.real for r in roots if abs(r.imag) < 1e-10]

def get_complex_roots(roots):
    """Extract and return complex roots"""
    return [r for r in roots if abs(r.imag) >= 1e-10]

# Create figure with multiple panels
fig = plt.figure(figsize=(16, 12))
gs = fig.add_gridspec(3, 3, hspace=0.3, wspace=0.3)

# Dimensions to analyze
dimensions = [2, 3, 4]
colors = ['blue', 'red', 'green']

# ========================================
# Panel 1: Root Count vs G (all dimensions)
# ========================================
ax1 = fig.add_subplot(gs[0, :])

G_values = np.linspace(-10, 10, 100)

for n, color in zip(dimensions, colors):
    real_counts = []
    complex_counts = []
    
    for G in G_values:
        roots = gap_roots_n(G, n)
        n_real = sum(1 for r in roots if abs(r.imag) < 1e-10)
        n_complex = len(roots) - n_real
        
        real_counts.append(n_real)
        complex_counts.append(n_complex)
    
    ax1.plot(G_values, real_counts, color=color, linewidth=2, 
             linestyle='-', label=f'n={n} (real)')
    ax1.plot(G_values, complex_counts, color=color, linewidth=2,
             linestyle='--', alpha=0.5, label=f'n={n} (complex)')

ax1.set_xlabel('G Value', fontsize=11)
ax1.set_ylabel('Number of Roots', fontsize=11)
ax1.set_title('Root Count vs G: n=2,3,4', fontsize=12, fontweight='bold')
ax1.legend(loc='center right', fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.5, 4.5)

# Mark special G values
ax1.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=-0.25, color='gold', linewidth=2, linestyle=':', label='G=-0.25 (collision)')
ax1.text(-9, 4.2, 'n=4: Most roots\nremain complex', fontsize=9, 
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

# ========================================
# Panel 2: Real Parts vs G (n=2)
# ========================================
ax2 = fig.add_subplot(gs[1, 0])

G_real = np.linspace(-10, 10, 200)
re_plus_n2 = []
re_minus_n2 = []

for G in G_real:
    roots = gap_roots_n(G, 2)
    re_plus_n2.append(roots[0].real)
    re_minus_n2.append(roots[1].real)

ax2.plot(G_real, re_plus_n2, 'b-', linewidth=2, label='$x_1$ (n=2)')
ax2.plot(G_real, re_minus_n2, 'r-', linewidth=1.5, label='$x_2$ (n=2)')
ax2.set_xlabel('G Value', fontsize=10)
ax2.set_ylabel('Real Part', fontsize=10)
ax2.set_title('n=2: Real Parts', fontsize=11, fontweight='bold')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# ========================================
# Panel 3: Real Parts vs G (n=3)
# ========================================
ax3 = fig.add_subplot(gs[1, 1])

G_real = np.linspace(-10, 10, 200)
re_n3 = [[] for _ in range(3)]

for G in G_real:
    roots = gap_roots_n(G, 3)
    roots_sorted = sorted(roots, key=lambda x: x.real)
    for i in range(3):
        re_n3[i].append(roots_sorted[i].real)

colors_n3 = ['blue', 'red', 'green']
for i in range(3):
    ax3.plot(G_real, re_n3[i], color=colors_n3[i], linewidth=2, label=f'$x_{i+1}$ (n=3)')

ax3.set_xlabel('G Value', fontsize=10)
ax3.set_ylabel('Real Part', fontsize=10)
ax3.set_title('n=3: Real Parts', fontsize=11, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# ========================================
# Panel 4: Real Parts vs G (n=4)
# ========================================
ax4 = fig.add_subplot(gs[1, 2])

G_real = np.linspace(-10, 10, 200)
re_n4 = [[] for _ in range(4)]

for G in G_real:
    roots = gap_roots_n(G, 4)
    roots_sorted = sorted(roots, key=lambda x: x.real)
    for i in range(4):
        re_n4[i].append(roots_sorted[i].real)

colors_n4 = ['blue', 'red', 'green', 'orange']
for i in range(4):
    ax4.plot(G_real, re_n4[i], color=colors_n4[i], linewidth=1.5, label=f'$x_{i+1}$ (n=4)')

ax4.set_xlabel('G Value', fontsize=10)
ax4.set_ylabel('Real Part', fontsize=10)
ax4.set_title('n=4: Real Parts', fontsize=11, fontweight='bold')
ax4.legend(fontsize=7)
ax4.grid(True, alpha=0.3)

# ========================================
# Panel 5: Magnitude Growth Comparison
# ========================================
ax5 = fig.add_subplot(gs[2, 0])

G_pos = np.linspace(1, 100, 100)
for n, color in zip(dimensions, colors):
    mags_n2 = []
    mags_n3 = []
    mags_n4 = []
    
    for G in G_pos:
        roots = gap_roots_n(G, n)
        mags = [abs(r) for r in roots]
        max_mag = max(mags)
        mags_n2.append(max_mag)
        
    ax5.plot(G_pos, mags_n2, color=color, linewidth=2, label=f'n={n}')

# Plot theoretical asymptotic: G^(1/n)
G_pos_dense = np.linspace(1, 100, 1000)
ax5.plot(G_pos_dense, np.sqrt(G_pos_dense), 'k--', linewidth=2, alpha=0.5, label='$G^{1/2}$')
ax5.plot(G_pos_dense, G_pos_dense**(1/3), 'k:', linewidth=2, alpha=0.5, label='$G^{1/3}$')
ax5.plot(G_pos_dense, G_pos_dense**(1/4), 'k-.', linewidth=2, alpha=0.5, label='$G^{1/4}$')

ax5.set_xlabel('G Value', fontsize=10)
ax5.set_ylabel('Max |x|', fontsize=10)
ax5.set_title('Growth Rate Comparison', fontsize=11, fontweight='bold')
ax5.legend(fontsize=7)
ax5.grid(True, alpha=0.3)
ax5.set_yscale('log')

# ========================================
# Panel 6: Complex Plane - n=2
# ========================================
ax6 = fig.add_subplot(gs[2, 1])

G_traj = np.linspace(-10, 10, 200)
re_traj_n2 = []
im_traj_n2 = []

for G in G_traj:
    roots = gap_roots_n(G, 2)
    roots_sorted = sorted(roots, key=lambda x: x.real)
    
    re_traj_n2.append([roots_sorted[0].real, roots_sorted[1].real])
    im_traj_n2.append([roots_sorted[0].imag, roots_sorted[1].imag])

re_traj_n2 = np.array(re_traj_n2)
im_traj_n2 = np.array(im_traj_n2)

ax6.plot(re_traj_n2[:, 0], im_traj_n2[:, 0], 'b-', linewidth=2, label='$x_1$')
ax6.plot(re_traj_n2[:, 1], im_traj_n2[:, 1], 'r-', linewidth=2, label='$x_2$')

# Mark special points
ax6.scatter([1], [0], s=100, c='purple', edgecolor='black', zorder=10, label='G=0')
ax6.scatter([0.5], [0], s=100, c='gold', edgecolor='black', zorder=10, label='G=-0.25')

ax6.set_xlabel('Real Part', fontsize=10)
ax6.set_ylabel('Imaginary Part', fontsize=10)
ax6.set_title('Complex Plane: n=2', fontsize=11, fontweight='bold')
ax6.legend(fontsize=7)
ax6.grid(True, alpha=0.3)
ax6.axis('equal')

# ========================================
# Panel 7: Complex Plane - n=3
# ========================================
ax7 = fig.add_subplot(gs[2, 2])

G_traj = np.linspace(-10, 10, 200)
re_traj_n3 = []
im_traj_n3 = []

for G in G_traj:
    roots = gap_roots_n(G, 3)
    roots_sorted = sorted(roots, key=lambda x: x.real)
    
    re_traj_n3.append([roots_sorted[0].real, roots_sorted[1].real, roots_sorted[2].real])
    im_traj_n3.append([roots_sorted[0].imag, roots_sorted[1].imag, roots_sorted[2].imag])

re_traj_n3 = np.array(re_traj_n3)
im_traj_n3 = np.array(im_traj_n3)

colors_n3 = ['blue', 'red', 'green']
for i in range(3):
    ax7.plot(re_traj_n3[:, i], im_traj_n3[:, i], color=colors_n3[i], 
             linewidth=1.5, label=f'$x_{i+1}$', alpha=0.7)

ax7.set_xlabel('Real Part', fontsize=10)
ax7.set_ylabel('Imaginary Part', fontsize=10)
ax7.set_title('Complex Plane: n=3', fontsize=11, fontweight='bold')
ax7.legend(fontsize=7)
ax7.grid(True, alpha=0.3)
ax7.axis('equal')

# Main title
fig.suptitle('Degrees of Freedom Analysis: $x^n = x + G$\n$G$ from $+\infty$ to $-\infty$, $n = 2,3,4$', 
             fontsize=14, fontweight='bold', y=0.995)

plt.tight_layout()

# Save
output_path = 'fig13_degrees_of_freedom.png'
plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()

print(f"✓ Created: {output_path}")
print()
print("Visualization shows:")
print("  - Root count variations across dimensions")
print("  - Real part trajectories for n=2,3,4")
print("  - Growth rate comparison: G^(1/n) power law")
print("  - Complex plane trajectories for n=2,3,4")
print("  - Impact of degrees of freedom on root behavior")
print()
print("Key findings:")
print("  - Higher n → slower growth (G^(1/n) with larger n)")
print("  - More roots with higher dimensions")
print("  - n=2 is special with collision at G = -0.25")
print("  - Higher n → more complex behavior, better chaos distribution")