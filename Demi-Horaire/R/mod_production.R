mod_production_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = "Paramètres de production",
        width = 12,
        dateRangeInput(ns("date_range"), "Période", start = Sys.Date() - 30, end = Sys.Date()),
        selectInput(ns("regions"), "Régions", choices = unique(data_production$region), multiple = TRUE),
        selectInput(ns("plages_injection"), "Plages de puissance d'injection",
                   choices = setdiff(unique(data_production$plage_puissance_injection), "Total"),
                   multiple = TRUE),
        selectInput(ns("filieres"), "Filières",
                   choices = unique(data_production$filiere),
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
        valueBoxOutput(ns("total_production"), width = 3),
        valueBoxOutput(ns("puissance_moyenne"), width = 3),
        valueBoxOutput(ns("puissance_max"), width = 3),
        valueBoxOutput(ns("date_max"), width = 3)
      )
    ),
    fluidRow(
      box(
        title = "Visualisation de la production",
        width = 12,
        plotlyOutput(ns("production_plot"))
      )
    )
  )
}

mod_production_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    data_filtered <- eventReactive(input$update, {
      req(input$regions, input$plages_injection, input$filieres)
      
      df <- data_production %>%
        filter(
          region %in% input$regions,
          plage_puissance_injection %in% input$plages_injection,
          filiere %in% input$filieres,
          horodate >= input$date_range[1],
          horodate <= input$date_range[2]
        ) %>%
        mutate(date = horodate) %>%
        group_by(across(c("date", "region", "filiere"))) %>%
        summarise(
          total_energie = sum(energie_injectee_wh, na.rm = TRUE),
          puissance_moyenne = mean(puissance_moyenne_w, na.rm = TRUE),
          .groups = 'drop'
        )
      
      if(input$affichage == "moyenne") {
        df <- df %>%
          group_by(date, region, filiere) %>%
          summarise(valeur = total_energie / n(), .groups = 'drop')
      } else if(input$affichage == "points") {
        df <- df %>%
          group_by(date, region, filiere) %>%
          summarise(valeur = n(), .groups = 'drop')
      } else {
        df$valeur <- df$total_energie
      }
      
      return(df)
    })
    
    output$production_plot <- renderPlotly({
      df <- data_filtered()
      validate(need(nrow(df) > 0, "Aucune donnée disponible pour les critères sélectionnés"))
      
      p <- ggplot(df, aes(x = date, y = valeur, 
                         color = interaction(filiere, region))) +
        geom_line() +
        labs(title = "Production d'énergie",
             x = "Date",
             y = switch(input$affichage,
                        "total" = "Énergie totale (Wh)",
                        "moyenne" = "Énergie moyenne (Wh)",
                        "points" = "Nombre de points")) +
        theme_minimal()
      
      ggplotly(p) %>% layout(hovermode = "x unified")
    })
    
    output$total_production <- renderValueBox({
      df <- data_filtered()
      total <- sum(df$total_energie, na.rm = TRUE)/1000
      valueBox(formatC(total, big.mark = " "), "Production totale (kWh)", color = "blue")
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
      valueBox(format(max_row$date, "%d/%m/%Y %H:%M"), "Date de puissance max", color = "yellow")
    })
    
    output$download_data <- downloadHandler(
      filename = function() {
        paste("production_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        write.csv(data_filtered(), file, row.names = FALSE)
      }
    )
  })
}