##
# Christoph Aurnhammer <aurnhammer@coli.uni-saarland.de>
# Apply (lme)rERP method to ERP data from Design 1
##

## SESSION PREPARATION
# load lmerERP functions
include("../../../code/lmerERP.jl");
contr = Dict(:Item => Grouping(), :Subject => Grouping());

### Cloze / logCloze in Condition A & C
# AC Cloze
dt = read_data("../../../data/ERP_Design1.csv", ["A", "C"]);
f1 = @formula(EEG ~ 1 + Cloze + (1 + Cloze | Item) + (1 + Cloze | Subject));
lmerERP = fit_models(dt, f1, contr, parallel=true);
generate_results(lmerERP, f1, "../data/lmerERP_AC_Cloze.csv");

# AC logCloze
dt = read_data("../../../data/ERP_Design1.csv", ["A", "C"]);
f2 = @formula(EEG ~ 1 + logCloze + (1 + logCloze | Item) + (1 + logCloze | Subject));
lmerERP = fit_models(dt, f2, contr, parallel=true);
generate_results(lmerERP, f2, "../data/lmerERP_AC_logCloze.csv");

### Noun / Verb Association in Condition C & D
# CD Noun
dt = read_data("../../../data/ERP_Design1.csv", ["C", "D"]);
f3 = @formula(EEG ~ 1 + Association_Noun + (1 + Association_Noun | Item) + (1 + Association_Noun | Subject));
lmerERP = fit_models(dt, f3, contr, parallel=true);
generate_results(lmerERP, f3, "../data/lmerERP_CD_AssocNoun.csv");

# CD Verb
dt = read_data("../../../data/ERP_Design1.csv", ["C", "D"]);
f4 = @formula(EEG ~ 1 + Association_Verb + (1 + Association_Verb | Item) + (1 + Association_Verb | Subject));
lmerERP = fit_models(dt, f4, contr, parallel=true);
generate_results(lmerERP, f4, "../data/lmerERP_CD_AssocVerb.csv");

## logCloze + Association_Noun in all Conditions
dt = read_data("../../../data/ERP_Design1.csv", false);
f5 = @formula(EEG ~ 1 + logCloze + Association_Noun + (1 + logCloze + Association_Noun | Item) + (1 + logCloze + Association_Noun | Subject));
lmerERP = fit_models(dt, f5, contr, parallel=true);
generate_results(lmerERP, f5, "../data/lmerERP_logCloze_AssocNoun.csv");

## logCloze in Condition A
dt = read_data("../../../data/ERP_Design1.csv", ["A"]);
f6 = @formula(EEG ~ 1 + logCloze + (1 + logCloze | Item) + (1 + logCloze | Subject));
lmerERP = fit_models(dt, f6, contr, parallel=true);
generate_results(lmerERP, f6, "../data/lmerERP_A_logCloze.csv");