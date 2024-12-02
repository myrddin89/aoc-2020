#%%
cd(@__DIR__)
using DelimitedFiles
# input_file = "test.txt"
input_file = "input.txt"
input = map(eachline(input_file)) do line
    parse.(Int, split(line, " "))
end

#%%
function issafe_report(report)
    Δ = diff(report)
    maximum(abs.(Δ)) <= 3 && (all(x -> sign(x) == 1, Δ) || all(x -> sign(x) == -1, Δ))
end

function problem_dampener(f; debug=false)
    function (report)
        f(report) && return true
        for i in axes(report, 1)
            report_temp = deleteat!(copy(report), i)
            f(report_temp) && return true
        end
        return false
    end
end

function count_safe_reports(reports)
    count(problem_dampener(issafe_report), reports)
end


count_safe_reports(input)
