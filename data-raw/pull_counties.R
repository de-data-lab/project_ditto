county_shapes <- tigris::counties(cb = T)
saveRDS(county_shapes,"data/county_shapes.RDS")
