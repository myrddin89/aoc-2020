##
cd(@__DIR__())
rot(ϕ) = Complex{Int}(round(Int,cos(deg2rad(ϕ))), round(Int,sin(deg2rad(ϕ))))
moves = Dict(
    'N' => α -> c -> begin (p,d) = c; (p + Complex{Int}(0,α), d) end,
    'S' => α -> c -> begin (p,d) = c; (p + Complex{Int}(0,-α), d) end,
    'E' => α -> c -> begin (p,d) = c; (p + Complex{Int}(α,0), d) end,
    'W' => α -> c -> begin (p,d) = c; (p + Complex{Int}(-α,0), d) end,
    'L' => ϕ -> c -> begin (p,d) = c; (p, d * rot(ϕ)) end,
    'R' => ϕ -> c -> begin (p,d) = c; (p, d * rot(-ϕ)) end,
    'F' => s -> c -> begin (p,d) = c; (p + s * d, d) end,
)
dist(p::Complex) = reim(p) .|> abs |> sum
dist(t::Tuple) = dist(first(t))
dist(t1::Tuple, t2::Tuple) = dist(t2[1] - t1[1]);

##
actions = map(eachline("test.txt")) do line
    moves[line[1]](parse(Int, line[2:end]))
end;

##
start = Complex{Int}(0,0), Complex{Int}(1,0)
finish = foldl(actions; init = start) do c, a
    a(c)
end
@show finish
dist(start, finish)

## PARTE 2
moves = Dict(
    'N' => α -> c -> begin (p,d) = c; (p, d + Complex{Int}(0,α)) end,
    'S' => α -> c -> begin (p,d) = c; (p, d + Complex{Int}(0,-α)) end,
    'E' => α -> c -> begin (p,d) = c; (p, d + Complex{Int}(α,0)) end,
    'W' => α -> c -> begin (p,d) = c; (p, d + Complex{Int}(-α,0)) end,
    'L' => ϕ -> c -> begin (p,d) = c; (p, d * rot(ϕ)) end,
    'R' => ϕ -> c -> begin (p,d) = c; (p, d * rot(-ϕ)) end,
    'F' => s -> c -> begin
        (p,d) = c
        (p + s * d, d)
    end,
)
actions = map(eachline("input.txt")) do line
    moves[line[1]](parse(Int, line[2:end]))
end;

##
start = Complex{Int}(0,0), Complex{Int}(10,1)
finish = foldl(actions; init = start) do c, a
    a(c)
end
@show finish
dist(start, finish)
