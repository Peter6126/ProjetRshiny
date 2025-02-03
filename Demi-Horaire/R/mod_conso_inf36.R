mod_conso_inf36_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = "Sélection des paramètres",
        width = 12,
        dateRangeInput(ns("date_range"), "Période", start = Sys.Date() - 30, end = Sys.Date()),
        selectInput(ns("region"), "Sélectionner la région", choices = unique(data_conso_inf36$region), multiple = TRUE),
        checkboxInput(ns("moyenne"), "Afficher la moyenne ?", value = TRUE),
        actionButton(ns("update"), "Mettre à jour"),
        downloadButton(ns("download_data"), "Télécharger les données")
      )
    ),
    fluidRow(
      box(
        title = "Résumé des données",
        width = 12,
        valueBoxOutput(ns("total_conso"))
      )
    ),
    fluidRow(
      box(
        title = "Graphique de consommation",
        width = 12,
        plotlyOutput(ns("consommation_plot"))
      )
    )
  )
}

mod_conso_inf36_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Filtrer les données en fonction des inputs
    data_filtered <- reactive({
      req(input$update) 
      data_conso_inf36 %>%
        filter(region %in% input$region, 
               horodate >= input$date_range[1], 
               horodate <= input$date_range[2])
    })
    
    # Graphique de consommation
    output$consommation_plot <- renderPlotly({
      req(data_filtered())
      df <- data_filtered()
      
      #print(head(df))
      
      validate(
        need(nrow(df) > 0, "Aucune donnée disponible pour les paramètres sélectionnés.")
      )
      
      g <- ggplot(df, aes(x = year(horodate), y = total_energie_soutiree_wh_, color = region)) +
        geom_line() +
        theme_minimal() +
        labs(title = "Consommation < 36 kVA", x = "Année", y = "Consommation")
      
      if (input$moyenne) {
        g <- g + geom_smooth(method = "loess", se = FALSE, linetype = "dashed", na.rm = TRUE )
      }
      ggplotly(g)
    })
    
    
    # Calculer la consommation totale
    output$total_conso <- renderValueBox({
      req(data_filtered()) # S'assurer que les données sont disponibles
      total_conso <- sum(data_filtered()$total_energie_soutiree_wh_, na.rm = TRUE)
      
      # Conversion en texte clair
      formatted_value <- format(round(total_conso, 2), big.mark = ",")
      
      valueBox(
        value = paste(formatted_value, "kWh"), 
        subtitle = "Total Consommation (kWh)", 
        icon = icon("chart-line"), 
        color = "blue"
      )
    })
    
    # Télécharger les données filtrées
    output$download_data <- downloadHandler(
      filename = function() {
        paste("data_conso_inf36_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        write.csv(data_filtered(), file, row.names = FALSE)
      }
    )
  })
}
