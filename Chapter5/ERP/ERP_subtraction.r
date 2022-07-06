# Christoph Aurnhammer, 2022
# Dissertation, Chapter 5
# Generate N400s bins by N400-Segment
library(data.table)
library(dplyr)
library(ggplot2)
source("../../code/plot_rERP.r")

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
dt <- fread("../../data/ERP_Design1.csv")
elec <- "Cz"
cond <- "C"

# Shared plotting properties
quart_labels <- c(1, 2, 3, 4)
quart_values <- c("blue", "black", "red", "orange")

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
source("../../code/plot_rERP.r")
p <- plot_grandavg_ci(dt_avg, modus = "Quantile", ttl = "Raw N400 Quantiles (Cz)", leg_labs = quart_labels, leg_vals = quart_values)
p <- p + theme(legend.position = "bottom")
p
f <- "plots/Subtration_RawN400_Quantiles.pdf"
ggsave(f, p, device = cairo_pdf, width = 4, height = 4)

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
dta <- merge(dta, n4seg[, c("Trial", "Quantile")], on = "Trial")

dt_avg <- avg_quart_dt(dta, elec)
source("../../code/plot_rERP.r")
p <- plot_grandavg_ci(dt_avg, modus = "Quantile", ttl = "N400 - Segment Quantiles (Cz)", leg_labs = quart_labels, leg_val = quart_values)
p <- p + theme(legend.position = "bottom")
p
f <- "plots/Subtration_N400minusSegment_Quantiles.pdf"
ggsave(f, p, device = cairo_pdf, width = 4, height = 4)
