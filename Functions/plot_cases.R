plot_cases <- function(case_data,selected_fips,comparison_fips) {
  
  plot_data_selected_fips <- case_data %>% 
    filter(fips == selected_fips) %>% 
    mutate(label = glue::glue("<b>County:</b> {full_county_name}<br>",
                              "<b>Week:</b> {week}<br>",
                              "<b>Cases:</b> {scales::comma(cases,1)}"))
  
  plot_data_comparison_fips <- case_data %>% 
    filter(fips %in% comparison_fips) %>% 
    mutate(label = glue::glue("<b>County:</b> {full_county_name}<br>",
                              "<b>Week:</b> {week}<br>",
                              "<b>New Cases:</b> {scales::comma(cases,1)}"),
           highlight = full_county_name)
  
  d <- highlight_key(plot_data_comparison_fips, ~fips)
  
  p <- ggplot() +
    geom_line(data = d,aes(x = week, y = cases, group = fips,text = label),color = "grey",size = 0.5,alpha = .5) +
    geom_line(data = plot_data_selected_fips,aes(x = week, y = cases, group = fips,text = label),color = CR_red(),size = 1) +
    theme_minimal() +
    scale_y_continuous(labels = scales::comma_format(1)) +
    theme(
      legend.position = "none",
      axis.title = element_blank()
    )
  
  
  gg <- ggplotly(p,tooltip = "text") %>% 
    config(displayModeBar = F)
  gg <- highlight(gg, on = "plotly_hover", off = "plotly_doubleclick", color = cb_gray(),opacityDim = getOption("opacityDim", 0.5))
  
  gg
  
}