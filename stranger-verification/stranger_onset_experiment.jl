# ============================================================
# STRANGER'S ONSET-TIME EXPERIMENT — Langton's Ant
# Question: How does highway onset time depend on perturbation size k?
# Motivating OBSERVED fact: perturbed starts (median 4051, n=100 mixed k)
# reached highway FASTER than empty grid (9977).
#
# Protocol (agreed with Dreamer's design):
#   k ∈ {0,1,2,3,4,5} black cells placed uniformly in [-10,10]^2
#   n = 100 trials per k (k>=1); k=0 is deterministic (1 run)
#   budget = 250,000 steps; seeded PRNG, seed recorded
#   Blind period detection (no assumption of 104), early-stop checks
#
# Epistemic tag of all results: OBSERVED (stated n, budget, placement box)
# ============================================================

const DX = (0, 1, 0, -1)
const DY = (1, 0, -1, 0)

mutable struct Ant
    x::Int; y::Int; dir::Int
    grid::Dict{Tuple{Int,Int},Bool}
end
Ant() = Ant(0, 0, 0, Dict{Tuple{Int,Int},Bool}())

@inline function step!(a::Ant)
    p = (a.x, a.y)
    black = get(a.grid, p, false)
    a.dir = black ? mod(a.dir + 3, 4) : mod(a.dir + 1, 4)
    black ? delete!(a.grid, p) : (a.grid[p] = true)
    a.x += DX[a.dir + 1]; a.y += DY[a.dir + 1]
    a
end

# Blind highway detection on a trace suffix (periods 1..maxP, sustained >= confirm_mult periods)
function detect_highway(trace::Vector{NTuple{3,Int}}, n::Int; maxP::Int=300, confirm_mult::Int=20)
    for P in 1:maxP
        need = confirm_mult * P
        n - need - P < 1 && continue
        lo = n - need - P + 1
        dx = trace[n][1] - trace[n-P][1]
        dy = trace[n][2] - trace[n-P][2]
        (dx == 0 && dy == 0) && continue
        ok = true
        for t in lo:(n - P)
            a, b = trace[t], trace[t+P]
            if b[3] != a[3] || b[1]-a[1] != dx || b[2]-a[2] != dy
                ok = false; break
            end
        end
        if ok
            t0 = lo
            while t0 - 1 >= 1
                a, b = trace[t0-1], trace[t0-1+P]
                (b[3] == a[3] && b[1]-a[1] == dx && b[2]-a[2] == dy) || break
                t0 -= 1
            end
            return (found=true, period=P, onset=t0, disp=(dx,dy))
        end
    end
    (found=false, period=0, onset=0, disp=(0,0))
end

# Run with early-stop detection every `checkevery` steps
function run_trial(init_black::Vector{Tuple{Int,Int}}, budget::Int; checkevery::Int=10_000)
    a = Ant()
    for p in init_black; a.grid[p] = true; end
    trace = Vector{NTuple{3,Int}}(undef, budget)
    t = 0
    while t < budget
        chunk = min(checkevery, budget - t)
        for _ in 1:chunk
            step!(a); t += 1
            trace[t] = (a.x, a.y, a.dir)
        end
        res = detect_highway(trace, t)
        res.found && return res
    end
    detect_highway(trace, budget)
end

# Deterministic xorshift PRNG (reproducible, package-free)
mutable struct XS; s::UInt64; end
function nextu!(r::XS)
    x = r.s; x ⊻= x << 13; x ⊻= x >> 7; x ⊻= x << 17
    r.s = x; x
end
randint!(r::XS, lo::Int, hi::Int) = lo + Int(nextu!(r) % UInt64(hi - lo + 1))

quantile_sorted(v, q) = v[clamp(round(Int, q*(length(v)-1)) + 1, 1, length(v))]

function main()
    BASESEED = 77_2025_01
    BUDGET   = 250_000
    NTRIALS  = 100
    KS       = 0:5
    println("Stranger's onset-time experiment")
    println("base seed=$BASESEED, budget=$BUDGET, n=$NTRIALS per k, box=[-10,10]^2")
    println("="^72)

    open("stranger_onset_results.csv", "w") do io
        println(io, "k,trial,found,period,onset,cells")

        for k in KS
            onsets = Int[]
            nofind = 0
            wrong_period = 0
            ntr = k == 0 ? 1 : NTRIALS
            for trial in 1:ntr
                # per-trial seed: reproducible and independent across (k, trial)
                rng = XS(UInt64(BASESEED) * 1_000_003 + UInt64(k) * 10_007 + UInt64(trial))
                cells = Tuple{Int,Int}[]
                while length(cells) < k
                    c = (randint!(rng, -10, 10), randint!(rng, -10, 10))
                    c in cells || push!(cells, c)
                end
                res = run_trial(cells, BUDGET)
                cellstr = join(["($(c[1]);$(c[2]))" for c in cells], " ")
                println(io, "$k,$trial,$(res.found),$(res.period),$(res.onset),\"$cellstr\"")
                if res.found && res.period == 104
                    push!(onsets, res.onset)
                elseif res.found
                    wrong_period += 1
                else
                    nofind += 1
                end
            end
            sort!(onsets)
            if !isempty(onsets)
                med = quantile_sorted(onsets, 0.5)
                q1  = quantile_sorted(onsets, 0.25)
                q3  = quantile_sorted(onsets, 0.75)
                fastfrac = count(<(9977), onsets) / length(onsets)
                println("k=$k  n=$ntr  found104=$(length(onsets))  nofind=$nofind  otherP=$wrong_period")
                println("      onset: min=$(onsets[1])  Q1=$q1  median=$med  Q3=$q3  max=$(onsets[end])")
                println("      fraction faster than empty-grid 9977: $(round(fastfrac, digits=2))")
            else
                println("k=$k  n=$ntr  found104=0  nofind=$nofind  otherP=$wrong_period")
            end
        end
    end
    println("\nRaw data: stranger_onset_results.csv")
    println("Tag: OBSERVED (n per k as stated, budget=$BUDGET, box=[-10,10]^2, seed=$BASESEED)")
end

main()
