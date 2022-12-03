#%%
cd(@__DIR__)
prio(x) = isuppercase(x) ? x - 'A' + 27 : x - 'a' + 1
mapreduce(+, eachline("input.txt")) do line
    l = lastindex(line)÷2
    a, b = SubString.(line, (1:l, l+1:lastindex(line)))
    sum(prio, Set(a) ∩ Set(b))
end

#%% PART TWO
mapreduce(g -> sum(prio, ∩(Set.(g)...)), +, Iterators.partition(eachline("input.txt"), 3))
