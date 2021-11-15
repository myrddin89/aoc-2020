## PARTE 1
cd(@__DIR__)
rx = r"([0-9]+)x([0-9]+)x([0-9]+)"
input = map(eachline("input.txt")) do line
    m = match(rx, line)
    sort(parse.(Int, m.captures))
end;

##
total_area(x, y, z) = 3x*y + 2y*z + 2x*z
sum(x->total_area(x...), input)

## PARTE 2
total_ribbon(xs) = 2*sum(xs[1:2]) + prod(xs)
sum(total_ribbon, input)
