library(tidyverse)
library(patchwork)
library(augsynth)

crimes_final <- readRDS("data/crimes_final.rds") |>
  filter(!is.na(case))

hist(crimes_final$murder)
hist(crimes_final$robbery)
hist(crimes_final$rape)
hist(crimes_final$assault)

crimes_final <- crimes_final |>
  mutate(log_murder = log(murder + 1), #includes 0 (~9%)
         log_robbery = log(robbery),
         log_rape = log(rape + 1), #includes 0 (<1%)
         log_assault = log(assault)
         )


hist(crimes_final$log_murder)
hist(crimes_final$log_robbery)
hist(crimes_final$log_rape)
hist(crimes_final$log_assault)

murder_line_plot <- ggplot(crimes_final |> mutate(year = factor(year)) |> filter(case == 1), aes(x = year, y = murder, color = PCT, group = PCT)) +
  geom_line() +  
  geom_point() + 
  labs(title = "Murder by year among 3 precincts", x = "Year", y = "Murder") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

robbery_line_plot <- ggplot(crimes_final |> mutate(year = factor(year)) |> filter(case == 1), aes(x = year, y = robbery, color = PCT, group = PCT)) +
  geom_line() +  
  geom_point() + 
  labs(title = "Robbery by year among 3 precincts", x = "Year", y = "Robbery") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

rape_line_plot <- ggplot(crimes_final |> mutate(year = factor(year)) |> filter(case == 1), aes(x = year, y = rape, color = PCT, group = PCT)) +
  geom_line() +  
  geom_point() + 
  labs(title = "Rape by year among 3 precincts", x = "Year", y = "Rape") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

assault_line_plot <- ggplot(crimes_final |> mutate(year = factor(year)) |> filter(case == 1), aes(x = year, y = assault, color = PCT, group = PCT)) +
  geom_line() +  
  geom_point() + 
  labs(title = "Assault by year among 3 precincts", x = "Year", y = "Assault") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

murder_line_plot + robbery_line_plot + rape_line_plot + assault_line_plot

# murder

syn_murder <- augsynth(log_murder ~ case, 
                unit = PCT, 
                time = year,
                data = crimes_final,
                progfunc = "ridge", 
                scm = T, 
                fixedeff = F)

syn_muder_summ <- summary(syn_murder)
syn_muder_summ
plot(syn_muder_summ)

# plots cross-validation
plot(syn_murder, cv = T)

# robbery

syn_robbery <- augsynth(log_robbery ~ case, 
                        unit = PCT, 
                        time = year,
                        data = crimes_final,
                        progfunc = "Ridge", 
                        scm = T,
                        fixedeff = F)

syn_robbery_summ <- summary(syn_robbery)
syn_robbery_summ
plot(syn_robbery_summ)
plot(syn_robbery, cv = T)


# rape
syn_rape <- augsynth(log_rape ~ case, 
                     unit = PCT, 
                     time = year,
                     data = crimes_final,
                     progfunc = "Ridge", 
                     scm = T,
                     fixedeff = F)

syn_rape_summ <- summary(syn_rape)
syn_rape_summ
plot(syn_rape_summ)
plot(syn_rape, cv = T)

# assault
syn_assault <- augsynth(log_assault ~ case, 
                        unit = PCT, 
                        time = year,
                        data = crimes_final,
                        progfunc = "Ridge", 
                        scm = T,
                        fixedeff = T,
                        lambda = 1.311880e-01)

syn_assault_summ <- summary(syn_assault)
syn_assault_summ
plot(syn_assault_summ)
plot(syn_assault, cv = T)

