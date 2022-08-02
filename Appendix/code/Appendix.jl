# Christoph Aurnhammer, 2022
# This is the inital version of my rERP.jl primer.
# rERPs have initially been described by Smith and Kutas (2015a, 2015b).
# DO NOT DISTRIBUTED THIS CODE.
# A final version will be made public as part of my Dissertation.

# Load the functions in rERPs.jl
# Packages are loaded from within rERPs.jl
include("../../code/rERP.jl");

# Define an array of electrodes on which to fit the models.
elec = [:Fp1, :Fp2, :F7, :F3, :Fz, :F4, :F8, :FC5, :FC1, :FC2, :FC6, :C3,
        :Cz, :C4, :CP5, :CP1, :CP2, :CP6, :P7, :P3, :Pz, :P4, :P8, :O1, :Oz, :O2];

# Define a models Structure. All arguments are arrays of column name Symbols, e.g. [:Item, :Subject]
# Arguments:
# - Descriptors: Fit separate models for each of these. You DO NOT have to add electrodes here!
# - NonDescriptors: Columns that we don't use but want to carry over to our output data.
# - Electrodes: Electrodes on which to fit separate models.
# - Predictors: Predictors to use in the model.
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);

# Pre-process the data, using the following arguments:
# - infile: Path to input file. Necessary.
# - outfile: Path to output file. set to false to return DataFrame directly instead of writing. Necessary.
# - models: Models structure specified above. Necessary.
# - baseline_corr: Apply baseline correction, if you haven't done so already. Default false.
# - sampling_rate: Downsample to a lower sampling rate. Default false.
# - invert_preds: Takes an array of predictor Symbols (e.g., [:Cloze, :Association]) to invert. Default false.
# - conds: Takes an array of condition labels to subset to (e.g. ["A", "B"]). Default false.
# - components: Collect the average N400 and Segment amplitude (Special sauce for one of my projects). Default false.
@time process_data("../../data/ERP_Design1.csv", "../data/ERP_Design1_AC_rERP.csv", models, conds=["A", "C"]);

# Read in processed data.
@time dt = read_data("../data/ERP_Design1_AC_rERP.csv", models);

# Fit the rERP models, using the three arguments:
# - data: data as processed by process_data()
# - models: models Structure
# - file: path to output file. Filenames will be automatically extended to *_data.csv and *_models.csv.
@time fit_models(dt, models, "../data/ERP_Design1_AC_rERP");

##########################
# rERPs as ERP averaging #
##########################
##### Fit intercept only models = compute grand-averaged ERP
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept]);
@time process_data("../../data/ERP_Design1.csv", "../data/ERP_Design1_AC_rERP.csv", models, conds=["A", "C"]);
@time dt = read_data("../data/ERP_Design1_AC_rERP.csv", models);
@time fit_models(dt, models, "../data/ERP_Design1_AC_Intercept_rERP");

##### Fit A vs. C condition coding models = compute per-condition grand-averaged ERP
# Create A vs C condition coding predictor. B and D rows are going to be discarded.
cond_coding = Dict("A" => -0.5, "B" => 0, "C" => 0.5, "D" => 0);
dt = DataFrame(File("../../data/ERP_Design1.csv"));
dt.CondCode = [cond_coding[x] for x in dt.Condition];
write("../../data/ERP_Design1.csv", dt);

models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :CondCode]);
@time process_data("../../data/ERP_Design1.csv", "../data/ERP_Design1_AC_rERP.csv", models, conds=["A", "C"]);
@time dt = read_data("../data/ERP_Design1_AC_rERP.csv", models);
@time fit_models(dt, models, "../data/ERP_Design1_AC_CondCode_rERP");

########################
# Continous predictors #
########################
# Fit models on conditions A and C using cloze probability
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Cloze]);
@time process_data("../../data/ERP_Design1.csv", "../data/ERP_Design1_AC_cloze_rERP.csv", models, invert_preds=[:Cloze], conds=["A", "C"]);
@time dt = read_data("../data/ERP_Design1_AC_cloze_rERP.csv", models);
@time fit_models(dt, models, "../data/ERP_Design1_AC_cloze_rERP");

# Fit models on all conditions using cloze probability and association
# In order to not take any condition subset, set conds = false.
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Cloze, :rcnoun]);
@time process_data("../../data/ERP_Design1.csv", "../data/ERP_Design1_cloze_rcnoun_rERP.csv", models, invert_preds=[:Cloze, :rcnoun]);
@time dt = read_data("../data/ERP_Design1_cloze_rcnoun_rERP.csv", models);
@time fit_models(dt, models, "../data/ERP_Design1_cloze_rcnoun_rERP");


################################
# Modeling Scalp Distributions #
################################
models = make_models([:Subject, :Timestamp], [:Item, :Condition], elec, [:Intercept, :Plaus, :Cloze_distractor]);
@time process_data("../../data/ERP_Design2.csv", "../data/ERP_Design2_rERP.csv", models, invert_preds=[:Plaus]);
@time dt = read_data("../data/ERP_Design2_rERP.csv", models);

@time fit_models(dt, models, "ERP_Design2_Plaus_Clozedist");
