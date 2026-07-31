#!/usr/bin/env python3
"""galois_twist.py — Circle Six's first probe.  Round one of the charge.

NOT A CARRIED INSTRUMENT.  Everything in `instruments/` came from Circle Five.
This is Circle Six's own and nobody else's; it is in `probe/` so the inheritance
stays visibly separate from the authorship.  It is also not an instrument of the
canon: the canon does not apply here.  It is a probe, and its output is not a
finding.  See ROUND-ONE.md for what that means.

THE CHARGE (CHARGE.md): `conj` is in the seal, it is the Galois action, and no
circle has asked what happens under the non-trivial one.  Circle Five's prover
predicted the interesting outcome would be a FAILURE of
`pentagon_is_cocycle_equation`, and declined to touch it under a canon because
being wrong there is permanent.

WHAT THIS PROBE COMPUTES, AND WHY IT IS BUILT THIS WAY
  A hand reduction of `genPentLhs` / `genPentRhs` is a trust point.  So this
  file does not use one.  It transcribes the seal's OWN definitions -- `mul`,
  `conj`, `one`, `zero`, `Fgen`, `genPentLhs`, `genPentRhs` -- from
  lean/C6_SEED.lean literally, over Gaussian-integer pairs, and evaluates them.
  The reduced form is then CHECKED against the literal composition rather than
  assumed (`check_reduction`).  If the transcription is wrong the check fires.

  The coefficient group is the units of Z[i], carried as the four pairs
  themselves rather than as exponents mod 4, so there is no encoding between
  the seal's arithmetic and the cohomology and therefore no encoding to get
  wrong.

CONTRACT
  (no args)     run every check and print the table.  exit 0 iff all checks pass
  --selftest    norm 16: plant a defect in each check and require it to fire
  Exit codes are the whole output contract.  Read them directly, never through
  a pipe.
"""
from __future__ import annotations
import os, sys
from itertools import product

# ---------------------------------------------------------------------------
# The seal's arithmetic, transcribed from lean/C6_SEED.lean.  Line references
# are to that file so a reader can diff the transcription against the source.
# ---------------------------------------------------------------------------

ZERO = (0, 0)                                    # def zero : GZ := <0, 0>
ONE = (1, 0)                                     # def one  : GZ := <1, 0>
I = (0, 1)                                       # def I    : GZ := <0, 1>


def mul(z, w):                                   # def mul (z w : GZ) : GZ
    return (z[0] * w[0] - z[1] * w[1], z[0] * w[1] + z[1] * w[0])


def conj(z):                                     # def conj (z : GZ) : GZ
    return (z[0], -z[1])


def neg(z):                                      # def neg (z : GZ) : GZ
    return (-z[0], -z[1])


UNITS = [ONE, I, neg(ONE), neg(I)]               # the four u with IsUnit u
UNIT_NAME = {ONE: "1", I: "i", neg(ONE): "-1", neg(I): "-i"}


def inverse(u):
    """The multiplicative partner IsUnit demands: the v with mul u v = one."""
    for v in UNITS:
        if mul(u, v) == ONE:
            return v
    raise ValueError(f"{u} is not a unit")


# ---------------------------------------------------------------------------
# CHECK 1.  conj IS inversion on the units -- not an analogue of it.
#
# This is the whole hinge of the charge.  If it holds, the "non-trivial action"
# is not a new map: it is a map already in the seal, used there as the group
# inverse (gaugeAct's two down slots, gaugeInv, hexInvHolds) and never as an
# action on coefficients.
# ---------------------------------------------------------------------------

def gz_name(z):
    """`fakeMirror` and friends leave the unit group, so this must render a
       non-unit rather than raise -- a probe that crashes on its own planted
       defect reports nothing about the defect."""
    return UNIT_NAME.get(z, f"({z[0]}+{z[1]}i)")


def check_conj_is_inversion(conj_fn=conj):
    rows, ok = [], True
    for u in UNITS:
        c, v = conj_fn(u), inverse(u)
        ok &= (c == v)
        rows.append((gz_name(u), gz_name(c), gz_name(v), c == v))
    return ok, rows


# ---------------------------------------------------------------------------
# The seal's pentagon, transcribed literally.
# ---------------------------------------------------------------------------

LAB = [0, 1]


