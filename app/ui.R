ui <- fluidPage(
    titlePanel("Mini Survey"),

    mainPanel(
        selectInput("satisfaction", "How satisfied are you?",
                    choices = c("Very satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very dissatisfied")),
        actionButton("submit", "Submit"),
        hr(),
        textOutput("thanks")
    )
) 
# TODO: second page, where you see the distribution of satisfaction (bar charg or histogram)