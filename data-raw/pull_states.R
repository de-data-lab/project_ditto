states <- tigris::states(cb = T) %>% 
  select(NAME,STATEFP)
saveRDS(states,"data/states.RDS")
