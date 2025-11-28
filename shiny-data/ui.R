library(shinythemes)

fluidPage(
  theme = shinytheme("cerulean"),
  title = "Hacking for Science - Demo Survey",
  fluidRow(
    column(
      width = 6,
      div(
        class = "jumbotron",
        h1("Hacking for Science"),
        p("Some Introductory paragraph motivating our survey.")
      )
    )
  ),
  uiOutput("basic_questions"),
  uiOutput("submit"),
  uiOutput("thanks")
)
