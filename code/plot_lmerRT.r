##
# Christoph Aurnhammer <aurnhammer@coli.uni-saarland.de>
# EEG plotting options for (lme)rRTs
##

library(data.table)
library(ggplot2)

se <- function(
    x,
    na.rm = FALSE
) {
    if (na.rm == TRUE) {
        sd(x, na.rm = TRUE) / sqrt(length(x[!is.na(x)]))
    } else {
        sd(x) / sqrt(length(x))
    }
}

# Return only the legend of an ggplot object
get_legend <- function(
    a_gplot
) {
    tmp <- ggplot_gtable(ggplot_build(a_gplot +
            theme(legend.box = "vertical",
                  legend.spacing.y = unit(0.005, "inch"))))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)
}

plot_lmerRT <- function(
    data,
    DV,
    yunit,
    title,
    ylims = NULL,
    grouping = "Condition",
    name,
    leg_labs,
    leg_vals,
    omit_legend = FALSE,
    save_legend = FALSE
) {
    # always exclude the word two words before critical
    data <- data[Region != "Pre-critical-2",]
    data$Region <- factor(data$Region,
            levels = c("Pre-critical", "Critical",
                       "Spillover", "Post-spillover"))

    # Data preprocessing
    if (!(DV %in% c("coefficients", "zvalue"))) {
        pm <- aggregate(data[[DV]] ~ Region + data[[grouping]] + Subject,
            data, FUN = mean)
        colnames(pm)[c(2,4)] <- c("group", "DV")
        plusminus <- aggregate(DV ~ Region + group, pm, FUN = mean)
        plusminus$SE <- aggregate(DV ~ Region + group, pm, FUN = se)[, 3]
        plusminus <- data.table(plusminus)
    } else if (DV == "zvalue") {
        plusminus <- data
        colnames(plusminus)[c(2, 3)] <- c("group", "DV")
        plusminus$sig <- plusminus$pvalue < 0.05
        df <- plusminus[, c("Region", "group", "pvalue", "sig")]
        df$posit <- rep(seq(ylims[1] - 3.5, ylims[1] - 0.3,
            length = length(unique(plusminus$group))),
            each = length(unique(plusminus$Region)))
        df$sig <- factor(df$sig, levels = c("TRUE", "FALSE"),
            labels = c("Significant", "Insignificant"))
        df$Region <- plusminus$Region
    } else {
        plusminus <- data
        colnames(plusminus)[c(2, 3)] <- c("group", "DV")
    }

    # For all plots
    p <- ggplot(plusminus, aes(x = Region, y = DV, color = group,
            group = group)) +
            geom_point(size = 2.5, shape = "cross") +
            geom_line(linewidth = 0.5)
    # conditional plot processing
    if (!(DV %in% c("zvalue", "coefficients"))) {
        p <- p + geom_errorbar(aes(ymin = DV - SE, ymax = DV + SE),
            width = .1, linewidth = 0.3)
    }
    if (DV == "coefficients") { # Coeffificents
        p <- p + geom_errorbar(aes(ymin = DV - SE, ymax = DV + SE),
            width = .1, linewidth = 0.3)
        p <- p + scale_color_manual(name = "Coefficients",
            values = leg_vals, labels = leg_labs)
        if ("Distractor Cloze" %in% leg_labs) {
            p <- p + guides(color = guide_legend(nrow = 2, byrow = TRUE))
        }
    } else if (DV == "zvalue") { # Z-values
        p <- p + geom_hline(yintercept = 0, linetype = "dashed")
        p <- p + scale_color_manual(name = "Z-value",
            values = leg_vals, labels = leg_labs)
        p <- p + geom_point(data = df, aes(x = Region, y = posit, shape = sig),
            size = 2.5)
        p <- p + scale_shape_manual(values = c(20, 32),
            name = "Corrected p-values",
            labels = c("Significant", "Nonsignificant"))
    } else if (grouping == "estimate") { # Condition a estimates
        p <- p + scale_color_manual(name = "log(Cloze)",
        labels = leg_labs,
        values = leg_vals)
    }
    else { # RTs, Residuals
        p <- p + scale_color_manual(
            name = "Condition",
            labels = leg_labs,
            values = leg_vals)
    }
    if ((is.vector(ylims) == TRUE) & (DV != "zvalue")) {
        p <- p + ylim(ylims[1], ylims[2])
    }
    if (title == "Observed RTs" & "A: Plausible" %in% leg_labs) {
        p <- p + guides(color = guide_legend(nrow = 3,
                                             byrow = TRUE))
    }

    p <- p + theme_minimal()
    p <- p + theme(plot.title = element_text(size = 8),
        axis.text.x = element_text(size = 7),
        legend.position = "bottom",
        legend.text = element_text(size = 5),
        legend.title = element_text(size = 6),
        legend.box = "vertical",
        legend.spacing.y = unit(-0.2, "cm"),
        legend.margin = margin(0,0,0,0),
        legend.box.margin = margin(-10, -10, -10, -50))
    p <- p + labs(x = "Region", y = yunit, title = title)

    # Option to omit legend and save it separately.
    if (omit_legend) {
        if (save_legend) {
            lgnd <- get_legend(p)
            ggsave(paste0("../plots/", name, "/RT_", DV, "_rtlegend.pdf"),
                    lgnd, device = cairo_pdf,
                    width = 4, height = 0.25)
        }
        p <- p + theme(legend.position = "none")
    }

    if (title == "Observed Reading Times") {DV <- paste0(DV, "_nolegend")}

    if (grouping == "estimate") {
        outpath <- paste0("../plots/", name, "/RT_A_estimate_", DV, ".pdf")
    } else {
        outpath <- paste0("../plots/", name, "/RT_", DV, ".pdf")
    }

    ggsave(outpath, p, width = 3, height = 3)
}