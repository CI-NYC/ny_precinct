library(tidyverse)

dat <- read_csv("data/shootings_with_takedowns.csv") |>
  arrange(precinct, year, month) |>
  #select(precinct, year, cureOn, projectRestore, takedown) |>
  mutate(intervention_this_year_incl_takedown = case_when(cureOn == TRUE ~ 1,
                                                          projectRestore == TRUE ~ 1,
                                                          takedown == TRUE ~ 1,
                                                          yearCure == year ~ 1, 
                                                          is.na(months_since_takedown) == FALSE ~ 1,
                                                          TRUE ~ 0),
         intervention_this_year_no_takedown = case_when(cureOn == TRUE ~ 1,
                                                        projectRestore == TRUE ~ 1,
                                                        yearCure == year ~ 1, 
                                                        TRUE ~ 0))

## ALL precincts (including takedown)
grouped_dat_incl_takedown <- dat |>
  filter(!(precinct %in% c(43, 47, 49))) |>
  filter(intervention_this_year_incl_takedown == 1) |>
  group_by(precinct) |>
  summarize(min_year = min(year))

all_years <- sort(unique(dat$year))

full_grid <- expand.grid(precinct = unique(dat$precinct),
                         year = all_years) |>
  filter(!(precinct %in% c(43, 47, 49))) 

full_grid <- full_grid |>
  left_join(grouped_dat_incl_takedown, by = "precinct")

full_grid <- full_grid |>
  mutate(intervention_active = ifelse(!is.na(min_year) & year >= min_year, 1, 0))

summary_table_incl_takedown_all_precincts <- full_grid |>
  group_by(year) |>
  summarize(
    intervention_groups = sum(intervention_active),
    no_intervention_groups = n() - intervention_groups
  )

summary_table_incl_takedown_all_precincts_wide <- summary_table_incl_takedown_all_precincts |>
  pivot_longer(cols = c(intervention_groups, no_intervention_groups),
               names_to = "status",
               values_to = "count") |>
  pivot_wider(names_from = year, values_from = count)

## ALL precincts (no takedown)
grouped_dat_no_takedown <- dat |>
  filter(!(precinct %in% c(43, 47, 49))) |>
  filter(intervention_this_year_no_takedown == 1) |>
  group_by(precinct) |>
  summarize(min_year = min(year))

all_years <- sort(unique(dat$year))

full_grid <- expand.grid(precinct = unique(dat$precinct),
                         year = all_years) |>
  filter(!(precinct %in% c(43, 47, 49))) 

full_grid <- full_grid |>
  left_join(grouped_dat_no_takedown, by = "precinct")

full_grid <- full_grid |>
  mutate(intervention_active = ifelse(!is.na(min_year) & year >= min_year, 1, 0))

summary_table_no_takedown_all_precincts <- full_grid |>
  group_by(year) |>
  summarize(
    intervention_groups = sum(intervention_active),
    no_intervention_groups = n() - intervention_groups
  )

summary_table_no_takedown_all_precincts_wide <- summary_table_no_takedown_all_precincts |>
  pivot_longer(cols = c(intervention_groups, no_intervention_groups),
               names_to = "status",
               values_to = "count") |>
  pivot_wider(names_from = year, values_from = count)

## precincts of interest (including takedown)
grouped_dat_incl_takedown <- dat |>
  filter(precinct %in% c( "41", "42", "44", "48", "52", "25", "73",
                          "60", "67", "69", "70", "71", "101", "105", "113")) |>
  filter(intervention_this_year_incl_takedown == 1) |>
  group_by(precinct) |>
  summarize(min_year = min(year))

all_years <- sort(unique(dat$year))

full_grid <- expand.grid(precinct = unique(dat$precinct),
                         year = all_years) |>
  filter(precinct %in% c( "41", "42", "44", "48", "52", "25", "73",
                          "60", "67", "69", "70", "71", "101", "105", "113"))

full_grid <- full_grid |>
  left_join(grouped_dat_incl_takedown, by = "precinct")

full_grid <- full_grid |>
  mutate(intervention_active = ifelse(!is.na(min_year) & year >= min_year, 1, 0))

summary_table_incl_takedown_all_precincts <- full_grid |>
  group_by(year) |>
  summarize(
    intervention_groups = sum(intervention_active),
    no_intervention_groups = n() - intervention_groups
  )

summary_table_incl_takedown_all_precincts_wide <- summary_table_incl_takedown_all_precincts |>
  pivot_longer(cols = c(intervention_groups, no_intervention_groups),
               names_to = "status",
               values_to = "count") |>
  pivot_wider(names_from = year, values_from = count)

## precincts of interest (no takedown)
grouped_dat_no_takedown <- dat |>
  filter(precinct %in% c( "41", "42", "44", "48", "52", "25", "73",
                          "60", "67", "69", "70", "71", "101", "105", "113")) |>
  filter(intervention_this_year_no_takedown == 1) |>
  group_by(precinct) |>
  summarize(min_year = min(year))

all_years <- sort(unique(dat$year))

full_grid <- expand.grid(precinct = unique(dat$precinct),
                         year = all_years) |>
  filter(precinct %in% c( "41", "42", "44", "48", "52", "25", "73",
                          "60", "67", "69", "70", "71", "101", "105", "113"))

full_grid <- full_grid |>
  left_join(grouped_dat_no_takedown, by = "precinct")

full_grid <- full_grid |>
  mutate(intervention_active = ifelse(!is.na(min_year) & year >= min_year, 1, 0))

summary_table_no_takedown_all_precincts <- full_grid |>
  group_by(year) |>
  summarize(
    intervention_groups = sum(intervention_active),
    no_intervention_groups = n() - intervention_groups
  )

summary_table_no_takedown_all_precincts_wide <- summary_table_no_takedown_all_precincts |>
  pivot_longer(cols = c(intervention_groups, no_intervention_groups),
               names_to = "status",
               values_to = "count") |>
  pivot_wider(names_from = year, values_from = count)

# year-month combinations where there were no shootings don't exist in this data
dat |>
  filter(curePrecinct == TRUE) |>
  mutate(
  ym = paste(year, month, sep = "-"),
  init_ym = paste(yearCure, monthCure, sep = "-")
) %>%
  group_by(precinct) %>%
  mutate(
    init_exists = init_ym %in% ym
  ) %>%
  ungroup() %>%
  filter(!init_exists)

dat