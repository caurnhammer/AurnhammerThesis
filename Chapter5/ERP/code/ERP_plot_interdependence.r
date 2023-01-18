source("../../../code/plot_rERP.r")
source("../../../code/benjamini-hochberg.r")

make_plots <- function(
    file,
    elec = c("F3", "Fz", "F4", "C3", "Pz", "C4", "P3", "Pz", "P4"),
    predictor = "Intercept"
) {
    # make dirs
    system(paste0("mkdir ../plots/", file))
    system(paste0("mkdir ../plots/", file, "/Waveforms"))
    # system(paste0("mkdir ../plots/", file, "/Topos"))

    # MODELS
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)

    model_labs <- c("Intercept", "N400", "Segment")
    model_vals <- c("black", "#E349F6", "#00FFFF")

    # Models: coefficent
    coef <- mod[(Type == "Coefficient"), ]
    coef$Condition <- coef$Spec
    print(unique(coef$Condition))
    plot_single_elec(coef, "Pz",
        file = paste0("../plots/", file, "/Waveforms/Coefficients_Pz.pdf"),
        title = "rERP coefficients. Condition C",
        modus = "Coefficient", ylims = c(15, -23.5),
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
    # eeg$Quantile <- factor(eeg$Condition)
    # data_labs <- c(1, 2, 3, 4)
    # data_vals <- c("blue", "red", "orange", "black")
    # data_vals <- c("blue", "black", "orange")
    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(2, 1, 3, 4),
    #     c("B", "A", "C", "D")), levels = c("A", "B", "C", "D"))
    # data_labs <- c("A", "B", "C", "D")
    # data_vals <- c("#000000", "#BB5566", "#004488", "#DDAA33")

    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2),
    #     c("A", "C")), levels = c("A", "C"))
    # data_labs <- c("A: Expected", "C: Unexpected")
    # data_vals <- c("#000000", "#004488")
    
    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2, 3),
    #     c("baseline", "event-related", "event-unrelated")),
    #     levels = c("baseline", "event-related", "event-unrelated"))
    # data_labs <- c("baseline", "event-related", "event-unrelated")
    # data_vals <- c("#000000", "red", "blue")

    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2),
    #     c("baseline", "event-related")),
    #     levels = c("baseline", "event-related"))
    # data_labs <- c("baseline", "event-related")
    # data_vals <- c("#000000", "red")

    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2),
    #     c("baseline", "event-unrelated")),
    #     levels = c("baseline", "event-unrelated"))
    # data_labs <- c("baseline", "event-unrelated")
    # data_vals <- c("#000000", "blue")

    eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1),
        c("baseline")),
        levels = c("baseline"))
    data_labs <- c("baseline")
    data_vals <- c("#000000")

    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2, 3),
    #     c("A", "B", "C")),
    #     levels = c("A", "B", "C"))
    # data_labs <- c("A", "B", "C")
    # data_vals <- c("#000000", "red", "blue")

    # Estimates
    obs <- eeg[Type == "EEG", ]

    plot_single_elec(obs, elec,
        file = paste0("../plots/", file,  "/Waveforms/Observed.pdf"),
        modus = "Condition", ylims = c(10, -5),
        leg_labs = data_labs, leg_vals = data_vals)

    # Estimated
    est <- eeg[Type == "est",]
    pred <- c("ŷ = b0 + b1 * 0 + b2 * 0", "ŷ = b0 + b1 * N400 + b2 * 0",
        "ŷ = b0 + b1 * 0 + b2 * Segment", "ŷ = b0 + b1 * N400 + b2 * Segment")
    # pred <- c("1", "1 + Time Window", "1 + Segment", "1 + Time Window + Segment")
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        spec <- unique(est_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(est_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Estimated_",
                  name, ".pdf"), title = paste0("Estimates ", pred[i]),
                  modus = "Condition", ylims = c(10, -5),
                  leg_labs = data_labs, leg_vals = data_vals, ci = TRUE)
    }

    # Residual
    res <- eeg[Type == "res", ]
    pred <- c("ŷ = b0 + b1 * 0 + b2 * 0", "ŷ = b0 + b1 * N400 + b2 * 0",
        "ŷ = b0 + b1 * 0 + b2 * Segment", "ŷ = b0 + b1 * N400 + b2 * Segment")
    pred <- rep("y - ŷ", 4)
    # pred <- c("1", "1 + Time Window", "1 + Segment", "1 + Time Window + Segment")
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec <- unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(res_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Residual_",
                  name, ".pdf"), title = paste0("Residuals ", pred[i]),
                  modus = "Condition", ylims = c(4, -4),
                  leg_labs = data_labs, leg_vals = data_vals, ci = TRUE)
    }
}

make_plots(paste0("ERP_Design1_N400Segment_AC"), c("Pz"),
    predictor = c("Intercept", "PzN400", "PzSegment"))

make_plots(paste0("ERP_dbc19_N400Segment_AB"), c("Pz"),
    predictor = c("Intercept", "PzN400", "PzSegment"))

make_plots(paste0("ERP_dbc19_N400Segment_AC"), c("Pz"),
    predictor = c("Intercept", "PzN400", "PzSegment"))


make_plots(paste0("ERP_dbc19_N400Segment_A"), c("Pz"),
    predictor = c("Intercept", "PzN400", "PzSegment"))

make_plots(paste0("ERP_dbc19_N400Segment_B"), c("Pz"),
    predictor = c("Intercept", "PzN400", "PzSegment"))

make_plots(paste0("ERP_dbc19_N400Segment_C"), c("Pz"),
    predictor = c("Intercept", "PzN400", "PzSegment"))