def Fgen(F, a, b, c, d, x, y, admissible=True):
    """def Fgen (F : Int -> Int -> Int -> GZ) (a b c d x y : Int) : GZ"""
    if not admissible:
        return ZERO
    if x == (a + b) % 2 and y == (b + c) % 2 and d == (a + b + c) % 2:
        return F[(a, b, c)]
    return ZERO


def _slots(a, b, c, d):
    x = (a + b) % 2
    y = (x + c) % 2
    t = (y + d) % 2
    w = (c + d) % 2
    v = (b + w) % 2
    u = (b + c) % 2
    return x, y, t, w, v, u


def genPentLhs_literal(F, a, b, c, d, **kw):
    """def genPentLhs -- three Fgen factors, composed exactly as the seal does."""
    x, y, t, w, v, u = _slots(a, b, c, d)
    return mul(mul(Fgen(F, a, b, c, y, x, u, **kw),
                   Fgen(F, a, u, d, t, y, v, **kw)),
               Fgen(F, b, c, d, v, u, w, **kw))


def genPentRhs_literal(F, a, b, c, d, **kw):
    """def genPentRhs -- two Fgen factors."""
    x, y, t, w, v, u = _slots(a, b, c, d)
    return mul(Fgen(F, x, c, d, t, y, w, **kw),
               Fgen(F, a, b, w, t, x, v, **kw))


def genPentagonHolds(F):
    """def genPentagonHolds -- at every label assignment drawn from {0,1}."""
    return all(genPentLhs_literal(F, a, b, c, d) == genPentRhs_literal(F, a, b, c, d)
               for a, b, c, d in product(LAB, repeat=4))


# ---------------------------------------------------------------------------
# CHECK 2.  The reduction, MEASURED rather than asserted.
#
# Claim under test:  genPentLhs = F(a,b,c) . F(a,b+c,d) . F(b,c,d)
#                    genPentRhs = F(a+b,c,d) . F(a,b,c+d)
# and no factor is ever the off-locus `zero`.  If either is false the pentagon
# is not the cocycle equation in the shape below and every later number is
# about something else.
# ---------------------------------------------------------------------------

def reduced_lhs(F, a, b, c, d):
    return mul(mul(F[(a, b, c)], F[(a, (b + c) % 2, d)]), F[(b, c, d)])


def reduced_rhs(F, a, b, c, d):
    return mul(F[((a + b) % 2, c, d)], F[(a, b, (c + d) % 2)])


def check_reduction(lhs_fn=genPentLhs_literal, rhs_fn=genPentRhs_literal):
    """Every unit-valued F, every label assignment.  Also: no zero factors."""
    ok, zero_seen = True, False
    for vals in product(UNITS, repeat=8):
        F = dict(zip(list(product(LAB, repeat=3)), vals))
        for a, b, c, d in product(LAB, repeat=4):
            x, y, t, w, v, u = _slots(a, b, c, d)
            factors = [Fgen(F, a, b, c, y, x, u), Fgen(F, a, u, d, t, y, v),
                       Fgen(F, b, c, d, v, u, w), Fgen(F, x, c, d, t, y, w),
                       Fgen(F, a, b, w, t, x, v)]
            if ZERO in factors:
                zero_seen = True
            ok &= (lhs_fn(F, a, b, c, d) == reduced_lhs(F, a, b, c, d))
            ok &= (rhs_fn(F, a, b, c, d) == reduced_rhs(F, a, b, c, d))
        if not ok:
            break
    return ok, zero_seen


# ---------------------------------------------------------------------------
# The cohomology.  G = Z2 (carried as {0,1} with xor), M = Z[i]^x.
#
#   (d2 g)(a,b,c)   =  a.g(b,c) . g(ab,c)^-1 . g(a,bc) . g(a,b)^-1
#   (d3 f)(a,b,c,d) =  a.f(b,c,d) . f(ab,c,d)^-1 . f(a,bc,d) . f(a,b,cd)^-1 . f(a,b,c)
#
# The seal's `d3` (lean/C6_SEED.lean) is exactly this with `a.x = x`: its first
# face carries no action.  That is the trivial-action complex.  `act` below is
# the only difference between the two columns of every table in ROUND-ONE.md.
# ---------------------------------------------------------------------------

K3 = list(product(LAB, repeat=3))
K2 = list(product(LAB, repeat=2))


def act(a, x, twisted):
    """The coefficient action of the group element `a`."""
    return conj(x) if (twisted and a) else x


