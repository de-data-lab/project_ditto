library(tidyverse)
library(leaflet)
library(shinycssloaders)
library(sf)
library(AzureStor)
library(shinydashboard)
library(shinydashboardPlus) #INSTALL FROM GITHUB devtools::install_github("RinteRface/shinydashboardPlus")
library(plotly)
library(CRplot)
library(htmlwidgets)
library(shinyWidgets)
library(DT)
library(shinyjs)
library(shinyalert)

library(mapboxer)

# Create endpoint for azure storage

#read in functions
source("Functions/ditto.R")
source("Functions/plot_cases.R")
source("Functions/leaflet_proxy_adds.R")

readRenviron(".Renviron")



#read in county geo shapes and county list
county_shapes <- readRDS("data/county_shapes.RDS") %>% sf::st_cast("POLYGON")
county_list <- county_shapes %>% as.data.frame() %>% select(STATEFP,NAME,GEOID) %>% arrange(NAME)

#read in state shape data
states_list <- readRDS("data/states.RDS") %>% arrange(NAME)

#read in naming lookup table
full_county_names_list <- readRDS("data/full_county_names_list.RDS")
full_county_names_list_for_input <- split(full_county_names_list %>% select(full_county_name,GEOID) %>% deframe(),full_county_names_list$STATE_NAME)

#read in covid cases
data_aggregated <- readRDS("data/data_aggregated.RDS")

legend_css_fix <- "div.info.legend.leaflet-control br {clear: both;}" # CSS to correct spacing
legend_html_fix <- htmltools::tags$style(type = "text/css", legend_css_fix)  # Convert CSS to HTML

#this code changes the selectize input if there is a county in the URL query when page loads
jscode <- '
shinyjs.init = function() {
  const urlParams = new URLSearchParams(window.location.search);
  const county = urlParams.get("county");
  if(urlParams.has("county")) {
    $("#county").selectize()[0].selectize.setValue(county);
  }
}'

ui <- dashboardPage(
  header = dashboardHeader(title = "DE Data Innovation Lab"),
  
  #SIDEBAR
  sidebar = dashboardSidebar(),
  
  #BODY
  body = dashboardBody(
    leafletjs,
    useShinyjs(),
    useShinyalert(),
    extendShinyjs(text = jscode, functions = c()),
    tags$head(tags$style("#county {background-color: #ECF0F5 !important};")),
    
    #HOW SIMILAR IS THE SPREAD OF COVID-19 IN X COUNTY TO OTHER COUNTIES IN THE UNITED STATES?
    fluidRow(
      tags$div(class="col-lg-5 col-md-4 col-sm-3",tags$p("How similar is the spread of COVID-19 in ",style = "padding-top:4px; font-size: 20px; text-align: right;; font-weight: bold;color: #666666;")),
      
      tags$div(class="col-lg-2 col-md-3 col-sm-4",tags$div(selectizeInput("county",label = NULL,choices = full_county_names_list_for_input,selected = "10003",width = "100%",options = list(placeholder="Type or scroll to select a county")),style = "text-align: center;")),
      tags$div(class="col-lg-4 col-md-4 col-sm-3",tags$p("to other counties in the United States?",style = "padding-top:4px; font-size: 20px; text-align: left; font-weight: bold; color: #666666;")),
    ),
    
    #HEATMAP OF SIMILARITY
    fluidRow(
      box(width = 12,title = HTML("Heatmap of Similarity <span style=\"font-size: 12px;\">(click on any county to change selection, hover over any county to see comparison)</span>"),mapboxerOutput("county_map") %>% htmlwidgets::prependContent(legend_html_fix) %>% shinycssloaders::withSpinner())
    )),
  
  title = "COVID-19 County Similarity Tool",skin = "purple"
)


server <- function(input, output, session) {
  
  #store selected county in a reactive (detect NULL values)
  selected_county_filter <- reactive({
    req(input$county)
  })
  
  #ditto calculation
  ditto_output <- eventReactive(selected_county_filter(),ignoreNULL = F,{
    print("ditto running")
    ditto(req(selected_county_filter()),n = 5000)
  })
  
  output$county_map <- renderMapboxer({
    print("rendering leaflet init")
    
    county_shapes <- county_shapes %>% 
      mutate(distance_color = "#FFFFFF",
             label = GEOID)
    
    selected_county_plot_data <- county_shapes %>%
      filter(GEOID == isolate(selected_county_filter()))

    mapboxer(
      center = c(-95.5, 38),
      zoom = 5,
      style = basemap_background_style(color = "#ffffff", opacity = 1)
    ) %>% 
      add_fill_layer(
        source = as_mapbox_source(county_shapes),fill_color = c("get","distance_color"),id = "test",fill_opacity = .8
      ) %>% 
      add_tooltips(layer_id = "test", tooltip = "{{label}}") %>% 
      add_line_layer(source = as_mapbox_source(states_list),line_color = "#323232",id="states") %>% 
      add_line_layer(source = as_mapbox_source(selected_county_plot_data),line_color = "red",id="selected_county",line_opacity = 1) %>% 
      add_navigation_control()
  })
  
  observeEvent(selected_county_filter(), {
    
    plot_data <- county_shapes %>% 
      #filter(GEOID != selected_county_filter()) %>% 
      left_join(ditto_output() %>% select(comp,distance),by = c("GEOID"="comp"))
    
    pal <- colorNumeric(
      palette = "viridis",
      domain = plot_data$distance
    )
    
    plot_data <- plot_data %>% 
      mutate(distance_color = pal(distance)) %>% 
      mutate(label = paste0(GEOID,": ",distance))
    
    selected_county_plot_data <- county_shapes %>%
      filter(GEOID == isolate(selected_county_filter()))
    
    
    
    mapboxer_proxy("county_map") %>% 
      set_data(
        data = plot_data,source_id = "test"
      ) %>% 
      set_data(
        data = selected_county_plot_data,source_id = "selected_county"
      ) %>% 
      update_mapboxer()
  })
  
}


shinyApp(ui = ui, server = server)