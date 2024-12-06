#%%
cd(@__DIR__)
input = stack(eachline("input.txt"))

#%%
function moveguard(patrolmap)
    curpos = findfirst(==('^'), patrolmap)
    isinside = true
    visited = Set{CartesianIndex{2}}([curpos])
    direction = CartesianIndex(0,-1)
    while true
        nextpos = curpos + direction
        i, j = nextpos.I
        if i ∉ axes(patrolmap, 1) || j ∉ axes(patrolmap, 2)
            break
        elseif patrolmap[nextpos] == '#'
            i, j = direction.I
            direction = CartesianIndex(-j, i)
            continue
        end
        curpos = nextpos
        push!(visited, curpos)
    end
    visited = collect(visited)
    patrolmap′ = copy(patrolmap)
    patrolmap′[visited] .= '*'
    return visited, patrolmap′
end

visited, patrolmap = moveguard(input)
