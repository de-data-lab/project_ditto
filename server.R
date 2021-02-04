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
  
  layover_div <- tags$div(
    HTML('<div><div id="mouseover_county_text" class="shiny-html-output shiny-bound-output" aria-live="polite"></div></div>')
  )  
  
  #map output
  output$county_map <- renderLeaflet({
    print("rendering leaflet init")
    leaflet(options = leafletOptions(zoomControl = F,attributionControl = FALSE,worldCopyJump = TRUE)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas") %>%
      setView(lat = 38, lng = -95.5, zoom = 4) %>% 
      addPolygons(data = county_shapes$geometry,stroke = F,weight = 0, smoothFactor = 0.2, fillOpacity = 0,opacity = 0,
                  color = "white",fillColor = "white",
                  layerId = paste0(county_shapes$GEOID)
      ) %>% 
      addPolygons(data = states_list,stroke = TRUE,weight = .6, smoothFactor = 0.8, fillOpacity = 0,
                  color = "#333333",fill = F) %>% 
      htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
    }") %>% 
      addControl(layover_div,position = "bottomleft")
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
  mouseover_county <- reactiveVal("")
   observe({
    if(!is.null(req(input$county_map_shape_mouseover$id))){
      mouseover_county(ditto_output() %>% filter(comp == input$county_map_shape_mouseover$id) %>% unlist())
    } else {
      mouseover_county(c("name" = ""))
    }
  })
  
  #when county mouseover on map, adjust hover text if not null
  observe({
    selected_county_filter()
    mc <- req(mouseover_county())
    if(mc["name"] == ""){
      runjs("document.getElementById('mouseover_county_text').innerHTML = '';")
    } else {
    contents <- HTML(glue::glue("<b>{mc[\"name\"]}</b><br><b>Similarity:</b> {scales::percent(as.numeric(mc[\"distance\"]),.01)}<br><b>Total Population:</b> {scales::comma(as.numeric(mc[\"total_pop\"]),1)}<br><b>% Urban/Rural:</b> {scales::comma(as.numeric(mc[\"per_urban\"]),.01)}% / {scales::comma(as.numeric(mc[\"per_rural\"]),.01)}%<br>"))
    runjs(paste0("document.getElementById('mouseover_county_text').innerHTML = \"",contents,"\";"))
    }
  })
  
  #remove hover text when filter changes
  observeEvent(input$county,{
    mouseover_county(c("name" = ""))
    runjs("document.getElementById('mouseover_county_text').innerHTML = '';")
  })
  
  #recolor map shapes when new county is selected
  observeEvent(selected_county_filter(),{
    print("leaflet proxy activate")
    plot_data <- county_shapes %>% 
      filter(GEOID != selected_county_filter()) %>% 
      left_join(ditto_output() %>% select(comp,distance),by = c("GEOID"="comp"))
    
    pal <- colorNumeric(
      palette = "viridis",
      domain = plot_data$distance
    )
    
    legend_pal <- colorNumeric(
      palette = "viridis",
      domain = plot_data$distance,
      reverse = T
    )
    
    selected_county_plot_data <- county_shapes %>%
      filter(GEOID == isolate(selected_county_filter()))
    
    leafletProxy("county_map") %>%
      setShapeStyle(data = plot_data, smoothFactor = 0.2, stroke = T, layerId = paste0(plot_data$GEOID), color = ~pal(distance),fillColor = ~pal(distance),opacity = .4,fillOpacity = .8,weight = 1) %>% 
      
      addPolygons(data = selected_county_plot_data,color = CRplot::CR_red(),weight = 1,fill = "red",stroke = F,fillOpacity = 1,layerId = "selected_county_map") %>% 
      
      addLegend("bottomright", pal = legend_pal, values = plot_data$distance,
                title = "Similarity",
                opacity = 1,layerId = "county_map_legend",
                labFormat = labelFormat(suffix = "%",transform = function(x) sort(x*100, decreasing = T))
      )
  })
  
  #data table output
  output$table <- DT::renderDataTable(server = T,{

    tibble::tribble(
      ~fips, ~comp, ~distance, ~name,  ~total_pop, ~per_urban, ~per_rural,
      "12345","12345", 1, "Placeholder", 123456, 50, 50
    ) %>% 
      arrange(desc(distance)) %>% 
      mutate(
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
      
      DT::datatable(rownames= FALSE,options = list(pageLength = 1000, scrollY = "300px",order = list(list(0, 'desc')))) %>% 
      DT::formatPercentage(c('Similarity','% Urban','% Rural'), 2) %>% 
      DT::formatRound('Total Population',0) %>% 
      DT::formatStyle(c('% Urban','% Rural'),
                      background = styleColorBar(range(0,1), 'lightblue'),
                      backgroundSize = '98% 88%',
                      backgroundRepeat = 'no-repeat',
                      backgroundPosition = 'center')

  })
  
  #data table proxy update
  dt_proxy <- DT::dataTableProxy("table")
  
  observe({
    print("replacing data in datatable")
    
    updated_data <- ditto_output() %>% 
    arrange(desc(distance)) %>% 
    mutate(
      per_urban = per_urban/100,
      per_rural = per_rural/100
    ) %>% 
    select(-fips,-comp,
           County = name,
           Similarity = distance,
           `Total Population` = total_pop,
           `% Urban` = per_urban,
           `% Rural` = per_rural
    )
    
    DT::replaceData(dt_proxy, updated_data,rownames= FALSE,resetPaging = T,clearSelection = T)
    
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
  
  #render plot title
  output$plotly_title <- renderText({
    selected_county_full_name <- full_county_names_list %>% 
      filter(GEOID == selected_county_filter()) %>% 
      select(full_county_name) %>% 
      unique() %>% 
      pull()
    
    paste0(glue::glue("<b style=\"color: #E83536;\">{selected_county_full_name}</b> vs. <span style=\"color: grey;\">Most Similar Counties</b>"))
  })

}