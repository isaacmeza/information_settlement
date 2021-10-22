library(readxl)
library(dplyr)
library(lubridate)

replace_na = function(x){
  x[is.na(x)] = 0
  x
}

df = read_excel('../Raw/placebo_operation.xlsm') %>%
      filter(row_number() > 3) %>%
      mutate_at(vars(expediente:cantidad_desistimiento), as.numeric) %>%
      mutate(fecha_lista = as.Date(as.numeric(fecha_lista), origin = '1899-12-30'),
             horario_audiencia = format(as.POSIXct(Sys.Date() + as.numeric(horario_audiencia)), '%H:%M', tz = 'UTC')) %>%
      mutate_at(vars(entrega_actor:entrega_rd), replace_na) %>%
      mutate(count_placebo = rowSums(.[8:11]),
             placebo = as.numeric(count_placebo > 0),
             count_partes = rowSums(.[12:15]),
             partes = as.numeric(count_partes > 0))

df %>%
  mutate(fecha_lista = format(fecha_lista, '%d-%m-%Y')) %>%
  write.csv(., '../DB/placebo_operation.csv')
      
      
saveRDS(df, '../DB/placebo_operation.RDS')
