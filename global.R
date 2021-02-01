library(tidyverse)
library(leaflet)
library(shinycssloaders)
library(sf)

library(shinydashboard)
library(shinydashboardPlus)

#read in functions
source("Functions/ditto.R")

#read in computed values
dist_df <- readRDS("data/dist_df.RDS")

#read in county geo shapes and county list
county_shapes <- readRDS("data/county_shapes.RDS")
county_list <- county_shapes %>% as.data.frame() %>% select(STATEFP,NAME,GEOID) %>% arrange(NAME)

#read in state lookup data
states_list <- readRDS("data/states.RDS") %>% arrange(NAME)

#read in naming lookup table
full_county_names_list <- readRDS("data/full_county_names_list.RDS")