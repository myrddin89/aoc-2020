##
cd(@__DIR__)
⊕(x, y) = x * y
⊗(x, y) = x + y
function parse_line(line)
    Meta.parse(replace(replace(line, r"\*" => s"⊕"), r"\+" => s"⊗"))
end
input = parse_line.(eachline("input.txt"))

##
sum(eval.(input))
