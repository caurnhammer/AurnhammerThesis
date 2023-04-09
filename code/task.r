#' Christoph Aurnhammer 2023
#' aurnhammer@coli.uni-saarland.de
#'
#' This script computes task performance metrics (Accuracy and Reaction Time).
#' Grand metrics are computed from per-subject averages.
#' Per-condition metrics are computed from per-subject per-condition averages.
#' This means that the range of values can be larger per-condition than
#' in the overall metrics.
#'
#' EEG data is expected to have already undergone artefact rejection.
#' SPR data is subjected to data exclusion before computing
#' task metrics (see function definition for default thresholds).
#'
#' The script expects the columns:
#' Subject, Item, Condition, Accuracy, ReactionTime

library(data.table)

read_task_data <- function(
    path
) {
    # Print file info
    cat("\nFile: ", path, "\n")

    # Read data
    dt <- fread(path)

    # Compute exclusion rate for ERP data
    # !! This is only correct if there is no item which was always excluded
    if (grepl("ERP", path)) {
        before <- length(unique(dt$Subject)) * length(unique(dt$Item))
        after <- nrow(dt[, lapply(.SD, mean), by = list(Subject, Item),
                    .SDcols = "Pz"])
        diff_trial <- before - after
        cat("Excluded ", diff_trial, "out of", before, "TRIALS (",
            round(diff_trial * 100 / before, 2), "% )\n")
    }

    # Exclude trial for SPR data
    if (grepl("SPR", path)) {
        dt <- exclude_trial(dt[Region != "Pre-critical-2", ])
    }

    # For comprehension questions, not every trial had a task.
    # Trials without a task are excluded.
    # This assumes that trials without a task have is.na(Accuracy)
    dt <- dt[!is.na(dt$Accuracy)]

    # Aggregate data to 1 row == 1 trial
    # This avoids spurious weightings,
    # e.g. introduced by variable length EEG epochs
    dt <- dt[, lapply(.SD, mean), by = list(Subject, Item, Condition),
                    .SDcols = c("Accuracy", "ReactionTime")]

    return(dt[, c("Subject", "Item", "Condition", "Accuracy", "ReactionTime")])
}

exclude_trial <- function(
    dt,
    lower = 50,      # lower reading time threshold
    upper = 2500,    # upper reading time threshold
    lower_rc = 50,   # lower reaction time threshold
    upper_rc = 6000  # upper reaction time threshold
) {
    dt_out <- dt

    for (s in unique(dt$Subject)) {
        # Subset for current subject
        dts <- dt[Subject == s, ]

        for (i in unique(dt$Item)) {
            # subset for current item
            dtsi <- dts[Item == i, ]

            # If reaction time < lower_rc OR > upper_rc
            # -> Exclude entire trial
            # If reading time ON ANY REGION < lower OR > upper
            # -> exclude entire trial
            if (!is.na(dtsi[1, ]$Accuracy)) {
                if ((sum(dtsi$ReadingTime < lower) +
                    sum(dtsi$ReadingTime > upper) +
                    sum(dtsi[1,]$ReactionTime < lower_rc) +
                    sum(dtsi[1,]$ReactionTime > upper_rc))
                    > 0) {
                    exc_trial <- dtsi[1, ]$Trial
                    dt_out <- dt_out[(Subject != s | Item != i), ]
                }
            }
        }
    }

    before <- nrow(dt)
    after <- nrow(dt_out)
    diff <- before - after
    numreg <- length(unique(dt$Region))
    diff_trial <- diff / length(unique(dt$Region))

    cat("Excluded ", diff_trial, "out of", before / numreg, "TRIALS (",
        round(diff_trial * 100 / (before / numreg), 2), "% )\n")

    return(dt_out)
}

