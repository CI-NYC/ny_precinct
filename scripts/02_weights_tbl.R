library(tidyverse)

weights_43_49_2024_no_other_areas <- readRDS("weights/weights_43_49_2024_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (43 + 49), 2024" = "V1")
weights_43_2024_no_other_areas <- readRDS("weights/weights_43_2024_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (43), 2024" = "V1")
weights_49_2024_no_other_areas <- readRDS("weights/weights_49_2024_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (49), 2024" = "V1")
weights_47_2024_no_other_areas <- readRDS("weights/weights_47_2024_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (47), 2024" = "V1")

weights_43_49_2020_no_other_areas <- readRDS("weights/weights_43_49_2020_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (43 + 49), 2020" = "V1")
weights_43_2020_no_other_areas <- readRDS("weights/weights_43_2020_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (43), 2020" = "V1")
weights_49_2020_no_other_areas <- readRDS("weights/weights_49_2020_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (49), 2020" = "V1")
weights_47_2020_no_other_areas <- readRDS("weights/weights_47_2020_no_other_areas.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("No Other Areas (47), 2020" = "V1")

weights_43_49_2024 <- readRDS("weights/weights_43_49_2024.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (43 + 49), 2024" = "V1")
weights_43_2024 <- readRDS("weights/weights_43_2024.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (43), 2024" = "V1")
weights_49_2024 <- readRDS("weights/weights_49_2024.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (49), 2024" = "V1")
weights_47_2024 <- readRDS("weights/weights_47_2024.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (47), 2024" = "V1")

weights_43_49_2020 <- readRDS("weights/weights_43_49_2020.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (43 + 49), 2020" = "V1")
weights_43_2020 <- readRDS("weights/weights_43_2020.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (43), 2020" = "V1")
weights_49_2020 <- readRDS("weights/weights_49_2020.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (49), 2020" = "V1")
weights_47_2020 <- readRDS("weights/weights_47_2020.rds") |>
  as.data.frame() |>
  rownames_to_column("precinct") |>
  rename("Other Areas (47), 2020" = "V1")

all_weights <- weights_43_49_2024_no_other_areas |>
  full_join(weights_43_2024_no_other_areas) |>
  full_join(weights_49_2024_no_other_areas) |>
  full_join(weights_47_2024_no_other_areas) |>
  full_join(weights_43_49_2020_no_other_areas) |>
  full_join(weights_43_2020_no_other_areas) |>
  full_join(weights_49_2020_no_other_areas) |>
  full_join(weights_47_2020_no_other_areas) |>
  full_join(weights_43_49_2024) |>
  full_join(weights_43_2024) |>
  full_join(weights_49_2024) |>
  full_join(weights_47_2024) |>
  full_join(weights_43_49_2020) |>
  full_join(weights_43_2020) |>
  full_join(weights_49_2020) |>
  full_join(weights_47_2020) |>
  mutate(precinct = as.numeric(precinct)) |>
  arrange(precinct)

knitr::kable(round(all_weights, 4), format = "latex", booktabs = TRUE, caption = "My Table")

  
