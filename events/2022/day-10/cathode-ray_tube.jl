#%%
cd(@__DIR__)
instruction(x, arg) = string(x) => parse(Int, arg)
instruction(x) = string(x) => nothing
T = Pair{String,Union{Int,Nothing}}
spl(line)::T = instruction(split(line)...)
program = map(spl, eachline("input.txt"))

#%% PROCEDURAL
function _procedural()
    cycle = 1
    pc = 1
    X = 1
    s = 0
    cycles = 20:40:220
    ncyc = 0
    while pc <= length(program)
        name, arg = program[pc]
        if name == "noop"
            pc += 1
        elseif name == "addx"
            if ncyc == 1
                X += arg
                ncyc = 0
                pc += 1
            else
                ncyc += 1
            end
        else
            continue
        end
        cycle += 1
        if cycle in cycles
            s += cycle * X
        end
        if cycle == last(cycles)
            break
        end
    end
    s
end
@time _procedural()

#%% FUNCTIONAL
noop(X, pc, ncyc) = X, pc+1, false
function addx(arg, X, pc, ncyc)
    ncyc && return X + arg, pc+1, false
    X, pc, true
end
function compute_cycle(name, arg, state)
    name == "noop" && return noop(state...)
    name == "addx" && return addx(arg, state...)
end
function _functional()
    reduce(20:40:220; init=(0, 1, 1, 1, false)) do (s, X, cycle, pc, ncyc), nc
        X, X′, pc, ncyc = reduce(cycle:nc; init=(X, X, pc, ncyc)) do (X, X′, pc, ncyc), c
            pc > length(program) && return X′, X, pc, ncyc
            name, arg = program[pc]
            X, pc′, ncyc = compute_cycle(name, arg, (X′, pc, ncyc))
            X′, X, pc′, ncyc
        end
        s+nc*X, X′, nc+1, pc, ncyc
    end
end
@time _functional() |> first

#%% PART TWO
function _procedural2()
    cycle = 1
    pc = 1
    X = 1
    ncyc = 0
    crt = fill('.', 40, 6)
    crt_inds = CartesianIndices(crt)
    crt_pos = 1
    while pc <= length(program)
        name, arg = program[pc]
        if name == "noop"
            c = crt_inds[crt_pos]
            if c.I[1] in X:X+2
                crt[c] = '#'
            end
            pc += 1
        elseif name == "addx"
            c = crt_inds[crt_pos]
            if c.I[1] in X:X+2
                crt[c] = '#'
            end
            if ncyc == 1
                X += arg
                ncyc = 0
                pc += 1
            else
                ncyc += 1
            end
        else
            continue
        end
        cycle += 1
        crt_pos += 1
    end
    for j in axes(crt, 2)
        for i in axes(crt, 1)
            print(crt[i, j])
        end
        println()
    end
end
@time _procedural2()
