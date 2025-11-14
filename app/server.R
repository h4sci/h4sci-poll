# # since our alpine image doesn't contain X11 (for R graphics)
# options(device = function(...) grDevices::png(...))

# library(shiny)
# library(DBI)
# library(RPostgres)

# connect_to_db <- function() {
#   dbConnect(
#     RPostgres::Postgres(),
#     host = Sys.getenv("PG_HOST", "postgres"),
#     user = Sys.getenv("PG_USER", "postgres"),
#     password = Sys.getenv("PG_PASSWORD", "postgres"),
#     dbname = Sys.getenv("PG_DB", "testdb"),
#     port = 5432
#   )
# }

# server <- function(input, output, session) {

#   # insert answer when user clicks submit into db
#   observeEvent(input$submit, {
#     con <- connect_to_db()
#     dbExecute(con,
#       "INSERT INTO survey_results (satisfaction) VALUES ($1)",
#       params = list(input$satisfaction)
#     )
#     # disconnect after
#     dbDisconnect(con)

#     # output$thanks <- renderText("Thanks for your answer!")
#   })

#   # plot distribution of all answers
#   output$distPlot <- renderPlot({

#     con <- connect_to_db()
#     df <- dbGetQuery(con, "SELECT satisfaction FROM survey_results")
#     dbDisconnect(con)

#     if (nrow(df) == 0) return(NULL)

#     counts <- table(df$satisfaction)

#     # highlight this user's choice
#     cols <- rep("grey70", length(counts))
#     idx <- which(names(counts) == input$satisfaction)
#     if (length(idx) > 0) cols[idx] <- "steelblue"

#     barplot(
#       counts,
#       main = "Satisfaction Distribution",
#       col = cols,
#       ylab = "Responses",
#       las = 2
#     )
#   })
# }


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

