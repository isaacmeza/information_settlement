library(readxl)
library(dplyr)
library(lubridate)

source('toolbox.R')
source('aux_clean_casefiles.R')

data = read_excel('../Raw/pilot_operation.xlsm', skip = 2, sheet = 'BASE SEGUIMIENTO')

data %>%
  rename('uno' = `1`) %>%
 # setNames(., limpia_nombres_feo(names(.))) %>%
  mutate_at(vars(`FECHA SIGUIENTE AUDIENCIA`, starts_with('c1_fecha')), function(x) replace(x, which(x == '0'), NA)) %>% 
  mutate_at(vars(`FECHA SIGUIENTE AUDIENCIA`, starts_with('c1_fecha')), limpia_fechas) %>% 
  mutate_at(vars(`FECHA SIGUIENTE AUDIENCIA`, starts_with('c1_fecha')), function(x) format(x, '%d/%m/%Y')) %>%
  write.csv(., file = '../DB/pilot_operation.csv', na = '')

data = data %>%
  rename('itt' = `1`) %>%
  setNames(., limpia_nombres_bonitos(names(.))) %>%
  saveRDS(., file = '../DB/pilot_operation_clean.RDS')
