source("../../../code/plot_rERP.r")
source("../../../code/benjamini-hochberg.r")

make_plots <- function(
    file,
    elec = c("F3", "Fz", "F4", "C3", "Cz", "C4", "P3", "Pz", "P4"),
    predictor = "Intercept"
) {
    # make dirs
    system(paste0("mkdir ../plots/", file))
    system(paste0("mkdir ../plots/", file, "/Waveforms"))
    # system(paste0("mkdir ../plots/", file, "/Topos"))

    # MODELS
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)

    # model_labs <- c("Intercept", "N400", "Segment")
    # model_vals <- c("black", "#E349F6", "#00FFFF")
    model_labs <- c("N400", "Segment")
    model_vals <- c("#E349F6", "#00FFFF")

    # Models: coefficent
    coef <- mod[(Type == "Coefficient") & (Spec != "Intercept"), ]
    coef$Condition <- coef$Spec
    print(unique(coef$Condition))
    plot_single_elec(coef, "Cz",
        file = paste0("../plots/", file, "/Waveforms/Coefficients_Cz.pdf"),
        modus = "Coefficient", ylims = c(20, -30),
        leg_labs = model_labs, leg_vals = model_vals)

    # Models: t-value
    # time_windows <- list(c(250, 400), c(600, 1000))
    # tval <- mod[Type == "t-value" & Spec != "Intercept", ]
    # sig <- mod[Type == "p-value" & Spec != "Intercept", ]
    # colnames(sig) <- gsub("_CI", "_sig", colnames(sig))

    # sig_corr <- bh_apply_wide(sig, elec, alpha=0.05, tws=time_windows)
    # sigcols <- grepl("_sig", colnames(sig_corr))
    # tval <- cbind(tval, sig_corr[,..sigcols])
    # mod$Spec <- factor(mod$Spec, levels = predictor)
    # tval$Condition <- tval$Spec

    # plot_nine_elec(tval, elec,
    #     file = paste0("../plots/", file, "/Waveforms/t-values.pdf"),
    #     modus = "t-value", ylims = c(7, -5), tws = time_windows,
    #     leg_labs = model_labs[2:length(model_vals)],
    #     leg_vals = model_vals[2:length(model_vals)])

    ## DATA
    eeg <- fread(paste0("../data/", file, "_data.csv"))
    eeg$Quantile <- factor(eeg$Condition)
    data_labs <- c(1, 2, 3, 4)
    # data_vals <- c("blue", "red", "orange", "black")
    data_vals <- c("blue", "black", "orange")

    # Estimates
    obs <- eeg[Type == "EEG", ]

    plot_single_elec(obs, elec,
        file = paste0("../plots/", file,  "/Waveforms/Observed.pdf"),
        modus = "Quantile", ylims = c(30, -30),
        leg_labs = data_labs, leg_vals = data_vals)

    # Estimated
    est <- eeg[Type == "est",]
    pred <- c("1", "1 + N400", "1 + Segment", "1 + N400 + Segment")
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        spec <- unique(est_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(est_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Estimated_",
                  name, ".pdf"), modus = "Quantile", ylims = c(30, -30),
                  leg_labs = data_labs, leg_vals = data_vals)
    }

    # Residual
    res <- eeg[Type == "res", ]
    pred <- c("1", "1 + N400", "1 + Segment", "1 + N400 + Segment")
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec <- unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(res_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Residual_",
                  name, ".pdf"), title = paste0("Residual Cz: ", pred[i]),
                modus = "Quantile", ylims = c(25, -30),
                  leg_labs = data_labs, leg_vals = data_vals)
    }
}

# make_plots("ERP_Design1_N400_C", c("Cz"),
#     predictor = c("Intercept", "CzN400"))

# make_plots("ERP_Design1_Segment_C", c("Cz"),
#     predictor = c("Intercept", "CzSegment"))

# make_plots("ERP_Design1_N400Segment_C", c("Cz"),
#     predictor = c("Intercept", "CzN400", "CzSegment"))

# make_plots("ERP_Design1_N400Segment_A", c("Cz"),
#     predictor = c("Intercept", "CzN400", "CzSegment"))

make_plots("ERP_Design2_N400Segment_A", c("Cz"),
    predictor = c("Intercept", "CzN400", "CzSegment"))

make_plots("ERP_Design2_N400Segment_B", c("Cz"),
    predictor = c("Intercept", "CzN400", "CzSegment"))

make_plots("ERP_Design2_N400Segment_C", c("Cz"),
    predictor = c("Intercept", "CzN400", "CzSegment"))