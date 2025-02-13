library(tidyverse)
library(augsynth)

crimes_final <- readRDS("data/crimes_final.rds") |>
  filter(!is.na(case)) |>
  filter(PCT %in% c("40", "41", "42", "44", "46", "48", "52", "25", "32", "73", "75",
                    "60", "67", "69", "70", "71", "101", "103", "105", "113",
                    "43", "47", "49")) # cases

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
         log_assault = log(assault)
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
                       lambda = 0.2, 
                       fixedeff = T)

syn_muder_summ <- summary(syn_murder)
syn_muder_summ
plot(syn_muder_summ)

# plots cross-validation
#plot(syn_murder, cv = T)

# SHOOTINGS
syn_shootings <- augsynth(log_shootings ~ case, 
                       unit = PCT, 
                       time = year,
                       data = crimes_final |> filter(year >= 2006),
                       progfunc = "Ridge", 
                       scm = T, 
                       lambda = 0.2, 
                       fixedeff = T)

syn_shootings_summ <- summary(syn_shootings)
syn_shootings_summ
plot(syn_shootings_summ)

# plots cross-validation
#plot(syn_shootings, cv = T)
