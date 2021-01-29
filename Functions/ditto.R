ditto <- function(dist_df, chosen_county, n = 10){
  
  dist_df %>% 
    filter(county == chosen_county) %>% 
    gather(comp, distance, -county) %>% 
    filter(comp != chosen_county) %>% 
    arrange(distance) %>% 
    head(n)
  
}

# philly_ditto <- ditto(dist_df, "Philadelphia, Pennsylvania, US")
# ncc_ditto <- ditto(dist_df, "New Castle, Delaware, US")