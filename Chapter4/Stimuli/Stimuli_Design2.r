# Christoph Aurnhammer, 2022
# Dissertation, Chapter 4
# Create density plots of Design 2 stimulus properties

library(data.table)
library(ggplot2)
library(gridExtra)


quad_density("../../data/Stimuli_Design2.csv", c("A", "B", "C"), c("black", "red", "blue"))

items_and_means <- function(data, Predictor) {
    data_items <- data[, lapply(.SD, mean), by = list(Item, Condition),
                    .SDcols = c(Predictor)]
    data_means <- data[, lapply(.SD, mean), by = list(Condition),
                    .SDcols = c(Predictor)]
    data_means <- aggregate(as.formula(paste0(Predictor, "~ Condition")),
                    data, FUN = mean)
    
    list(data_items, data_means)
}

quad_density <- function(path, leg_labs, leg_vals) {
    dt <- fread(path)

    plaus   <- items_and_means(dt, "Plaus")
    plaus_d <- items_and_means(dt, "Plaus_distractor")
    cloze   <- items_and_means(dt, "Cloze")
    cloze_d <- items_and_means(dt, "Cloze_distractor")

    pl <- plot_density(plaus[[1]], plaus[[2]], ylab = "Plausibility", "Plaus", leg_labs, leg_vals, ylimits=c(1, 1.5))
    pl_d <- plot_density(plaus_d[[1]], plaus_d[[2]], ylab = "Plausibility", "Plaus_distractor", leg_labs, leg_vals, ylimits = c(1, 1.5))
    cl <- plot_density(cloze[[1]], cloze[[2]], ylab = "Cloze Probability", "Cloze", leg_labs, leg_vals, ylimits=c(1, 10))
    cl_d <- plot_density(cloze_d[[1]], cloze_d[[2]], ylab = "Cloze Probability", "Cloze_distractor", leg_labs, leg_vals)

    leg <- get_legend(pl)
    nl <- theme(legend.position = "none")
    gg <- arrangeGrob(arrangeGrob(pl + nl, pl_d + nl, cl + nl, cl_d + nl,
                    layout_matrix = matrix(1:4, ncol = 2)), 
                leg, heights = c(10, 1))
    ggsave("../Figures/Design2_Densities.pdf", gg, device = cairo_pdf,
            width = 7, height = 7)
}

plot_density <- function(data, data_means, ylab, predictor, leg_labs, leg_vals, ylimits) {
    p <- ggplot(data, aes_string(x = predictor, color = "Condition", fill = "Condition"))
    p <- p + geom_density(alpha = 0.4) + theme_minimal()
    p <- p + ylims(ylimits)
    p <- p + geom_vline(data = data_means, aes_string(xintercept = predictor,
                color = "Condition"), linetype = "dashed") +
                scale_x_continuous(breaks = seq(1, 7))
    p <- p + scale_color_manual(labels = leg_labs, values = leg_vals)
    p <- p + scale_fill_manual(labels = leg_labs, values = leg_vals)
    p <- p + labs(y = "Density", x = ylab)
    p <- p + theme(legend.position = "bottom")
    p
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
