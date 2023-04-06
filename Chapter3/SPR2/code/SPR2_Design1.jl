##
# Apply (lme)rRT analysis to SPR1 Design 1
##
include("../../../code/lmerRT.jl");
contr = Dict(:Subject => Grouping(), :Item => Grouping());

# logCloze + Association_Noun in all condition
dt = read_spr_data("../../../data/SPR2_Design1.csv",
    [:logCloze, :Association_Noun];
    invert_preds = [:logCloze, :Association_Noun]);
dt = exclude_trial(dt[(dt.Region .!= "Pre-critical-2"),:], 50, 2500, 50, 6000);
f = @formula(logRT ~ 1 + logCloze + Association_Noun + 
    (1 + logCloze + Association_Noun | Item) + 
    (1 + logCloze + Association_Noun | Subject));
lmerRT = fit_lmer_models(dt, f, contr);
generate_results(lmerRT, f, "../data/lmerRT_logCloze_AssocNoun.csv");

# logCloze in condition A
dt = read_spr_data("../../../data/SPR2_Design1.csv",
    [:logCloze, :Association_Noun];
    invert_preds = [:logCloze, :Association_Noun],
    conds = ["A"]);
dt = exclude_trial(dt[(dt.Region .!== "Pre-critical-2"),:], 50, 2500, 50, 6000);
f = @formula(logRT ~ 1 + logCloze + 
        (1 + logCloze | Item) + 
        (1 + logCloze | Subject));
lmerRT = fit_lmer_models(dt, f, contr);
generate_results(lmerRT, f, "../data/lmerRT_A_logCloze.csv");