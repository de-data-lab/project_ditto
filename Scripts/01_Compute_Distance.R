## Script to conduct clustering 


# Normalize 

cases_scaled <- 
  cases_spread %>% 
  column_to_rownames("combined_key") %>% 
  apply(1, scale) %>%
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("combined_key")


# Return column names lost after apply function

colnames(cases_scaled) <- colnames(cases_spread)


cases_clust <- 
  cases_scaled %>% 
  column_to_rownames("combined_key") %>% 
  drop_na()


# Compute Total Distance - we will want to probably limit to last two weeks

total_dist <- dist(cases_clust)

dist_df <- 
  as.data.frame(as.matrix(total_dist)) %>% 
  rownames_to_column("county")




