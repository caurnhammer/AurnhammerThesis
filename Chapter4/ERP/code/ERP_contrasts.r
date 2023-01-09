library(data.table)
library(lmerTest)

elec <- c("F3", "Fz", "F4", "C3", "Cz", "C4", "P3", "Pz", "P4")

dt <- fread("../../../data/ERP_Design2.csv")

# Create difference of C to A&B (absence of semantic attraction) and difference of B to A&C (presence of conflict).
dt$SemAttContr_absence <- ifelse(dt$Condition == "C", 0.6666667, -0.3333333)
dt$SemAttContr_presence <- ifelse(dt$Condition == "B", 0.6666667, -0.3333333)

# Create three levels of plaus (A > B > C), corresponding to plaus across the three conditions
dt$PlausContr <- ifelse(dt$Condition == "C", -0.5, ifelse(dt$Condition == "A", 0.5, 0))

n4 <- dt[Timestamp >= 300 & Timestamp <= 500, lapply(.SD, mean), by=list(Item, Condition, Subject, SemAttContr_absence, SemAttContr_presence, PlausContr), .SDcols=elec]
n4$Elecavg <- rowMeans(n4[, ..elec])

p6 <- dt[Timestamp >= 600 & Timestamp <= 800, lapply(.SD, mean), by=list(Item, Condition, Subject,  SemAttContr_absence, SemAttContr_presence, PlausContr), .SDcols=elec]
p6$Elecavg <- rowMeans(p6[, ..elec])

summary(lmer(Elecavg ~ SemAttContr_absence + (1 + SemAttContr_absence | Subject) + (1 + SemAttContr_absence | Item), n4))
summary(lmer(Elecavg ~ SemAttContr_presence + (1 + SemAttContr_presence | Subject) + (1 + SemAttContr_presence | Item), p6))

summary(lmer(Elecavg ~ PlausContr + (1 + PlausContr | Subject) + (1 + PlausContr | Item), n4))
summary(lmer(Elecavg ~ PlausContr + (1 + PlausContr | Subject) + (1 + PlausContr | Item), p6))

summary(lmer(Elecavg ~ PlausContr + SemAttContr_absence + (1 + PlausContr+ SemAttContr_absence  | Subject) + (1 + PlausContr + SemAttContr_absence | Item), n4))
summary(lmer(Elecavg ~ PlausContr + SemAttContr_presence + (1 + PlausContr+ SemAttContr_presence  | Subject) + (1 + PlausContr + SemAttContr_presence | Item), p6))
