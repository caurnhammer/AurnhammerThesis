# Christoph Aurnhammer, 2022
# Dissertation, Chapter 5
# Generate N400s bins by N400-Segment
library(data.table)
library(dplyr)
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

# Load data of Design 1, baseline condition
dt <- fread("../../../data/ERP_Design1.csv")
elec <- "Pz"
cond <- c("A", "C")
# Condition plotting properties
cond_labels <- c("A: Expected", "C: Unexpected")
cond_values <- c("black", "#004488")
# Shared Quantile plotting properties
quart_labels <- c(1, 2, 3)
quart_values <- c("#E69F00", "black", "#009E73")

############################
# Plot a few single trials #
############################
n <- 4
dt_condc <- dt[Condition %in% cond, ]
rand_trials <- sample(dt_condc$TrialNum, n)
dt_rtrials <- dt_condc[TrialNum %in% rand_trials,]
dt_rtrials$TrialNum <- factor(dt_rtrials$TrialNum)
p_list <- vector(mode = "list", length = length(n))
lims <- c(max(dt_rtrials$Pz), min(dt_rtrials$Pz))
for (i in 1:n) {
    single_trial <- dt_rtrials[TrialNum == unique(dt_rtrials$TrialNum)[i], ]
    p_list[[i]] <- ggplot(single_trial, aes(x = Timestamp, y = Pz,
            color = TrialNum, group = TrialNum)) + geom_line() +
            theme_minimal() + scale_y_reverse(limits = c(lims[1], lims[2])) +
            theme(legend.position = "none") +
            scale_color_manual(values = "black") +
            geom_hline(yintercept = 0, linetype = "dashed") +
            geom_vline(xintercept = 0, linetype = "dashed") +
            stat_smooth(method = "lm", se = FALSE, size = 0.5) +
            labs(y = paste0("Amplitude (", "\u03BC", "Volt\u29"), title = "Pz")
}
gg <- arrangeGrob(p_list[[1]] + labs(x = ""),
                  p_list[[2]] + labs(x = "", y = ""),
                  p_list[[3]] + labs(title = "") +
                  theme(plot.margin = margin(t = -20, r = 5, b = 0, l = 5)),
                  p_list[[4]] + labs(y = "", title = "") +
                  theme(plot.margin = margin(t = -20, r = 5, b = 0, l = 5)),
        layout_matrix = matrix(1:4, ncol = 2, byrow = TRUE))
ggsave("../plots/Subtraction/ERP_Design1_randtrials_AC_Pz.pdf", gg,
    device = cairo_pdf, width = 5, height = 5)
  
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
plot_single_elec(dt_c, elec,
    file = paste0("../plots/Subtraction/ERP_Design1_AC_Pz.pdf"),
    modus = "Condition", ylims = c(9, -5),
    leg_labs = cond_labels, leg_vals = cond_values)

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
plot_single_elec(dt_avg, elec,
    file = paste0("../plots/Subtraction/Subtraction_Design1_RawN400_Tertiles.pdf"),
    modus = "Quantile", ylims = c(18, -14),
    leg_labs = quart_labels, leg_vals = quart_values)

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
plot_single_elec(dt_avg, elec,
    file = paste0("../plots/Subtraction/Subtraction_Design1_N400minusSegment_Tertiles_AC.pdf"),
    modus = "Quantile", ylims = c(18, -14),
    leg_labs = quart_labels, leg_vals = quart_values)

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


######################
# BASELINE CONDITION #
######################
# dt_cond <- dt[Condition == "A", ]
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)

# n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# n4seg <- merge(n400, segment, by = "Trial")
# colnames(n4seg)[2:3] <- c("N400", "Segment")
# n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
# n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)

# n4seg$Quantile <- sample(rep(c(1, 2, 3), 1000), size=nrow(n4seg))
# n4seg$Quantile <- sample(c(rep(c(1,2,3), 284), c(1,2)))

# dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

# dt_avg <- avg_quart_dt(dt_cond, elec)
# plot_single_elec(dt_avg, elec,
#     file = paste0("../plots/Subtraction/Subtraction_Design1_N400minusSegment_Quartiles_A.pdf"),
#     modus = "Quantile", ylims = c(18, -14),
#     leg_labs = quart_labels, leg_vals = quart_values)


