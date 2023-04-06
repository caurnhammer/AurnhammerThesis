include("../../../code/lmerRT.jl");
contr = Dict(:Subject => Grouping(), :Item => Grouping());

## Data Preparation
# Load data and scale continuous covariates
dt = read_spr_data("../../../data/SPR_Design2.csv",
    [:PrecritRT, :Plaus, :Cloze_distractor];
    invert_preds = [:Plaus]);

# exclude data
dt = exclude_trial(dt[((dt.Region .!= "Pre-critical-2")),:], 50, 2500, 50, 10000);

# Plaus + Distractor Cloze
f1 = @formula(logRT ~ 1 + Plaus + Cloze_distractor + 
    (1 + Plaus + Cloze_distractor | Item) + 
    (1 + Plaus + Cloze_distractor | Subject));
lmerRT = fit_lmer_models(dt, f1, contr);
generate_results(lmerRT, f1, "../data/rRT_Plaus_Clozedist.csv");

# Plaus + Distractor Cloze
f2 = @formula(logRT ~ 1 + PrecritRT + Plaus + Cloze_distractor + 
    (1 + PrecritRT + Plaus + Cloze_distractor | Item) + 
    (1 +  PrecritRT + Plaus + Cloze_distractor | Subject));
lmerRT = fit_lmer_models(dt, f2, contr);
generate_results(lmerRT, f2, "../data/rRT_PrecritRT_Plaus_Clozedist.csv");