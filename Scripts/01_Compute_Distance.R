## Script to conduct clustering 


# Normalize 

scaled_data <- 
data_spread %>% 
  column_to_rownames("combined_key") %>% 
  apply(1, scale) %>%
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("combined_key")


# Return column names lost after apply function

colnames(scaled_data) <- colnames(data_spread)


clust_data <- 
  scaled_data %>% 
  column_to_rownames("combined_key") %>% 
  drop_na()


# Compute Total Distance - we will want to probably limit to last two weeks

total_dist <- dist(clust_data)

dist_df <- 
  as.data.frame(as.matrix(total_dist)) %>% 
  rownames_to_column("county")


# Test philly and ncc

ditto <- function(dist_df, chosen_county, n = 10){
  
  dist_df %>% 
    filter(county == chosen_county) %>% 
    gather(comp, distance, -county) %>% 
    filter(comp != chosen_county) %>% 
    arrange(distance) %>% 
    head(n)
  
}

philly_ditto <- ditto(dist_df, "Philadelphia, Pennsylvania, US")


ncc_ditto <- ditto(dist_df, "New Castle, Delaware, US")




