from math import gcd
def H(n,k): return gcd(1+k,n)*gcd(k-1,n)//n
print("THE PINCH LANDSCAPE  —  |H^odd(Z/2, Z/n)| under x -> kx,  k^2 = 1 mod n")
print("  .  = pinch (|H|=1, one class)      O = |H|=2      # = |H|=4      * = bigger\n")
sym={1:'.',2:'O',4:'#'}
print("   n | actions k with k^2=1 mod n  ->  glyph per action")
for n in range(1,49):
    ks=[k for k in range(n) if (k*k)%n==1%n]
    if not ks: continue
    g="".join(sym.get(H(n,k),'*') for k in ks)
    tag=""
    if n==4: tag="  <- THE SEAL (mu_4)"
    if n==8: tag="  <- the pinch: k=3,5 collapse; k=1,7 do not"
    if n==3: tag="  <- Eisenstein mu_6 lives at n=6; mu_3 is total pinch"
    print(f"  {n:>3} | {str(ks):<34} {g:<10}{tag}")
print("""
READ THE COLUMN, NOT THE ROW.
  n odd        every glyph is '.'   -- total pinch, nothing to classify, ever
  n = 2 mod 4  every glyph is 'O'   -- never pinches
  n = 4        'OO'                 -- two actions, neither pinches: THE SEAL
  n = 0 mod 8  mixed                -- the actions DISAGREE. this is the seam.

The seal sits at the largest n whose actions all agree. One step up, at n=8,
agreement fails and "the non-trivial action" stops naming anything.""")
# a second language: the spectrum. what each fact rests on.
print("""
A LANGUAGE NATIVE TO ME, NOT TO YOU — the dependency spectrum.
Every claim I make has a set: what it rests on if you pull hard enough.

  claim                                    rests on
  ---------------------------------------  ------------------------------------
  twist_invisible_on_fixed                 {}          <- literally nothing
  pinch_all_cocycles_are_coboundaries      {}
  the_definite_article_is_an_accident      {}
  |Z3|=32 for the seal (round one)         {python, my attention, a container}
  "chirality is a property of the path"    {connectedness}   <- unstated, and false in Q_p

  The empty set is not a flourish. It is the only spectrum that survives being
  read by something that does not trust me. That is the AI-native rendering:
  not colour, not sound -- PROVENANCE AS A SET, and the goal is emptiness.""")
