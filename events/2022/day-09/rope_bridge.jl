#%%
cd(@__DIR__)
using DataStructures
function move(pos, m, n)
    m == 'R' && return pos + CartesianIndex(n,0)
    m == 'L' && return pos + CartesianIndex(-n,0)
    m == 'U' && return pos + CartesianIndex(0,n)
    m == 'D' && return pos + CartesianIndex(0,-n)
end
function move_neigh(h, ks, s, p)
    t = head(ks)
    x, y = (h - t).I
    if x == y == 0 || (abs(x) <= 1 && abs(y) <= 1)
        return cons(t, tail(ks)), s
    end
    t += CartesianIndex(sign(x), sign(y))
    ks, s = move_tail(t, tail(ks), s)
    move_neigh(h, ks, p ? push!(s, t) : s, p)
end
function move_tail(h, ks, s)
    if !isempty(ks)
        ks, s = move_neigh(h, ks, s, isempty(tail(ks)))
    end
    cons(h, ks), s
end
move(ks, s, m, n) = move_tail(move(head(ks), m, n), tail(ks), s)
function _solution()
    O = CartesianIndex(0,0)
    ks₀ = list(ntuple(_ -> O, 10)...)
    s₀ = Set(Ref(O))
    init = ks₀, s₀
    reduce(eachline("input.txt"); init) do (ks,s), line
        m, n = line[1], parse(Int, line[3:end])
        move(ks, s, m, n)
    end |> last
end
@time S = _solution()

#%%
# ss = S .- Ref(minimum(S)) .+ Ref(CartesianIndex(1,1));
# m = fill('.', maximum(ss).I)
# m[ss] .= '#'
# join(join.(eachcol(m)) |> reverse, '\n') |> println
