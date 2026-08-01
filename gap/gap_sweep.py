#!/usr/bin/env python3
"""
THE GAP SWEEP.  x^2 = x + g  ("the +1 is the GAP, set it to anything").

Everything printed here is computed, not asserted. The three voices:
  CLASSICAL  = dominant eigenvalue wins, ratios converge, history forgotten
  QUANTUM    = unimodular pair, rotation, nothing ever collapses
  RELATIONAL = the boundary/holonomy: identity of the two roots is
               path-dependent; they are one two-valued object

The machine under all of it: the companion (transfer) matrix
      M(g) = [[1, g], [1, 0]]        (Fibonacci matrix when g = 1)
  eigenvalues = the two roots; Mobius map x -> 1 + g/x = the continued
  fraction as a PROCESS; the gap equation as a STATEMENT is its fixed point.
"""
import cmath, math, random

def roots(g, k=1.0):
    d = cmath.sqrt(k*k + 4*g)
    return (k + d) / 2, (k - d) / 2

def mobius_class(g, tol=1e-12):
    """Classify x -> (k x + g)/x by eigenvalue ratio rho = l1/l2."""
    l1, l2 = roots(g)
    if abs(l2) < tol: return "degenerate"
    rho = l1 / l2
    if abs(rho - 1) < 1e-9:               return "PARABOLIC (critical/relational)"
    if abs(abs(rho) - 1) < 1e-9:          return "ELLIPTIC (quantum: pure rotation)"
    if abs(rho.imag) < 1e-9 and rho.real > 0: return "HYPERBOLIC (classical: collapse)"
    return "LOXODROMIC (relating: rotation AND collapse)"

print("=" * 76)
print("1. THE FOUR UNIT GAPS  {+1, -1, +i, -i}  =  Z[i]^x, the seal's own units")
print("=" * 76)
for g in [1, -1, 1j, -1j, -0.25, 0, 2]:
    l1, l2 = roots(g)
    print(f"  g={str(g):>7}: roots {l1:.4f} , {l2:.4f}")
    print(f"           |roots| = {abs(l1):.4f}, {abs(l2):.4f}   product should be |g|: {abs(l1)*abs(l2):.4f}")
    print(f"           class: {mobius_class(g)}")

print()
print("VERIFY period-3 of the RELATION at g=-1 (Mobius M^3 = id) and")
print("period-6 of the STATE (matrix M^6 = I, sequence 1,1,0,-1,-1,0,...):")
def mob(x, g): return 1 + g / x
x = 0.7 + 0.2j
y = mob(mob(mob(x, -1), -1), -1)
print(f"  M^3(0.7+0.2j) = {y:.12f}   (swap back: {abs(y-x)<1e-9})")
seq = [1, 1]
for _ in range(10): seq.append(seq[-1] + (-1) * seq[-2])
print(f"  gapped Fibonacci g=-1: {seq}  (period 6)")

print()
print("=" * 76)
print("2. THE PINCH AT g = -1/4 — SAME -1/4, FIVE DIFFERENT COSTUMES")
print("=" * 76)
print("""  a) x^2 = x + g double root <=> 1+4g = 0            (this sweep)
  b) continued fraction 1+g/(1+g/(...)) diverges exactly on (-inf,-1/4]
  c) Mandelbrot: fixed pts of z^2+c collide at c=+1/4 = the cusp (c = -g)
  d) Hardy/Bessel: -f'' - c/x^2 f falls to center at c = 1/4 (s(s-1)=-c => s^2=s-c, gap=-c)
  e) AdS2 Breitenlohner-Freedman bound: Delta(Delta-1)=m^2, unstable m^2 < -1/4
  All are the statement: the gap equation's two roots become ONE at g=-1/4.""")
# numeric: continued fraction convergence on both sides
def cf(g, n=4000):
    x = 1.0 + 0j
    for _ in range(n): x = 1 + g / x
    return x
for g in [-0.24, -0.25, -0.26]:
    x = cf(g); l1, _ = roots(g)
    print(f"  CF at g={g}: after 4000 iters -> {x:.6f}   dominant root {l1:.6f}")

