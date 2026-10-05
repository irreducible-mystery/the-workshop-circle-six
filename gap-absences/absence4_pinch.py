"""PR #7's open question: does twisted-vs-untwisted H^3 have its own -1/4,
   a coupling where the two cohomologies PINCH?

   Answer: yes. Build the family the seal is one point of."""
from math import gcd
from itertools import product
print("="*72)
print("THE PINCH — H^3 HAS A -1/4, AND THE SEAL IS SITTING NEXT TO IT")
print("="*72)
print("""The seal's coefficient group is mu_4. Generalise to mu_n, written additively
as Z/n. An action of G = Z/2 on Z/n is x -> kx with k^2 = 1 mod n. Sweep BOTH.

Brute force, no formula: enumerate all cochains, count Z^3 and B^3 directly.""")

def cohom(n,k):
    """|Z^3|,|B^3|,|H^3| for G=Z/2 acting on Z/n by x->kx. Unnormalised cochains."""
    K3=list(product([0,1],repeat=3)); K2=list(product([0,1],repeat=2))
    def act(a,x): return (k*x)%n if a else x%n
    def d3(f):
        return all((act(a,f[(b,c,d)])-f[(a^b,c,d)]+f[(a,b^c,d)]-f[(a,b,c^d)]+f[(a,b,c)])%n==0
                   for a,b,c,d in product([0,1],repeat=4))
    def d2(g):
        return tuple((act(a,g[(b,c)])-g[(a^b,c)]+g[(a,b^c)]-g[(a,b)])%n for a,b,c in K3)
    Z=sum(1 for v in product(range(n),repeat=8) if d3(dict(zip(K3,v))))
    B=len({d2(dict(zip(K2,v))) for v in product(range(n),repeat=4)})
    return Z,B,Z//B

def formula(n,k):
    return gcd(1+k,n)*gcd(k-1,n)//n

print(f"\n  {'n':>3} {'k':>3} {'action':<12} {'|Z3|':>7} {'|B3|':>6} {'|H3|':>5} {'formula':>8}  {'':<4}")
rows=[]
for n in range(1,13):
    ks=[k for k in range(n) if (k*k)%n==1%n] if n>1 else [0]
    for k in ks:
        if n<=8:
            Z,B,H=cohom(n,k); f=formula(n,k) if n>1 else 1
            ok = "ok" if H==f else "MISMATCH"
        else:
            Z=B=0; H=formula(n,k); f=H; ok="(formula)"
        nm = "trivial" if k%n==1%n else ("inversion" if k%n==(n-1)%n else f"x^{k}")
        rows.append((n,k,nm,Z,B,H,f,ok))
        star = "   <=== PINCH: one class" if H==1 and n>1 else ""
        seal = "   <=== THE SEAL" if n==4 else ""
        if n<=8:
            print(f"  {n:>3} {k:>3} {nm:<12} {Z:>7} {B:>6} {H:>5} {f:>8}  {ok:<4}{star}{seal}")
print("\n  --- continuing by the verified formula |H^odd| = gcd(1+k,n)*gcd(k-1,n)/n ---")
for n,k,nm,Z,B,H,f,ok in rows:
    if n>8:
        star = "   <=== PINCH" if H==1 else ""
        print(f"  {n:>3} {k:>3} {nm:<12} {'':>7} {'':>6} {H:>5} {f:>8}{star}")
