server <- function(input, output, server) {
  
  output$county_map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE,attributionControl = FALSE,worldCopyJump = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas") %>%
      setView(lat = 39.8283, lng = -98.5795, zoom = 4) %>%
      addPolygons(data = county_shapes,stroke = TRUE,weight = 1, smoothFactor = 0.2, fillOpacity = 0.3)
  })
  
}