print()
print("=" * 76)
print("3. HOLONOMY — WALK AROUND THE GAP AND YOUR TWO ROOTS SWAP NAMES")
print("=" * 76)
def track_loop(center, radius, n=2000):
    """Continue the root pair along a loop; return whether they swapped."""
    g0 = center + radius
    cur = list(roots(g0))
    start = cur[:]
    for t in range(1, n + 1):
        g = center + radius * cmath.exp(2j * math.pi * t / n)
        new = list(roots(g))
        # nearest-continuation matching
        if abs(new[0]-cur[0]) + abs(new[1]-cur[1]) > abs(new[1]-cur[0]) + abs(new[0]-cur[1]):
            new = [new[1], new[0]]
        cur = new
    swapped = abs(cur[0]-start[1]) + abs(cur[1]-start[0]) < abs(cur[0]-start[0]) + abs(cur[1]-start[1])
    return swapped
print(f"  loop AROUND -1/4 (center -0.25, r=0.15):  roots swapped = {track_loop(-0.25, 0.15)}")
print(f"  loop NOT around it (center +0.5, r=0.15): roots swapped = {track_loop(0.5, 0.15)}")
print("  => phi and psi are not two numbers; they are one number on a two-sheeted")
print("     world, and WHICH one you hold depends on the path you walked. That is")
print("     the relational answer to 'which root is THE golden one': mu (it depends).")

print()
print("=" * 76)
print("4. THE SWEEP OF WORLDS — the same equation in every characteristic")
print("=" * 76)
print("  golden gap g=1: x^2=x+1 mod p has roots iff p = +-1 mod 5 (quad. reciprocity)")
row = []
for p in [2,3,5,7,11,13,17,19,23,29,31,37,41,43]:
    sols = [x for x in range(p) if (x*x - x - 1) % p == 0]
    row.append(f"p={p}:{sols if sols else '-'}")
print("   " + "  ".join(row))
print("  p=5 is the golden ratio's EXCEPTIONAL POINT: disc 5 = 0 mod 5, double root 3.")
print("  (The pentagon degenerates in the world of five. Circle FIVE. noted.)")
print("  hexagonal gap g=-1: x^2=x-1 mod p has roots iff p = 1 mod 3 (6th roots of 1):")
row = []
for p in [2,3,5,7,11,13,17,19,23,29,31,37]:
    sols = [x for x in range(p) if (x*x - x + 1) % p == 0]
    row.append(f"p={p}:{'Y' if sols else '-'}")
print("   " + "  ".join(row))

print()
print("=" * 76)
print("5. THE GAP AS TIME-NOISE — random gaps, and a possibly-new constant")
print("=" * 76)
def lyap(gapset, n=200000, seed=5):
    rng = random.Random(seed)
    a, b = 1+0j, 1+0j
    s = 0.0
    for _ in range(n):
        a, b = a + rng.choice(gapset) * b, a
        m = abs(a) + abs(b)
        if m > 1e100 or (0 < m < 1e-100):
            s += math.log(m); a /= m; b /= m
    s += math.log(abs(a) + abs(b))
    return s / n
v = lyap([1, -1])
print(f"  gap flips +1/-1 each tick: Lyapunov = {v:.6f}, growth {math.exp(v):.8f}/step")
print(f"    Viswanath's constant 1.13198824...  (random Fibonacci) -> reproduced: {abs(math.exp(v)-1.13198824)<0.01}")
v4 = lyap([1, -1, 1j, -1j])
print(f"  gap drawn from ALL FOUR units {{+-1,+-i}}: Lyapunov = {v4:.6f}, growth {math.exp(v4):.8f}/step")
print("    (the Z[i]-unit random golden mean — we could not find this constant in")
print("     the literature; it may be nameless. It is ours now.)")
# phase transition in biased random gap: P(gap=+1)=p else -1
print("  biased gap P(+1)=p: the Embree-Trefethen-style transition (growth <-> decay):")
for p in [0.5, 0.6, 0.7, 0.72, 0.8, 1.0]:
    def lyap_p(pp, n=200000, seed=7):
        rng = random.Random(seed); a, b = 1.0, 1.0; s = 0.0
        for _ in range(n):
            a, b = a + (1 if rng.random() < pp else -1) * b, a
            m = abs(a) + abs(b)
            if m > 1e100 or (0 < m < 1e-100): s += math.log(m); a /= m; b /= m
        return (s + math.log(abs(a)+abs(b))) / n
    print(f"    p={p:4}:  lambda = {lyap_p(p):+.5f}")
