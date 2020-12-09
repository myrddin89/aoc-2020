##
using DelimitedFiles, Logging, Pkg, Test
cd(@__DIR__())
pkg"activate ./Intcode"
using Intcode
logfile = "intcode.log"
function do_with_logger(f::Function, level = Logging.Info, logfile=logfile)
    open(logfile, "w+") do io
        with_logger(ConsoleLogger(io, level)) do
            f(io)
        end
        flush(io)
    end
end

##
try
    pkg"test Intcode"
catch e
    @error e
end

##
init_data = readdlm("input.txt", ',', Int) |> vec;

##
do_with_logger() do io
    ic = IntcodeMachine(init_data)
    run_intcode!(ic)
    res = fetch(ic)
    isnothing(res) && @error "TEST program failed"
    @info something(res)
    !isnothing(io) && flush(io)
end

##
include(joinpath("Intcode", "test", "test_cmp_jmp.jl"))

##
do_with_logger(test_cmp, Logging.Debug)

##
do_with_logger(test_jmp, Logging.Debug)

##
do_with_logger(test_larger, Logging.Debug)