#####################
# DELOGU ET AL 2019 #
#####################
# dt <- fread("../../../data/dbc_data.csv")
# elec <- "Pz"
# cond <- "C"
# # Condition plotting properties
# cond_labels <- c("Baseline", "Event-rel.", "Event-unrel.")
# cond_values <- c("black", "red", "blue")

# # Condition averages
# dt_s <- dt[, lapply(.SD, mean),
#     by = list(Subject, Condition, Timestamp), .SDcols = elec]
# dt_avg <- dt_s[, lapply(.SD, mean),
#     by = list(Condition, Timestamp), .SDcols = elec]
# dt_avg$Pz_CI <- dt_s[, lapply(.SD, ci),
#     by = list(Condition, Timestamp), .SDcols = elec][,..elec]
# dt_avg$Spec <- dt_avg$Condition
# plot_single_elec(dt_avg, elec,
#     file = paste0("../plots/Subtraction/ERP_dbc19_Pz.pdf"),
#     modus = "Condition", ylims = c(9, -5),
#     leg_labs = cond_labels, leg_vals = cond_values)

# # Binning per condition
# conds <- c("control", "script-related", "script-unrelated")
# cond_alts <- c("Baseline", "Event-related", "Event-unrelated")
# for (i in c(1, 2, 3)) {
#     dt_cond <- dt[Condition == conds[i], ]
#     dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
#     n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     n4seg <- merge(n400, segment, by = "Trial")
#     colnames(n4seg)[2:3] <- c("N400", "Segment")
#     n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
#     n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)
#     dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

#     dt_avg <- avg_quart_dt(dt_cond, elec)
#     source("../../../code/plot_rERP.r")
#     print(cond_alts[i])
#     plot_single_elec(dt_avg, elec,
#         file = paste0("../plots/Subtraction/Subtraction_dbc19_N400minusSegment_Quantiles_", cond_alts[i], ".pdf"),
#         title = cond_alts[i],
#         modus = "Quantile", ylims = c(18, -14),
#         leg_labs = quart_labels, leg_vals = quart_values)
# }

##############
# VALIDATION #
##############

# Move through time
# dt_cond <- dt
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
# n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#     by = list(Trial, Condition), .SDcols = c(elec, "Cloze")]
# p600 <- dt_cond[(Timestamp > 600 & Timestamp < 800), lapply(.SD, mean),
#     by = list(Trial, Condition), .SDcols = c(elec, "Cloze")]
# segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# n4seg <- merge(n400, segment, by = "Trial")
# n4seg <- merge(n4seg, p600, by = "Trial")
# colnames(n4seg)[c(3,5,7)] <- c("N400", "Segment", "P600")
# n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
# n4seg$P6minSeg <- n4seg$P600 - n4seg$Segment
# # n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)

# n4seg$N4Quantile <- ntile(n4seg$N400, 2)
# n4seg$P6Quantile <- ntile(n4seg$Segment, 2)
# table(n4seg$N4Quantile, n4seg$P6Quantile)

# n4seg$N4Quantile <- ntile(n4seg$N400, 2)
# n4seg$P6Quantile <- ntile(n4seg$P600, 2)
# table(n4seg$N4Quantile, n4seg$P6Quantile)

# n4seg$N4Quantile <- ntile(n4seg$N4minSeg, 2)
# n4seg$P6Quantile <- ntile(n4seg$P600, 2)
# table(n4seg$N4Quantile, n4seg$P6Quantile)

# n4seg$N4Quantile <- ntile(n4seg$N4minSeg, 2)
# n4seg$P6Quantile <- ntile(n4seg$P6minSeg, 2)
# table(n4seg$N4Quantile, n4seg$P6Quantile)


# dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

# delogu within-condition plaus relation
# conds <- c("control", "script-related", "script-unrelated")
# cond_alts <- c("Baseline", "Event-related", "Event-unrelated")
# # tws <- seq(-100, 1000, 200)
# tws <- c(300, 800)
# for (tw in tws) {
#     # dt_cond <- dt[Condition == cond, ]
#     # dt_cond <- dt[Condition == "script-related", ]
#     #dt_cond <- dt[Condition == "script-unrelated", ]
#     dt_cond <- dt
#     dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
#     n400 <- dt_cond[(Timestamp > tw & Timestamp < (tw+200)), lapply(.SD, mean),
#         by = list(Trial, Condition), .SDcols = c(elec, "Plaus")]
#     segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     n4seg <- merge(n400, segment, by = "Trial")
#     colnames(n4seg)[c(3,5)] <- c("N400", "Segment")
#     n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
#     n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)
#     dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

