# If components are provided, they are automatically inverted. I.e. no need to provide them to invert_preds argument
include("../../../code/rERP.jl");

# Aurnhammer et al. (2021), Condition A & C
elec = [:Pz];        
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);

# Design 1
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A", "C"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment]);
@time fit_models(dt, models, "adsbc21_N400Segment_AC");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment]);
@time fit_models(dt, models, "adsbc21_N400Segment_A");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["C"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment]);
@time fit_models(dt, models, "adsbc21_N400Segment_C");
>>>>>>> 1d47acaed1bb35e2e1ea7f682ec9b6800bd37e38

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment], quant = false);
@time fit_models(dt, models, "ERP_Design1_N400Segment_A");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["C"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment], quant = false);
@time fit_models(dt, models, "ERP_Design1_N400Segment_C");

# dbc 19
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);
dta = process_data("../../../data/dbc19_data.csv", false, models, conds=["control"], components=[:N400, :Segment]);
dtb = process_data("../../../data/dbc19_data.csv", false, models, conds=["script-related"], components=[:N400, :Segment]);
dtc = process_data("../../../data/dbc19_data.csv", false, models, conds=["script-unrelated"], components=[:N400, :Segment]);

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment]);
fit_models(dta, models, "dbc19_N400Segment_A");
fit_models(dtb, models, "dbc19_N400Segment_B");
fit_models(dtc, models, "dbc19_N400Segment_C");
