# ui <- fluidPage(
# 
#   titlePanel("Project Ditto"),
#   splitLayout(
#     tags$div(
#       leafletOutput("county_map") %>% shinycssloaders::withSpinner(),
#       tableOutput("test_table") %>% shinycssloaders::withSpinner()
#       
#     ),
#     tags$div(
#       fluidRow(
#         column(5, selectizeInput("state",label = "State Select",choices = c(""))),
#         column(5,selectizeInput("county",label = "County Select",choices = c(""))),
#         column(2,actionButton("go","Go")),
#       ),
#       plotOutput("individual_county") %>% shinycssloaders::withSpinner()
#       
#       
#     )
#   )
# )

library(shinydashboardPlus)

ui <- dashboardPage(
  options = list(sidebarExpandOnHover = TRUE),
  header = dashboardHeader(),
  sidebar = dashboardSidebar(minified = TRUE, collapsed = TRUE),
  body = dashboardBody(
    box(leafletOutput("county_map") %>% shinycssloaders::withSpinner()),
    box(tableOutput("test_table") %>% shinycssloaders::withSpinner()),
    
    box(
      fluidRow(
        column(5,selectizeInput("state",label = "State Select",choices = c(""))),
        column(5,selectizeInput("county",label = "County Select",choices = c(""))),
        column(2,actionButton("go","Go"))
      )
    ),
    
    box(plotOutput("individual_county") %>% shinycssloaders::withSpinner())
    
  ),
  controlbar = dashboardControlbar(),
  title = "DashboardPage"
)