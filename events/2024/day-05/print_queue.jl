#%%
cd(@__DIR__)

function parse_input(input_file)
    rules = Set{Pair{Int,Int}}()
    updates = Vector{Int}[]
    reading_rules = true
    for line in eachline(input_file)
        if isempty(line)
            reading_rules = false
            continue
        end
        pages = parse.(Int, split(line, r"\||,"))
        if reading_rules
            push!(rules, Pair(pages...))
        else
            push!(updates, pages)
        end
    end
    return (rules, updates)
end

#%%
rules, updates = parse_input("input.txt")

#%%
sorted_updates = filter(updates) do u
    issorted(u, lt=(x, y) -> ((x => y) ∈ rules))
end

sum(sorted_updates) do u
    u[(length(u)-1)÷2+1]
end

#%%
not_sorted_updates = filter(updates) do u
    !issorted(u, lt=(x, y) -> ((x => y) ∈ rules))
end

sum(not_sorted_updates) do u
    sort!(u, lt=(x, y) -> ((x => y) ∈ rules))
    u[(length(u)-1)÷2+1]
end
