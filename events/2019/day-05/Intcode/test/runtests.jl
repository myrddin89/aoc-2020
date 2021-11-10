ENV["JULIA_DEBUG"] = "Intcode"
using Intcode, Test, Logging

include("test_data.jl")

@testset "Run test for Intcode" begin
    res = all(
        map(TestData.test_cases_data) do (i,o)
            ic = IntcodeMachine(i)
            @info "\nTesting $i => $o..."
            run_intcode!(ic)
            res = ic.tape == o
            if res
                @info "PASSED"
            else
                @error "[FAILED] $ic" ic.tape
            end
            res
        end
    )
    @test res
end
