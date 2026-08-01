#!/usr/bin/env python3
"""
Complete Journey Analysis: G from +∞ to -∞
Analyzing the GAP equation x² = x + G across all parameter space
"""

import math
import cmath
import numpy as np

def gap_roots(G):
    """Calculate roots of the GAP equation x² = x + G"""
    disc = 1 + 4*G
    if disc >= 0:
        sqrt_disc = math.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2
    else:
        sqrt_disc = cmath.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2

def rotation_number(G):
    """Calculate rotation number for G < -1/4"""
    if G >= -0.25:
        return 0
    # Rotation angle: θ/2π where θ = arccos(1/√(1+4G))
    disc = 1 + 4*G
    theta = cmath.phase(complex(1, math.sqrt(-disc)))
    return theta / (2 * math.pi)

print("=" * 80)
print(" COMPLETE JOURNEY: G from +∞ to -∞")
print("=" * 80)
print()

# Checkpoints from +∞ to -∞
checkpoints = [
    100, 50, 20, 10, 5, 3, 2, 1.5, 1, 0.75, 0.5, 0.25, 0,
    -0.1, -0.2, -0.25, -0.3, -0.5, -1, -2, -5, -10, -50, -100
]

phases = []

print("ROOT EVOLUTION TABLE")
print("=" * 100)
print(f"{'G Value':>10} | {'s_+':>15} | {'s_-':>15} | {'Magnitude':>10} | {'Phase':>15}")
print("-" * 100)

for G in checkpoints:
    s_plus, s_minus = gap_roots(G)
    mag_plus = abs(s_plus)
    mag_minus = abs(s_minus)
    
    # Determine phase
    if G > 100:
        phase = "Far +∞"
    elif G > 10:
        phase = "Large Positive"
    elif G > 2:
        phase = "Positive Core"
    elif G > 1:
        phase = "Golden Zone"
    elif G > 0:
        phase = "Core Realm"
    elif G > -0.25:
        phase = "Counting Realm"
    elif G > -0.25 - 1e-10:
        phase = "★★ COLLISION ★★"
    elif G > -1:
        phase = "Rotating Core"
    elif G > -10:
        phase = "Rotating Deep"
    else:
        phase = "Far -∞"
    
    phases.append((G, s_plus, s_minus, phase))
    
    # Format output based on real/complex
    if isinstance(s_plus, complex):
        s_plus_str = f"{s_plus.real:.3f}{s_plus.imag:+.3f}i"
        s_minus_str = f"{s_minus.real:.3f}{s_minus.imag:+.3f}i"
    else:
        s_plus_str = f"{s_plus:.6f}"
        s_minus_str = f"{s_minus:.6f}"
    
    mag_str = f"{mag_plus:.3f}"
    
    # Highlight special G values
    G_str = f"{G:8.2f}"
    if G == 100:
        G_str = "+100.00"
    elif G == -100:
        G_str = "-100.00"
    elif G == -0.25:
        G_str = "  -0.25 ★"
    elif G == 0:
        G_str = "   0.00 ★"
    elif G == 1:
        G_str = "   1.00 ★"
    elif G == 2:
        G_str = "   2.00 ★"
    
    print(f"{G_str} | {s_plus_str:>15} | {s_minus_str:>15} | {mag_str:>10} | {phase:>15}")

print()
print("=" * 100)
print()

# Analyze the key transitions
print("KEY TRANSITIONS ANALYSIS")
print("=" * 80)
print()

print("1. POSITIVE INFINITY (G → +∞):")
print("   As G → +∞:")
print("   s_+ ≈ √G → +∞")
print("   s_- ≈ -√G → -∞")
print("   Both real, distinct, with s_+ + s_- = 1 (always!)")
print("   Product: s_+ · s_- = -G → -∞")
print()

print("2. LARGE POSITIVE (G ∈ (10, ∞)):")
print("   s_+ grows steadily as √G")
print("   s_- grows negatively as -√G")
print("   Domain: Real roots, distinct")
print("   Character: Asymptotic simplicity")
print()

print("3. POSITIVE CORE (G ∈ (2, 10)):")
print("   s_+: From 2 to 3.7")
print("   s_-: From -1 to -2.7")
print("   Both negative and positive present")
print("   Integer crossing at G = 2: s_+ = 2, s_- = -1")
print()

print("4. GOLDEN ZONE (G ∈ (1, 2)):")
print("   Golden ratio at G = 1:")
print("   s_+ = φ = (1 + √5)/2 ≈ 1.618")
print("   s_- = ψ = (1 - √5)/2 ≈ -0.618")
print("   Special symmetries and self-similarity")
print()

print("5. CORE REALM (G ∈ (0, 1)):")
print("   s_+: From 1 to 1.618")
print("   s_-: From 0 to -0.618")
print("   Pure counting at G = 0: s_+ = 1, s_- = 0")
print("   Stability window before golden ratio")
print()

print("6. COUNTING REALM (G ∈ (-0.25, 0)):")
print("   s_+: From 0.5 to 1")
print("   s_-: From 0.5 to 0")
print("   Roots approach collision at G = -0.25")
print("   Boundary of real domain")
print()