#     print(c(tw, tw+200))
#     print(cor(n4seg$Plaus, n4seg$N4minSeg))
#     print(cor(n4seg$Plaus, n4seg$N400))
#     print(summary(lm(Plaus ~ N4minSeg, n4seg)))
    
#     dt_avg <- avg_quart_dt(dt_cond, elec)
#     source("../../../code/plot_rERP.r")
#     plot_single_elec(dt_avg, elec,
#         file = paste0("../plots/Subtraction/Subtraction_dbc19_N400minusSegment_Quantiles_", tw, "_", tw+200, ".pdf"),
#         title = cond_alts[i],
#         modus = "Quantile", ylims = c(18, -14),
#         leg_labs = quart_labels, leg_vals = quart_values)
# }


# # Show single trials in extreme bins
# dt_cond <- dt[Condition == "A", ]
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)

# n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# n4seg <- merge(n400, segment, by = "Trial")
# colnames(n4seg)[2:3] <- c("N400", "Segment")
# n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
# n4seg$Quantile <- ntile(n4seg$N4minSeg, 5)
# dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

# dt_ex <- dt_cond[Quantile == 5,]
# dt_tex <- dt_ex[sample(unique(dt_ex$Trial),1),]
# ggplot(dt_tex, aes(x=Timestamp, y=Pz)) + geom_line() + scale_y_reverse() + theme_minimal()

# dt_ex <- dt_cond[Quantile == 1,]
# dt_tex <- dt_ex[sample(unique(dt_ex$Trial),1),]
# ggplot(dt_tex, aes(x=Timestamp, y=Pz)) + geom_line() + scale_y_reverse() + theme_minimal()

# # Move through time
# tws <- seq(-100, 1000, 200)
# for (tw in tws){
#     #dt_cond <- dt[Condition == "A"]
#     dt_cond <- dt
#     dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
#     n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#         by = list(Trial, Condition), .SDcols = c(elec, "Cloze")]
#     p600 <- dt_cond[(Timestamp > 600 & Timestamp < 800), lapply(.SD, mean),
#         by = list(Trial, Condition), .SDcols = c(elec, "Cloze")]
#     segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     n4seg <- merge(n400, segment, by = "Trial")
#     n4seg <- merge(n4seg, p600, by = "Trial")
#     colnames(n4seg)[c(3,5,7)] <- c("N400", "Segment", "P600")
#     n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
#     n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)
#     dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

#     print(c(tw, tw+200))
#     # print(table(n4seg$Quantile, n4seg$Condition))
#     #print(cor(n4seg$Cloze, n4seg$Quantile))
#     #print(cor(n4seg$Cloze, n4seg$N4minSeg))
#     print(summary(lm(Cloze ~ N4minSeg, n4seg)))

#     # pdf(paste0("../plots/Subtraction/Heatmap_QuantilesCond_", tw, ".pdf"))
#     # n4seg$Condition <- factor(n4seg$Condition, levels=c("A", "B", "C", "D"))
#     # heatmap(table(n4seg$Quantile, n4seg$Condition), Rowv = NA, Colv = NA)
#     # dev.off()

#     dt_avg <- avg_quart_dt(dt_cond, elec)
#     plot_single_elec(dt_avg, elec,
#         file = paste0("../plots/Subtraction/Subtraction_Design1_N400minusSegment_Quartiles_", tw, ".pdf"),
#         modus = "Quantile", ylims = c(18, -14),
#         leg_labs = quart_labels, leg_vals = quart_values)
# }

# # RELATION OF THE BINS TO CLOZE PROBABILITY
# # RAW
# dt_cond <- dt[Condition == "A",]
# #dt_cond <- dt
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
# n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#     by = list(Trial, Subject, ItemNum, Condition, NumInSess), .SDcols = c(elec, "Cloze")]
# n400$Quantile <- ntile(n400[,..elec], 3)
# dt_cond <- merge(dt_cond, n400[, c("Trial", "Quantile", "Cloze")], on = "Trial")
# dt_trial <- dt_cond[, lapply(.SD, mean), by = list(Trial), .SDcols=c("Cloze", "Quantile")]
# cor(dt_trial$Cloze, dt_trial$Quantile)

