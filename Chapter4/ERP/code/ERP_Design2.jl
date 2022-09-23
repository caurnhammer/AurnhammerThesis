include("../../../code/rERP.jl");

elec = [:Fp1, :Fp2, :F7, :F3, :Fz, :F4, :F8, :FC5, :FC1, :FC2, :FC6, :C3,
        :Cz,  :C4,  :CP5, :CP1, :CP2, :CP6, :P7,  :P3,  :Pz,  :P4,  :P8,  :O1,  :Oz,  :O2];

# Within-subjects regression
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus, :Cloze_distractor]);
@time process_data("../../../data/ERP_Design2.csv", "../data/Design2_rERP.csv", models, invert_preds=[:Plaus]);
@time dt = read_data("../data/Design2_rERP.csv", models);

@time fit_models(dt, models, "Design2_Plaus_Clozedist");

# Interaction
dt.Interaction = zscore(dt.Plaus .* dt.Cloze_distractor) .* -1
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus, :Cloze_distractor, :Interaction]);
@time fit_models(dt, models, "Design2_Plaus_Clozedist_Interaction");

# C vs AB
dt.CvsAB = zscore(dt.Condition .== 3)
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus, :Cloze_distractor, :CvsAB]);
@time fit_models(dt, models, "Design2_Plaus_Clozedist_CvsAB");

# Across-subjects regression, yielding a single-tvalue for each electrode and time-step
dts = dt
unique(dts.Subject)
dts.Subject = ones(nrow(dts))

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus, :Cloze_distractor]);
@time fit_models(dts, models, "Design2_Plaus_Clozedist_across");

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus, :Cloze_distractor, :Interaction]);
@time fit_models(dts, models, "Design2_Plaus_Clozedist_Interaction_across");

# Predict EEG by ReadingTimes (from separate Exp)
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :ReadingTime]);
@time process_data("../../../data/ERP_Design2.csv", "../data/Design2_rERP_RT.csv", models);
@time dtrt = read_data("../data/Design2_rERP_RT.csv", models);

@time fit_models(dtrt, models, "Design2_RT");
