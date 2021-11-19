## PARTE 1
cd(@__DIR__)
conv(c) = c == '.' ? 0 : c == '#' ? 1 : missing
#init = conv.(reduce(hcat, collect.(eachline("input.txt"))))
init = conv.([
    [ '.' '#' '.' ];
    [ '.' '.' '#' ];
    [ '#' '#' '#' ]
])
sz = 3 * max(size(init)...)
cells = zeros(Int, sz, sz, sz)
cells[1:size(init, 1),1:size(init, 2),1] .= init;
new_cells = similar(cells);
start = deepcopy(cells);

##
wrap(x, y, z; sz=size(cells)) = CartesianIndex((mod(i, 1:si) for (i,si) in zip((x, y, z), sz))...)
function neighbours(c; sz=size(cells))
    x, y, z = c.I .- 1
    Δs = (-1, 0, 1)
    [wrap(x+a+1, y+b+1, z+c+1; sz) for a in Δs, b in Δs, c in Δs if (a,b,c) != (0,0,0)] |> vec
end
isactive(c) = c == 1
function conway!(new_cells, cells)
    @assert size(new_cells) == size(cells)
    _isactive(c) = isactive(cells[c])
    foreach(CartesianIndices(cells)) do c
        state = cells[c]
        ns = neighbours(c; sz=size(cells))
        num = count(_isactive, ns)
        cells[c] = if _isactive(c)
            num != 2 && num != 3 ? 0 : state
        else
            num == 3 ? 1 : state
        end
    end
end

##
cells = deepcopy(start)
new_cells .= 0
println("Epoch (0): active cells $(count(isactive, cells))")
foreach(1:6) do epoch
    global cells
    global new_cells
    conway!(new_cells, cells)
    new_cells, cells = cells, new_cells
    println("Epoch ($epoch): active cells $(count(isactive, cells))")
end
