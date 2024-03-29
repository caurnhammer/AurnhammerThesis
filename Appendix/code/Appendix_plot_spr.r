source("../../code/plot_rERP.r")

make_plots <- function(
    file,
    predictor,
    inferential = FALSE,
    model_labs
) {
    # make dirs
    system(paste0("mkdir -p ../plots/", file))

    ## MODELS
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)
    mod$Region <- factor(plyr::mapvalues(mod$Timestamp, c(2, 1, 4, 3),
        c("Post-spillover", "Critical",
          "Spillover", "Pre-critical")),
        levels = c("Pre-critical", "Critical",
                    "Spillover", "Post-spillover")) 
    mod$Timestamp <- NULL
    model_vals <- c("black", "#E349F6", "#00FFFF", "#37cb8b")

    # Models: coefficent
    coef <- mod[Type == "Coefficient", ]

    plot_rSPR(
        data = coef,
        file = paste0("../plots/", file, "/Coefficients.pdf"),
        modus = "coefficients",
        yunit = "Intercept + Coefficient",
        title = "Coefficients",
        ylims = c(5.74, 5.82),
        leg_labs = model_labs,
        leg_vals = model_vals)

    # Models: t-value
    if (inferential == TRUE) {
        tval <- mod[Type == "t-value" & Spec != "Intercept", ]
        sig <- mod[Type == "p-value" & Spec != "Intercept", ]
        colnames(sig) <- gsub("logRT", "p-value", colnames(sig))
        colnames(sig) <- gsub("p-value_CI", "sig", colnames(sig))
        tval <- cbind(tval, sig[,"sig"])
        plot_rSPR(tval,
            file = paste0("../plots/", file, "/t-values.pdf"),
            yunit = "t-value", title = "Inferential Statistics",
            ylims = c(-4, 4), modus = "t-value",
            leg_labs = model_labs[2:length(model_labs)],
                    leg_vals = model_vals[2:length(model_labs)])
    }

    ## DATA
    spr <- fread(paste0("../data/", file, "_data.csv"))
    spr$Condition <- factor(plyr::mapvalues(spr$Condition, c(1, 2, 3, 4),
                        c("A", "B", "C", "D")), levels = c("A", "B", "C", "D"))
    spr$Region <- factor(plyr::mapvalues(spr$Timestamp, c(2, 1, 4, 3),
                    c("Post-spillover", "Critical",
                    "Spillover", "Pre-critical")),
                    levels = c("Pre-critical-2", "Pre-critical", "Critical",
                                "Spillover", "Post-spillover"))
    spr$Timestamp <- NULL
    data_labs <- c("A: A+E+", "B: A-E+", "C: A+E-", "D: A-E-")
    data_vals <- c("#000000", "#BB5566", "#004488", "#DDAA33")

    # Observed
    obs <- spr[Type == "EEG", ]

    plot_rSPR(
        data = obs,
        file = paste0("../plots/", file, "/Observed.pdf"),
        yunit = "logRT",
        title = "Observed RTs",
        ylims = c(5.685, 5.865),
        leg_labs = data_labs,
        leg_vals = data_vals,
        omit_legend = FALSE,
        save_legend = TRUE)

    combo <- c("Intercept", "Intercept + Cloze", "Intercept + Noun Assoc.",
            "Intercept + Cloze + Noun Assoc.")
    # Estimated
    est <- spr[Type == "est", ]
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_rSPR(
            data = est_set,
            file = paste0("../plots/", file, "/Estimated_",
                name, ".pdf"),
            yunit = "logRT",
            title = paste0("Estimates: ", combo[i]),
            ylims = c(5.685, 5.865),
            leg_labs = data_labs,
            leg_vals = data_vals,
            omit_legend = TRUE,
            save_legend = FALSE)
    }

    # Residual
    res <- spr[Type == "res", ]
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_rSPR(
            data = res_set,
            file = paste0("../plots/", file, "/Residual_",
                name, ".pdf"),
            yunit = "logRT",
            title = paste0("Residuals: ", combo[i]),
            ylims = c(-0.05, 0.05),
            leg_labs = data_labs,
            leg_vals = data_vals,
            omit_legend = TRUE,
            save_legend = FALSE)
    }
}

make_plots("SPR2_Design1_Cloze_Assocnoun_rRT",
    predictor = c("Intercept", "Cloze", "Association_Noun"),
    model_labs = c("Intercept", "Cloze", "Noun Association"))

make_plots("SPR2_Design1_Cloze_Assocnoun_across_rRT",
    predictor = c("Intercept", "Cloze", "Association_Noun"),
    inferential = TRUE,
    model_labs = c("Intercept", "Cloze", "Noun Association"))