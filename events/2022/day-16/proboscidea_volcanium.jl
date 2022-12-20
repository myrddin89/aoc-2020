#%%
cd(@__DIR__)
input = map(eachline("input.txt")) do line
    m = match(r"Valve ([A-Z]+) has flow rate=([0-9]+); tunnels? leads? to valves? (.*)", line)
    if isnothing(m)
        @info line
        return
    end
    v, r, dest = m.captures
    (valve=v, flow=parse(Int, r), dest=tuple(split(dest, ", ")...))
end
