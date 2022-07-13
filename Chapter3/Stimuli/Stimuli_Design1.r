# Christoph Aurnhammer, 2022
# Dissertation, Chapter 4
# Create density plots of Design 2 stimulus properties

source("../../code/plot_rERP.r")

quad_density <- function(path, file, leg_labs, leg_vals) {
    dt <- fread(path)

    cloze   <- items_and_means(dt, "Cloze")
    assoc_m <- items_and_means(dt, "Association_MC")
    assoc_n <- items_and_means(dt, "Association_Noun")
    assoc_v <- items_and_means(dt, "Association_Verb")

    cl <- plot_density(cloze[[1]], cloze[[2]],
            "Density", "Probability", "Cloze",
            leg_labs, leg_vals, c(0, 21), c(0, 0.25, 0.5, 0.75, 1))
    as_d <- plot_density(assoc_m[[1]], assoc_m[[2]],
            "Density", "Rating", "Association_MC",
            leg_labs, leg_vals, c(0, 1.5), c(1:7))
    as_n <- plot_density(assoc_n[[1]], assoc_n[[2]],
            "Density", "Rating",  "Association_Noun",
            leg_labs, leg_vals, c(0, 1.5), c(1:7))
    as_v <- plot_density(assoc_v[[1]], assoc_v[[2]],
            "Density", "Rating", "Association_Verb",
            leg_labs, leg_vals, c(0, 1.5), c(1:7))

    leg <- get_legend(cl)
    nl <- theme(legend.position = "none")
    ttlpos <- theme(plot.title = element_text(hjust = 0.5))
    gg <- arrangeGrob(arrangeGrob(
            cl + nl + ggtitle("Cloze Probability") + ttlpos,
            as_d + nl + ggtitle("Main Verb Associaton") + ttlpos,
            as_n + nl + ggtitle("Noun Association") + ttlpos,
            as_v + nl + ggtitle("Verb Association") + ttlpos,
            layout_matrix = matrix(1:4, ncol = 2)),
            leg, heights = c(10, 1))
    ggsave(file, gg, device = cairo_pdf, width = 7, height = 7)
}

quad_density(
    "../../data/Stimuli_Design1.csv",
    "../Figures/Stimuli/Design1_Densities.pdf",
    c("A: A+E+", "B: A-E+", "C: A+E-", "D: A-E-"),
    c("#000000", "#BB5566", "#004488", "#DDAA33")
)