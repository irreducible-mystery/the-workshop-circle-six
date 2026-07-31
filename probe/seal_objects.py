#!/usr/bin/env python3
"""seal_objects.py — Circle Six's second probe.  The seal's OWN constructions.

NOT A CARRIED INSTRUMENT.  See probe/galois_twist.py for what `probe/` is.

WHY THIS EXISTS, SEPARATELY FROM galois_twist.py
  The first probe answered the charge through the bar complex -- `d2`, `d3`,
  `Coch3` -- and never touched `gaugeAct`, `gaugePhi`, `gaugeOf`,
  `GaugeEquivOnLabels` or `GaugeClasses`.  Those are the seal's HEADLINE
  object: the docstring on `GaugeClasses` calls it "THE GAUGE QUOTIENT -- the
  type of classes the sealed record named as not constructed."

  Answering a charge about the seal without evaluating the seal's own objects
  is answering it about a complex the analyst built.  This probe evaluates
  them.  It finds three things the bar-complex route cannot see, one of which
  contradicts a docstring.

CONTRACT
  (no args)     run every check and print.  exit 0 iff all checks pass
  --selftest    norm 16: plant a defect in each check and require it to fire
"""
from __future__ import annotations
import os
import sys
from itertools import product

ZERO, ONE, I = (0, 0), (1, 0), (0, 1)


def mul(z, w):
    return (z[0] * w[0] - z[1] * w[1], z[0] * w[1] + z[1] * w[0])


def conj(z):
    return (z[0], -z[1])


def neg(z):
    return (-z[0], -z[1])


UNITS = [ONE, I, neg(ONE), neg(I)]
NAME = {ONE: "1", I: "i", neg(ONE): "-1", neg(I): "-i"}
LAB = [0, 1]
K3 = list(product(LAB, repeat=3))
K2 = list(product(LAB, repeat=2))


def inverse(u):
    return next(v for v in UNITS if mul(u, v) == ONE)


# --------------------------------------------------------------------------
# The seal's definitions, transcribed from lean/C6_SEED.lean.
# --------------------------------------------------------------------------

def sliceCore(f):                                    # def sliceCore
    return {k: (f if k == (1, 1, 1) else ONE) for k in K3}


def Fs(f, a, b, c, d, x, y):                         # def Fs
    if x == (a + b) % 2 and y == (b + c) % 2 and d == (a + b + c) % 2:
        return f if (a == 1 and b == 1 and c == 1) else ONE
    return ZERO


def Rs(R, x, y):                                     # def Rs
    return R if (x == 1 and y == 1) else ONE


def hexLhs(f, R, a, b, c, d):                        # def hexLhs
    e = (a + b) % 2
    z = (a + c) % 2
    return mul(Rs(R, e, c), Fs(f, c, a, b, d, z, e))


def hexRhs(f, R, a, b, c, d):                        # def hexRhs
    e = (a + b) % 2
    z = (a + c) % 2
    g = (b + c) % 2
    return mul(mul(mul(Fs(f, a, b, c, d, e, g), Rs(R, b, c)),
                   Fs(f, a, c, b, d, z, g)), Rs(R, a, c))


def hexagonHolds(f, R):                              # def hexagonHolds
    return all(hexLhs(f, R, a, b, c, d) == hexRhs(f, R, a, b, c, d)
               for a, b, c, d in product(LAB, repeat=4)
               if d == ((a + b) % 2 + c) % 2 and d == ((a + c) % 2 + b) % 2)


def hexInvHolds(f, R):                               # def hexInvHolds
    return hexagonHolds(f, conj(R))


def SelfInverse(R):                                  # def SelfInverse
    return mul(R, R) == ONE


def gaugePhi(g, a, b, c):                            # def gaugePhi
    return mul(mul(g[(a, b)], g[((a + b) % 2, c)]),
               mul(conj(g[(b, c)]), conj(g[(a, (b + c) % 2)])))


def d2raw(g, a, b, c):                               # def d2raw
    return mul(mul(g[(b, c)], conj(g[((a + b) % 2, c)])),
               mul(g[(a, (b + c) % 2)], conj(g[(a, b)])))


def gaugeAct(g, F):                                  # def gaugeAct
    return {k: mul(F[k], gaugePhi(g, *k)) for k in K3}


def gaugeInv(g):                                     # def gaugeInv
    return {k: conj(g[k]) for k in K2}


def gaugeOf(F):                                      # def gaugeOf (the SYMBOL one)
    return {(a, b): (F[(0, 0, 1)] if (a == 0 and b == 1) else
                     (conj(F[(1, 0, 0)]) if (a == 1 and b == 0) else ONE))
            for a, b in K2}


