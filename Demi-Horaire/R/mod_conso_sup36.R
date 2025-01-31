mod_conso_sup36_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = "Paramètres d'analyse",
        width = 12,
        dateRangeInput(ns("date_range"), "Période", start = Sys.Date() - 30, end = Sys.Date()),
        selectInput(ns("regions"), "Régions", choices = unique(data_conso_sup36$region), multiple = TRUE),
        selectInput(ns("profils"), "Profils règlementaires", 
                    choices = unique(data_conso_sup36$profil_reglementaire), 
                    multiple = TRUE),
        selectInput(ns("plages"), "Plages de puissance", 
                    choices = setdiff(unique(data_conso_sup36$plage_puissance), "Total"), 
                    multiple = TRUE),
        selectInput(ns("secteurs"), "Secteurs d'activité", 
                    choices = unique(data_conso_sup36$secteur_activite), 
                    multiple = TRUE),
        radioButtons(ns("affichage"), "Type d'affichage",
                     choices = c("Courbe totale" = "total", 
                                 "Courbe moyenne" = "moyenne",
                                 "Nombre de points" = "points")),
        checkboxInput(ns("pas_temporel"), "Pas quotidien", value = FALSE),
        actionButton(ns("update"), "Mettre à jour"),
        downloadButton(ns("download_data"), "Télécharger les données")
      )
    ),
    fluidRow(
      box(
        title = "Indicateurs clés",
        width = 12,
        valueBoxOutput(ns("total_energie"), width = 3),
        valueBoxOutput(ns("puissance_moyenne"), width = 3),
        valueBoxOutput(ns("puissance_max"), width = 3),
        valueBoxOutput(ns("date_max"), width = 3)
      )
    ),
    fluidRow(
      box(
        title = "Visualisation des données",
        width = 12,
        plotlyOutput(ns("conso_plot"))
      )
    )
  )
}

mod_conso_sup36_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    data_filtered <- eventReactive(input$update, {
      req(input$regions, input$profils, input$plages, input$secteurs)
      
      # Création de la colonne date en premier
      df <- data_conso_sup36 %>%
        filter(
          region %in% input$regions,
          profil_reglementaire %in% input$profils,
          plage_puissance %in% input$plages,
          secteur_activite %in% input$secteurs,
          horodate >= input$date_range[1],
          horodate <= input$date_range[2]
        ) %>%
        mutate(date = horodate)
      
      # Agrégation principale
      df <- df %>%
        group_by(date, region, secteur_activite) %>%
        summarise(
          total_energie = sum(total_energie_soutiree_wh, na.rm = TRUE),
          puissance_moyenne = mean(puissance_moyenne_w, na.rm = TRUE),
          .groups = 'drop'
        )
      
      # Gestion des options d'affichage
      if(input$affichage == "moyenne") {
        df <- df %>%
          group_by(date, region, secteur_activite) %>%
          summarise(
            valeur = total_energie / n(), 
            .groups = 'drop'
          )
      } else if(input$affichage == "points") {
        df <- df %>%
          group_by(date, region, secteur_activite) %>%
          summarise(
            valeur = n(), 
            .groups = 'drop'
          )
      } else {
        df <- df %>%
          mutate(valeur = total_energie)
      }
      
      return(df)
    })
    
    # Graphique interactif
    output$conso_plot <- renderPlotly({
      df <- data_filtered()
      validate(need(nrow(df) > 0, "Aucune donnée disponible pour les critères sélectionnés"))
      
      x_var <- if(input$pas_temporel) sym("date") else sym("horodate")
      
      p <- ggplot(df, aes(x = !!x_var, y = valeur, 
                          color = interaction(secteur_activite, region))) +
        geom_line() +
        labs(title = "Consommation >= 36 kVA",
             x = "Date",
             y = switch(input$affichage,
                        "total" = "Énergie totale (Wh)",
                        "moyenne" = "Énergie moyenne (Wh)",
                        "points" = "Nombre de points")) +
        theme_minimal()
      
      ggplotly(p) %>% layout(hovermode = "x unified")
    })
    
    # Value boxes
    output$total_energie <- renderValueBox({
      df <- data_filtered()
      total <- sum(df$total_energie, na.rm = TRUE)/1000
      valueBox(formatC(total, big.mark = " "), "Énergie totale (kWh", color = "blue")
    })
    
    output$puissance_moyenne <- renderValueBox({
      df <- data_filtered()
      valeur <- mean(df$puissance_moyenne, na.rm = TRUE)/1000
      valueBox(formatC(valeur, format = "f", digits = 1), "Puissance moyenne (kW)", color = "green")
    })
    
    output$puissance_max <- renderValueBox({
      df <- data_filtered()
      max_row <- df[which.max(df$puissance_moyenne),]
      valeur <- max_row$puissance_moyenne/1000
      valueBox(formatC(valeur, format = "f", digits = 1), "Puissance max (kW)", color = "red")
    })
    
    output$date_max <- renderValueBox({
      df <- data_filtered()
      max_row <- df[which.max(df$puissance_moyenne),]
      date <- if(input$pas_temporel) max_row$date else max_row$horodate
      valueBox(format(date, "%d/%m/%Y %H:%M"), "Date de puissance max", color = "yellow")
    })
    
    # Téléchargement des données
    output$download_data <- downloadHandler(
      filename = function() {
        paste("conso_sup36_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        write.csv(data_filtered(), file, row.names = FALSE)
      }
    )
  })
}