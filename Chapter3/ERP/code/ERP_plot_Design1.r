##
# Christoph Aurnhamer <aurnhammer@coli.uni-saarland.de>
# Plot (lmer)ERP results for ERP data of Design 1
##

### SESSION PREPARATION
# load plotting functions into workspace
system("mkdir -p ../plots")
source("../../../code/plot_lmerERP.r")
source("../../../code/benjamini-hochberg.r")
source("../../../code/plot_rERP.r")

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
                     title = "Coefficients",
                     yunit = "Intercept + coefficient",
                     subject_avg = subject_avg,
                     ci = ci,
                     ylims = ylims,
                     grouping = "Coefficient",
                     leg_labs,
                     leg_vals)
    } else if (mode == "zval") {
        zval_cols <- colnames(data)[grep("zval", colnames(data))]
        sig_cols <- colnames(data)[grep("sig", colnames(data))]
        zval_cols <- setdiff(zval_cols, "zval_1")
        sig_cols <- setdiff(sig_cols, "sig_pval_1")
        cols <- c("Condition", "Item", "Subject", "Timestamp", "TrialNum",
                  "Electrode", zval_cols, sig_cols)
        data <- data[,..cols]
        data1 <- melt(data,
                        id.vars = c("Condition", "Item", "Subject",
                                    "Timestamp", "TrialNum", "Electrode"),
                        measure.vars = zval_cols,
                        variable.name = "zvalue",
                        value.name = "zval")
        data1$sig <- melt(data,
                        id.vars = c("Condition", "Item", "Subject",
                                    "Timestamp", "TrialNum", "Electrode"),
                        measure.vars = sig_cols,
                        variable.name = "signif",
                        value.name = "sig")$sig
        data1 <- dcast(data1,
                        formula = Condition + Item + Subject + Timestamp +
                                  TrialNum + zvalue ~ Electrode,
                        value.var = c("zval", "sig"))
        plot_midline(data = data1,
                     file = paste0(name, "/zvalues.pdf"),
                     title = "Z-values",
                     yunit = "Z-value",
                     subject_avg = FALSE,
                     ci = FALSE,
                     ylims = ylims,
                     grouping = "zvalue",
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
                     yunit = yunit,
                     subject_avg = subject_avg,
                     ci = ci,
                     ylims = ylims,
                     grouping = "logCloze",
                     leg_labs,
                     leg_vals)
    } else {
        data <- data[,c("Condition", "Item", "Subject", "Timestamp",
                        "TrialNum", "Electrode", ..var)]
        data <- dcast(data,
                    formula = Condition + Item + Subject + Timestamp +
                              TrialNum ~ Electrode,
                    value.var = var)
        plot_midline(data = data,
                     file = paste0(name, "/", var, ".pdf"),
                     title = title,
                     yunit = yunit,
                     subject_avg = subject_avg,
                     ci = ci,
                     ylims = ylims,
                     grouping = "Condition",
                     leg_labs = leg_labs,
                     leg_vals = leg_vals)
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

    # Observed data
    lmerERPplot(lmerERP,
                "EEG",
                yunit = "Amplitude (μVolt)",
                title = "Observed ERPs",
                ylims = c(9, -7),
                ci = TRUE,
                leg_labs = data_labs,
                leg_vals = data_vals,
                name = name)

    if (length(model_labs) == 3) {
        preds <- c("Intercept", "Intercept + logCloze",
                    "Intercept + Noun Association",
                    "Intercept + logCloze + Noun Association")
    } else {
        preds <- c("Intercept", paste0("Intercept + ", model_labs[2]))
    }

    # Estimated Waveforms
    estimates <- colnames(lmerERP)[which(grepl("est_", colnames(lmerERP)))]
    i <- 1
    for (x in estimates) {
        lmerERPplot(lmerERP,
                    x,
                    yunit = "Amplitude (μVolt)",
                    title = paste("Estimates:", preds[i]),
                    ylims = c(9, -7),
                    ci = TRUE,
                    leg_labs = data_labs,
                    leg_vals = data_vals,
                    name = name)
        i <- i + 1
    }

    # Residuals
    residuals <- colnames(lmerERP)[which(grepl("res_", colnames(lmerERP)))]
    i <- 1
    for (x in residuals) {
        lmerERPplot(lmerERP,
                    x,
                    yunit = "Amplitude (μVolt)",
                    title = paste("Residuals:", preds[i]),
                    ci = TRUE,
                    ylims = c(4.5, -4.5),
                    leg_labs = data_labs,
                    leg_vals = data_vals,
                    name = name)
        i <- i + 1
    }

    # Coefficients
    lmerERPplot(lmerERP,
                mode = "coef",
                ci = FALSE,
                subject_avg = FALSE,
                ylims = c(8, -6),
                leg_labs = model_labs,
                leg_vals = model_vals,
                name = name)

    # Apply multiple comparisons correction
    lmerERP <- bh_apply(lmerERP,
                        alpha = 0.05,
                        time_windows = list(c(350, 450), c(600, 800)))
    # Z-values
    lmerERPplot(lmerERP,
                mode = "zval",
                ylims = c(9.5, -9.5),
                leg_labs = model_labs[2:length(model_labs)],
                leg_vals = model_vals[2:length(model_labs)],
                name = name)

    # Condition A estimates
    if (path == "../data/lmerERP_A_logCloze.csv") {
        data_labs <- c("Maximum", "Average", "1 SD", "Minimum")
        data_vals <- c("#ff0000", "#000000", "#E349F6", "#495cf6")
        lmerERPplot(lmerERP,
                    mode = "A_estimates",
                    ci = TRUE,
                    subject_avg = TRUE,
                    yunit = "Amplitude (μVolt)",
                    title = "Estimated ERPs: Log(Cloze) Levels",
                    ylims = c(8, -6),
                    leg_labs = data_labs,
                    leg_vals = data_vals,
                    name = name)
    }
}

