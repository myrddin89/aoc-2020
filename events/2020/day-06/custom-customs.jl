##
cd(@__DIR__())
using IterTools: groupby
using Underscores
@_ sum(foldl(∪, Set.(_))|>length, groupby(isempty, eachline("input.txt")))

## PARTE 2
@_ sum(foldl(∩, Set.(_))|>length, groupby(isempty, eachline("input.txt")))
