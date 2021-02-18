# Project Ditto

## Objective
Tool's objective is to compare a single county's COVID-19 cases to other counties in the US.

## Data Pipeline
The `update_data_azure.R` file processes and saves relevant data to Azure blob storage.

- Pre-processing of similarity scores and uploads a csv per county
- Saves `data_aggregated` - a tidy format of cases per county per week
- Saves `data_sparklines` - a tidy format of county information + sparkline for datatable

## Development Instructions

### .Renviron
This project requires a connection to DDIL's Azure blob storage to access processed data. The environment variables will look like the  following in the `.Renviron` file:

```
storage_container_url = ""
storage_container_name = ""
storage_container_key = ""
```

### Local package installation
The `global.R` file has the packages required to run the Shiny app. Please note that `shinydashboardPlus` should be installed from the latest GitHub release `devtools::install_github("RinteRface/shinydashboardPlus")`.

## Docker Commands (to run locally)
After creating the .Renviron file, you can run the app in a docker container.

`docker build -t project_ditto .`

`docker run --rm -p 3838:3838 project_ditto`