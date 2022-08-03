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
    system(paste0("mkdir ../plots/", file, "/Topos"))

    # MODELS
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)

    model_labs <- predictor
    model_vals <- c("black", "#E349F6", "#00FFFF")

    # Models: coefficent
    coef <- mod[Type == "Coefficient", ]
    coef$Condition <- coef$Spec
    plot_single_elec(coef, "C3",
        file = paste0("../plots/", file, "/Waveforms/Coefficients_C3.pdf"),
        modus = "Coefficient", ylims = c(10, -5.5),
        leg_labs = model_labs, leg_vals = model_vals)
    plot_single_elec(coef, "Pz", 
        file = paste0("../plots/", file, "/Waveforms/Coefficients_Pz.pdf"),
        modus = "Coefficient", ylims = c(10, -5.5),
        leg_labs = model_labs, leg_vals = model_vals)

    # Models: t-value
    time_windows <- list(c(250, 400), c(600, 1000))
    tval <- mod[Type == "t-value" & Spec != "Intercept", ]
    sig <- mod[Type == "p-value" & Spec != "Intercept", ]
    colnames(sig) <- gsub("_CI", "_sig", colnames(sig))

    sig_corr <- bh_apply_wide(sig, elec, alpha=0.05, tws=time_windows)
    sigcols <- grepl("_sig", colnames(sig_corr))
    tval <- cbind(tval, sig_corr[,..sigcols])
    mod$Spec <- factor(mod$Spec, levels = predictor)
    tval$Condition <- tval$Spec

    plot_nine_elec(tval, elec,
        file = paste0("../plots/", file, "/Waveforms/t-values.pdf"),
        modus = "t-value", ylims = c(7, -5), tws = time_windows,
        leg_labs = model_labs[2:length(model_vals)],
        leg_vals = model_vals[2:length(model_vals)])

    ## DATA
    eeg <- fread(paste0("../data/", file, "_data.csv"))
    eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2, 3),
                             c("A", "B", "C")), levels = c("A", "B", "C"))

    data_labs <- c("A", "B", "C")
    data_vals <- c("black", "red", "blue")

    # Observed
    obs <- eeg[Type == "EEG", ]
    plot_nine_elec(obs, elec,
        file = paste0("../plots/", file,  "/Waveforms/Observed.pdf"),
        modus = "Condition", ylims = c(10.5, -5.5),
        leg_labs = data_labs, leg_vals = data_vals)

    plot_full_elec(data = obs, e = elec_all, 
        file = paste0("../plots/", file, "/Waveforms/Observed_Full.pdf"),
        title = "Observed", modus = "Condition",
        ylims = c(10.5, -5.5), leg_labs = data_labs, leg_vals = data_vals)

    plot_topo(obs, file = paste0("../plots/", file, "/Topos/Observed"),
                tw = c(250, 400), cond_man = "B", cond_base = "A",
                add_title = "\nObserved", omit_legend = TRUE,
                save_legend = TRUE)
    plot_topo(obs, file = paste0("../plots/", file, "/Topos/Observed"),
                tw = c(600, 1000), cond_man = "B", cond_base = "A",
                add_title = "\nObserved", omit_legend = TRUE)
    plot_topo(obs, file = paste0("../plots/", file, "/Topos/Observed"),
                tw = c(250, 400), cond_man = "C", cond_base = "A",
                add_title = "\nObserved", omit_legend = TRUE)
    plot_topo(obs, file = paste0("../plots/", file, "/Topos/Observed"),
                tw = c(600, 1000), cond_man = "C", cond_base = "A",
                add_title = "\nObserved", omit_legend = TRUE)

    # Estimated
    est <- eeg[Type == "est",]
    pred <- c("Intercept", "Tar. Plaus.", "Dist. Cloze",
              "Dist. Cloze + Tar. Plaus.")
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        spec <- unique(est_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_nine_elec(est_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Estimated_",
                  name, ".pdf"), modus = "Condition", ylims = c(10.5, -5.5),
                  leg_labs = data_labs, leg_vals = data_vals)
        plot_topo(est_set, 
            file = paste0("../plots/", file, "/Topos/Estimated_", name),
            tw = c(600, 1000), cond_man = "B", cond_base = "A",
            add_title = paste("\nEstimate", pred[i]), omit_legend = TRUE)
    }

    # Residual
    res <- eeg[Type == "res", ]
    pred <- c("Intercept", "Tar. Plaus.", "Dist. Cloze",
              "Dist. Cloze + Tar. Plaus.")
    for (i in seq(1, length(unique(res$Spec)))) {
        spec <- unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec <- unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_nine_elec(res_set, elec,
                  file = paste0("../plots/", file, "/Waveforms/Residual_",
                  name, ".pdf"), modus = "Condition", ylims = c(4.7, -4),
                  leg_labs = data_labs, leg_vals = data_vals)
    }
}

make_plots("Design2_Plaus_Clozedist",
    predictor = c("Intercept", "Plaus", "Cloze_dist"))

make_plots("Design2_Plaus_Clozedist_across",
    predictor = c("Intercept", "Plaus", "Cloze_dist"))

make_plots("Design2_RT", predictor = c("Intercept", "ReadingTime"))
