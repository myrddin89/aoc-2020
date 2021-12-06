## PARTE 1
cd(@__DIR__)
input = reduce(hcat,
    map(line -> parse.(Bool, collect(line)), eachline("input.txt")));

##
scores = sum(input, dims=2) |> vec
γ_bits = broadcast(>(size(input, 2) ÷ 2), scores)
γ, ϵ = reduce(enumerate(reverse(γ_bits)); init=(0,0)) do (γ, ϵ), (i, b)
    γ |= b << (i-1)
    ϵ |= ~b << (i-1)
    γ, ϵ
end
γ * ϵ
