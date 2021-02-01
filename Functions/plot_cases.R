plot_cases <- function(cases_gathered, fips_code){
  
  ggplotly(
  data_aggregated %>% 
    filter(fips == fips_code) %>%
    ggplot(aes(x = week,
               y = cases,
               group = 1,
               text = paste0("<br><b>Week: </b>", week,
                             "<br><b>Number of Weekly Cases: </b>", cases))) +
    geom_line(color = CR_red()) +
    theme_compassred() +
    scale_y_continuous(labels = scales::comma) +
    labs(x = "",
         y = "Number of Weekly Cases")
    
    
  , tooltip = c("text")) %>% 
    config(displayModeBar = F)
  
  
  
}