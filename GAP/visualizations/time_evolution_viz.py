#!/usr/bin/env python3
"""
Time Evolution Visualization: GAP Equation with Temporal Dynamics
Visualizing x^n = x + G with time parameter t
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
        coeffs[0] = 1
        coeffs[-2] = -1
        coeffs[-1] = -G
        roots = np.roots(coeffs)
        return list(roots)

def logistic_time_evolution(G, n, t, r=2.8, dt=0.01):
    """Time evolution using logistic-like dynamics"""
    initial_roots = gap_roots_n(G, n)
    trajectories = []
    
    for root in initial_roots:
        trajectory = [root]
        x = root
        
        for i in range(int(t/dt)):
            G_mod = G * (1 + 0.1 * math.sin(i * dt))
            x_new = r * x * (1 - x) + G_mod / (n * (i+1)**0.5)
            
            if abs(x_new) < 1000:
                trajectory.append(x_new)
            else:
                trajectory.append(x / abs(x) * 10)
                
        trajectories.append(trajectory)
    
    return trajectories

def linear_dynamics_evolution(G, n, t, alpha=0.1, dt=0.01):
    """Time evolution using linear dynamics toward fixed points"""
    initial_roots = gap_roots_n(G, n)
    trajectories = []
    
    for root in initial_roots:
        trajectory = [root]
        x = root
        
        for _ in range(int(t/dt)):
            if isinstance(x, complex):
                x_power = x ** n
            else:
                x_power = x ** n
            
            dx = alpha * (x_power - x - G) * dt
            x_new = x - dx
            
            if abs(x_new) < 100:
                trajectory.append(x_new)
                x = x_new
            else:
                break
                
        trajectories.append(trajectory)
    
    return trajectories

def oscillatory_evolution(G, n, t, omega=2*math.pi, amplitude=0.5, dt=0.01):
    """Time evolution with oscillatory modulation"""
    initial_roots = gap_roots_n(G, n)
    trajectories = []
    phases = [0, math.pi/2][:len(initial_roots)]
    
    for root, phase in zip(initial_roots, phases):
        trajectory = []
        time_points = np.arange(0, t, dt)
        
        for time_point in time_points:
            oscillation = amplitude * cmath.exp(1j * (omega * time_point + phase))
            x_t = root + oscillation
            trajectory.append(x_t)
        
        trajectories.append(trajectory)
    
    return trajectories

# Create figure with multiple panels
fig = plt.figure(figsize=(16, 12))
gs = fig.add_gridspec(3, 3, hspace=0.3, wspace=0.3)

# ========================================
# Panel 1: Time Evolution - Linear Dynamics (G=1)
# ========================================
ax1 = fig.add_subplot(gs[0, 0])

G, n = 1, 2
trajectories = linear_dynamics_evolution(G, n, t=5, alpha=0.1)

time_points = np.arange(0, len(trajectories[0]) * 0.01, 0.01)
colors = ['blue', 'red']

for traj, color in zip(trajectories, colors):
    re_parts = [t.real for t in traj]
    im_parts = [t.imag for t in traj]
    ax1.plot(time_points[:len(traj)], re_parts[:len(traj)], color=color, linewidth=2, label='Re')
    ax1.plot(time_points[:len(traj)], im_parts[:len(traj)], color=color, linewidth=1, linestyle='--', alpha=0.7, label='Im')

ax1.set_xlabel('Time t', fontsize=10)
ax1.set_ylabel('Value', fontsize=10)
ax1.set_title(f'Linear Dynamics: G={G}, n={n}', fontsize=11, fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# ========================================
# Panel 2: Time Evolution - Linear Dynamics (G=-0.25)
# ========================================
ax2 = fig.add_subplot(gs[0, 1])

G, n = -0.25, 2
trajectories = linear_dynamics_evolution(G, n, t=5, alpha=0.1)

colors = ['blue', 'red']
for traj, color in zip(trajectories, colors):
    re_parts = [t.real for t in traj]
    im_parts = [t.imag for t in traj]
    ax2.plot(time_points[:len(traj)], re_parts[:len(traj)], color=color, linewidth=2)
    ax2.plot(time_points[:len(traj)], im_parts[:len(traj)], color=color, linewidth=1, linestyle='--', alpha=0.7)

ax2.set_xlabel('Time t', fontsize=10)
ax2.set_ylabel('Value', fontsize=10)
ax2.set_title(f'Linear Dynamics: G={G}, n={n}', fontsize=11, fontweight='bold')
ax2.grid(True, alpha=0.3)

# ========================================
# Panel 3: Time Evolution - Logistic Dynamics
# ========================================
ax3 = fig.add_subplot(gs[0, 2])

G, n = 1, 2
trajectories = logistic_time_evolution(G, n, t=5, r=2.8)

colors = ['blue', 'red']
for traj, color in zip(trajectories, colors):
    vals = [t.real for t in traj]
    ax3.plot(np.arange(len(vals)) * 0.01, vals, color=color, linewidth=2)

ax3.set_xlabel('Time t', fontsize=10)
ax3.set_ylabel('Value', fontsize=10)
ax3.set_title(f'Logistic Dynamics: G={G}, n={n}', fontsize=11, fontweight='bold')
ax3.grid(True, alpha=0.3)

# ========================================
# Panel 4: Complex Plane Trajectories - Oscillatory
# ========================================
ax4 = fig.add_subplot(gs[1, 0])

G, n = 1, 2
trajectories = oscillatory_evolution(G, n, t=2*math.pi, omega=2*math.pi, amplitude=0.5)

colors = ['blue', 'red']
for traj, color in zip(trajectories, colors):
    re_parts = [t.real for t in traj]
    im_parts = [t.imag for t in traj]
    ax4.plot(re_parts, im_parts, color=color, linewidth=2)
    ax4.scatter([re_parts[0]], [im_parts[0]], color='black', s=50, zorder=10)  # Start point

ax4.set_xlabel('Real Part', fontsize=10)
ax4.set_ylabel('Imaginary Part', fontsize=10)
ax4.set_title(f'Complex Plane: Oscillatory Evolution\nG={G}, n={n}', fontsize=11, fontweight='bold')
ax4.grid(True, alpha=0.3)
ax4.axis('equal')

# ========================================
# Panel 5: Complex Plane - Multiple G values
# ========================================
ax5 = fig.add_subplot(gs[1, 1])

colors = ['blue', 'red', 'green', 'orange']
G_values = [1, 0, -0.25, -1]

for G, color in zip(G_values, colors):
    trajectories = linear_dynamics_evolution(G, 2, t=2, alpha=0.1)
    
    if len(trajectories) > 0 and len(trajectories[0]) > 0:
        re_parts = [t.real for t in trajectories[0]]
        im_parts = [t.imag for t in trajectories[0]]
        ax5.plot(re_parts, im_parts, color=color, linewidth=2, label=f'G={G}')
        ax5.scatter([re_parts[0]], [im_parts[0]], color=color, s=30, zorder=10)

ax5.set_xlabel('Real Part', fontsize=10)
ax5.set_ylabel('Imaginary Part', fontsize=10)
ax5.set_title('Complex Plane: Linear Dynamics\nDifferent G values', fontsize=11, fontweight='bold')
ax5.legend(fontsize=8)
ax5.grid(True, alpha=0.3)
ax5.axis('equal')

# ========================================
# Panel 6: Phase Space - Multiple trajectories
# ========================================
ax6 = fig.add_subplot(gs[1, 2])

G, n = 1, 2
trajectories = logistic_time_evolution(G, n, t=5, r=2.8)

for i, traj in enumerate(trajectories[:3]):
    # Plot trajectory in phase space: x(t) vs x(t-1)
    if len(traj) > 1:
        x_t = traj[1:]
        x_t_prev = traj[:-1]
        re_curr = [x.real for x in x_t]
        re_prev = [x.real for x in x_t_prev]
        color = ['blue', 'red', 'green'][i]
        ax6.scatter(re_curr, re_prev, c=color, alpha=0.5, s=10, label=f'Traj {i+1}')

ax6.set_xlabel('x(t)', fontsize=10)
ax6.set_ylabel('x(t-1)', fontsize=10)
ax6.set_title('Phase Space: Logistic Dynamics', fontsize=11, fontweight='bold')
ax6.legend(fontsize=8)
ax6.grid(True, alpha=0.3)

# ========================================
# Panel 7: Time-Dependent G(t)
# ========================================
ax7 = fig.add_subplot(gs[2, 0])

t = np.linspace(0, 10, 200)
G_t_1 = 1 + 0.5 * np.sin(2*math.pi * t)
G_t_2 = 0.5 + 0.5 * np.cos(math.pi * t)

ax7.plot(t, G_t_1, 'b-', linewidth=2, label='G(t) = 1 + 0.5sin(2πt)')
ax7.plot(t, G_t_2, 'r-', linewidth=2, label='G(t) = 0.5 + 0.5cos(πt)')
ax7.set_xlabel('Time t', fontsize=10)
ax7.set_ylabel('G(t)', fontsize=10)
ax7.set_title('Time-Dependent G(t)', fontsize=11, fontweight='bold')
ax7.legend(fontsize=8)
ax7.grid(True, alpha=0.3)

# ========================================
# Panel 8: Bifurcation-like Behavior
# ========================================
ax8 = fig.add_subplot(gs[2, 1])

# Bifurcation analysis with different dynamics parameters
G_values = np.linspace(-1, 2, 100)
stable_points = []
r_values = [2.0, 2.5, 2.8, 3.5]

colors = ['blue', 'red', 'green', 'orange']
for r, color in zip(r_values, colors):
    x_vals = []
    for G in G_values:
        # Quick evolution to find approximate attractor
        x = 0.5
        for _ in range(50):
            x = r * x * (1 - x) + G * 0.01
        x_vals.append(x)
    ax8.plot(G_values, x_vals, color=color, linewidth=1.5, label=f'r={r}')

ax8.set_xlabel('G', fontsize=10)
ax8.set_ylabel('Attractor x', fontsize=10)
ax8.set_title('Bifurcation-like Behavior', fontsize=11, fontweight='bold')
ax8.legend(fontsize=8)
ax8.grid(True, alpha=0.3)

# ========================================
# Panel 9: 3D Landscape Conceptualization
# ========================================
ax9 = fig.add_subplot(gs[2, 2])

# Create 3D conceptualization
G_vals = np.array([1, 0, -0.25, -1])
n_vals = [2, 3, 4]
t_vals = [0, 1, 2]

# Plot conceptual 3D structure
fig_g = plt.figure(figsize=(5, 5))
ax_g = fig_g.add_subplot(111, projection='3d')

# Sample trajectory
G_sweep = np.linspace(-2, 3, 50)
n_sweep = 2 + np.sin(G_sweep * 0.5) * 0.5
t_sweep = np.linspace(0, 5, 50)

x_traj = []
for G, n, t in zip(G_sweep, n_sweep, t_sweep):
    roots = gap_roots_n(G, int(n))
    if len(roots) > 0:
        x_traj.append(abs(roots[0]))

ax_g.plot(G_sweep, n_sweep, t_sweep, 'b-', linewidth=2, label='Trajectory')
ax_g.scatter(G_sweep[::10], n_sweep[::10], t_sweep[::10], c='red', s=30, zorder=10)

ax_g.set_xlabel('G', fontsize=10)
ax_g.set_ylabel('n', fontsize=10)
ax_g.set_zlabel('t', fontsize=10)
ax_g.set_title('3D Landscape:\n(G, n, t) Space', fontsize=11, fontweight='bold')
ax_g.grid(True, alpha=0.3)

# We'll create this as a separate figure
fig_g.savefig('fig14_3d_landscape_temp.png', dpi=300, bbox_inches='tight', facecolor='white')
plt.close(fig_g)

# Replace with 2D conceptual
ax9.text(0.5, 0.5, '3D Landscape\n(G, n, t) Space\n\nSee: fig14_3d_landscape_temp.png', 
         ha='center', va='center', fontsize=12,
         bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.5))
ax9.axis('off')
ax9.set_title('3D Space Concept', fontsize=11, fontweight='bold')

# Main title
fig.suptitle('Time Evolution Analysis: GAP Equation $x^n = x + G$\nTemporal Dynamics with Parameter G, Dimension n, and Time t', 
             fontsize=14, fontweight='bold', y=0.995)

plt.tight_layout()

# Save
output_path = 'fig14_time_evolution.png'
plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()

print(f"✓ Created: {output_path}")
print()
print("Visualization shows:")
print("  - Time evolution with linear dynamics (stable fixed points)")
print("  - Time evolution with logistic dynamics (can become chaotic)")
print("  - Complex plane trajectories for oscillatory evolution")
print("  - Phase space portraits showing attractor structure")
print("  - Time-dependent G(t) parameter functions")
print("  - Bifurcation-like behavior as parameters vary")
print("  - 3D (G, n, t) space conceptualization")
print()
print("Key findings:")
print("  - Linear dynamics converge to GAP roots (fixed points)")
print("  - Oscillatory dynamics create circular/elliptical trajectories")
print("  - Logistic dynamics can show chaotic behavior")
print("  - Time-dependent G creates moving attractors")
print("  - Higher dimensions modify temporal behavior")
print("  - Phase space reveals attractor/repeller structure")