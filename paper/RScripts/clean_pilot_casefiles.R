library(readxl)
library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)

source('aux_clean_casefiles.R')

######################################################################################################################################
# Raw data for old do-files
######################################################################################################################################

data_raw = read_excel('../Raw/pilot_casefiles.xlsx', skip = 3) %>%
  filter(Clave != 'clave') %>% 
  rename(exp_comp = comp_Esp) %>%
  mutate_at(vars(starts_with('prob')), limpia_probas) %>%
  mutate_at(vars(starts_with('liq')), as.numeric) %>%
  mutate(comp_esp = prob_laudoPos*liq_laudoPos/prob_laudos) %>% 
  mutate_at(vars(starts_with('fecha')), limpia_fechas) %>%
  setNames(., aux_nombres_iniciales(names(.))) 

write.csv(data_raw, file = '../DB/pilot_casefiles.csv', na = '')


######################################################################################################################################
# Clean data for R and new stuff
######################################################################################################################################

data_clean = read_excel('../Raw/pilot_casefiles.xlsx', skip = 4) %>%
              #     mutate(dummy_vac = genera_dummy(fecha_inic_vac, fecha_fin_vac, c_vac),
              #             dummy_ag = genera_dummy(fecha_inic_ag, fecha_fin_ag, c_ag)) %>%x
              mutate_at(vars(contains('fecha')), limpia_fechas) %>%
              mutate(top_despacho_ac = despacho_ac %in% top_despachos) %>%
              mutate_at(vars(contains('dummy')), limpia_dummy) %>%
              setNames(., nm = gsub('dummy_', '', names(.))) %>%
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
                     prob_ganar = prob_laudopos/prob_laudos,
                     comp_esp = prob_ganar*liq_laudopos)
  
######################################################################################################################################
# Codefendant
######################################################################################################################################

dems_imss = select(data_clean, id_actor, starts_with("nombre_d"), -nombre_despido) %>%
  gather(dem, nombre, -id_actor) %>%
  mutate(codem_imss = grepl("IMSS", nombre) | (grepl("INSTITUTO", nombre) &
                                                 (grepl("SEGURO", nombre) | grepl("FONDO", nombre))) |
           grepl("INFONAVIT", nombre)) %>%
  group_by(id_actor) %>%
  summarise(codem = sum(codem_imss)) %>%
  mutate(codem = ifelse(codem>0, 1,0))

data = left_join(data_clean, dems_imss)


saveRDS(data_clean, file = '../DB/pilot_casefiles.RDS')
  

  