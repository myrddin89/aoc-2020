#%%
cd(@__DIR__)
using DataStructures, OffsetArrays
flip(f) = (x,y) -> f(y, x)
∅ = Set{CartesianIndex{2}}()
O = CartesianIndex(0,500)
@time rocks = mapreduce(union!, eachline("input.txt"), init=copy(∅)) do line
    _nil = nil(CartesianIndex{2})
    Λ = mapreduce(flip(cons), eachsplit(line, "->"), init=_nil) do point
        x, y = parse.(Int, eachsplit(strip(point), ","))
        CartesianIndex(y, x)
    end
    mapreduce(union!, Λ, tail(Λ), init=copy(∅)) do c1, c2
        vec(min(c1, c2):max(c1, c2))
    end
end;

#%%
function draw_map(rocks, resting; hasfloor=false, O=O)
    println("\033c")
    c1, c2 = extrema(rocks ∪ Ref(O))
    r1, r2 = extrema((c1, c2, extrema(resting)...))
    cm = c2
    floor = ∅
    if hasfloor
        cm += CartesianIndex(2, 0)
        floor = Set(CartesianIndex(cm.I[1], r1.I[2]):CartesianIndex(cm.I[1],r2.I[2]))
    end
    c1, c2 = extrema((cm, r1, r2))
    inds = c1:c2
    for i in axes(inds, 1)
        for j in axes(inds, 2)
            c = inds[i, j]
            if c ∈ rocks
                print('#')
            elseif c ∈ resting
                print('o')
            elseif c ∈ floor
                print('_')
            else
                print('.')
            end
        end
        println()
    end
end

#%%
function _solution(∅=∅, O=O)
    directions = CartesianIndex(1, 0), CartesianIndex(1, -1), CartesianIndex(1, 1)
    isfalling = false
    resting = copy(∅)
    c1, c2 = extrema(rocks ∪ Ref(O))
    lims = c1:c2
    while !isfalling
        isresting = false
        c = c′ = O
        while !isresting
            for d ∈ directions
                c′ = c+d
                if c′ ∉ rocks && c′ ∉ resting
                    c = c′
                    isresting = false
                    break
                else
                    isresting = true
                end
            end
            if c′ ∉ lims
                isfalling = true
                break
            end
        end
        if !isfalling
            push!(resting, c)
        end
    end
    resting, length(resting)
end

#%%
@time resting, l = _solution()
draw_map(rocks, resting)
@info l

#%% PART TWO
function _solution2(∅=∅, O=O)
    directions = CartesianIndex(1, 0), CartesianIndex(1, -1), CartesianIndex(1, 1)
    isblocked = false
    resting = copy(∅)
    floor, _ = maximum(rocks ∪ Ref(O)).I
    floor += 2
    while !isblocked
        isresting = false
        c = c′ = O
        while !isresting
            for d ∈ directions
                c′ = c+d
                if c′ ∉ rocks && c′ ∉ resting && c′.I[1] < floor
                    c = c′
                    isresting = false
                    break
                else
                    isresting = true
                end
            end
            if c == O
                push!(resting, O)
                isblocked = true
                break
            end
        end
        if !isblocked
            push!(resting, c)
        end
    end
    resting, length(resting)
end

#%%
@time resting, l = _solution2()
# draw_map(rocks, resting; hasfloor=true)
@info l
