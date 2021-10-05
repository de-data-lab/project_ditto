library(tidyverse)
library(leaflet)
library(shinycssloaders)
library(sf)
library(AzureStor)
library(shinydashboard)
library(shinydashboardPlus) #INSTALL FROM GITHUB devtools::install_github("RinteRface/shinydashboardPlus")
library(plotly)
library(CRplot)
library(htmlwidgets)
library(shinyWidgets)
library(DT)
library(shinyjs)
library(shinyalert)
library(sparkline)
library(shinythemes)
library(tigris)

#read env vars
#readRenviron(".Renviron")

#read in functions
source("Functions/ditto.R")
source("Functions/plot_cases.R")
source("Functions/leaflet_proxy_adds.R") #https://github.com/rstudio/leaflet/issues/496#issuecomment-650122985

#create endpoint for azure storage
endpoint <- storage_endpoint(os.environ('CONTAINER_URL'), key = os.environ('CONTAINER_KEY'))
container <- storage_container(endpoint, os.environ('CONTAINER_NAME'))

#read in county geo shapes and county list
county_shapes <- tigris::counties(cb = T,resolution = "5m")
county_list <- county_shapes %>% as.data.frame() %>% select(STATEFP,NAME,GEOID) %>% arrange(NAME)

#read in state shape data
states_list <- tigris::states(cb = T,resolution = "5m") %>% 
  select(NAME,STATEFP) %>% 
  filter(NAME != "Commonwealth of the Northern Mariana Islands") %>%
  arrange(NAME)

#read in naming lookup table
full_county_names_list <- county_shapes %>% select(GEOID,COUNTY_NAME = NAME,STATEFP) %>% 
  as.data.frame() %>% 
  select(-geometry) %>% 
  left_join(states_list %>% select(STATEFP,STATE_NAME = NAME),by="STATEFP") %>% 
  select(-geometry) %>% 
  mutate(full_county_name = paste0(COUNTY_NAME,", ",STATE_NAME))
full_county_names_list_for_input <- split(full_county_names_list %>% select(full_county_name,GEOID) %>% deframe(),full_county_names_list$STATE_NAME)
