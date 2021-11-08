##
cd(@__DIR__())
function parse_mask(s, ::Type{T} = UInt64) where {T<:Unsigned}
    mask0 = zero(T)
    bit1 = one(T)
    map(enumerate(reverse(s))) do (i, c)
        c == '0' && return Base.Fix2(&, ~((mask0 | bit1) << (i-1)))
        c == '1' && return Base.Fix2(|, (mask0 | bit1) << (i-1))
        return missing
    end |> skipmissing |> collect
end
maskrx = r"mask = (.*)"
memrx = r"mem\[([0-9]+)\] = ([0-9]+)"
ismask(t) = t[1] === :mask
ismem(t) = t[1] === :mem
function run_program(prog)
    space = extrema(t->t[2], Iterators.filter(ismem, prog))
    mem = zeros(Int, space)
    mask = nothing
    foreach(prog) do cmd
        if ismask(cmd)
            mask = cmd[2]
            return
        end
        if ismem(cmd)
            mem[cmd[2]] = foldl(mask; init = cmd[3]) do v, op2
                op2(v)
            end
            return
        end
    end
    sum(mem)
end

##
prog = map(eachline("input.txt")) do line
    m = match(maskrx, line)
    if !isnothing(m)
        return :mask, parse_mask(m[1])
    end
    m = match(memrx, line)
    if !isnothing(m)
        return :mem, parse(Int, m[1]), parse(Int, m[2])
    end
    return nothing
end;

##
run_program(prog)

## PARTE 2
