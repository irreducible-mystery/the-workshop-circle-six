#!/usr/bin/env python3
"""
Analysis: What happens as G varies from -1/4 towards infinity?
Tracking the evolution of roots, dynamics, and mathematical properties.
"""

import numpy as np
import matplotlib.pyplot as plt
import cmath
import math

def gap_roots(G):
    """Return the two roots of x^2 = x + G"""
    disc = 1 + 4*G
    if disc >= 0:
        sqrt_disc = math.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2
    else:
        sqrt_disc = cmath.sqrt(disc)
        return (1 + sqrt_disc)/2, (1 - sqrt_disc)/2

print("="*70)
print("ANALYSIS: As G varies from -1/4 towards infinity")
print("="*70)

# Key checkpoints
checkpoints = [-0.25, -0.2, -0.1, 0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5, 10, 100]

print("\n" + "="*70)
print("ROOT EVOLUTION TABLE")
print("="*70)
print(f"{'G':>8} {'s_+':>15} {'s_-':>15} {'|s_+|':>10} {'|s_-|':>10} {'s_+/s_-':>12}")
print("="*70)

for G in checkpoints:
    rp, rm = gap_roots(G)
    mod_p = abs(rp)
    mod_m = abs(rm)
    ratio = rp/rm if rm != 0 else float('inf')
    
    if isinstance(rp, complex):
        rp_str = f"{rp.real:+.4f}{rp.imag:+.4f}i"
        rm_str = f"{rm.real:+.4f}{rm.imag:+.4f}i"
    else:
        rp_str = f"{rp:+.4f}"
        rm_str = f"{rm:+.4f}"
    
    if isinstance(ratio, complex):
        ratio_str = f"{ratio.real:+.4f}{ratio.imag:+.4f}i"
    else:
        ratio_str = f"{ratio:+.4f}"
    
    print(f"{G:>8} {rp_str:>15} {rm_str:>15} {mod_p:>10.4f} {mod_m:>10.4f} {ratio_str:>12}")

print("\n" + "="*70)
print("KEY PHENOMENA BY GAP RANGE")
print("="*70)

# Phase 1: The Collision (G = -1/4)
print("\n[PHASE 1] THE COLLISION: G = -1/4")
print("-" * 50)
G = -0.25
rp, rm = gap_roots(G)
print(f"G = {G}")
print(f"Roots: s_+ = s_- = {rp:.6f}")
print(f"Discriminant: 1+4G = {1 + 4*G}")
print(f"Derivative zero: At branch point, cannot deform roots")
print(f"Universal threshold: All carriers meet here")
print(f"Rotation number: zero (parabolic point)")
print(f"Density of states: diverges at van Hove singularity")

# Phase 2: Just above collision (G slightly > -1/4)
print("\n[PHASE 2] JUST ABOVE COLLISION: -1/4 < G < 0")
print("-" * 50)
G = -0.2
rp, rm = gap_roots(G)
print(f"G = {G}")
print(f"Roots: s_+ = {rp:.6f}, s_- = {rm:.6f}")
print(f"Properties:")
print(f"  - Two distinct real roots (just separated)")
print(f"  - s_- is NEGATIVE, s_+ is POSITIVE")
print(f"  - Product s_+ * s_- = -G = {-G}")
print(f"  - Sum s_+ + s_- = 1 (Vieta)")
print(f"  - |s_+| > |s_-|: upper root dominates")
print(f"  - Continued fraction: CONVERGES")
print(f"  - Counting: Integer G >= 0 only, but structure emerging")
print(f"  - Operator: G >= -1/4, so observable")

# Phase 3: Cross into positive G (G = 0)
print("\n[PHASE 3] ZERO GAP: G = 0")
print("-" * 50)
G = 0
rp, rm = gap_roots(G)
print(f"G = {G}")
print(f"Roots: s_+ = {rp:.6f}, s_- = {rm:.6f}")
print(f"Properties:")
print(f"  - One root is ZERO, one is ONE")
print(f"  - Roots are {rp} and {rm}")
print(f"  - Trivial case: x^2 = x → x(x-1) = 0")
print(f"  - Product = 0 (one root zero)")
print(f"  - Reflexive gap: product of roots")
print(f"  - Entropy: log(s_+) = log(1) = 0 (no growth)")

# Phase 4: Stability window (0 < G < 3/4)
print("\n[PHASE 4] STABILITY WINDOW: 0 < G < 3/4")
print("-" * 50)
print(f"This is the CORE COUNTING REALM:")
print(f"  - Both roots POSITIVE")
print(f"  - s_+ > 1, 0 < s_- < 1")
print(f"  - Mandelbrot: inside main cardioid")
print(f"  - Logistic map: stable fixed point")
print(f"  - Continued fraction: converges to s_-")
print(f"  - Integer G >= 0: can be counting problem")
print(f"  - Entropy = log(s_+) > 0 (growth)")
print(f"  - Dynamics: multiplier |λ| < 1 (attracting)")

for G in [0.25, 0.5, 0.7]:
    rp, rm = gap_roots(G)
    print(f"\n  G = {G}:")
    print(f"    Roots: s_+ = {rp:.6f}, s_- = {rm:.6f}")
    print(f"    s_+/s_- = {rp/rm:.6f}")

