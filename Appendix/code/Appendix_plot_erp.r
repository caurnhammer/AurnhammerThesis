source("../../code/plot_rERP.r")
source("../../code/benjamini-hochberg.r")
source("../../code/plot_lmerERP.r")

make_plots <- function(
    file,
    elec = c("F3", "Fz", "F4", "C3", "Cz", "C4", "P3", "Pz", "P4"),
    predictor = "Intercept",
    inferential = FALSE,
    design,
    model_labs
) {
    # make dirs
    system(paste0("mkdir -p ../plots/", file))
    system(paste0("mkdir -p ../plots/", file, "/Waveforms"))
    system(paste0("mkdir -p ../plots/", file, "/Topos"))

    elec_nine <- c("F3", "Fz", "F4", "C3", "Cz", "C4", "P3", "Pz", "P4")

    if (grepl("across", file)) {
        ci = FALSE
    } else {
        ci = TRUE
    }

    ##########
    # MODELS #
    ##########
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)

    # Models: coefficent
    coef <- mod[Type == "Coefficient", ]
    coef$Condition <- coef$Spec
    model_vals <- c("black", "#E349F6", "#00FFFF")

    plot_single_elec(
        data = coef,
        e = c("Pz"),
        file = paste0("../plots/", file, "/Waveforms/Coefficients.pdf"),
        title = "Coefficients",
        modus = "Coefficient",
        ylims = c(9, -5.5),
        leg_labs = model_labs,
        leg_vals = model_vals)

    plot_full_elec(
        data = coef,
        e = elec,
        file = paste0("../plots/",
        file,
        "/Waveforms/Coefficients_Full.pdf"),
        title = "Coefficients",
        modus = "Coefficient",
        ylims = c(7, -5),
        leg_labs = model_labs,
        leg_vals = model_vals)

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
        plot_nine_elec(
            data = tval, 
            e = elec_nine,
            file = paste0("../plots/", file, "/Waveforms/t-values.pdf"),
            title = "Inferential Statistics",
            modus = "t-value",
            ylims = c(8, -9),
            tws = time_windows,
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
        data_labs <- c("A: A+E+", "C: A+E-")
        data_vals <- c("black", "#004488")
    } else if (design == "Design1") {
        eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(2, 1, 3, 4),
                     c("B", "A", "C", "D")), levels = c("A", "B", "C", "D"))
        data_labs <- c("A: A+E+", "B: A-E+", "C: A+E-", "D: A-E-")
        data_vals <- c("#000000", "#BB5566", "#004488", "#DDAA33")
    } else if (design == "Design2") {
        eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(2, 1, 3),
                        c("B", "A", "C")), levels = c("A", "B", "C"))
        data_labs <- c("A: Plausible",
                       "B: Less plausible, attraction",
                       "C: Implausible, no attraction")
        data_vals <- c("#000000", "red", "blue")
    }

    # Data: Observed
    obs <- eeg[Type == "EEG", ]

    plot_single_elec(
        data = obs,
        e = c("Pz"),
        file = paste0("../plots/", file,  "/Waveforms/Observed.pdf"),
        title = "Observed",
        ylims = c(9, -5.5),
        modus = "Condition",
        ci = ci,
        leg_labs = data_labs,
        leg_vals = data_vals,
        omit_legend = TRUE,
        save_legend = TRUE)
    plot_full_elec(
        data = obs, 
        e = elec_all, 
        file = paste0("../plots/", file, "/Waveforms/Observed_Full.pdf"),
        title = "Observed",
        modus = "Condition",
        ci = ci,
        ylims = c(9, -5.5),
        leg_labs = data_labs,
        leg_vals = data_vals)

    if (design == "Design1_AC") {
        plot_topo(
            data = obs, 
            file = paste0("../plots/", file, "/Topos/Observed"),
            tw = c(300, 500),
            cond_man = "C",
            cond_base = "A",
            omit_legend = TRUE,
            save_legend = TRUE)
    } else if (design == "Design2") {
        plot_topo(
            data = obs,
            file = paste0("../plots/", file, "/Topos/Observed"),
            tw = c(600, 1000),
            cond_man = "B",
            cond_base = "A",
            omit_legend = TRUE,
            save_legend = TRUE)
    }

    # Data: Estimated
    if (design == "Design1_AC_log") {
        combo <- c("Intercept", "Intercept + logCloze",
                   "Intercept + Noun Association",
                   "Intercept + logCloze + Noun Association")
    } else {
        combo <- c("Intercept", "Intercept + Cloze",
                   "Intercept + Noun Association",
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
        if (design == "Design1") {
            plot_single_elec(
                data = est_set,
                e = c("Pz"),
                file = paste0("../plots/", file, 
                        "/Waveforms/Estimated_", name, ".pdf"),
                title = paste("Estimates", combo[i]),
                modus = "Condition",
                ci = ci,
                ylims = c(9, -5.5),
                leg_labs = data_labs,
                leg_vals = data_vals,
                omit_legend = TRUE,
                save_legend = FALSE)
        } else {
            plot_single_elec(
                data = est_set,
                e = c("Pz"),
                file = paste0("../plots/", file, 
                        "/Waveforms/Estimated_", name, ".pdf"),
                title = paste("Estimates", combo[i]),
                modus = "Condition",
                ci = ci,
                ylims = c(9, -5.5),
                leg_labs = data_labs,
                leg_vals = data_vals)
        }
        if (design == "Design2") {
            plot_topo(
                data = est_set,
                file = paste0("../plots/", file, "/Topos/Estimated_", name),
                tw = c(600, 1000),
                cond_man = "B",
                cond_base = "A",
                add_title = paste("\nEstimate", pred[i]),
                omit_legend = TRUE)
        }
    }

    # Data: Residual
    res <- eeg[Type == "res", ]
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec <- unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        if (design == "Design1") {
            plot_single_elec(
                data = res_set,
                e = c("Pz"),
                file = paste0("../plots/", file,
                        "/Waveforms/Residual_", name, ".pdf"),
                title = paste("Residuals", combo[i]),
                modus = "Condition",
                ci = ci,
                ylims = c(3.5, -3.5),
                leg_labs = data_labs,
                leg_vals = data_vals,
                omit_legend = TRUE,
                save_legend = FALSE)
        } else {
            plot_single_elec(
                data = res_set,
                e = c("Pz"),
                file = paste0("../plots/", file,
                        "/Waveforms/Residual_", name, ".pdf"),
                title = paste("Residuals", combo[i]),
                modus = "Condition",
                ci = ci,
                ylims = c(3.5, -3.5),
                leg_labs = data_labs,
                leg_vals = data_vals)
        }
        if (design == "Design2") {
            plot_topo(
                data = res_set,
                file = paste0("../plots/", file, "/Topos/Residual_", name),
                tw = c(600, 1000),
                cond_man = "B",
                cond_base = "A",
                add_title = paste("\nResidual", pred[i]), 
                omit_legend = TRUE)
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

    ggsave(p, filename = "../Figures/App/Stimuli_zscore.pdf",
            device = cairo_pdf, width = 3, height = 3)
    p
}

# produce single midline plot.
lmerERPplot <- function(
    data,
    var = NULL,
    yunit = "",
    title = "",
    ylims = NULL,
    subject_avg = TRUE,
    ci = TRUE,
    mode = "",
    leg_labs,
    leg_vals,
    name
) {
    if (mode == "coef") {
        coefs_cols <- colnames(data)[grep("coef", colnames(data))]
        se_cols <- colnames(data)[grep("SE_", colnames(data))]
        cols <- c("Condition", "Item", "Subject", "Timestamp", "TrialNum",
                  "Electrode", coefs_cols, se_cols)
        data <- data[,..cols]
        data1 <- melt(data, id.vars = c("Condition", "Item", "Subject",
                      "Timestamp", "TrialNum", "Electrode"),
                      measure.vars = coefs_cols,
                      variable.name = "Coefficient",
                      value.name = "coefval")
        data1$seval <- melt(data, id.vars = c("Condition", "Item", "Subject",
                        "Timestamp", "TrialNum", "Electrode"),
                        measure.vars = se_cols,
                        variable.name = "SE",
                        value.name = "seval")$seval
        data1 <- dcast(data1,
                        formula = Condition + Item + Subject + Timestamp +
                                  TrialNum + Coefficient ~ Electrode,
                        value.var = c("coefval", "seval"))
        plot_midline(data = data1,
                     file = paste0(name, "/coefficients.pdf"),
                     title = "lmerERP Coefficients",
                     yunit = "Intercept + coefficient",
                     subject_avg = subject_avg,
                     ci = ci,
                     ylims = ylims,
                     grouping = "Coefficient",
                     leg_labs,
                     leg_vals)
    } else if (mode == "A_estimates") {
        logCloze_range <- range(data$z_logCloze)
        data <- data[, lapply(.SD, mean),
                by = list(Timestamp, Electrode, Subject),
                .SDcols = c("1", "logCloze",
                            "s_1", "s_logCloze",
                            "i_1", "i_logCloze")]

        data$est_max <- (data$"1" + data$i_1 + data$s_1) +
                        (data$logCloze + data$s_logCloze + data$i_logCloze) *
                            logCloze_range[[1]]
        data$est_avg <- (data$"1" + data$i_1 + data$s_1) +
                        (data$logCloze + data$s_logCloze + data$i_logCloze) * 0
        data$est_1SD <- (data$"1" + data$i_1 + data$s_1) +
                        (data$logCloze + data$s_logCloze + data$i_logCloze) * 1
        data$est_min <- (data$"1" + data$i_1 + data$s_1) +
                        (data$logCloze + data$s_logCloze + data$i_logCloze) *
                            logCloze_range[[2]]

        est_cols <- colnames(data)[grep("est_", colnames(data))]
        data_m <- melt(data,
                        id.vars = c("Timestamp", "Electrode", "Subject"),
                        measure.vars = est_cols,
                        variable.name = "logCloze",
                        value.name = "estimates")
        data_c <- dcast(data_m,
                        formula = Timestamp + logCloze + Subject ~ Electrode,
                        value.var = "estimates")
        plot_midline(data = data_c,
                     file = paste0(name, "/A_estimates.pdf"),
                     title = title,
                     yunit = "Amplitude ( \U00B5 Volt)",
                     subject_avg = subject_avg,
                     ci = ci,
                     ylims = ylims,
                     grouping = "logCloze",
                     leg_labs,
                     leg_vals)
    }
}

# produce midline plot for observed, estimates, residuals,
# coefficients, z-values
produce_lmer_plots <- function(
    path,
    data_labs,
    data_vals,
    model_labs,
    model_vals
) {
    # Create output dir
    name = paste0("../plots/", substr(path, 9, nchar(path) - 4))
    system(paste("mkdir -p", name))

    # LMER ERP DATA
    lmerERP <- fread(path)

    # Coefficients
    lmerERPplot(lmerERP,
                mode = "coef",
                ci = FALSE,
                subject_avg = FALSE,
                ylims = c(8, -6),
                leg_labs = model_labs,
                leg_vals = model_vals,
                name = name)

    # Condition A estimates
    lmerERPplot(lmerERP,
        mode = "A_estimates",
        ci = TRUE,
        subject_avg = TRUE,
        ylims = c(8, -6),
        title = "Estimated ERPs: Log(Cloze) Levels",
        leg_labs = data_labs,
        leg_vals = data_vals,
        name = name)
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
    inferential = TRUE, model_labs = c("Intercept", "Cloze"))

make_plots("ERP_Design1_AC_logCloze_rERP", elec_all,
    predictor = c("Intercept", "logCloze"), design = "Design1_AC_log",
    model_labs = c("Intercept", "logCloze"))

make_plots("ERP_Design1_Cloze_AssocNoun_rERP", elec_all,
    predictor = c("Intercept", "Cloze", "Association_Noun"), design = "Design1",
    model_labs = c("Intercept", "Cloze", "Noun Association"))

make_plots("ERP_Design1_Cloze_AssocNoun_across_rERP", elec_all,
    predictor = c("Intercept", "Cloze", "Association_Noun"),
    inferential = TRUE, design = "Design1",
    model_labs = c("Intercept", "Cloze", "Noun Association"))

make_plots("ERP_Design2_Plaus_Clozedist_rERP", elec_all,
    predictor = c("Intercept", "Plaus", "Cloze_distractor"), design = "Design2",
    model_labs = c("Intercept", "Plausibility", "Distractor Cloze"))

produce_lmer_plots(
    "../data/lmerERP_A_logCloze.csv",
    c("Maximum", "Average", "1 SD", "Minimum"),
    c("#ff0000", "#000000", "#E349F6", "#495cf6"),
    c("Intercept", "log(Cloze)"),
    c("#000000", "#E349F6")
)