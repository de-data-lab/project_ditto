print("Running Script to update files")
#get connection creds
#readRenviron(".Renviron")

#library(AzureStor,lib.loc=".", verbose=TRUE)

#endpoint <- storage_endpoint(Sys.getenv("storage_container_url"), key = Sys.getenv("storage_container_key"))
#container <- storage_container(endpoint, Sys.getenv("storage_container_name"))


#Update CSVs in Azure
source("Scripts/00_Ingestion_DeathCleaning.R")
source("Scripts/01_Compute_Distance.R")
source("Scripts/02_Merge_Write.R")

#Cases tidy format
full_county_names_list <- tigris::counties(cb = T,resolution = "5m") %>%
  select(GEOID,COUNTY_NAME = NAME,STATEFP) %>% 
  as.data.frame() %>% 
  select(-geometry) %>% 
  left_join(tigris::states(cb = T,resolution = "5m") %>% 
              select(NAME,STATEFP) %>% 
              filter(NAME != "Commonwealth of the Northern Mariana Islands") %>%
              arrange(NAME) %>% select(STATEFP,STATE_NAME = NAME),by="STATEFP") %>% 
  select(-geometry) %>% 
  mutate(full_county_name = paste0(COUNTY_NAME,", ",STATE_NAME))

data_aggregated %>% 
  left_join(full_county_names_list,by = c("fips" = "GEOID")) %>% 
  left_join(county_stats %>% select(fips,total_pop)) %>% 
  mutate(cases_per = round((cases/total_pop)*100000,2)) %>% 
  AzureStor::storage_save_rds(container,file = "project_ditto/saved_rds/data_aggregatedDeath.RDS")

#Single row per fips, sparkline included
library(sparkline)
AzureStor::storage_load_rds(container,"project_ditto/saved_rds/data_aggregatedDeath.RDS") %>% 
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
  ) %>% 
  AzureStor::storage_save_rds(container,file = "project_ditto/saved_rds/data_sparklinesDeath.RDS")
