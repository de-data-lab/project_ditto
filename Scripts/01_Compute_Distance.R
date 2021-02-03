## Script to compute distance

library(lsa)

# Normalize 

scaled_data <- 
data_spread %>% 
  drop_na() %>% 
  column_to_rownames("fips") %>% 
  apply(1, scale) %>%
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("fips")


# Return column names lost after apply function

colnames(scaled_data) <- colnames(data_spread)


clust_data <- 
  scaled_data %>% 
  column_to_rownames("fips") %>% 
  drop_na()


# Compute Total Distance - we will want to probably limit to last two weeks

#total_dist <- dist(clust_data)

total_dist <- as.data.frame(cosine(t(as.matrix(clust_data))))

dist_df <- 
  total_dist %>% 
  #as.data.frame(as.matrix(total_dist)) %>% 
  rownames_to_column("fips")

# Try cosine

# total_dist_cosine <- as.data.frame(cosine(t(as.matrix(clust_data))))
# 
# 
# total_dist_cosine <- as.data.frame(total_dist_cosine)
# 
dist_cosine_df <-
total_dist_cosine %>%
  rownames_to_column("fips")


ncc_ditto <-
  dist_df %>%
  filter(fips == 06043) %>%
  gather(comp, euc, -fips)


ncc_ditto_cosine <-
  dist_cosine_df %>%
  filter(fips == 06043) %>%
  gather(comp, cosine, -fips)


cosine_euc_comp <-
  ncc_ditto %>%
  left_join(ncc_ditto_cosine, by = c("fips", "comp")) %>%
  mutate(cosine = 1-cosine) %>%
  arrange(cosine)

cosine_euc_comp %>%
  ggplot(aes(x = euc, y = cosine)) +
  geom_point()


