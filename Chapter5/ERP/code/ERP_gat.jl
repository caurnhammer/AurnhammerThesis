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
    Threads.@threads for i in collect(1:num_ts)
        m = hcat(intercept, y_ts_pred[:,i], seg) \ y_ts
        coefs[i,:,1] = m[1,:]
        coefs[i,:,2] = m[2,:]
        coefs[i,:,3] = m[3,:]
    end

    coefs
end

function plot_gat(betas, ts, ttl)
    println("Maximum Abs value: ", maximum(abs.([minimum(betas), maximum(betas)])))

    p = heatmap(ts, ts, betas, ticks=range(-200, 1200, 15), title=ttl, xlabel="Dependent (Y)", ylabel="Predictor (x)", c=cgrad([:blue, :white,:red]), clims=(-16.5, 16.5))
    gui(p)

    p
end

function plot_waveform(betas, ts)
    p = plot(ts, betas[1,:,1] .* -1)

    p
end

function save_gat_plots(beta_3d, dt)
    ts = unique(dt.Timestamp)

    p1 = plot_gat(beta_3d[:,:,1], ts, "Intercept")
    savefig(p1, "../plots/GAT/GAT_coef_intercept.pdf")

    p2 = plot_gat(beta_3d[:,:,2], ts, "Time-step Voltage")
    savefig(p2, "../plots/GAT/GAT_coef_timestep.pdf")
    
    p3 = plot_gat(beta_3d[:,:,3], ts, "Segment Voltage")
    savefig(p3, "../plots/GAT/GAT_coef_segment.pdf")
end