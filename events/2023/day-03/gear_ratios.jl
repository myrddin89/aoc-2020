#%%
cd(@__DIR__)
issymbol(x) = !isdigit(x) && x != '.'
schema = permutedims(reduce(hcat, collect.(readlines("test.txt"))), (2,1))
neighbours = [CartesianIndex(x,y) for x in -1:1, y in -1:1 if (x,y) != (0,0)]
all_symbols = findall(issymbol, schema)

function find_digits(schema, s::CartesianIndex)
    nums_right = Char[]
    nums_left = Char[]
    c = s
    while checkbounds(Bool, schema, c) && isdigit(schema[c])
        push!(nums_right, schema[c])
        c += CartesianIndex(0,1)
    end
    c = s + CartesianIndex(0,-1)
    while checkbounds(Bool, schema, c) && isdigit(schema[c])
        push!(nums_left, schema[c])
        c += CartesianIndex(0,-1)
    end
    parse(Int, String(reverse(nums_left)) * String(nums_right))
end

function check_digit_neighbour(schema, c::CartesianIndex)
    any(neighbours) do n
        checkbounds(Bool, schema, c+n) && isdigit(schema[c+n])
    end
end

sum(all_symbols) do c
    res = map(neighbours) do n
        x = c+n
        checkbounds(Bool, schema, x) || return nothing
        isdigit(schema[x]) && return find_digits(schema, x)
        nothing
    end
    println(filter(!isnothing, res))
    sum(Iterators.filter(!isnothing,res))
end
