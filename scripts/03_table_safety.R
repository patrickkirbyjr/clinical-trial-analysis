# Script: 03_table_safety.R
# Purpose: Conduct safety analysis
# Author: Patrick Kirby Jr.

# load libraries
library(tidyverse)
library(gtsummary)

# load the safety dataset
adae <- read_csv("data/adae.csv")
adsl <- read_csv("data/adsl.csv")

# prepare data
adae_clean <- adae %>%
  filter(TRTEMFL == "Y") %>%
  distinct(USUBJID, TRT01P, AEDECOD)

# calculate true population
n_pop <- adsl %>%
  count(TRT01P) %>%
  deframe()

# build AE table
table_ae <- adae_clean %>%
  select(TRT01P, AEDECOD) %>%
  tbl_summary(
    by = TRT01P,
    label = list(AEDECOD ~ "Adverse Event (Preferred Term)"),
    sort = all_categorical() ~ "frequency"
  ) %>%
  modify_header(all_stat_cols() ~ "**{level}**\n(N = {n_pop[level]})") %>%
  bold_labels() %>%
  modify_caption("**Table 2: Incidence of Treatment-Emergent Adverse Events**")

# save the output
table_ae %>%
  as_gt() %>%
  gt::gtsave(filename = "outputs/table_ae_safety.png")
message("Safety table generated and saved to /outputs.")