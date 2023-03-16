source("../../code/plot_rERP.r")
source("../../code/benjamini-hochberg.r")

make_plots <- function(
    file,
    elec = c("F3", "Fz", "F4", "C3", "Cz", "C4", "P3", "Pz", "P4"),
    predictor = "Intercept",
    inferential = FALSE,
    design,
    model_labs
) {
    # make dirs
    system(paste0("mkdir ../plots/", file))
    system(paste0("mkdir ../plots/", file, "/Waveforms"))
    system(paste0("mkdir ../plots/", file, "/Topos"))

    elec_nine <- c("F3", "Fz", "F4", "C3", "Cz", "C4", "P3", "Pz", "P4")

    ##########
    # MODELS #
    ##########
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)

    # Models: coefficent
    coef <- mod[Type == "Coefficient", ]
    coef$Condition <- coef$Spec
    model_vals <- c("black", "#E349F6", "#00FFFF")

    plot_single_elec(data = coef, e = c("Pz"), 
        file = paste0("../plots/", file, "/Waveforms/Coefficients.pdf"),
        title = "Coefficients", modus = "Coefficient",
        ylims = c(10, -5), leg_labs = model_labs, leg_vals = model_vals)

    source("../../code/plot_rERP.r")
    plot_full_elec(data = coef, e = elec, file = paste0("../plots/", file,
        "/Waveforms/Coefficients_Full.pdf"),
        title = "Coefficients", modus = "Coefficient",
        ylims = c(7, -5), leg_labs = model_labs, leg_vals = model_vals)

    # Models: t-value
    if (inferential == TRUE) {
        time_windows <- list(c(300, 500), c(600, 1000))
        tval <- mod[Type == "t-value" & Spec != "Intercept", ]
        sig <- mod[Type == "p-value" & Spec != "Intercept", ]
        colnames(sig) <- gsub("_CI", "_sig", colnames(sig))

        sig_corr <- bh_apply_wide(sig, elec_nine, alpha = 0.05,
                        tws = time_windows)
        sigcols <- grepl("_sig", colnames(sig_corr))
        tval <- cbind(tval, sig_corr[, ..sigcols])
        tval$Condition <- tval$Spec
        plot_nine_elec(tval, elec_nine,
            file = paste0("../plots/", file, "/Waveforms/t-values.pdf"),
            title = "Inferential Statistics",
            modus = "t-value", ylims = c(8, -9), tws = time_windows,
            leg_labs = model_labs[2:length(model_labs)],
            leg_vals = model_vals[2:length(model_vals)])
    }

    ########
    # DATA #
    ########
    eeg <- fread(paste0("../data/", file, "_data.csv"))

    if (design %in% c("Design1_AC", "Design1_AC_log")) {
        eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2),
                        c("A", "C")), levels = c("A", "C"))
        data_labs <- c("A", "C")
        data_vals <- c("black", "#004488")
    } else if (design == "Design1") {
        eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(2, 1, 3, 4),
                     c("B", "A", "C", "D")), levels = c("A", "B", "C", "D"))
        data_labs <- c("A", "B", "C", "D")
        data_vals <- c("#000000", "#BB5566", "#004488", "#DDAA33")
    } else if (design == "Design2") {
        eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(2, 1, 3),
                        c("B", "A", "C")), levels = c("A", "B", "C"))
        data_labs <- c("A", "B", "C")
        data_vals <- c("#000000", "red", "blue")
    }

    # Data: Observed
    obs <- eeg[Type == "EEG", ]

    plot_single_elec(obs, c("Pz"),
        file = paste0("../plots/", file,  "/Waveforms/Observed.pdf"),
        title = "Observed",
        modus = "Condition", ylims = c(9, -5.5),
        leg_labs = data_labs, leg_vals = data_vals)
    plot_full_elec(data = obs, e = elec_all, file = paste0("../plots/", file,
        "/Waveforms/Observed_Full.pdf"),
        title = "Observed", modus = "Condition",
        ylims = c(9, -5.5), leg_labs = data_labs, leg_vals = data_vals)

    if (design == "Design1_AC") {
        plot_topo(obs, file = paste0("../plots/", file, "/Topos/Observed"),
                tw = c(300, 500), cond_man = "C", cond_base = "A",
                omit_legend = TRUE, save_legend = TRUE)
    } else if (design == "Design2") {
        plot_topo(obs, file = paste0("../plots/", file, "/Topos/Observed"),
                tw = c(600, 1000), cond_man = "B", cond_base = "A",
                omit_legend = TRUE, save_legend = TRUE)
    }

    # Data: Estimated
    if (design == "Design1_AC_log") {
        combo <- c("Intercept", "Intercept + logCloze", "Intercept + Noun Association",
                "Intercept + logCloze + Noun Association")
    } else {
        combo <- c("Intercept", "Intercept + Cloze", "Intercept + Noun Association",
            "Intercept + Cloze + Noun Association")
    }
    
    pred <- c("Intercept", "Tar. Plaus.", "Dist. Cloze",
              "Dist. Cloze + Tar. Plaus.")
    est <- eeg[Type == "est", ]
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        spec <- unique(est_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(est_set, c("Pz"),
            file = paste0("../plots/", file,
                "/Waveforms/Estimated_", name, ".pdf"),
            title = paste("Estimates", combo[i]),
            modus = "Condition", ylims = c(9, -5.5),
            leg_labs = data_labs, leg_vals = data_vals)
        if (design == "Design2") {
            plot_topo(est_set,
            file = paste0("../plots/", file, "/Topos/Estimated_", name),
            tw = c(600, 1000), cond_man = "B", cond_base = "A",
            add_title = paste("\nEstimate", pred[i]), omit_legend = TRUE)
        }
    }

    # Data: Residual
    res <- eeg[Type == "res", ]
    for (i in seq(1, length(unique(res$Spec)))) {
        spec = unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec = unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(res_set, c("Pz"),
                 file = paste0("../plots/", file, "/Waveforms/Residual_",
                 name, ".pdf"), title = paste("Residuals", combo[i]),
                 modus = "Condition", ylims = c(3.5, -3.5),
                 leg_labs = data_labs, leg_vals = data_vals)
        if (design == "Design2") {
            plot_topo(res_set,
                file = paste0("../plots/", file, "/Topos/Residual_", name),
                tw = c(600, 1000), cond_man = "B", cond_base = "A",
                add_title = paste("\nResidual", pred[i]), omit_legend = TRUE)
        }
    }
}

