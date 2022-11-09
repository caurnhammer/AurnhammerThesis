## SESSION PREPARATION
pwd()

#using CSV, DataFrames, DataFramesMeta, MixedModels, PooledArrays
using CSV, DataFrames, MixedModels
using StatsBase: mean, std, zscore

#include("spr_fns.jl")
include("../../../code/rERP.jl")

## DATA PREPARATION
# Load data and scale continuous covariates
models = make_models([:Subject, :Timestamp], [:Item, :Condition, :ReadingTime, :ReactionTime, :Duplicated], [:logRT], [:Intercept, :Cloze, :rcnoun])
@time process_spr_data("../../../data/SPR1_Design1.csv", "../data/SPR1_Design1_rRT.csv", models, invert_preds=[:Cloze, :rcnoun]);
dt = read_data("../data/SPR1_Design1_rRT.csv", models);

# exclude data
dt = exclude_trial(dt[((dt.Timestamp .!== "critical -2") .& (dt.Duplicated .!== "multi")),:], 50, 2500, 50, 6000)

#### TODO: zscore rcnoun / rcverb. Update formula. Run models anew.

## MODEL PREPARATION
contr = Dict(:Subject => Grouping(), :Item => Grouping())

f0 = @formula(logRT ~ 1 + srp + rcnoun + (1 + srp + rcnoun| Item) + (1 + srp + rcnoun | Subject))
f1 = @formula(logRT ~ 1 + srp + (1 + srp | Item) + (1 + srp | Subject))
f = f0

lmerSPR = fit_models(dt, f, contr);

numpred = length(f.rhs) - 2
coefs = [Symbol(x) for x in string.(f.rhs[1:numpred])];

lmerSPR = combine_datasets(dt, lmerSPR, coefs[2:length(coefs)])
lmerSPR = compute_RTs(lmerSPR, coefs);
estimates = names(lmerSPR)[occursin.("est_", names(lmerSPR))]
lmerSPR = compute_residuals(lmerSPR, estimates); 
lmerSPR = compute_coefs(lmerSPR, coefs); 

CSV.write("data/lmerSPR1_srprcnoun.csv", lmerSPR);
