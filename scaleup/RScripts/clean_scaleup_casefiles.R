library(dplyr)
library(lubridate)
library(tidyr)
library(readxl)

source('toolbox.R')
source('utils.R')
load('utils.RData')


######################################################################################################################################
# Read data
######################################################################################################################################

df = read_excel('../Raw/scaleup_casefiles.xlsm', skip = 3) %>%
      rename(fecha_captura = fceha_captura) %>%
      select(clave:dummy_nulidad) %>%
#     mutate(dummy_vac = genera_dummy(fecha_inic_vac, fecha_fin_vac, c_vac),
#             dummy_ag = genera_dummy(fecha_inic_ag, fecha_fin_ag, c_ag)) %>%
      mutate_at(vars(contains('fecha')), limpia_fechas)


######################################################################################################################################
# Codefendant
######################################################################################################################################
dems_imss = select(df, id_actor, starts_with("nombre_d"), -nombre_despido) %>%
  gather(dem, nombre, -id_actor) %>%
  mutate(codem_imss = grepl("IMSS", nombre) | (grepl("INSTITUTO", nombre) &
                                                    (grepl("SEGURO", nombre) | grepl("FONDO", nombre))) |
           grepl("INFONAVIT", nombre)) %>%
  group_by(id_actor) %>%
  summarise(codem = sum(codem_imss)) %>%
  mutate(dummy_codem = ifelse(codem>0, 1,0)) %>%
  select(-codem)

df = left_join(df, dems_imss)


######################################################################################################################################
# Top sue
######################################################################################################################################

df$top_despacho_ac = df$despacho_ac %in% top_despachos

######################################################################################################################################
## Clean dummy and numeric (monetary, periodic) variables, filter out cases we don't need
######################################################################################################################################

df = mutate_at(df, vars(contains('dummy')), limpia_dummy) %>%
      setNames(., nm = gsub('dummy_', '', names(df))) %>%
      mutate(antig = fecha_salida - fecha_entrada) %>%
      mutate_at(vars(contains('monto'), 
                     contains('sueldo'), 
                     contains('horas'),
                     antig, trabajador_base), limpia_montos) %>%
      filter(grepl('REINST', accion_principal) | 
               grepl('INDEM', accion_principal) |
               grepl('RESC', accion_principal)) %>%
      mutate_at(vars(starts_with('per')), limpia_categorica, validos = 0:3) %>%
      mutate(anio_nac = as.numeric(anio_nac),
             edad = anio - anio_nac,
             tipo_jornada = limpia_categorica(tipo_jornada, 1:4),
             antig = antig/365,
             abogado_pub = ifelse(tipo_abogado_ac == '3', 1, 0)) 


## Write data
write.csv(df, '../DB/scaleup_casefiles.csv', na = '', row.names = F)
saveRDS(df, '../DB/scaleup_casefiles.RDS')
