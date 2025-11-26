library(tidyverse)
library(augsynth)
library(readxl)

# getting case data
dat49 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 1) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(precinct = 49)

dat47 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 2) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(precinct = 47)

dat43 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 3) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(precinct = 43)

merged_dat <- dat49 |>
  merge(dat47, all = TRUE) |>
  merge(dat43, all = TRUE) |>
  pivot_longer(cols = c(suv_target_area, pcnt_other_areas), 
               names_to = "group", 
               values_to = "y") |>
  mutate(log_shootings = log(y + 1)) |>
  mutate(treated = ifelse(group == "suv_target_area", 1, 0)) |>
  mutate(treated_year = ifelse(treated == 1, 2015, 0)) |>
  arrange(treated, precinct, year) |>
  mutate(GROUP = as.numeric(paste0(precinct, treated))) |>
  mutate(group = ifelse(group == "pcnt_other_areas", "Other Area", "SUV Target Area")) 

merged_dat_sub <- merged_dat |>
  filter(year <= 2020)

plot <- ggplot(merged_dat, aes(x = year, y = y, color = group)) +
  geom_line(size = 1) +
  facet_wrap(~ precinct) +
  theme_minimal() +
  labs(
    x = "Year",
    y = "Shootings",
    color = "Intervention"
  ) +
  theme(legend.position = c(0.75, 0.75),
        legend.box.background = element_rect(
          color = "black", fill = "gray95", linewidth = 1
        ))

ggsave(filename = "figures_overleaf_111725/raw_shootings.pdf",
       width = 9,
       height = 6,
       units = "in",
       plot = plot)

cases <- merged_dat |>
  filter(year >= 2006) |>
  select(precinct, GROUP, year, log_shootings, y, treated) |>
  mutate(intervention = ifelse(year > 2014 & treated == 1, 1, 0)) |>
  mutate(precinct = as.character(GROUP)) |>
  select(-c(GROUP, treated)) |>
  as.data.frame() |>
  filter(year <= 2020)

# getting control data
dat <- read_csv("data/shootings_with_takedowns.csv") |>
  arrange(precinct, year, month) |>
  mutate(precinct = as.character(precinct)) |>
  #select(precinct, year, cureOn, projectRestore, takedown) |>
  mutate(intervention_this_year_no_takedown = case_when(cureOn == TRUE ~ 1,
                                                        projectRestore == TRUE ~ 1,
                                                        yearCure == year ~ 1, 
                                                        TRUE ~ 0))  |>
  filter(year <= 2020)

grouped_dat <- dat |>
  group_by(year, precinct) |>
  summarize(log_shootings = log(sum(numShootings, na.rm = TRUE) + 1),
            y = sum(numShootings, na.rm = TRUE),
            intervention = ifelse(any(intervention_this_year_no_takedown), 1, 0)) |>
  group_by(precinct) |>
  mutate(any_intervention = ifelse(any(intervention == 1), 1, 0)) |>
  filter((any_intervention == 0)) |>
  select(-any_intervention)

# 55 unique precincts
all_combos <- expand_grid(
  precinct = unique(grouped_dat$precinct),
  year = 2006:2020
)

grouped_dat_full_incl_47 <- all_combos |>
  left_join(grouped_dat, by = c("precinct", "year")) |>
  ungroup() |>
  mutate(log_shootings = replace_na(log_shootings, 0),
         intervention = replace_na(0, 0)) |>
  merge(cases, all = TRUE) |>
  filter(year != 2014) |>
  filter(!precinct %in% c("43", "49", "121", "120", "122", "123")) # due to boundary changes

grouped_dat_full <- grouped_dat_full_incl_47 |>
  filter(!precinct %in% c("471", "470"))


# avg_df <- grouped_dat_full |>
#   filter(precinct %in% c("431", "491")) |>
#   group_by(year) |>
#   summarise(log_shootings = mean(log_shootings)) |>
#   mutate(precinct = "cases_avg")
# 
# temp <- grouped_dat_full |>
#   merge(avg_df, all = TRUE) |>
#   filter(precinct %in% c("431", "491", "1", "cases_avg"))
# 
# ggplot(temp, aes(x = year, y = log_shootings, color = precinct)) +
#   geom_line(size = 1.2) +
#   geom_point(size = 2) +
#   labs(title = "Line Plot of 3 Precincts",
#        x = "year",
#        y = "log shootings") +
#   theme_minimal()

set.seed(5)

#56 precincts

# SHOOTINGS
syn_shootings_new <- augsynth(log_shootings ~ intervention, 
                              unit = precinct, 
                              time = year,
                              data = grouped_dat_full,
                              progfunc = "none", 
                              scm = T, 
                              #lambda = 1, 
                              fixedeff = T)

saveRDS(syn_shootings_new$weights, "weights/weights_43_49_2020.rds")

syn_shootings_summ_new <- summary(syn_shootings_new, inf_type = "jackknife+")
syn_shootings_summ_new
plot(syn_shootings_summ_new)

