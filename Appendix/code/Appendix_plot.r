source("../../code/plot_rERP.r")
source("../../code/benjamini-hochberg.r")

make_plots <- function(
    file,
    elec = c("F3", "Fz", "F4", "C3", "Cz", "C4", "P3", "Pz", "P4"),
    predictor = "Intercept"
) {
    # make dirs
    system(paste0("mkdir ../plots/", file))
    system(paste0("mkdir ../plots/", file, "/Waveforms"))
    system(paste0("mkdir ../plots/", file, "/Topos"))

    ##########
    # MODELS #
    ##########
    mod <- fread(paste0("../data/", file, "_models.csv"))
    mod$Spec <- factor(mod$Spec, levels = predictor)

    # Models: coefficent
    coef <- mod[Type == "Coefficient", ]
    coef$Condition <- coef$Spec

    model_labs <- predictor
    model_vals <- c("black", "#E349F6", "#00FFFF")
    plot_elec(data = coef, e = elec, file = paste0("../plots/", file,
        "/Waveforms/Coefficients.pdf"), modus = "Coefficient",
        ylims = c(10, -5.5), leg_labs = model_labs, leg_vals = model_vals)
    # plot_topo(coef, file = paste0("../plots/", file, "/Topos/Coefficients"),
    #             tw = c(300, 500), cond_man = predictor[2],
    #             cond_base = "Intercept", label = "Coefficient")

    # Models: t-value
#     time_windows <- list(c(300, 500), c(600, 1000))
#     tval <- mod[Type == "t-value" & Spec != "Intercept", ]
#     sig <- mod[Type == "p-value" & Spec != "Intercept", ]
#     colnames(sig) <- gsub("_CI", "_sig", colnames(sig))

#     sig_corr <- bh_apply_wide(sig, elec, alpha = 0.05, tws = time_windows)

#     sigcols <- grepl("_sig", colnames(sig_corr))
#     tval <- cbind(tval, sig_corr[,..sigcols])
#     tval$Condition <- tval$Spec
#     plot_elec(tval, elec, 
#         file = paste0("../plots/", file, "/Waveforms/t-values.pdf"),
#         modus = "t-value", ylims=c(7, -5), tws=time_windows,
#         leg_labs = model_labs[2:length(model_labs)],
#         leg_vals = model_vals[2:length(model_vals)])

#     plot_topo(tval, file = paste0("../plots/", file, "/Topos/t-values"),
#                 tw = c(300, 500), cond_man = predictor,
#                 cond_base = "Intercept", label = "Coefficient")

    ########
    # DATA #
    ########
    eeg <- fread(paste0("../data/", file, "_data.csv"))

    # eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(1, 2),
    #                 c("A", "C")), levels = c("A", "C"))
    # data_labs <- c("A", "C")
    # data_vals <- c("black", "#004488")
    
    eeg$Condition <- factor(plyr::mapvalues(eeg$Condition, c(4, 1, 3, 2),
                     c("B", "A", "C", "D")), levels = c("A", "B", "C", "D"))
    data_labs <- c("A", "B", "C", "D")
    data_vals <- c("#000000", "#BB5566", "#004488", "#DDAA33")

    # Data: Observed
    obs <- eeg[Type == "EEG", ]
    source("plot_rERP.r")
    plot_elec(obs, elec,
        file = paste0("../plots/", file,  "/Waveforms/Observed.pdf"),
        modus = "Condition", ylims=c(8, -5.5),
        leg_labs = data_labs, leg_vals = data_vals)

    plot_topo(obs, file = paste0("../plots/", file, "/Topos/Observed"),
                tw = c(300, 500), cond_man = "C", cond_base = "A")

    # Data: Estimated
    source("plot_rERP.r")
    est <- eeg[Type == "est",]
    for (i in seq(1, length(unique(est$Spec)))) {
        spec <- unique(est$Spec)[i]
        est_set <- est[Spec == spec, ]
        spec <- unique(est_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_elec(est_set, elec,
                file = paste0("../plots/", file,
                "/Waveforms/Estimated_", name, ".pdf"),
                modus = "Condition", ylims = c(8, -5.5),
                leg_labs = data_labs, leg_vals = data_vals)
        plot_topo(est_set, file = paste0("../plots/",
                file, "/Topos/Estimated_", name),
                tw = c(300, 500), cond_man = "C", cond_base = "A")
    }

    # Data: Residual
    source("plot_rERP.r")
    res <- eeg[Type == "res", ]
    for (i in seq(1, length(unique(res$Spec)))) {
        spec = unique(res$Spec)[i]
        res_set <- res[Spec == spec, ]
        spec = unique(res_set$Spec)
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_elec(res_set, elec,
                file = paste0("../plots/", file, "/Waveforms/Residual_",
                name, ".pdf"), modus = "Condition", ylims = c(4.7, -4),
                leg_labs = data_labs, leg_vals = data_vals)
        plot_topo(res_set, 
                file = paste0("../plots/", file, "/Topos/Residual_", name),
                tw = c(300, 500), cond_man = "C", cond_base = "A")
    }
}


#make_plots("CAPEXP_AC_Intercept_rERP", predictor = c("Intercept"))

# make_plots("CAPEXP_AC_CondCode_rERP", predictor = c("Intercept", "CondCode"))

# make_plots("CAPEXP_AC_cloze_rERP", predictor = c("Intercept", "Cloze"))

make_plots("ERP_Design1_cloze_rcnoun_rERP", predictor = c("Intercept", "Cloze", "rcnoun"))
