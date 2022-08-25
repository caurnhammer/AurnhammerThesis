source("../../code/plot_rERP.r")

ci <- function(x) {
    1.96 * se(x)
}

data_labs <- c("A: Expected", "C: Unexpected")
data_vals <- c("#000000", "#004488")

dt <- fread("../../data/ERP_Design1.csv")
dt_ac <- dt[Condition %in% c("A", "C"), ]

dt_ac_sc <- dt_ac[, lapply(.SD, mean),
            by = list(Condition, Timestamp, Subject), .SDcols = c("Pz")]
dt_ac_c <- dt_ac_sc[, lapply(.SD, mean),
            by = list(Condition, Timestamp), .SDcols = c("Pz")]
dt_ac_c$Pz_CI <- dt_ac_sc[, lapply(.SD, ci),
            by = list(Condition, Timestamp), .SDcols = c("Pz")]$Pz

dt_ac_c$Spec <- dt_ac_c$Condition

ylimits <- c(10, -5.5)
p <- plot_single_elec(dt_ac_c, "Pz",
        file = FALSE,
        modus = "Condition", ylims = ylimits,
        leg_labs = data_labs, leg_vals = data_vals)

p <- p + annotate("rect", xmin = 300, xmax = 500, ymin = ylimits[2],
            ymax = ylimits[1], alpha = .15)
p <- p + annotate("text", x = 400, y = ylimits[2], label = "N400")
p <- p + annotate("rect", xmin = 600, xmax = 1000, ymin = ylimits[2],
            ymax = ylimits[1], alpha = .15)
p <- p + annotate("text", x = 800, y = ylimits[2], label = "P600")

gg <- p + theme(legend.key.size = unit(0.5, "cm"), #change legend key size
        legend.key.height = unit(0.5, "cm"), #change legend key height
        legend.key.width = unit(0.5, "cm"), #change legend key width
        legend.title = element_text(size = 9), #change legend title font size
        legend.text = element_text(size = 7))
gg <- gg + theme(plot.title = element_text(size = 7.5))
legend <- get_legend(gg)
nl <- theme(legend.position = "none")
gg <- arrangeGrob(gg + nl + ggtitle("Pz"),
            legend, heights = c(10, 1))

ggsave(file = "../plots/ERP_Design1_AC_Pz.pdf", gg,
    device = cairo_pdf, width = 3, height = 3)
