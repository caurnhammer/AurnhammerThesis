source("../../code/plot_rERP.r")

make_plots <- function(
    file,
    predictor,
    model_labs
) {
    # make dirs
    system(paste0("mkdir ../plots/", file))
    system(paste0("mkdir ../plots/", file, "/Waveforms"))
    system(paste0("mkdir ../plots/", file, "/Topos"))

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

    source("../../code/plot_rERP.r")
    plot_rSPR(coef,
        file = paste0("../plots/", file, "/Waveforms/Coefficients.pdf"),
        modus = "coefficients",
        yunit = "ReadingTime", title = "Coefficients",
        leg_labs = model_labs, leg_vals = model_vals)

    # Models: t-value
    # NOTE: P-values are averaged across subjects. If the average p-value is < 0.05, this graphs produces a significance blob.
    if (design = "SPR2_Design1_across") {
        tval <- mod[Type == "t-value" & Spec != "Intercept",]
        sig <- mod[Type == "p-value" & Spec != "Intercept",]
        colnames(sig) <- gsub("ReadingTime", "sig_average", colnames(sig))
        colnames(sig) <- gsub("sig_average_CI", "sig_proportion", colnames(sig))
        sigcols <- grepl("sig_", colnames(sig))
        tval <- cbind(tval, sig[,..sigcols])
        plot_rSPR(tval, "t-value", yunit="t-value", title="t-values", ylims=c(-7, 2.5))
    }
    
    ## DATA
    spr <- fread(paste0("data/", file, "_data.csv"))
    
    spr$Condition <- factor(plyr::mapvalues(spr$Condition, c(1, 2, 3), c("A", "B", "C")), levels=c("A", "B", "C"))
    spr$Region <- factor(plyr::mapvalues(spr$Timestamp, c(1, 2, 3, 4), c("Pre-critical", "Critical", "Spillover", "Post-spillover")), levels=c("Pre-critical", "Critical", "Spillover", "Post-spillover"))
    spr$Timestamp <- NULL

    # Observed
    obs <- spr[Type == "EEG",]
    source("plot_rERP.r")
    plot_rSPR(obs, "Observed", yunit="ReadingTime", title="Observed RTs")

    # Estimated
    source("plot_rERP.r")
    est <- spr[Type == "est",]
    for (i in seq(1,length(unique(est$Spec)))){
        spec = unique(est$Spec)[i] 
        est_set <- est[Spec == spec,]
        if(clip_precrit){est_set <- est_set[Region!="Pre-critical",]}
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_rSPR(est_set, paste("est",name,sep="_"), yunit="ReadingTime", title=name)
    }

    # Residual
    source("plot_rERP.r")
    res <- spr[Type == "res",]
    for (i in seq(1,length(unique(res$Spec)))){
        spec = unique(res$Spec)[i] 
        res_set <- res[Spec == spec,]
        if(clip_precrit){res_set <- res_set[Region!="Pre-critical",]}
        name <- gsub("\\[|\\]|:|,| ", "", spec)
        plot_rSPR(res_set, paste("res",name,sep="_"), yunit="ReadingTime", title=name)
    }
}

make_plots("SPR2_Design1_Cloze_rcnoun_rRT",
    predictor = c("Intercept", "Cloze", "rcnoun"),
    model_labs = c("Intercept", "Cloze", "Noun Association"))
#make_plots("GP6_Plaus_Clozedist_RTPrecrit", clip_precrit=TRUE)