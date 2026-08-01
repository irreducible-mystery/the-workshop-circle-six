#!/usr/bin/env python3
"""
Visualization: As G varies from -1/4 towards infinity
"""

import numpy as np
import matplotlib.pyplot as plt
import math
import cmath

def gap_roots(G):
    disc = 1 + 4*G
    if disc >= 0:
        sqrt_disc = math.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2
    else:
        sqrt_disc = cmath.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2

# Set up figure
plt.style.use('dark_background')
fig = plt.figure(figsize=(20, 12))
gs = fig.add_gridspec(3, 3, hspace=0.35, wspace=0.3)
fig.suptitle('G → ∞: The Evolution from Collision to Dominance', fontsize=20, color='#FFD700', weight='bold')

# =============================================================================
# Panel 1: Root Evolution (Real vs Imaginary)
# =============================================================================
ax1 = fig.add_subplot(gs[0, :2])
G_vals = np.linspace(-0.25, 10, 200)
s_plus_real = []
s_minus_real = []
s_plus_imag = []
s_minus_imag = []

for G in G_vals:
    rp, rm = gap_roots(G)
    s_plus_real.append(rp.real if isinstance(rp, complex) else rp)
    s_minus_real.append(rm.real if isinstance(rm, complex) else rm)
    s_plus_imag.append(rp.imag if isinstance(rp, complex) else 0)
    s_minus_imag.append(rm.imag if isinstance(rm, complex) else 0)

# Plot real parts
ax1.plot(G_vals, s_plus_real, 'cyan', linewidth=2.5, label='Re(s_+)', alpha=0.8)
ax1.plot(G_vals, s_minus_real, 'magenta', linewidth=2.5, label='Re(s_-)', alpha=0.8)

# Plot imaginary parts (only exist below -1/4, but we start at -1/4)
ax1.plot(G_vals, s_plus_imag, 'cyan', linewidth=1.5, linestyle='--', label='Im(s_+) = 0', alpha=0.5)
ax1.plot(G_vals, s_minus_imag, 'magenta', linewidth=1.5, linestyle='--', label='Im(s_-) = 0', alpha=0.5)

# Mark key points
key_points = [(-0.25, 0.5, 'Collision: G=-1/4'),
              (0, 1, 's_+=1'),
              (0, 0, 's_-=0'),
              (1, 1.618, 'φ'),
              (1, -0.618, 'ψ'),
              (2, 2, 's_+=2'),
              (2, -1, 's_-=-1')]

for G, val, label in key_points:
    color = 'yellow' if 'Collision' in label else 'white'
    ax1.plot(G, val, 'o', markersize=8, color=color, markeredgecolor='black', markeredgewidth=1, zorder=10)
    ax1.text(G, val + 0.15, label, fontsize=8, ha='center', color=color, weight='bold')

# Highlight regions
ax1.axvspan(-0.25, 0, alpha=0.15, color='red', label='Emergence (-1/4<G<0)')
ax1.axvspan(0, 0.75, alpha=0.15, color='green', label='Stability (0<G<3/4)')
ax1.axvspan(0.75, 2, alpha=0.15, color='orange', label='Instability (3/4<G<2)')
ax1.axvspan(2, 10, alpha=0.15, color='purple', label='Dominance (G>2)')

ax1.set_xlabel('Gap G', fontsize=13)
ax1.set_ylabel('Root Value', fontsize=13)
ax1.set_title('Root Evolution: From Collision to Dominance', fontsize=14, color='#FFD700')
ax1.legend(loc='upper left', fontsize=9)
ax1.grid(True, alpha=0.2)
ax1.set_xlim(-0.3, 10)

# =============================================================================
# Panel 2: Root Moduli Comparison
# =============================================================================
ax2 = fig.add_subplot(gs[0, 2])
s_plus_mod = [abs(gap_roots(G)[0]) for G in G_vals]
s_minus_mod = [abs(gap_roots(G)[1]) for G in G_vals]

