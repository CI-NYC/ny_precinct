library(tidyverse)
library(augsynth)

crimes_final <- readRDS("data/crimes_final.rds") |>
  filter(!is.na(case)) |>
  filter(PCT %in% c("40", "41", "42", "44", "46", "48", "52", "25", "32", "73", "75",
                    "60", "67", "69", "70", "71", "101", "103", "105", "113",
                    "43", "47", "49")) |>
  rowwise() |>
  mutate(crime_total = sum(murder, robbery, rape, assault, na.rm = TRUE))

hist(crimes_final$murder)
hist(crimes_final$shootings)
hist(crimes_final$robbery)
hist(crimes_final$rape)
hist(crimes_final$assault)

crimes_final <- crimes_final |>
  mutate(log_murder = log(murder + 1), #includes a 0 in PCT 60 in 2018
         log_shootings = log(shootings), 
         log_robbery = log(robbery),
         log_rape = log(rape),
         log_assault = log(assault),
         log_crime_total = log(crime_total)
  )


hist(crimes_final$log_murder)
hist(crimes_final$log_shootings)
hist(crimes_final$log_robbery)
hist(crimes_final$log_rape)
hist(crimes_final$log_assault)

# MURDER
syn_murder <- augsynth(log_murder ~ case, 
                       unit = PCT, 
                       time = year,
                       data = crimes_final,
                       progfunc = "Ridge", 
                       scm = T, 
                       #lambda = 0.2, 
                       fixedeff = T)

syn_muder_summ <- summary(syn_murder)
syn_muder_summ
plot(syn_muder_summ)

# plots cross-validation
plot(syn_murder, cv = T)

# SHOOTINGS
syn_shootings <- augsynth(log_shootings ~ case, 
                       unit = PCT, 
                       time = year,
                       data = crimes_final |> filter(year >= 2006),
                       progfunc = "Ridge", 
                       scm = T, 
                       #lambda = 0.03, 
                       fixedeff = T)

syn_shootings_summ <- summary(syn_shootings, inf_type = "jackknife+")
syn_shootings_summ
plot(syn_shootings_summ)

# plots cross-validation
plot(syn_shootings, cv = T)

# SHOOTINGS (non extrapolate)
syn_shootings_basic <- augsynth(log_shootings ~ case, 
                          unit = PCT, 
                          time = year,
                          data = crimes_final |> filter(year >= 2006),
                          progfunc = "None", 
                          scm = T, 
                          fixedeff = F)

syn_shootings_summ_basic <- summary(syn_shootings_basic, inf_type = "jackknife+")
syn_shootings_summ_basic
plot(syn_shootings_summ_basic)

# crime_total
syn_crime_total <- augsynth(log_crime_total ~ case, 
                            unit = PCT, 
                            time = year,
                            data = crimes_final,
                            progfunc = "Ridge", 
                            scm = T, 
                            lambda = 0.005, 
                            fixedeff = T)

syn_crime_total_summ <- summary(syn_crime_total, inf_type = "jackknife+")
syn_crime_total_summ
plot(syn_crime_total_summ)

# plots cross-validation
#plot(syn_crime_total, cv = T)

# crime_total (non extrapolate)
syn_crime_total_basic <- augsynth(log_crime_total ~ case, 
                                  unit = PCT, 
                                  time = year,
                                  data = crimes_final,
                                  progfunc = "None", 
                                  scm = T, 
                                  fixedeff = F)

syn_crime_total_summ_basic <- summary(syn_crime_total_basic, inf_type = "jackknife+")
syn_crime_total_summ_basic
plot(syn_crime_total_summ_basic)


# do the same for murders + total crimes (4 categories) + writeup
