server <- function(input, output, session) {
  
  #store selected county in a reactive (detect NULL values)
  selected_county_filter <- reactive({
    req(input$county)
  })
  
  #print out currently selected county
  observe({
    cat("Currently Selected County:",selected_county_filter(),"\n")
  })
  
  #ditto calculation
  ditto_output <- eventReactive(selected_county_filter(),ignoreNULL = F,{
    ditto(dist_df,req(selected_county_filter()),n = 5000) %>% 
      left_join(full_county_names_list %>% select(GEOID,full_county_name),by = c("comp" = "GEOID"))
  })
  
  #map output
  output$county_map <- renderLeaflet({
    print("rendering leaflet init")
    leaflet(options = leafletOptions(zoomControl = FALSE,attributionControl = FALSE,worldCopyJump = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas") %>%
      setView(lat = 38, lng = -95.5, zoom = 4) %>% 
      addPolygons(data = county_shapes,stroke = F,weight = 0, smoothFactor = 0.2, fillOpacity = 0,
                  color = "white",fill = "white",
                  layerId = paste0(county_shapes$GEOID)) %>% 
      addPolygons(data = states_list,stroke = TRUE,weight = .6, smoothFactor = 0.8, fillOpacity = 0,
                  color = "#333333",fill = F)
  })
  
  #if map is clicked, set values
  observe({
    if(!is.null(req(input$county_map_shape_click$id))){
      shiny::updateSelectizeInput(session,"county",selected = input$county_map_shape_click$id)
    }
  })

  observeEvent(selected_county_filter(),{
    print("leaflet proxy activate")
    plot_data <- county_shapes %>% 
      left_join(ditto_output() %>% select(comp,distance),by = c("GEOID"="comp"))
    
    pal <- colorNumeric(
      palette = "viridis",
      domain = plot_data$distance,
      reverse = T
    )
    
    selected_county_plot_data <- county_shapes %>%
      filter(GEOID == isolate(selected_county_filter()))
    
    leafletProxy("county_map") %>%
      
      setShapeStyle(data = plot_data, smoothFactor = 0.2, stroke = T, layerId = paste0(plot_data$GEOID), color = ~pal(distance),fillColor = ~pal(distance),opacity = .4,fillOpacity = .8,weight = 1) %>% 
      
      addPolygons(data = selected_county_plot_data,color = CRplot::CR_red(),weight = 1,fill = "red",stroke = F,fillOpacity = 1,layerId = "selected_county_map") %>% 
      
      addLegend("bottomright", pal = pal, values = plot_data$distance,
                title = "Distance",
                opacity = 1,layerId = "county_map_legend"
      )
  })
  
  #table output
  output$table <- renderTable({
    
    ditto_output() %>% 
      head(20) %>% 
      select(County = full_county_name,
             `Distance Score` = distance)

  })
  
  #plot cases over time
  output$trend <- renderPlotly({
    plot_cases(data_aggregated,selected_county_filter())
  })

}