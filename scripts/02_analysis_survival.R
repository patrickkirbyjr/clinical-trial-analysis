# Script: 00_sim_data.R
# Purpose: Conduct survival analysis
# Author: Patrick Kirby Jr.

# load libraries
library(tidyverse)
library(survival)
library(survminer)

# load time-to-event dataset
adtte <- read_csv("data/adtte.csv")

# create EVNT column
adtte_clean <- adtte %>%
  filter(PARAMCD == "OS") %>%
  mutate(
    EVNT = if_else(CNSR == 0, 1, 0)
  )

# create survival object
surv_obj <- Surv(time = adtte_clean$AVAL, event = adtte_clean$EVNT)

# fit Kaplan-Meier curves
km_fit <- survfit(surv_obj ~ TRT01P, data = adtte_clean)

# log-rank to get p-value
log_rank_test <- survdiff(surv_obj ~ TRT01P, data = adtte_clean)

# print stats to console
print(km_fit)
print(log_rank_test)

# generate KM plot
km_plot <- ggsurvplot(
  km_fit,
  data = adtte_clean,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  risk.table.col = "strata",
  linetype = "strata",
  surv.median.linie = "hv",
  ggtheme = theme_minimal(),
  palette = c("#E7B800", "#2E9FDF"),
  title = "Kaplan-Meier Estimate of Overall Survival",
  xlab = "Time (Days)",
  ylab = "Survival Probability",
  legend.title = "Treatment",
  legend.labs = c("Investigational Drug", "Placebo")
)
print(km_plot)

# save output
png("outputs/km_curve_os.png", width = 1200, height = 800, res = 120)
print(km_plot)
dev.off()
message("Survival analysis complete. Plot saved to /outputs.")