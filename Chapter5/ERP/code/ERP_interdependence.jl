# If components are provided, they are automatically inverted. I.e. no need to provide them to invert_preds argument
include("../../../code/rERP.jl");

# Aurnhammer et al. (2021), Condition A & C
elec = [:Fz, :Cz, :Pz];        
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);

## Aurnhammer et al. (2021)
# Condition A & C (Expected / Unexpected)
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A", "C"], components=[:N400, :Segment]);
fit_models_components(dt, models, "rERP_N400Segment_AC");

# Condition A / C separately
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A"], components=[:N400, :Segment]);
fit_models_components(dt, models, "rERP_N400Segment_A");
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["C"], components=[:N400, :Segment]);
fit_models_components(dt, models, "rERP_N400Segment_C");

## Delogu et al., (2019)
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);
dta = process_data("../../../data/dbc19_data.csv", false, models, conds=["control"], components=[:N400, :Segment]);
dtb = process_data("../../../data/dbc19_data.csv", false, models, conds=["script-related"], components=[:N400, :Segment]);
dtc = process_data("../../../data/dbc19_data.csv", false, models, conds=["script-unrelated"], components=[:N400, :Segment]);

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment]);
fit_models_components(dta, models, "rERP_dbc19_N400Segment_A");
fit_models_components(dtb, models, "rERP_dbc19_N400Segment_B");
fit_models_components(dtc, models, "rERP_dbc19_N400Segment_C");