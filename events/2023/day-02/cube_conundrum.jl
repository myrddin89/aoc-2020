#%%
cd(@__DIR__)

parse_id(line) = parse(Int, match(r"Game (?<id>[0-9]+)", line)["id"])

function parse_run(line)
    matches = eachmatch(r"(?<num>[0-9]+) (?<color>[a-z]+)", line)
    [(num=parse(Int, m["num"]), color=m["color"]) for m in matches]
end

function parse_game(line::AbstractString)
    parts = split(line, r":|;", keepempty=false)
    parse_id(parts[1]), parse_run.(parts[begin+1:end])
end

configuration = Dict("red" => 12, "green" => 13, "blue" => 14)

parsed_games = map(parse_game, eachline("input.txt"))

function isgamepossible(game)
    _, runs = game
    all(runs) do draws
        all(draws) do r
            r.num <= get(configuration, r.color, 0)
        end
    end
end

getid(game) = first(game)
sum(getid, filter(isgamepossible, parsed_games))

#%%
function minconfig(game)
    _, runs = game
    config = Dict{String,Int}()
    foreach(runs) do draws
        foreach(draws) do r
            config[r.color] = max(r.num, get(config, r.color, 0))
        end
    end
    config
end

cube_power(cubes) = prod(r -> r.second, cubes)

sum(cube_power ∘ minconfig, parsed_games)