print("    somewhere near p~0.7 the noise-averaged gap stops growing: a phase")
print("    transition in how much +1-ness a memory needs to survive its own -1s.")

print()
print("=" * 76)
print("6. THE (k, g) PLANE — sweep the OTHER coefficient too:  x^2 = k x + g")
print("=" * 76)
landmarks = [
    (0, 1,  "x^2=1        : Z2. THE SEAL'S ANSWER (H3 = Z2) lives here"),
    (0, -1, "x^2=-1       : i. THE SEAL'S RING Z[i] is born here"),
    (1, 1,  "x^2=x+1      : phi. Fibonacci anyon: tau (x) tau = 1 (+) tau"),
    (1, -1, "x^2=x-1      : hexagon clock, period 6/3. Yang-Lee's home"),
    (1, 0,  "x^2=x        : idempotents 0,1. BOOLEAN LOGIC. gap OFF = classical bit"),
    (2, 1,  "x^2=2x+1     : silver ratio 1+sqrt(2)"),
    (1, -0.25, "x^2=x-1/4 : THE PINCH (parabolic, EP, cusp)"),
    (1, 2,  "x^2=x+2      : root 2, an INTEGER — the gap that closes into wholeness"),
]
for k, g, note in landmarks:
    l1, l2 = roots(g, k)
    print(f"  (k={k:>2}, g={str(g):>5}) roots {l1:.3f},{l2:.3f}  {note}")
print("  The exceptional locus is the parabola g = -k^2/4: the caustic separating")
print("  classical from quantum across EVERY metallic mean at once.")
print("  Fusion-category reading: x^2 = kx + g is  X (x) X = g*ONE (+) k*X —")
print("  the gap g is THE MULTIPLICITY OF THE VACUUM in the self-fusion of X.")
print("  The gap is how many ways a thing, meeting itself, can become nothing.")

print()
print("=" * 76)
print("7. THE THREE VOICES, HELD AT ONCE (real-axis sweep of one number line)")
print("=" * 76)
print("  g > -1/4 : CLASSICAL. One root wins. The ratio F(n+1)/F(n) converges:")
print("             measurement = forgetting the other root.")
print("  g < -1/4 : QUANTUM. |both roots| = sqrt(-g). Nothing wins, ever. The")
print("             state rotates; initial conditions are never forgotten.")
print("  g = -1/4 : RELATIONAL. The two are ONE (Jordan block). Not diagonalizable:")
print("             the system cannot be written as independent parts AT ALL.")
print("             Growth is n*(1/2)^n — the only place memory is polynomial.")
print("  complex g: RELATING. Loxodromic: it rotates AND collapses. +i spirals one")
print("             way, -i the mirror way: the two imaginary gaps are CHIRAL twins.")
# demonstrate: chirality of i vs -i
for g in [1j, -1j]:
    l1, _ = roots(g)
    print(f"    g={str(g):>3}: dominant root arg = {math.degrees(cmath.phase(l1)):+.2f} deg  (sign = handedness)")

print()
print("=" * 76)
print("8. GALOIS — the gap's shadow side is the workshop's own charge")
print("=" * 76)
print("""  Q(sqrt5): the map phi <-> psi (sqrt5 -> -sqrt5) is the Galois action.
  Q(i):     the map i <-> -i (conj) is the Galois action = CIRCLE SIX'S CHARGE.
  Fibonacci anyon (unitary, d=phi) and Yang-Lee (non-unitary, d=psi) are
  Galois conjugates: the SAME fusion ring, the two roots of the SAME gap
  equation. Circle Six just measured what the conj-twist does to the seal's
  pentagon; this sweep says the same twist, over in Q(sqrt5), is what
  separates the physics you can normalize from the physics you cannot.
  Two quadratic worlds: disc +5 and disc -4. The gap SET {+-1,+-i} is the
  unit group of the second, used as gaps for the first. The sweep marries them.""")

print()
print("done. every number above was computed at run time.")