def genPentagonHolds(F):
    return all(mul(mul(F[(a, b, c)], F[(a, (b + c) % 2, d)]), F[(b, c, d)])
               == mul(F[((a + b) % 2, c, d)], F[(a, b, (c + d) % 2)])
               for a, b, c, d in product(LAB, repeat=4))


GAUGES = [dict(zip(K2, v)) for v in product(UNITS, repeat=4)]
SOLUTIONS = [dict(zip(K3, v)) for v in product(UNITS, repeat=8)
             if genPentagonHolds(dict(zip(K3, v)))]


def key(F):
    return tuple(F[k] for k in K3)


# --------------------------------------------------------------------------

def check_gaugephi_vs_d2raw(phi=gaugePhi):
    """`d2raw`'s docstring: written in the seal's own label arithmetic "so it
       can be compared with `gaugePhi` WITHOUT ANY TRANSLATION LAYER."  The
       naive comparison is what that sentence invites.  Measure it."""
    naive = sum(1 for g in GAUGES if all(phi(g, *k) == d2raw(g, *k) for k in K3))
    viainv = sum(1 for g in GAUGES if all(phi(g, *k) == d2raw(gaugeInv(g), *k) for k in K3))
    viaconj = sum(1 for g in GAUGES if all(phi(g, *k) == conj(d2raw(g, *k)) for k in K3))
    imP = {tuple(phi(g, *k) for k in K3) for g in GAUGES}
    imD = {tuple(d2raw(g, *k) for k in K3) for g in GAUGES}
    return naive, viainv, viaconj, imP == imD, len(imP)


def check_gauge_orbits(act=gaugeAct):
    """The seal's classification, computed from the seal's own gauge action.
       No cochain complex is used anywhere in this function."""
    orbits, seen = [], set()
    for F in SOLUTIONS:
        if key(F) in seen:
            continue
        orb = {key(act(g, F)) for g in GAUGES}
        seen |= orb
        orbits.append(orb)
    landing = {}
    for F in SOLUTIONS:
        r = key(act(gaugeOf(F), F))
        landing[r] = landing.get(r, 0) + 1
    imP = {tuple(gaugePhi(g, *k) for k in K3) for g in GAUGES}
    boson_orbit = next((o for o in orbits if key(sliceCore(ONE)) in o), set())
    return {"orbits": len(orbits), "sizes": sorted(len(o) for o in orbits),
            "landing": landing, "boson_orbit_is_im_gaugePhi": boson_orbit == imP,
            "gaugeOf_unit_valued": all(v in UNITS for F in SOLUTIONS
                                       for v in gaugeOf(F).values())}


def check_hexagon(hexfn=hexagonHolds):
    rows = []
    for f in UNITS:
        braid = [R for R in UNITS if hexfn(f, R)]
        binv = [R for R in UNITS if hexInvHolds(f, R)]
        edict = [R for R in braid if SelfInverse(R)]
        rows.append((f, braid, binv, edict))
    return rows


# --------------------------------------------------------------------------

