library(shinydashboardPlus)
legend_css_fix <- "div.info.legend.leaflet-control br {clear: both;}" # CSS to correct spacing
legend_html_fix <- htmltools::tags$style(type = "text/css", legend_css_fix)  # Convert CSS to HTML

ui <- dashboardPage(
  options = list(sidebarExpandOnHover = TRUE),
  header = dashboardHeader(title = "DE Data Innovation Lab"),
  sidebar = dashboardSidebar(minified = F, collapsed = T,
                             tags$div(style = "margin-left: 20px;",
                               tags$h2("Sourcing"),
                               tags$p("COVID-19 Case Data: ",tags$a("JHU CSSE",href ="https://github.com/CSSEGISandData/COVID-19",target="_blank"),"<br>Population/Demographic Data: Census Bureau")
                             )),
  body = dashboardBody(
    leafletjs,
    useShinyjs(),
    # fluidRow(
      # box(width = 12,title = FALSE,
          fluidRow(
            column(4,splitLayout(tags$a(href = "https://ddil.ai",target="_blank",tags$img(src = "ddil_logo.png",height = "60px")),tags$h1("Project Ditto",style = "margin-top: 10px;"),cellWidths = c("25%","75%"))),
            column(4,tags$p("This is a paragraph of what to expect and learn with this tool. Select a county to display similar counties based on COVID-19 trends. You can also click on any county on the map.",style = "margin-top:10px;")),
            
            #How similar is the COVID-19 spread of cases in x county to other counties for all time
            #also keep the other helper text
            
            column(3,selectizeInput("county",label = "County Select",choices = full_county_names_list_for_input,selected = "10003",width = "100%")),
            
          # )
      # )
    ),
    
    
    fluidRow(
      box(width = 12,title = "Heatmap of Similarity",leafletOutput("county_map") %>% htmlwidgets::prependContent(legend_html_fix) %>% shinycssloaders::withSpinner())
    ),
    fluidRow(
    box(title = "Table of Similarity",DT::dataTableOutput("table") %>% shinycssloaders::withSpinner()),
    box(title = htmlOutput("plotly_title"),plotlyOutput("trend") %>% shinycssloaders::withSpinner())
    )
    
  ),
  
  title = "Project Ditto",skin = "purple"
)