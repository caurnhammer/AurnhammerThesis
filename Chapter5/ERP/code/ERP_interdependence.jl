# If components are provided, they are automatically inverted. I.e. no need to provide them to invert_preds argument

include("../../../code/rERP.jl");

# Aurnhammer et al. (2021), Condition C
elec = [:Pz];        
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);

# Design 1
@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["C"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);
# SWITCH ON AND OFF IN fit_models_components
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400_C");
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_Segment_C");
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400Segment_C");

@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["A"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400Segment_A");

@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["B"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400Segment_B");

@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["C"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400Segment_C");

@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["D"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400Segment_D");

# dbc 19
@time process_data("../../../data/dbc_data.csv", "../data/ERP_dbc19_rERP.csv", models, conds=["control"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_dbc19_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_dbc19_N400Segment_A");

@time process_data("../../../data/dbc_data.csv", "../data/ERP_dbc19_rERP.csv", models, conds=["script-related"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_dbc19_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_dbc19_N400Segment_B");

@time process_data("../../../data/dbc_data.csv", "../data/ERP_dbc19_rERP.csv", models, conds=["script-unrelated"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_dbc19_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_dbc19_N400Segment_C");

# Design 2
# SWITCH ON AND OFF IN fit_models_components
@time process_data("../../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, conds=["A"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design2_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design2_N400Segment_A");

@time process_data("../../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, conds=["B"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design2_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design2_N400Segment_B");

@time process_data("../../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, conds=["C"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design2_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design2_N400Segment_C");

# DEV
include("../../../code/rERP.jl");
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["A"], components=[:N400, :P600, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :PzSegment], quant = false);
include("../../../code/rERP.jl"); @time fit_models(dt, models, "ERP_Design1_Segment_A");


models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N400Segment_A");

include("../../../code/rERP.jl");
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["A"], components=[:N400minP600, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N600minP1000Segment_A");

include("../../../code/rERP.jl");
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = true);
@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_rERP.csv", models, conds=["A"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design1_rERP.csv", models);
include("../../../code/rERP.jl"); @time fit_models_components(dt, models, "ERP_Design1_N000Segment_A");


# Through time
include("../../../code/rERP.jl");
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept], quant = false);
tw_length = 200
tws = collect(range(0, 1000, 11))
for t in tws
    @time dt = process_data("../../../data/ERP_Design1.csv", false, models, components=[:TimeWindow, :Segment], time_windows=[t, t+tw_length]);
    # @time dt = process_data("../../../data/ERP_Design1.csv", false, models, components=[:Segment], time_windows=[t, t+tw_length]);
    @time fit_models_components(dt, models, string("ERP_Design1_TimeWindowSegment_", Int(t), "-", Int(t+tw_length)));
end
