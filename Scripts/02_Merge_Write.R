# Merge relevant county data and output individual csv files


# Gather distance data

distance_gathered <-
  dist_df %>% 
  gather(comp, distance, -fips)


# Join county stats to distance via fips

distance_relevant_info <-
  distance_gathered %>% 
  left_join(county_stats, by = c("comp" = "fips")) %>% 
  drop_na() %>% 
  mutate(distance = ifelse(distance < 0 , 0, distance))


# Write individual csv files

for (i in unique(distance_relevant_info$fips)){
  
  w_con <- textConnection("foo", "w")
  
  county_df <-
    distance_relevant_info %>% 
    filter(fips == i)
  
  
  write.csv(county_df, w_con, row.names = F)
  r_con <- textConnection(textConnectionValue(w_con))
  close(w_con)
  storage_upload(container, r_con, paste0("project_ditto/county_cases/", i, ".csv"))
  Sys.sleep(.05)
  
  
}

