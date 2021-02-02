library(tidyr)
library(tibble)
library(dplyr)
library(readr)
library(stringr)
library(janitor)
library(lubridate)
library(tidycensus)
library(plotly)

# Read in daily data and get rid of unncessary columns

data <- 
  read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv") %>% 
  select(-UID, -iso2, -iso3, -code3, -Admin2) %>% 
  clean_names()


# gather, aggregate, and then spread 

data_gathered <-
  data %>% 
  mutate(fips = str_pad(fips, 5, pad = "0")) %>% 
  select(-combined_key, -province_state, -country_region, -lat, -long) %>% 
  gather(date, cases, -fips) %>% 
  mutate(date = str_remove_all(date, "x"),
         date = str_replace_all(date, "_", "-"),
         date = as.Date(date, format = "%m-%d-%y"))


data_aggregated <-
  data_gathered %>% 
  mutate(week = floor_date(date, unit = "week")) %>% 
  group_by(fips, week) %>% 
  mutate(cases = cases - lag(cases, 1)) %>% 
  summarize(cases = sum(cases, na.rm = T)) %>% 
  ungroup() %>% 
  mutate(cases = ifelse(cases < 0, 0, cases))


# Spread back to have on row per county

data_spread <-
  data_aggregated %>% 
  spread(key = week, value = cases)

scaled_data <- 
  data_spread %>% 
  drop_na() %>% 
  column_to_rownames("fips") %>% 
  apply(1, scale) %>%
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("fips")


# Return column names lost after apply function

colnames(scaled_data) <- colnames(data_spread)


clust_data <- 
  scaled_data %>% 
  column_to_rownames("fips") %>% 
  drop_na()


# Compute Total Distance - we will want to probably limit to last two weeks

total_dist <- dist(clust_data)

dist_df <- 
  as.data.frame(as.matrix(total_dist)) %>% 
  rownames_to_column("fips")


ditto <- function(dist_df, chosen_county, n = 10){
  
  dist_df %>% 
    filter(fips == chosen_county) %>% 
    gather(comp, distance, -fips) %>% 
    filter(comp != chosen_county) %>% 
    arrange(distance) %>% 
    head(n)
  
}

#Load in fips codes from tidycensus for county names, clean, and select two cols
fips_codes <- fips_codes
fips_codes$fips <- paste(fips_codes$state_code, fips_codes$county_code, sep = "")
fips_codes$county <- paste(fips_codes$county, fips_codes$state, sep = ", ")
fips_codes <- fips_codes %>% dplyr::select(county, fips)


#spaghetti plot function

#Take in whatever fips you desire plus the daily case data
plot_cases <- function(selected_fips, case_data) {
  
  hold_ditto <- ditto(dist_df, selected_fips)
  
  ditto_data <- case_data %>% 
    filter(fips %in% c(hold_ditto$comp, selected_fips))
  
  ditto_data <- left_join(ditto_data, fips_codes, by = "fips")
  
  ditto_data <- ditto_data %>% dplyr::mutate(highlight = 
                                               ifelse(fips == selected_fips,  
                                                      unique(ditto_data[ditto_data$fips == selected_fips, ]$county), 
                                                      "Other"))
  
  d <- highlight_key(ditto_data, ~fips)
  
  p <- d %>%
    ggplot(aes(x = week, y = cases, group = county,
               color = highlight, size=highlight)) + #what even is the groups argument anyways then smh
    geom_line() +
    scale_color_manual(values = c("#69b3a2", "lightgrey")) +
    scale_size_manual(values=c(1.5,0.2)) +
    theme_ipsum() +
    theme(
      legend.position = "none",
      plot.title = element_text(size = 14)
    ) +
    ggtitle("New COVID Cases by week of Comparable Counties")
  
  
  gg <- ggplotly(p, tooltip = c("county", "week", "cases"))
  testly <- highlight(gg, on = "plotly_hover", off = "plotly_doubleclick", color = "red")
  
  testly
  
}

plot_cases(selected_fips = "01007", case_data = data_aggregated)
