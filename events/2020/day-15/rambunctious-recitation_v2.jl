## PARTE 2
cd(@__DIR__)
using OrderedCollections: OrderedDict
function play_game(input, stop)
    spoken = OrderedDict{Int,Pair{Int,Int}}()
    foreach(pairs(IndexLinear(), input)) do (i, x)
        spoken[x] = i => 0
    end
    prev = last(input) => length(input) => 0
    foreach(length(input)+1:stop) do turn
        key, (t, Δ) = prev
        t′, _ = get(spoken, Δ, turn => 0)
        prev = Δ => turn => turn - t′
        spoken[prev.first] = prev.second
    end
    return prev
end

##
n = 30000000
input = [18, 11, 9, 0, 5, 1]
#input = [0,3,6]
@time turn = play_game(input, n)
