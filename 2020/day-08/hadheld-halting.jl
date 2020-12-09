##
cd(@__DIR__())
rx = r"([a-z][a-z][a-z]) ((\+|\-)([0-9]+))"
code = map(eachline("input.txt")) do line
    m = match(rx, line)
    String(m[1]), parse(Int,m[2])
end

mutable struct Handheld
    count::Int
    ip::Int
    running::Bool
end

Handheld() = Handheld(0, 1, false)
function start!(hh::Handheld)
    hh.count = 0
    hh.ip = 1
    hh.running = true
end
isrunning(hh::Handheld) = hh.running

function run_code!(hh::Handheld, code, jp::Int)
    start!(hh)
    visited = Set{Int}()
    inc = 1
    exited = false
    c, i = code[jp]
    if c == "jmp"
        code[jp] = ("nop", i)
    elseif c == "nop"
        code[jp] = ("jmp", i)
    end
    while isrunning(hh)
        if hh.ip < 1 || hh.ip > length(code)
            @error "ip out of bounds"
        end
        c, i = code[hh.ip]
        if hh.ip ∈ visited
            @info "Second run: $(hh.count)" hh
            break
        end
        push!(visited, hh.ip)
        if c == "acc"
            hh.count += i
            @debug "acc $i; ip = $(hh.ip); count = $(hh.count)"
        elseif c == "jmp"
            inc = i
            @debug "jmp $i; ip = $(hh.ip); count = $(hh.count)"
        elseif c == "nop"
            @debug "NOP $i; ip = $(hh.ip); count = $(hh.count)"
        else
            @error "Unknown instruction: $c; ip = $(hh.ip)"
            break
        end
        hh.ip += inc
        if hh.ip > length(code)
            hh.running = false
            @debug "should stop" hh
            if inc == 1
                exited = true
            end
        end
        inc = 1
    end
    @info "count is: $(hh.count)"
    return exited
end

##
ENV["JULIA_DEBUG"] = nothing

##
function find_error(hh::Handheld, code)
    jmps = findall(x->x[1]=="jmp", code)
    nops = findall(x->x[1]=="nop", code)
    e = false
    for j in jmps
        e = run_code!(hh, copy(code), j)
        if e
            @info "Found error; count = $(hh.count)" hh
            break
        end
    end
    e && return
    for n in nops
        e = run_code!(hh, copy(code), n)
        if e
            @info "Found error; count = $(hh.count)" hh
            break
        end
    end
end

##
hh = Handheld()
find_error(hh, code)

## PARTE 2
