##
# Christoph Aurnhammer <aurnhammer@coli.uni-saarland.de>
#
# Functions implementing lmerERP analysis
##

using CSV
using DataFrames
using MixedModels
using PooledArrays
using Distributed
using StatsBase: mean, zscore

## FUNCTION DEFINITION
function read_data(path, conds)
    # Load data.
    data = DataFrame(CSV.File(path));

    # Take condition subsets at this point (i.e. before any z-scoring takes place)
    if conds != false
        data = data[subset_inds(data, conds),:]
    end

    # zscore
    data[:,:Cloze] = zscore(data[:,:Cloze]);
    data[:,:logCloze] = zscore(data[:,:logCloze]);
    data[:,:Association_Noun] = zscore(data[:,:Association_Noun]);
    data[:,:Association_Verb] = zscore(data[:,:Association_Verb]);

    # invert
    data[:,:Cloze] = data[:,:Cloze] .* -1;
    data[:,:logCloze] = data[:,:logCloze] .* -1;
    data[:,:Association_Noun] = data[:,:Association_Noun] .* -1;
    data[:,:Association_Verb] = data[:,:Association_Verb] .* -1;

    # Melt data to long format. Select electrodes on the fly.
    m_vars = [:Condition, :Item, :Subject, :Timestamp, :TrialNum, :Cloze, :logCloze, :Association_Noun, :Association_Verb];
    id_vars = [:Fz, :Cz, :Pz];
    data = stack(data, id_vars, m_vars, variable_name=:Electrode, value_name=:EEG);
    
    # Apply pooled array to random groupings
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

function fit_lmer_models(data, form, f_contr ; parallel)
    ## Allocate output df, run models, enter numsub * numitems rows into output in one go.
    # output alloction
    num_groupings = length(f_contr);             # number of grouping factors (in ranefs)
    numpred = length(form.rhs) - num_groupings;  # number of predictors (including zval_intercept)
    pred_names = string.(form.rhs[1:numpred]);   # get predictor names
    tl = length(unique(data[!,:Timestamp]));     # num of unique timestamps
    el = length(unique(data[!,:Electrode]));     # num of unique electrodes
    su = length(unique(data[!,:Subject]));       # num of unique subjects
    it = length(unique(data[!,:Item]));          # num of unique items
    n = tl * el * su * it;                       # nrows of final data frame
    r = su * it;                                 # nrows that are written
    subj = unique(data[!,:Subject]);             # array of unique subjects
    items = unique(data[!,:Item]);               # array of unique items
    # Preallocate output dataframe
    output_names = vcat([:Timestamp, :Electrode, :Subject, :Item], [Symbol.(string("zval_",string(x))) for x in Symbol.(pred_names)],
                        [Symbol.(string("pval_",string(x))) for x in Symbol.(pred_names)],
                        [Symbol.(string("SE_",string(x))) for x in Symbol.(pred_names)],
                        [x for x in Symbol.(pred_names)],
                        [Symbol.(string("s_",string(x))) for x in Symbol.(pred_names)], 
                        [Symbol.(string("i_",string(x))) for x in Symbol.(pred_names)], :AIC, :BIC);
    
    ncols = (4 + numpred * 4 + numpred * num_groupings + 2);
    output = DataFrame(zeros(n, ncols), :auto);
    rename!(output, output_names);
    output[!,:Electrode] = string.(output[!,:Electrode]);
    
    # model fitting
    counter = 0;
    startind = 1;
    for (i, t) in enumerate(unique(data[!,:Timestamp]))
        if parallel == true
            output = parallel_lmer(data, form, f_contr, counter, startind, tl, el, t, r, subj, items, su, it, numpred, output)
            counter = counter + 3
            startind = startind + r * 3
        else            
            output = serial_lmer(data, form, f_contr, counter, startind, tl, el, t, r, subj, items, su, it, numpred, output)
            counter = counter + 3
            startind = startind + r * 3
        end
    end

    output
end

