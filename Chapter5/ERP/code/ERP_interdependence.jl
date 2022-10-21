include("../../../code/rERP.jl");

# Aurnhammer et al. (2021), Condition C
elec = [:Cz];        
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);

@time process_data("../../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, conds=["C"], components=[:N400, :Segment]);
@time dt = read_data("../data/ERP_Design2_rERP.csv", models);
# SWITCH ON AND OFF IN fit_models_components
#@time fit_models_components(dt, models, "ERP_Design1_N400");
#@time fit_models_components(dt, models, "ERP_Design1_Segment");
@time fit_models_components(dt, models, "ERP_Design2_N400Segment_C");
