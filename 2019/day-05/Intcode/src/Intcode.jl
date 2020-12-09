module Intcode

Base.Experimental.@optlevel 3

export IntcodeMachine
export run_intcode!, reset!
export set!

import Base: show, fetch, length

const AbstractTape = AbstractVector{<:Integer}

abstract type AbstractMode end
struct PositionMode <: AbstractMode end
struct ImmediateMode <: AbstractMode end

const _m_position = PositionMode()
const _m_immediate = ImmediateMode()

show(io::IO, ::ImmediateMode) = print(io, "MI")
show(io::IO, ::PositionMode) = print(io, "MP")

abstract type AbstractOp end
struct Add <: AbstractOp end; length(::Add) = 4
struct Mul <: AbstractOp end; length(::Mul) = 4
struct Input <: AbstractOp end; length(::Input) = 2
struct Output <: AbstractOp end; length(::Output) = 2
struct JumpTrue <: AbstractOp end; length(::JumpTrue) = 3
struct JumpFalse <: AbstractOp end; length(::JumpFalse) = 3
struct Less <: AbstractOp end; length(::Less) = 4
struct Equals <: AbstractOp end; length(::Equals) = 4
struct Halt <: AbstractOp end; length(::Halt) = 1

struct JumpValue
    value::Int
end

show(io::IO, jp::JumpValue) = print(io, "Jump($(jp.value))")

const _op_add = Add()
const _op_mul = Mul()
const _op_in = Input()
const _op_out = Output()
const _op_jpt = JumpTrue()
const _op_jpf = JumpFalse()
const _op_ls = Less()
const _op_eq = Equals()
const _op_halt = Halt()

const _opcode_map = Dict(
    [1,0] => _op_add,
    [2,0] => _op_mul,
    [3,0] => _op_in,
    [4,0] => _op_out,
    [5,0] => _op_jpt,
    [6,0] => _op_jpf,
    [7,0] => _op_ls,
    [8,0] => _op_eq,
    [9,9] => _op_halt,
)

show(io::IO, ::Add) = print(io, "A")
show(io::IO, ::Mul) = print(io, "M")
show(io::IO, ::Input) = print(io, "I")
show(io::IO, ::Output) = print(io, "O")
show(io::IO, ::JumpTrue) = print(io, "JT")
show(io::IO, ::JumpFalse) = print(io, "JF")
show(io::IO, ::Less) = print(io, "LS")
show(io::IO, ::Equals) = print(io, "EQ")
show(io::IO, ::Halt) = print(io, "H")

struct IntcodeInstruction{
    M1 <: AbstractMode,
    M2 <: AbstractMode,
    M3 <: AbstractMode,
    Opcode <: AbstractOp,
    Tape <: AbstractTape,
}
    mode::Tuple{M1,M2,M3}
    opcode::Opcode
    data::Tape
end

show(io::IO, i::IntcodeInstruction) = print(io, "<$(i.opcode)$(i.mode): $(i.data)>")
length(i::IntcodeInstruction) = length(i.opcode)

abstract type AbstractState end
struct Running <: AbstractState end
struct Idle <: AbstractState end
struct Halted <: AbstractState end

show(io::IO, ::Running) = print(io, "RUNNING")
show(io::IO, ::Idle) = print(io, "IDLE")
show(io::IO, ::Halted) = print(io, "HALTED")

const _s_run = Running()
const _s_idle = Idle()
const _s_halt = Halted()

mutable struct IntcodeMachine{Tape <: AbstractTape}
    state::Union{Nothing,<:AbstractState}
    pc::Int
    tape::Tape
    init::Tape
    IntcodeMachine(tape::Tape) where {Tape <: AbstractTape} =
        new{Tape}(_s_idle, 0, copy(tape), copy(tape))
end

show(io::IO, ic::IntcodeMachine) = print(io, "Intcode ($(ic.state)): pc=$(ic.pc)")


