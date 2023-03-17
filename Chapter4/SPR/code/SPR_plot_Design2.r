source("../../../code/plot_lmerRT.r")

produce_spr_plots <- function(
    path
) {
    lmerRT <- fread(paste0("../data/", path, ".csv"))

    # make dirs
    system(paste0("mkdir -p ../plots/", path))

    data_labs <- c("A: Plausible", "B: Less plausible, attraction",
                   "C: Implausible, no attraction")
    data_vals <- c("black", "red", "blue")

    if (grepl("PrecritRT", path)) {
        model_labs <- c("Intercept", "PrecritRT", "Plausibility",
            "Distractor Cloze")
        model_vals <- c("#000000", "red", "#E349F6", "#00FFFF")
    } else {
        model_labs <- c("Intercept", "Plausibility", "Distractor Cloze")
        model_vals <- c("#000000", "#E349F6", "#00FFFF")
    }

    # Observed Data
    plot_lmerRT(
        data = lmerRT,
        DV = "logRT",
        yunit = "logRT",
        title = "Observed RTs",
        ylims = c(5.5, 5.8),
        grouping = "Condition",
        name = path,
        leg_labs = data_labs,
        leg_vals = data_vals,
        omit_legend = FALSE,
        save_legend = FALSE)

    # Estimated RTs
    estimates <- colnames(lmerRT)[which(grepl("est_", colnames(lmerRT)))]
    i <- 1
    for (x in estimates) {
        if (i == 1) {lgn <- TRUE} else {lgn <- FALSE}
        plot_lmerRT(
            data = lmerRT,
            DV = x,
            yunit = "logRT",
            title = "Estimated RTs",
            ylims = c(5.5, 5.8),
            grouping = "Condition",
            name = path,
            leg_labs = data_labs,
            leg_vals = data_vals,
            omit_legend = TRUE,
            save_legend = lgn)
        i <- i + 1
    }

    # Residuals
    residuals <- colnames(lmerRT)[which(grepl("res_", colnames(lmerRT)))]
    for (x in residuals) {
        plot_lmerRT(
            data = lmerRT,
            DV = x,
            yunit = "logRT",
            title = "Residuals: Plausibility + Cloze Distractor",
            ylims = c(0.12, -0.12),
            grouping = "Condition",
            name = path,
            leg_labs = data_labs,
            leg_vals = data_vals,
            omit_legend = TRUE,
            save_legend = FALSE)
    }

    # Coefficients
    coefs_cols <- colnames(lmerRT)[grep("coef", colnames(lmerRT))]
    SE_cols <- colnames(lmerRT)[grep("SE_", colnames(lmerRT))]
    cols <- c("Condition", "Item", "Subject", "Region", coefs_cols, SE_cols)
    data <- lmerRT[,..cols]
    data1 <- melt(data, id.vars=c("Condition", "Region"),
        measure.vars = coefs_cols, variable.name = "Coefficient",
        value.name = "coefficients")
    data1$SE <- melt(data, id.vars = c("Condition", "Region"),
        measure.vars = SE_cols, variable.name = "Coefficient",
        value.name = "SE")$SE
    data1 <- data1[, lapply(.SD, mean), by = list(Region, Coefficient),
        .SDcols = c("coefficients", "SE")]
    plot_lmerRT(
        data = data1,
        DV = "coefficients",
        yunit = "SPR Coefficients",
        title = "Coefficients",
        ylims = NULL,
        grouping = "Coefficient",
        name = path,
        leg_labs = model_labs,
        leg_vals = model_vals,
        omit_legend = FALSE,
        save_legend = TRUE)

    # Z-values
    zval_cols <- setdiff(colnames(lmerRT)[grep("zval_",
        colnames(lmerRT))], "zval_1")
    pval_cols <- setdiff(colnames(lmerRT)[grep("pval_",
        colnames(lmerRT))], "pval_1")
    cols <- c("Condition", "Item", "Subject", "Region", zval_cols, pval_cols)
    data <- lmerRT[,..cols]
    data1 <- melt(data, id.vars=c("Condition", "Region"),
        measure.vars = zval_cols, variable.name = "Zvalue",
        value.name = "zvalue")
    data1$pvalue <- melt(data, id.vars=c("Condition", "Region"),
        measure.vars = pval_cols, variable.name = "Pvalue",
        value.name="pvalue")$pvalue
    data1 <- data1[, lapply(.SD, mean), by = list(Region, Zvalue),
        .SDcols = c("zvalue", "pvalue")]
    plot_lmerRT(
        data = data1,
        DV = "zvalue",
        yunit = "Z-values",
        title = "Inferential Statistics",
        ylims = c(-2, 7),
        grouping = "Zvalue",
        name = path,
        leg_labs = model_labs[2:length(model_labs)],
        leg_vals = model_vals[2:length(model_labs)],
        omit_legend = FALSE,
        save_legend = TRUE)
}

produce_spr_plots("rRT_Plaus_Clozedist")

produce_spr_plots("rRT_PrecritRT_Plaus_Clozedist")