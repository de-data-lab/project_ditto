library(tidyverse)
library(leaflet)
library(shinycssloaders)
library(sf)
library(AzureStor)
library(lsa)

library(shinydashboard)
library(shinydashboardPlus)

library(plotly)
library(CRplot)

library(shinyWidgets)

#read in functions
source("Functions/ditto.R")
source("Functions/plot_cases.R")
source("Functions/leaflet_proxy_adds.R")

# Create endpoint for azure storage

endpoint <- storage_endpoint(Sys.getenv("storage_container_url"), key = Sys.getenv("storage_container_key"))
container <- storage_container(endpoint, Sys.getenv("storage_container_name"))


#read in computed values
dist_df <- readRDS("data/dist_df.RDS")

#read in county geo shapes and county list
county_shapes <- readRDS("data/county_shapes.RDS")
county_list <- county_shapes %>% as.data.frame() %>% select(STATEFP,NAME,GEOID) %>% arrange(NAME)

#read in state lookup data
states_list <- readRDS("data/states.RDS") %>% arrange(NAME)
state_list_prep <- states_list$STATEFP
names(state_list_prep) <- states_list$NAME

#read in naming lookup table
full_county_names_list <- readRDS("data/full_county_names_list.RDS")
full_county_names_list_for_input <- split(full_county_names_list %>% select(full_county_name,GEOID) %>% deframe(),full_county_names_list$STATE_NAME)


#read in covid cases
data_aggregated <- readRDS("data/data_aggregated.RDS")