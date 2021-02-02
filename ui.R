library(shinydashboardPlus)

ui <- dashboardPage(
  options = list(sidebarExpandOnHover = TRUE),
  header = dashboardHeader(title = "DE Data Innovation Lab"),
  sidebar = dashboardSidebar(minified = F, collapsed = T,
                             tags$div(style = "margin-left: 20px;",
                               tags$h2("Sourcing"),
                               tags$p("Lorem Ipsum")
                             )),
  body = dashboardBody(
    leafletjs,
    # fluidRow(
      # box(width = 12,title = FALSE,
          fluidRow(
            column(3,splitLayout(tags$a(href = "https://ddil.ai",target="_blank",tags$img(src = "ddil_logo.png",height = "60px")),tags$h1("Project Ditto",style = "margin-top: 10px;"),cellWidths = c("30%","70%"))),
            column(4,tags$p("This is a paragraph of what to expect and learn with this tool. Select a county to display similar counties based on COVID-19 trends. You can also click on any county on the map.",style = "margin-top:10px;")),
            column(2,selectizeInput("county",label = "County Select",choices = full_county_names_list_for_input,selected = "10003",width = "100%")),
            
          # )
      # )
    ),
    
    
    fluidRow(
      box(width = 12,title = "Heatmap of Similarity",leafletOutput("county_map") %>% shinycssloaders::withSpinner()),
    
    ),
    fluidRow(
    box(title = "Table Output",tableOutput("table") %>% shinycssloaders::withSpinner()),
    box(title = "COVID-19 Cases Trended",plotlyOutput("trend") %>% shinycssloaders::withSpinner())
    )
    
  ),
  
  title = "Project Ditto",skin = "purple"
)