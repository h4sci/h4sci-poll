ui <- fluidPage(
    titlePanel("Mini Survey"),

    mainPanel(
        selectInput("satisfaction", "How satisfied are you?",
                    choices = c("Very satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very dissatisfied")),
        actionButton("submit", "Submit"),
        hr(),
        textOutput("thanks"),
        # hr(),
        # plotOutput("distPlot")
    )
)