@inline function opcode(ds::AbstractTape)::Union{Nothing,<:AbstractOp}
    1 <= length(ds) <= 2 || return nothing
    op = [0,0]
    r = 1:length(ds)
    op[r] .= ds
    res = get(_opcode_map, op, nothing)
    if isnothing(res)
        @debug "Opcode '$ds' unknown"
        return nothing
    end
    return res
end

@inline function modes(d::Int)::Union{Nothing,<:AbstractMode}
    d == 0 && return _m_position
    d == 1 && return _m_immediate
    @debug "Mode '$d' unknown"
    return nothing
end

@noinline function modes(ds::AbstractTape)::Union{Nothing,Tuple{<:AbstractMode,<:AbstractMode,<:AbstractMode}}
    cs = [0,0,0]
    cs[1:length(ds)] .= ds
    ms = modes.(cs)
    any(isnothing, ms) && return nothing
    tuple(ms...)
end

@inline function _opmode(ds::AbstractTape)
    op = opcode(view(ds, 1:min(2, length(ds))))
    isnothing(op) && return nothing
    ms = modes(view(ds, 3:length(ds)))
    isnothing(ms) && return nothing
    (ms, op)
end

function opmode(tape::AbstractTape)
    _opmode(digits(tape[1]))
end

@inline function data_seg(op::AbstractOp, tape::AbstractTape)::Union{Nothing,<:AbstractTape}
    length(op) == 1 && return Int[]
    length(op) == 2 && return view(tape, 2:2)
    length(op) == 3 && return view(tape, 2:3)
    length(op) == 4 && return view(tape, 2:4)
    nothing
end

@inline function decode(tape::AbstractTape)::Union{Nothing,IntcodeInstruction}
    decodes = opmode(tape)
    isnothing(decodes) && return nothing
    ms, op = decodes
    data = data_seg(op, tape)
    isnothing(data) && return nothing
    IntcodeInstruction(ms, op, data)
end

function (i::IntcodeInstruction)(tape::AbstractTape)::Union{Nothing,Some{<:Any}}
    i.opcode(tape, i.mode, i.data)
end

function fetch_data(tape::AbstractTape, ::PositionMode, addr::Integer)
    tape[addr + 1]
end

function fetch_data(::AbstractTape, ::ImmediateMode, data::Integer)
    data
end

function set_data!(tape::AbstractTape, addr::Integer, v::Integer)
    tape[addr + 1] = v
end

