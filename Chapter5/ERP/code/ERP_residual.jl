include("../../../code/rERP.jl");

elec = [:Fp1, :Fp2, :F7, :F3, :Fz, :F4, :F8, :FC5, :FC1, :FC2, :FC6, :C3,
        :Cz,  :C4,  :CP5, :CP1, :CP2, :CP6, :P7,  :P3,  :Pz,  :P4,  :P8,  :O1,  :Oz,  :O2];

# PONE within-condition logCloze
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :logCloze]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:logCloze], conds=["A"]);
@time fit_models(dt, models, "ERP_Design1_A_logCloze");
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :logCloze]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:logCloze], conds=["B"]);
@time fit_models(dt, models, "ERP_Design1_B_logCloze");
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :logCloze]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:logCloze], conds=["C"]);
@time fit_models(dt, models, "ERP_Design1_C_logCloze");
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :logCloze]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:logCloze], conds=["D"]);
@time fit_models(dt, models, "ERP_Design1_D_logCloze");

# logCloze constrasts: A&C | B&D
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :logCloze]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:logCloze], conds=["A", "C"]);
@time fit_models(dt, models, "ERP_Design1_AC_logCloze");
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:logCloze], conds=["B", "D"]);
@time fit_models(dt, models, "ERP_Design1_BD_logCloze");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :CondCodeExp]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:CondCodeExp], conds=["A", "C"]);
@time fit_models(dt, models, "ERP_Design1_AC_CondCode");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :CondCodeExp, :CondCodeAssoc]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:CondCodeExp, :CondCodeAssoc], conds=["A", "B", "C", "D"]);
@time fit_models(dt, models, "ERP_Design1_ABCD_CondCode");


models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Cloze]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:Cloze], conds=["A", "C"]);
@time fit_models(dt, models, "ERP_Design1_AC_Cloze");
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:Cloze], conds=["A"]);
@time fit_models(dt, models, "ERP_Design1_A_Cloze");
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:Cloze], conds=["C"]);
@time fit_models(dt, models, "ERP_Design1_C_Cloze");


# predict AB | CD differnece by association -> should not reduce resids in P6 and hence correl should not come out?
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :rcnoun]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:rcnoun], conds=["A", "B"]);
@time fit_models(dt, models, "ERP_Design1_AB_rcnoun");
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:rcnoun], conds=["C", "D"]);
@time fit_models(dt, models, "ERP_Design1_CD_rcnoun");

# randpred
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :randpred]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A"]);
@time fit_models(dt, models, "ERP_Design1_A_randpred");
# dt = process_data("../../../data/ERP_Design1.csv", false, models, conds=["A", "C"]);
# @time fit_models(dt, models, "ERP_Design1_AC_randpred");

# Design 2
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus]);
dt = process_data("../../../data/ERP_Design2.csv", false, models, invert_preds=[:Plaus]);
@time fit_models(dt, models, "ERP_Design2_ABC_Plaus");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus]);
dt = process_data("../../../data/ERP_Design2.csv", false, models, invert_preds=[:Plaus], conds=["A"]);
@time fit_models(dt, models, "ERP_Design2_A_Plaus");
dt = process_data("../../../data/ERP_Design2.csv", false, models, invert_preds=[:Plaus], conds=["B"]);
@time fit_models(dt, models, "ERP_Design2_B_Plaus");
dt = process_data("../../../data/ERP_Design2.csv", false, models, invert_preds=[:Plaus], conds=["C"]);
@time fit_models(dt, models, "ERP_Design2_C_Plaus");


# predict CD differnece by association -> should not reduce resids in P6 and hence correl should not come out?
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :rcnoun]);
dt = process_data("../../../data/ERP_Design1.csv", false, models, invert_preds=[:rcnoun], conds=["C", "D"]);
@time fit_models(dt, models, "ERP_Design1_CD_rcnoun");
