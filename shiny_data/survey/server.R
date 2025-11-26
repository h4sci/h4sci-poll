library(shiny)
library(shinyjs)
library(DBI)
library(RPostgres)

shinyServer(function(input, output, session) {
  # it should be sufficient to store the session token.
  # cookies auth is a more sophisticated alternative, but
  # let's not dive into js to deep for now.
  # session$token

  store_record <- function(response) {
    con <- dbConnect(
      drv = Postgres(),
      user = "postgres",
      host = "db_container",
      dbname = "postgres",
      password = "postgres",
      port = 5432
    )
    dbExecute(con, "SET SEARCH_PATH=rseed")
    dbAppendTable(con, dbQuoteIdentifier(con, "h4sci_demo"), response)
    dbDisconnect(con)
  }


  submitted <- reactiveVal(FALSE)

  output$basic_questions <- renderUI(
      if (!submitted()) {
        fluidRow(
          column(
            width = 6,
            div(
              class = "panel panel-primary",
              div(
                class = "panel-heading",
                h3("Basic Questions")
              ),
              div(
                class = "panel-body",
                "Please indicate your familiarity with the following demo topic.
                1 = never heard of it, 2 = trying out status, 3 = used it in courses or projects,
                4 = use this language regularly, very experienced,
                5 = expert: write my own extensions, packages, etc.",
                sliderInput("demo_slider", "Demo Slider", min = 1, max = 5, value = 3),
              )
            )
          )
        )
      }
    )

  output$free_text <- renderUI(
      if (!submitted()) {
        fluidRow(
          column(
            width = 6,
            div(
              class = "panel panel-primary",
              div(
                class = "panel-heading",
                h3("Additional Expectations")
              ),
              div(
                class = "panel-body",
                "Do you have any additional unaddressed expectations or comments you would like to submit?",
                textAreaInput(
                  "free_text",
                  "",
                  "", rows=20, cols=150
                )
              )
            )
          )
        )
      }
    )



  response <- reactive({
    dt <- data.frame(
      id = session$token,
      free_text = paste(input$free_text, collapse = ","),
      demo_slider = input$demo_slider,
      survey_year = 2025,
      stringsAsFactors = FALSE
    )
  })


  output$submit <- renderUI(
    if (!submitted()) {
      fluidRow(
        column(
          width = 6,
          div(
            class = "panel panel-primary",
            div(
              class = "panel-heading",
              h3("Submit Your Answers!")
            ),
            div(
              class = "panel-body", align = "right",
              actionButton("submit", "submit")
            )
          )
        )
      )
    }
  )


  observeEvent(input$submit, {
    store_record(response())
    submitted(TRUE)
    # has_participated(TRUE)
    # js$setcookie("HAS_PARTICIPATED_IN_SPOSM_INTRO_SURVEY")
  })

  output$thanks <- renderUI(
    if (submitted()) {
      fluidRow(
        column(
          width = 6,
          div(
            class = "panel panel-info",
            div(
              class = "panel-heading",
              h3("Thank You")
            ),
            div(
              class = "panel-body", align = "right",
              "Thank you for your participation. Please only take part once.",
              conditionalPanel(
                condition = "input.raffle == 'Yes'",
                sprintf("Here is your session token: %s. We will reveal the first 8 characters of the winner token in class. Please contact us if your token matches.", session$token)
              )
            ),

          )
        )
      )
    }
  )
})