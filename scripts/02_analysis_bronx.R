library(tidyverse)
library(augsynth)

crimes_final_bronx_queens <- readRDS("data/crimes_final_bronx_queens.rds") |>
  filter(!is.na(case))

hist(crimes_final_bronx_queens$murder)
hist(crimes_final_bronx_queens$robbery)
hist(crimes_final_bronx_queens$rape)
hist(crimes_final_bronx_queens$assault)

crimes_final_bronx_queens <- crimes_final_bronx_queens |>
  mutate(log_murder = log(murder + 1), #includes 0 (~9%)
         log_robbery = log(robbery),
         log_rape = log(rape),
         log_assault = log(assault)
  )


hist(crimes_final_bronx_queens$log_murder)
hist(crimes_final_bronx_queens$log_robbery)
hist(crimes_final_bronx_queens$log_rape)
hist(crimes_final_bronx_queens$log_assault)

# murder

syn_murder <- augsynth(log_murder ~ case, 
                       unit = PCT, 
                       time = year,
                       data = crimes_final_bronx_queens,
                       progfunc = "Ridge", 
                       scm = T, 
                       fixedeff = T)

syn_muder_summ <- summary(syn_murder)
syn_muder_summ
plot(syn_muder_summ)

# plots cross-validation
plot(syn_murder, cv = T)

# robbery

syn_robbery <- augsynth(log_robbery ~ case, 
                        unit = PCT, 
                        time = year,
                        data = crimes_final_bronx_queens,
                        progfunc = "Ridge", 
                        scm = T,
                        fixedeff = F)

syn_robbery_summ <- summary(syn_robbery)
syn_robbery_summ
plot(syn_robbery_summ)
# plots cross-validation
plot(syn_robbery, cv = T)

# rape
syn_rape <- augsynth(log_rape ~ case, 
                     unit = PCT, 
                     time = year,
                     data = crimes_final_bronx_queens,
                     progfunc = "Ridge", 
                     scm = T,
                     fixedeff = F)

syn_rape_summ <- summary(syn_rape)
syn_rape_summ
plot(syn_rape_summ)
# plots cross-validation
plot(syn_rape, cv = T)

# assault
syn_assault <- augsynth(log_assault ~ case, 
                        unit = PCT, 
                        time = year,
                        data = crimes_final_bronx_queens,
                        progfunc = "none", 
                        scm = T,
                        fixedeff = T)

syn_assault_summ <- summary(syn_assault)
syn_assault_summ
plot(syn_assault_summ)
# plots cross-validation
plot(syn_assault, cv = T)
