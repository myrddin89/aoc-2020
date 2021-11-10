##
path = @__DIR__()
using DelimitedFiles

##
data = readdlm(joinpath(path,"input.txt"), '\n', Int) |> vec

##
function compute_fuel_requirement(data::Vector)
    sum(data) do x
        compute_fuel_requirement(x)
    end
end
function compute_fuel_requirement(x::Real)
    amount = x ÷ 3 - 2
    amount <= 0 && return 0
    amount + compute_fuel_requirement(amount)
end

##
compute_fuel_requirement(data)
