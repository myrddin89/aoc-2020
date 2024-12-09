#%%
cd(@__DIR__)
using Combinatorics
fieldmap = stack(eachline("test.txt")) |> permutedims

function print_map(fieldmap)
    for r in eachrow(fieldmap)
        foreach(print, r)
        println()
    end
end

#%%
print_map(fieldmap)

#%%
antennas = mapreduce(mergewith!(append!), pairs(fieldmap)) do (c, x)
    x == '.' && return Dict{Char,Vector{CartesianIndex{2}}}()
    Dict(x => [c])
end

#%%
function dist(a1, a2)
    abs.((a2-a1).I)
end

#%%
for (a, pos) in antennas
    foreach(combinations(pos, 2)) do cs
        println(dist(cs...))
    end
end
