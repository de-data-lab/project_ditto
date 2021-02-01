county_shapes <- readRDS("data/county_shapes.RDS")
states_list <- readRDS("data/states.RDS") %>% arrange(NAME)

county_shapes %>% select(GEOID,COUNTY_NAME = NAME,STATEFP) %>% 
  as.data.frame() %>% 
  select(-geometry) %>% 
  left_join(states_list %>% select(STATEFP,STATE_NAME = NAME),by="STATEFP") %>% 
  select(-geometry) %>% 
  mutate(full_county_name = paste0(COUNTY_NAME,", ",STATE_NAME)) %>% 
  saveRDS("data/full_county_names_list.RDS")
