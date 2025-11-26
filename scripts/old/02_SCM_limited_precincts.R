library(tidyverse)
library(augsynth)
library(readxl)

# getting case data
dat49 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 1) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(precinct = 49)

# dat47 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 2) |>
#   janitor::clean_names() |>
#   mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
#   mutate(precinct = 47)

dat43 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 3) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(precinct = 43)

merged_dat <- dat49 |>
  #merge(dat47, all = TRUE) |>
  merge(dat43, all = TRUE) |>
  pivot_longer(cols = c(suv_target_area, pcnt_other_areas), 
               names_to = "group", 
               values_to = "y") |>
  mutate(log_shootings = log(y + 1)) |>
  mutate(treated = ifelse(group == "suv_target_area", 1, 0)) |>
  mutate(treated_year = ifelse(treated == 1, 2015, 0)) |>
  arrange(treated, precinct, year) |>
  mutate(GROUP = as.numeric(paste0(precinct, treated)))

cases <- merged_dat |>
  filter(year >= 2006) |>
  select(precinct, GROUP, year, log_shootings, treated) |>
  mutate(intervention = ifelse(year > 2014 & treated == 1, 1, 0)) |>
  mutate(precinct = as.character(GROUP)) |>
  select(-c(GROUP, treated)) |>
  as.data.frame() |>
  filter(year <= 2018)

# getting control data
dat <- read_csv("data/shootings_with_takedowns.csv") |>
  arrange(precinct, year, month) |>
  mutate(precinct = as.character(precinct)) |>
  #select(precinct, year, cureOn, projectRestore, takedown) |>
  mutate(intervention_this_year_no_takedown = case_when(cureOn == TRUE ~ 1,
                                                        projectRestore == TRUE ~ 1,
                                                        yearCure == year ~ 1, 
                                                        TRUE ~ 0))  |>
  filter(year <= 2018)



grouped_dat <- dat |>
  group_by(year, precinct) |>
  summarize(log_shootings = log(sum(numShootings, na.rm = TRUE) + 1),
            intervention = ifelse(any(intervention_this_year_no_takedown), 1, 0)) |>
  group_by(precinct) |>
  mutate(any_intervention = ifelse(any(intervention == 1), 1, 0)) |>
  filter((any_intervention == 0)) |>
  select(-any_intervention)

all_combos <- expand_grid(
  precinct = unique(grouped_dat$precinct),
  year = 2006:2018
)

grouped_dat_full <- all_combos |>
  left_join(grouped_dat, by = c("precinct", "year")) |>
  ungroup() |>
  mutate(log_shootings = replace_na(log_shootings, 0),
         intervention = replace_na(0, 0)) |>
  merge(cases, all = TRUE) |>
  filter(year != 2014) |>
  filter(precinct %in% c( "41", "42", "44", "48", "52", "25", "73",
                          "60", "67", "69", "70", "71", "101", "105", "113",
                          "430", "490",
                          "431", "491"))

set.seed(5)

# SHOOTINGS
syn_shootings_new <- augsynth(log_shootings ~ intervention, 
                              unit = precinct, 
                              time = year,
                              data = grouped_dat_full,
                              progfunc = "ridge", 
                              scm = T, 
                              lambda = 0.003, 
                              fixedeff = T)

syn_shootings_summ_new <- summary(syn_shootings_new, inf_type = "jackknife+")
syn_shootings_summ_new
plot(syn_shootings_summ_new)

# SHOOTINGS PCT 43

grouped_dat_43 <- grouped_dat_full |>
  filter(precinct != "491")

syn_shootings_43 <- augsynth(log_shootings ~ intervention, 
                             unit = precinct, 
                             time = year,
                             data = grouped_dat_43,
                             progfunc = "ridge", 
                             scm = T, 
                             lambda = 0.003, 
                             fixedeff = T)

syn_shootings_summ_43 <- summary(syn_shootings_43, inf_type = "jackknife+")
syn_shootings_summ_43
plot(syn_shootings_summ_43)

# SHOOTINGS PCT 49

grouped_dat_49 <- grouped_dat_full |>
  filter(precinct != "431")

syn_shootings_49 <- augsynth(log_shootings ~ intervention, 
                             unit = precinct, 
                             time = year,
                             data = grouped_dat_49,
                             progfunc = "Ridge", 
                             scm = T, 
                             lambda = 0.003, 
                             fixedeff = T)

syn_shootings_summ_49 <- summary(syn_shootings_49, inf_type = "jackknife+")
syn_shootings_summ_49
plot(syn_shootings_summ_49)