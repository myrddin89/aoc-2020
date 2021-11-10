##
input_range = 158126:624574
data = digits.(input_range) .|> reverse
length(data)

##
function filter_passw(data)
    nondec = filter(data) do xs
        d = first(xs)
        for i in xs[2:end]
            d <= i || return false
            d = i
        end
        true
    end

    filter(nondec) do xs
        d = first(xs)
        groups = Dict{Int,Int}()
        for i in xs[2:end]
            if i == d
                if d in keys(groups)
                    groups[d] += 1
                else
                    groups[d] = 2
                end
            end
            d = i
        end
        any(==(2), values(groups))
    end
end
count_many(data) = length(data)

##
filter_passw(data)