function parallel_lmer(data, form, f_contr, counter, startind, tl, el, t, r, subj, items, su, it, numpred, output)
    Threads.@threads for e in unique(data[!,:Electrode])  
                # subset data for timestamp and electrode    
                te_dt = data[(data.Timestamp .== t) .& (data.Electrode .== e),:];
                print("> ", round((counter*100) / (tl*el), digits=1), "% done. Model = ", counter, " / ", tl*el, "; Timestamp = ", t, ".", "\r")
                m = fit(MixedModel, form, te_dt, contrasts=f_contr, progress=false);
                
                zvals = m.beta ./ m.stderror
                aic = m.objective + 2 * dof(m)
                bic = m.objective + dof(m) * log(nobs(m))
                
                # determine input indices
                if e == "Cz"
                    sind = startind+r
                elseif e == "Pz"
                    sind = startind+(r)*2
                else
                    sind = startind
                end
                
                output[sind:(sind+r-1),:] = DataFrame(vcat([fill(t,r), fill(e,r), repeat(subj,inner=it), repeat(items,outer=su)], [fill(y,r) for y in zvals], [fill(y,r) for y in m.pvalues], [fill(y,r) for y in m.stderror],
                                                    [fill(y,r) for y in m.beta], [subj_coef(m.b[2],x,su,it,numpred) for x in 1:numpred], [item_coef(m.b[1],x,su,it,numpred) for x in 1:numpred], [fill(aic,r), fill(bic, r)]), names(output))
    end

    output
end

function serial_lmer(data, form, f_contr, counter, startind, tl, el, t, r, subj, items, su, it, numpred, output)
    for (j, e) in enumerate(unique(data[!,:Electrode]))
            counter = counter + 1
            # subset data for timestamp and electrode
            te_dt = data[(data.Timestamp .== t) .& (data.Electrode .== e),:];
            
            # fit model
            print("> ", round((counter*100) / (tl*el), digits=1), "% done. Model = ", counter, " / ", tl*el, "; Timestamp = ", t, ". Electrode = ", e, ".\r")
            m = fit(MixedModel, form, te_dt, contrasts=f_contr, progress=false);
            zvals = m.beta ./ m.stderror
            aic = m.objective + 2 * dof(m)
            bic = m.objective + dof(m) * log(nobs(m))
            
            # TO DO : use ranef names. Currently only supports fixef = ranef models.
            output[startind:(startind+r-1),:] = DataFrame(vcat([fill(t,r), fill(e,r), repeat(subj,inner=it), repeat(items,outer=su)], [fill(y,r) for y in zvals], [fill(y,r) for y in m.pvalues], [fill(y,r) for y in m.stderror],
                                                [fill(y,r) for y in m.beta], [subj_coef(m.b[2],x,su,it,numpred) for x in 1:numpred], [item_coef(m.b[1],x,su,it,numpred) for x in 1:numpred], [fill(aic,r), fill(bic, r)]), names(output))
            
            startind = startind + r
    end
    
    output
end

function generate_results(fitted, form, output_path)
    # prepare data
    numpred = length(form.rhs) - 2
    coefs = [Symbol(x) for x in string.(form.rhs[1:numpred])];
    fitted = combine_datasets(dt, fitted, coefs[2:length(coefs)]); 
    
    # compute estimates & residuals & add coefs to intercept
    fitted = compute_estimates(fitted, coefs);
    estimates = names(fitted)[occursin.("est_", names(fitted))]
    fitted = compute_residuals(fitted, estimates); 
    fitted = compute_coefs(fitted, coefs); 

    ## Write to disk
    CSV.write(output_path, fitted)
end

function combine_datasets(eeg_data, lmer_data, preds)
    # collapse eeg data to item * subject subset of non-excluded trials. Rename predictor cols to z*. (zscored predictors)
    stim = combine(groupby(eeg_data, [:Subject, :Item, :Condition, :TrialNum]), [x => mean => string("z_", x) for x in preds]);
    lmer_data = innerjoin(lmer_data, stim, on = [:Subject, :Item]);
    lmer_data = innerjoin(lmer_data, eeg_data[:,[:Timestamp, :Electrode, :Subject, :Item, :EEG]], on = [:Timestamp, :Electrode, :Subject, :Item]);

    lmer_data
end

function compute_estimates(lmer_data, preds)
    # Exclude interecept in combinations
    if preds[1] == Symbol("1")
        combi = [[x] for x in preds[2:length(preds)]];
    else 
        combi = [[x] for x in preds];
    end

    # TODO: improve to include more than two combis
    # Generate predictor combinations
    combi_cp = combi
    global excludelist = [:plc]
    global combi
    for x in combi_cp
        for y in combi_cp
            if (x != y) & (sum([[x, y] == z for z in excludelist]) == 0)
                # TODO: avoid global
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
            lmer_data[!,:est_1] = lmer_data[!,Symbol("1")] .+ lmer_data[!,:s_1] .+ lmer_data[!,:i_1]
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
        lmer_data[!,Symbol(string("res_", string(x[5:lastindex(x)])))] = lmer_data[!,:EEG] .- lmer_data[!,Symbol(x)]
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
