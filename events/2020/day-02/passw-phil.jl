##
cd(@__DIR__())
rx = r"([0-9]+)-([0-9]+) (.): (.+)"
map(eachline("input.txt")) do line
    m = match(rx, line)
    a = parse(Int, m[1])
    b = parse(Int, m[2])
    char = m[3]
    passw = m[4]
    fs = findall(char, passw)
    isempty(fs) && return false
    us = union(fs...)
    (a ∈ us) ⊻ (b ∈ us)
end |> count
