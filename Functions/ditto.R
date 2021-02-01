ditto <- function(dist_df, chosen_county, n = 10){
  
  dist_df %>% 
    filter(fips == chosen_county) %>% 
    gather(comp, distance, -fips) %>% 
    filter(comp != chosen_county) %>% 
    arrange(distance) %>% 
    head(n)
  
}

# philly_ditto <- ditto(dist_df, "Philadelphia, Pennsylvania, US")
# ncc_ditto <- ditto(dist_df, "New Castle, Delaware, US")