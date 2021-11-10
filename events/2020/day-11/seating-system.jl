##
cd(@__DIR__())
codes = Dict(
    '.' => 1,
    'L' => 2,
    '#' => 3,
)
function check_cartesian(c, rows, cols)
    i, j = c.I
    1 <= i <= rows && 1 <= j <= cols && return c
    missing
end
directions = [
    CartesianIndex(-1,-1),
    CartesianIndex(-1,0),
    CartesianIndex(-1,1),
    CartesianIndex(0,-1),
    CartesianIndex(0,1),
    CartesianIndex(1,-1),
    CartesianIndex(1,0),
    CartesianIndex(1,1),
]
emptyseat(v) = v == codes['L']
occupiedseat(v) = v == codes['#']
isseat(v) = emptyseat(v) || occupiedseat(v)
function find_seat(c, d, grid)
    rows, cols = size(grid)
    cur = c + d
    while !ismissing(check_cartesian(cur, rows, cols)) && !isseat(grid[cur])
        cur += d
    end
    check_cartesian(cur, rows, cols)
end
function get_neighbours(c, grid)
    [find_seat(c, d, grid) for d ∈ directions]
end
function compute_neighbours(grid::AbstractMatrix{Int})
    rows, cols = size(grid)
    neigh = Array{Union{Missing,CartesianIndex{2}}}(undef, 8, rows, cols)
    for c ∈ CartesianIndices(grid)
        neigh[:, c] .= get_neighbours(c, grid)
    end
    neigh
end
function rules(v, ns)
    emptyseat(v) && return count(==(codes['#']), ns) == 0 ? codes['#'] : v
    occupiedseat(v) && return count(==(codes['#']), ns) >= 5 ? codes['L'] : v
    return v
end
flip((x,y)) = (y,x)
flip(c::CartesianIndex{2}) = CartesianIndex(flip(c.I))
function update_cells!(grid, old, neighbours, rules)
    copy!(old, grid)
    for c ∈ CartesianIndices(grid)
        ns = [old[n] for n ∈ skipmissing(view(neighbours, :, c))]
        grid[c] = rules(old[c], ns)
    end
end
function show_grid(grid)
    invcodes = ['.', 'L', '#']
    rows, cols = size(grid)
    for j ∈ 1:cols
        for i ∈ 1:rows
            print(invcodes[grid[i, j]])
        end
        print('\n')
    end
end

##
seats = reduce(hcat, map(eachline("input.txt")) do line
    map(c -> codes[c], collect(line))
end);
neighbours = compute_neighbours(seats);

##
grid = copy(seats)
old = fill!(similar(grid), 0);

##
while grid != old
    update_cells!(grid, old, neighbours, rules)
end

##
count(==(codes['#']), grid)
