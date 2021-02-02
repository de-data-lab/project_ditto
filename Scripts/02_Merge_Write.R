# Merge relevant county data and output individual csv files


# Download county stats

county_stats_blob <- download_blob(container, src="project_ditto/county_stats.csv", dest=NULL, overwrite=FALSE)
county_stats <- 
  read_csv(county_stats_blob) %>% 
  select(fips, name, total_pop, per_urban, per_rural)


# Gather distance data

distance_gathered <-
  dist_df %>% 
  gather(comp, distance, -fips)


# Join county stats to distance via fips

distance_relevant_info <-
  distance_gathered %>% 
  left_join(county_stats, by = c("comp" = "fips"))


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
  
  
}
