#%%
cd(@__DIR__)
using DataStructures
using DelimitedFiles
norm1(c) = sum(abs, c)
dist(c1, c2) = norm1(c2 .- c1)
input′ = readdlm("input.txt", ',', Int)'
input = eachcol(input′) .|> Tuple |> Set;

#%%
function _solution1(input)
    v = collect(input)
    adj = counter(NTuple{3,Int})
    @views @inbounds for i in axes(v, 1)
        c1 = v[i]
        for j in i+1:lastindex(v, 1)
            c2 = v[j]
            if dist(c1, c2) == 1
                inc!(adj, c1, 2)
            end
        end
    end
    6 * size(v, 1) - sum(adj)
end
@time p1 = _solution1(input)

#%% PART TWO
function _solution2(input, input′)
    (minx, maxx), (miny, maxy), (minz,maxz) = extrema(input′, dims=2)
    neigh(x, y, z) = ((x-1,y,z),(x+1,y,z),(x,y-1,z),(x,y+1,z),(x,y,z-1),(x,y,z+1))
    Q = Queue{NTuple{3,Int}}()
    enqueue!(Q, (minx-1,miny-1,minz-1))
    outside = Set([(minx-1,miny-1,minz-1)])
    function _checkin(x, y, z)
        minx-1 <= x <= maxx+1 && miny-1 <= y <= maxy+1 && minz-1 <= z <= maxz+1
    end
    while !isempty(Q)
        c = dequeue!(Q)
        push!(outside, c)
        for c′ in neigh(c...)
            x, y, z = c′
            _checkin(x, y, z) && c′ ∉ input && c′ ∉ outside && c′ ∉ Q || continue
            enqueue!(Q, c′)
        end
    end
    @info "CICLO TERMINATO"
    inds = Set((x, y, z) for x in minx-1:maxx+1, y in miny-1:maxy+1, z in minz-1:maxz+1)
    inside = setdiff!(inds, input ∪ outside) |> collect
    @info length(inside)
    p_inside = _solution1(inside)
    @info p_inside
    p1 - p_inside
end

#%%
@time res = _solution2(input,input′)
