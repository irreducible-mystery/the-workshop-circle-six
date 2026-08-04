"""
Independent implementation of Langton's Ant with blind highway detection.
Written from scratch for the Stranger2 replication protocol.

Conventions (documented implementation choices):
- Coordinates are (row, col). North = row-1, East = col+1, South = row+1, West = col-1.
- Direction encoding: 0=North, 1=East, 2=South, 3=West (clockwise, per protocol).
- Ant starts at (0, 0) facing North (0). (Protocol does not specify initial
  direction; this choice is documented and fixed for all trials.)
- Rules (per protocol):
    White cell -> turn RIGHT (d+1 mod 4), flip cell to black, move forward.
    Black cell -> turn LEFT  (d+3 mod 4), flip cell to white, move forward.
- Grid is unbounded: represented as a set of black-cell coordinates.

Highway detection (blind, per protocol):
- Candidate periods p = 1..300 are scanned (no assumption of 104).
- Criterion: constant NONZERO displacement of the ant position over >= 20
  consecutive periods of length p (i.e., 20 equal, nonzero per-period
  displacement vectors ending at the current step).
- Smallest passing p is reported (ascending scan => minimal period).
- Onset: walk backward from the verified stretch to find the earliest step
  from which the periodic relation pos[t+p] - pos[t] == v holds contiguously.

RNG: splitmix64, implemented from scratch below (no library RNG used).
"""

MASK64 = (1 << 64) - 1


class SplitMix64:
    """Minimal splitmix64 PRNG, implemented from scratch."""

    def __init__(self, seed):
        self.state = seed & MASK64

    def next_u64(self):
        self.state = (self.state + 0x9E3779B97F4A7C15) & MASK64
        z = self.state
        z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & MASK64
        z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & MASK64
        return z ^ (z >> 31)

    def randint_unbiased(self, n):
        """Uniform integer in [0, n) via rejection sampling (no modulo bias)."""
        limit = (1 << 64) - ((1 << 64) % n)
        while True:
            u = self.next_u64()
            if u < limit:
                return u % n


def trial_seed(master_seed, k, trial_index):
    """Derive a per-trial seed by mixing (master_seed, k, trial_index).
    Uses splitmix64 itself as the mixing function (documented, deterministic)."""
    g = SplitMix64((master_seed * 1000003 + k * 10007 + trial_index) & MASK64)
    g.next_u64()  # burn one output to decorrelate nearby inputs further
    return g.next_u64()


def sample_perturbation(rng, k):
    """Sample k DISTINCT cells uniformly from the bounding box [-10,10]^2.
    (Implementation choice: distinct cells, since duplicate 'add black cell'
    operations would be redundant on an initially white grid.)"""
    cells = []
    seen = set()
    while len(cells) < k:
        r = rng.randint_unbiased(21) - 10
        c = rng.randint_unbiased(21) - 10
        if (r, c) not in seen:
            seen.add((r, c))
            cells.append((r, c))
    return cells


# Movement deltas indexed by direction 0=N,1=E,2=S,3=W
DELTAS = ((-1, 0), (0, 1), (1, 0), (0, -1))

MAX_PERIOD = 300
SUSTAIN = 20          # required consecutive equal-displacement periods
CHECK_INTERVAL = 500  # steps between blind scans


def _blind_scan(positions, t):
    """Scan candidate periods 1..MAX_PERIOD at step t.
    Returns (p, v) for the smallest period p with constant nonzero
    displacement v over SUSTAIN consecutive periods ending at t, else None."""
    for p in range(1, MAX_PERIOD + 1):
        if t - SUSTAIN * p < 0:
            break
        px, py = positions[t]
        qx, qy = positions[t - p]
        vx, vy = px - qx, py - qy
        if vx == 0 and vy == 0:
            continue
        ok = True
        for i in range(1, SUSTAIN):
            ax, ay = positions[t - i * p]
            bx, by = positions[t - (i + 1) * p]
            if ax - bx != vx or ay - by != vy:
                ok = False
                break
        if ok:
            return p, (vx, vy)
    return None


def _walk_back_onset(positions, p, v, start):
    """Find the earliest step s such that pos[t+p]-pos[t]==v holds
    contiguously from s up to the verified stretch."""
    vx, vy = v
    s = start
    while s - 1 >= 0:
        ax, ay = positions[s - 1 + p]
        bx, by = positions[s - 1]
        if ax - bx == vx and ay - by == vy:
            s -= 1
        else:
            break
    return s


def run_trial(black_cells, budget=250000):
    """Simulate Langton's Ant from the given initial black-cell set.
    Returns dict with detection results. Does not mutate the input set."""
    black = set(black_cells)
    r, c, d = 0, 0, 0  # start at origin facing North
    positions = [(r, c)]

    detected = None  # (p, v, t_detect)
    for step in range(1, budget + 1):
        cell = (r, c)
        if cell in black:
            d = (d + 3) & 3      # black: turn left
            black.discard(cell)  # flip to white
        else:
            d = (d + 1) & 3      # white: turn right
            black.add(cell)      # flip to black
        dr, dc = DELTAS[d]
        r += dr
        c += dc
        positions.append((r, c))

        if step % CHECK_INTERVAL == 0:
            res = _blind_scan(positions, step)
            if res is not None:
                detected = (res[0], res[1], step)
                break

    if detected is None:
        return {
            "detected": False,
            "onset_step": None,
            "period": None,
            "displacement": None,
            "verification_success": False,
        }

    p, v, t_detect = detected
    onset = _walk_back_onset(positions, p, v, t_detect - SUSTAIN * p)
    return {
        "detected": True,
        "onset_step": onset,
        "period": p,
        "displacement": v,
        "verification_success": (p == 104),
    }