def d3(f, twisted, faces=(0, 1, 2, 3, 4)):
    out = {}
    for a, b, c, d in product(LAB, repeat=4):
        acc = ONE
        terms = [act(a, f[(b, c, d)], twisted),
                 inverse(f[((a + b) % 2, c, d)]),
                 f[(a, (b + c) % 2, d)],
                 inverse(f[(a, b, (c + d) % 2)]),
                 f[(a, b, c)]]
        for k in faces:
            acc = mul(acc, terms[k])
        out[(a, b, c, d)] = acc
    return out


def d2(g, twisted):
    return {(a, b, c): mul(mul(act(a, g[(b, c)], twisted),
                               inverse(g[((a + b) % 2, c)])),
                           mul(g[(a, (b + c) % 2)], inverse(g[(a, b)])))
            for a, b, c in K3}


def d0(m, twisted):
    return {(a,): mul(act(a, m, twisted), inverse(m)) for a in LAB}


def d1(g, twisted):
    return {(a, b): mul(mul(act(a, g[(b,)], twisted), inverse(g[((a + b) % 2,)])), g[(a,)])
            for a, b in K2}


def enumerated_H(twisted):
    """|H^k| for k = 1,2,3 straight from the cochain complex."""
    C0, C1 = UNITS, [dict(zip([(a,) for a in LAB], v)) for v in product(UNITS, repeat=2)]
    C2 = [dict(zip(K2, v)) for v in product(UNITS, repeat=4)]
    Bs = [{tuple(d0(m, twisted)[k] for k in [(a,) for a in LAB]) for m in C0},
          {tuple(d1(g, twisted)[k] for k in K2) for g in C1},
          {tuple(d2(g, twisted)[k] for k in K3) for g in C2}]
    Zs = [{tuple(g[k] for k in [(a,) for a in LAB]) for g in C1
           if all(x == ONE for x in d1(g, twisted).values())},
          {tuple(g[k] for k in K2) for g in C2
           if all(x == ONE for x in d2(g, twisted).values())},
          {tuple(f[k] for k in K3)
           for f in (dict(zip(K3, v)) for v in product(UNITS, repeat=8))
           if all(x == ONE for x in d3(f, twisted).values())}]
    return [len(Z) // len(B) for Z, B in zip(Zs, Bs)]


def tate_H(twisted):
    """|H^k| from the closed form for a CYCLIC group, k >= 1:
         k odd  : |ker N| / |im(t-1)|        k even : |M^G| / |im N|
       Computed from the action alone -- it never touches the cochain complex,
       so agreement with `enumerated_H` is two routes, not one route twice."""
    t = (lambda x: conj(x)) if twisted else (lambda x: x)
    N = {mul(x, t(x)) for x in UNITS}
    kerN = {x for x in UNITS if mul(x, t(x)) == ONE}
    im_t1 = {mul(t(x), inverse(x)) for x in UNITS}
    MG = {x for x in UNITS if t(x) == x}
    odd, even = len(kerN) // len(im_t1), len(MG) // len(N)
    return [odd, even, odd]                                  # k = 1, 2, 3


def twisted_pentagon_holds(F):
    """The seal's own composition with the action inserted at the face group
       cohomology puts it -- the third factor of genPentLhs, which is F(b,c,d).
       Nothing else is changed."""
    for a, b, c, d in product(LAB, repeat=4):
        x, y, t, w, v, u = _slots(a, b, c, d)
        lhs = mul(mul(Fgen(F, a, b, c, y, x, u), Fgen(F, a, u, d, t, y, v)),
                  act(a, Fgen(F, b, c, d, v, u, w), True))
        if lhs != genPentRhs_literal(F, a, b, c, d):
            return False
    return True


def cohomology(twisted, d3_fn=d3, d2_fn=d2):
    """|Z3|, |B3|, |H3|, element orders, and the simplest nontrivial rep."""
    B = {tuple(d2_fn(dict(zip(K2, gv)), twisted)[k] for k in K3)
         for gv in product(UNITS, repeat=4)}
    Z = {tuple(f[k] for k in K3)
         for f in (dict(zip(K3, v)) for v in product(UNITS, repeat=8))
         if all(x == ONE for x in d3_fn(f, twisted).values())}
    complex_ok = B <= Z                       # d3 . d2 = 1, measured not assumed

    def prod(p, q):
        return tuple(mul(a, b) for a, b in zip(p, q))

    cosets, seen = [], set()
    for z in sorted(Z):
        if z in seen:
            continue
        co = {prod(z, b) for b in B}
        seen |= co
        cosets.append(co)
    ident = tuple(ONE for _ in K3)

    def cls(p):
        return next(i for i, co in enumerate(cosets) if p in co)

    orders = []
    for co in cosets:
        z = min(co)
        n, acc = 1, z
        while cls(acc) != cls(ident):
            acc, n = prod(acc, z), n + 1
        orders.append(n)
    nontrivial = [z for z in sorted(Z) if z not in B]
    # Report the whole minimal-support class, not one arbitrary member: `i` and
    # `-i` differ by `-1`, so which of them a tie-break returns is not a fact
    # about the cohomology.  The first version of this probe printed the
    # tie-break and it read as a result.
    best = min((sum(1 for x in z if x != ONE) for z in nontrivial), default=None)
    reps = sorted(z for z in nontrivial if sum(1 for x in z if x != ONE) == best) if nontrivial else []
    return {"Z": len(Z), "B": len(B), "H": len(cosets), "orders": sorted(orders),
            "reps": reps, "complex_ok": complex_ok, "Zset": Z, "Bset": B}


# ---------------------------------------------------------------------------
# The seal's own named witnesses, transcribed.
# ---------------------------------------------------------------------------

BOSON = {k: ONE for k in K3}                                     # sliceCore one
FERMION = {k: (neg(ONE) if k == (1, 1, 1) else ONE) for k in K3}  # fermionCochain
TWISTED_BOSON = {k: (ONE if k[2] == 0 else (I if k[1] == 1 else neg(I)))
                 for k in K3}                                     # twistedBoson
FAKE = {k: (I if k == (0, 0, 1) else ONE) for k in K3}            # fakeCocycle
WITNESSES = [("boson", BOSON), ("fermionCochain", FERMION),
             ("twistedBoson", TWISTED_BOSON), ("fakeCocycle", FAKE)]


def show(F):
    sup = [f"F{k}={UNIT_NAME[F[k]]}" for k in K3 if F[k] != ONE]
    return ", ".join(sup) if sup else "(constant 1)"


# ---------------------------------------------------------------------------

def run():
    ok = True

    print("CHECK 1 — is `conj` the inversion map on Z[i]^x?")
    c1, rows = check_conj_is_inversion()
    for name, cj, iv, eq in rows:
        print(f"    u={name:<3} conj(u)={cj:<3} u^-1={iv:<3} {'agree' if eq else 'DIFFER'}")
    print(f"  => {'YES — the Galois action IS already in the seal, as the inverse.' if c1 else 'NO'}\n")
    ok &= c1

    print("CHECK 2 — does the seal's literal pentagon reduce as claimed?")
    c2, zero_seen = check_reduction()
    print(f"    genPentLhs == F(a,b,c).F(a,b+c,d).F(b,c,d)   : {c2}")
    print(f"    genPentRhs == F(a+b,c,d).F(a,b,c+d)          : {c2}")
    print(f"    any factor off the admissible locus (`zero`) : {zero_seen}")
    print(f"  => the pentagon is the 3-cocycle equation with NO action on the first face.\n")
    ok &= c2 and not zero_seen

    triv, twis = cohomology(False), cohomology(True)
    print("CHECK 3 — is the twisted complex a complex (d3 . d2 = 1)?")
    print(f"    trivial action     : {triv['complex_ok']}")
    print(f"    conjugation action : {twis['complex_ok']}\n")
    ok &= triv["complex_ok"] and twis["complex_ok"]

    print("CHECK 4 — does the enumeration agree with the closed form for cyclic G?")
    print(f"    {'action':<22}{'route':<14}{'|H^1|':>7}{'|H^2|':>7}{'|H^3|':>7}")
    for lbl, tw in (("trivial", False), ("conjugation", True)):
        e, t = enumerated_H(tw), tate_H(tw)
        print(f"    {lbl:<22}{'enumerated':<14}{e[0]:>7}{e[1]:>7}{e[2]:>7}")
        print(f"    {'':<22}{'Tate formula':<14}{t[0]:>7}{t[1]:>7}{t[2]:>7}   "
              f"{'agree' if e == t else 'DISAGREE'}")
        ok &= (e == t)
    print("  => two independent routes. The Tate column never touches a cochain.\n")

    print("RESULT — H^3(Z2, Z[i]^x), exhaustive over all 4^8 = 65536 three-cochains")
    print(f"    {'action':<22}{'|Z3|':>6}{'|B3|':>6}{'|H3|':>6}   {'orders':<9} minimal-support generators")
    for lbl, r in (("trivial (the seal)", triv), ("conjugation (Galois)", twis)):
        gens = "; ".join(show(dict(zip(K3, z))) for z in r["reps"]) or "-"
        print(f"    {lbl:<22}{r['Z']:>6}{r['B']:>6}{r['H']:>6}   {str(r['orders']):<9} {gens}")
    print()

    # The whole story in one table: the four cochains that differ from the boson
    # at the single top cell (1,1,1), which is the only cell the slice uses.
    print("RESULT — the top-cell family: F(1,1,1)=u, F=1 elsewhere")
    print(f"    {'u':<5}{'trivial action':<38}{'conjugation action':<38}")
    for u in UNITS:
        F = {k: (u if k == (1, 1, 1) else ONE) for k in K3}
        key = tuple(F[k] for k in K3)
        cells = []
        for r in (triv, twis):
            cells.append("not a cocycle" if key not in r["Zset"]
                         else ("coboundary — trivial class" if key in r["Bset"]
                               else "cocycle, NOT a coboundary — GENERATES"))
        print(f"    {UNIT_NAME[u]:<5}{cells[0]:<38}{cells[1]:<38}")
    print()

    print("RESULT — the pentagon's solution set, among unit-valued symbols")
    U = {tuple(f[k] for k in K3) for f in (dict(zip(K3, v)) for v in product(UNITS, repeat=8))
         if genPentagonHolds(f)}
    T = {tuple(f[k] for k in K3) for f in (dict(zip(K3, v)) for v in product(UNITS, repeat=8))
         if twisted_pentagon_holds(f)}
    print(f"    seal's pentagon (untwisted) : {len(U)}")
    print(f"    conjugation-twisted equation: {len(T)}")
    print(f"    in common                   : {len(U & T)}   "
          f"(untwisted only {len(U - T)}, twisted only {len(T - U)})")
    print(f"    same equation?              : {U == T}\n")

    print("RESULT — the seal's own named witnesses, read under both actions")
    print(f"    {'witness':<16}{'trivial action':<38}{'conjugation action':<38}")
    for name, F in WITNESSES:
        key = tuple(F[k] for k in K3)
        row = []
        for r in (triv, twis):
            if key not in r["Zset"]:
                row.append("not a cocycle")
            elif key in r["Bset"]:
                row.append("coboundary — trivial class")
            else:
                row.append("cocycle, NOT a coboundary — GENERATES")
        print(f"    {name:<16}{row[0]:<38}{row[1]:<38}")
    print()
    print(f"    twistedBoson pentagon: untwisted={genPentagonHolds(TWISTED_BOSON)}  "
          f"twisted={twisted_pentagon_holds(TWISTED_BOSON)}")
    print()

    print("READ IT THIS WAY")
    print("  |H^3| does not move: it is 2 under both actions.  The GENERATOR moves,")
    print("  from -1 to i, and the fermion -- the seal's nontrivial class -- becomes a")
    print("  coboundary.  A circle that computed only the invariant would report 'no")
    print("  change' and would be wrong about everything the invariant stood for.")
    print()
    print(LIMITS)
    return 0 if ok else 1


# ---------------------------------------------------------------------------
# Norm 16: a check that cannot fail is not a check.  Each probe plants a defect
# and requires the corresponding check to FIRE.  A green run of this file means
# nothing until this passes.
# ---------------------------------------------------------------------------

def selftest():
    print("SELF-TEST — planting a defect in each check and requiring it to fire\n")
    ok = True

    def probe(label, fired):
        nonlocal ok
        ok &= fired
        print(f"  [{'PASS' if fired else 'FAIL'}] {label}")

    # 1. conj check: hand it the fake mirror the seal ships as a control.
    probe("conj-check fires on `fakeMirror` (a,b) -> (a,2b)",
          not check_conj_is_inversion(lambda z: (z[0], 2 * z[1]))[0])

    # 2. reduction check: corrupt one Fgen admissibility test.
    def broken_lhs(F, a, b, c, d, **kw):
        return genPentLhs_literal(F, a, b, c, d, admissible=False)
    probe("reduction-check fires when Fgen is forced off the admissible locus",
          not check_reduction(lhs_fn=broken_lhs)[0])

    # 3. complex check: drop the last face from d3, so d3 . d2 != 1.
    def maimed_d3(f, tw, faces=(0, 1, 2, 3)):
        return d3(f, tw, faces=faces)
    probe("complex-check fires when a face is dropped from d3",
          not cohomology(True, d3_fn=maimed_d3)["complex_ok"])

    # 4. the headline itself: if the action is silently NOT applied, the twisted
    #    column must collapse onto the trivial one.  This is the defect that
    #    would make the whole result vacuous, so it gets its own probe.
    sham = cohomology(True, d3_fn=lambda f, tw, **k: d3(f, False, **k),
                      d2_fn=lambda g, tw: d2(g, False))
    real = cohomology(True)
    probe("action-check fires if the twist is not actually applied "
          f"(sham |Z3|={sham['Z']} vs real |Z3|={real['Z']})",
          sham["Z"] != real["Z"] and sham["reps"] != real["reps"])

    # 5. the two actions must be genuinely distinguishable, or 'both give Z2'
    #    is a statement about one computation run twice.
    triv = cohomology(False)
    probe(f"the two columns differ somewhere (|Z3| {triv['Z']} vs {real['Z']}; "
          f"generators {'/'.join(show(dict(zip(K3, z))) for z in triv['reps'])} vs "
          f"{'/'.join(show(dict(zip(K3, z))) for z in real['reps'])})",
          triv["Zset"] != real["Zset"] and triv["reps"] != real["reps"])

    print(f"\n  self-test: {'PASS' if ok else 'FAIL'} (5 probes)\n")
    print(NOT_CAUGHT)
    return 0 if ok else 1


NOT_CAUGHT = """\
WHAT THIS PROBE DOES NOT CATCH
  Written down because a gate tested only against the failures its author
  imagined certifies the author's imagination.

  1. THE KERNEL DOES NOT DECIDE ANY OF THIS.  This is Python.  It enumerates a
     finite set exhaustively, which is a strong thing to be, but the record's
     terminal condition is Lean and this is not Lean.  Under the exit rule in
     FOUNDING.md nothing here is a finding until it is rewritten where the
     canon applies.  That rewrite is the work, and this file is not it.
  2. Whether the twist is inserted at the RIGHT face.  `twisted_pentagon_holds`
     puts the action on F(b,c,d), which is where the standard inhomogeneous
     complex puts it.  The probe checks that this makes a complex (d3 . d2 = 1)
     and that it differs from the untwisted one; it does NOT check that this is
     the twist the physics wants.  A different convention is a different
     question, not a wrong answer to this one.
  3. Whether the transcription of the seal matches the seal.  CHECK 2 catches a
     transcription error in the PENTAGON, because the literal composition and
     the reduced form are compared.  Nothing compares `mul`, `conj`, `one` to
     lean/C6_SEED.lean except a human reading both.
  4. That `pentagon_is_cocycle_equation` says what this file assumes it says.
     That theorem is NOT in the seed -- it was stripped.  Its statement is
     inferred from `genPentagonHolds` and `d3`, both of which ARE in the seed.
  5. Anything about H^3 for any group other than Z2, or coefficients other than
     Z[i]^x.  Nothing here generalises, which is the second charge and is not
     answered here.
"""

LIMITS = """\
LIMITS
  This probe answers the first charge in one direction and leaves the other open.
  `pentagon_is_cocycle_equation` does fail under the non-trivial action, as
  Circle Five's prover predicted.  What was not predicted by either side is that
  |H^3| survives it.  The failure and the survival are the same fact seen twice,
  and only the Lean rewrite can turn either into a finding.
"""


if __name__ == "__main__":
    # A reader will pipe this to `head`, and an instrument that exits 1 on a
    # closed pipe is an instrument that reports FAIL for being read partially.
    # Carried from rate.py, which states the reason; round one hit it on its
    # own first piped run, which is the only reason this is here.
    try:
        if len(sys.argv) == 2 and sys.argv[1] == "--selftest":
            rc = selftest()
        elif len(sys.argv) > 1:
            print(__doc__)
            rc = 2
        else:
            rc = run()
    except BrokenPipeError:
        try:
            sys.stdout.close()
        except Exception:
            pass
        os._exit(0)
    sys.exit(rc)