# summary(lm(Cloze ~ scale(Quantile), n400))

# # SUBTRACTION
# dt_cond <- dt[Condition == "A"]
# #dt_cond <- dt
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
# n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#     by = list(Trial), .SDcols = c(elec, "Cloze")]
# n4seg <- merge(n400, segment, by = "Trial")
# colnames(n4seg)[2:3] <- c("N400", "Segment")
# n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
# n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)
# dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")
# dt_trial <- dt_cond[, lapply(.SD, mean), by = list(Trial, Condition), .SDcols=c("Cloze", "Quantile", "Pz")]
# cor(dt_trial$Cloze, dt_trial$Quantile)

# summary(lm(Cloze ~ scale(Quantile), n4seg))
# summary(lm(Cloze ~ scale(N400), n4seg))
# summary(lm(Cloze ~ scale(N4minSeg), n4seg))


# summary(lm(N400 ~ scale(Cloze), n4seg))
# summary(lm(N4minSeg ~ scale(Cloze), n4seg))

# ########
# # Correlation of N400 to Segment and N4minSeg to Segment
# dt_cond <- dt[Condition == "A", ]
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)

# n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#     by = list(Trial), .SDcols = c(elec, "Cloze")]
# n4seg <- merge(n400, segment, by = "Trial")
# colnames(n4seg)[2:3] <- c("N400", "Segment")
# n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
# n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)
# dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

# dt_trial <- dt_cond[, lapply(.SD, mean), by = list(Trial, Condition), .SDcols=c("Cloze", "Quantile", "Pz")]

# cor(n4seg$N400, n4seg$Segment)
# cor(n4seg$N4minSeg, n4seg$Segment)

# sl <- 57
# ggsave(ggplot(n4seg, aes(x=N400, y=Segment)) + geom_point(size=0.5) + theme_minimal() + lims(x=c(-sl, sl), y=c(-sl, sl)), file="/Users/chr/Desktop/N4_Segment.pdf", device=cairo_pdf, width=5, height=5)
# ggsave(ggplot(n4seg, aes(x=N4minSeg, y=Segment)) + geom_point(size=0.5) + theme_minimal() + lims(x=c(-sl, sl), y=c(-sl, sl)), file="/Users/chr/Desktop/N4minSeg_Segment.pdf", device=cairo_pdf, width=5, height=5)

# ggsave(ggplot(n4seg, aes(x=N400, y=Cloze)) + geom_point() + theme_minimal(), file="/Users/chr/Desktop/N4_Cloze.pdf", device=cairo_pdf, width=5, height=5)
# ggsave(ggplot(n4seg, aes(x=N4minSeg, y=Cloze)) + geom_point() + theme_minimal(), file="/Users/chr/Desktop/N4minSeg_Cloze.pdf", device=cairo_pdf, width=5, height=5)

# # raw P6
# dt_cond <- dt[Condition == "A",]
# #dt_cond <- dt
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
# p600 <- dt_cond[(Timestamp > 600 & Timestamp < 800), lapply(.SD, mean),
#     by = list(Trial, Subject, ItemNum, Condition, NumInSess), .SDcols = c(elec, "Cloze")]
# p600$Quantile <- ntile(p600[,..elec], 3)
# dt_cond <- merge(dt_cond, p600[, c("Trial", "Quantile", "Cloze")], on = "Trial")
# dt_trial <- dt_cond[, lapply(.SD, mean), by = list(Trial), .SDcols=c("Cloze", "Quantile")]
# cor(dt_trial$Cloze, dt_trial$Quantile)

# summary(lm(Cloze ~ scale(Quantile), p600))

# dt_avg <- avg_quart_dt(dt_cond, elec)
# plot_single_elec(dt_avg, elec,
#     file = paste0("../plots/Subtraction/Subtraction_Design1_RawP600_Tertiles_A.pdf"),
#     modus = "Quantile", ylims = c(18, -14),
#     leg_labs = quart_labels, leg_vals = quart_values)


# # P6-Segment
# dt_cond <- dt[Condition == "A", ]
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)

