ui <- fluidPage(

  titlePanel("Project Ditto"),
  splitLayout(
    tags$div(
      leafletOutput("county_map") %>% shinycssloaders::withSpinner(),
      plotOutput("individual_county") %>% shinycssloaders::withSpinner()
    ),
    tags$div(
      tableOutput("test_table") %>% shinycssloaders::withSpinner(),
      selectizeInput("state",label = "State Select",choices = c("")),
      selectizeInput("county",label = "County Select",choices = c("")),
      actionButton("go","Go")
    )
  )
)