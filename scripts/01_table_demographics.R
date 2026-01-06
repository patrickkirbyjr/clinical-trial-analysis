# Script: 01_table_demographics.R
# Purpose: Generate a Table 1
# Author: Patrick Kirby Jr.

# load libraries
library(tidyverse)
library(gtsummary)

# load subject-level dataset
adsl <- read_csv("data/adsl.csv")

# select variables
adsl_clean <- adsl %>%
  select(TRT01P, AGE, SEX, RACE)

# create base table
table1 <- adsl_clean %>%
  tbl_summary(
    by = TRT01P,
    statistic = list(all_continuous() ~ "{mean} ({sd})"),
    label = list(
      AGE ~ "Age (Years)",
      SEX ~ "Sex",
      RACE ~ "Race"
    )
  )

# add p-values
table_1 <- table1 %>%
  add_p() %>%
  add_overall() %>%
  bold_labels() %>%
  modify_header(label = "**Characteristic**")

# save the output
table1 %>%
  as_gt() %>%
  gt::gtsave(filename = "outputs/table1_demographics.png")
message("Table 1 generated and saved to /outputs folder.")