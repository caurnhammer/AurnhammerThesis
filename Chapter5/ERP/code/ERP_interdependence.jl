# If components are provided, they are automatically inverted. I.e. no need to provide them to invert_preds argument
include("../../../code/rERP.jl");

# Aurnhammer et al. (2021), Condition A & C
elec = [:Fz];        
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);

# Design 1
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A", "C"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment], quant = false);
#@time fit_models(dt, models, "ERP_Design1_N400_AC");
#@time fit_models(dt, models, "ERP_Design1_Segment_AC");
@time fit_models(dt, models, "ERP_Design1_N400Segment_AC");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment], quant = false);
@time fit_models(dt, models, "ERP_Design1_N400Segment_A");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["C"], components=[:N400, :Segment]);
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment], quant = false);
@time fit_models(dt, models, "ERP_Design1_N400Segment_C");

# dbc 19
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
dta = process_data("../../../data/dbc19_data.csv", false, models, conds=["control"], components=[:N400, :Segment]);
dtb = process_data("../../../data/dbc19_data.csv", false, models, conds=["script-related"], components=[:N400, :Segment]);
dtc = process_data("../../../data/dbc19_data.csv", false, models, conds=["script-unrelated"], components=[:N400, :Segment]);

#### DEBUG HARM
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus, :Assoc]);
dtdbc = process_data("../../../data/dbc19_data.csv", false, models, invert_preds=[:Plaus, :Assoc]);
dtdbc.Subject = ones(nrow(dtdbc));

fit_models(dtdbc, models, "ERP_dbc19_N400Segment");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment], quant = false);
fit_models(dta, models, "ERP_dbc19_N400Segment_A");
fit_models(dtb, models, "ERP_dbc19_N400Segment_B");
fit_models(dtc, models, "ERP_dbc19_N400Segment_C");

# # Design 2
# # SWITCH ON AND OFF IN fit_models_components
# @time process_data("../../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, conds=["A"], components=[:N400, :Segment]);
# @time dt = read_data("../data/ERP_Design2_rERP.csv", models);
# include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design2_N400Segment_A");

# @time process_data("../../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, conds=["B"], components=[:N400, :Segment]);
# @time dt = read_data("../data/ERP_Design2_rERP.csv", models);
# include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design2_N400Segment_B");

# @time process_data("../../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, conds=["C"], components=[:N400, :Segment]);
# @time dt = read_data("../data/ERP_Design2_rERP.csv", models);
# include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design2_N400Segment_C");

# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);
# @time dt = process_data("../../../data/ERP_Design2.csv", false, models, components=[:N400, :Segment]);
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment]);
# include("../../../code/rERP.jl"); @time fit_models(dt, models, "ERP_Design2_N400Segment");

# # DEV
# include("../../../code/rERP.jl");
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
# @time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["A"], components=[:N400, :P600, :Segment]);
# @time dt = read_data("../data/ERP_Design1_rERP.csv", models);

# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzSegment], quant = false);
# include("../../../code/rERP.jl"); @time fit_models(dt, models, "ERP_Design1_Segment_A");


# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
# include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400Segment_A");

# include("../../../code/rERP.jl");
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
# @time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["A"], components=[:N400minP600, :Segment]);
# @time dt = read_data("../data/ERP_Design1_rERP.csv", models);
# include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N600minP1000Segment_A");

# include("../../../code/rERP.jl");
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
# @time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["A"], components=[:N400, :Segment]);
# @time dt = read_data("../data/ERP_Design1_rERP.csv", models);
# include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N000Segment_A");


# ## Through time
# # Aurnhammer et al., 2021
# include("../../../code/rERP.jl");
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
# tw_length = 200
# tws = collect(range(-100, 1000, 12));
# for t in tws
#     @time dt = process_data("../../../data/ERP_Design1.csv", false, models, components=[:TimeWindow, :Segment], time_windows=[t, t+tw_length]);
#     @time fit_models_components(dt, models, string("ERP_Design1_TimeWindowSegment_", Int(t), "-", Int(t+tw_length)));
# end

# # Delogu et al., 2019
# include("../../../code/rERP.jl");
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
# tw_length = 200
# tws = collect(range(-100, 1000, 12));
# for t in tws
#     @time dt = process_data("../../../data/dbc_data.csv", false, models, components=[:TimeWindow, :Segment], time_windows=[t, t+tw_length]);
#     @time fit_models_components(dt, models, string("ERP_dbc19_TimeWindowSegment_", Int(t), "-", Int(t+tw_length)));
# end

# # different combis for across condition data
# include("../../../code/rERP.jl");
# elec = [:Pz];   
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
# @time dt = process_data("../../../data/ERP_Design1.csv", false, models, components=[:TimeWindow, :Segment], time_windows=[300, 500]);
# @time fit_models_components(dt, models, string("ERP_Design1_N4minP6Segment"));

# include("../../../code/rERP.jl");
# elec = [:Pz];   
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
# @time dt = process_data("../../../data/ERP_Design1.csv", false, models, components=[:TimeWindow], time_windows=[300, 500]);
# @time fit_models_components(dt, models, string("ERP_Design1_N4minP6"));

# include("../../../code/rERP.jl");
# elec = [:Pz];   
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
# @time dt = process_data("../../../data/ERP_Design1.csv", false, models, components=[:N400, :P600], time_windows=[300, 500]);
# @time fit_models_components(dt, models, string("ERP_Design1_N400P600"));

# include("../../../code/rERP.jl");
# elec = [:Pz];   
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
# @time dt = process_data("../../../data/dbc_data.csv", false, models, conds=["script-related", "script-unrelated"], components=[:N400, :Segment], time_windows=[300, 500]);
# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400, :PzSegment], quant = false);
# @time fit_models(dt, models, "ERP_dbc19_N400Segment_BC");

# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
# include("../../../code/rERP.jl"); @time dt = process_data("../../../data/dbc_data.csv", false, models, components=[:N400, :Segment]);

# dt.PzN400A = zeros(nrow(dt));
# dt[(dt.Condition .== 1),:PzN400A] = zscore(copy(dt[(dt.Condition .== 1),:PzN400]));

# dt.PzN400B = zeros(nrow(dt));
# dt[(dt.Condition .== 2),:PzN400B] = zscore(copy(dt[(dt.Condition .== 2),:PzN400]));

# dt.PzN400C = zeros(nrow(dt));
# dt[(dt.Condition .== 3),:PzN400C] = zscore(copy(dt[(dt.Condition .== 3),:PzN400]));

# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400A, :PzN400B, :PzN400C, :PzSegment], quant = false);
# fit_models(dt, models, "ERP_dbc19_condN400Segment");

# models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzN400A, :PzN400B, :PzN400C], quant = false);
# fit_models(dt, models, "ERP_dbc19_condN400");

