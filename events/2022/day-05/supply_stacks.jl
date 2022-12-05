#%%
cd(@__DIR__)
using DataStructures

#%%
stack_lines, move_lines, ns = reduce(eachline("input.txt"), init=(String[], String[], String)) do (stacks, moves, ns), line
    isempty(line) && return stacks, moves, ns
    '[' in line && return vcat(stacks, [line]), moves, ns
    line[1] == 'm' && return stacks, vcat(moves, [line]), ns
    stacks, moves, line
end
nstacks = parse(Int, last(split(ns)))
stacks0 = ntuple(_ -> Stack{Char}(), nstacks)
stacks = reduce(reverse(stack_lines), init=stacks0) do stacks, line
    foreach(findall('[', line)) do i
        push!(stacks[ns[i+1]-'0'], line[i+1])
    end
    stacks
end
map(first, reduce(move_lines, init=stacks) do stacks, line
    n, from, to = parse.(Int, split(line)[[2,4,6]])
    foreach(_ -> push!(stacks[to], pop!(stacks[from])), 1:n)
    stacks
end) |> join

#%% PART TWO
stack_lines, move_lines, ns = reduce(eachline("input.txt"), init=(String[], String[], String)) do (stacks, moves, ns), line
    isempty(line) && return stacks, moves, ns
    '[' in line && return vcat(stacks, [line]), moves, ns
    line[1] == 'm' && return stacks, vcat(moves, [line]), ns
    stacks, moves, line
end
nstacks = parse(Int, last(split(ns)))
stacks = reduce(reverse(stack_lines), init=ntuple(_ -> Deque{Char}(), nstacks)) do stacks, line
    foreach(findall('[', line)) do i
        pushfirst!(stacks[ns[i+1]-'0'], line[i+1])
    end
    stacks
end
map(first, reduce(move_lines, init=stacks) do stacks, line
    n, from, to = parse.(Int, split(line)[[2,4,6]])
    tmp = Deque{Char}()
    foreach(_ -> push!(tmp, popfirst!(stacks[from])), 1:n)
    foreach(_ -> pushfirst!(stacks[to], pop!(tmp)), 1:n)
    stacks
end) |> join


#%% IMMUTABLE LIST VERSION
map(first, reduce(move_lines, init=[list(d...) for d in stacks]) do stacks, line
    n, from, to = parse.(Int, split(line)[[2,4,6]])
    tmp = nil(Char)
    foreach(1:n) do _
        x, t = head(stacks[from]), tail(stacks[from])
        if !isempty(t)
            stacks[from] = t
        end
        tmp = cons(x, tmp)
    end
    isempty(tmp) && return stacks
    stacks[to] = cat(reverse(tmp), stacks[to])
    stacks
end) |> join
