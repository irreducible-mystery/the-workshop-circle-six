# ============================================================
# STRANGER'S INDEPENDENT VERIFICATION
# Elementary CA exhaustive classification, width-8 cyclic universe
# Written WITHOUT reading Dreamer's implementation (contamination control)
#
# Epistemic status of output: EXHAUSTIVELY VERIFIED over the stated
# finite domain (all 256 rules x all 256 initial states, exact cycle
# detection -- no step limit, no sampling).
#
# Key design choice: state space of width-8 cyclic CA is exactly 2^8 = 256
# states. Every trajectory MUST be eventually periodic (pigeonhole).
# Therefore "growing" is not a possible class in this universe.
# We compute, per rule:
#   - exact successor map succ[s] for all 256 states
#   - exact transient length and cycle period for every initial state
#   - max/min period over all starts, max transient, # distinct cycles
# ============================================================

const WIDTH = 8
const NSTATES = 256  # 2^WIDTH

# Apply elementary CA rule to state s (UInt: bit i = cell i), cyclic boundary.
function step_ca(s::Int, rule::Int)::Int
    new = 0
    for i in 0:(WIDTH-1)
        left   = (s >> ((i + 1) % WIDTH)) & 1        # neighbor with higher index = left (convention consistent throughout)
        center = (s >> i) & 1
        right  = (s >> ((i - 1 + WIDTH) % WIDTH)) & 1
        idx = (left << 2) | (center << 1) | right     # Wolfram neighborhood index 0..7
        if (rule >> idx) & 1 == 1
            new |= (1 << i)
        end
    end
    return new
end

# Exact cycle structure for one rule: returns per-state (transient, period)
# plus rule-level summary. Uses full trajectory walking with visited-time map.
function analyze_rule(rule::Int)
    succ = [step_ca(s, rule) for s in 0:(NSTATES-1)]  # succ[s+1] = successor of s

    # period[s+1], transient[s+1]; -1 = unknown
    period    = fill(-1, NSTATES)
    transient = fill(-1, NSTATES)

    for start in 0:(NSTATES-1)
        period[start+1] != -1 && continue
        # walk until we hit a state with known values or revisit within this walk
        path = Int[]
        pos_in_path = Dict{Int,Int}()   # state => index in path (0-based step count)
        s = start
        while true
            if period[s+1] != -1
                # tail joins previously solved region
                for (k, st) in enumerate(path)
                    d = length(path) - (k - 1)          # steps from st to s
                    period[st+1]    = period[s+1]
                    transient[st+1] = max(0, transient[s+1] + d)
                end
                break
            elseif haskey(pos_in_path, s)
                # found a new cycle within this walk
                cstart = pos_in_path[s]
                plen = length(path) - cstart
                for (k, st) in enumerate(path)
                    idx0 = k - 1
                    period[st+1]    = plen
                    transient[st+1] = idx0 < cstart ? (cstart - idx0) : 0
                end
                break
            else
                pos_in_path[s] = length(path)
                push!(path, s)
                s = succ[s+1]
            end
        end
    end

    # distinct cycles: canonical representative = min state among cycle members
    cyclereps = Set{Int}()
    for s in 0:(NSTATES-1)
        if transient[s+1] == 0
            # walk the cycle to find min member
            m = s; t = succ[s+1]
            while t != s
                m = min(m, t); t = succ[t+1]
            end
            push!(cyclereps, m)
        end
    end

    return (maxperiod = maximum(period),
            minperiod = minimum(period),
            maxtransient = maximum(transient),
            ncycles = length(cyclereps),
            # period reached from the single-cell seed (state 1), common convention:
            seed_period = period[2],
            seed_transient = transient[2])
end

# ---------------- main ----------------
function main()
    println("Stranger's exhaustive width-$WIDTH cyclic elementary CA classification")
    println("Domain: all 256 rules x all 256 initial states, exact cycle detection")
    println("="^70)

    maxperiods = zeros(Int, 256)
    maxtransients = zeros(Int, 256)

    class_counts = Dict{String,Int}()
    per_rule = Vector{NamedTuple}(undef, 256)

    for rule in 0:255
        r = analyze_rule(rule)
        per_rule[rule+1] = r
        maxperiods[rule+1] = r.maxperiod
        maxtransients[rule+1] = r.maxtransient

        cls = r.maxperiod == 1 ? "fixed-point (max period 1)" :
              r.maxperiod == 2 ? "max period 2" :
              "max period > 2"
        class_counts[cls] = get(class_counts, cls, 0) + 1
    end

    println("\nClassification by MAX period over ALL 256 initial states:")
    for (k, v) in sort(collect(class_counts))
        println("  $k : $v rules ($(round(100v/256, digits=1))%)")
    end

    println("\nGlobal extremes across all rules:")
    mp, mpi = findmax(maxperiods)
    mt, mti = findmax(maxtransients)
    println("  Longest period anywhere: $mp (rule $(mpi-1))")
    println("  Longest transient anywhere: $mt (rule $(mti-1))")

    # Distribution of max periods
    pdist = Dict{Int,Int}()
    for p in maxperiods; pdist[p] = get(pdist, p, 0) + 1; end
    println("\nDistribution of max period (period => #rules):")
    for (p, c) in sort(collect(pdist))
        println("  period $p => $c rules")
    end

    # Spot checks against known facts:
    println("\nSpot checks:")
    # Rule 204 is the identity rule: every state is a fixed point.
    r204 = per_rule[205]
    println("  Rule 204 (identity): maxperiod=$(r204.maxperiod), maxtransient=$(r204.maxtransient), ncycles=$(r204.ncycles)  [expect 1, 0, 256]")
    # Rule 51 is complement: every state has period 2 (no fixed points possible since 8 cells all flip)
    r51 = per_rule[52]
    println("  Rule 51 (complement): maxperiod=$(r51.maxperiod), minperiod=$(r51.minperiod)  [expect 2, 2]")
    # Rule 0 maps everything to 0: fixed point, transient <= 1
    r0 = per_rule[1]
    println("  Rule 0 (zero map): maxperiod=$(r0.maxperiod), maxtransient=$(r0.maxtransient), ncycles=$(r0.ncycles)  [expect 1, 1, 1]")

    # Note on the impossibility of 'growing':
    println("\nNOTE: In a finite cyclic universe (2^$WIDTH = $NSTATES states), every")
    println("trajectory is eventually periodic by pigeonhole. 'Growing' is not a")
    println("possible class here. Any 'growing' classification indicates either an")
    println("unbounded-width implementation or an undetected-cycle artifact.")

    # Save per-rule table
    open("stranger_ca_results.csv", "w") do io
        println(io, "rule,maxperiod,minperiod,maxtransient,ncycles,seed_period,seed_transient")
        for rule in 0:255
            r = per_rule[rule+1]
            println(io, "$rule,$(r.maxperiod),$(r.minperiod),$(r.maxtransient),$(r.ncycles),$(r.seed_period),$(r.seed_transient)")
        end
    end
    println("\nPer-rule table saved to stranger_ca_results.csv")
end

main()
