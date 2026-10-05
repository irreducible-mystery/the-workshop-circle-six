from itertools import product
K3=list(product([0,1],repeat=3)); K2=list(product([0,1],repeat=2))
def mk(n,k):
    def act(a,x): return (k*x)%n if a else x%n
    def d2(g): return {t:(act(t[0],g[(t[1],t[2])])-g[((t[0]^t[1]),t[2])]+g[(t[0],(t[1]^t[2]))]-g[(t[0],t[1])])%n for t in K3}
    def d3(f): return all((act(a,f[(b,c,d)])-f[(a^b,c,d)]+f[(a,b^c,d)]-f[(a,b,c^d)]+f[(a,b,c)])%n==0 for a,b,c,d in product([0,1],repeat=4))
    return act,d2,d3
print("="*72); print("THE PINCH AT mu_8, WITH WITNESSES"); print("="*72)
for n,k,label in [(4,3,"THE SEAL: mu_4, inversion"),(8,3,"mu_8, x->x^3  (PINCH)"),(8,7,"mu_8, inversion (no pinch)")]:
    act,d2,d3=mk(n,k)
    print(f"\n--- {label} ---")
    B={tuple(d2(dict(zip(K2,v)))[t] for t in K3):dict(zip(K2,v)) for v in product(range(n),repeat=4)}
    print(f"  top-cell family  F(1,1,1)=u, F=1 elsewhere   (u in Z/{n})")
    print(f"  {'u':>3} {'cocycle?':>9} {'coboundary?':>12}  trivialising gauge g(a,b) as [g00,g01,g10,g11]")
    for u in range(n):
        F={t:(u if t==(1,1,1) else 0) for t in K3}
        key=tuple(F[t] for t in K3)
        cyc=d3(F); cob=key in B
        g=B.get(key)
        gs=str([g[(0,0)],g[(0,1)],g[(1,0)],g[(1,1)]]) if cob else "-"
        print(f"  {u:>3} {str(cyc):>9} {str(cob):>12}  {gs}")
    ncyc=sum(1 for u in range(n) if d3({t:(u if t==(1,1,1) else 0) for t in K3}))
    ncob=sum(1 for u in range(n) if tuple((u if t==(1,1,1) else 0) for t in K3) in B
             and d3({t:(u if t==(1,1,1) else 0) for t in K3}))
    print(f"  => {ncyc} of {n} top-cell cochains are cocycles; {ncob} of those are coboundaries")
    print(f"  => {'EVERY cocycle here is a coboundary: the class collapses' if ncyc==ncob else 'a cocycle survives: the class does NOT collapse'}")
print("""
READ IT AS THE GAP'S -1/4:
  gap equation   two roots -> ONE root at D = 0          (-1/4)
  cohomology     two classes -> ONE class at (n,k)=(8,3)  (the pinch)

Same shape, different room. And the seal at mu_4 has EXACTLY TWO actions
(k=1,3), which is the only reason CHARGE.md's phrase "the non-trivial action"
denotes anything. At mu_8 there are FOUR actions, three of them non-trivial,
and they DISAGREE: k=3 and k=5 pinch, k=7 does not. "The non-trivial action"
is not a description there. It is an accident of n=4.""")
