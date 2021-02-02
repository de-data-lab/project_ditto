## Data Ingestion Script

library(readr)
library(stringr)
library(janitor)
library(lubridate)

# Read in daily data and get rid of unncessary columns

data <- 
  read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv") %>% 
  select(-UID, -iso2, -iso3, -code3, -Admin2) %>% 
  clean_names()


# gather, aggregate, and then spread 

data_gathered <-
  data %>% 
  mutate(fips = str_pad(fips, 5, pad = "0")) %>% 
  select(-combined_key, -province_state, -country_region, -lat, -long) %>% 
  gather(date, cases, -fips) %>% 
  mutate(date = str_remove_all(date, "x"),
         date = str_replace_all(date, "_", "-"),
         date = as.Date(date, format = "%m-%d-%y"))


data_aggregated <-
  data_gathered %>% 
  mutate(week = floor_date(date, unit = "week")) %>% 
  group_by(fips, week) %>% 
  mutate(cases = cases - lag(cases, 1)) %>% 
  summarize(cases = sum(cases, na.rm = T)) %>% 
  ungroup() %>% 
  mutate(cases = ifelse(cases < 0, 0, cases))


# Spread back to have on row per county

data_spread <-
  data_aggregated %>% 
  spread(key = week, value = cases)



  
  
