include("../../../code/rERP.jl");

# Aurnhammer et al. (2021), Condition C
elec = [:Cz];        
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);

@time process_data("../../../data/ERP_Design1.csv", "../data/ERP_Design1_C_rERP.csv", models, conds=["C"], components=[:N400, :Segment]);

@time dt = read_data("../data/ERP_Design1_C_rERP.csv", models);
select!(dt, Not(:Condition));
dt[:,:Condition] = dt[:,:Quantile];

@time fit_models_components(dt, models, "ERP_Design1_N400Segment")