#%%
cd(@__DIR__)
using IntervalSets
input = stack(eachline("test.txt"))

#%%
function make_neighbours(input, l)
    indices = CartesianIndices(input)
    neighbourhood = [CartesianIndex(s1*(l-1), s2*(l-1)) for s1 in [-1, 0, 1] for s2 in [-1, 0, 1] if s1 != 0 || s2 != 0]

    neighs = map(indices) do c
        filter(c .+ neighbourhood) do c′
            i, j = Tuple(c′)
            i ∈ axes(input, 1) && j ∈ axes(input, 2)
        end
    end

    # filter(cs -> length(cs) == l, neighs)
end

neighbours = make_neighbours(input, length("XMAS"));

result = map(neighbours) do n
    input[n]
end
