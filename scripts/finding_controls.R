library(tidyverse)
library(ggplot2)
library(plotly)

crimes_final <- readRDS("data/crimes_final.rds") |>
  filter(!is.na(case))

cases_avg <- crimes_final |>
  filter(PCT %in% c(43, 47, 49)) |>
  group_by(year) |>
  summarize(murder = mean(murder),
         rape = mean(rape),
         robbery = mean(rape),
         assault = mean(assault)) |>
  mutate(PCT = "cases_avg",
         case = 1)

crimes_final <- crimes_final |>
  merge(cases_avg, all = TRUE) |>
  filter(!(PCT %in% c("43", "47", "49")))

crimes_final_limited <- crimes_final |>
  filter(PCT %in% c("cases_avg", "40", "41", "42", "44", "45", "46", "48", "50", "52", "25", "30", "32", "33", "73", "75")) |>
  filter(year <= 2013)

palette_colors <- c(RColorBrewer::brewer.pal(19, "Paired"), "magenta3", "turquoise3", "yellow4", "black")

murder_plot_limited <- ggplot(crimes_final_limited, aes(x = factor(year), y = murder, color = PCT, group = PCT,
                                                   text = paste("PCT:", PCT, "<br>Year:", year, "<br>Murder:", round(murder, 2)))) +
  geom_line(size = 1, aes(text = paste0("PCT: ", PCT))) +  
  geom_point(size = 2) + 
  scale_color_manual(values = palette_colors) + 
  theme_minimal() +      
  labs(title = "Murder by year among selected precincts", x = "Year", y = "Murder")

ggplotly(murder_plot_limited, tooltip = "text")


# crimes_final_comparison <- crimes_final |>
#   group_by(PCT) |>
#   mutate(flag = ifelse(any(murder == 0), 1, 0)) |>
#   filter(flag == 0)

murder_plot_all <- ggplot(crimes_final, aes(x = factor(year), y = murder, color = PCT, group = PCT,
                                                        text = paste("PCT:", PCT, "<br>Year:", year, "<br>Murder:", round(murder, 2)))) +
  geom_line(size = 1, aes(text = paste0("PCT: ", PCT))) +  
  geom_point(size = 2) + 
  theme_minimal() +      
  labs(title = "Murder by year among selected precincts", x = "Year", y = "Murder")

ggplotly(murder_plot_all, tooltip = "text")


# finding slopes by PCT
slopes <- data.frame(PCT = character(), slope = numeric(), stringsAsFactors = FALSE)

for(pct in unique(crimes_final_comparison$PCT)) {
  group_data <- subset(crimes_final_comparison, PCT == pct)
  model <- lm(murder ~ year, data = group_data)
  slope <- coef(model)['year']
  slopes <- rbind(slopes, data.frame(PCT = pct, slope = slope)) |>
    arrange(slope)
  rownames(slopes) <- NULL 
}


