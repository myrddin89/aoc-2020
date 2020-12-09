##
cd(@__DIR__())
rows = 128
cols = 8
seats = map(eachline("input.txt")) do line
    row = foldl(line[1:7]; init=(0,rows-1)) do (l,u), c
        c == 'F' && return (l,(l+u)÷2)
        c == 'B' && return ((l+u)÷2+1,u)
    end
    col = foldl(line[8:10]; init=(0,cols-1)) do (l,u), c
        c == 'L' && return (l,(l+u)÷2)
        c == 'R' && return ((l+u)÷2+1,u)
    end
    first(row) * cols + first(col)
end |> sort


## PARTE 2
filter(!in(seats), first(seats):last(seats))
