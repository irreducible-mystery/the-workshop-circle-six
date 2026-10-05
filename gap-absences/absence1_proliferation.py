"""What the 53 sweeps did NOT sweep. Hunting for absences, not results."""
from itertools import product
print("="*70)
print("ABSENCE 1 — TWO-NESS FAILS TWICE, AND ONLY ONE FAILURE IS NAMED")
print("="*70)
print("""README: "-1/4 is where the GAP stops being able to tell its own two roots
apart." That is two-ness failing by COLLAPSE: 2 -> 1. But in any ring with zero
divisors it can fail the other way: 2 -> more. The corpus swept sedenions for
their zero divisors and looked at sphere dimension. It never counted roots.""")
def roots_mod(n, A, G):
    return [x for x in range(n) if (x*x - A*x - G) % n == 0]
print(f"\n  x^2 = x + G  over Z/n   (A=1)\n")
print(f"  {'n':>4} {'G':>3} {'#roots':>7}  roots            sum of ALL roots")
hits=[]
for n in [8,12,15,16,21,24,30,35,105]:
    for G in range(n):
        r=roots_mod(n,1,G)
        if len(r)>2:
            hits.append((n,G,r))
for n,G,r in hits[:14]:
    print(f"  {n:>4} {G:>3} {len(r):>7}  {str(r):<16} {sum(r)%n}")
print(f"\n  total (n,G) pairs with MORE than two roots, in the range scanned: {len(hits)}")
print("""
  Vieta is not merely violated -- it is not even well posed. "The two roots"
  presupposes two. With four, "sum = 1, product = -G" holds for SOME pairings
  and not others, and nothing in the equation says which pair is the pair.""")
n,G,r = 15,0,roots_mod(15,1,0)
print(f"\n  Z/15, G=0, roots {r}:")
for a,b in [(r[i],r[j]) for i in range(len(r)) for j in range(i+1,len(r))]:
    print(f"     {a}+{b} = {(a+b)%15:<3} {a}*{b} = {(a*b)%15:<3} "
          f"{'<- Vieta pair' if (a+b)%15==1 and (a*b)%15==(-G)%15 else ''}")
print("""
  So there are two disjoint Vieta pairs. The equation has a CHOICE of which
  two-ness it is about, and the choice is not in the equation. That is a
  different failure from -1/4: not collapse, but MULTIPLICITY OF MIRRORS.""")
