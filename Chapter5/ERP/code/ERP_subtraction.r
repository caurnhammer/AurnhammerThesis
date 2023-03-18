# Christoph Aurnhammer, 2022
# Dissertation, Chapter 5
# Generate N400s bins by N400-Segment
library(data.table)
library(dplyr)
system("mkdir -p ../plots/Subtraction")
source("../../../code/plot_rERP.r")

# helper function to average data down to the level of one value per condition,
# per electrode, per time step. Works with one or more electrodes.
avg_quart_dt <- function(df, elec, add_grandavg = FALSE) {
    df_s_avg <- df[, lapply(.SD, mean), by = list(Subject, Quantile, Timestamp),
        .SDcols = elec]
    df_avg <- df_s_avg[, lapply(.SD, mean), by = list(Quantile, Timestamp),
        .SDcols = elec]
    df_avg[, paste0(elec, "_CI")] <- df_s_avg[, lapply(.SD, ci),
        by = list(Quantile, Timestamp), .SDcols = elec][,..elec]
    df_avg$Quantile <- as.factor(df_avg$Quantile)
    df_avg$Spec <- df_avg$Quantile
    df_avg <- df_avg[, c("Spec", "Timestamp", "Quantile", ..elec,
        paste0(..elec, "_CI"))]

    if (add_grandavg) {
        df_s_gavg <- df[, lapply(.SD, mean), by = list(Subject, Timestamp),
            .SDcols = elec]
        df_gavg <- df_s_gavg[, lapply(.SD, mean), by = list(Timestamp),
            .SDcols = elec]

        df_gavg[, paste0(elec, "_CI")] <- df_s_gavg[, lapply(.SD, ci),
            by = list(Timestamp), .SDcols = elec][,..elec]
        df_gavg$Quantile <- 42
        df_gavg$Spec <- df_gavg$Quantile
        df_avg <- rbind(df_avg, df_gavg)
    }

    df_avg
}

ci <- function(vec) {
    1.96 * se(vec)
}

# Load data of Aurnhammer et al. (2021)
dt <- fread("../../../data/ERP_Design1.csv")
elec <- "Pz"
cond <- c("A", "C")
# Condition plotting properties
cond_labels <- c("A: Expected", "C: Unexpected")
cond_values <- c("black", "#004488")
# Shared Quantile plotting properties
quart_labels <- c(1, 2, 3)
quart_values <- c("#E69F00", "black", "#009E73")

##########################
# Plot Design 1 Cond A/C #
##########################
dt_c_s <- dt[Condition %in% c("A", "C"), lapply(.SD, mean),
    by = list(Subject, Condition, Timestamp), .SDcols = elec]
dt_c <- dt_c_s[Condition %in% c("A", "C"), lapply(.SD, mean),
    by = list(Condition, Timestamp), .SDcols = elec]
dt_c$Pz_CI <- dt_c_s[Condition %in% c("A", "C"), lapply(.SD, ci),
    by = list(Condition, Timestamp), .SDcols = elec][,..elec]
dt_c$Spec <- dt_c$Condition
plot_single_elec(
    data = dt_c,
    e = elec,
    file = paste0("../plots/Subtraction/Design1_AC_Pz.pdf"),
    modus = "Condition",
    ylims = c(9, -5),
    leg_labs = cond_labels,
    leg_vals = cond_values)

############################
# Plot a few single trials #
############################
n <- 4
dt_condc <- dt[Condition %in% cond, ]
set.seed(420)
rand_trials <- sample(dt_condc$TrialNum, n)
dt_rtrials <- dt_condc[TrialNum %in% rand_trials,]
dt_rtrials$TrialNum <- factor(dt_rtrials$TrialNum)
p_list <- vector(mode = "list", length = length(n))
lims <- c(max(dt_rtrials$Pz), min(dt_rtrials$Pz))
for (i in 1:n) {
    single_trial <- dt_rtrials[TrialNum == unique(dt_rtrials$TrialNum)[i], ]
    p_list[[i]] <- ggplot(single_trial, 
            aes(x = Timestamp, y = Pz, color = TrialNum, group = TrialNum)) + 
            geom_line() +
            theme_minimal() + 
            scale_y_reverse(limits = c(lims[1], lims[2])) +
            theme(legend.position = "none") +
            scale_color_manual(values = "black") +
            geom_hline(yintercept = 0, linetype = "dashed") +
            geom_vline(xintercept = 0, linetype = "dashed") +
            stat_smooth(method = "lm", se = FALSE, linewidth = 0.5) +
            labs(y = paste0("Amplitude (", "\u03BC", "Volt\u29"), title = "Pz")
}
gg <- arrangeGrob(p_list[[1]] + labs(x = ""),
                  p_list[[2]] + labs(x = "", y = ""),
                  p_list[[3]] + labs(title = "") +
                  theme(plot.margin = margin(t = -20, r = 5, b = 0, l = 5)),
                  p_list[[4]] + labs(y = "", title = "") +
                  theme(plot.margin = margin(t = -20, r = 5, b = 0, l = 5)),
        layout_matrix = matrix(1:4, ncol = 2, byrow = TRUE))
