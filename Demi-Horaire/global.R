setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

source("R/fonction.R")

data_production <- load_and_clean_data('data/prod-region.csv')
data_production$horodate <- as.Date(data_production$horodate, format = '%Y-%m-%d')


data_conso_inf36 <- load_and_clean_data('data/conso-inf36-region.csv')
data_conso_inf36$horodate <- as.Date(data_conso_inf36$horodate, format = '%Y-%m-%d')

data_conso_sup36 <- load_and_clean_data('data/conso-sup36-region.csv')
data_conso_sup36$horodate <- as.Date(data_conso_sup36$horodate, format = '%Y-%m-%d')