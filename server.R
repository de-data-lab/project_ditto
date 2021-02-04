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
    print("ditto running")
    ditto(req(selected_county_filter()),n = 5000)
  })
  
  #map output
  output$county_map <- renderLeaflet({
    print("rendering leaflet init")
    leaflet(options = leafletOptions(zoomControl = FALSE,attributionControl = FALSE,worldCopyJump = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas") %>%
      setView(lat = 38, lng = -95.5, zoom = 4) %>% 
      addPolygons(data = county_shapes$geometry,stroke = F,weight = 0, smoothFactor = 0.2, fillOpacity = 0,opacity = 0,
                  color = "white",fillColor = "white",
                  layerId = paste0(county_shapes$GEOID)
                  # ,highlight = highlightOptions(
                  #   weight = 1,
                  #   color = "black",
                  #   opacity = 1,
                  #   #stroke = T,
                  #   bringToFront = F,
                  #   fillOpacity = .8,
                  #   fill = T
                  # )
      ) %>% 
      addPolygons(data = states_list,stroke = TRUE,weight = .6, smoothFactor = 0.8, fillOpacity = 0,
                  color = "#333333",fill = F)
  })
  
  #if map is clicked, set values
  observe({
    clicked_county <- req(input$county_map_shape_click$id)
    print(clicked_county)
    
    if(!is.null(clicked_county) && !(clicked_county %in% c("49003", "49033", "49057", "49029", "49009", "49023", "49027", "49001", "49031", "49017", "49055", "49041", "49039", "49019"))){
      shiny::updateSelectizeInput(session,"county",selected = clicked_county)
    }
    
  })

  #mouseover value for map
  mouseover_county <- reactive({
    #print(input$county_map_shape_mouseover$id)
    if(!is.null(req(input$county_map_shape_mouseover$id))){
      ditto_output() %>% filter(comp == input$county_map_shape_mouseover$id) %>% unlist()
    }
  })
  
  #display mouseover output
  output$mouseover_county_text <- renderText({
    mc <- req(mouseover_county())

    HTML(glue::glue("<b>{mc[\"name\"]}:</b> {scales::percent(as.numeric(mc[\"distance\"]),.01)}<br>
                    <b>Total Population:</b> {scales::comma(as.numeric(mc[\"total_pop\"]),1)}<br>
                    <b>% Urban/Rural:</b> {scales::comma(as.numeric(mc[\"per_urban\"]),.01)}% / {scales::comma(as.numeric(mc[\"per_rural\"]),.01)}%<br>"))
  })
  
  #recolor map shapes when new county is selected
  observeEvent(selected_county_filter(),{
    print("leaflet proxy activate")
    plot_data <- county_shapes %>% 
      filter(GEOID != selected_county_filter()) %>% 
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
                title = "Similarity %",
                opacity = 1,layerId = "county_map_legend",
                labFormat = labelFormat(suffix = "%",transform = function(x) 100 * x)
      )
  })
  
  #table output
  output$table <- DT::renderDataTable(server = T,{
    
    total_pop_range <- ditto_output() %>% 
      select(total_pop) %>% range()
    
    ditto_output() %>% 
      arrange(desc(distance)) %>% 
      mutate(
            #distance = scales::percent(distance,.1),
             #total_pop = scales::comma(total_pop,1),
             #per_urban = scales::percent(per_urban/100,.01),
             #per_rural = scales::percent(per_rural/100,.01)
              per_urban = per_urban/100,
              per_rural = per_rural/100
             ) %>% 
      select(-fips,-comp,
             County = name,
             Similarity = distance,
             `Total Population` = total_pop,
             `% Urban` = per_urban,
             `% Rural` = per_rural
      ) %>% 
      
      DT::datatable(rownames= FALSE,options = list(pageLength = 1000, scrollY = "300px"),) %>% 
      DT::formatPercentage(c('Similarity','% Urban','% Rural'), 2) %>% 
      DT::formatRound('Total Population',0) %>% 
      DT::formatStyle(c('% Urban','% Rural'),
                      background = styleColorBar(range(0,1), 'lightblue'),
                      backgroundSize = '98% 88%',
                      backgroundRepeat = 'no-repeat',
                      backgroundPosition = 'center')

  })
  
  #plot cases over time
  output$trend <- renderPlotly({
    comparison_fips <- ditto_output() %>% 
      filter(comp != selected_county_filter()) %>% 
      head(10) %>% 
      select(comp) %>% 
      pull()

    plot_cases(data_aggregated,selected_county_filter(),comparison_fips)
  })
  
  output$plotly_title <- renderText({
    selected_county_full_name <- full_county_names_list %>% 
      filter(GEOID == selected_county_filter()) %>% 
      select(full_county_name) %>% 
      unique() %>% 
      pull()
    
    paste0(glue::glue("<b style=\"color: #E83536;\">{selected_county_full_name}</b> vs. <span style=\"color: grey;\">Most Similar Counties</b>"))
  })

}