ax2.plot(G_vals, s_plus_mod, 'cyan', linewidth=2.5, label='|s_+|')
ax2.plot(G_vals, s_minus_mod, 'magenta', linewidth=2.5, label='|s_-|')
ax2.axhline(y=1, color='white', linestyle='--', linewidth=1, alpha=0.5, label='|s|=1')

# Mark crossing at G=0
ax2.plot(0, 0, 'yo', markersize=10, markeredgecolor='white', markeredgewidth=1, label='G=0: s_-=0')
ax2.plot(0, 1, 'yo', markersize=10, markeredgecolor='white', zorder=10)

ax2.set_xlabel('Gap G', fontsize=13)
ax2.set_ylabel('|Root|', fontsize=13)
ax2.set_title('Root Moduli: s_+ Dominates', fontsize=14, color='#FFD700')
ax2.legend(loc='upper left', fontsize=9)
ax2.grid(True, alpha=0.2)
ax2.set_xlim(-0.3, 10)

# =============================================================================
# Panel 3: Root Ratio (Dominance Measure)
# =============================================================================
ax3 = fig.add_subplot(gs[1, 0])
ratios = []
for G in G_vals:
    rp, rm = gap_roots(G)
    if rm == 0:
        ratios.append(float('inf'))
    else:
        ratio = rp/rm
        if abs(ratio) > 100:
            ratios.append(100 if ratio > 0 else -100)
        else:
            ratios.append(ratio.real if isinstance(ratio, complex) else ratio)

# Plot only finite values
valid_G = [g for g, r in zip(G_vals, ratios) if abs(r) < 100]
valid_ratios = [r for r in ratios if abs(r) < 100]

ax3.plot(valid_G, valid_ratios, 'yellow', linewidth=2.5)
ax3.axhline(y=-1, color='white', linestyle='--', linewidth=1, alpha=0.5)
ax3.axhline(y=1, color='white', linestyle='--', linewidth=1, alpha=0.5)
ax3.axvline(x=0, color='cyan', linestyle='--', linewidth=1, alpha=0.5, label='G=0 (s_-=0)')

ax3.set_xlabel('Gap G', fontsize=13)
ax3.set_ylabel('s_+ / s_-', fontsize=13)
ax3.set_title('Root Ratio: Measure of Dominance', fontsize=14, color='#FFD700')
ax3.grid(True, alpha=0.2)
ax3.set_ylim(-10, 10)
ax3.set_xlim(-0.3, 10)

# =============================================================================
# Panel 4: Entropy Evolution
# =============================================================================
ax4 = fig.add_subplot(gs[1, 1])
entropies = [math.log(abs(gap_roots(G)[0])) if abs(gap_roots(G)[0]) > 0 else float('-inf') for G in np.linspace(-0.24, 10, 200)]

G_entropy = np.linspace(-0.24, 10, 200)
ax4.plot(G_entropy, entropies, 'green', linewidth=2.5, label='Entropy = log|s_+|')
ax4.axhline(y=0, color='white', linestyle='--', linewidth=1, alpha=0.5, label='Zero entropy (G=0)')
ax4.axhline(y=math.log(1.618), color='yellow', linestyle='--', linewidth=1, alpha=0.5, label=f'log(φ) ≈ {math.log(1.618):.4f}')

# Mark minimum
min_entropy = min(entropies)
min_G = G_entropy[entropies.index(min_entropy)]
ax4.plot(min_G, min_entropy, 'ro', markersize=10, label=f'Min entropy at G={min_G:.2f}')

ax4.set_xlabel('Gap G', fontsize=13)
ax4.set_ylabel('Entropy (log|s_+|)', fontsize=13)
ax4.set_title('Entropy Evolution: From Zero to Growth', fontsize=14, color='#FFD700')
ax4.legend(loc='upper left', fontsize=9)
ax4.grid(True, alpha=0.2)
ax4.set_xlim(-0.3, 10)

# =============================================================================
# Panel 5: Vieta's Invariants
# =============================================================================
ax5 = fig.add_subplot(gs[1, 2])
sums = [gap_roots(G)[0] + gap_roots(G)[1] for G in np.linspace(-0.24, 10, 200)]
products = [gap_roots(G)[0] * gap_roots(G)[1] for G in np.linspace(-0.24, 10, 200)]