# p600 <- dt_cond[(Timestamp > 800 & Timestamp < 1000), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# segment <- dt_cond[(Timestamp > 0 & Timestamp < 1200), lapply(.SD, mean),
#     by = list(Trial), .SDcols = c(elec, "Cloze")]
# p6seg <- merge(p600, segment, by = "Trial")
# colnames(p6seg)[2:3] <- c("P600", "Segment")
# p6seg$P6minSeg <- p6seg$P600 - p6seg$Segment
# p6seg$Quantile <- ntile(p6seg$P6minSeg, 3)
# dt_cond <- merge(dt_cond, p6seg[, c("Trial", "Quantile")], by = "Trial")

# dt_trial <- dt_cond[, lapply(.SD, mean), by = list(Trial, Condition), .SDcols=c("Cloze", "Quantile", "Pz")]

# cor(p6seg$P600, p6seg$Segment)
# cor(p6seg$P6minSeg, p6seg$Segment)

# summary(lm(Cloze ~ scale(Quantile), p6seg))

# summary(lm(Cloze ~ scale(P6minSeg), p6seg))
# summary(lm(P600 ~ scale(Cloze), p6seg))
# summary(lm(P6minSeg ~ scale(Cloze), p6seg))

# summary(lm(Cloze ~ scale(Segment), p6seg))
# summary(lm(Cloze ~ scale(P600), p6seg))
# summary(lm(Cloze ~ scale(P6minSeg), p6seg))

# dt_avg <- avg_quart_dt(dt_cond, elec)
# plot_single_elec(dt_avg, elec,
#     file = paste0("../plots/Subtraction/Subtraction_Design1_P600minusSegment_Tertiles_A.pdf"),
#     modus = "Quantile", ylims = c(18, -14),
#     leg_labs = quart_labels, leg_vals = quart_values)

# sl <- 57
# ggsave(ggplot(p6seg, aes(x=P600, y=Segment)) + geom_point(size=0.5) + theme_minimal() + lims(x=c(-sl, sl), y=c(-sl, sl)), file="/Users/chr/Desktop/P6_Segment.pdf", device=cairo_pdf, width=5, height=5)
# ggsave(ggplot(p6seg, aes(x=P6minSeg, y=Segment)) + geom_point(size=0.5) + theme_minimal() +  lims(x=c(-sl, sl), y=c(-sl, sl)), file="/Users/chr/Desktop/P6minSeg_Segment.pdf", device=cairo_pdf, width=5, height=5)


# # Simu stuff
# reso <- 700
# simu <- data.table(Trial = rep(0, reso * 1000), Time = rep(seq(-200, 1198, length=reso), 1000), Data = rep(0, reso * 1000))
# j <- 1
# for (i in seq(1, 1000)) {
#     simu[j:(j+reso-1), "Trial"] <- i
#     simu[j:(j+reso-1), "Data"] <- seq(0, sample(seq(-10, 10), 1), length = reso)
#     j <- j + reso
# }
# simu

# # raw n4
# sim <- simu
# simn4seg <- sim[(Time > 300 & Time < 500), lapply(.SD, mean),
#     by = list(Trial), .SDcols = "Data"]
# simn4seg$Quantile <- ntile(simn4seg[,"Data"], 3)
# sim <- merge(sim, simn4seg[, c("Trial", "Quantile")], on = "Trial")
# sim_avg <- sim[, lapply(.SD, mean), by=list(Time, Quantile), .SDcols = "Data"]
# sim_avg$Quantile <- as.factor(sim_avg$Quantile)
# p <- ggplot(sim_avg, aes(x=Time, y=Data, color=Quantile)) + geom_line() + scale_y_reverse() + theme_minimal()
# ggsave(p, file="/Users/chr/Desktop/sim_rawbins.pdf", device=cairo_pdf, width=5, height=5)

# # subtraction
# sim <- simu
# n400 <- sim[(Time > 300 & Time < 500), lapply(.SD, mean),
#     by = list(Trial), .SDcols = "Data"]
# segment <- sim[Time > 0, lapply(.SD, mean),
#     by = list(Trial), .SDcols = "Data"]
# simn4seg <- merge(n400, segment, by = "Trial")
# colnames(simn4seg)[2:3] <- c("N400", "Segment")
# simn4seg$N4minSeg <- simn4seg$N400 - simn4seg$Segment
# simn4seg$Quantile <- ntile(simn4seg$N4minSeg, 3)
# sim <- merge(sim, simn4seg[, c("Trial", "Quantile")], by = "Trial")
# sim_avg <- sim[, lapply(.SD, mean), by=list(Time, Quantile), .SDcols = "Data"]
# sim_avg$Quantile <- as.factor(sim_avg$Quantile)
# p <- ggplot(sim_avg, aes(x=Time, y=Data, color=Quantile)) + geom_line() + scale_y_reverse() + theme_minimal()
# ggsave(p, file="/Users/chr/Desktop/sim_subtractionbins.pdf", device=cairo_pdf, width=5, height=5)