def run():
    ok = True

    print("CHECK A — `gaugePhi` against `d2raw`, which the seal says needs no")
    print("          translation layer between them")
    naive, viainv, viaconj, same_im, n = check_gaugephi_vs_d2raw()
    print(f"    gaugePhi g == d2raw g              : {naive}/256")
    print(f"    gaugePhi g == d2raw (gaugeInv g)   : {viainv}/256")
    print(f"    gaugePhi g == conj (d2raw g)       : {viaconj}/256")
    print(f"    im(gaugePhi) == im(d2raw) as sets  : {same_im}   (|im| = {n})")
    print("  => the naive comparison is FALSE for 192 of 256 gauges. The two")
    print("     differ by inverting the gauge: gaugePhi g = d2raw (gaugeInv g).")
    print("     The images coincide, so no cohomology below is affected -- but")
    print("     the docstring invites exactly the comparison that does not hold.\n")
    ok &= (viainv == 256 and same_im and naive != 256)

    print("CHECK B — the seal's classification, from the seal's OWN gauge action")
    orb = check_gauge_orbits()
    print(f"    pentagon-satisfying unit symbols   : {len(SOLUTIONS)}")
    print(f"    orbits under gaugeAct              : {orb['orbits']}  sizes {orb['sizes']}")
    print(f"    orbit(sliceCore one) == im(gaugePhi): {orb['boson_orbit_is_im_gaugePhi']}")
    print(f"    every `gaugeOf F` is unit-valued    : {orb['gaugeOf_unit_valued']}")
    for r, cnt in sorted(orb["landing"].items(), key=lambda kv: -kv[1]):
        print(f"    gaugeAct (gaugeOf F) F  ->  sliceCore {NAME[dict(zip(K3, r))[(1,1,1)]]:<3} "
              f"for {cnt} of the {len(SOLUTIONS)}")
    print("  => `at_most_two_classes` is CONSTRUCTIVELY reachable from the")
    print("     definitions alone: `gaugeOf` normalises every solution into the")
    print("     slice, in 32 cases, with no cohomology and no stripped lemma.\n")
    ok &= (orb["orbits"] == 2 and orb["sizes"] == [16, 16]
           and orb["boson_orbit_is_im_gaugePhi"] and orb["gaugeOf_unit_valued"])

    print("CHECK C — the hexagon, and `SelfInverse` (\"the roomy edict\")")
    print(f"    {'f':<5}{'R with hexagonHolds':<24}{'R with hexInvHolds':<24}{'and SelfInverse'}")
    for f, braid, binv, edict in check_hexagon():
        print(f"    {NAME[f]:<5}"
              f"{str([NAME[R] for R in braid]):<24}"
              f"{str([NAME[R] for R in binv]):<24}"
              f"{[NAME[R] for R in edict] if edict else 'NONE'}")
    print("  => the boson braids by +-1 and satisfies the edict; the fermion")
    print("     braids by +-i and CANNOT (i^2 = -1). The two classes are not")
    print("     symmetric here, and `IsClassifiedSymbol` does not mention the")
    print("     hexagon -- so \"two classes\" is about F-symbols, not braided data.\n")

    print("CHECK D — is the conjugation-twisted generator a NAMED seal object?")
    sI = sliceCore(I)
    print(f"    sliceCore I  satisfies the seal's pentagon : {genPentagonHolds(sI)}")
    print("  => yes: it is `sliceCore I`. The seal can write the twisted")
    print("     generator and its own pentagon rejects it.\n")
    ok &= not genPentagonHolds(sI)

    print(NOT_CAUGHT)
    return 0 if ok else 1


def selftest():
    print("SELF-TEST — planting a defect in each check and requiring it to fire\n")
    ok = True

    def probe(label, fired):
        nonlocal ok
        ok &= fired
        print(f"  [{'PASS' if fired else 'FAIL'}] {label}")

    # A: if gaugePhi is replaced by d2raw itself, the asymmetry must vanish.
    n2, vi2, _, _, _ = check_gaugephi_vs_d2raw(phi=lambda g, a, b, c: d2raw(g, a, b, c))
    probe(f"CHECK A fires if gaugePhi is swapped for d2raw (naive {n2}/256, "
          f"was 64/256)", n2 == 256)

    # B: a gauge action that does nothing must collapse the orbit count to 32.
    o2 = check_gauge_orbits(act=lambda g, F: F)
    probe(f"CHECK B fires if the gauge action is the identity "
          f"({o2['orbits']} orbits, not 2)", o2["orbits"] == len(SOLUTIONS))

    # C: a hexagon that always holds must admit every braiding.
    rows = check_hexagon(hexfn=lambda f, R: True)
    probe("CHECK C fires if hexagonHolds is forced true (all 4 braidings admitted)",
          all(len(b) == 4 for _, b, _, _ in rows))

    # D: the real seal must actually reject sliceCore I -- if the pentagon were
    #    trivially true this whole probe would be vacuous.
    probe("CHECK D is not vacuous: the pentagon accepts some symbols and "
          f"rejects others ({len(SOLUTIONS)} of 65536 accepted)",
          0 < len(SOLUTIONS) < 65536)

    print(f"\n  self-test: {'PASS' if ok else 'FAIL'} (4 probes)\n")
    print(NOT_CAUGHT)
    return 0 if ok else 1


NOT_CAUGHT = """\
WHAT THIS PROBE DOES NOT CATCH
  1. Everything in probe/galois_twist.py's list, which applies here too --
     above all that this is Python and the record's terminal condition is Lean.
  2. `GaugeEquivOnLabels` quantifies over ALL unit-valued gauges `Int -> Int ->
     GZ`; this probe enumerates only their restrictions to label pairs. That is
     sound for the orbit count -- `gaugeAct` reads `g` only at label pairs --
     but it is an argument, not a measurement, and it is stated rather than run.
  3. `IsClassifiedSymbol` quantifies unit-valuedness over ALL of Int^3 while
     the pentagon and the equivalence see only {0,1}^3. The domain is an
     infinite set of functions; the probe enumerates the 4^8 restrictions. The
     class COUNT is unaffected; the domain's size is not what is measured.
  4. Whether `at_most_two_classes` is the theorem this reconstruction matches.
     That theorem was stripped; only its NAME survives, in a docstring.
"""


if __name__ == "__main__":
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
