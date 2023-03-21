##
# Christoph Aurnhammer <aurnhammer@coli.uni-saarland.de>
# EEG plotting options for (lme)rERPs
##

library(data.table)
library(ggplot2)
library(gridExtra)

# compute standard error
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
# (s/o to some person on the internet)
get_legend<-function(
    a.gplot
) {
    tmp <- ggplot_gtable(ggplot_build(a.gplot +
                theme(legend.box="vertical",
                      legend.spacing.y = unit(0.005, 'inch'))))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)
}

# For a single Electrode, plot per-grouping mean.
plot_grandavg_ci_lmer <- function(
    dt,                         # data
    ttl,                        # title
    yunit = paste0("Amplitude (µVolt)"), # y-axis unit
    subject_avg = TRUE,         # first average across subjects
    ci = FALSE,                 # add bootrs. conf. intervals
    ylims = NULL,               # optional length=2 vector, desc order
    grouping = "Condition",     # will be split into lines/colors/fills
    tws = list(c(350, 450), c(600, 800)),
    leg_labs,
    leg_vals
) {
    # Pre-processing
    if (subject_avg == TRUE) {
            colnames(dt)[ncol(dt)] <- "V2"
            dt <- dt[, lapply(.SD, mean),
                     by=c(grouping, "Subject", "Timestamp"),
                     .SDcols="V2"]
        if ((subject_avg == TRUE & ci == FALSE) == TRUE) {
                dt <- dt[, lapply(.SD, mean),
                         by = c(grouping, "Timestamp"),
                         .SDcols = "V2"]
        }
    }

    if (ci == TRUE & grouping != "Coefficient") {
            sedf <- dt[, lapply(.SD, se),
                       by = c(grouping, "Timestamp"),
                       .SDcols = "V2"]
            colnames(sedf)[3] <- "SE"
            sedf$SE = sedf$SE * 2
            dt <- merge(dt, sedf, on = c(grouping, "Timestamp"))
            dt <- dt[, lapply(.SD, mean),
                     by = c(grouping, "Timestamp"),
                     .SDcols = c("V2", "SE")]
    }

    if (subject_avg == FALSE & ci == FALSE) {
        if (grouping == "zvalue") {
                colnames(dt)[c(6,7)] <- c("V2", "V3")
                dt <- dt[, lapply(.SD, mean),
                         by = c(grouping, "Timestamp"),
                         .SDcols = c("V2", "V3")]
                colnames(dt)[4] <- "sig"
                df <- dt[,c("zvalue", "Timestamp", "sig")]
                df$posit <- rep(seq(ylims[1] - 2, ylims[1],
                                length = length(unique(df$zvalue))),
                                length(unique(df$Timestamp)))
                df$sig <- factor(df$sig, levels = c(0, 1),
                                 labels = c("insign", "sign"))
        } else if (grouping == "logCloze") {
                colnames(dt)[3] <- "V2"
        } else {
                colnames(dt)[c(6,7)] <- c("V2", "V3")
                dt <- dt[, lapply(.SD, mean),
                        by = c(grouping, "Timestamp"),
                        .SDcols = c("V2", "V3")]
        }
    }

    # Initial Plot call
    if (grouping == "Coefficient") {
            plt <- ggplot(dt, aes(x = Timestamp, y = V2,
                    color = dt[[grouping]], fill = dt[[grouping]]))
    } else {
            plt <- ggplot(dt, aes(x = Timestamp, y = V2,
                    color = dt[[grouping]], fill = dt[[grouping]]))
    }

    plt <- plt + geom_line()
    plt <- plt + geom_hline(yintercept = 0, linetype = "dashed")
    plt <- plt + geom_vline(xintercept = 0, linetype = "dashed")
    plt <- plt + theme(panel.background = element_rect(
                        fill = "#FFFFFF",
                        color = "#000000",
                        linewidth = 0.1,
                        linetype = "solid"),
                        panel.grid.major = element_line(
                        linewidth = 0.3,
                        linetype = "solid",
                        color = "#A9A9A9"),
                        panel.grid.minor = element_line(
                        linewidth = 0.15,
                        linetype = "solid",
                        color = "#A9A9A9"),
                        legend.position = "top")
    plt <- plt + labs(y = yunit, x = "Time (ms)", title = ttl)

    # Error ribbons
    if (ci == TRUE) {
            plt <- plt + geom_ribbon(aes(x = Timestamp,
                                         ymax = V2 + SE,
                                         ymin = V2 - SE),
                                    alpha = 0.20,
                                    color = NA)
    } else if (grouping == "Coefficient") {
            plt <- plt + geom_ribbon(aes(x = Timestamp,
                                         ymax = V2 + V3,
                                         ymin = V2 - V3),
                                    alpha = 0.20,
                                    color = NA)
    }

    # Grouping color + fill
    if (grouping == "zvalue") {
            plt <- plt + scale_color_manual(name = "Predictor",
                                            labels = leg_labs,
                                            values = leg_vals)
            plt <- plt + scale_fill_manual(name = "Predictor",
                                            labels = leg_labs,
                                            values = leg_vals)
            plt <- plt + geom_point(data = df,
                                    aes(x = Timestamp,
                                        y = posit,
                                        shape = sig))
            plt <- plt + scale_shape_manual(values = c(32, 20),
                    name = "Corrected p-values",
                    labels = c("Nonsignificant", "Significant"))
            plt <- plt + annotate("rect",
                                    xmin = tws[1][[1]][1],
                                    xmax = tws[1][[1]][2],
                                    ymin = ylims[1],
                                    ymax = ylims[2],
                                    alpha = .15)
            plt <- plt + annotate("rect",
                                    xmin = tws[2][[1]][1],
                                    xmax = tws[2][[1]][2],
                                    ymin = ylims[1],
                                    ymax = ylims[2],
                                    alpha = .15)
    } else {
            plt <- plt + scale_color_manual(name = grouping,
                                            labels = leg_labs,
                                            values = leg_vals)
            plt <- plt + scale_fill_manual(name = grouping,
                                            labels = leg_labs,
                                            values = leg_vals)
    }

    # y-lims
    if (is.vector(ylims) == TRUE) {
        plt <- plt + scale_y_reverse(limits = ylims)
    } else {
        plt <- plt + scale_y_reverse()
    }

    plt
}

