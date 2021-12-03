## PARTE 1
cd(@__DIR__)
using DelimitedFiles
input = readdlm("input.txt");
get_move(::Val{:forward}, x) = CartesianIndex(x, 0)
get_move(::Val{:up}, x) = CartesianIndex(0, -x)
get_move(::Val{:down}, x) = CartesianIndex(0, x)
get_move(::Val, x) = missing

##
origin = CartesianIndex(0, 0)
res = foldl(eachrow(input); init=origin) do pos, (s, Δ)
    move = get_move(Val(Symbol(s)), Δ)
    ismissing(move) && return
    pos += move
end
prod(res.I)
