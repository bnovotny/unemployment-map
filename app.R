# App to return an animated choropleth map of unemployment rate in US counties by year

library(shiny)
source("helpers.R")
ordered_counties <- readRDS("data/ordered_counties.rds")
unemployment_rate <- readRDS("data/unemployment_rate.rds")
library(maps)
library(mapproj)
library(dplyr)

# User interface ----
ui <- fluidPage(
  titlePanel("Unemployment Map"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create choropleth maps displaying unemployment
               data for US Counties by year."),
      
      tags$style(
        ".irs-bar {",
        "  border-color: transparent;",
        "  background-color: transparent;",
        "}",
        ".irs-bar-edge {",
        "  border-color: transparent;",
        "  background-color: transparent;",
        "}"
      ),
      
      # Animated slider to iterate through years
      sliderInput("var", 
                  label = "Choose year to display",
                  min = 1990, max  = 2017,
                  value = 1990, sep = "",
                  ticks = FALSE, animate = animationOptions(interval = 400, loop = TRUE)
                  ),
      
      sliderInput("range", 
                  label = "% unemployment range of interest:",
                  min = 0, max = 40, value = c(0, 50))
    ),
    
    mainPanel(plotOutput("map"))
  )
)

server <- function(input, output) {
  
  # Extract data for the corresponding year
  data_input <- reactive({
    
    unemployment_rate_selected <- unemployment_rate[unemployment_rate$Year == input$var,]
    selected <- left_join(ordered_counties, unemployment_rate_selected, "FIPS")
    selected$Unemp.Rate
    
  })
  
  output$map <- renderPlot({
    
    legend <- paste("% Unemployment", input$year)
    
    percent_map(data_input(), "red", legend, input$range[1], input$range[2], 
                main_title = paste("Percent Unemployment by County, ", input$var))
    
  })
}


# Run app ----
shinyApp(ui, server)