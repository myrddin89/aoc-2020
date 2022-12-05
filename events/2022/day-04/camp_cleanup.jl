#%%
cd(@__DIR__)
using IntervalSets
contained(a, b) = a ⊆ b || b ⊆ a
contained(xs) = contained(xs...)
count(eachline("input.txt")) do line
    map(split.(split(line, ","), "-")) do xs
        Interval(parse.(Int, xs)...)
    end |> contained
end

#%% PART TWO
count(eachline("input.txt")) do line
    ys = map(split.(split(line, ","), "-")) do xs
        Interval(parse.(Int, xs)...)
    end
    !isempty(∩(ys...))
end
