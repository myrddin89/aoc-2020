## PARTE 1
cd(@__DIR__())
using IterTools: groupby
keys = Set(("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"))
colors = Set(("amb", "blu", "brn", "gry", "grn", "hzl", "oth"))
rules = Dict(
    "byr" => x -> begin
        m = match(r"^([0-9][0-9][0-9][0-9])$", x)
        isnothing(m) && return false
        1920 <= parse(Int, m[1]) <= 2002
    end,
    "iyr" => x -> begin
        m = match(r"^([0-9][0-9][0-9][0-9])$", x)
        isnothing(m) && return false
        2010 <= parse(Int, m[1]) <= 2020
    end,
    "eyr" => x -> begin
        m = match(r"^([0-9][0-9][0-9][0-9])$", x)
        isnothing(m) && return false
        2020 <= parse(Int, m[1]) <= 2030
    end,
    "hgt" => x -> begin
        m = match(r"^([1-9][0-9]+)(cm|in)$", x)
        if isnothing(m)
            return false
        elseif m[2] == "cm"
            return 150 <= parse(Int, m[1]) <= 193
        elseif m[2] == "in"
            return 59 <= parse(Int, m[1]) <= 76
        end
    end,
    "hcl" => contains(r"^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$"),
    "ecl" => x -> x ∈ colors,
    "pid" => contains(r"^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$"),
    "cid" => _ -> true,
)

##
sum(map(x->map(a->a[1:3],foldl(∪, split.(x))),Iterators.filter(x->x[1]!="", groupby(!isempty, eachline("input.txt"))))) do p
    keys ⊆ p
end


## PARTE 2
_validate_fields(p) = all(pairs(p)) do (k, f)
    rules[k](f)
end

##
res = filter(map(x->map(a->split(a,":"),foldl(∪, split.(x)))|>Dict,Iterators.filter(x->x[1]!="", groupby(!isempty, eachline("input.txt"))))) do p
    keys ⊆ Base.keys(p) && _validate_fields(p)
end
