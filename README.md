# Project Ditto

## Objective
Tool's objective is to compare a single county's COVID-19 cases to other counties in the US.

## Development Instructions
In order to run the Shiny app locally, the `/data` folder must be created and contain the .RDS files that are saved as a results of the scripts in `/data-raw`. Please run the `/dev/convert_data_raw_to_data.R` script to do this.

## .Renviron
This project requires a connection to DDIL's Azure blob storage to access processed data. The environment variables will look like the  following in the `.Renviron` file:

```
storage_container_url = ""
storage_container_name = ""
storage_container_key = ""
```