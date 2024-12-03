#%%
cd(@__DIR__)
input = read("input.txt", String)
#input = readchomp("test.txt")
#input = readchomp("test2.txt")

function mull(input)
    reg = r"(mul\([0-9]+,[0-9]+\))"
    mapreduce((+), eachmatch(reg, input)) do m
        res = replace(m.match, "mul" => "*")
        @eval $(Meta.parse(res))
    end
end

mull(input)

#%%
# function mull2f(input)
#     reg = r"mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)"
#     reduce(eachmatch(reg, input), init=(0, true)) do (result, enabled), m
#         m.match == "do()" && return (result, true)
#         m.match == "don't()" && return (result, false)
#         if enabled
#             return (result + *(parse.(Int, m.captures)...), enabled)
#         else
#             return (result, enabled)
#         end
#     end |> first
# end

function mull2f(input)
    reg = r"mul\([0-9]+,[0-9]+\)|do\(\)|don't\(\)"
    reduce(eachmatch(reg, input), init=(0, true)) do (result, enabled), m
        m.match == "do()" && return (result, true)
        m.match == "don't()" && return (result, false)
        if enabled
            mul = replace(m.match, "mul" => "*") |> Meta.parse |> eval
            return (result + mul, enabled)
        else
            return (result, enabled)
        end
    end |> first
end

function mull2(input)
    reg = r"mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)"
    enabled = true
    result = 0
    for m in eachmatch(reg, input)
        if startswith(m.match, "mul")
            if enabled
                xs = parse.(Int, m.captures)
                result += *(xs...)
            end
        elseif m.match == "do()"
            enabled = true
        elseif m.match == "don't()"
            enabled = false
        end
    end
    return result
end

mull2f(input)