plot_zscores <- function(file, pred) {
    dt <- fread(file)
    dt <- dt[Condition %in% c("A", "C"), ]

    p <- ggplot(dt, aes(y = Cloze, x = scale(Cloze), color = Condition))
    p <- p + geom_point()
    p <- p + scale_color_manual(labels = c("A", "C"),
                values = c("black", "#004488"))
    p <- p + theme_minimal()
    p <- p + theme(legend.position = "bottom")
    p <- p + geom_vline(xintercept = mean(scale(dt$Cloze)), linetype = "dashed")
    p <- p + geom_hline(yintercept = mean(dt$Cloze), linetype = "dashed")
    p <- p + labs(x = "z-standardized Cloze", title = "Z-standardization")

    ggsave(p, filename = "../Figures/Stimuli_zscore.pdf",
            device = cairo_pdf, width = 3, height = 3)
    p
}

plot_zscores("../../data/Stimuli_Design1.csv", "Cloze")

elec_all <- c("Fp1", "Fp2", "F7", "F3", "Fz", "F4", "F8", "FC5",
                "FC1", "FC2", "FC6", "C3", "Cz", "C4", "CP5", "CP1",
                "CP2", "CP6", "P7", "P3", "Pz", "P4", "P8", "O1", "Oz", "O2")

make_plots("ERP_Design1_AC_Intercept_rERP", elec_all,
    predictor = c("Intercept"), design = "Design1_AC",
    model_labs = c("Intercept"))

make_plots("ERP_Design1_AC_CondCode_rERP", elec_all,
    predictor = c("Intercept", "CondCode"), design = "Design1_AC",
    model_labs = c("Intercept", "Condition Code"))

make_plots("ERP_Design1_AC_Cloze_rERP", elec_all,
    predictor = c("Intercept", "Cloze"), design = "Design1_AC",
    model_labs = c("Intercept", "Cloze"))

make_plots("ERP_Design1_AC_logCloze_rERP", elec_all,
    predictor = c("Intercept", "logCloze"), design = "Design1_AC_log",
    model_labs = c("Intercept", "logCloze"))

make_plots("ERP_Design1_Cloze_Assocnoun_rERP", elec_all,
    predictor = c("Intercept", "Cloze", "Assocnoun"), design = "Design1",
    model_labs = c("Intercept", "Cloze", "Noun Association"))

make_plots("ERP_Design1_Cloze_Assocnoun_across_rERP", elec_all,
    predictor = c("Intercept", "Cloze", "Assocnoun"),
    inferential = TRUE, design = "Design1",
    model_labs = c("Intercept", "Cloze", "Noun Association"))

make_plots("ERP_Design2_Plaus_Clozedist_rERP", elec_all,
    predictor = c("Intercept", "Plaus", "Cloze_distractor"), design = "Design2",
    model_labs = c("Intercept", "Plausibility", "Distractor Cloze"))