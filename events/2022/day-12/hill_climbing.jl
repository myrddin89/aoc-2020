#%%
cd(@__DIR__)
using DataStructures
map_ = mapreduce(collect, hcat, eachline("input.txt"));
elevation = copy(map_)
S = findfirst(==('S'), vec(elevation))
E = findfirst(==('E'), vec(elevation))
elevation[S] = 'a'
elevation[E] = 'z'
weights = elevation .- 'a'
directions = CartesianIndex(1, 0), CartesianIndex(-1, 0), CartesianIndex(0, 1), CartesianIndex(0, -1)
@inline function _check_index(c, axs)
    i, j = c.I
    rs, cs = axs
    i in rs && j in cs
end
neigh = map(vec(CartesianIndices(map_))) do x
    [x+d for d in directions if _check_index(x+d, axes(map_))]
end
@inline function tolinindex(c, rows)
    i, j = c.I
    (j - 1) * rows + i
end

#%%
function dijkstra(weights, S, E)
    rows = size(weights, 1)
    dist = zeros(Int, length(weights))
    prev = zeros(Int, length(weights))
    Q = PriorityQueue{Int,Int}()
    @inbounds for v in eachindex(weights)
        dist[v] = typemax(Int)
    end
    dist[S] = 0
    prev[S] = S
    Q[S] = 0
    inds = CartesianIndices(map_)
    steps = 0
    while !isempty(Q)
        u, _ = dequeue_pair!(Q)
        if u == E
            @info "DESTINATION"
            break
        end
        d = dist[u]
        d == typemax(Int) && break
        @inbounds for v in neigh[u]
            weights[v] - weights[u] < -1 && continue
            #x = d + abs(weights[v] - weights[u] - 1)
            x = d + 1
            iv = tolinindex(v, rows)
            if x < dist[iv]
                dist[iv] = x
                prev[iv] = u
                Q[iv] = x
                steps += 1
            end
        end
    end
    dist, prev
end

#%%
@time dist, prev = dijkstra(weights, E, S);

#%%
function _shortest_path(prev)
    # λ = nil(Int)
    λ = MutableLinkedList{Int}()
    u = E
    @inbounds while prev[u] != S
        # λ = cons(u, λ)
        pushfirst!(λ, u)
        u′ = prev[u]
        if u == u′
            @warn "LOOP DETECTED: $u"
            break
        end
        u = u′
    end
    λ, length(λ)
end

#%%
@time λ, l = _shortest_path(prev)
@show l+1

#%% PART TWO
function _shortest_trail(dist, elevation)
    starts = findall(==('a'), vec(elevation))
    x = dist[starts] |> argmin
    dist[starts[x]]
end

#%%
@time _shortest_trail(dist, elevation)