make_grid_plot <- function(
    path,
    data_labs,
    data_vals
) {
    system(paste0("mkdir -p ../plots/", path))

    elec_all <- c("Fp1", "Fp2", "F7", "F3", "Fz", "F4", "F8", "FC5",
                "FC1", "FC2", "FC6", "C3", "Cz", "C4", "CP5", "CP1",
                "CP2", "CP6", "P7", "P3", "Pz", "P4", "P8", "O1", "Oz", "O2")

    eeg <- fread(paste0("../data/", path, "_data.csv"))
    eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(2, 1, 3, 4),
                     c("B", "A", "C", "D")), levels = c("A", "B", "C", "D"))
    obs <- eeg[Type == "EEG", ]

    plot_full_elec(
        data = obs, 
        e = elec_all, 
        file = paste0("../plots/", path, "/Observed_Full.pdf"),
        title = "Observed",
        modus = "Condition",
        ci = FALSE,
        ylims = c(9, -5.5),
        leg_labs = data_labs,
        leg_vals = data_vals)
}

produce_lmer_plots(
    "../data/lmerERP_AC_Cloze.csv",
    c("A: A+E+", "C: A+E-"),
    c("#000000", "#004488"),
    c("Intercept", "Cloze"),
    c("#000000", "#E349F6")
)

produce_lmer_plots(
    "../data/lmerERP_AC_logCloze.csv",
    c("A: A+E+", "C: A+E-"),
    c("#000000", "#004488"),
    c("Intercept", "log(Cloze)"),
    c("#000000", "#E349F6")
)

produce_lmer_plots(
    "../data/lmerERP_CD_AssocNoun.csv",
    c("C: A+E-", "D: A-E-"),
    c("#004488", "#DDAA33"),
    c("Intercept", "Noun Association"),
    c("#000000", "#00FFFF")
)

produce_lmer_plots(
    "../data/lmerERP_CD_AssocVerb.csv",
    c("C: A+E-", "D: A-E-"),
    c("#004488", "#DDAA33"),
    c("Intercept", "Verb Association"),
    c("#000000", "#00FFFF")
)

produce_lmer_plots(
    "../data/lmerERP_logCloze_AssocNoun.csv",
    c("A: A+E+", "B: A-E+", "C: A+E-", "D: A-E-"),
    c("#000000", "#BB5566", "#004488", "#DDAA33"),
    c("Intercept", "log(Cloze)", "Noun Association"),
    c("#000000", "#E349F6", "#00FFFF")
)

produce_lmer_plots(
    "../data/lmerERP_A_logCloze.csv",
    c("A: A+E+"),
    c("#000000"),
    c("Intercept", "log(Cloze)"),
    c("#000000", "#E349F6")
)

make_grid_plot("ERP_Design1_rERP",
    data_labs = c("A: A+E+", "B: A-E+", "C: A+E-", "D: A-E-"),
    data_vals = c("#000000", "#BB5566", "#004488", "#DDAA33")
)
