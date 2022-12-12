source("../../code/plot_rERP.r")

make_plots <- function(
    file,
    predictor,
    inferential = FALSE,
    model_labs
) {
    # make dirs
    system(paste0("mkdir ../plots/", file))

    ## MODELS
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)
    mod$Region <- factor(plyr::mapvalues(mod$Timestamp, c(2, 1, 3, 4),
        c("Pre-critical", "Critical", "Spillover", "Post-spillover")),
        levels = c("Pre-critical", "Critical", "Spillover", "Post-spillover"))
    mod$Timestamp <- NULL
    model_vals <- c("black", "#E349F6", "#00FFFF")

    # Models: coefficent
    coef <- mod[Type == "Coefficient", ]

    plot_rSPR(coef,
        file = paste0("../plots/", file, "/Coefficients.pdf"),
        modus = "coefficients", yunit = "ReadingTime", title = "Coefficients",
        ylims = c(5.71, 5.825), leg_labs = model_labs, leg_vals = model_vals)

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
    spr$Region <- factor(plyr::mapvalues(spr$Timestamp, c(2, 1, 3, 4),
        c("Pre-critical", "Critical", "Spillover", "Post-spillover")),
        levels = c("Pre-critical", "Critical", "Spillover", "Post-spillover"))
    spr$Timestamp <- NULL
    data_labs <- c("A", "B", "C", "D")
    data_vals <- c("#000000", "#BB5566", "#004488", "#DDAA33")

    # Observed
    obs <- spr[Type == "EEG", ]

    source("../../code/plot_rERP.r")
    plot_rSPR(obs,
        file = paste0("../plots/", file, "/Observed.pdf"),
        yunit = "logRT",
        title = "Observed RTs",
        ylims = c(5.685, 5.865),
        leg_labs = data_labs, leg_vals = data_vals)

    # Estimated
    est <- spr[Type == "est", ]
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_rSPR(est_set,
            file = paste0("../plots/", file, "/Estimated_",
                name, ".pdf"),
            yunit = "logRT",
            title = paste0("Estimated RTs: ", name),
            ylims = c(5.685, 5.865),
            leg_labs = data_labs, leg_vals = data_vals)
    }

    # Residual
    res <- spr[Type == "res", ]
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_rSPR(res_set,
            file = paste0("../plots/", file, "/Residual_",
                name, ".pdf"),
            yunit = "logRT",
            title = paste0("Residual Error: ", name),
            ylims = c(-0.05, 0.05),
            leg_labs = data_labs, leg_vals = data_vals)
    }
}

make_plots("SPR2_Design1_logCloze_AssociationNoun_rRT",
    predictor = c("Intercept", "logCloze", "rcnoun"),
    model_labs = c("Intercept", "logCloze", "Noun Association"))

make_plots("SPR2_Design1_logCloze_AssociationNoun_across_rRT",
    predictor = c("Intercept", "logCloze", "Association_Noun"),
    inferential = TRUE,
    model_labs = c("Intercept", "logCloze", "Noun Association"))

make_plots("SPR2_Design1_logCloze_AssociationNoun_Interaction_rRT",
    predictor = c("Intercept", "logCloze", "Association_Noun", "Interaction_logCloze_NounAssoc"),
    model_labs = c("Intercept", "logCloze", "Noun Association", "Interaction"))