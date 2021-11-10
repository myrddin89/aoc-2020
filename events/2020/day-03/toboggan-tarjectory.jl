##
cd(@__DIR__())
using FFTViews
using Base.Iterators: cycle, takewhile, filter, accumulate
mappa = reduce(hcat, Vector{Char}.(eachline("input.txt"))) |> FFTView;
prod(((1,1), (3,1), (5, 1), (7, 1), (1, 2)) .|> CartesianIndex) do Δ
    pos = takewhile(c -> c.I[2] < size(mappa, 2), accumulate(+, cycle([Δ]); init=CartesianIndex(0,0)))
    filter(c -> mappa[c] == '#', pos) |> collect |> length
end


##
sum(enumerate(eachline("input.txt"))) do (i, line)
    map([(1,1), (3,1), (5, 1), (7, 1), (1, 2)]) do (r,d)
        (i-1) % d == 0 || return false
        line[(((i-1) ÷ d) * r) % length(line) + 1] == '#'
    end
end |> prod
