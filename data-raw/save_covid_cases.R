source("Scripts/00_Ingestion_Cleaning.R")

full_county_names_list <- readRDS("data/full_county_names_list.RDS")

data_aggregated <- data_aggregated %>% 
  left_join(full_county_names_list,by = c("fips" = "GEOID")) %>% 
  left_join(county_stats %>% select(fips,total_pop)) %>% 
  mutate(cases_per = round((cases/total_pop)*100000,2))
saveRDS(data_aggregated,"data/data_aggregated.RDS")
