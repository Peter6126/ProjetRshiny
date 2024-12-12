# Chargement des bibliothèques nécessaires
library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(plotly)

df <-read.csv('data/conso-inf36-region.csv', header = TRUE)
# Chargement et nettoyage des données
# Exemple des noms des colonnes ajustés à partir de vos données
conso_inf36 <- conso.inf36.region %>%
  rename(
    Date = V1,
    Region = V2,
    Code_region = V3,
    Profil = V4,
    Plage_puissance = V5,
    Nb_points_soutirage = V6,
    Energie_soutiree_Wh = V7,
    Courbe_Moyenne1_Wh = V8,
    Indice_Courbe1 = V9,
    Courbe_Moyenne2_Wh = V10,
    Indice_Courbe2 = V11,
    Courbe_Moyenne1_2_Wh = V12,
    Indice_Courbe1_2 = V13,
    Jour_max_du_mois = V14,
    Semaine_max_du_mois = V15
  ) %>%
  mutate(
    Date = ymd_hms(Date),  # Conversion de la date
    Energie_soutiree_Wh = as.numeric(Energie_soutiree_Wh)  # Assurez-vous que les valeurs sont numériques
  ) %>%
  filter(!is.na(Energie_soutiree_Wh))  # Retirer les lignes avec des NA dans Energie_soutiree_Wh

print(colnames(conso_inf36))
# Interface utilisateur
ui <- dashboardPage(
  dashboardHeader(title = "Analyse Conso < 36kVA"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Conso < 36kVA", tabName = "inf36")
    ),
    radioButtons("display", "Affichage :",
                 choices = c("Courbe totale" = "total", 
                             "Nombre de points" = "points",
                             "Courbe moyenne" = "average")),
    dateRangeInput("date_range", "Période :",
                   start = min(conso_inf36$Date, na.rm = TRUE),
                   end = max(conso_inf36$Date, na.rm = TRUE)),
    selectizeInput("regions", "Régions :",
                   choices = unique(conso_inf36$Region),
                   selected = unique(conso_inf36$Region)[1],  # Région par défaut
                   multiple = TRUE),
    radioButtons("time_step", "Pas de temps :",
                 choices = c("Demi-horaire" = "30min", "Quotidien" = "day"))
  ),
  dashboardBody(
    tabItem(tabName = "inf36",
            plotlyOutput("plot_inf36"),
            fluidRow(
              valueBoxOutput("total_box_inf36"),
              valueBoxOutput("avg_box_inf36"),
              valueBoxOutput("max_box_inf36")
            ),
            downloadButton("download_inf36", "Télécharger les données")
    )
  )
)

# Serveur
server <- function(input, output, session) {
  # Filtrer les données selon les choix utilisateur
  filtered_data <- reactive({
    req(input$regions, input$date_range)
    validate(
      need(input$regions, "Veuillez sélectionner au moins une région."),
      need(input$date_range[1] <= input$date_range[2], "La plage de dates est invalide.")
    )
    conso_inf36 %>%
      filter(
        Region %in% input$regions,
        Date >= input$date_range[1],
        Date <= input$date_range[2]
      ) %>%
      group_by(
        Date = if (input$time_step == "day") as.Date(Date) else Date,
        Region
      ) %>%
      summarise(
        Valeur = if (input$display == "average") {
          mean(Energie_soutiree_Wh, na.rm = TRUE)
        } else {
          sum(Energie_soutiree_Wh, na.rm = TRUE)
        },
        .groups = "drop"
      )
  })
  
  # Créer un graphique
  output$plot_inf36 <- renderPlotly({
    data <- filtered_data()
    req(nrow(data) > 0)
    p <- ggplot(data, aes(x = Date, y = Valeur, color = Region)) +
      theme_minimal() +
      labs(title = "Consommation < 36kVA par région", x = "Date", y = "Valeur")
    if (input$display %in% c("total", "average")) {
      p <- p + geom_line()
    }
    if (input$display %in% c("points", "total")) {
      p <- p + geom_point()
    }
    ggplotly(p)
  })
  
  # Créer des Value Boxes
  output$total_box_inf36 <- renderValueBox({
    total <- sum(filtered_data()$Valeur, na.rm = TRUE)
    valueBox(paste(round(total, 2), "kWh"), "Total", color = "blue")
  })
  
  output$avg_box_inf36 <- renderValueBox({
    avg <- mean(filtered_data()$Valeur, na.rm = TRUE)
    valueBox(paste(round(avg, 2), "kW"), "Moyenne", color = "green")
  })
  
  output$max_box_inf36 <- renderValueBox({
    data <- filtered_data()
    max_val <- max(data$Valeur, na.rm = TRUE)
    max_date <- data$Date[which.max(data$Valeur)]
    valueBox(paste(round(max_val, 2), "kW"), "Maximum", color = "red")
  })
  
  # Télécharger les données filtrées
  output$download_inf36 <- downloadHandler(
    filename = function() {
      paste("conso_inf36_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# Lancer l'application Shiny
shinyApp(ui = ui, server = server)




 