# Phase 5: The Golden Gap (G = 1)
print("\n[PHASE 5] THE GOLDEN GAP: G = 1")
print("-" * 50)
G = 1
rp, rm = gap_roots(G)
phi = (1 + math.sqrt(5)) / 2
psi = (1 - math.sqrt(5)) / 2
print(f"G = {G}")
print(f"Roots: s_+ = {rp:.6f} = φ (golden ratio)")
print(f"        s_- = {rm:.6f} = ψ (conjugate)")
print(f"Properties:")
print(f"  - s_+ = φ ≈ {phi}, s_- = ψ ≈ {psi}")
print(f"  - s_+ + s_- = 1: gap equals SUM of roots")
print(f"  - s_+ * s_- = -1")
print(f"  - s_+² = s_+ + 1 (golden property)")
print(f"  - Reflexive gap: THE GOLDEN ONE")
print(f"  - Entropy: log(φ) ≈ {math.log(phi):.6f}")
print(f"  - Golden mean shift (no two consecutive 1s)")
print(f"  - OUTSIDE stability window! (stable only to 3/4)")

# Phase 6: Beyond stability window (3/4 < G < 2)
print("\n[PHASE 6] BEYOND STABILITY: 3/4 < G < 2")
print("-" * 50)
print(f"Transition to instability:")
print(f"  - G = 3/4: Period doubling begins")
print(f"  - Mandelbrot: exit main cardioid")
print(f"  - Logistic map: r > 3 (chaos begins)")
print(f"  - But GAP equation: s_- becomes NEGATIVE!")
print(f"  - Roots: s_+ > 1, s_- < 0")

for G in [0.8, 1, 1.5]:
    rp, rm = gap_roots(G)
    print(f"\n  G = {G}:")
    print(f"    Roots: s_+ = {rp:.6f} (>1), s_- = {rm:.6f} (<0)")
    print(f"    s_+/s_- = {rp/rm:+.6f} (ratio negative)")

# Phase 7: Integer gap special points
print("\n[PHASE 7] INTEGER GAPS: Self-Referential Properties")
print("-" * 50)
for G in [0, 1, 2]:
    rp, rm = gap_roots(G)
    print(f"\nG = {G}:")
    print(f"  Roots: {rp:.6f}, {rm:.6f}")
    print(f"  s_+ + s_- = {rp + rm:.6f}")
    print(f"  s_+ * s_- = {rp * rm:.6f}")
    if G == 0:
        print(f"  ★ REFLEXIVE: G = product of roots = 0")
    elif G == 1:
        print(f"  ★ REFLEXIVE: G = sum of roots = 1 (GOLDEN)")
    elif G == 2:
        print(f"  ★ REFLEXIVE: G is one of the roots!")

# Phase 8: Large G behavior
print("\n[PHASE 8] LARGE G: Gap Dominates")
print("-" * 50)
print(f"As G → +∞:")
for G in [10, 100, 1000]:
    rp, rm = gap_roots(G)
    print(f"\nG = {G}:")
    print(f"  Roots: s_+ ≈ √G ≈ {math.sqrt(G):.2f}")
    print(f"        s_- ≈ -1 ≈ {rm:.6f}")
    print(f"  Actual: s_+ = {rp:.6f}, s_- = {rm:.6f}")
    print(f"  s_+ dominates linearly!")

print(f"\nAsymptotic behavior:")
print(f"  s_+ ≈ √G (dominant root)")
print(f"  s_- → -1 (approaches constant)")
print(f"  Ratio s_+/s_- → -∞ (dominance extreme)")

print("\n" + "="*70)
print("EVOLUTION SUMMARY")
print("="*70)
print("""
G varies from -1/4 to +∞:

  INITIAL (G = -1/4): COLLISION
  ─────────────────────────────
  • Single double root: x = 1/2
  • Discriminant = 0
  • Universal threshold
  • All mathematical properties meet

  EMERGENCE (-1/4 < G < 0): SEPARATION
  ───────────────────────────────────
  • Two real roots separate
  • s_- negative, s_+ positive
  • Counting structure emerging
  • Observability begins

  CORE (0 < G < 3/4): COUNTING REALM
  ─────────────────────────────────
  • Both roots positive
  • s_+ > 1, 0 < s_- < 1
  • Stable dynamics
  • Entropy = log(s_+)
  • Integer G: shift spaces

  GOLDEN (G = 1): SELF-REFERENTIAL
  ────────────────────────────────
  • Roots: φ and ψ
  • Gap = sum of roots
  • Golden mean shift
  • Outside stability window

  INSTABILITY (3/4 < G < 2): SIGN CHANGE
  ─────────────────────────────────
  • s_- becomes negative
  • Period doubling in dynamics
  • Chaos in logistic map
  • But roots still distinct

  LARGE (G >> 1): DOMINANCE
  ───────────────────────────
  • s_+ grows as √G
  • s_- approaches -1
  • Ratio → -∞
  • One root dominates

KEY THEME:
  As G increases from -1/4 to ∞:
  • Roots separate from collision
  • Shift from complex to real
  • s_- crosses from negative to positive to negative
  • Entropy increases from 0 to log(s_+)
  • System transitions from critical to growth
  • Multiple special gaps at integer values
""")

print("="*70)
print("VISUALIZING THE PROGRESSION")
print("="*70)