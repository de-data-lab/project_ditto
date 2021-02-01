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
    fluidRow(
      box(title = "Heatmap of Similarity",leafletOutput("county_map") %>% shinycssloaders::withSpinner()),
    
    box(title = "Selected County",
      fluidRow(
        column(5,selectizeInput("state",label = "State Select",choices = state_list_prep,selected = 10)),
        column(5,selectizeInput("county",label = "County Select",choices = c(""))),
        column(2,actionButton("go","Go"))
      ),
      fluidRow(
        column(7,plotOutput("individual_county",width = "100%") %>% shinycssloaders::withSpinner()),
        column(5,
               HTML("<b>Demographic Breakdown</b><br>
                     white_pop<br>
                     black_pop<br>
                     asian_pop<br>
                     hispanic_pop<br>
                     total_pop<br>
                     per_urban<br>
                     per_rural"))
      )
    )
    ),
    fluidRow(
    box(title = "Table Output",collapsible = T,tableOutput("test_table") %>% shinycssloaders::withSpinner()),
    )
    
  ),
  controlbar = dashboardControlbar(),
  title = "Project Ditto",skin = "purple"
)