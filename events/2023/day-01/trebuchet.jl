#%%
cd(@__DIR__)
sum(eachline("input.txt")) do line
    first_digit = findfirst(isdigit, line)
    last_digit = findlast(isdigit, line)
    parse(Int, line[first_digit] * line[last_digit])
end

#%%
digits = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
digit_pattern = join(digits, '|')
dict_digits = Dict(zip(digits, '1':'9'))
str2num(x::AbstractString) = isnothing(tryparse(Int, x)) ? dict_digits[x] : first(x)
sum(eachline("input.txt")) do line
    matches = eachmatch(Regex("[0-9]|$digit_pattern"), line, overlap=true) |> collect
    found_digits = first(matches).match, last(matches).match
    tryparse(Int, mapfoldl(str2num, (*), found_digits))
end
