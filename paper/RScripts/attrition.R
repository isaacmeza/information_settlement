library(readstata13)
library(dplyr)
library(purrr)

get_takeup = function(df, parte){
  contestadas = salida %>% 
    filter(ES_1_1 == parte) %>%
    left_join(df) %>%
    nrow(.)
  
  contestadas/nrow(df)
}

variables = c('Actor', 'Actor', 'Demandado', 'Representante del actor', 'Representante del demandado')
names(variables) = c('salida', 'actor', 'dem', 'rep_actor', 'rep_dem')

surveys = list.files('../DB/', pattern = 'Append *', full.names = T) %>%
          lapply(read.dta13) %>%
          lapply(function(x) distinct(x, folio, .keep_all = T)) %>%
          setNames(., nm = c('salida', 'actor', 'dem', 'rep_actor', 'rep_dem'))


takeup = names(surveys) %>%
          map_dbl(function(x) get_takeup(surveys[[x]], variables[x]))

mean(takeup[2:5])