# myvec <- seq(100, 1100, length.out = 11)
# myvec <- c(0, (myvec))
# t <- 2
# print(simu[Trial==t, "Data"])
# for (i in myvec) {
#     roi <- mean(simu[Trial == t & Time > i & Time < (i + 100),]$Data) 
#     seg <- mean(simu[Trial == t & Time > 0,]$Data)
#     sub <- roi - seg
#     print(c(roi, seg, sub))
# }
# # -> for a positive drifting trial, the subtraction biases the bin to be too negative for early time-windows 
# # and too positive for later time-windows (vice versa for a negative drifting trial).
# # This only affects bin assignment and does not alter the data being shown.

# dt_cond <- dt
# dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)
# n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#     by = list(Trial, Condition), .SDcols = elec]
# segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#     by = list(Trial), .SDcols = c(elec, "Cloze")]
# n4seg <- merge(n400, segment, by = "Trial")
# colnames(n4seg)[3:4] <- c("N400", "Segment")
# n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
# n4seg$Quantile <- ntile(n4seg$N4minSeg, 3)

# p600 <- dt_cond[(Timestamp > 600 & Timestamp < 800), lapply(.SD, mean),
#     by = list(Trial), .SDcols = elec]
# segment <- dt_cond[(Timestamp > 0 & Timestamp < 1200), lapply(.SD, mean),
#     by = list(Trial), .SDcols = c(elec, "Cloze")]
# p6seg <- merge(p600, segment, by = "Trial")
# colnames(p6seg)[2:3] <- c("P600", "Segment")
# p6seg$P6minSeg <- p6seg$P600 - p6seg$Segment

# n4p6seg <- merge(n4seg, p6seg[, c("Trial", "P600", "P6minSeg")], on="Trial")
# fwrite(n4p6seg, "/Users/chr/Desktop/n4p6seg.csv")

# ---------------------> attic

#######################################
# Within-condition N400-P600 dynamics #
# shown for all conditions            #
#######################################
# original condition complex
# dt <- fread("../../../data/ERP_Design1.csv")
# elec <- "Pz"
# cond_labels <- c("A: E+A+", "B: E+A-", "C: E-A+", "D: E-A-")
# cond_values <- c("#000000", "#BB5566", "#004488", "#DDAA33")
# dt_s <- dt[, lapply(.SD, mean),
#     by = list(Subject, Condition, Timestamp), .SDcols = elec]
# dt_all <- dt[, lapply(.SD, mean),
#     by = list(Condition, Timestamp), .SDcols = elec]
# dt_all$Pz_CI <- dt[, lapply(.SD, ci),
#     by = list(Condition, Timestamp), .SDcols = elec][,..elec]
# dt_all$Spec <- dt_all$Condition
# plot_single_elec(dt_all, elec,
#     file = paste0("../plots/Subtraction/ERP_Design1_ABCD_Pz.pdf"),
#     modus = "Condition", ylims = c(9, -5),
#     leg_labs = cond_labels, leg_vals = cond_values)

# # Show condition average + two subtraction-based quantiles within condition
# quart_labels <- c("Avg.", "Low Quant", "High Quant")
# quart_values <- c("solid", "dotted", "dashed")
# cond_colos <- c("#000000", "#BB5566", "#004488", "#DDAA33")

# source("../../../code/plot_rERP.r")

# for (cond in c("A", "B", "C", "D")) {
#     dt_cond <- dt[Condition == cond, ]
#     dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)

#     n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     n4seg <- merge(n400, segment, by = "Trial")
#     colnames(n4seg)[2:3] <- c("N400", "Segment")
#     n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
#     n4seg$Quantile <- ntile(n4seg$N4minSeg, 2)
#     dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

#     dt_avg <- avg_quart_dt(dt_cond, elec, add_grandavg = TRUE)
#     dt_avg$Spec <- ifelse(dt_avg$Spec == 42, "Average", ifelse(dt_avg$Spec == 1, "Low Quant", "High Quant"))
#     dt_avg$ConditionQuantile <- dt_avg$Quantile
#     dt_avg$Condition <- cond

