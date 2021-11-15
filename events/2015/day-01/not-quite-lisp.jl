## PARTE 1
cd(@__DIR__)

##
open("input.txt") do f
    sum(strip(read(f, String))) do x
        2 * (')' - x) - 1
    end
end

## PARTE 2
input = open("input.txt") do f
    strip(read(f, String))
end |> collect;

##
findfirst(==(-1), accumulate((f, x) -> f + 2 * (')' - x) - 1, input; init=0))
