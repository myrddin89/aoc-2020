#%%
cd(@__DIR__)
using DelimitedFiles
input = readdlm("input.txt", Int)

function compare_lists(input)
    mapslices(diff, mapslices(sort, input, dims=1), dims=2) .|> abs |> sum
end

#%%
compare_lists(input)

#%%
function similarity_score(input)
    input = mapslices(sort, input, dims=1)
    score = 0
    for n in view(input, :, 1)
        score += n * count(==(n), view(input, :, 2))
    end
    return score
end

similarity_score(input)
