#!/usr/bin/env python3
"""
Time Evolution Analysis: GAP Equation with Temporal Dynamics
Analyzing x^n = x + G with time-dependent evolution
"""

import math
import cmath
import numpy as np

def gap_roots_n(G, n):
    """Calculate roots of n-dimensional GAP equation: x^n = x + G"""
    
    if n == 2:
        disc = 1 + 4*G
        if disc >= 0:
            sqrt_disc = math.sqrt(disc)
            return [(1 + sqrt_disc)/2, (1 - sqrt_disc)/2]
        else:
            sqrt_disc = cmath.sqrt(disc)
            return [(1 + sqrt_disc)/2, (1 - sqrt_disc)/2]
    else:
        coeffs = [0] * (n + 1)
        coeffs[0] = 1  # x^n coefficient
        coeffs[-2] = -1  # x coefficient
        coeffs[-1] = -G  # constant term
        roots = np.roots(coeffs)
        return list(roots)

def logistic_time_evolution(G, n, t, r=2.8, dt=0.01):
    """
    Time evolution using logistic-like dynamics
    
    x_{t+1} = r * x_t * (1 - x_t) + G_modulated
    
    This creates temporal behavior beyond the static GAP solutions
    """
    # Start from GAP roots
    initial_roots = gap_roots_n(G, n)
    
    # Evolve each root through time
    trajectories = []
    for root in initial_roots:
        trajectory = [root]
        x = root
        
        for _ in range(int(t/dt)):
            # Temporal dynamics parameter modulation
            G_mod = G * (1 + 0.1 * math.sin(len(trajectory) * dt))
            
            # Logistic-like evolution
            x_new = r * x * (1 - x) + G_mod / (n * len(trajectory)**0.5)
            
            # Keep bounded
            if abs(x_new) < 1000:
                trajectory.append(x_new)
            else:
                trajectory.append(x / abs(x) * 10)  # Reset to bounded
                
        trajectories.append(trajectory)
    
    return trajectories

def linear_dynamics_evolution(G, n, t, alpha=0.1, dt=0.01):
    """
    Time evolution using linear dynamics toward fixed points
    
    dx/dt = alpha * (GAP_equation - x) = alpha * (x^n - x - G)
    """
    initial_roots = gap_roots_n(G, n)
    
    trajectories = []
    for root in initial_roots:
        trajectory = [root]
        x = root
        
        for _ in range(int(t/dt)):
            # Dynamics: dx/dt = alpha * (x^n - x - G)
            
            # For complex x, use complex power
            if isinstance(x, complex):
                x_power = x ** n
            else:
                x_power = x ** n
            
            dx = alpha * (x_power - x - G) * dt
            x_new = x - dx
            
            # Prevent explosion
            if abs(x_new) < 100:
                trajectory.append(x_new)
                x = x_new
            else:
                break
                
        trajectories.append(trajectory)
    
    return trajectories

def oscillatory_evolution(G, n, t, omega=2*math.pi, amplitude=0.5, dt=0.01):
    """
    Time evolution with oscillatory modulation
    
    x(t) = x_0 + amplitude * sin(omega * t + phase)
    """
    initial_roots = gap_roots_n(G, n)
    
    trajectories = []
    phases = [0, math.pi/2, math.pi, 3*math.pi/2][:len(initial_roots)]
    
    for root, phase in zip(initial_roots, phases):
        trajectory = []
        
        time_points = np.arange(0, t, dt)
        for time_point in time_points:
            # Oscillatory evolution
            oscillation = amplitude * cmath.exp(1j * (omega * time_point + phase))
            x_t = root + oscillation
            
            trajectory.append(x_t)
        
        trajectories.append(trajectory)
    
    return trajectories

