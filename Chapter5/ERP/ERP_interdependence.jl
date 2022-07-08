include("../../code/rERP.jl");

# Aurnhammer et al. (2021), Condition C
elec = [:Fp1, :Fp2, :F7, :F3, :Fz, :F4, :F8, :FC5, :FC1, :FC2, :FC6, :C3,
        :Cz,  :C4,  :CP5, :CP1, :CP2, :CP6, :P7,  :P3,  :Pz,  :P4,  :P8,  :O1,  :Oz,  :O2];
elec = [:Fz, :Cz, :Pz];        
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);

@time process_data("../../data/ERP_Design1.csv", "data/ERP_Design1_C_rERP.csv", models, conds=["C"], components=[:N400, :Segment]);

@time dt = read_data("data/ERP_Design1_C_rERP.csv", models);
select!(dt, Not(:Condition));
dt[:,:Condition] = dt[:,:Quantile];

@time fit_models_components(dt, models, "ERP_Design1_N400Segment")