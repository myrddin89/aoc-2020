#%%
cd(@__DIR__)
using DataStructures: SortedDict, Backward
# data_file = "input.txt"
data_file = "test.txt"
disk_map = readchomp(data_file);

#%%
function print_fs(fs_layout)
    foreach(fs_layout) do x
        x < 0 && return print('.')
        print(x)
    end
    println()
end

function filesystem_layout(disk_map)
    fs_layout = Int[]
    file_id = 0
    free_id = -1
    for i in 1:2:lastindex(disk_map)
        data_block = Iterators.repeated(file_id, parse(Int, disk_map[i]))
        append!(fs_layout, data_block)

        i+1 <= lastindex(disk_map) || continue

        data_block = Iterators.repeated(free_id, parse(Int, disk_map[i+1]))
        append!(fs_layout, data_block)

        file_id += 1
        free_id -= 1
    end
    return fs_layout
end

function compact_layout!(fs_layout)
    head_idx = firstindex(fs_layout)
    tail_idx = lastindex(fs_layout)
    while head_idx < tail_idx
        if fs_layout[head_idx] < 0
            while tail_idx > head_idx && fs_layout[tail_idx] < 0
                tail_idx -= 1
            end
            if fs_layout[tail_idx] >= 0
                fs_layout[head_idx], fs_layout[tail_idx] = fs_layout[tail_idx], fs_layout[head_idx]
            end
        end
        head_idx += 1
    end
    return fs_layout
end

function defragment!(fs_layout)
    file_map = mapreduce(mergewith!(append!), enumerate(fs_layout), init=SortedDict{Int,Vector{Int}}(Base.Order.ReverseOrdering())) do (i, x)
        Dict(x => [i])
    end
    free_blocks = filter(p -> p.first < 0, file_map)
    file_blocks = filter(p -> p.first >= 0, file_map)
    for (x, block) in file_blocks
        findfirst(free_blocks) do (_, free_block)
            length(free_block) >= length(block)
        end
    end
end

function fs_checksum(fs_layout)
    mapreduce((+), enumerate(fs_layout)) do (id, x)
        x < 0 && return 0
        (id-1) * x
    end
end

#%%
fs_layout = filesystem_layout(disk_map);

# print_fs(fs_layout)

compact_fs_layout = compact_layout!(deepcopy(fs_layout));

# print_fs(fs_layout_defrag)

fs_checksum(compact_fs_layout)

fs_layout_defrag = defragment!(deepcopy(fs_layout))

# fs_checksum(fs_layout_defrag)
