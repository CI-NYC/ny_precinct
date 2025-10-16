library(tidyverse)
library(augsynth)
library(did)
library(readxl)

crimes_final <- readRDS("data/crimes_final.rds") |>
  filter(!is.na(case)) |>
  filter(PCT %in% c( "41", "42", "44", "48", "52", "25", "73",
                     "60", "67", "69", "70", "71", "101", "105", "113",
                     "43", "47", "49")) |> # cases
  rowwise() |>
  mutate(crime_total = sum(murder, robbery, rape, assault, na.rm = TRUE))

## Difference in Difference Analysis

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


# for each precint, only use control and case
for (p in c("43", "47", "49"))
{
  
if (p == "43")
{
  merged_dat_new <- merged_dat |>
    filter(PCT == "43")
} else if (p == "47")
{
  merged_dat_new <- merged_dat |>
    filter(PCT == "47")
} else
{
  merged_dat_new <- merged_dat |>
    filter(PCT == "49")
}


### Removing 2014
# removing 2014
set.seed(10)
res <- att_gt(yname = "log_y",
              tname = "year",
              idname = "GROUP",
              #clustervars = c("PCT", "GROUP"),
              gname = "treated_year",
              data = merged_dat_new  |> filter(year != 2014), # remove 2014 due to rollout period
              control_group = "notyettreated" # includes both those that are never treated and those yet to be treated
)

# aggregate
res_dynamic <- aggte(res, type = "dynamic")
summary(res_dynamic)
print(ggdid(res_dynamic))
}