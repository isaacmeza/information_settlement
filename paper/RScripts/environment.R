instalar <- function(paquete) {
  if (!require(paquete,character.only = TRUE, 
               quietly = TRUE, 
               warn.conflicts = FALSE)) {
    install.packages(as.character(paquete), 
                     dependencies = TRUE, 
                     repos = "http://cran.us.r-project.org")
    library(paquete, 
            character.only = TRUE, 
            quietly = TRUE, 
            warn.conflicts = FALSE)
  }
}


paquetes = c('dplyr', 
             'tidyr', 
             'e1071', 
             'randomForest', 
             'data.table', 
             'unbalanced', 
             'lubridate', 
             'stringr', 
             'stringdist', 
             'kimisc', 
             'readr', 
             'stargazer',
             'neuralnet',
             'caTools',
             'mboost',
             'purrr')


lapply(paquetes, instalar)
rm(paquetes, instalar)