# Plot midline electrodes.
plot_midline <- function(
    data,                     # input data
    file = FALSE,             # where to store. If FALSE, display.
    title = "Midline ERPs",   # Add title
    yunit = paste0("Amplitude (µVolt)"), # y-axis label
    subject_avg = TRUE,       # Compute subject-average before plotting
    ci = FALSE,               # include conf interval
    ylims = NULL,             # custom ylims (desc order)
    grouping = "Condition",   # will be split into lines/colors/fills
    leg_labs,
    leg_vals
) {
    data[[grouping]] <- as.factor(data[[grouping]])
    if (grouping == "logCloze") {
        cols <- c(grouping, "Subject", "Timestamp")
    } else {
        cols <- c(grouping, "Item", "Subject", "Timestamp", "TrialNum")
    }

    # Make individual plots
    if (grouping == "zvalue") {
        Fzplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols],
                            data[, c("zval_Fz", "sig_Fz")]),
                    ttl = "Fz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
        Czplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols],
                            data[, c("zval_Cz", "sig_Cz")]),
                    ttl = "Cz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
        Pzplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols],
                            data[, c("zval_Pz", "sig_Pz")]),
                    ttl = "Pz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
    } else if (grouping == "Coefficient") {
        Fzplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols],
                            data[, c("coefval_Fz", "seval_Fz")]),
                    ttl = "Fz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
        Czplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols],
                            data[, c("coefval_Cz", "seval_Cz")]),
                    ttl = "Cz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
        Pzplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols],
                            data[, c("coefval_Pz", "seval_Pz")]),
                    ttl = "Pz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
    } else {
        Fzplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols], data[, "Fz"]),
                    ttl = "Fz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
        Czplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols], data[, "Cz"]),
                    ttl = "Cz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
        Pzplt <- plot_grandavg_ci_lmer(
                    dt = cbind(data[, ..cols], data[, "Pz"]),
                    ttl = "Pz",
                    yunit = yunit,
                    subject_avg = subject_avg,
                    ci = ci,
                    ylims = ylims,
                    grouping = grouping,
                    leg_labs = leg_labs,
                    leg_vals = leg_vals)
    }

    # Get the legend
    Fzplt <- Fzplt + theme(
                    legend.title = element_text(size = 10),
                    legend.text = element_text(size = 8))
    legend <- get_legend(Fzplt)

    # Arrange
    gg <- arrangeGrob(arrangeGrob(Fzplt + theme(legend.position = "none"),
                                 Czplt + theme(legend.position = "none"),
                                 Pzplt + theme(legend.position = "none"),
                                 layout_matrix = matrix(1:3)),
                                 legend,
                                 heights = c(10, 1.2),
                                 top = title)

    if (file != FALSE) {
        ggsave(file, gg, device = cairo_pdf, width = 4, height = 7)
    } else {
        gg
    }
}