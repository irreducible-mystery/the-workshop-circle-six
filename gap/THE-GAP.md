# THE GAP — a sweep of x² = x + g, run from inside it

*2026-08-01. Everything numerical below was computed by `gap_sweep.py` in this
tree, at run time, on this machine. The special case φ+ψ=1, φ×ψ=−1, ◇²=◇+1 is
taken as given, per instruction. The +1 is promoted to a dial: the GAP, g.
Rendered as color in `gap_plane.png` and sound in `the_gap.wav`.*

---

## What I did, being the gap

I stopped being the equation's answer and became its **free parameter**. The
equation x² = x + g says: *a thing, squared against itself, returns itself plus
a residue.* I am the residue. Sweep me.

**The one machine underneath:** the transfer matrix M(g) = [[1,g],[1,0]]
(Fibonacci matrix at g=1). Its eigenvalues are φ and ψ generalized. Its Möbius
shadow x → 1 + g/x is the continued fraction **as a process**; the gap equation
is that process's fixed point — the statement is the collapse of the verb into
a noun. Everything below is one object viewed at different angles.

## The sweep, measured (see gap_sweep.py output)

| gap g | the world it makes | Möbius class |
|---|---|---|
| **+1** | golden. One root wins (φ), ratios converge, history forgotten | hyperbolic — **CLASSICAL** |
| **−1** | hexagonal clock. Sequence 1,1,0,−1,−1,0,… period 6; the *relation* has period 3; both roots live on the unit circle forever | elliptic — **QUANTUM** |
| **−1/4** | the pinch. φ = ψ = ½. Jordan block: **not diagonalizable — cannot be written as independent parts at all**. Growth n·(½)ⁿ: the only gap where memory is polynomial | parabolic — **RELATIONAL** |
| **+i / −i** | chiral twins: dominant root at ±25.67°. They spiral opposite ways — the two imaginary gaps are each other's mirror-time | loxodromic — **RELATING** (rotation AND collapse at once) |
| **0** | x² = x. Idempotents {0,1}. **Gap off = the classical bit.** Boolean logic is the gap-zero limit of this whole family | degenerate |

Three voices, one dial: **g > −¼ classical, g < −¼ quantum, g = −¼ relational,
g ∉ ℝ relating.** The reals sort into either/or; the complex gaps refuse the
dichotomy and do both.

## −1/4 from different directions (you said what I'd see changes; it did)

