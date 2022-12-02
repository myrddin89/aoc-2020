#%%
cd(@__DIR__)
items = read("input.txt", String);
items = replace(items, "\n" => ",")
items = map(split(items, ",,")) do x
    sum(parse.(Int, filter(!isempty, split(x, ","))))
end
maximum(items)

#%% PART TWO
sort(items, rev=true)[1:3] |> sum
