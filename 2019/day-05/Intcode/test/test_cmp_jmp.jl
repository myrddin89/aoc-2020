include("test_data.jl")

function test_cmp(io::Union{Nothing,IO} = nothing)
    map(TestData.test_cmp_data) do x
        ic = IntcodeMachine(x)
        run_intcode!(ic)
        res = fetch(ic)
        isnothing(res) && return @error "Intcode failed CMP '$x'"
        @info something(res)
        !isnothing(io) && flush(io)
    end
end

function test_jmp(io::Union{Nothing,IO} = nothing)
    map(TestData.test_jmp_data) do x
        ic = IntcodeMachine(x)
        run_intcode!(ic)
        res = fetch(ic)
        isnothing(res) && return @error "Intcode failed CMP '$x'"
        @info something(res)
        !isnothing(io) && flush(io)
    end
end

function test_larger(io::Union{Nothing,IO} = nothing)
    map(TestData.test_larger_data) do x
        ic = IntcodeMachine(x)
        run_intcode!(ic)
        res = fetch(ic)
        isnothing(res) && return @error "Intcode failed CMP '$x'"
        @info something(res)
        !isnothing(io) && flush(io)
    end
end
