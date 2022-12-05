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

    # model_labs <- c("Intercept", "TimeWindow", "Segment")
    # model_vals <- c("black", "#E349F6", "#00FFFF")
    # model_labs <- c("Intercept", "N4minP6")
    # model_vals <- c("black", "#E349F6")
    # model_labs <- c("Intercept", "N400", "P600")
    # model_vals <- c("black", "#E349F6", "#00FFFF")
    # model_labs <- c("Intercept", "Segment")
    # model_vals <- c("black", "#00FFFF")
    # model_labs <- c("Intercept", "N400A", "N400B", "N400C", "Segment")
    # model_vals <- c("black", "pink", "#E349F6", "purple", "#00FFFF")
    model_labs <- c("Intercept", "N400", "Segment")
    model_vals <- c("black", "#E349F6", "#00FFFF")

    # Models: coefficent
    coef <- mod[(Type == "Coefficient"), ]
    coef$Condition <- coef$Spec
    print(unique(coef$Condition))
    plot_single_elec(coef, "Pz",
        file = paste0("../plots/", file, "/Waveforms/Coefficients_Pz.pdf"),
        title = "rERP coefficients",
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

    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2, 3),
    #     c("baseline", "event-related", "event-unrelated")),
    #     levels = c("baseline", "event-related", "event-unrelated"))
    # data_labs <- c("baseline", "event-related", "event-unrelated")
    # data_vals <- c("#000000", "red", "blue")

    eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2),
        c("event-related", "event-unrelated")),
        levels = c("event-related", "event-unrelated"))
    data_labs <- c("event-related", "event-unrelated")
    data_vals <- c("red", "blue")

    # Estimates
    obs <- eeg[Type == "EEG", ]

    plot_single_elec(obs, elec,
        file = paste0("../plots/", file,  "/Waveforms/Observed.pdf"),
        modus = "Condition", ylims = c(10, -5),
        leg_labs = data_labs, leg_vals = data_vals)

    # Estimated
    est <- eeg[Type == "est",]
    # pred <- c("1", "1 + N400", "1 + Segment", "1 + N400 + Segment")
    pred <- c("1", "1 + Time Window", "1 + Segment", "1 + Time Window + Segment")
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        spec <- unique(est_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(est_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Estimated_",
                  name, ".pdf"), modus = "Condition", ylims = c(10, -5),
                  leg_labs = data_labs, leg_vals = data_vals, ci = FALSE)
    }

    # Residual
    res <- eeg[Type == "res", ]
    # pred <- c("1", "1 + N400", "1 + Segment", "1 + N400 + Segment")
    pred <- c("1", "1 + Time Window", "1 + Segment", "1 + Time Window + Segment")
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec <- unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(res_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Residual_",
                  name, ".pdf"), title = paste0("Residual Pz: ", pred[i]),
                modus = "Condition", ylims = c(4, -4),
                  leg_labs = data_labs, leg_vals = data_vals, ci = FALSE)
    }
}

# make_plots("ERP_Design1_N400_C", c("Pz"),
#     predictor = c("Intercept", "PzN400"))

# make_plots("ERP_Design1_Segment_C", c("Pz"),
#     predictor = c("Intercept", "PzSegment"))

# make_plots("ERP_Design1_N400Segment_C", c("Pz"),
#     predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_Design1_N400Segment_A", c("Pz"),
#    predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_dbc19_N400Segment_A", c("Pz"),
#    predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_dbc19_N400Segment_B", c("Pz"),
#    predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_dbc19_N400Segment_C", c("Pz"),
#    predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_Design1_N400P600Segment_C", c("Pz"),
#    predictor = c("Intercept", "PzN400", "PzP600", "PzSegment"))

# make_plots("ERP_Design1_SegmentCloze_A", c("Pz"),
#    predictor = c("Intercept", "PzSegment", "Cloze"))

# make_plots("ERP_Design1_Segment2_A", c("Pz"),
#    predictor = c("Intercept", "PzSegment"))

# make_plots("ERP_Design1_Segment2_A", c("Pz"),
#    predictor = c("Intercept", "PzN400", "PzSegment"))


# make_plots("ERP_Design1_N400Segment_A", c("Pz"),
#     predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_Design2_N400Segment_B", c("Pz"),
#     predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_Design2_N400Segment_C", c("Pz"),
#     predictor = c("Intercept", "PzN400", "PzSegment"))

# make_plots("ERP_Design1_N400minP600Segment_A", c("Pz"),
#     predictor = c("Intercept", "PzN400minP600", "PzSegment"))
 

# make_plots("ERP_Design1_N000minP200Segment_A", c("Pz"),
#     predictor = c("Intercept", "PzN400minP600", "PzSegment"))

# make_plots("ERP_Design1_N600minP1000Segment_A", c("Pz"),
#     predictor = c("Intercept", "PzN400minP600", "PzSegment"))

# tw_length = 200
# tws = seq(-100, 1000, 100)
# for (t in tws) {
#     # make_plots(paste0("ERP_Design1_TimewindowSegment_", t, "-", t+tw_length), c("Pz"),
#     #     predictor = c("Intercept", "PzTimeWindow", "PzSegment"))
#     make_plots(paste0("ERP_Design1_TimewindowSmallSegment_", t, "-", t+tw_length), c("Pz"),
#         predictor = c("Intercept", "PzTimeWindow", "PzSegment"))
#     # make_plots(paste0("ERP_Design1_Segment_", t, "-", t+tw_length), c("Pz"),
#     #     predictor = c("Intercept", "PzSegment"))
#     # make_plots(paste0("ERP_Design1_TimeWindow_", t, "-", t+tw_length), c("Pz"),
#     #     predictor = c("Intercept", "PzTimeWindow"))
# }

# for (t in tws) {
#     make_plots(paste0("ERP_dbc19_TimeWindowSegment_", t, "-", t+tw_length), c("Pz"),
#         predictor = c("Intercept", "PzTimeWindow", "PzSegment"))
# }


# make_plots(paste0("ERP_Design1_N4minP6Segment"), c("Pz"),
#     predictor = c("Intercept", "PzTimeWindow", "PzSegment"))

# make_plots(paste0("ERP_Design1_N4minP6"), c("Pz"),
#     predictor = c("Intercept", "PzTimeWindow"))

# make_plots(paste0("ERP_Design1_N400P600"), c("Pz"),
#     predictor = c("Intercept", "PzN400", "PzP600"))

# make_plots(paste0("ERP_dbc19_N4minP6"), c("Pz"),
#     predictor = c("Intercept", "PzTimeWindow"))

# make_plots(paste0("ERP_dbc19_condN400Segment"), c("Pz"),
#     predictor = c("Intercept", "PzN400A", "PzN400B", "PzN400C", "PzSegment"))

# make_plots(paste0("ERP_dbc19_condN400"), c("Pz"),
#     predictor = c("Intercept", "PzN400A", "PzN400B", "PzN400C"))


make_plots(paste0("ERP_dbc19_N400Segment_BC"), c("Pz"),
    predictor = c("Intercept", "PzN400", "PzSegment"))
