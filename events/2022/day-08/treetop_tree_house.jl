#%%
cd(@__DIR__)
trees = reduce(eachline("input.txt"), init=zeros(Int, 0, 0)) do a, line
    isempty(a) && return parse.(Int, collect(line))
    hcat(a, parse.(Int, collect(line)))
end |> permutedims;
count(CartesianIndices(trees)) do index
    r, c = index.I
    dirs = (1:r-1,c), (r,1:c-1), (r+1:size(trees,1),c), (r,c+1:size(trees,2))
    any(maximum(trees[d...],init=-1) < trees[index] for d in dirs)
end

#%% PART TWO
maximum(CartesianIndices(trees)) do index
    r, c = index.I
    dirs = (reverse(1:r-1),c), (r,reverse(1:c-1)), (r+1:size(trees,1),c), (r,c+1:size(trees,2))
    prod(dirs) do d
        ts = trees[d...] |> vec
        something(findfirst(>=(trees[index]), ts), lastindex(ts))
    end
end