stats_condition <- function(
    dt
) {
    ## GRAND
    # Compute averages per subject
    dt_subject <- dt[, lapply(.SD, mean), by = list(Subject),
                    .SDcols = c("Accuracy", "ReactionTime")]

    ## PER CONDITION
    # Compute averages per subject & condition
    dt_subject_cond <- dt[, lapply(.SD, mean),
            by = list(Subject, Condition),
            .SDcols = c("Accuracy", "ReactionTime")]

    # Compute average / sd /range per condition from
    # per-subject & per-condition averages
    dt_cond <- dt_subject_cond[, lapply(.SD, mean),
            by = list(Condition),
            .SDcols = c("Accuracy", "ReactionTime")]
    dt_cond[,c("Accuracy_SD", "ReactionTime_SD")] <- dt_subject_cond[,
            lapply(.SD, sd),
            by = list(Condition),
            .SDcols = c("Accuracy", "ReactionTime")][, c("Accuracy",
                "ReactionTime")]
    dt_cond[,c("Accuracy_Range_Min", "Accuracy_Range_Max")] <- data.table(
            aggregate(Accuracy ~ Condition, dt_subject_cond, range))[, c(2, 3)]
    dt_cond[,c("ReactionTime_Range_Min",
            "ReactionTime_Range_Max")] <- data.table(
            aggregate(ReactionTime ~ Condition,
                    dt_subject_cond, range))[, c(2, 3)]

    # Format output
    colnames(dt_cond)[c(2, 3)] <- c("Accuracy_Mean", "ReactionTime_Mean")
    dt_cond[, c(2, 4, 6, 7)] <- round(dt_cond[, c(2, 4, 6, 7)] * 100, 1)
    dt_cond[, c(3, 5, 8, 9)] <- round(dt_cond[, c(3, 5, 8, 9)])

    ## Print per-condition stats
    # Accuracy
    cat("\nAccuracy:\n")
    cat("Condition\tMean\tSD\tRange\n")
    cat(paste("Grand\t", round(mean(dt_subject$Accuracy) * 100, 1),
        round(sd(dt_subject$Accuracy) * 100, 1),
        round(range(dt_subject$Accuracy)[1] * 100, 1),
        round(range(dt_subject$Accuracy)[2] * 100, 1), sep = "\t"), "\n")
    cat("--------------------------------------------\n")
    i <- 1
    for (cond in unique(dt$Condition)) {
        cat(paste(cond, "", dt_cond[i, ]$Accuracy_Mean,
            dt_cond[i, ]$Accuracy_SD,
            dt_cond[i, ]$Accuracy_Range_Min,
            dt_cond[i, ]$Accuracy_Range_Max, sep = "\t"), "\n")
        i <- i + 1
    }
    cat("--------------------------------------------\n")
    # ReactionTime
    cat("\nReaction Time:\n")
    cat("Condition\tMean\tSD\tRange\n")
    cat(paste("Grand\t", round(mean(dt_subject$ReactionTime)),
        round(sd(dt_subject$ReactionTime)),
        round(range(dt_subject$ReactionTime)[1]),
        round(range(dt_subject$ReactionTime)[2]), sep = "\t"), "\n")
    cat("--------------------------------------------\n")
    i <- 1
    for (cond in unique(dt$Condition)) {
        cat(paste(cond, "", dt_cond[i, ]$ReactionTime_Mean,
            dt_cond[i, ]$ReactionTime_SD,
            dt_cond[i, ]$ReactionTime_Range_Min,
            dt_cond[i, ]$ReactionTime_Range_Max, sep = "\t"), "\n")
        i <- i + 1
    }
    cat("--------------------------------------------\n")
}

print_task_stats <- function(
    path
) {
    dt <- read_task_data(path)
    stats_condition(dt)
}

print_task_stats("../data/ERP_Design1.csv")
print_task_stats("../data/SPR1_Design1.csv")
print_task_stats("../data/SPR2_Design1.csv")
print_task_stats("../data/SPR_Design2.csv")
print_task_stats("../data/ERP_Design2.csv")
