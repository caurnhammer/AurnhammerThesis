library(data.table)
library(ggplot2)

data_file <- "ERP_Design1_A_logCloze_fulldata.csv"
data_file <- "ERP_Design1_B_logCloze_fulldata.csv"
data_file <- "ERP_Design1_C_logCloze_fulldata.csv"
data_file <- "ERP_Design1_D_logCloze_fulldata.csv"

data_file <- "ERP_Design1_AC_logCloze_fulldata.csv"
data_file <- "ERP_Design1_BD_logCloze_fulldata.csv"
data_file <- "ERP_Design1_AC_logCloze_reducedC_fulldata.csv"

data_file <- "ERP_Design1_AB_rcnoun_fulldata.csv"
data_file <- "ERP_Design1_CD_rcnoun_fulldata.csv"

data_file <- "ERP_Design1_AC_Cloze_fulldata.csv"
data_file <- "ERP_Design1_A_Cloze_fulldata.csv"
data_file <- "ERP_Design1_C_Cloze_fulldata.csv"

data_file <- "ERP_Design1_AC_CondCode_fulldata.csv"

data_file <- "ERP_Design1_ABCD_CondCode_fulldata.csv"

data_file <- "ERP_Design1_A_randpred_fulldata.csv"
data_file <- "ERP_Design1_AC_randpred_fulldata.csv"

data_file <- "ERP_Design2_ABC_Plaus_fulldata.csv"
data_file <- "ERP_Design2_A_Plaus_fulldata.csv"
data_file <- "ERP_Design2_B_Plaus_fulldata.csv"
data_file <- "ERP_Design2_C_Plaus_fulldata.csv"

dt <- fread(data_file)
x <- "logCloze"
x <- "Cloze"
x <- "CondCodeExp"
x <- "CondCodeAssoc"
x <- "CondCodeExp, :CondCodeAssoc"
x <- "rcnoun"
x <- "randpred"

resred <- dt[Type == "res" & Spec == "[:Intercept]", c(1:6)]
resred$Int <- dt[Type == "res" & Spec == "[:Intercept]", "Pz"]
resred$pred <- dt[Type == "res" & Spec == paste0("[:Intercept, :", x, "]"), "Pz"]
resred$red <- abs(resred$pred) - abs(resred$Int)
n4p6 <- data.table(n4=resred[Timestamp >= 300 & Timestamp <= 500, lapply(.SD, mean), by=list(Subject, Item), .SDcols = "red"]$red, p6=resred[Timestamp >= 600 & Timestamp <= 800, lapply(.SD, mean), by=list(Subject, Item), .SDcols="red"]$red)
ggplot(n4p6, aes(n4, p6)) + geom_point() + geom_smooth(method = "lm")

set.seed(98)
n4p6$p6permute <- n4p6[sample(seq(1:854))]$p6
ggplot(n4p6, aes(n4, p6permute)) + geom_point() + geom_smooth(method = "lm")

source("../../../code/plot_rERP.r")
mod <- fread("ERP_Design1_A_randpred_models.csv")
coef <- mod[Type == "Coefficient"]
# coef$Spec <- factor(plyr::mapvalues(coef$Spec, c("Intercept", "CondCodeExp", "CondCodeAssoc"),
    # c("Intercept", "CondCodeExp", "CondCodeAssoc")), levels = c("Intercept", "CondCodeExp", "CondCodeAssoc"))
model_labs <- c("Intercept", "randpred", "CondCodeAssoc")
model_vals <- c("black", "#E349F6", "cyan")
plot_single_elec(coef, "Pz", file = FALSE,
    title = "rERP coefficients",
    modus = "Coefficient", ylims = c(9, -5),
    leg_labs = model_labs, leg_vals = model_vals)

#######################################################

table(n4p6$n4 < 0, n4p6$p6 < 0) / nrow(n4p6)
cor(n4p6$n4, n4p6$p6)

plot(n4p6$n4[order(n4p6$n4)])
plot(n4p6$p6[order(n4p6$p6)])

# corr plot plus lm
# ggplot(n4p6, aes(n4, p6)) + geom_point() + geom_smooth(method = "lm") + lims(x=c(-22, 22),y=c(-22, 22))
ggplot(n4p6, aes(n4, p6)) + geom_point() + geom_smooth(method = "lm")

summary(lm(n4 ~ p6, n4p6))
summary(lm(p6 ~ n4, n4p6))

# Residual improvement over time
resred_ot <- resred[, lapply(.SD, mean), by = list(Timestamp), .SDcols = "red"]
ggplot(resred_ot, aes(Timestamp, red)) + geom_line()

meanabs_ot <- resred[, lapply(.SD, abs), by = list(Timestamp), .SDcols = "Int"][, lapply(.SD, mean), by=Timestamp, .SDcols="Int"]
ggplot(meanabs_ot, aes(Timestamp, Int)) + geom_line()

resred$abs <- abs(resred$pred)
meanabs_ot <- resred[, lapply(.SD, mean), by = list(Timestamp), .SDcols = "abs"]
ggplot(meanabs_ot, aes(Timestamp, abs)) + geom_line()
