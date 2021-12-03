## PARTE 2
cd(@__DIR__)
using DelimitedFiles
input = readdlm("input.txt");

##
apply_move(t, move::AbstractString, value) = apply_move(t, Val(Symbol(move)), value)
apply_move((x, y, aim), ::Val{:forward}, value) =
    (x + value, y + aim * value, aim)
apply_move((x, y, aim), ::Val{:up}, value) =
    (x, y, aim - value)
apply_move((x, y, aim), ::Val{:down}, value) =
    (x, y, aim + value)
apply_move(t, ::Val, value) = t

##
x, y, _ = foldl(eachrow(input); init=(0,0,0)) do cur, (move, value)
    apply_move(cur, move, value)
end
@show x * y
