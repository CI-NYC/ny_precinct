library(tidyverse)
library(did)

dat49 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 1) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(PCT = 49)

dat47 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 2) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(PCT = 47)

dat43 <- read_excel("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx", sheet = 3) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(PCT = 43)

merged_dat <- dat49 |>
  merge(dat47, all = TRUE) |>
  merge(dat43, all = TRUE) |>
  pivot_longer(cols = c(suv_target_area, pcnt_other_areas), 
               names_to = "group", 
               values_to = "y") |>
  mutate(log_y = log(y)) |>
  mutate(treated = ifelse(group == "suv_target_area", 1, 0)) |>
  mutate(treated_year = ifelse(treated == 1, 2015, 0)) |>
  arrange(treated, PCT, year) |>
  mutate(GROUP = as.numeric(paste0(PCT, treated)))

ggplot(merged_dat, aes(x = year, y = log_y, color = factor(group), group = factor(group))) +
  geom_line() +
  geom_point() +
  facet_wrap(~ PCT) +
  geom_vline(xintercept = 2014, color = "black", linetype = "solid") +
  theme_minimal() +
  labs(title = "log shootings by precinct",
       x = "Year",
       y = "log(shootings)",
       color = "Group")

# removing 2014
set.seed(10)
res <- att_gt(yname = "log_y",
              tname = "year",
              idname = "GROUP",
              #clustervars = c("PCT", "GROUP"),
              gname = "treated_year",
              data = merged_dat  |> filter(year != 2014), # remove 2014 due to rollout period
              control_group = "notyettreated" # includes both those that are never treated and those yet to be treated
)

# aggregate
res_dynamic <- aggte(res, type = "dynamic")
summary(res_dynamic)
ggdid(res_dynamic)

# anticipating 2014
set.seed(10)
res_anticipation <- att_gt(yname = "log_y",
                           tname = "year",
                           idname = "GROUP",
                           #clustervars = c("PCT", "GROUP"),
                           gname = "treated_year",
                           data = merged_dat,
                           anticipation = 1,
                           control_group = "notyettreated" # includes both those that are never treated and those yet to be treated
)

# aggregate
res_dynamic_anticipation <- aggte(res_anticipation, type = "dynamic")
summary(res_dynamic_anticipation)
ggdid(res_dynamic_anticipation)

# questions: clustering?



  
  
  
  
  
  
  
  


