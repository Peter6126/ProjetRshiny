# Analyse des consommations et productions régionales au pas demi-horaire

## Description du projet

Ce projet implémente une application **Shiny** permettant d'analyser et de visualiser les consommations et productions d'énergie par région en France, à différentes granularités (demi-horaire ou quotidienne). Les données proviennent du portail **Enedis** et sont analysées à travers plusieurs critères tels que les régions, les profils règlementaires, les plages de puissance, etc.

### Objectif

L'application permet à l'utilisateur de sélectionner et d'afficher les données suivantes :

- Consommation < 36 kVA
- Consommation ≥ 36 kVA
- Production d'énergie par filière

Les données sont visualisées sous forme de graphiques interactifs et sont accompagnées de statistiques détaillées sur la consommation ou la production. L'utilisateur peut également télécharger les données filtrées.

## Données utilisées

Les données sont récupérées depuis le portail **Enedis** :

1. **Production par région** :  
   [Jeu de données de production régionale](https://data.enedis.fr/explore/dataset/prod-region/information/)

2. **Consommation pour les clients ≥ 36 kVA** :  
   [Jeu de données de consommation pour les clients ≥ 36 kVA](https://data.enedis.fr/explore/dataset/conso-sup36-region/information/)

3. **Consommation pour les clients < 36 kVA** :  
   [Jeu de données de consommation pour les clients < 36 kVA](https://data.enedis.fr/explore/dataset/conso-inf36-region/information/)

## Prérequis

Avant de pouvoir utiliser l'application, vous devez disposer des outils suivants :

### 1. Installation de R et RStudio
- **R** : Téléchargez **R** depuis [CRAN](https://cran.r-project.org/).
- **RStudio** : Téléchargez l'IDE **RStudio** depuis [RStudio](https://www.rstudio.com/products/rstudio/download/).

### 2. Installer les dépendances

L'application nécessite plusieurs packages R pour fonctionner correctement. Les principaux packages nécessaires sont :

- **shiny** : pour créer l'application web interactive
- **dplyr** : pour manipuler les données
- **ggplot2** : pour la visualisation des données
- **lubridate** : pour gérer les dates et heures
- **shinydashboard** : pour créer des interfaces utilisateur de type dashboard
- **DT** : pour afficher des tableaux interactifs
- **readr** : pour lire les fichiers CSV

### 3. Jeux de données

Téléchargez les jeux de données nécessaires depuis les liens ci-dessous et placez-les dans le dossier approprié de votre projet :

- **Production par région** : [Jeu de données de production régionale](https://data.enedis.fr/explore/dataset/prod-region/information/)
- **Consommation pour les clients ≥ 36 kVA** : [Jeu de données de consommation pour les clients ≥ 36 kVA](https://data.enedis.fr/explore/dataset/conso-sup36-region/information/)
- **Consommation pour les clients < 36 kVA** : [Jeu de données de consommation pour les clients < 36 kVA](https://data.enedis.fr/explore/dataset/conso-inf36-region/information/)

### 4. Lancer l'application

Une fois les packages installés et les données téléchargées, vous pouvez lancer l'application en suivant ces étapes :

1. **Cloner ou télécharger le projet** depuis GitHub.
2. **Ouvrir le projet dans RStudio** en chargeant le fichier principal du projet (souvent `app.R`).
3. **Exécuter l'application** en utilisant la fonction `shiny::runApp()` dans RStudio.

## Fonctionnalités

L'application permet de configurer plusieurs paramètres via l'interface utilisateur, permettant de visualiser les données de manière flexible.

### Inputs

1. **Choisir le type de données à afficher** :  
   L'utilisateur peut choisir de visualiser la consommation pour les clients < 36 kVA, la consommation pour les clients ≥ 36 kVA ou la production d'énergie.

2. **Sélectionner la période d'analyse** :  
   L'utilisateur peut choisir la période d'analyse via une interface de calendrier, avec la possibilité de définir une plage de dates.

3. **Sélectionner une ou plusieurs régions** :  
   Il est possible de visualiser les données pour une ou plusieurs régions spécifiques, et de les additionner si nécessaire.

4. **Sélectionner un ou plusieurs profils règlementaires** :  
   L'utilisateur peut choisir un ou plusieurs profils règlementaires pour afficher les données cumulées.

5. **Plages de puissance** :  
   L'utilisateur peut filtrer les données en fonction de plages de puissance, comme 0-36 kVA, 36-72 kVA, etc.

6. **Pas de temps** :  
   L'utilisateur peut choisir entre une granularité demi-horaire ou quotidienne pour l'affichage des données.

7. **Secteurs d'activité** (pour les consommations ≥ 36 kVA) :  
   Permet de filtrer les données en fonction des secteurs d'activité.

8. **Filières de production** (pour la production) :  
   L'utilisateur peut choisir parmi différentes filières (éolien, solaire, etc.).

### Outputs

L'application génère plusieurs sorties :

1. **Graphique interactif** :  
   Un graphique affichant la consommation ou la production en fonction des critères sélectionnés.

2. **Value Boxes** :  
   Des boîtes d'information indiquant la somme des consommations ou productions pour la période sélectionnée, la puissance moyenne et maximale, ainsi que l'heure ou le jour où la puissance maximale a été atteinte.

3. **Téléchargement des données** :  
   Un bouton permet à l'utilisateur de télécharger les données filtrées selon les critères définis.

---

## Contact

- **Développeur** : Kuassi Pierre DOVODJI - Nasser OLLEIK - Kouassi Julien ATTA
  **Email** : [dovodjipierre@gmail.com](mailto:dovodjipierre@gmail.com)

