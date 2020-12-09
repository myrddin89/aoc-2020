##
using DelimitedFiles
input_path = joinpath(@__DIR__(), "input.txt")
flip(x, y) = (y, x)
flip((x,y)) = (y, x)
flip(c::CartesianIndex) = CartesianIndex(flip(c.I))

##
input_data = readdlm(input_path,',',String)
encode_move(::Val{'U'}) = 0x00
encode_move(::Val{'D'}) = 0x11
encode_move(::Val{'R'}) = 0x01
encode_move(::Val{'L'}) = 0x10
data = map(input_data) do v
    k = encode_move(Val(v[1]))
    l = parse(Int, v[2:end])
    k, l
end |> permutedims
paths = [eachcol(data)...]

##
function decode_move(k, l)
    k == 0x00 && return CartesianIndex(0,l)
    k == 0x11 && return CartesianIndex(0,-l)
    k == 0x01 && return CartesianIndex(l,0)
    k == 0x10 && return CartesianIndex(-l,0)
    CartesianIndex(0,0)
end
decode_move(t::Tuple) = decode_move(t...)
function follow_path(paths::AbstractVector{<:AbstractVector{Tuple{UInt8,Int}}})
    map(paths) do mvs
        accumulate(mvs; init=CartesianIndex(0,0)) do cur, (k, l)
            cur + decode_move(k,l)
        end
    end
end
function intersections(paths::AbstractVector{<:AbstractVector{CartesianIndex{2}}})
    intersect(paths...)
end
dist(xs) = sum(abs,xs)
dist(c::CartesianIndex) = dist(c.I)

## TESTS
test_cases = (
    "R8,U5,L5,D3",
    "U7,R6,D4,L4",
    "R75,D30,R83,U83,L12,D49,R71,U7,L72,U62,R66,U55,R34,D71,R55,D58,R83",
    "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51,U98,R91,D20,R16,D67,R40,U7,R15,U6,R7",
)
res = map(test_cases) do x
    a = split(x,",")
    path = map(a) do v
        k = encode_move(Val(v[1]))
        l = parse(Int, v[2:end])
        k, l
    end
    follow_path([path])
end

##
test_dist = (
    "R8,U5,L5,D3",
    "U7,R6,D4,L4",
)
paths = map(test_dist) do x
    a = split(x,",")
    path = map(a) do v
        k = encode_move(Val(v[1]))
        l = parse(Int, v[2:end])
        k, l
    end
end
res = follow_path(paths|>collect)
display(res)

##
points = map(res) do ps
    prec = CartesianIndex(0,0)
    map(ps) do p
        x, y = p.I
        px, py = prec.I
        dx, dy = sign(x-px), sign(y-py)
        prec = p
        dx == 0 && return [CartesianIndex(px, j) for j in py+dy:dy:y]
        [CartesianIndex(j, py) for j in px+dx:dx:x]
    end
end
points = map(x -> reduce(vcat, x), points)
map(length, points)


##
res = follow_path(paths)
nothing

##
minimum(dist.(intersections(points)))

##
inters = intersections(points)

##
# steps2inters = map(points) do ps
#     findall(ps) do p
#         any(==(p), inters)
#     end
# end
steps2inters = map(inters) do i
    reduce(vcat, map(points) do ps
        findfirst(==(i), ps)
    end)
end

##
minimum(sum, steps2inters)
