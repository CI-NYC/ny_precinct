library(tidyverse)
library(knitr)

model_43_49_2024_no_other_areas <- readRDS("models/model_43_49_2024_no_other_areas.rds")
model_43_2024_no_other_areas <- readRDS("models/model_43_2024_no_other_areas.rds")
model_47_2024_no_other_areas <- readRDS("models/model_47_2024_no_other_areas.rds")
model_49_2024_no_other_areas <- readRDS("models/model_49_2024_no_other_areas.rds")

extract_att <- function(summary_obj) {
  overall <- summary_obj$average_att
  overall_string <- sprintf("%.2f (%.2f, %.2f)", 
                            ((exp(overall$Estimate) - 1) * 100) * -1, 
                            ((exp(overall$upper_bound) - 1) * 100) * -1,
                            ((exp(overall$lower_bound) - 1) * 100 * -1))
  
  att_df <- summary_obj$att[summary_obj$att$Time >= 2015, ]
  time_strings <- sprintf("%.2f (%.2f, %.2f)", 
                          ((exp(att_df$Estimate) - 1) * 100) * -1, 
                          ((exp(att_df$upper_bound) - 1) * 100) * -1,
                          ((exp(att_df$lower_bound) - 1) * 100) * -1)
  
  c(overall_string, setNames(time_strings, att_df$Time))
}

col1 <- extract_att(model_43_49_2024_no_other_areas)
col2 <- extract_att(model_43_2024_no_other_areas)
col3 <- extract_att(model_47_2024_no_other_areas)
col4 <- extract_att(model_49_2024_no_other_areas)

result_table <- data.frame(
  Period = c("Overall", names(col1)[-1]),
  Model1 = col1,
  Model2 = col2,
  Model3 = col3,
  Model4 = col4,
  row.names = NULL
)

kable(result_table, 
      format = "latex",
      booktabs = TRUE,
      col.names = c("Period", "Precincts 43 + 49", "Precinct 43", "Precinct 47", "Precinct 49"),
      align = c('l', 'r', 'r', 'r', 'r'),
      caption = "ATT Estimates with 95\\% Confidence Intervals") 