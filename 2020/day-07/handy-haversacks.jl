cd(@__DIR__())
using Base.Iterators: take
import Base: push!
kind_re = r"^([a-z]+ ?[a-z]*) bags"i
children_re = r"([0-9]+) ([a-z]+ ?[a-z]*) (bag|bags),?.?"i
fs = (m->String(m[1]), ms->map(m->(String(m[2])),ms))
apply(f,x) = f(x)
rules = Dict(filter(x->!isempty(x[2]), map(eachline("input.txt")) do line
    kind = match(kind_re, line)
    children = eachmatch(children_re, line)
    map(apply, fs, (kind, children))
end));

##
function search_shiny!(counts, ks)
    foldl(ks; init=Set{String}()) do p, k
        c = get(counts, k, nothing)
        isnothing(c) && return p
        if c
            return p ∪ Set([k])
        else
            others = get(rules, k, nothing)
            isnothing(others) && return p
            res = search_shiny!(counts, others)
            if !isempty(res)
                counts[k] = true
                return search_shiny!(counts, ks)
            end
            return p ∪ res
        end
    end
end


##
nm = "shiny gold"
counts = Dict(map(collect(pairs(rules))) do (k, others)
    if nm ∈ others
        return k => true
    else
        return k => false
    end
end);
search_shiny!(counts, keys(counts))

## PARTE 2
fs = (m->String(m[1]), ms->map(m->(parse(Int, m[1]),String(m[2])),ms))
rules = Dict(filter(x->!isempty(x[2]), map(eachline("input.txt")) do line
    kind = match(kind_re, line)
    children = eachmatch(children_re, line)
    map(apply, fs, (kind, children))
end));

##
function count_bags(ks)
    length(ks) == 0 && return 0
    sum(ks) do (n, k)
        n * (1 + count_bags(get(rules, k, [])))
    end
end

##
count_bags(rules["shiny gold"])
