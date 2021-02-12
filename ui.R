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
  sidebar = dashboardSidebar(minified = F, collapsed = T,
                             tags$div(style = "margin: 20px;",
                                      tags$a(href = "https://ddil.ai",target="_blank",tags$img(src = "ddil_logo_white.png",height = "75px",style = "margin-bottom:10px;")),
                                      tags$br(),
                                      tags$a("Learn More",href = "https://ddil.ai",target="_blank"),
                                      tags$br(),
                                      
                                      # Overview
                                      tags$h2("Overview"),
                                      tags$p("Have you ever been curious about which places in the US have experienced COVID in the same way as you? 
                                             This tool allows you to compare your county (or any other) to all other counties and territories across the US.
                                             Counties that are most similar to yours will be highlighted in yellow, while less similar counties will be
                                             highlighted in purple."),
                                      
                                      # Directions
                                      tags$h2("Directions"),
                                      tags$p("Select a county from the drop down menu or by clicking on a county on the map. 
                                             Similarity scores will be automatically updated based upon your selection."),
                                      
                                      # Sharing
                                      tags$h2("Sharing"),
                                      tags$p("Click the button below to share the selected county view with others!"),
                                      actionButton("copy_link","Copy Link",icon = icon("clipboard")),
                                      
                                      # Sourcing
                                      tags$h2("Sourcing"),
                                      tags$p(HTML("<b>COVID-19 Case Data</b><br>"),tags$a("JHU CSSE",href ="https://github.com/CSSEGISandData/COVID-19",target="_blank"),HTML("<br><br><b>Population/Demographic Data</b><br>Census Bureau"))
                             )),
  
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
      box(width = 12,title = HTML("Heatmap of Similarity <span style=\"font-size: 12px;\">(click on any county to change selection, hover over any county to see comparison)</span>"),leafletOutput("county_map") %>% htmlwidgets::prependContent(legend_html_fix) %>% shinycssloaders::withSpinner())
    ),
    
    #TABLE OF SIMILARITY AND PLOT
    fluidRow(
    box(title = "Table of Similarity",DT::dataTableOutput("table") %>% shinycssloaders::withSpinner()),
    box(title = htmlOutput("plotly_title"),plotlyOutput("trend") %>% shinycssloaders::withSpinner())
    )
    
  ),
  
  title = "COVID-19 County Similarity Tool",skin = "purple"
)