Shootings DiD by Precinct
================
2025-08-11

``` r
knitr::opts_chunk$set(warning = FALSE, message = FALSE)
knitr::opts_chunk$set(message = FALSE)

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(augsynth))
suppressPackageStartupMessages(library(did))
suppressPackageStartupMessages(library(readxl))
```

``` r
crimes_final <- readRDS(here::here("data/crimes_final.rds")) |>
  filter(!is.na(case)) |>
  filter(PCT %in% c( "41", "42", "44", "48", "52", "25", "73",
                     "60", "67", "69", "70", "71", "101", "105", "113",
                     "43", "47", "49")) |> # cases
  rowwise() |>
  mutate(crime_total = sum(murder, robbery, rape, assault, na.rm = TRUE))

## Difference in Difference Analysis

dat49 <- read_excel(here::here("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx"), sheet = 1) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(PCT = 49)

dat47 <- read_excel(here::here("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx"), sheet = 2) |>
  janitor::clean_names() |>
  mutate(across(everything(), ~ as.numeric(gsub("[^0-9.-]", "", .)))) |>
  mutate(PCT = 47)

dat43 <- read_excel(here::here("data/SUV vs NYPD PCNT DATA_2004_2024.xlsx"), sheet = 3) |>
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
    filter(PCT == "43" | treated == 0)
} else if (p == "47")
{
  merged_dat_new <- merged_dat |>
    filter(PCT == "47" | treated == 0)
} else
{
  merged_dat_new <- merged_dat |>
    filter(PCT == "49" | treated == 0)
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
print(paste0("Precinct ", p))
res_dynamic <- aggte(res, type = "dynamic")
summary(res_dynamic)
print(ggdid(res_dynamic))
}
```

    ## [1] "Precinct 43"

    ## 
    ## Call:
    ## aggte(MP = res, type = "dynamic")
    ## 
    ## Reference: Callaway, Brantly and Pedro H.C. Sant'Anna.  "Difference-in-Differences with Multiple Time Periods." Journal of Econometrics, Vol. 225, No. 2, pp. 200-230, 2021. <https://doi.org/10.1016/j.jeconom.2020.12.001>, <https://arxiv.org/abs/1803.09015> 
    ## 
    ## 
    ## Overall summary of ATT's based on event-study/dynamic aggregation:  
    ##     ATT    Std. Error     [ 95%  Conf. Int.]  
    ##  0.5341        0.2043     0.1337      0.9345 *
    ## 
    ## 
    ## Dynamic Effects:
    ##  Event time Estimate Std. Error [95% Simult.  Conf. Band]  
    ##         -10  -1.0890     0.0445       -2.8085      0.6304  
    ##          -9   1.3806     0.1652       -4.9997      7.7609  
    ##          -8  -0.2334     0.0666       -2.8078      2.3410  
    ##          -7   0.4664     0.0583       -1.7873      2.7201  
    ##          -6  -0.0278     0.1203       -4.6731      4.6175  
    ##          -5  -0.4406     0.1018       -4.3734      3.4922  
    ##          -4  -0.8223     0.1411       -6.2726      4.6279  
    ##          -3   1.0459     0.0143        0.4921      1.5997 *
    ##          -2  -0.5574     0.0683       -3.1939      2.0791  
    ##           0   1.0032     0.0471       -0.8180      2.8244  
    ##           1   0.7241     0.2918      -10.5489     11.9970  
    ##           2   0.9090     0.1626       -5.3725      7.1904  
    ##           3   1.2152     0.6045      -22.1362     24.5665  
    ##           4  -0.2670     0.2803      -11.0937     10.5596  
    ##           5   0.6627     0.1473       -5.0280      6.3535  
    ##           6   0.3982     0.2250       -8.2928      9.0892  
    ##           7   0.0951     0.2776      -10.6278     10.8180  
    ##           8   0.4408     0.3997      -15.0005     15.8821  
    ##           9   0.1599     0.2926      -11.1441     11.4640  
    ## ---
    ## Signif. codes: `*' confidence band does not cover 0
    ## 
    ## Control Group:  Not Yet Treated,  Anticipation Periods:  0
    ## Estimation Method:  Doubly Robust

