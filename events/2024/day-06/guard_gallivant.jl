#%%
cd(@__DIR__)
patrolmap = stack(eachline("input.txt"))

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


#%%
function moveguard2(patrolmap)
    curpos = findfirst(==('^'), patrolmap)
    isnothing(curpos) && error("starting position not found")
    direction = CartesianIndex(0,-1)
    visited = Set{Tuple{CartesianIndex{2},CartesianIndex{2}}}([(curpos, direction)])
    isloop = false
    while true
        nextpos = curpos + direction
        i, j = nextpos.I
        if i ∉ axes(patrolmap, 1) || j ∉ axes(patrolmap, 2)
            break
        elseif patrolmap[nextpos] == '#' || patrolmap[nextpos] == 'O'
            i, j = direction.I
            direction = CartesianIndex(-j, i)
            continue
        end
        curpos = nextpos
        if (curpos, direction) ∈ visited
            @info "loop detected: $curpos"
            isloop = true
            break
        end
        push!(visited, (curpos, direction))
    end
    visited_pos = map(first, collect(visited))
    directions = map(last, collect(visited))
    return visited_pos, isloop
end

function
end

visited, patrolmap = moveguard2(patrolmap)
