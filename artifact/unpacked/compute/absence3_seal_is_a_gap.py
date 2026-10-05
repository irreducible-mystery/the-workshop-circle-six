"""ABSENCE 3 — the GAP corpus and lean/C6_SEED.lean share a repo and have never
   been pointed at each other. The seal IS a gap value."""
from math import gcd
print("="*70)
print("ABSENCE 3 — THE SEAL IS A GAP, AND IT IS ONE OF EXACTLY TWO SPECIAL ONES")
print("="*70)
print("""Generalise as the corpus already did: <>^2 = A<> + G, discriminant D = A^2+4G.
The room the roots live in is Q(sqrt D). So the GAP sweep IS a sweep over
quadratic fields, indexed by D.

  golden gap  (A,G) = (1, 1)   D =  5   Q(sqrt5)     phi
  critical    (A,G) = (1,-1/4) D =  0   degenerate   the branch point
  Eisenstein  (A,G) = (1,-1)   D = -3   Q(sqrt-3)    e^{+-i pi/3}
  THE SEAL    (A,G) = (0,-1)   D = -4   Q(i)         +-i     <-- lean/C6_SEED.lean

The seal's coefficient group is Z[i]^x. That is the UNIT GROUP of the ring of
integers at D = -4. So ask the question the corpus never asked:

     as the gap sweeps, what happens to the UNIT GROUP?""")
def units_imag(D):
    """|O_K^x| for imaginary quadratic discriminant D<0"""
    if D==-3: return 6
    if D==-4: return 4
    return 2
def is_disc(D):
    if D>=0: return False
    return D%4 in (0,1)
print(f"\n  {'D':>6} {'field':<14} {'|units|':>8}  units                  sigma acts on units")
rows=[]
for D in range(-1,-45,-1):
    if not is_disc(D): continue
    n=units_imag(D)
    if D==-3: u="mu_6 = <e^{i pi/3}>"; act="fixes mu_2, moves 4"
    elif D==-4: u="mu_4 = {1,i,-1,-i}"; act="fixes mu_2, moves +-i"
    else: u="mu_2 = {1,-1}"; act="TRIVIAL -- fixes everything"
    rows.append((D,f"Q(sqrt{D})",n,u,act))
for D,f,n,u,act in rows[:12]:
    print(f"  {D:>6} {f:<14} {n:>8}  {u:<22} {act}")
print(f"  ... and every remaining D < -4 is the same: |units| = 2, sigma trivial on them.")
print("""
  ===> THE UNIT GROUP EXCEEDS {1,-1} AT EXACTLY TWO GAPS IN THE WHOLE
       IMAGINARY QUADRATIC UNIVERSE: D = -3 and D = -4.

  Circle Five built its entire classification on Z[i]^x -- one of the two.

  Consequence for the charge. Circle Six's finding is that sigma is INVISIBLE on
  the real units {1,-1} and VISIBLE on {i,-i}. That finding REQUIRES units
  outside {1,-1}. So:

     D = -4  (the seal)     mu_4 : sigma has a 2-element fixed set and a
                                   2-element free orbit -> the finding exists
     D = -3  (Eisenstein)   mu_6 : sigma fixes mu_2, moves the other four
                                   -> the finding would exist, differently
     every other D < -4     mu_2 : sigma fixes EVERYTHING
                                   -> there is no finding. Nothing to see.
                                   Not overlooked -- ABSENT.

  Five circles did not fail to ask the question at a generic gap. At a generic
  gap the question has no content. The record is sitting on one of the two
  discriminants in the entire family where the non-trivial action can do
  anything at all, and nobody noticed that either.""")
print("""
  And the real-quadratic side, which nobody has touched at all:""")
def fund_unit_norm(D):
    """crude: does the fundamental unit of Q(sqrtD) have norm -1? via Pell"""
    import math
    m=D if D%4==1 else D//4
    # search x^2 - m y^2 = +-1
    for y in range(1,4000):
        s=m*y*y
        for t in (-1,1):
            x2=s+t
            x=int(math.isqrt(x2))
            if x*x==x2 and x>0: return t
    return None
print(f"  {'D':>5} {'field':<12} norm of fundamental unit   unit group")
for D in [5,8,12,13,17,21,24,28,29]:
    if D%4 not in (0,1): continue
    nm=fund_unit_norm(D)
    print(f"  {D:>5} Q(sqrt{D:<5}) {str(nm):>18}          INFINITE (rank 1)")
print("""
  For D > 0 the unit group is infinite. sigma acts on an infinite group, the
  fixed subgroup is {1,-1}, and the quotient is infinite. Every cohomology
  computation in the seal would be a DIFFERENT KIND OF OBJECT. The golden gap
  D = 5 -- the one the whole prompt starts from -- is on this side.

  ===> The seal chose the ONE regime where the coefficient group is finite,
       non-trivial, and acted on non-trivially. The golden gap is not in it.""")
