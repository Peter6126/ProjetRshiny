#library

library(assertthat)
library(ggplot2)
library(stringr)
library(tidyr)
library(dplyr)
library(tidyverse)
library(lubridate)
library(stringr)
library(plotly)

####### Fonction permettant de nettoyer les noms des variables #######

#' Nettoyer les noms des colonnes d'un dataframe
#'
#' Cette fonction transforme les noms des colonnes d'un dataframe pour les rendre
#' uniformes et compatibles avec des conventions de nommage simples.
#'
#' @param df Un dataframe dont les colonnes doivent être renommées.
#'
#' @return Un dataframe avec les noms des colonnes nettoyés :
#'   - Les majuscules sont transformées en minuscules.
#'   - Les caractères accentués (comme é, è, ê) sont remplacés par leurs équivalents non accentués.
#'   - Les points (".") sont remplacés par des underscores ("_").
#'
#' @export
#'
#' @examples
#' data <- data.frame("Nom.Var" = 1:5, "Été" = 6:10)
#' clean_data <- clean_col(data)
#' print(clean_data)

clean_col <- function(data) {
  data_clean <- data
  colnames(data_clean) <- colnames(df) %>%
    str_to_lower() %>%
    str_replace_all(pattern = "[éèê]", replacement = "e") %>%
    str_replace_all(pattern = "\\.", replacement = "_") %>%
    str_replace_all(pattern = "_+", replacement = "_")
  return(data_clean)
}

####### Fonction pour charger et nettoyer les données #######

#' Charger et nettoyer les données
#'
#' Cette fonction charge un fichier CSV et nettoie les noms des colonnes à l'aide de `clean_col`.
#'
#' @param file_path Chemin du fichier CSV à charger.
#'
#' @return Un dataframe nettoyé.
#'
#' @export
#'
#' @examples
#' data <- load_and_clean_data("data.csv")
#' print(data)

load_and_clean_data <- function(file_path) {
  data <- read.csv(file_path, header = TRUE, sep = ';')
  clean_data <- clean_col(data)
  return(clean_data)
}