source("Scripts/00_Ingestion_Cleaning.R")
data_aggregated <- data_aggregated %>% 
  left_join(full_county_names_list,by = c("fips" = "GEOID"))
saveRDS(data_aggregated,"data/data_aggregated.RDS")
