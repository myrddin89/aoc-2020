##
cd(@__DIR__())
using IterTools: groupby
using Combinatorics: powerset
jolts = map(eachline("input.txt")) do line
    parse(Int, line)
end;

##
function find_chain(jolts)
    res = [0]
    joltsc = copy(jolts)
    while !isempty(joltsc)
        x = last(res)
        ms = findall(joltsc) do y
            abs(y-x) <= 3
        end
        if isnothing(ms) || isempty(ms)
            @info "Not found $x"
            break
        else
            m = argmin([joltsc[m] for m ∈ ms])
        end
        append!(res, joltsc[ms[m]])
        deleteat!(joltsc, ms[m])
    end
    append!(res, last(res) + 3)
    res, diff(res), [filter(==(x), diff(res)) |> length for x ∈ (1,2,3)]
end

##
chain, d, h = find_chain(jolts)
@info h[1] * h[3]

## PARTE 2
function check_chain(chain)
    maximum(diff(chain)) <= 3
end
function find_pivot(chain)
    Iterators.filter(eachindex(chain)) do i
        i == 1 && return false
        i == lastindex(chain) && return false
        chain[i+1] - chain[i-1] <= 3
    end |> collect
end
function count_chains(chain, ns)
    gs = []
    cur = Int[ns[1]]
    for n ∈ ns[2:end]
        if n - last(cur) == 1
            push!(cur, n)
        else
            push!(gs, cur)
            cur = [n]
        end
    end
    push!(gs, cur)
    prod(gs) do g
        length(g) == 1 && return 2
        ss = powerset(g, 2)
        1 + length(g) + count(ss) do s
            c′ = copy(chain)
            check_chain(deleteat!(c′, s))
        end
    end
end;

##
ns = find_pivot(chain)
count_chains(chain, ns)
