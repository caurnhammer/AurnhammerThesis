##
# Christoph Aurnhammer <aurnhammer@coli.uni-saarland.de>
# Apply (lme)rERP method to ERP data from Design 1
##

## SESSION PREPARATION
run(`mkdir -p ../data`)
include("../../../code/lmerERP.jl");
contr = Dict(:Item => Grouping(), :Subject => Grouping());

### Cloze / logCloze in Condition A & C
# AC Cloze
dt = read_data("../../../data/ERP_Design1.csv", ["A", "C"]);
f1 = @formula(EEG ~ 1 + Cloze + (1 + Cloze | Item) + (1 + Cloze | Subject));
lmerERP = fit_lmer_models(dt, f1, contr, parallel=true);
generate_results(lmerERP, f1, "../data/lmerERP_AC_Cloze.csv");

# AC logCloze
dt = read_data("../../../data/ERP_Design1.csv", ["A", "C"]);
f2 = @formula(EEG ~ 1 + logCloze + (1 + logCloze | Item) + (1 + logCloze | Subject));
lmerERP = fit_lmer_models(dt, f2, contr, parallel=true);
generate_results(lmerERP, f2, "../data/lmerERP_AC_logCloze.csv");

### Noun / Verb Association in Condition C & D
# CD Noun
dt = read_data("../../../data/ERP_Design1.csv", ["C", "D"]);
f3 = @formula(EEG ~ 1 + Association_Noun + (1 + Association_Noun | Item) + (1 + Association_Noun | Subject));
lmerERP = fit_lmer_models(dt, f3, contr, parallel=true);
generate_results(lmerERP, f3, "../data/lmerERP_CD_AssocNoun.csv");

# CD Verb
dt = read_data("../../../data/ERP_Design1.csv", ["C", "D"]);
f4 = @formula(EEG ~ 1 + Association_Verb + (1 + Association_Verb | Item) + (1 + Association_Verb | Subject));
lmerERP = fit_lmer_models(dt, f4, contr, parallel=true);
generate_results(lmerERP, f4, "../data/lmerERP_CD_AssocVerb.csv");

## logCloze + Association_Noun in all Conditions
dt = read_data("../../../data/ERP_Design1.csv", false);
f5 = @formula(EEG ~ 1 + logCloze + Association_Noun + (1 + logCloze + Association_Noun | Item) + (1 + logCloze + Association_Noun | Subject));
lmerERP = fit_lmer_models(dt, f5, contr, parallel=true);
generate_results(lmerERP, f5, "../data/lmerERP_logCloze_AssocNoun.csv");

## logCloze in Condition A
dt = read_data("../../../data/ERP_Design1.csv", ["A"]);
f6 = @formula(EEG ~ 1 + logCloze + (1 + logCloze | Item) + (1 + logCloze | Subject));
lmerERP = fit_lmer_models(dt, f6, contr, parallel=true);
generate_results(lmerERP, f6, "../data/lmerERP_A_logCloze.csv");

# Put through rERP.jl to obtain full grid graph
include("../../../code/rERP.jl");
elec = [:Fp1, :Fp2, :F7, :F3, :Fz, :F4, :F8, :FC5, :FC1, :FC2, :FC6, :C3,
        :Cz, :C4, :CP5, :CP1, :CP2, :CP6, :P7, :P3, :Pz, :P4, :P8, :O1, :Oz, :O2];
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);
@time dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=false);
@time fit_models(dt, models, "../data/ERP_Design1_rERP");