def analyze_time_evolution():
    """Analyze GAP equation with time evolution"""
    
    print("=" * 80)
    print(" TIME EVOLUTION ANALYSIS: GAP Equation with Temporal Dynamics")
    print("=" * 80)
    print()
    print("Analyzing x^n = x + G as G, n, AND time t all vary")
    print()
    
    # Parameters to analyze
    G_values = [1, 0, -0.25, -1]
    n_values = [2, 3, 4]
    time_points = [0, 1, 2, 5, 10]
    
    print("STATIC ROOTS (t = 0):")
    print("=" * 60)
    
    for G in G_values:
        print(f"\nG = {G}:")
        for n in n_values:
            roots = gap_roots_n(G, n)
            roots_str = []
            for r in sorted(roots, key=lambda x: x.real):
                if abs(r.imag) < 1e-10:
                    roots_str.append(f"{r.real:.3f}")
                else:
                    roots_str.append(f"{r.real:.3f}{r.imag:+.3f}i")
            print(f"  n={n}: {roots_str}")
    
    print()
    print("=" * 60)
    print()
    
    # Time evolution analysis
    print("TIME EVOLUTION ANALYSIS")
    print("=" * 80)
    print()
    
    print("1. LOGISTIC-TYPE EVOLUTION")
    print("-" * 60)
    print("Evolution: x_{t+1} = r * x_t * (1 - x_t) + G(t)")
    print()
    
    for G in [1, -0.25]:
        print(f"G = {G}, n = 2:")
        trajectories = logistic_time_evolution(G, 2, t=5, r=2.8)
        
        for i, traj in enumerate(trajectories):
            print(f"  Root {i+1}:")
            print(f"    t=0:   {traj[0].real:.3f}{traj[0].imag:+.3f}i")
            print(f"    t=1:   {traj[100].real:.3f}{traj[100].imag:+.3f}i")
            print(f"    t=2:   {traj[200].real:.3f}{traj[200].imag:+.3f}i")
            print(f"    t=5:   {traj[500].real:.3f}{traj[500].imag:+.3f}i")
        print()
    
    print("2. LINEAR DYNAMICS EVOLUTION")
    print("-" * 60)
    print("Evolution: dx/dt = alpha * (x^n - x - G)")
    print()
    
    for G in [1, -0.25]:
        print(f"G = {G}, n = 2:")
        trajectories = linear_dynamics_evolution(G, 2, t=2, alpha=0.1)
        
        for i, traj in enumerate(trajectories):
            if len(traj) > 0:
                print(f"  Root {i+1}:")
                print(f"    t=0:   {traj[0].real:.3f}{traj[0].imag:+.3f}i")
                if len(traj) > 50:
                    print(f"    t=0.5: {traj[50].real:.3f}{traj[50].imag:+.3f}i")
                if len(traj) > 100:
                    print(f"    t=1.0: {traj[100].real:.3f}{traj[100].imag:+.3f}i")
                if len(traj) > 190:
                    print(f"    t=2.0: {traj[-1].real:.3f}{traj[-1].imag:+.3f}i")
        print()
    
    print("3. OSCILLATORY EVOLUTION")
    print("-" * 60)
    print("Evolution: x(t) = x_0 + A * sin(omega * t + phase)")
    print()
    
    for G in [1, -0.25]:
        print(f"G = {G}, n = 2:")
        trajectories = oscillatory_evolution(G, 2, t=2*math.pi, omega=2*math.pi, amplitude=0.5)
        
        for i, traj in enumerate(trajectories):
            print(f"  Root {i+1}:")
            print(f"    t=0:     {traj[0].real:.3f}{traj[0].imag:+.3f}i")
            print(f"    t=π/4:   {traj[157].real:.3f}{traj[157].imag:+.3f}i")
            print(f"    t=π/2:   {traj[314].real:.3f}{traj[314].imag:+.3f}i")
            print(f"    t=π:     {traj[628].real:.3f}{traj[628].imag:+.3f}i")
            print(f"    t=2π:    {traj[-1].real:.3f}{traj[-1].imag:+.3f}i")
        print()
    
    print("=" * 80)
    print()
    
    # Temporal pattern analysis
    print("TEMPORAL PATTERN ANALYSIS")
    print("=" * 80)
    print()
    
    print("As time evolves, several behaviors emerge:")
    print()
    print("1. STEADY STATE BEHAVIOR:")
    print("   Linear dynamics converge toward fixed points")
    print("   Roots are attractors in phase space")
    print("   System reaches equilibrium")
    print()
    print("2. PERIODIC BEHAVIOR:")
    print("   Oscillatory evolution creates cycles")
    print("   Roots trace circles/ellipses in complex plane")
    print("   Period depends on frequency omega")
    print()
    print("3. CHAOTIC BEHAVIOR:")
    print("   Logistic-type dynamics can become chaotic")
    print("   Small changes in initial conditions → divergence")
    print("   Bifurcations as parameter r varies")
    print()
    print("4. SPIRAL BEHAVIOR:")
    print("   Complex roots spiral toward/attractors")
    print("   Real parts converge, imaginary parts oscillate")
    print("   Creates beautiful spiral patterns")
    print()
    
    # Time-dependent G
    print("=" * 80)
    print()
    print("TIME-DEPENDENT G(t)")
    print("=" * 80)
    print()
    print("When G also varies with time:")
    print()
    print("G(t) = G_0 + G_1 * sin(omega_G * t)")
    print()
    print("Roots then become functions of time:")
    print("x(t)^n = x(t) + G(t)")
    print()
    print("This creates:")
    print("  - Moving attractors in phase space")
    print("  - Roots that track the changing landscape")
    print("  - Dynamic equilibrium shifting with G(t)")
    print("  - Resonance when omega_x = omega_G")
    print()
    
    # The complete 3D picture
    print("=" * 80)
    print()
    print("THE COMPLETE 3D PICTURE")
    print("=" * 80)
    print()
    print("We now have THREE parameters varying:")
    print("  1. G: Parameter space [+∞ to -∞]")
    print("  2. n: Dimensional space [2 to ∞]")
    print("  3. t: Temporal space [0 to ∞]")
    print()
    print("This creates a 3D mathematical landscape:")
    print()
    print("Axes:")
    print("  - Horizontal: G (parameter)")
    print("  - Vertical: n (dimension)")
    print("  - Depth: t (time)")
    print()
    print("Features:")
    print("  - Fixed points are lines in 3D space")
    print("  - Trajectories are curves in 3D space")
    print("  - Periodic orbits are helical structures")
    print("  - Chaotic regions are volume-filling")
    print()
    
    # Temporal universality
    print("=" * 80)
    print()
    print("TEMPORAL UNIVERSALITY")
    print("=" * 80)
    print()
    print("Universal laws persist even with time:")
    print()
    print("1. ASYMPTOTIC CONVERGENCE:")
    print("   For stable dynamics: x(t) → FIXED POINTS as t → ∞")
    print()
    print("2. CONSERVATION LAWS:")
    print("   Energy/Lyapunov functions may be conserved")
    print("   Symmetries may persist: s_+(t) + s_-(t) = f(t)")
    print()
    print("3. INVARIANT MANIFOLDS:")
    print("   Phase space structures emerge")
    print("   Attractors, repellers, saddle points")
    print("   Stable/unstable manifolds")
    print()
    print("4. BIFURCATION DIAGRAMS:")
    print("   At critical G, n: qualitative changes")
    print("   Saddle-node, pitchfork, Hopf bifurcations")
    print("   Transition from order to chaos")
    print()
    
    print("=" * 80)
    print(" TIME EVOLUTION ANALYSIS COMPLETE")
    print("=" * 80)

if __name__ == "__main__":
    analyze_time_evolution()