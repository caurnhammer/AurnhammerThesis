# Christoph Aurnhammer, 2022
# Dissertation, Chapter 5
# Generate N400s bins by N400-Segment
library(data.table)
library(dplyr)
source("../../../code/plot_rERP.r")

# helper function to average data down to the level of one value per condition,
# per electrode, per time step. Works with one or more electrodes.
avg_quart_dt <- function(df, elec){
    df_s_avg <- df[, lapply(.SD, mean), by = list(Subject, Quantile, Timestamp),
        .SDcols = elec]
    df_avg <- df_s_avg[, lapply(.SD, mean), by = list(Quantile, Timestamp),
        .SDcols = elec]
    df_avg[, paste0(elec, "_CI")] <- df_s_avg[, lapply(.SD, se),
        by = list(Quantile, Timestamp), .SDcols = elec][,..elec]
    df_avg$Quantile <- as.factor(df_avg$Quantile)
    df_avg$Spec <- df_avg$Quantile
    df_avg <- df_avg[, c("Spec", "Timestamp", "Quantile", ..elec,
        paste0(..elec, "_CI"))]

    df_avg
}

# Load data of Design 1, baseline condition
dt <- fread("../../../data/ERP_Design1.csv")
elec <- "Cz"
cond <- "C"
# Condition plotting properties
cond_labels <- c("A: Expected", "C: Unexpected")
cond_values <- c("black", "#004488")
# Shared Quantile plotting properties
quart_labels <- c(1, 2, 3, 4)
quart_values <- c("blue", "red", "orange", "black")

############################
# Plot a few single trials #
############################
n <- 4
dt_condc <- dt[Condition == "C",]
rand_trials <- sample(dt_condc$TrialNum, n)
dt_rtrials <- dt_condc[TrialNum %in% rand_trials,]
dt_rtrials$TrialNum <- factor(dt_rtrials$TrialNum)
p_list <- vector(mode = "list", length = length(n))
lims <- c(max(dt_rtrials$Cz), min(dt_rtrials$Cz))
for (i in 1:n) {
    single_trial <- dt_rtrials[TrialNum == unique(dt_rtrials$TrialNum)[i], ]
    p_list[[i]] <- ggplot(single_trial, aes(x = Timestamp, y = Cz,
            color = TrialNum, group = TrialNum)) + geom_line() +
            theme_minimal() + scale_y_reverse(limits = c(lims[1], lims[2])) +
            theme(legend.position = "none") +
            scale_color_manual(values = "black") +
            geom_hline(yintercept = 0, linetype = "dashed") +
            geom_vline(xintercept = 0, linetype = "dashed") +
            labs(y = paste0("Amplitude (", "\u03BC", "Volt\u29"), title = "Cz")
}
gg <- arrangeGrob(p_list[[1]] + labs(x = ""),
                  p_list[[2]] + labs(x = "", y = ""),
                  p_list[[3]] + labs(title = "") + theme(plot.margin = margin(t=-20, r=5, b=0, l=5)),
                  p_list[[4]] + labs(y = "", title = "") + theme(plot.margin = margin(t=-20, r=5, b=0, l=5)),
        layout_matrix = matrix(1:4, ncol = 2, byrow = TRUE))
ggsave("../plots/Subtraction/ERP_Design1_randtrials_Cz.pdf", gg,
    device = cairo_pdf, width = 5, height = 5)

##########################
# Plot Design 1 Cond A/C #
##########################
ci <- function(vec) {
    1.96 * se(vec)
}
dt_c_s <- dt[Condition %in% c("A", "C"), lapply(.SD, mean),
    by = list(Subject, Condition, Timestamp), .SDcols = c("Cz")]
dt_c <- dt[Condition %in% c("A", "C"), lapply(.SD, mean),
    by = list(Condition, Timestamp), .SDcols = c("Cz")]
dt_c$Cz_CI <- dt[Condition %in% c("A", "C"), lapply(.SD, ci),
    by = list(Condition, Timestamp), .SDcols = c("Cz")]$Cz
dt_c$Spec <- dt_c$Condition
plot_single_elec(dt_c, elec,
    file = paste0("../plots/Subtraction/ERP_Design1_AC_Cz.pdf"),
    modus = "Condition", ylims = c(9, -5.5),
    leg_labs = cond_labels, leg_vals = cond_values)

#####################################
# Plot Quantile bins computed from  #
# raw N400 per-trial averages       #
#####################################
dta <- dt[Condition == cond,]
dta$Trial <- paste(dta$ItemNum, dta$Subject)
elec <- "Cz"
n400 <- dta[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
    by = list(Trial, Subject, ItemNum, Condition, NumInSess), .SDcols = elec]
n400$Quantile <- ntile(n400[,..elec], 4)
dta <- merge(dta, n400[, c("Trial", "Quantile")], on = "Trial")

dt_avg <- avg_quart_dt(dta, elec)
plot_single_elec(dt_avg, elec,
    file = paste0("../plots/Subtraction/Subtration_RawN400_Quantiles.pdf"),
    modus = "Quantile", ylims = c(20, -20),
    leg_labs = quart_labels, leg_vals = quart_values)

#####################################
# Plot Quantile bins computed from  #
# N400 - Segment per-trial averages #
#####################################
dta <- dt[Condition == cond,]
dta$Trial <- paste(dta$ItemNum, dta$Subject)

n400 <- dta[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
    by = list(Trial), .SDcols = elec]
segment <- dta[(Timestamp > 0), lapply(.SD, mean),
    by = list(Trial), .SDcols = elec]
n4seg <- merge(n400, segment, by = "Trial")
colnames(n4seg)[2:3] <- c("N400", "Segment")
n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
n4seg$Quantile <- ntile(n4seg$N4minSeg, 4)
dta <- merge(dta, n4seg[, c("Trial", "Quantile")], by = "Trial")

dt_avg <- avg_quart_dt(dta, elec)
plot_single_elec(dt_avg, elec,
    file = paste0("../plots/Subtraction/Subtration_N400minusSegment_Quantiles.pdf"),
    modus = "Quantile", ylims = c(20, -20),
    leg_labs = quart_labels, leg_vals = quart_values)