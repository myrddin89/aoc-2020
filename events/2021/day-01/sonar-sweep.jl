##
cd(@__DIR__)
using DelimitedFiles
input = readdlm("input.txt", Int) |> vec;

##
count(>(0),diff(input))


## PARTE 2
using DataStructures: nil, cons, list

##
res = foldl(1:length(input)-2; init=nil()) do l, w
    cons(sum(input[w:w+2]), l)
end;

##
count(>(0), diff(collect(reverse(res))))
