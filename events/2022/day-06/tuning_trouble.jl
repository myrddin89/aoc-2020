#%%
cd(@__DIR__)
input = read("input.txt", String)[begin:end-1]
n=14
for i in eachindex(input)
    i+n-1 > length(input) && continue
    if length(Set(input[i:i+n-1])) == n
        @info i+n-1
        break
    end
end
