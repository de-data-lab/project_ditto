library(sparkline)
data_sparklines <- readRDS("data/data_aggregated.RDS") %>% 
  group_by(fips) %>% 
  summarize(
    sparkline = spk_chr(
      cases, type ="line",
      chartRangeMin = 0, chartRangeMax = max(cases),
      fillColor = "#FFFFFF00", #transparent fill
      lineColor = "#888888", #lightgrey line
      minSpotColor = "",maxSpotColor = "",spotColor = "", #don't show highs/lows
      lineWidth = 3 #thicker line
      #https://omnipotent.net/jquery.sparkline/#s-docs
    ),
    total_cases = sum(as.numeric(cases))
  )
saveRDS(data_sparklines,"data/data_sparklines.RDS")