G_vieta = np.linspace(-0.24, 10, 200)
ax5.plot(G_vieta, sums, 'cyan', linewidth=2.5, label='Sum = s_+ + s_- = 1')
ax5.plot(G_vieta, products, 'magenta', linewidth=2.5, label='Product = s_+ * s_- = -G')

ax5.set_xlabel('Gap G', fontsize=13)
ax5.set_ylabel('Value', fontsize=13)
ax5.set_title("Vieta's Invariants (Always True)", fontsize=14, color='#FFD700')
ax5.legend(loc='upper left', fontsize=9)
ax5.grid(True, alpha=0.2)
ax5.set_xlim(-0.3, 10)

# =============================================================================
# Panel 6: Special Gaps Marker
# =============================================================================
ax6 = fig.add_subplot(gs[2, 0])
special_gaps = {
    -0.25: 'Collision\nG=-1/4',
    0: 'Zero\ns_-=0',
    0.75: 'Bifurcation\nG=3/4',
    1: 'Golden\ns_+=φ',
    2: 'Root\ns_-=G',
}

for i, (G, label) in enumerate(special_gaps.items()):
    rp, rm = gap_roots(G)
    color = 'yellow' if G == -0.25 else 'cyan' if G == 1 else 'white'
    ax6.plot([G, G], [0, i], color=color, linewidth=2, alpha=0.7)
    ax6.plot(G, i, 'o', markersize=12, color=color, markeredgecolor='white', markeredgewidth=2, zorder=10)
    ax6.text(G, i + 0.1, label, ha='center', fontsize=9, color=color, weight='bold')
    ax6.text(G, i - 0.15, f's_+={rp:.3f}', ha='center', fontsize=8, color='white', alpha=0.7)

ax6.set_xlabel('Gap G', fontsize=13)
ax6.set_yticks([])
ax6.set_title('Special Gaps on Journey', fontsize=14, color='#FFD700')
ax6.set_xlim(-0.3, 3)
ax6.set_ylim(-0.5, len(special_gaps))
ax6.grid(True, alpha=0.2, axis='x')

# =============================================================================
# Panel 7: Asymptotic Behavior
# =============================================================================
ax7 = fig.add_subplot(gs[2, 1:])
G_asym = np.logspace(0, 3, 100)  # G from 1 to 1000
s_plus_asym = [gap_roots(G)[0] for G in G_asym]
s_minus_asym = [gap_roots(G)[1] for G in G_asym]
sqrt_G = np.sqrt(G_asym)

ax7.plot(G_asym, s_plus_asym, 'cyan', linewidth=2.5, label='s_+ (actual)')
ax7.plot(G_asym, sqrt_G, 'cyan', linestyle='--', linewidth=2, alpha=0.5, label='√G (asymptotic)')
ax7.plot(G_asym, s_minus_asym, 'magenta', linewidth=2.5, label='s_- (actual)')
ax7.plot(G_asym, -np.ones_like(G_asym), 'magenta', linestyle='--', linewidth=2, alpha=0.5, label='-1 (asymptotic)')

ax7.set_xscale('log')
ax7.set_xlabel('Gap G (log scale)', fontsize=13)
ax7.set_ylabel('Root Value', fontsize=13)
ax7.set_title('Asymptotic Regime: s_+ ~ √G, s_- → -1', fontsize=14, color='#FFD700')
ax7.legend(loc='lower right', fontsize=10)
ax7.grid(True, alpha=0.2)

# Add annotation
ax7.text(10, 30, 'for G >> 1:\n  s_+ ≈ √G\n  s_- ≈ -1', fontsize=11, 
         bbox=dict(boxstyle="round,pad=0.5", facecolor="black", alpha=0.7), color='yellow')

plt.savefig('visualizations/fig11_g_infinity.png', dpi=300, bbox_inches='tight')
plt.close()

print("✓ Created: fig11_g_infinity.png")
print("\nVisualization shows:")
print("  - Root evolution from collision to dominance")
print("  - s_+ grows as √G for large G")
print("  - s_- approaches -1 for large G")