@inline function (op::Add)(
    tape::AbstractTape,
    mode::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    x = fetch_data(tape, mode[1], data[1])
    y = fetch_data(tape, mode[2], data[2])
    res = x + y
    set_data!(tape, data[3], res) |> Some
end

@inline function (op::Mul)(
    tape::AbstractTape,
    mode::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    x = fetch_data(tape, mode[1], data[1])
    y = fetch_data(tape, mode[2], data[2])
    res = x * y
    set_data!(tape, data[3], res) |> Some
end

function (op::Input)(
    tape::AbstractTape,
    ::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    input = nothing
    try
        input = parse(Int, readline())
    catch
        @error "Cannot parse input as Int: $input"
        return nothing
    end
    isnothing(input) && return nothing
    set_data!(tape, data[1], input) |> Some
end

function (op::Output)(
    tape::AbstractTape,
    mode::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    val = fetch_data(tape, mode[1], data[1])
    println(val)
    Some(val)
end

function (op::JumpTrue)(
    tape::AbstractTape,
    mode::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    fetch_data(tape, mode[1], data[1]) != 0 || return Some(nothing)
    fetch_data(tape, mode[2], data[2]) + 1 |> JumpValue |> Some
end

function (op::JumpFalse)(
    tape::AbstractTape,
    mode::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    fetch_data(tape, mode[1], data[1]) == 0 || return Some(nothing)
    fetch_data(tape, mode[2], data[2]) + 1 |> JumpValue |> Some
end

function (op::Less)(
    tape::AbstractTape,
    mode::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    x = fetch_data(tape, mode[1], data[1])
    y = fetch_data(tape, mode[2], data[2])
    set_data!(tape, data[3], x < y) |> Some
end

function (op::Equals)(
    tape::AbstractTape,
    mode::Tuple{M1,M2,M3},
    data::AbstractTape,
) where {M1 <: AbstractMode,M2 <: AbstractMode,M3 <: AbstractMode,}
    x = fetch_data(tape, mode[1], data[1])
    y = fetch_data(tape, mode[2], data[2])
    set_data!(tape, data[3], x == y) |> Some
end

function fetch_intcode!(ic::IntcodeMachine)::Union{Nothing,IntcodeInstruction}
    i = decode(view(ic.tape, ic.pc:length(ic.tape)))
    if isnothing(i)
        ic.state = nothing
        return nothing
    else
        return i
    end
end

should_halt(::Halt) = true
should_halt(::AbstractOp) = false
should_halt(i::IntcodeInstruction) = should_halt(i.opcode)
should_jump(res::Some{<:Any}) = something(res) isa JumpValue
should_jump(::Nothing) = false

function halt!(ic::IntcodeMachine)
    ic.state = _s_halt
    return Some(_s_halt)
end

function jump!(ic::IntcodeMachine, jp::JumpValue)
    ic.pc = jp.value
end

function exec!(ic::IntcodeMachine, i::IntcodeInstruction)::Union{Nothing,Some{<:Any}}
    should_halt(i) && return halt!(ic)
    res = i(ic.tape)
    if isnothing(res)
        ic.state = nothing
    elseif should_jump(res)
        jump!(ic, something(res))
    end
    return res
end

function increment!(ic::IntcodeMachine, i::IntcodeInstruction)
    if ic.pc > length(ic.tape)
        if ic.debug; debug_failure(ic, "pc past code") end
        return false
    end
    ic.pc += length(i)
    return true
end

isrunning(ic::IntcodeMachine) = ic.state === _s_run
issuccess(ic::IntcodeMachine) = !isnothing(ic.state)
isidle(ic::IntcodeMachine) = ic.state === _s_idle

function reset!(ic::IntcodeMachine)
    ic.state = _s_idle
    ic.pc = 0
    ic.tape = copy(ic.init)
end

function start!(ic::IntcodeMachine)
    if !isidle(ic)
        debug_failure(ic, "Intcode is not ready, please reset")
        return false
    end
    ic.state = _s_run
    ic.pc = 1
    return true
end

function run_intcode!(ic::IntcodeMachine)::Union{Nothing,Some{<:AbstractState}}
    start!(ic) || return nothing
    while isrunning(ic)
        i = fetch_intcode!(ic)
        issuccess(ic) || return debug_failure(ic, i)
        res = exec!(ic, i)
        issuccess(ic) || return debug_failure(ic, i, res)
        debug_info(ic, i, res)
        should_jump(res) || increment!(ic, i) || return debug_failure(ic, i, res)
    end
    issuccess(ic) || return nothing
    Some(ic.state)
end

function set!(ic::IntcodeMachine, noun::Integer, verb::Integer)
    ic.tape[2] = noun
    ic.tape[3] = verb
end

function fetch(ic::IntcodeMachine)::Union{Nothing,Some{<:Integer}}
    issuccess(ic) || return nothing
    ic.tape |> first |> Some
end

@inline function debug_info(
    ic::IntcodeMachine,
    i::Union{Nothing,AbstractOp,IntcodeInstruction},
    res
)
    @debug "$ic; i=$i; res=$res"
end

@inline function debug_failure(
    ic::IntcodeMachine,
    i::Union{Nothing,AbstractOp,IntcodeInstruction},
    res
)
    @debug "[FAILED] $ic; i=$i; res=$res"
end

@inline function debug_failure(
    ic::IntcodeMachine,
    i::Union{Nothing,AbstractOp,IntcodeInstruction}
)
    @debug "[FAILED] $ic; i=$i"
end

@inline function debug_failure(ic::IntcodeMachine, msg::AbstractString)
    @error "[FAILED] $msg" ic
end

end # module