plot_43_39 <- plot(syn_shootings_summ_new)

ggsave(filename = "figures_overleaf_111725/plot_43_49_2020_incl_430_490.pdf",
       width = 9,
       height = 6,
       units = "in",
       plot = plot_43_39)

# SHOOTINGS PCT 43

grouped_dat_43 <- grouped_dat_full |>
  filter(precinct != "491")

syn_shootings_43 <- augsynth(log_shootings ~ intervention, 
                              unit = precinct, 
                              time = year,
                              data = grouped_dat_43,
                              progfunc = "ridge", 
                              scm = T, 
                              lambda = 1, 
                              fixedeff = T)

saveRDS(syn_shootings_43$weights, "weights/weights_43_2020.rds")

syn_shootings_summ_43 <- summary(syn_shootings_43, inf_type = "jackknife+")
syn_shootings_summ_43
plot(syn_shootings_summ_43)

plot_43 <- plot(syn_shootings_summ_43)

ggsave(filename = "figures_overleaf_111725/plot_43_2020_incl_430_490.pdf",
       width = 9,
       height = 6,
       units = "in",
       plot = plot_43)

# SHOOTINGS PCT 49

grouped_dat_49 <- grouped_dat_full |>
  filter(precinct != "431")

syn_shootings_49 <- augsynth(log_shootings ~ intervention, 
                             unit = precinct, 
                             time = year,
                             data = grouped_dat_49,
                             progfunc = "Ridge", 
                             scm = T, 
                             lambda = 1, 
                             fixedeff = T)

saveRDS(syn_shootings_49$weights, "weights/weights_49_2020.rds")

syn_shootings_summ_49 <- summary(syn_shootings_49, inf_type = "jackknife+")
syn_shootings_summ_49
plot(syn_shootings_summ_49)

plot_49 <- plot(syn_shootings_summ_49)

ggsave(filename = "figures_overleaf_111725/plot_49_2020_incl_430_490.pdf",
       width = 9,
       height = 6,
       units = "in",
       plot = plot_49)

# SHOOTINGS PCT 47
grouped_dat_47 <- grouped_dat_full_incl_47 |>
  filter(!(precinct %in% c("431", "491")))

syn_shootings_47 <- augsynth(log_shootings ~ intervention, 
                             unit = precinct, 
                             time = year,
                             data = grouped_dat_47,
                             progfunc = "none", 
                             scm = T, 
                             #lambda = 20, 
                             fixedeff = T)

saveRDS(syn_shootings_47$weights, "weights/weights_47_2020.rds")

syn_shootings_summ_47 <- summary(syn_shootings_47, inf_type = "jackknife+")
syn_shootings_summ_47
plot(syn_shootings_summ_47)

plot_47 <- plot(syn_shootings_summ_47)

ggsave(filename = "figures_overleaf_111725/plot_47_2020_incl_430_490.pdf",
       width = 9,
       height = 6,
       units = "in",
       plot = plot_47)

# 
# # what if we remove precincts with 0?
# grouped_dat_full <- grouped_dat_full |>
#   group_by(precinct) |>
#   mutate(has_0 = ifelse(any(is.na(y)), 1, 0)) |>
#   filter(has_0 != 1) |>
#   ungroup() |>
#   mutate(log_y = log(y))
# 
# # SHOOTINGS
# syn_shootings_new <- augsynth(log_y ~ intervention, 
#                               unit = precinct, 
#                               time = year,
#                               data = grouped_dat_full,
#                               progfunc = "ridge", 
#                               scm = T, 
#                               lambda = 1, 
#                               fixedeff = T)
# 
# syn_shootings_summ_new <- summary(syn_shootings_new, inf_type = "jackknife+")
# syn_shootings_summ_new
# plot(syn_shootings_summ_new)
# 
# # SHOOTINGS PCT 43
# 
# grouped_dat_43 <- grouped_dat_full |>
#   filter(precinct != "491")
# 
# syn_shootings_43 <- augsynth(log_y ~ intervention, 
#                              unit = precinct, 
#                              time = year,
#                              data = grouped_dat_43,
#                              progfunc = "ridge", 
#                              scm = T, 
#                              lambda = 1, 
#                              fixedeff = T)
# 
# syn_shootings_summ_43 <- summary(syn_shootings_43, inf_type = "jackknife+")
# syn_shootings_summ_43
# plot(syn_shootings_summ_43)
# 
# # SHOOTINGS PCT 49
# 
# grouped_dat_49 <- grouped_dat_full |>
#   filter(precinct != "431")
# 
# syn_shootings_49 <- augsynth(log_y ~ intervention, 
#                              unit = precinct, 
#                              time = year,
#                              data = grouped_dat_49,
#                              progfunc = "Ridge", 
#                              scm = T, 
#                              lambda = 1, 
#                              fixedeff = T)
# 
# syn_shootings_summ_49 <- summary(syn_shootings_49, inf_type = "jackknife+")
# syn_shootings_summ_49
# plot(syn_shootings_summ_49)




