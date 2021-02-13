states <- tigris::states(cb = T,resolution = "5m") %>% 
  select(NAME,STATEFP) %>% 
  filter(NAME != "Commonwealth of the Northern Mariana Islands")
saveRDS(states,"data/states.RDS")
