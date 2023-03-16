##
# Christoph Aurnhammer <aurnhammer@coli.uni-saarland.de>
#
# Functions implementing (lmer)rRT analyses
# analogous to rERPs (Smith & Kutas, 2015, Psychophysiology)
##

using CSV
using DataFrames
using MixedModels
using PooledArrays
using StatsBase: mean, std, zscore

function exclude(df, sd_cutoff)
    n = nrow(df)
    # compute SD per subject and exlude based on that
    for s in unique(df[:Subject])
        # compute mean + sd per subject
        s_mean = mean(df[(df.Subject .== s),:ReadingTime])
        s_sd = std(df[df.Subject .==s ,:ReadingTime])
        df = df[.!((df.Subject .== s) .& (df.ReadingTime .> (s_mean + sd_cutoff * s_sd)) .| (df.ReadingTime .< (s_mean - sd_cutoff * s_sd))),:]
    end
    percent_excluded = ((n - nrow(df)) / nrow(df) * 100)
    print("Excluded ", round(percent_excluded, digits=2), "% of data based on ", sd_cutoff, " per-subject SD.\n")

    df
end

function exclude_trial(df, lower, upper, lower_rc, upper_rc)
    df_out = df
    for s in unique(df[!,:Subject])
        # subset for current subject
        dts = df[(df.Subject .== s),:];
        for i in unique(dts[!,:Item])
            # subset current item
            dti = dts[(dts.Item .== i),:];
            
            if sum(dti.ReactionTime .=== missing) > 1
                exc = sum((dti.ReadingTime .> upper) .| (dti.ReadingTime .< lower)) > 0;
                if exc == true
                    df_out = df_out[.!((df_out.Subject .== s) .& (df_out.Item .== i)),:];
                end
            elseif sum(dti.ReactionTime .=== missing) == 0
                exc = sum((dti.ReadingTime .> upper) .| (dti.ReadingTime .< lower) .| (dti.ReactionTime .> upper_rc) .| (dti.ReactionTime .< lower_rc)) > 0;
                if exc == true
                    df_out = df_out[.!((df_out.Subject .== s) .& (df_out.Item .== i)),:];
                end
            end
        end
    end

    println(nrow(df)-nrow(df_out), " / ", nrow(df), " excluded (", (nrow(df)-nrow(df_out))*100/nrow(df) ,"%).")
    
    df_out
end

function read_spr_data(path, conds)
    data = DataFrame(CSV.File(path))
    
    # Take condition subsets at this point (i.e. before any z-scoring takes place)
    if conds != false
        data = data[subset_inds(data, conds),:]
    end

    data.logCloze = zscore(data.logCloze)
    data.Association_Noun = zscore(data.Association_Noun)

    data.logCloze = data.logCloze .* -1
    data.Association_Noun = data.Association_Noun .* -1

    data = data[:,[:Condition, :Item, :Subject, :Region, :Duplicated, :logRT,
                   :ReadingTime, :ReactionTime, :logCloze, :Association_Noun]]

    data = transform!(data,
            :Subject => PooledArray => :Subject,
            :Item => PooledArray => :Item);

    data
end

function subset_inds(data, conds)
    ind = Int.(zeros(nrow(data)))
    for x in conds
        ind_curr = (data.Condition .== x)
        ind = ind .| ind_curr
    end

    Bool.(ind)
end

function item_coef(b_array,index,n_sub,n_it,n_pred)
    collect(Iterators.flatten(fill(reshape(b_array,(n_it*n_pred))[index:n_pred:(n_it*n_pred)],n_sub)))
end

function subj_coef(b_array,index,n_sub,n_it,n_pred)
    repeat(reshape(b_array,(n_sub*n_pred))[index:n_pred:(n_sub*n_pred)], inner=(n_it))
end

function fit_lmer_models(data, form, f_contr)
    # Determine data properties
    num_groupings = length(f_contr);             # number of grouping factors (in ranefs)
    numpred = length(form.rhs) - num_groupings;  # number of predictors (including zval_intercept)
    pred_names = string.(form.rhs[1:numpred]);   # get predictor names
    tl = length(unique(data[!,:Region]));        # num of unique Regions
    su = length(unique(data[!,:Subject]));       # num of unique subjects
    it = length(unique(data[!,:Item]));          # num of unique items
    n = tl * su * it;                            # nrows of final data frame
    r = su * it;                                 # nrows that are written
    subj = unique(data[!,:Subject]);             # array of unique subjects
    items = unique(data[!,:Item]);               # array of unique items

    # Allocate output
    output_names = vcat([:Region, :Subject, :Item], [Symbol.(string("zval_",string(x))) for x in Symbol.(pred_names)],
                         [Symbol.(string("pval_",string(x))) for x in Symbol.(pred_names)], 
                         [Symbol.(string("SE_",string(x))) for x in Symbol.(pred_names)],
                         [x for x in Symbol.(pred_names)],
                        [Symbol.(string("s_",string(x))) for x in Symbol.(pred_names)], [Symbol.(string("i_",string(x))) for x in Symbol.(pred_names)], :AIC, :BIC);
    ncols = (3 + numpred * 4 + numpred * num_groupings + 2);
    output = DataFrame(zeros(n, ncols), :auto);
    rename!(output, [String(n) for n in output_names]);
    s_region = string.(collect(output[:,"Region"]))
    select!(output, Not("Region"))
    insertcols!(output, 1, "Region" => s_region)
    output[:,:Region] = s_region

    counter = 0;
    startind = 1;
    for (i, t) in enumerate(unique(data[!,:Region]))          
        counter = counter + 1
        # subset data for Region
        te_dt = data[(data.Region .== t),:];
        
        # fit model
        m = fit(MixedModel, form, te_dt, contrasts=f_contr, progress=false);
        zvals = m.beta ./ m.stderror
        aic = m.objective + 2 * dof(m)
        bic = m.objective + dof(m) * log(nobs(m))
        
        # TO DO : use ranef names. Currently only supports fixef = ranef models.
        temp = DataFrame(vcat([fill(t,r), repeat(subj,inner=it), repeat(items,outer=su)], [fill(y,r) for y in zvals], [fill(y,r) for y in m.pvalues], [fill(y,r) for y in m.stderror],
                                            [fill(y,r) for y in m.beta], [subj_coef(m.b[2],x,su,it,numpred) for x in 1:numpred], [item_coef(m.b[1],x,su,it,numpred) for x in 1:numpred], [fill(aic,r), fill(bic, r)]), :auto)
        rename!(temp, names(output))
        output[startind:(startind+r-1),:] = temp
        
        startind = startind + r

        print("> ", round((counter*100) / tl, digits=2), "% done. Model = ", counter, " / ", tl, "; Region = ", t, ".\r")
    end

    output
