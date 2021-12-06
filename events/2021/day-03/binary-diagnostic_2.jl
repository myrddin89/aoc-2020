## PARTE 2
cd(@__DIR__)
input = map(line -> parse.(Bool, collect(line)), eachline("input.txt"));

##
function keep_only(pred, input)
    res = deepcopy(input)
    for j in axes(input[1], 1)
        length(res) == 1 && break
        pattern = pred(length(res))(foldl((s, row) -> s+row[j], res; init=0))
        filter!(row -> row[j] == pattern, res)
    end
    first(res)
end

##
oxygen_b = keep_only(d -> >=(cld(d, 2)), input)
CO2_b = keep_only(d -> <(cld(d, 2)), input)
n = length(oxygen_b)
oxygen, CO2 = foldl(0:n-1; init=(0,0)) do (o, c), i
    o |= oxygen_b[n-i] << i
    c |= CO2_b[n-i] << i
    o, c
end
oxygen * CO2
