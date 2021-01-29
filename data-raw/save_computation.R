source("Scripts/00_Ingestion_Cleaning.R")
source("Scripts/01_Compute_Distance.R")
saveRDS(dist_df,"data/dist_df.RDS")
