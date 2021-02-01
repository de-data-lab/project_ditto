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
    county_list_prep <- county_list %>% filter(STATEFP == input$state) %>% pull(NAME)
    
    updateSelectizeInput(session,"county",choices = county_list_prep,selected = "New Castle")
  })
  
  observe({
    cat("Currently Selected State: ",input$state,
        "\nCurrently Selected County: ",input$county) %>% 
      print()
  })
  
  #ditto calculation
  ditto_output <- eventReactive(input$go,ignoreInit = T,{
    state_full_name <- states_list %>% filter(STATEFP == input$state) %>% pull(NAME)
    county_state_input <- paste0(input$county,", ",state_full_name,", US")
    ditto(dist_df,county_state_input,n = 100)
  })
  
  #map output
  output$county_map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE,attributionControl = FALSE,worldCopyJump = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas") %>%
      setView(lat = 39.8283, lng = -98.5795, zoom = 4) %>%
      addPolygons(data = county_shapes[1,1],stroke = TRUE,weight = 1, smoothFactor = 0.2, fillOpacity = 0.3)
  })
  
  #table output
  output$test_table <- renderTable({
    ditto_output() %>% 
      head(10) %>% 
      select(-county)
  })
  
  output$individual_county <- renderPlot({
    input$go
    
    isolate({
    
    selected_county_fips <- county_list %>%
      filter(NAME == req(input$county)) %>%
      filter(STATEFP == req(input$state)) %>%
      pull(GEOID)
    
    county_shapes %>% 
      filter(GEOID == selected_county_fips) %>% 
      ggplot() +
      geom_sf(fill = "lightblue") +
      theme_void()
    
    })
  })
  
}