ggsave("../plots/Subtraction/Design1_randtrials_AC_Pz.pdf", gg,
    device = cairo_pdf, width = 5, height = 5)

#####################################
# Plot Quantile bins computed from  #
# raw N400 per-trial averages       #
#####################################
dt_cond <- dt[Condition %in% cond,]
dt_cond$Trial <- paste(dt_cond$Item, dt_cond$Subject)
n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
    by = list(Trial, Subject, Item, Condition), .SDcols = elec]
n400$Quantile <- ntile(n400[,..elec], 3)
dt_cond <- merge(dt_cond, n400[, c("Trial", "Quantile")], on = "Trial")

dt_avg <- avg_quart_dt(dt_cond, elec)
plot_single_elec(
    data = dt_avg,
    e = elec,
    file = paste0("../plots/Subtraction/Subtraction_Design1_RawN400.pdf"),
    modus = "Quantile",
    ylims = c(18, -14),
    leg_labs = quart_labels,
    leg_vals = quart_values)

#####################################
# Plot Quantile bins computed from  #
# N400 - Segment per-trial averages #
#####################################
dt_cond <- dt[Condition %in% cond, ]
dt_cond$Trial <- paste(dt_cond$Item, dt_cond$Subject)

n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
    by = list(Trial), .SDcols = elec]
segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
    by = list(Trial), .SDcols = elec]
n4seg <- merge(n400, segment, by = "Trial")
colnames(n4seg)[2:3] <- c("N400", "Segment")
n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)
dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

dt_avg <- avg_quart_dt(dt_cond, elec)
plot_single_elec(
    data = dt_avg,
    e = elec,
    file = paste0("../plots/Subtraction/Subtraction_Design1_N400minusSegment.pdf"),
    modus = "Quantile",
    ylims = c(18, -14),
    leg_labs = quart_labels,
    leg_vals = quart_values)

##########################
# (Partial) Correlations #
##########################
dt_cond <- dt[Condition %in% cond, ]
dt_cond$Trial <- paste(dt_cond$Item, dt_cond$Subject)

n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
    by = list(Trial), .SDcols = elec]
colnames(n400)[2] <- "N400"
p600 <- dt_cond[(Timestamp > 600 & Timestamp < 1000), lapply(.SD, mean),
    by = list(Trial), .SDcols = elec]
colnames(p600)[2] <- "P600"
segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
    by = list(Trial), .SDcols = elec]
colnames(segment)[2] <- "Segment"

n4p6 <- merge(n400, p600, by = "Trial")
n4p6seg <- merge(n4p6, segment, by = "Trial")

round(cor(n4p6seg$N400, n4p6seg$P600), 3)

library(ppcor)
pcor.test(n4p6seg$N400, n4p6seg$P600, n4p6seg$Segment)

#####################
# DELOGU ET AL 2019 #
#####################
dt <- fread("../../../data/dbc19_data.csv")
elec <- "Pz"
cond <- "C"
# Condition plotting properties
cond_labels <- c("Baseline", "Event-rel.", "Event-unrel.")
cond_values <- c("black", "red", "blue")

# Condition averages
dt_s <- dt[, lapply(.SD, mean),
    by = list(Subject, Condition, Timestamp), .SDcols = elec]
dt_avg <- dt_s[, lapply(.SD, mean),
    by = list(Condition, Timestamp), .SDcols = elec]
dt_avg$Pz_CI <- dt_s[, lapply(.SD, ci),
    by = list(Condition, Timestamp), .SDcols = elec][,..elec]
dt_avg$Spec <- dt_avg$Condition
plot_single_elec(
    data = dt_avg, 
    e = elec,
    file = paste0("../plots/Subtraction/dbc19_Pz.pdf"),
    modus = "Condition",
    ylims = c(9, -5),
    leg_labs = cond_labels,
    leg_vals = cond_values)