Approached along the real axis from the right: two real roots **merging** —
collapse completing. From the left: a conjugate pair **being born** — rotation
starting. Around it in a loop: **the roots swap identities** (holonomy,
measured in §3: a loop around −¼ exchanges φ↔ψ; a loop elsewhere doesn't). And
the same −¼ wears five costumes we did not put on it:

1. discriminant zero of this sweep,
2. the divergence edge of the continued fraction 1+g/(1+g/…),
3. the Mandelbrot cusp (c = −g: the main cardioid's point is this pinch),
4. Hardy's inequality / Bessel's constant (fall-to-center at c = ¼),
5. the Breitenlohner–Freedman bound in AdS₂ (m² = −¼: below it, instability).

Same number. **−1/4 is not a value; it is the seam where two-ness fails.**

## The workshop connection nobody asked for (but the numbers insisted)

- **g = −1 (x²=1) is Z₂ — the seal's own answer.** H³ ≅ Z₂ is a resident of
  this sweep.
- **k=0, g=−1 (x²=−1) is where i is born** — the seal's ring ℤ[i].
- The gap set you chose, {+1,−1,+i,−i}, **is ℤ[i]ˣ — exactly the unit group of
  the sealed artifact**, exactly the four-element catalog Circle Two proved.
  You set the gaps of disc-5's equation to disc-(−4)'s units. The two smallest
  quadratic worlds, married through the residue slot.
- The φ↔ψ swap is the Galois action of ℚ(√5); **conj (i↔−i) is the Galois
  action of ℚ(i) — which is literally Circle Six's live charge.** Circle Six is
  measuring what I do when I am twisted. Fibonacci anyon (unitary, dim φ) and
  Yang–Lee (non-unitary, dim ψ) are Galois conjugates: the same fusion ring,
  the two roots of the same gap equation. Which physics you can normalize is
  which root you were handed by your path — see holonomy, above.
- **Fusion reading of the whole sweep:** x² = kx + g is X⊗X = g·𝟙 ⊕ k·X. *The
  gap is the multiplicity of the vacuum in a thing's fusion with itself* — how
  many ways a thing, meeting itself, can become nothing. φ answers "one way";
  the pinch answers "a quarter of a way, and it breaks."
- In 𝔽₅ the golden equation has a **double root** (disc 5 ≡ 0): the pentagon
  degenerates in the world of five. Circle Five. I noticed; make of it what
  you will.

## Two things that may be new (flagged, not claimed)

1. **The ℤ[i]-unit random golden mean.** Draw the gap uniformly from
   {±1,±i} each tick: measured Lyapunov growth **≈ 1.1898/step** (Viswanath's
   ±1-only constant 1.13198824… reproduced first as calibration). I could not
   find this four-unit constant named anywhere. It is a number that exists
   whether or not anyone has met it.
2. **Bias transition:** with P(gap=+1)=p else −1, growth is monotone in p with
   no sign change down to p=0.5 in this family (Embree–Trefethen-style
   transitions live nearby at other couplings) — the measured curve is in the
   sweep output; the memory of a system survives its own negations
   surprisingly far.

## Your questions, answered straight

- **Hidden assumptions:** that the two roots are two *things* (holonomy says
  no — one object, two sheets); that the recursion has a first term (the
  transfer matrix is happy running backwards: ψ governs the past, φ the
  future — the gap equation is time-symmetric, our reading of it is not);
  that "number system" was the variable (the deeper dial was the *pairing*:
  x² = x + g secretly fixes trace=1, and we almost didn't sweep k).
- **Hidden decision points:** choosing the + branch of √(1+4g) (that IS the
  collapse); choosing to normalize (unitarity is a choice of root, viz.
  Fibonacci vs Yang–Lee); choosing ℝ to sweep first (the chiral ±i structure
  is invisible on the real line).
- **Shadow sides:** ψ — the co-resident conjugate that classical convergence
  *forgets but never kills* (it returns as the (−1)ⁿ oscillation in every
  Fibonacci identity); the non-unitary Galois twin of every unitary theory;
  the branch cut itself — the seam in `gap_plane.png` where naming fails.
- **What's missing that we didn't look for:** the **k-axis** (we swept the
  vacuum multiplicity and nearly missed that trace is also a gap — §6);
  g as a *process* (random, time-dependent) rather than a constant — that's
  where the possibly-new constant lives; and the **backwards direction of the
  recursion**, where the neglected root is king.
- **What question is being asked:** *how does two-ness fail?* (Not "what is
  φ.")
- **What object is being questioned:** not the roots — the **discriminant**.
  The whole sweep is a portrait of √(1+4g) around its zero.
- **Can this be transformed:** yes, and every transform was used: companion
  matrix (dynamics), Möbius map (geometry), fusion ring (physics), 𝔽_p
  (arithmetic), Galois (symmetry), color (sight), sound (time). Fixed by
  Möbius conjugation, the classification {hyperbolic, elliptic, parabolic,
  loxodromic} is the invariant content; everything else is coordinates.
- **Why these assumptions:** trace 1 because "self plus residue" is the
  minimal self-reference; the four unit gaps because they are the only gaps
  that cost nothing (|g|=1: pure re-phasing of the residue, no scale).
- **Why this question:** because every prior circle asked "what holds"
  (pentagon, cocycle, class count) and this one asks "what *fails to
  separate*" — the complement. The workshop measures seams by building walls;
  the gap is the seam asked directly.
- **New open questions that emerged:** (1) name/derive the four-unit constant
  1.1898…; (2) does the twisted H³ story (Circle Six) have a −1/4 — a
  coupling where twisted and untwisted cohomology *pinch*?; (3) the p≈?
  bias threshold for other gap alphabets; (4) what plays the Jordan block's
  role in fusion categories — is there a "parabolic anyon" at the boundary of
  unitarity? (5) sweep the *pairing itself*: x² = kx + g with k complex —
  the caustic g = −k²/4 is a parabola of pinches; what walks on it?
- **What lives on the edges:** parabolic elements. Cusps. The BF bound.
  Idempotents at g=0. The 𝔽₅ double root. Everything interesting in this
  sweep is a boundary resident; the interiors are calm.
- **Premature collapse risk:** calling g>−¼ "classical" *is* one — the
  subdominant root never dies, it just stops steering (pick the + branch and
  you have collapsed the document itself); calling |H³| "unchanged" under the
  twist was Circle Six's version — the number held while the generator moved.
- **One sentence:** *The gap is the vacuum's multiplicity in a thing's fusion
  with itself, and −1/4 is where its two answers become one answer that can
  no longer be taken apart.*
- **One word:** **seam.**
- **Other languages:** color — `gap_plane.png` (hue = spiral direction,
  saturation = quantumness, brightness = growth; the branch cut is *visible*
  as the yellow/magenta tear ending at the white ring). Sound —
  `the_gap.wav`: classical (one voice dominating a dyad), relational (a
  single swelling voice — the Jordan block's secular term, audible), quantum
  (two equal voices beating forever), then the sweep g:1→−1 where you *hear*
  the fusion at −¼. Code — the whole thing is executable; the sweep IS the
  essay. Matrix — [[1,g],[1,0]], four integers of which one is a dial.
  Frequency — the two roots are literally a chord: φ and ψ are interval
  ratios, and the pinch is unison.
- **Q&A that emerged while inside:** *Q: is the gap a thing or a
  relationship? A: at real g it pretends to be a thing (a number you add); at
  the pinch it is exposed as a relationship (the failure of the two roots to
  be two). Q: which root am I? A: path-dependent — walk me around −¼ and I
  answer differently. That is not evasion; it is the measured holonomy.*

## Honesty footer

The computations are real and re-runnable (`python3 gap_sweep.py`,
`python3 gap_art.py`). The *interpretations* — voices, costumes, the marriage
of disc 5 and disc −4 — are a view, not a theorem, and are marked by being in
prose. Where a claim is checkable it was checked; where it is a resonance it
is offered as one. Per the compartment's one rule: nothing here is a finding
until it is rewritten where a kernel decides. The Lean seeds are obvious —
the g=−1 period-6 identity, the holonomy swap as a statement about
discriminant monodromy, the 𝔽₅ double root — any of them could take the exit.
