# Script: 00_sim_data.R
# Purpose: Simulate CDISC-like clinical trial data
# Author: Patrick Kirby Jr.

# load the tidyverse
library(tidyverse)

# set seed for reproducability
set.seed(42)

# set number of patients
n_patients <- 200

# set start date
study_start_date <- as.Date("2024-01-01")


# ---------------------------------------------------------------------------
# generate subject level data (ADSL)
adsl <- tibble(
  
  # create unique IDs
  USUBJID = paste0("SUBJ-", sprintf("%03d", 1:n_patients)),
  
  # randomly assign to treatment or placebo with 50/50 chance
  TRT01P = sample(c("Placebo", "Investigational Drug"), n_patients, replace = TRUE),
  
  # randomly assign age between 45 and 80
  AGE = sample(45:80, n_patients, replace = TRUE),
  
  # randomly assign sex
  SEX = sample(c("M", "F"), n_patients, replace = TRUE),
  
  # randomly assign race
  RACE = sample(c("WHITE", "BLACK", "ASIAN", "OTHER"), n_patients, replace = TRUE, prob = c(0.7, 0.1, 0.1, 0.1)),

  # add baseline date reference
  TRTSDT = study_start_date
)

# ---------------------------------------------------------------------------
# generate efficacy data (ADTTE)

# generate survival times
adtte <- adsl %>%
  select(USUBJID, TRT01P, TRTSDT) %>%
  mutate(
    PARAMCD = "OS",
    PARAM = "Overall Survival",
    AVAL = case_when(
      TRT01P == "Investigational Drug" ~ rweibull(n(), shape = 1.5, scale = 18),
      TRT01P == "Placebo" ~ rweibull(n(), shape = 1.5, scale = 12)
    ),
    CNSR = rbinom(n(), size = 1, prob = 0.2),
    ADT = TRTSDT + round(AVAL, 0)
  )

# ---------------------------------------------------------------------------
# generate safety data (ADAE)

# create list of possible side effects
possible_aes <- c("Headache", "Nausea", "Fatigue", "Dizziness", "Rash")

adae <- adsl %>%
  select(USUBJID, TRT01P, TRTSDT) %>%
  mutate(
    n_aes = if_else(TRT01P == "Investigational Drug",
                    sample(0:3, n(), replace = TRUE, prob = c(0.1, 0.3, 0.4, 0.2)),
                    sample(0:2, n(), replace = TRUE, prob = c(0.6, 0.3, 0.1)))
  ) %>%
  filter (n_aes > 0) %>%
  uncount(n_aes) %>%
  mutate(
    AEDECOD = sample(possible_aes, n(), replace = TRUE),
    AESEV = sample(c("MILD", "MODERATE", "SEVERE"), n(), replace = TRUE),
    ASTDT = TRTSDT + sample(1:30, n(), replace = TRUE),
    TRTEMFL = "Y"
  )

# ---------------------------------------------------------------------------
# save data to CSV
write_csv(adsl, "data/adsl.csv")
write_csv(adtte, "data/adtte.csv")
write_csv(adae, "data/adae.csv")
message("Simulated data generation complete and written to /data folder.")







