library(tidyverse)
library(readxl)
library(lubridate)

crimes <- read_excel("data/seven-major-felony-offenses-by-precinct-2000-2023.xls", col_names = TRUE)
colnames(crimes) <- crimes[2, ]
crimes <- crimes[-c(1, 2), ] |>
  fill(PCT) |>
  filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" |
           CRIME == "RAPE" |
           CRIME == "ROBBERY" |
           CRIME == "FELONY ASSAULT") |>
  mutate(CRIME = case_when(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" ~ "murder",
                           CRIME == "RAPE" ~ "rape",
                           CRIME == "ROBBERY" ~ "robbery",
                           CRIME == "FELONY ASSAULT" ~ "assault"
                           ))

crimes_final <- crimes |>
  mutate(across(3:ncol(crimes), as.numeric)) |>
  pivot_longer(cols = starts_with("20"),
               names_to = "year",
               values_to = "value") |>
  pivot_wider(names_from = "CRIME",
              values_from = "value",
              id_cols = c("PCT", "year")) |>
  mutate(year = as.numeric(year))

#precinct_to_cd <- read_excel("data/precinct_to_cd.xlsx")

## shooting data
shooting_historic <- read_csv("data/NYPD_Shooting_Incident_Data__Historic.csv") |>
  mutate(OCCUR_DATE = mdy(OCCUR_DATE),
         year = year(OCCUR_DATE)) |>
  relocate(year, .after = OCCUR_DATE)
  
shooting_current <- read_csv("data/NYPD_Shooting_Incident_Data__Year_To_Date.csv") |>
  mutate(OCCUR_DATE = mdy(OCCUR_DATE),
         year = year(OCCUR_DATE)) |>
  relocate(year, .after = OCCUR_DATE)

shooting_historic_grouped <- shooting_historic |>
  group_by(PRECINCT, year) |> 
  summarize(shootings = n()) |>
  ungroup() |> 
  complete(PRECINCT, year) |>
  arrange(year)

shooting_current_grouped <- shooting_current |>
  group_by(PRECINCT, year) |> 
  summarize(shootings = n()) |>
  arrange(year)

shootings_all_grouped <- shooting_historic_grouped |>
  merge(shooting_current_grouped, all = TRUE) |>
  arrange(PRECINCT, year) |>
  mutate(PRECINCT = as.character(PRECINCT)) |>
  rename("PCT" = "PRECINCT")

crimes_final <- crimes_final |>
  left_join(shootings_all_grouped)

crimes_final <- crimes_final |>
  mutate(case = case_when(year > 2014 & PCT %in% c("43", "47", "49") ~ 1,
                          year == 2014 ~ as.numeric(NA),
                          TRUE ~ 0)) |>
  filter(!(PCT %in% c("120", "121", "122", "77", "78", "88", "DOC", "22"))) |> # removing precincts that have changed/not relevant
  filter(year >= 2004) |>
  mutate(shootings = ifelse(is.na(shootings) & year >= 2006, 0, shootings))

saveRDS(crimes_final, "data/crimes_final.rds")




