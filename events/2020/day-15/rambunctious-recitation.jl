## PARTE 1
cd(@__DIR__)
function play_game(input, stop)
    turns = zeros(Int, stop)
    turns[1:length(input)] .= input
    foreach(length(input)+1:stop) do i
        j = findprev(==(turns[i-1]), turns, i-2)
        isnothing(j) && return
        turns[i] = i - j - 1
    end
    turns
end

##
n = 200000
#input = [18, 11, 9, 0, 5, 1]
input = [0, 3, 6]
@time turns = play_game(input, n)
n => last(turns)
