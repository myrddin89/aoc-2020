##
cd(@__DIR__())
using Underscores
using Base.Iterators: product
plen = 25
codes = @_ map(parse(Int, _), eachline("input.txt"));

##
i, invalid = Iterators.filter(enumerate(codes[plen+1:end])) do (i, c)
    foldl(product(codes[i:i+plen-1], codes[i:i+plen-1]); init=true) do p, (x, y)
        x >= y && return p
        p && x+y!=c
    end
end |> collect |> first

## PARTE 2
i = findfirst(==(invalid), codes);

##
filter(!isnothing, map(2:i-1) do l
    j = findfirst(1:i-l) do j
        sum(codes[j:j+l-1]) == invalid
    end
    isnothing(j) && return nothing
    extrema(codes[j:j+l-1]) |> sum
end)
