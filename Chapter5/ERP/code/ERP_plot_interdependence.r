source("../../../code/plot_rERP.r")

make_plots <- function(
    file,
    elec = c("Fz", "Pz", "Pz"),
    predictor = "Intercept",
    data_set = "",
    cond_name,
    data_labs,
    data_vals
) {
    # make dirs
    system(paste0("mkdir -p ../plots/", file))

    # MODELS
    model_labs <- c("Intercept", "N400", "Segment")
    model_vals <- c("black", "#E349F6", "#00FFFF")
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- gsub("Fz", "", mod$Spec)
    mod$Spec <- factor(mod$Spec, levels = predictor)

    # Models: coefficent
    coef <- mod[(Type == "Coefficient"), ]
    coef$Condition <- coef$Spec
    omitlgnd <- ifelse(file == "rERP_N400Segment_AC", FALSE, TRUE)
    plot_single_elec(
        data = coef,
        e = "Pz",
        file = paste0("../plots/", file, "/Coefficients_Pz.pdf"),
        title = paste("rERP coefficients.", cond_name),
        modus = "Coefficient",
        ylims = c(15, -23.5),
        leg_labs = model_labs,
        leg_vals = model_vals,
        omit_legend = omitlgnd,
        save_legend = TRUE)
    plot_midline(
        coef,
        elec,
        file = paste0("../plots/", file, "/Coefficients_Midline.pdf"),
        title = paste("rERP coefficients.", cond_name),
        modus = "Coefficient",
        ylims = c(15, -23.5),
        leg_labs = model_labs,
        leg_vals = model_vals)

    ## DATA
    # Observed
    eeg <- fread(paste0("../data/", file, "_data.csv"))
    eeg$Condition <- factor(plyr::mapvalues(eeg$Condition,
        c(1:length(unique(eeg$Condition))),
        data_labs), levels = data_labs)
    obs <- eeg[Type == "EEG", ]
    plot_single_elec(
        data = obs,
        e = "Pz",
        file = paste0("../plots/", file,  "/Observed.pdf"),
        modus = "Condition",
        ylims = c(9, -5),
        leg_labs = data_labs,
        leg_vals = data_vals,
        omit_legend = FALSE,
        save_legend = TRUE)
    plot_midline(
        obs,
        elec,
        file = paste0("../plots/", file,  "/Observed_Midline.pdf"),
        modus = "Condition",
        ylims = c(9, -5),
        leg_labs = data_labs,
        leg_vals = data_vals)

    # Estimates
    est <- eeg[Type == "est", ]
    pred <- c("ŷ = β0 + β1 * 0 + β2 * 0",
              "ŷ = β0 + β1 * N400 + β2 * 0",
              "ŷ = β0 + β1 * 0 + β2 * Segment",
              "ŷ = β0 + β1 * N400 + β2 * Segment")
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        spec <- unique(est_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(
            data = est_set,
            e = "Pz",
            file = paste0("../plots/", file, "/Estimated_", name, ".pdf"),
            title = paste0("Estimates ", pred[i]),
            modus = "Condition",
            ylims = c(9, -5),
            leg_labs = data_labs,
            leg_vals = data_vals,
            omit_legend = TRUE,
            save_legend = FALSE)
        plot_midline(
            est_set,
            elec,
            file = paste0("../plots/", file, "/Estimated_",
                name, "_Midline.pdf"),
            title = paste0("Estimates ", pred[i]),
            modus = "Condition",
            ylims = c(9, -5),
            leg_labs = data_labs,
            leg_vals = data_vals,
            ci = TRUE)

        if (i == 2) {
        plot_single_elec(
            data = est_set,
            e = "Pz",
            file = paste0("../plots/", file, "/Estimated_", name,
                            "_withlegend.pdf"),
            title = paste0("Estimates ", pred[i]),
            modus = "Condition",
            ylims = c(9, -5),
            leg_labs = data_labs,
            leg_vals = data_vals,
            omit_legend = FALSE,
            save_legend = FALSE)
        }
    }

    # Residual
    res <- eeg[Type == "res", ]
    pred <- rep("y - ŷ", 4)
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec <- unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_single_elec(
            data = res_set,
            e = "Pz",
            file = paste0("../plots/", file, "/Residual_", name, ".pdf"),
            title = paste0("Residuals ", pred[i]),
            modus = "Condition",
            ylims = c(4, -4),
            leg_labs = data_labs,
            leg_vals = data_vals,
            omit_legend = TRUE,
            save_legend = FALSE)
        plot_midline(
            res_set,
            elec,
            file = paste0("../plots/", file, "/Residual_",
                name, "_Midline.pdf"),
            title = paste0("Residuals ", pred[i]),
            modus = "Condition",
            ylims = c(4, -4),
            leg_labs = data_labs,
            leg_vals = data_vals,
            ci = TRUE)
    }
}

make_plots(paste0("rERP_N400Segment_AC"), c("Fz", "Cz", "Pz"),
    predictor = c("Intercept", "N400", "Segment"),
    cond_name = "Expected & Unexpected.",
    data_labs = c("A: Expected", "C: Unexpected"),
    data_vals = c("#000000", "#004488"))
make_plots(paste0("rERP_N400Segment_A"), c("Fz", "Cz", "Pz"),
    predictor = c("Intercept", "N400", "Segment"),
    cond_name = "Expected.",
    data_labs = c("A: Expected"),
    data_vals = c("#000000"))
make_plots(paste0("rERP_N400Segment_C"), c("Fz", "Cz", "Pz"),
    predictor = c("Intercept", "N400", "Segment"),
    cond_name = "Unexpected.",
    data_labs = c("A: Unexpected"),
    data_vals = c("#004488"))

make_plots(paste0("rERP_dbc19_N400Segment_A"), c("Fz", "Cz", "Pz"),
    predictor = c("Intercept", "N400", "Segment"),
    data_set = "dbc", cond_name = "Baseline.",
    data_labs = c("Baseline"),
    data_vals = c("#000000"))
make_plots(paste0("rERP_dbc19_N400Segment_B"), c("Fz", "Cz", "Pz"),
    predictor = c("Intercept", "N400", "Segment"),
    data_set = "dbc", cond_name = "Event-related.",
    data_labs = c("Event-rel."),
    data_vals = c("#FF0000"))
make_plots(paste0("rERP_dbc19_N400Segment_C"), c("Fz", "Cz", "Pz"),
    predictor = c("Intercept", "N400", "Segment"),
    data_set = "dbc", cond_name = "Event-unrelated.",
    data_labs = c("Event-unrel."),
    data_vals = c("#0000FF"))