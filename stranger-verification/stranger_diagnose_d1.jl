# Exact diagnosis of D1: which (rule, state) pairs have transient+period > 49,
# i.e. would evade Dreamer's 50-step history check and be mislabeled :growing?
const WIDTH = 8
const NSTATES = 256

function step_ca(s::Int, rule::Int)::Int
    new = 0
    for i in 0:(WIDTH-1)
        left   = (s >> ((i + 1) % WIDTH)) & 1
        center = (s >> i) & 1
        right  = (s >> ((i - 1 + WIDTH) % WIDTH)) & 1
        idx = (left << 2) | (center << 1) | right
        (rule >> idx) & 1 == 1 && (new |= (1 << i))
    end
    new
end

function transients_periods(rule)
    succ = [step_ca(s, rule) for s in 0:NSTATES-1]
    period = fill(-1, NSTATES); transient = fill(-1, NSTATES)
    for start in 0:NSTATES-1
        period[start+1] != -1 && continue
        path = Int[]; pos = Dict{Int,Int}(); s = start
        while true
            if period[s+1] != -1
                for (k, st) in enumerate(path)
                    d = length(path) - (k-1)
                    period[st+1] = period[s+1]
                    transient[st+1] = max(0, transient[s+1] + d)
                end
                break
            elseif haskey(pos, s)
                c = pos[s]; plen = length(path) - c
                for (k, st) in enumerate(path)
                    i0 = k-1
                    period[st+1] = plen
                    transient[st+1] = i0 < c ? c - i0 : 0
                end
                break
            else
                pos[s] = length(path); push!(path, s); s = succ[s+1]
            end
        end
    end
    transient, period
end

println("Rules with ANY state where transient+period > 49 (evades 50-step check):")
total_bad_pairs = 0
for rule in 0:255
    tr, pe = transients_periods(rule)
    bad = count(i -> tr[i] + pe[i] > 49, 1:NSTATES)
    if bad > 0
        global total_bad_pairs += bad
        println("  rule $rule: $bad/256 states evade detection (max transient+period = $(maximum(tr .+ pe)))")
    end
end
println("\nTotal evading (rule,state) pairs: $total_bad_pairs / $(256*256)")
println("Probability a RANDOM state evades on a random vulnerable rule => explains")
println("why Dreamer saw ~2 'growing' rules per run (sampling 1 random state/rule).")
