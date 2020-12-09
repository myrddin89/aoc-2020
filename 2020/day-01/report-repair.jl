##
cd(@__DIR__())
using DelimitedFiles

##
path = "input.txt"
vals = readdlm(path, ' ', Int)

##
function find_triple(vals, res = 2020)
    for x in vals, y in vals, z in vals
        x + y + z == res && return x*y*z
    end
end

##
find_triple(vals)