print("7. ★★★ UNIVERSAL COLLISION (G = -0.25) ★★★")
print("   Discriminant Δ = 1 + 4G = 0")
print("   s_+ = s_- = 0.5 (complete degeneracy)")
print("   Van Hove singularity: ρ(g) = (1+4g)^(-1/2) → ∞")
print("   Branch point origin for entire root structure")
print("   Threshold between Counting and Rotating realms")
print()

print("8. ROTATING CORE (G ∈ (-1, -0.25)):")
print("   Roots become complex conjugates")
print("   s_± = (1 ± i|√(1+4G)|)/2")
print("   Acquire rotation number θ/π ∈ [0, 1]")
print("   Magnitude: |s_±| = √[(1 + |1+4G|)/4]")
print()

print("9. ROTATING DEEP (G ∈ (-10, -1)):")
print("   Complex roots with larger imaginary parts")
print("   Rotation number increases toward 0.25")
print("   Magnitude grows: |s_±| = √[(-4G)/4] = √(-G)")
print("   Roots trace larger circles in complex plane")
print()

print("10. NEGATIVE INFINITY (G → -∞):")
print("    As G → -∞:")
print("    s_± = (1 ± i√(4G-1))/2 ≈ ±i√G")
print("    Magnitude: |s_±| ≈ √|G| → ∞")
print("    Rotation number → 1/4")
print("    Both roots become purely imaginary conjugates")
print()

print("=" * 80)
print()

# Summary statistics
print("SUMMARY STATISTICS")
print("=" * 80)
print()

real_G_count = sum(1 for G, _, _, _ in phases if G >= -0.25)
complex_G_count = sum(1 for G, _, _, _ in phases if G < -0.25)
collision_count = 1  # Only at G = -0.25

print(f"Real root domain (G ≥ -0.25):  {real_G_count} checkpoints")
print(f"Complex root domain (G < -0.25): {complex_G_count} checkpoints")
print(f"Collision point (G = -0.25): 1 special point")
print()

print("Ratio of domains:")
print(f"Real domain:     {100*real_G_count/len(checkpoints):.1f}%")
print(f"Complex domain:  {100*complex_G_count/len(checkpoints):.1f}%")
print()

# Eternal symmetries
print("ETERNAL SYMMETRIES (valid for ALL G):")
print("=" * 80)
print("   1. Sum:      s_+ + s_- = 1 (always exact)")
print("   2. Product:  s_+ · s_- = -G (always exact)")
print("   3. Midpoint: (s_+ + s_-)/2 = 0.5 (always exact)")
print("   4. Chiral:   x → 1-x maps s_+ ↔ s_-")
print()

# The complete story
print("THE COMPLETE STORY")
print("=" * 80)
print()
print("As G journey from +∞ to -∞:")
print()
print("1. START at POSITIVE INFINITY:")
print("   → Two real roots, s_+ → +∞, s_- → -∞")
print("   → Both grow as √|G|")
print("   → Symmetric about x = 0.5")
print()
print("2. DESCEND through POSITIVE VALUES:")
print("   → Golden ratio appears (G = 1)")
print("   → Integer crossing (G = 2)")
print("   → Pure counting (G = 0)")
print()
print("3. APPROACH the UNIVERSAL COLLISION:")
print("   → Roots converge at G = -0.25")
print("   → Complete degeneracy: s_+ = s_- = 0.5")
print("   → Van Hove singularity marks the threshold")
print()
print("4. CROSS into ROTATING REALM:")
print("   → Roots become complex conjugates")
print("   → Acquire rotation number θ/π")
print("   → Begin circular motion")
print()
print("5. DESCEND toward NEGATIVE INFINITY:")
print("   → Magnitude grows as √|G|")
print("   → Rotation number → 1/4")
print("   → Roots become purely imaginary conjugates")
print("   → s_± ≈ ±i√|G| → ±i∞")
print()
print("6. END at NEGATIVE INFINITY:")
print("   → Both roots at infinity (in imaginary directions)")
print("   → Sum remains 1 (even at infinity!)")
print("   → Product → +∞")
print()

print("THE UNIVERSAL TRUTH:")
print("=" * 80)
print("   Throughout the entire journey from G = +∞ to G = -∞:")
print("   ✓ The midpoint 0.5 remains eternal and unchanging")
print("   ✓ The sum s_+ + s_- = 1 is preserved at every moment")
print("   ✓ The chiral symmetry x → 1-x persists across all domains")
print("   ✓ Only the nature of the roots transforms (real ↔ complex)")
print()
print("   The GAP equation encodes:")
print("   • Emergence (one → two roots)")
print("   • Ordering (trajectories determined)")
print("   • Transformation (real ↔ complex)")
print("   • Invariance (eternal symmetries)")
print("   • Asymptotic elegance (√|G| growth)")
print()

print("=" * 80)
print(" ANALYSIS COMPLETE")
print("=" * 80)