#%%
cd(@__DIR__)
using DelimitedFiles
input = readdlm("input.txt", ' ', String) .|> Symbol
rock, paper, scissors = 1, 2, 3
enc = (A=rock, B=paper, C=scissors, X=rock, Y=paper, Z=scissors)
wins(x, y) = (x == y ? 3 : (x-y in (-1,2) ? 6 : 0)) + y
map(eachrow(input)) do (x, y)
    wins(enc[x], enc[y])
end |> sum

#%% SECOND PART
map(eachrow(input)) do (x, y)
    x = enc[x]
    if y == :X
        x == rock && return wins(x, scissors)
        x == paper && return wins(x, rock)
        x == scissors && return wins(x, paper)
    elseif y == :Y
        wins(x, x)
    else
        x == rock && return wins(x, paper)
        x == paper && return wins(x, scissors)
        x == scissors && return wins(x, rock)
    end
end |> sum
