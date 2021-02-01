server <- function(input, output, session) {
  
  #populate county dropdown
  observe({
    #filter counties to relevant state
    county_list <- county_list %>% filter(STATEFP == input$state)
    
    #named list for counties
    county_list_prep <- county_list$GEOID
    names(county_list_prep) <- county_list$NAME
    
    #update selected county
    updateSelectizeInput(session,"county",choices = county_list_prep)
  })
  
  observe({
    cat("Currently Selected State:",input$state,
        "\nCurrently Selected County:",input$county)
  })
  
  #ditto calculation
  ditto_output <- eventReactive(input$go,ignoreNULL = F,{
    ditto(dist_df,input$county,n = 5000) %>% 
      left_join(full_county_names_list %>% select(GEOID,full_county_name),by = c("comp" = "GEOID"))
  })
  
  #map output
  output$county_map <- renderLeaflet({
    
    plot_data <- county_shapes %>% 
      left_join(ditto_output() %>% select(comp,distance),by = c("GEOID"="comp"))
    
    pal <- colorNumeric(
      palette = "viridis",
      domain = plot_data$distance,
      #na.color = "#FFffffff",
      #alpha = T
      reverse = T
      )
    
    selected_county_plot_data <- county_shapes %>% 
      filter(GEOID == isolate(input$county))
    
    leaflet(options = leafletOptions(zoomControl = FALSE,attributionControl = FALSE,worldCopyJump = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas") %>%
      setView(lat = 38, lng = -95.5, zoom = 4) %>%

      addPolygons(data = plot_data,stroke = TRUE,weight = 0, smoothFactor = 0.2, fillOpacity = 0.8,
                  color = ~pal(distance),fill = ~pal(distance),
                  layerId = paste0(plot_data$GEOID,"_",plot_data$STATEFP)) %>% 
      
      addPolygons(data = selected_county_plot_data,color = CRplot::CR_red(),weight = 1,fill = "red",stroke = F,fillOpacity = 1) %>% 
      
      addPolygons(data = states_list,stroke = TRUE,weight = .6, smoothFactor = 0.8, fillOpacity = 0,
                  color = "#333333",fill = F) %>% 
      
      addLegend("bottomright", pal = pal, values = plot_data$distance,
                title = "Distance",
                #labFormat = labelFormat(prefix = "$"),
                opacity = 1
      )
  })
  
  #if map is clicked, set values
  observe({
    if(!is.null(req(input$county_map_shape_click$id))){
      
      selected_val <- str_split(input$county_map_shape_click$id,"_")[[1]]
      selected_county <- selected_val[1] %>% as.numeric()
      selected_state <- selected_val[2]

      shiny::updateSelectizeInput(session,"state",selected = selected_state)
      shiny::updateSelectizeInput(session,"county",selected = selected_county)
      
      
    }
  })
  
  #table output
  output$table <- renderTable({
    
    ditto_output() %>% 
      head(20) %>% 
      select(County = full_county_name,
             `Distance Score` = distance)

  })
  
  output$trend <- renderPlotly({
    input$go
    plot_cases(data_aggregated,isolate(input$county))
  })
}