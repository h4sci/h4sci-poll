library(shiny)
library(DBI)
library(RPostgres)

server <- function(input, output, session) {

    # Connect to SQLite DB (auto-creates file if missing)
    db <- dbConnect(SQLite(), "survey.sqlite")

    # Create table if not exists
    dbExecute(db, "
        CREATE TABLE IF NOT EXISTS responses (
            timestamp TEXT,
            name TEXT,
            satisfaction TEXT
        )
    ")

    observeEvent(input$submit, {

        # Insert data
        dbExecute(db,
            "INSERT INTO responses (timestamp, name, satisfaction) VALUES (?, ?, ?)",
            params = list(Sys.time(), input$name, input$satisfaction)
        )

        output$thanks <- renderText("Thanks for your response!")
    })

    # Close connection when session ends
    session$onSessionEnded(function() {
        dbDisconnect(db)
    })
}

connect_to_db <- function() {
  dbConnect(
    RPostgres::Postgres(),
    host = Sys.getenv("PG_HOST", "postgres"),
    user = Sys.getenv("PG_USER", "postgres"),
    password = Sys.getenv("PG_PASSWORD", "postgres"),
    dbname = Sys.getenv("PG_DB", "testdb"),
    port = 5432
  )
}

# ui <- fluidPage(
#   h2("Minimal R Shiny + Postgres Example"),
#   verbatimTextOutput("result")
# )

server <- function(input, output, session) {

  output$result <- renderPrint({
    con <- connect_to_db()
    on.exit(dbDisconnect(con))

    dbGetQuery(con, "SELECT NOW() AS server_time;")
  })
}

# shinyApp(ui, server)

