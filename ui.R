ui <- fluidPage(

  titlePanel("Project Ditto"),
  splitLayout(
    leafletOutput("county_map") %>% shinycssloaders::withSpinner()
  )
)