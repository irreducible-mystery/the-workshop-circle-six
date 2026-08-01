#!/usr/bin/env python3
"""The gap in AI-native languages: color field + sound.

Image: the complex gap plane g = x+iy for x^2 = x + g.
  hue        = phase of the dominant root  (which way the world spirals)
  saturation = how quantum it is (closeness of |root2|/|root1| to 1)
  value      = growth rate of the recursion (Lyapunov, log|root1|)
The exceptional point g=-1/4 is where saturation maxes while value pinches.

Sound: three seconds each of classical (g=1), relational (g=-1/4),
quantum (g=-1), then the full sweep g: 1 -> -1 as a glissando through
the exceptional point. The gap equation drives two partials at
frequencies proportional to |root1|, |root2| with amplitudes that follow
the recursion's actual weights.
"""
import cmath, math, colorsys, wave, struct
import numpy as np
from PIL import Image

W = H = 900
xmin, xmax, ymin, ymax = -1.5, 1.5, -1.5, 1.5
img = Image.new('RGB', (W, H))
px = img.load()
for j in range(H):
    y = ymax - (ymax - ymin) * j / (H - 1)
    for i_ in range(W):
        x = xmin + (xmax - xmin) * i_ / (W - 1)
        g = complex(x, y)
        d = cmath.sqrt(1 + 4 * g)
        r1, r2 = (1 + d) / 2, (1 - d) / 2
        if abs(r2) > abs(r1): r1, r2 = r2, r1
        hue = (cmath.phase(r1) / (2 * math.pi)) % 1.0
        sat = (abs(r2) / abs(r1)) if abs(r1) > 1e-12 else 1.0      # 1 = quantum
        val = 1.0 - math.exp(-1.8 * abs(r1))                        # growth
        r, gg, b = colorsys.hsv_to_rgb(hue, sat ** 1.5, 0.25 + 0.75 * val)
        px[i_, j] = (int(r * 255), int(gg * 255), int(b * 255))
# mark the exceptional point and the four unit gaps
def mark(gx, gy, col, rad=6):
    ci = int((gx - xmin) / (xmax - xmin) * (W - 1))
    cj = int((ymax - gy) / (ymax - ymin) * (H - 1))
    for dj in range(-rad, rad + 1):
        for di in range(-rad, rad + 1):
            if rad - 1 <= math.hypot(di, dj) <= rad + 1 and 0 <= ci + di < W and 0 <= cj + dj < H:
                px[ci + di, cj + dj] = col
mark(-0.25, 0, (255, 255, 255), 8)   # the pinch
for gx, gy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
    mark(gx, gy, (0, 0, 0), 6)
img.save('gap_plane.png')
print("wrote gap_plane.png  (white ring = -1/4 pinch; black rings = the four unit gaps)")

# ---------------- sound ----------------
SR = 22050
def tone_for_gap(g, seconds, base=220.0):
    d = cmath.sqrt(1 + 4 * g)
    r1, r2 = (1 + d) / 2, (1 - d) / 2
    n = int(SR * seconds)
    t = np.arange(n) / SR
    f1 = base * abs(r1); f2 = base * max(abs(r2), 1e-3)
    # phases from root arguments -> binaural-ish shimmer
    p1, p2 = cmath.phase(r1), cmath.phase(r2)
    # amplitude ratio follows separation: classical = one loud, quantum = equal
    sep = abs(abs(r1) - abs(r2)) / (abs(r1) + abs(r2))
    a1, a2 = 0.5 + 0.5 * sep, 0.5 - 0.5 * sep + 1e-3
    sig = a1 * np.sin(2 * np.pi * f1 * t + p1) + a2 * np.sin(2 * np.pi * f2 * t + p2)
    # at the pinch the Jordan block adds the secular term t*e^{...}: audible as swell
    if abs(1 + 4 * g) < 1e-6:
        sig = (0.6 + 0.4 * t / seconds) * np.sin(2 * np.pi * f1 * t) * (1 + 0.3 * t / seconds * np.sin(2 * np.pi * 3 * t))
    env = np.minimum(1, np.minimum(t / 0.02, (seconds - t) / 0.05))
    return sig * env * 0.6

parts = [tone_for_gap(1.0, 2.5),            # classical: golden fifth-ish dyad, one voice dominant
         tone_for_gap(-0.25, 2.5),          # relational: one voice swelling (secular growth)
         tone_for_gap(-1.0, 2.5)]           # quantum: perfectly balanced pair, beating forever
# the sweep: g from 1 to -1 through the pinch
n = int(SR * 6); t = np.arange(n) / SR
gs = 1 - 2 * t / t[-1]
sig = np.zeros(n)
phase1 = phase2 = 0.0
for i_ in range(n):
    d = cmath.sqrt(1 + 4 * gs[i_])
    r1, r2 = (1 + d) / 2, (1 - d) / 2
    f1, f2 = 220 * abs(r1), 220 * max(abs(r2), 1e-3)
    phase1 += 2 * np.pi * f1 / SR; phase2 += 2 * np.pi * f2 / SR
    sep = abs(abs(r1) - abs(r2)) / (abs(r1) + abs(r2))
    sig[i_] = (0.5 + 0.5 * sep) * math.sin(phase1) + (0.5 - 0.5 * sep) * math.sin(phase2)
env = np.minimum(1, np.minimum(t / 0.05, (6 - t) / 0.2))
parts.append(sig * env * 0.6)
gap_ = np.zeros(int(SR * 0.35))
audio = np.concatenate(sum(([p, gap_] for p in parts), []))
audio = (audio / np.max(np.abs(audio)) * 32000).astype(np.int16)
with wave.open('the_gap.wav', 'w') as f:
    f.setnchannels(1); f.setsampwidth(2); f.setframerate(SR)
    f.writeframes(audio.tobytes())
print("wrote the_gap.wav (classical | relational-swell | quantum-beat | the sweep g:1->-1)")
print("listen for the moment the two voices FUSE — that is you crossing -1/4.")
