include("../../../code/rERP.jl")
using Plots

function proc_for_gat(file; sampling_rate = false)
    data = DataFrame(File(file))
    
    if "ItemNum" in names(data)
        rename!(data, :ItemNum => :Item);
    end

    if sampling_rate != false
        data = downsample(data, sampling_rate)
    end

    models = make_models([], [], [:Cz], [])
    data = collect_component(data, "Segment", models; tws = 0, twe = 1200)

    data = data[:,[:Item, :Condition, :Subject, :Timestamp, :Cz, :CzSegment, :Cloze]]

    sort!(data, [:Timestamp])

    data
end

function gat(data; cond = "C")
    data = data[data.Condition .== cond,:]

    nrow_ts = nrow(data[data.Timestamp .== -200,:])
    num_ts = length(unique(data.Timestamp))

    y_ts = reshape(Array(data.Cz), (nrow_ts, num_ts))
    
    # Predictors
    # To do: get rid of redundant ar -> df -> ar casting
    y_ts_pred = Array(DataFrame(zscore.(eachcol(y_ts)), :auto))
    intercept = ones(nrow_ts)
    seg = zscore(Array(data.CzSegment)[1:nrow_ts,1])


    # Output
    coefs = zeros(num_ts, num_ts, 3)

    num = num_ts^2
    print("Fitting ", num, " models using ", Threads.nthreads(), " threads. \n")  
    #for i in collect(1:num_ts)
    Threads.@threads for i in collect(1:num_ts)
        m = hcat(intercept, y_ts_pred[:,i], seg) \ y_ts
        coefs[i,:,1] = m[1,:]
        coefs[i,:,2] = m[2,:]
        coefs[i,:,3] = m[3,:]
    end

    coefs
end

function plot_gat(betas, ts, ttl)
    p = heatmap(x=ts, y=ts, z=betas, title=ttl, xlabel="Y", ylabel="x", c=cgrad([:blue, :white,:red]), clims=(-8.5, 8.5))
    gui(p)

    p
end

function plot_waveform(betas)
    ts = collect(range(start=-200, stop=1198, length=700))
    p = plot(ts, betas[1,:,1])
    gui(p)
end
