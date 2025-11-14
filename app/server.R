library(shiny)
library(DBI)
library(RPostgres)

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


server <- function(input, output, session) {

  output$result <- renderPrint({
    con <- connect_to_db()
    on.exit(dbDisconnect(con))

    dbGetQuery(con, "SELECT NOW() AS server_time;")
  })
}