end

function generate_results(fitted, form, output_path)
    # prepare data
    numpred = length(form.rhs) - 2;
    coefs = [Symbol(x) for x in string.(f.rhs[1:numpred])];
    fitted = combine_datasets(dt, fitted, coefs[2:length(coefs)]);
    
    # compute estimates & residuals & add coefs to intercept
    fitted = compute_estimates(fitted, coefs);
    estimates = names(fitted)[occursin.("est_", names(fitted))];
    fitted = compute_residuals(fitted, estimates);
    fitted = compute_coefs(fitted, coefs); 

    # Write to disk
    CSV.write(output_path, fitted);
end

function combine_datasets(data, lmer_data, preds)
    # collapse eeg data to item * subject subset of non-excluded trials. Rename predictor cols to z*. (zscored predictors)
    stim = combine(groupby(data, [:Subject, :Item, :Condition]), [x => mean => string("z_", x) for x in preds]);
    lmer_data = innerjoin(lmer_data, stim, on = [:Subject, :Item]);
    lmer_data = innerjoin(lmer_data, data[:,[:Region, :Subject, :Item, :logRT, :ReadingTime]], on = [:Region, :Subject, :Item]);

    lmer_data
end

function compute_estimates(lmer_data, preds)
    # Exclude intercept in combinations
    if preds[1] == Symbol("1")
        combi = [[x] for x in preds[2:length(preds)]];
    else 
        combi = [[x] for x in preds];
    end

    # Genereate predictor combinations
    combi_cp = combi
    global excludelist = [:plc]
    global combi
    for x in combi_cp
        for y in combi_cp
            if (x != y) & (sum([[x, y] == z for z in excludelist]) == 0)
                global combi = vcat(combi, [[x, y]]);
                global excludelist = vcat(excludelist, [[y, x]]);
            end
        end
    end

    # vcat intercept with combination
    if preds[1] == Symbol("1")
        combi = vcat([[preds[1]]], combi);
        combi =  vcat(combi, [[[x] for x in preds[2:length(preds)]]]);
    else 
        combi = vcat(combi, [[[x] for x in preds[2:length(preds)]]])
    end 

    for x in combi
        if x[1] == Symbol("1") # intercept
            lmer_data[!,:est_1] = lmer_data[!,Symbol("1")] .+ lmer_data[!,:s_1]  .+ lmer_data[!,:i_1]
        elseif typeof(x[1]) == Symbol # intercept + single pred
            lmer_data[!,Symbol(string("est_"), x[1])] = lmer_data[!,:est_1] + (lmer_data[!,x[1]] .+ lmer_data[!,Symbol("s_", x[1])] .+ lmer_data[!,Symbol("i_", x[1])]) .* lmer_data[!,Symbol("z_", x[1])];
        elseif typeof(x[1]) == Array{Symbol,1} # intercept + combination of preds
            # start with intercept
            temp_data = lmer_data[!,:est_1]
            colname = "est_"
            # for each element within combination
            for y in x
                colname = string(colname, y[1])
                temp_data = temp_data .+ (lmer_data[!,Symbol(y[1])] .+ lmer_data[!,Symbol("s_", y[1])] .+ lmer_data[!,Symbol("i_", y[1])]) .* lmer_data[!,Symbol("z_", y[1])]
            end
            lmer_data[!,Symbol(colname)] = temp_data
        end
    end

    lmer_data
end

function compute_residuals(lmer_data, preds)
    # Residuals: observed - estimated
    for x in preds
        lmer_data[!,Symbol(string("res_", string(x[5:lastindex(x)])))] = lmer_data[!,:logRT] .- lmer_data[!,Symbol(x)]
    end

    lmer_data
end

function compute_coefs(lmer_data, preds)
    # Compute sum of intercept and coefs (fixef + subject ranef + item ranef)
    for x in preds
        if x == Symbol("1")
            lmer_data[!,:coef_1] = lmer_data[!,Symbol("1")] .+ lmer_data[!,:s_1] .+ lmer_data[!,:i_1]
        else
            lmer_data[!,Symbol(string("coef_intercept_", string(x)))] = lmer_data[!,:coef_1] .+ lmer_data[!,x] .+ lmer_data[!,Symbol(string("s_", string(x)))] .+ lmer_data[!,Symbol(string("i_", string(x)))]
        end
    end
    
    lmer_data
end