#     source("../../../code/plot_rERP.r")
#     plot_single_elec(dt_avg, elec,
#         file = paste0("../plots/Subtraction/Subtraction_Design1_N400minusSegment_Quantiles_", cond, ".pdf"),
#         modus = "ConditionQuantile", ylims = c(13, -7),
#         leg_labs = quart_labels, leg_vals = quart_values, ci = FALSE)

#     if (cond == "A") {
#         dt_out <- dt_avg
#     } else {
#         dt_out <- rbind(dt_out, dt_avg)
#     }
# }

# source("../../../code/plot_rERP.r")
# plot_single_elec(dt_out, elec,
#     file = paste0("../plots/Subtraction/Subtraction_Design1_N400minusSegment_Quantiles_Conds.pdf"),
#     modus = "ConditionQuantile", ylims = c(13, -7),
#     leg_labs = quart_labels, leg_vals = quart_values, ci = FALSE)

# # DESIGN 2
# dt <- fread("../../../data/ERP_Design2.csv")
# elec <- "Pz"
# cond_labels <- c("A", "B", "C")
# cond_values <- c("#000000", "red", "blue")
# dt_s <- dt[, lapply(.SD, mean),
#     by = list(Subject, Condition, Timestamp), .SDcols = elec]
# dt_all <- dt[, lapply(.SD, mean),
#     by = list(Condition, Timestamp), .SDcols = elec]
# dt_all$Pz_CI <- dt[, lapply(.SD, ci),
#     by = list(Condition, Timestamp), .SDcols = elec][,..elec]
# dt_all$Spec <- dt_all$Condition
# plot_single_elec(dt_all, elec,
#     file = paste0("../plots/Subtraction/ERP_Design2_ABC_Pz.pdf"),
#     modus = "Condition", ylims = c(9, -5),
#     leg_labs = cond_labels, leg_vals = cond_values)

# # Show condition average + two subtraction-based quantiles within condition
# quart_labels <- c("Avg.", "Low Quant", "High Quant")
# quart_values <- c("solid", "dotted", "dashed")

# for (cond in c("A", "B", "C")) {
#     dt_cond <- dt[Condition == cond, ]
#     dt_cond$Trial <- paste(dt_cond$ItemNum, dt_cond$Subject)

#     n400 <- dt_cond[(Timestamp > 300 & Timestamp < 500), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     segment <- dt_cond[(Timestamp > 0), lapply(.SD, mean),
#         by = list(Trial), .SDcols = elec]
#     n4seg <- merge(n400, segment, by = "Trial")
#     colnames(n4seg)[2:3] <- c("N400", "Segment")
#     n4seg$N4minSeg <- n4seg$N400 - n4seg$Segment
#     n4seg$Quantile <- ntile(n4seg$N4minSeg, 2)
#     dt_cond <- merge(dt_cond, n4seg[, c("Trial", "Quantile")], by = "Trial")

#     dt_avg <- avg_quart_dt(dt_cond, elec, add_grandavg = TRUE)
#     dt_avg$Spec <- ifelse(dt_avg$Spec == 42, "Average", ifelse(dt_avg$Spec == 1, "Low Quant", "High Quant"))
#     dt_avg$ConditionQuantile <- dt_avg$Quantile
#     dt_avg$Condition <- cond

#     source("../../../code/plot_rERP.r")
#     plot_single_elec(dt_avg, elec,
#         file = paste0("../plots/Subtraction/Subtraction_Design2_N400minusSegment_Quantiles_", cond, ".pdf"),
#         modus = "ConditionQuantile", ylims = c(13, -7),
#         leg_labs = quart_labels, leg_vals = quart_values, ci = FALSE)

#     if (cond == "A") {
#         dt_out <- dt_avg
#     } else {
#         dt_out <- rbind(dt_out, dt_avg)
#     }
# }

# source("../../../code/plot_rERP.r")
# plot_single_elec(dt_out, elec,
#     file = paste0("../plots/Subtraction/Subtraction_Design2_N400minusSegment_Quantiles_Conds.pdf"),
#     modus = "ConditionQuantile", ylims = c(13, -7),
#     leg_labs = quart_labels, leg_vals = quart_values, ci = FALSE)
