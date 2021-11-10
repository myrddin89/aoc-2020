init_data = readdlm(joinpath(path, "input_02.txt"), ',', Int) |> vec;

##
do_with_logger() do
    noun = 12
    verb = 2
    @info "noun=$noun; verb=$verb; res=$(100noun+verb)"
    ic = IntcodeMachine(init_data)
    set!(ic, noun, verb)
    run_intcode!(ic)
    @info "IntCode result: $(fetch(ic))"
end

##
function find_noun_verb(init_data::Vector{Int})
    nouns = 0:99
    verbs = 0:99
    found = nothing
    output = 19690720
    ic = IntcodeMachine(init_data)
    for noun in nouns, verb in verbs
        reset!(ic)
        set!(ic, noun, verb)
        run_intcode!(ic)
        res = fetch(ic)
        isnothing(res) && break
        @debug "noun=$noun, verb=$verb, res=$(something(res))"
        if something(res) == output
            found = Some(100noun + verb)
            break
        end
    end
    found
end

##
do_with_logger(Logging.Info) do
    res = find_noun_verb(init_data)
    if isnothing(res)
        @info "Found nothing"
    else
        @info "Found: $res"
    end
end
