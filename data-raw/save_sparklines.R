library(sparkline)
source("Scripts/00_Ingestion_Cleaning.R")
data_sparklines <- readRDS("data/data_aggregated.RDS") %>% 
  group_by(fips) %>% 
  summarize(
    sparkline = spk_chr(
      cases_per, type ="line",
      width = 100,
      height = 30,
      chartRangeMin = 0, chartRangeMax = max(cases_per),
      fillColor = "#FFFFFF00", #transparent fill
      lineColor = "#888888", #lightgrey line
      minSpotColor = "",maxSpotColor = "",spotColor = "", #don't show highs/lows
      lineWidth = 3, #thicker line
      tooltipFormat = "{{y.2}}"
      #https://omnipotent.net/jquery.sparkline/#s-docs
    ),
    total_cases = sum(as.numeric(cases)),
    cases_per = (sum(as.numeric(cases))/min(total_pop))*100000
  )
saveRDS(data_sparklines,"data/data_sparklines.RDS")
