#%%
cd(@__DIR__)
using DelimitedFiles
using CircularArrays
input = readdlm("input.txt", '\n', Int) |> vec |> CircularVector;

#%%
function wrap(x, r)
    x == 0 && return x
    mod(x, r)
end
@inline function swap!(a, k, n, r)
    n == 0 && return
    n = wrap(n, r)
    for i in k:k+n-1
        j = i+1
        @inbounds a[i], a[j] = a[j], a[i]
    end
end
function get_coo(xs)
    _0 = findfirst(x -> x.second == 0, xs)
    sum(xs[i].second for i in _0 .+ (1:3) * 1000)
end
function make_round!(xs, inds)
    f, l = first(inds), last(inds)
    rs = 1:max(f, l)-min(f, l)
    for i in inds
        κ = findfirst(x -> x.first == i, xs)
        @inbounds _, n = xs[κ]
        swap!(xs, κ, n, rs)
        # @info i, κ, n, wrap(n, rs), [wrap(x, rs) => i for (i,x) in xs]
    end
    xs
end

#%%
function _solution1(input)
    res = CircularVector([i => n for (i, n) in enumerate(input)])
    make_round!(res, eachindex(input))
    get_coo(res), [x.second for x in res]
end

#%%
@time _solution1(input)

#%% PART TWO
dkey = 811589153

#%%
function _solution2(input, dkey)
    inds = eachindex(input)
    # @info input, input * dkey
    res = CircularVector([i => n * dkey for (i, n) in enumerate(input)])
    # @info [i => x => wrap(x, 1:6) for (i,x) in res]
    # @info 1, firstindex(res), first(res).second, [wrap(x, 1:6) => i for (i, x) in res]
    for _ in 1:10
        make_round!(res, inds)
    end
    get_coo(res), map(x->x.second, res)
end

#%%
@time _solution2(input, dkey)
