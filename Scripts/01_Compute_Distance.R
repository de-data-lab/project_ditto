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




