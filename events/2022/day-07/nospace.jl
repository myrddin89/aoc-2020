#%%
cd(@__DIR__)
using DataStructures

#%%
max_sz = 100_000
dir_stack = nil(String)
dirs = counter(Tuple)
for line in eachline("input.txt")
    args = split(line)
    if args[1] == "\$"
        args[2] == "cd" || continue
        dir_stack = args[3] == ".." ? tail(dir_stack) : cons(args[3], dir_stack)
    elseif startswith(args[1], r"[0-9]")
        cur_sz = parse(Int, args[1])
        ss = dir_stack
        while !isempty(ss)
            inc!(dirs, Tuple(ss), cur_sz)
            ss = tail(ss)
        end
    end
end
sum(x.second for x in dirs if x.second <= max_sz)

#%% SECOND PART
total_space = 70_000_000
required = 30_000_000
target = required - (total_space - dirs[("/",)])
minimum(x.second for x in dirs if x.second >= target)
