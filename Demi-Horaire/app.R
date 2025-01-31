library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(lubridate)

# Charger les modules
source("R/mod_conso_inf36.R")
source("R/mod_conso_sup36.R")
source("R/mod_production.R")
source("global.R")

# Fichier principal de l'application
ui <- dashboardPage(
  dashboardHeader(title = "Analyse des Consommations et Productions Régionales"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Consommation < 36 kVA", tabName = "conso_inf36"),
      menuItem("Consommation >= 36 kVA", tabName = "conso_sup36"),
      menuItem("Production", tabName = "production")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "conso_inf36", mod_conso_inf36_ui("conso_inf36")),
      tabItem(tabName = "conso_sup36", mod_conso_sup36_ui("conso_sup36")),
      tabItem(tabName = "production", mod_production_ui("production"))
    )
  )
)

server <- function(input, output, session) {
  mod_conso_inf36_server("conso_inf36")
  mod_conso_sup36_server("conso_sup36")
  mod_production_server("production")
}

shinyApp(ui, server)
