server <- function(input, output, session) {
  
  #populate state dropdown
  observe({
    #named list for states
    state_list_prep <- states_list$STATEFP
    names(state_list_prep) <- state_list$NAME
    
    updateSelectizeInput(session,"state",choices = state_list_prep,selected = 10)
  })
  
  #populate county dropdown
  observe({
    #filter counties to relevant state
    county_list_prep <- county_list %>% filter(STATEFP == input$state) %>% pull(NAME)
    
    updateSelectizeInput(session,"county",choices = county_list_prep,selected = "New Castle")
  })
  
  #ditto calculation
  ditto_output <- eventReactive(input$go,ignoreInit = T,{
    state_full_name <- states_df %>% filter(STATEFP == input$state) %>% pull(NAME)
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
      head(10)
      select(-county)
  })
  
}