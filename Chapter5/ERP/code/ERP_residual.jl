include("../../../code/rERP.jl")

elec = [:Fp1, :Fp2, :F7, :F3, :Fz, :F4, :F8, :FC5, :FC1, :FC2, :FC6, :C3,
        :Cz,  :C4,  :CP5, :CP1, :CP2, :CP6, :P7,  :P3,  :Pz,  :P4,  :P8,  :O1,  :Oz,  :O2];

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :logCloze]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:logCloze], conds=["A", "C"])

@time fit_models(dt, models, "ERP_Design1_AC_Cloze");
