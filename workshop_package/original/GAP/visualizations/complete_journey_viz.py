#!/usr/bin/env python3
"""
Complete Journey Visualization: G from +∞ to -∞
Visualizing the complete mathematical structure of the GAP equation
"""

import matplotlib.pyplot as plt
import numpy as np
import math
import cmath

# Set style
plt.style.use('default')
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300

def gap_roots(G):
    """Calculate roots of the GAP equation x² = x + G"""
    disc = 1 + 4*G
    if disc >= 0:
        sqrt_disc = math.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2
    else:
        sqrt_disc = cmath.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2

# Create figure with multiple panels
fig = plt.figure(figsize=(16, 12))
gs = fig.add_gridspec(3, 3, hspace=0.3, wspace=0.3)

# ========================================
# Panel 1: Root Trajectories (Real parts) - Main
# ========================================
ax1 = fig.add_subplot(gs[0, :2])

# Real roots (G >= -0.25)
G_real = np.linspace(-0.25, 10, 1000)
s_plus_real = []
s_minus_real = []
for G in G_real:
    sp, sm = gap_roots(G)
    s_plus_real.append(sp)
    s_minus_real.append(sm)

# Complex roots: show real parts (always 0.5)
G_complex = np.linspace(-10, -0.25, 500)
real_part_complex = [0.5] * len(G_complex)

# Plot real domain
ax1.plot(G_real, s_plus_real, 'b-', linewidth=2, label='$s_+$ (real domain)')
ax1.plot(G_real, s_minus_real, 'r-', linewidth=2, label='$s_-$ (real domain)')

# Plot collision point
ax1.plot([-0.25], [0.5], 'o', color='gold', markersize=12, markeredgecolor='black', 
         linewidth=2, label='Collision', zorder=5)

# Mark special G values
ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=1, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=2, color='gray', linestyle='--', alpha=0.5)

ax1.scatter([0], [1], s=100, c='orange', edgecolor='black', zorder=10, label='Pure counting')
ax1.scatter([1], [1.618], s=100, c='purple', edgecolor='black', zorder=10, label='Golden ratio')
ax1.scatter([2], [2], s=100, c='green', edgecolor='black', zorder=10, label='Integer')

ax1.set_xlabel('G Value', fontsize=11)
ax1.set_ylabel('Real Part', fontsize=11)
ax1.set_title('Root Trajectories: Real Part vs G', fontsize=12, fontweight='bold')
ax1.legend(loc='lower right', fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-10, 10)
ax1.set_ylim(-5, 5)

# Annotate realms
ax1.text(5, 3.5, 'Positive\nDomain', ha='center', va='center', 
         fontsize=10, bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.5))
ax1.text(-0.5, 1.2, 'Counting\nRealm', ha='center', va='center', 
         fontsize=10, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))
