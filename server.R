server <- function(input, output, session) {
  
  #populate state dropdown
  observe({
    #named list for states
    state_list_prep <- states_list$STATEFP
    names(state_list_prep) <- states_list$NAME
    
    updateSelectizeInput(session,"state",choices = state_list_prep,selected = 10)
  })
  
  #populate county dropdown
  observe({
    #filter counties to relevant state
    county_list <- county_list %>% filter(STATEFP == input$state)
    
    #named list for counties
    county_list_prep <- county_list$GEOID
    names(county_list_prep) <- county_list$NAME
    
    updateSelectizeInput(session,"county",choices = county_list_prep,selected = 10003)
  })
  
  observe({
    cat("Currently Selected State:",input$state,
        "\nCurrently Selected County:",input$county) %>% 
      print()
  })
  
  #ditto calculation
  ditto_output <- eventReactive(input$go,ignoreInit = T,{
    ditto(dist_df,input$county,n = 5000) %>% 
      left_join(full_county_names_list %>% select(GEOID,full_county_name),by = c("comp" = "GEOID"))
  })
  
  #map output
  output$county_map <- renderLeaflet({
    
    selected_counties <- ditto_output() %>% pull(comp)
    
    plot_data <- county_shapes %>% 
      #filter(GEOID %in% selected_counties) %>% 
      left_join(ditto_output() %>% select(comp,distance),by = c("GEOID"="comp"))
    
    print(ditto_output())
    
    pal <- colorNumeric(
      palette = "viridis",
      domain = plot_data$distance,
      #na.color = "#FFffffff",
      #alpha = T
      reverse = T
      )
    
    leaflet(options = leafletOptions(zoomControl = FALSE,attributionControl = FALSE,worldCopyJump = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas") %>%
      setView(lat = 39.8283, lng = -98.5795, zoom = 4) %>%
      addPolygons(data = plot_data,stroke = TRUE,weight = 0, smoothFactor = 0.2, fillOpacity = 0.8,
                  color = ~pal(distance),fill = ~pal(distance)
                  )
  })
  
  #table output
  output$test_table <- renderTable({
    
    ditto_output() %>% 
      # select(County = full_county_name,
      #        `Distance Score` = distance) %>% 
      tail(100)
  })
  
  output$individual_county <- renderPlot({
    input$go
    
    isolate({
    
    county_shapes %>% 
      filter(GEOID == input$county) %>% 
      ggplot() +
      geom_sf(fill = "lightblue") +
      theme_void()
    
    })
  })
  
}