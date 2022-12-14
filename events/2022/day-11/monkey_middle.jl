#%%
cd(@__DIR__)
using DataStructures
function _parse_monkey_n(line)
    i, j = findfirst(' ', line), findlast(':', line)
    parse(Int, line[i+1:j-1]) + 1
end
function _parse_items(::Type{T}, line) where T
    q = Queue{T}()
    i = findfirst(':', line)
    if !isnothing(i)
        foreach(x -> enqueue!(q, parse(Int, x)), split(line[i+1:end], ","))
    end
    q
end
_parse_items(line) = _parse_items(Int, line)
function _parse_op(line)
    i = findfirst(x -> x == '+' || x == '*', line)
    op = line[i] == '+' ? (+) : (*)
    arg = line[i+1:end] |> strip
    if arg == "old"
        x -> op(x, x)
    else
        n = parse(Int, arg)
        x -> op(x, oftype(x, n))
    end
end
function _parse_test(line)
    i = findlast(' ', line)
    parse(Int, line[i+1:end])
end
function _parse_branch(line)
    i = findlast(' ', line)
    parse(Int, line[i+1:end]) + 1
end
parse_funcs = (
    _parse_monkey_n,
    _parse_items,
    _parse_op,
    _parse_test,
    _parse_branch,
    _parse_branch,
)
function apply_op(op, x, d, t, f)
    y = op(x)
    y % d == 0 ? (y, t) : (y, f)
end

#%%
monkeys = map(Iterators.partition(Iterators.filter(!isempty, eachline("test.txt")), 6)) do blocks
    num, items, op, d, t, f = map((f,b) -> f(b), parse_funcs, blocks)
    (; num, items, test=x -> apply_op(op, x, d, t, f))
end
scores = zeros(Int, length(monkeys))
rounds = 1:20
for round in rounds
    for monkey in monkeys
        n = monkey.num
        while !isempty(monkey.items)
            scores[n] += 1
            item = dequeue!(monkey.items)
            item′, dest = monkey.test(item)
            if round == last(rounds)
                @info n, item, item′, dest
            end
            enqueue!(monkeys[dest].items, item′)
        end
    end
end
@info scores
sort(scores)[end-1:end] |> prod
