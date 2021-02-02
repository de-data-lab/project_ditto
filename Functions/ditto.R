ditto <- function(chosen_county, path_folder = "project_ditto/county_cases/", n = 10){
  
  path <- paste0(path_folder, chosen_county, ".csv")
  
  blob <- download_blob(container, src=path, dest=NULL, overwrite=FALSE)
  
  read_csv(blob) %>% 
    arrange(distance) %>% 
    head(n)

}

# philly_ditto <- ditto(dist_df, "Philadelphia, Pennsylvania, US")
# ncc_ditto <- ditto(dist_df, "New Castle, Delaware, US")