ax1.text(-5, 0.8, 'Rotating\nRealm\n(Re = 0.5)', ha='center', va='center', 
         fontsize=10, bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

# ========================================
# Panel 2: Root Trajectories (Imaginary parts)
# ========================================
ax2 = fig.add_subplot(gs[1, :2])

# Complex roots: imaginary parts
G_complex_plot = np.linspace(-10, -0.25, 500)
imag_plus_complex = []
imag_minus_complex = []
for G in G_complex_plot:
    sp, sm = gap_roots(G)
    imag_plus_complex.append(sp.imag)
    imag_minus_complex.append(sm.imag)

# Zero imaginary parts for real domain
G_real_plot = np.linspace(-0.25, 10, 500)
imag_real_zero = [0] * len(G_real_plot)

ax2.plot(G_real_plot, imag_real_zero, 'k-', linewidth=1, alpha=0.5, label='Real domain (Im = 0)')
ax2.plot(G_complex_plot, imag_plus_complex, 'b-', linewidth=2, label='$\Im[s_+]$ (rotating)')
ax2.plot(G_complex_plot, imag_minus_complex, 'r-', linewidth=2, label='$\Im[s_-]$ (rotating)')

# Mark collision point (imaginary part = 0)
ax2.plot([-0.25], [0], 'o', color='gold', markersize=12, markeredgecolor='black', 
         linewidth=2, label='Collision', zorder=5)

ax2.set_xlabel('G Value', fontsize=11)
ax2.set_ylabel('Imaginary Part', fontsize=11)
ax2.set_title('Root Trajectories: Imaginary Part vs G', fontsize=12, fontweight='bold')
ax2.legend(loc='upper right', fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-10, 10)
ax2.set_ylim(-5, 5)

# ========================================
# Panel 3: Magnitude Growth
# ========================================
ax3 = fig.add_subplot(gs[2, :2])

# Calculate magnitudes
G_plot_real = np.linspace(-0.25, 100, 1000)
mag_plus_real = []
mag_minus_real = []
for G in G_plot_real:
    sp, sm = gap_roots(G)
    mag_plus_real.append(abs(sp))
    mag_minus_real.append(abs(sm))

G_plot_complex = np.linspace(-100, -0.25, 1000)
mag_plus_complex = []
mag_minus_complex = []
for G in G_plot_complex:
    sp, sm = gap_roots(G)
    mag_plus_complex.append(abs(sp))
    mag_minus_complex.append(abs(sm))

ax3.plot(G_plot_real, mag_plus_real, 'b-', linewidth=2, label='$|s_+|$')
ax3.plot(G_plot_real, mag_minus_real, 'r-', linewidth=2, label='$|s_-|$')
ax3.plot(G_plot_complex, mag_plus_complex, 'b--', linewidth=2)
ax3.plot(G_plot_complex, mag_minus_complex, 'r--', linewidth=2, label='Rotating realm')

# Plot √|G| asymptotic
G_pos = np.linspace(1, 100, 100)
G_neg = np.linspace(-100, -1, 100)
ax3.plot(G_pos, np.sqrt(G_pos), 'k:', linewidth=2, alpha=0.7, label='$\sqrt{G}$ (asymptotic)')
ax3.plot(G_neg, np.sqrt(-G_neg), 'k:', linewidth=2, alpha=0.7)

# Mark collision point
ax3.plot([-0.25], [0.5], 'o', color='gold', markersize=12, markeredgecolor='black', 
         linewidth=2, zorder=5)

ax3.set_xlabel('G Value', fontsize=11)
ax3.set_ylabel('Magnitude $|s|$', fontsize=11)
ax3.set_title('Root Magnitude Growth: $|s_{\pm}|$ vs G', fontsize=12, fontweight='bold')
ax3.legend(loc='upper left', fontsize=8)
ax3.grid(True, alpha=0.3)
ax3.set_xlim(-100, 100)
ax3.set_ylim(0, 12)

# ========================================
# Panel 4: Complex Plane Trajectory
# ========================================
ax4 = fig.add_subplot(gs[0, 2])

# Plot root trajectories in complex plane
# Real domain (G from -0.25 to 10)
G_traj = np.linspace(-0.25, 10, 1000)
re_plus_traj = []
im_plus_traj = []
re_minus_traj = []
im_minus_traj = []
for G in G_traj:
    sp, sm = gap_roots(G)
    re_plus_traj.append(sp.real)
    im_plus_traj.append(sp.imag)
    re_minus_traj.append(sm.real)
    im_minus_traj.append(sm.imag)

ax4.plot(re_plus_traj, im_plus_traj, 'b-', linewidth=2, label='$s_+$ (real domain)')
ax4.plot(re_minus_traj, im_minus_traj, 'r-', linewidth=2, label='$s_-$ (real domain)')

# Mark collision point
ax4.plot([0.5], [0], 'o', color='gold', markersize=12, markeredgecolor='black', 
         linewidth=2, zorder=5, label='Collision')

# Mark special points
ax4.scatter([1], [0], s=100, c='orange', edgecolor='black', zorder=10)
ax4.scatter([1.618], [0], s=100, c='purple', edgecolor='black', zorder=10)
ax4.scatter([2], [0], s=100, c='green', edgecolor='black', zorder=10)

ax4.set_xlabel('Real Part', fontsize=10)
ax4.set_ylabel('Imaginary Part', fontsize=10)
ax4.set_title('Complex Plane: Real Domain', fontsize=11, fontweight='bold')
ax4.grid(True, alpha=0.3)
ax4.legend(loc='upper left', fontsize=8)
ax4.axis('equal')

# ========================================
# Panel 5: Complex Plane: Rotating Realm
# ========================================
ax5 = fig.add_subplot(gs[1, 2])

# Rotating domain (G from -10 to -0.25)
G_rot = np.linspace(-10, -0.25, 1000)
re_plus_rot = []
im_plus_rot = []
re_minus_rot = []
im_minus_rot = []
for G in G_rot:
    sp, sm = gap_roots(G)
    re_plus_rot.append(sp.real)
    im_plus_rot.append(sp.imag)
    re_minus_rot.append(sm.real)
    im_minus_rot.append(sm.imag)

ax5.plot(re_plus_rot, im_plus_rot, 'b-', linewidth=2, label='$s_+$')
ax5.plot(re_minus_rot, im_minus_rot, 'r-', linewidth=2, label='$s_-$', alpha=0.5)

# Mark collision point
ax5.plot([0.5], [0], 'o', color='gold', markersize=12, markeredgecolor='black', 
         linewidth=2, zorder=5, label='Collision')

ax5.set_xlabel('Real Part', fontsize=10)
ax5.set_ylabel('Imaginary Part', fontsize=10)
ax5.set_title('Complex Plane: Rotating Realm', fontsize=11, fontweight='bold')
ax5.grid(True, alpha=0.3)
ax5.legend(loc='lower left', fontsize=8)
ax5.axis('equal')

# ========================================
# Panel 6: The Eternal Point 0.5
# ========================================
ax6 = fig.add_subplot(gs[2, 2])

# Show the eternal midpoint
ax6.scatter([0.5], [0], s=300, c='gold', edgecolor='black', linewidth=3, zorder=10)
ax6.text(0.5, 0.8, 'The Eternal Point\nx = 0.5\n\nAlways the midpoint\nAlways preserved\nThe anchor of the\nGAP universe', 
         ha='center', va='center', fontsize=11,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

ax6.set_xlim(0, 1)
ax6.set_ylim(-0.5, 0.5)
ax6.set_title('Eternal Symmetry', fontsize=11, fontweight='bold')
ax6.axis('off')

# Main title
fig.suptitle('Complete Journey: G from $+\infty$ to $-\infty$\nGAP Equation: $x^2 = x + G$', 
             fontsize=14, fontweight='bold', y=0.995)

plt.tight_layout()

# Save
output_path = 'fig12_complete_journey.png'
plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()

print(f"✓ Created: {output_path}")
print()
print("Visualization shows:")
print("  - Complete root trajectories from G = -∞ to G = +∞")
print("  - Real and imaginary parts across all domains")
print("  - Magnitude growth following √|G| law")
print("  - Complex plane trajectories for all domains")
print("  - Eternal symmetry at x = 0.5")
print("  - Golden ratio, integer, and collision points marked")
print()
print("Coverage:")
print("  - Positive infinity → Golden zone → Core → Counting realm")
print("  - Universal collision at G = -0.25")
print("  - Rotating realm → Negative infinity")
print("  - All phases, all domains, complete mathematical structure")