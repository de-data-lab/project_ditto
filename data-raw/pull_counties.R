county_shapes <- tigris::counties(cb = T,resolution = "5m")
saveRDS(county_shapes,"data/county_shapes.RDS")
