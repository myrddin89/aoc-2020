#%%
cd(@__DIR__)
using ProgressLogging
function dist(c1, c2)
    x1, y1 = c1.I
    x2, y2 = c2.I
    abs(x2-x1) + abs(y2-y1)
end
y₀ = 2_000_000
# y₀ = 10
input = map(eachline("input.txt")) do line
    m = match(r"Sensor at x=([-0-9]*), y=([-0-9]*): closest beacon is at x=([-0-9]*), y=([-0-9]*)", line)
    x1,y1,x2,y2 = parse.(Int, m.captures)
    c1, c2 = CartesianIndex(y1,x1), CartesianIndex(y2,x2)
    (sens=c1, beacon=c2, dist=dist(c1, c2))
end
xmin, xmax = reduce(input, init=(typemax(Int), typemin(Int))) do (min_, max_), s
    _, x = s.sens.I
    min(min_, x - s.dist), max(max_, x + s.dist)
end
ymin, ymax = reduce(input, init=(typemax(Int), typemin(Int))) do (min_, max_), s
    y, _ = s.sens.I
    min(min_, y - s.dist), max(max_, y + s.dist)
end
cmin, cmax = CartesianIndex(y₀, xmin), CartesianIndex(y₀, xmax)

#%%
function _solution1()
    filter(cmin:cmax) do c
        any(input) do s
            dist(s.sens, c) <= s.dist && s.beacon != c && s.sens != c
        end
    end |> length
end

#%%
@time _solution1()

#%%
function _solution()
    count_ = 0
    for c in cmin:cmax
        res = any(input) do s
            dist(s.sens, c) <= s.dist && s.beacon != c && s.sens != c
        end
        if res
            count_ += 1
        end
    end
    count_
end

#%%
# @time _solution()

#%% PART TWO
# X = 20
X = 4_000_000
y₀ = X ÷ 2
function tf(res)
    length(res) == 1 || return nothing
    y, x = first(res).I
    x * 4_000_000 + y
end
function _solution2()
    function _find_pair()
        flt = Iterators.filter(Iterators.product(input, input)) do (c1, c2)
            c1 != c2 && dist(c1.sens, c2.sens) >= c1.dist + c2.dist + 2
        end
        argmin(flt) do (c1, c2)
            dist(c1.sens, c2.sens)
        end
    end
    c1, c2 = _find_pair()
    @info dist(c1.sens, c2.sens) - c1.dist - c2.dist
    # @info res
    # res = tf([c])
    res = nothing
    return res, c1, c2
end

#%%
@time res, c1, c2 = _solution2()

#%%
dirs = (CartesianIndex(0,1), CartesianIndex(1,0))
s = c1.sens + CartesianIndex(-c1.dist-1,2)
e = c1.sens + CartesianIndex(0, c1.dist+1+2)
@info s, e, dist(s, e)

#%%
n = dist(s, e)
let s = s
    @progress for i in 0:n-1
        check = all(input) do S
            S.sens != c1 && dist(S.sens, s) > S.dist && S.beacon != s
        end
        if check
            @info s
            break
        end
        s += dirs[i % 2 + 1]
    end
    @info s, tf([s]), s == e
end

#%%
function _draw_map(c1, c2)
    sol = CartesianIndex(11, 14)
    map_ = fill('.', 21, 21)
    for c in CartesianIndices(map_)
        for s in (c1, c2)
            @inbounds if c == s.sens
                map_[c] = 'S'
            elseif c == sol
                map_[c] = 'X'
            elseif c == s.beacon
                map_[c] = 'B'
            elseif dist(c, s.sens) <= s.dist && map_[c] == '.'
                map_[c] = '#'
            end end
    end
    for i in axes(map_, 1)
        for j in axes(map_, 2)
            print(map_[i, j])
        end
        println()
    end
end

#%%
_draw_map(c1, c2)

#%%