![](DiD_by_precinct_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

    ## [1] "Precinct 47"

    ## 
    ## Call:
    ## aggte(MP = res, type = "dynamic")
    ## 
    ## Reference: Callaway, Brantly and Pedro H.C. Sant'Anna.  "Difference-in-Differences with Multiple Time Periods." Journal of Econometrics, Vol. 225, No. 2, pp. 200-230, 2021. <https://doi.org/10.1016/j.jeconom.2020.12.001>, <https://arxiv.org/abs/1803.09015> 
    ## 
    ## 
    ## Overall summary of ATT's based on event-study/dynamic aggregation:  
    ##     ATT    Std. Error     [ 95%  Conf. Int.] 
    ##  0.2538        0.1393    -0.0192      0.5268 
    ## 
    ## 
    ## Dynamic Effects:
    ##  Event time Estimate Std. Error [95% Simult.  Conf. Band] 
    ##         -10  -0.6937     0.0691       -3.3623      1.9748 
    ##          -9   0.9387     0.1652       -5.4416      7.3190 
    ##          -8  -0.2334     0.0666       -2.8078      2.3410 
    ##          -7  -0.4697     0.0583       -2.7234      1.7840 
    ##          -6   0.3487     0.1203       -4.2966      4.9940 
    ##          -5  -0.3818     0.0292       -1.5101      0.7465 
    ##          -4   0.5257     0.1411       -4.9245      5.9760 
    ##          -3  -0.5253     0.0143       -1.0791      0.0284 
    ##          -2   0.2310     0.0683       -2.4055      2.8676 
    ##           0  -0.4223     0.1768       -7.2520      6.4074 
    ##           1   0.8137     0.2918      -10.4592     12.0866 
    ##           2   0.2158     0.1220       -4.4957      4.9273 
    ##           3   0.6116     0.3751      -13.8762     15.0994 
    ##           4   0.3616     0.2803      -10.4651     11.1882 
    ##           5   0.3934     0.1473       -5.2973      6.0842 
    ##           6   0.3337     0.2616       -9.7721     10.4394 
    ##           7   0.7237     0.2776       -9.9992     11.4466 
    ##           8   0.5098     0.3997      -14.9315     15.9511 
    ##           9  -1.0032     0.1594       -7.1594      5.1530 
    ## ---
    ## Signif. codes: `*' confidence band does not cover 0
    ## 
    ## Control Group:  Not Yet Treated,  Anticipation Periods:  0
    ## Estimation Method:  Doubly Robust

![](DiD_by_precinct_files/figure-gfm/unnamed-chunk-2-2.png)<!-- -->

    ## [1] "Precinct 49"

    ## 
    ## Call:
    ## aggte(MP = res, type = "dynamic")
    ## 
    ## Reference: Callaway, Brantly and Pedro H.C. Sant'Anna.  "Difference-in-Differences with Multiple Time Periods." Journal of Econometrics, Vol. 225, No. 2, pp. 200-230, 2021. <https://doi.org/10.1016/j.jeconom.2020.12.001>, <https://arxiv.org/abs/1803.09015> 
    ## 
    ## 
    ## Overall summary of ATT's based on event-study/dynamic aggregation:  
    ##      ATT    Std. Error     [ 95%  Conf. Int.]  
    ##  -0.4267        0.1393    -0.6997     -0.1537 *
    ## 
    ## 
    ## Dynamic Effects:
    ##  Event time Estimate Std. Error [95% Pointwise  Conf. Band]  
    ##         -10   0.6056     0.0691          0.4702      0.7410 *
    ##          -9  -0.1599     0.1652         -0.4836      0.1639  
    ##          -8  -0.0103     0.2474         -0.4951      0.4746  
    ##          -7  -0.1051     0.0583         -0.2194      0.0093  
    ##          -6   0.4541     0.1203          0.2184      0.6898 *
    ##          -5   0.2060     0.1018          0.0065      0.4056 *
    ##          -4  -0.0984     0.2490         -0.5865      0.3897  
    ##          -3   0.2350     0.0143          0.2069      0.2631 *
    ##          -2  -0.0874     0.0683         -0.2212      0.0464  
    ##           0  -0.9331     0.1768         -1.2797     -0.5866 *
    ##           1   0.2540     0.2918         -0.3179      0.8260  
    ##           2  -1.1705     0.1220         -1.4095     -0.9314 *
    ##           3  -1.3343     0.1456         -1.6197     -1.0489 *
    ##           4  -0.0439     0.2803         -0.5932      0.5054  
    ##           5  -0.0586     0.0844         -0.2240      0.1068  
    ##           6  -0.5826     0.2616         -1.0954     -0.0698 *
    ##           7   0.9060     0.2776          0.3619      1.4501 *
    ##           8  -0.5888     0.3997         -1.3723      0.1947  
    ##           9  -0.7155     0.1594         -1.0279     -0.4032 *
    ## ---
    ## Signif. codes: `*' confidence band does not cover 0
    ## 
    ## Control Group:  Not Yet Treated,  Anticipation Periods:  0
    ## Estimation Method:  Doubly Robust

![](DiD_by_precinct_files/figure-gfm/unnamed-chunk-2-3.png)<!-- -->
