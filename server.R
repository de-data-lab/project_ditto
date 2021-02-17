server <- function(input, output, session) {
  
  #store selected county in a reactive (detect NULL values)
  selected_county_filter <- reactive({
    req(input$county)
  })
  
  #when a county is selected, update query param
  #issue with shinyapps deployment here
  # observeEvent(selected_county_filter(),ignoreInit = T,ignoreNULL = T,{
  #   updateQueryString(paste0("?county=",selected_county_filter()))
  # })
  
  onclick("copy_link",shinyalert(title = "Copy The Link Below", text=paste0("https://compassred.shinyapps.io/project_ditto/?county=",selected_county_filter()), type = "info"))
  
  #print out currently selected county
  observe({
    cat("Currently Selected County:",selected_county_filter(),"\n")
  })
  
  #when you click the county filter, remove the text
  onclick("county", {
    updateSelectizeInput(session, "county", selected = "")
  })
  
  #ditto calculation
  ditto_output <- eventReactive(selected_county_filter(),ignoreNULL = F,{
    print("ditto running")
    ditto(req(selected_county_filter()),n = 5000)
  })
  
  #define layover html div to add to map
  layover_div <- tags$div(
    HTML('<div id="mouseover_county_text" class="shiny-html-output shiny-bound-output" aria-live="polite"></div>')
  )  
  
  #map output
  output$county_map <- renderLeaflet({
    print("rendering leaflet init")
    leaflet(options = leafletOptions(zoomControl = F,attributionControl = FALSE,worldCopyJump = TRUE, scrollWheelZoom = F)) %>% 
      addProviderTiles(providers$CartoDB.Positron, group = "Canvas",options = providerTileOptions(minZoom = 4)) %>%
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
      addControl(layover_div,position = "bottomleft",layerId = "mouseover_layer") %>% 
      leaflet.extras::suspendScroll()
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
    contents <- HTML(glue::glue("<b>{mc[\"name\"]}</b><br><b>Similarity:</b> {scales::percent(as.numeric(mc[\"distance\"]),.01)}<br><b>Total Population:</b> {scales::comma(as.numeric(mc[\"total_pop\"]),1)}"))
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
    shinyjs::runjs("document.getElementById('heatmap_title').style.color = 'lightgrey';")
    plot_data <- county_shapes %>% 
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
      
      addPolygons(data = selected_county_plot_data,color = CRplot::CR_red(),weight = 1.5,fill = F,stroke = T,fillOpacity = 0,opacity = 1,layerId = "selected_county_map") %>% 
      
      addLegend("bottomright", pal = legend_pal, values = plot_data$distance,
                title = "Similarity",
                opacity = 1,layerId = "county_map_legend",
                labFormat = labelFormat(suffix = "%",transform = function(x) sort(x*100, decreasing = T))
      )
    
    shinyjs::runjs("document.getElementById('heatmap_title').style.removeProperty('color');")
  })
  
  #data table output
  output$table <- DT::renderDataTable(server = T,{

    tibble::tribble(
      ~fips, ~comp, ~distance, ~name,  ~total_pop,~total_cases, ~cases_per, ~sparkline,
      "12345","12345", 1, "Placeholder", 123456,1500,500.00, "<div></div>"
    ) %>% 
      arrange(desc(distance)) %>% 
      select(-fips,-comp,
             County = name,
             Similarity = distance,
             `Total Population` = total_pop,
             `Total Cases` = total_cases,
             `Total Cases per Capita` = cases_per,
             `New Case Trend` = sparkline
      ) %>% 
      
      DT::datatable(rownames= FALSE,escape = FALSE,options = list(pageLength = 100, scrollY = "300px",order = list(list(0, 'desc')),fnDrawCallback = htmlwidgets::JS(
        'function(){HTMLWidgets.staticRender();}'
      ))) %>% 
      spk_add_deps() %>% 
      DT::formatPercentage(c('Similarity'), 2) %>% 
      DT::formatRound(c('Total Population','Total Cases','Total Cases per Capita'),0) %>% 
      DT::formatString(c('County','New Case Trend'))

  })
  
  #data table proxy update
  dt_proxy <- DT::dataTableProxy("table")
  
  observe({
    print("replacing data in datatable")
    
    updated_data <- ditto_output() %>% 
    arrange(desc(distance)) %>% 
    left_join(data_sparklines %>% select(fips,total_cases,cases_per,sparkline),by = c("comp" = "fips")) %>% 
    select(-fips,-comp,-per_urban,-per_rural,
           County = name,
           Similarity = distance,
           `Total Population` = total_pop,
           `Total Cases` = total_cases,
           `Total Cases per Capita` = cases_per,
           `New Case Trend` = sparkline
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
    
    paste0(glue::glue("New COVID-19 Cases per Capita (100k) in <b style=\"color: #E83536;\">{selected_county_full_name}</b> vs. <span style=\"color: #9e9e9e;\">Most Similar Counties</b>"))
  })

}