#%%
cd(@__DIR__)
function eval_packet(p)
    if p isa Expr
        if p.head == :vect
            [eval_packet(x) for x in p.args]
        end
    else
        p
    end
end
myisless(x::Int, y::Int) = x <= y
myisless(xs::Vector, x::Int) = myisless(xs, [x])
myisless(x::Int, ys::Vector) = myisless([x], ys)
function myisless(xs::Vector, ys::Vector)
    for (x, y) in zip(xs, ys)
        x == y && continue
        return myisless(x, y)
    end
    length(xs) <= length(ys)
end

#%%
packets = map(Iterators.partition(Iterators.filter(!isempty, eachline("input.txt")), 2)) do ps
    eval_packet.(Meta.parse.(ps))
end

#%%
sum(enumerate(packets)) do (i, (l, r))
    l == r && return i
    myisless(l, r) ? i : 0
end

#%% PART TWO
packets′ = reduce(packets, init=[]) do a, ps
    [a; ps]
end
push!(packets′, [[2]], [[6]])


#%%
packets′ = sort(packets′, lt=myisless);

#%%
findall(x -> x == [[2]] || x == [[6]], packets′) |> prod
