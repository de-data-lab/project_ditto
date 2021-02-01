## Data Ingestion Script

library(tidyr)
library(tibble)
library(dplyr)
library(readr)
library(stringr)
library(janitor)
library(lubridate)

# Read in daily data and get rid of unncessary columns

cases <- 
  read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv") %>% 
  select(-UID, -iso2, -iso3, -code3, -Admin2) %>% 
  clean_names()

# Need to aggregate weekly, but what's the best way of doing so with the current struc
# Potentially need to gather, aggregate, and then spread 

cases_gathered <-
  cases %>% 
  select(-fips, -province_state, -country_region, -lat, -long) %>% 
  gather(date, cases, -combined_key) %>% 
  mutate(date = str_remove_all(date, "x"),
         date = str_replace_all(date, "_", "-"),
         date = as.Date(date, format = "%m-%d-%y"))

# Note: Might want to fill in dates

cases_aggregated <-
  cases_gathered %>% 
  mutate(week = floor_date(date, unit = "week")) %>% 
  group_by(combined_key, week) %>% 
  mutate(cases = cases - lag(cases, 1)) %>% 
  summarize(cases = sum(cases, na.rm = T)) %>% 
  ungroup() %>% 
  mutate(cases = ifelse(cases < 0, 0, cases))


# Spread back to have on row per county

cases_spread <-
  cases_aggregated %>% 
  spread(key = week, value = cases)



  
  
