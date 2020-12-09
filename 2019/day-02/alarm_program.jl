##
path = @__DIR__()
using DelimitedFiles

##
mutable struct IntCode
    debug::Bool
    state::Union{Int,Nothing}
    pc::Int
    tape::Vector{Int}
    IntCode(tape::Vector{Int}; debug = false) = new(debug, 0, 0, copy(tape))
end
function debug_info(ic::IntCode, i::Int, res)
    println("IntCode ($(ic.state)): pc=$(ic.pc); i=$i; res=$res")
end
function debug_failure(ic::IntCode, i::Int, res)
    println("IntCode ($(ic.state)) FAILED: pc=$(ic.pc); i=$i; res=$res")
end
function debug_failure(ic::IntCode, msg::AbstractString)
    println("IntCode ($(ic.state)) FAILED: pc=$(ic.pc) -- $msg")
end

function add(ic::IntCode)
    address1 = ic.tape[ic.pc+2]+1
    address2 = ic.tape[ic.pc+3]+1
    address3 = ic.tape[ic.pc+4]+1
    x = ic.tape[address1]
    y = ic.tape[address2]
    res = x + y
    ic.tape[address3] = res
    if ic.debug
        println("IntCode ($(ic.state)) opcode[$(ic.pc+1)]: (1, $address1, $address2, $address3)")
    end
    res
end
function mul(ic::IntCode)
    address1 = ic.tape[ic.pc+2]+1
    address2 = ic.tape[ic.pc+3]+1
    address3 = ic.tape[ic.pc+4]+1
    x = ic.tape[address1]
    y = ic.tape[address2]
    res = x * y
    ic.tape[address3] = res
    if ic.debug
        println("IntCode ($(ic.state)) opcode[$(ic.pc+1)]: (2, $address1, $address2, $address3)")
    end
    res
end
function stop(ic::IntCode)
    if ic.debug
        println("IntCode ($(ic.state)) opcode[$(ic.pc+1)]: (99, -, -, -)")
    end
    ic.state = -1
end
function fail(ic::IntCode)
    opcode = ic.tape[ic.pc+1]
    if ic.debug
        println("IntCode ($(ic.state)) opcode[$(ic.pc+1)]: ($opcode, -, -, -)")
    end
    ic.state = nothing
end

function (ic::IntCode)()
    i = ic.tape[ic.pc+1]
    res = ic(i)
    i, res
end
function (ic::IntCode)(i::Int)
    i == 1 && return add(ic)
    i == 2 && return mul(ic)
    i == 99 && return stop(ic)
    fail(ic)
end

function increment(ic::IntCode)
    if ic.pc >= length(ic.tape)
        ic.state = nothing
        if ic.debug; debug_failure(ic, "pc past code") end
    end
    ic.pc += 4
end

isrunning(ic::IntCode) = !isnothing(ic.state) && ic.state != -1
issuccess(ic::IntCode) = !isnothing(ic.state)

function evaluate_intcode(ic::IntCode)::Union{Nothing,Some{Vector{Int}}}
    while isrunning(ic)
        i, res = ic()
        if ic.debug; debug_info(ic, i, res) end
        if !issuccess(ic); debug_failure(ic, i, res) end
        increment(ic)
    end
    !issuccess(ic) && return nothing
    Some(ic.tape)
end

function set_input(ic::IntCode, noun::Int, verb::Int)
    ic.tape[2] = noun
    ic.tape[3] = verb
end

function get_output(ic::IntCode)
    ic.tape |> first
end



##
test_cases = (
    ([1,0,0,0,99],                    [2,0,0,0,99]),
    ([2,3,0,3,99],                    [2,3,0,6,99]),
    ([2,4,4,5,99,0],                  [2,4,4,5,99,9801]),
    ([1,1,1,4,99,5,6,0,99],           [30,1,1,4,2,5,6,0,99]),
    ([1,9,10,3,2,3,11,0,99,30,40,50], [3500,9,10,70,2,3,11,0,99,30,40,50]),
)
function test_intcode(tests)
    println("Run test for IntCode")
    res = all(
        map(tests) do (i,o)
            ic = IntCode(i; debug=true)
            println("\nTesting $i => $o...")
            evaluate_intcode(ic)
            res = ic.tape == o
            if res
                println("PASSED")
            else
                println("FAILED: $(ic.tape)")
            end
            res
        end
    )
    if res
        println("\nAll tests PASSED!")
    else
        println("\nTest FAILED")
    end
end

##
test_intcode(test_cases)

##
init_data = readdlm(joinpath(path, "input.txt"), ',', Int) |> vec;

##
noun = 12
verb = 2
output = 19690720
println("noun=$noun; verb=$verb; res=$(100noun+verb)")
data = copy(init_data)
data[2] = noun
data[3] = verb
ic = IntCode(data)
evaluate_intcode(ic)
println("IntCode result: $(first(ic.tape))")

##
function find_noun_verb(init_data::Vector{Int}, output::Int)
    nouns = 0:99
    verbs = 0:99
    found = nothing
    for noun in nouns, verb in verbs
        ic = IntCode(init_data)
        set_input(ic, noun, verb)
        evaluate_intcode(ic)
        if get_output(ic) == output
            found = Some(100noun + verb)
            break
        end
    end
    return found
end


##
res = find_noun_verb(init_data, output)
if isnothing(res)
    println("Found nothing")
else
    println("Found: $res")
end
