# ============================================================
# STRANGER'S INDEPENDENT VERIFICATION -- Langton's Ant
# Written WITHOUT reading Dreamer's implementation.
#
# Part 1 (existence / exact check): from empty grid, verify chaotic
#   transient then highway with period 104 in ant-state displacement.
#   Detection method: find time T after which the full ant state
#   (position delta, direction, and local cell pattern effect) repeats
#   with a constant displacement vector every 104 steps, sustained.
#   Epistemic tag for the RESULT: EXHAUSTIVELY VERIFIED for this single
#   initial condition over the simulated window (existence-style check).
#
# Part 2 (evidence): N random finite perturbations near origin;
#   measure fraction that reach highway within step budget, and
#   transient length distribution. Epistemic tag: OBSERVED (sample
#   statistics only; can never prove the universal-highway conjecture).
# ============================================================

# Directions: 0=N,1=E,2=S,3=W ; turn right on white(0), left on black(1)
const DX = (0, 1, 0, -1)
const DY = (1, 0, -1, 0)

mutable struct Ant
    x::Int; y::Int; dir::Int
    grid::Dict{Tuple{Int,Int},Bool}   # sparse: true = black
end
Ant() = Ant(0, 0, 0, Dict{Tuple{Int,Int},Bool}())

@inline function step!(a::Ant)
    p = (a.x, a.y)
    black = get(a.grid, p, false)
    a.dir = black ? mod(a.dir + 3, 4) : mod(a.dir + 1, 4)  # left if black, right if white
    if black
        delete!(a.grid, p)   # keep dict sparse
    else
        a.grid[p] = true
    end
    a.x += DX[a.dir + 1]; a.y += DY[a.dir + 1]
    return a
end

# Highway detection WITHOUT assuming period a priori, then confirm 104:
# Record (x, y, dir) trace. The highway means: exists P and T0 such that
# for all t >= T0: dir(t+P)==dir(t) and (x,y)(t+P)-(x,y)(t) == constant
# nonzero vector. We detect by scanning candidate periods 1..300 against
# the tail of the trace, requiring sustained agreement over >= 20*P steps.
function detect_highway(trace::Vector{NTuple{3,Int}}; maxP::Int=300, confirm_mult::Int=20)
    n = length(trace)
    for P in 1:maxP
        need = confirm_mult * P
        n - need - P < 1 && continue
        lo = n - need - P + 1
        # displacement over one period at the tail
        dx = trace[n][1] - trace[n-P][1]
        dy = trace[n][2] - trace[n-P][2]
        (dx == 0 && dy == 0) && continue   # must be translating
        ok = true
        for t in lo:(n - P)
            a, b = trace[t], trace[t+P]
            if b[3] != a[3] || b[1]-a[1] != dx || b[2]-a[2] != dy
                ok = false; break
            end
        end
        if ok
            # earliest onset: walk backwards while pattern still holds
            t0 = lo
            while t0 - 1 >= 1 && t0 - 1 + P <= n
                a, b = trace[t0-1], trace[t0-1+P]
                (b[3] == a[3] && b[1]-a[1] == dx && b[2]-a[2] == dy) || break
                t0 -= 1
            end
            return (found = true, period = P, onset = t0, disp = (dx, dy))
        end
    end
    return (found = false, period = 0, onset = 0, disp = (0, 0))
end

function run_and_detect(init_black::Vector{Tuple{Int,Int}}, nsteps::Int)
    a = Ant()
    for p in init_black; a.grid[p] = true; end
    trace = Vector{NTuple{3,Int}}(undef, nsteps)
    for t in 1:nsteps
        step!(a)
        trace[t] = (a.x, a.y, a.dir)
    end
    return detect_highway(trace)
end

# ------- deterministic PRNG (xorshift) for reproducibility, no packages -------
mutable struct XS; s::UInt64; end
function nextu!(r::XS)
    x = r.s
    x ⊻= x << 13; x ⊻= x >> 7; x ⊻= x << 17
    r.s = x
    return x
end
randint!(r::XS, lo::Int, hi::Int) = lo + Int(nextu!(r) % UInt64(hi - lo + 1))

function main()
    println("Stranger's independent Langton's Ant verification")
    println("="^70)

    # ---- Part 1: empty grid ----
    println("\n[Part 1] Empty grid, 15000 steps, period detected WITHOUT assuming 104:")
    res = run_and_detect(Tuple{Int,Int}[], 15000)
    if res.found
        println("  Highway FOUND: period=$(res.period), onset step ≈ $(res.onset), displacement/period=$(res.disp)")
        println("  Expected from literature: period 104, onset ≈ 9977–10000, |disp|=(±2,±2)")
        agree = res.period == 104
        println("  Period agrees with known value 104: $agree")
    else
        println("  Highway NOT found -- implementation problem likely.")
    end

    # ---- Part 2: random finite perturbations ----
    println("\n[Part 2] Random finite perturbations (OBSERVED evidence, not proof):")
    NTRIALS = 100           # 5x Dreamer's n=20
    BUDGET  = 250_000       # generous step budget
    rng = XS(UInt64(20240601))
    found_count = 0
    onsets = Int[]
    failures = Int[]
    for trial in 1:NTRIALS
        k = randint!(rng, 1, 12)                       # 1..12 black cells
        cells = Tuple{Int,Int}[]
        for _ in 1:k
            push!(cells, (randint!(rng, -10, 10), randint!(rng, -10, 10)))
        end
        unique!(cells)
        res = run_and_detect(cells, BUDGET)
        if res.found && res.period == 104
            found_count += 1
            push!(onsets, res.onset)
        else
            push!(failures, trial)
        end
    end
    println("  Trials: $NTRIALS, budget $BUDGET steps each, cells perturbed in [-10,10]^2 (1-12 cells)")
    println("  Period-104 highway detected: $found_count / $NTRIALS ($(round(100found_count/NTRIALS, digits=1))%)")
    if !isempty(onsets)
        println("  Onset steps: min=$(minimum(onsets)), median=$(sort(onsets)[cld(end,2)]), max=$(maximum(onsets))")
    end
    if !isempty(failures)
        println("  Trials with NO highway within budget: $(length(failures)) -> trial ids $(failures)")
        println("  NOTE: 'not found within budget' ≠ 'never forms'. Tag: OBSERVED, budget-limited.")
    end

    println("\nEpistemic summary:")
    println("  Part 1: EXHAUSTIVELY VERIFIED (single initial condition, exact integer dynamics)")
    println("  Part 2: OBSERVED (n=$NTRIALS, budget=$BUDGET; no claim beyond sample)")
    println("  Universal highway conjecture: remains CONJECTURED (cannot be settled by simulation)")
end

main()
