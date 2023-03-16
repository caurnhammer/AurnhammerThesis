source("../../../code/plot_lmerRT.r")

produce_rt_plots <- function(
    path,
    data_labs,
    data_vals,
    model_labs,
    model_vals
) {
    name <- paste0("../plots/", substr(path, 9, nchar(path) - 4))
    system(paste("mkdir", name))

    # read data
    lmerRT <- fread(path)

    # Observed Data
    plot_lmerRT(lmerRT, "logRT",
                 yunit = "logRT",
                 title = "Observed RTs",
                 ylims = c(5.72, 5.87),
                 name = name,
                 leg_labs = data_labs,
                 leg_vals = data_vals)

    # Estimated RTs
    estimates <- colnames(lmerRT)[which(grepl("est_", colnames(lmerRT)))]
    for (x in estimates) {
         plot_lmerRT(lmerRT,
                      DV = x,
                      yunit = "logRT",
                      title = "Estimated RTs",
                      ylims = c(5.72, 5.87),
                      name = name,
                      leg_labs = data_labs,
                      leg_vals = data_vals)
    }

    # Residuals
    residuals <- colnames(lmerRT)[which(grepl("res_", colnames(lmerRT)))]
    for (x in residuals) {
        plot_lmerRT(lmerRT,
                    DV = x,
                    yunit = "logRT",
                    title = "Residuals",
                    ylims=c(0.06, -0.06),
                    name = name,
                    leg_labs = data_labs,
                    leg_vals = data_vals)
    }

    # Coefficients
    coefs_cols <- colnames(lmerRT)[grep("coef", colnames(lmerRT))]
    SE_cols <- colnames(lmerRT)[grep("SE_", colnames(lmerRT))]
    cols <- c("Condition", "Item", "Subject", "Region", coefs_cols, SE_cols)
    data <- lmerRT[,..cols]
    data1 <- melt(data, id.vars = c("Condition", "Region"),
                    measure.vars = coefs_cols,
                    variable.name = "Coefficient",
                    value.name = "coefficients")
    data1$SE <- melt(data,
                id.vars = c("Condition", "Region"),
                measure.vars = SE_cols,
                variable.name = "Coefficient",
                value.name = "SE")$SE
    data1 <- data1[, lapply(.SD, mean), 
                by = list(Region, Coefficient),
                .SDcols = c("coefficients", "SE")]
    plot_lmerRT(data1,
                "coefficients",
                yunit = "Intercept + coefficient",
                title = "Coefficients",
                grouping = "Coefficient",
                ylims = c(5.72, 5.86),
                name = name,
                leg_labs = model_labs,
                leg_vals = model_vals)

    # Z-values
    zval_cols <- setdiff(colnames(lmerRT)[grep("zval_",
                    colnames(lmerRT))], "zval_1")
    pval_cols <- setdiff(colnames(lmerRT)[grep("pval_",
                    colnames(lmerRT))], "pval_1")
    cols <- c("Condition", "Item", "Subject", "Region", zval_cols, pval_cols)
    data <- lmerRT[,..cols]
    data1 <- melt(data, id.vars = c("Condition", "Region"),
                measure.vars = zval_cols,
                variable.name = "Zvalue",
                value.name = "zvalue")
    data1$pvalue <- melt(data, id.vars = c("Condition", "Region"),
                        measure.vars = pval_cols,
                        variable.name = "Pvalue",
                        value.name = "pvalue")$pvalue
    data1 <- data1[, lapply(.SD, mean), by = list(Region, Zvalue),
                .SDcols = c("zvalue", "pvalue")]
    plot_lmerRT(data1,
                "zvalue",
                yunit = "Z-values",
                title = "Effect Size",
                ylims = c(-2, 3),
                grouping = "Zvalue",
                name = name,
                leg_labs = model_labs[2:length(model_vals)],
                leg_vals = model_vals[2:length(model_vals)])
}

produce_rt_plots(
    "../data/lmerRT_logCloze_AssocNoun.csv",
    c("A: A+E+", "B: A-E+", "C: A+E-", "D: A-E-"),
    c("#000000", "#BB5566", "#004488", "#DDAA33"),
    c("Intercept", "log(Cloze)", "Noun Association"),
    c("#000000", "#E349F6", "#00FFFF")
)