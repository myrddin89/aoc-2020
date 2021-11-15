## PARTE 2
cd(@__DIR__())
using DataStructures: Queue, enqueue!, nil, cons, list, Cons
maskrx = r"mask = (.*)"
memrx = r"mem\[([0-9]+)\] = ([0-9]+)"
function parse_mask_v2(address::T, s::AbstractString) where {T<:Unsigned}
    b1 = one(T)
    n = length(s)
    address′ = foldl(1:n; init=address) do a, i
        s[n-i+1] == '1' || return a
        a | b1 << (i - 1)
    end
    foldl(1:n; init=list(address′)) do addrs, i
        s[n-i+1] == 'X' || return addrs
        foldl(addrs; init=nil(T)) do xs, x
            mask = b1 << (i - 1)
            y = x | mask
            z = x & ~mask
            cons(z, cons(y, xs))
        end
    end
end
function parse_mem(::Type{T}, address, value) where {T<:Unsigned}
    parse(T, address) => parse(T, value)
end
function set_mem!(tape::Dict, mem, mask)
    isnothing(mem) && return
    address, value = mem
    addrs = parse_mask_v2(address, mask)
    foreach(addrs) do a
        tape[a] = value
    end
end
function run_program_v2(input, ::Type{T} = UInt64) where {T<:Unsigned}
    tape = Dict{T,Int}()
    mem = nothing
    mask = nothing
    foreach(eachline(input)) do line
        if (m = match(maskrx, line); !isnothing(m))
            mask = m[1]
        elseif (m = match(memrx, line); !isnothing(m))
            mem = parse_mem(T, m[1], m[2])
            set_mem!(tape, mem, mask)
        end
    end
    sum(values(tape))
end

##
@show run_program_v2("input.txt", UInt64);
