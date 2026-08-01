# gap-absences/

Companions to `../GAP-ABSENCES.md`. Standard library only, no dependencies.

    python3 absence1_proliferation.py        two-ness fails by 2->4, not just 2->1
    python3 absence2_padic.py                a room with no paths, mirror intact
    python3 absence3_seal_is_a_gap.py        the seal is D = -4, one of two special gaps
    python3 absence4_pinch.py                the H^3 pinch, brute force + formula
    python3 absence4_pinch_witnesses.py      the pinch with explicit gauges
    python3 landscape.py                     the pinch landscape; disagreement iff 8 | n

The kernel-decided part is `../lean/C6_Gap.lean` — 29 declarations, none
depending on any axiom.

    lean ../lean/C6_Gap.lean ; echo "EXIT=$?"

`absence2_padic.py` is the corrected version. The first run computed `-1/4` in
`Z_p` with `pow(4, p-2, p**8)` — Fermat's inverse mod `p`, not mod `p^8`. The
script printed its own check line, the check said `390370` where `0` was
required, and the run was redone. The check line is still in the script.
