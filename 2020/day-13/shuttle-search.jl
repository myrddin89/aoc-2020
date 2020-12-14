##
cd(@__DIR__())
lines = readlines("input.txt")
tm = parse(Int, lines[1])
@show tm
ids = map(split(lines[2], ",")) do x
    x == "x" && return missing
    parse(Int128, x)
end |> skipmissing |> collect

##
ts = (tm .÷ ids .+ 1) .* ids
@show idn = ids[argmin(ts)]
@show wt = minimum(ts) - tm
@show idn * wt


## PARTE 2
lines = readlines("input.txt")
idsts = map(split(lines[2], ",")) do x
    x == "x" && return missing
    parse(Int128, x)
end |> enumerate
idsts = Iterators.filter(idsts) do (i,d)
    !ismissing(d)
end
ts = map(first, idsts) .- 1
ids = map(last, idsts)

##
n = 1068781
function find_tm(ids, ts; start = 1)
    n = start
    seqts = zeros(Int128, length(ids))
    ds = similar(ids)
    ds[1] = 0
    ds[2:end] .= 1
    @. seqts = ((n ÷ ids) + ds) * ids - ts
    while !all(==(seqts[1]), seqts[2:end])
        n += 1
        @. seqts = ((n ÷ ids) + ds) * ids - ts
    end
    n
end
function extended_gcd(a::T, b::T) where T
    old_r::T, r::T = a, b
    old_s::T, s::T = 1, 0
    old_t::T, t::T = 0, 1
    while r != 0
        q = old_r ÷ r
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
        old_t, t = t, old_t - q * t
    end
    (old_s, old_t), old_r, (t, s)
end
function cong_x(y::Union{Int128,BigInt}, p::Union{Int128,BigInt}, N::Integer = 1_000_000_000)
    c = zero(typeof(y))
    k = y ÷ p |> abs
    if y < 0
        y += k * p
    end
    while y < 0 && c <= N
        y += p
        c += 1
    end
    c = zero(typeof(y))
    k = y ÷ p |> abs
    if y > p
        y -= k * p
    end
    while y > p && y > 0 && c <= N
        y -= p
        c += 1
    end
    y
end
function find_tm_2(a::T, b, t1, t2, N::Integer = 1_000_000_000) where T
    (s, t), _, _ = extended_gcd(a, b)
    @show (s, t)
    x::T = t1 * t * b + t2 * s * a
    cong_x(x, a * b, N)
end
function find_tm_opt(ids, ts, N::Integer = 1_000_000_000)
    foldl(zip(ids[2:end], ts[2:end]); init=(ids[1],zero(Int128))) do (a, x), (b, t)
        @show (a, x), (b, t)
        a * b, find_tm_2(a, b, x, -t, N)
    end |> last
end

##
k = 9
@time x = find_tm_opt(ids[1:k], ts[1:k], 100_000_000_000)
@show x
@show (x .+ ts[1:k]) .% ids[1:k];
