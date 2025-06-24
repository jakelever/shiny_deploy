library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Simple Histogram Example"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 5,
                  max = 50,
                  value = 20)
    ),
    
    mainPanel(
      plotOutput("distPlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$distPlot <- renderPlot({
    x <- rnorm(500)
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    hist(x, breaks = bins, col = 'steelblue', border = 'white')
  })
}

# Run the app
shinyApp(ui = ui, server = server)
