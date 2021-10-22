# Librerías

library(dplyr)
library(validate)
library(feather)
library(readr)
library(lubridate)
library(readxl)
library(stringr)

# Funciones auxiliares

arregla_na <- function(x){
  x[is.na(x)] <- 0
  x
}

arregla_rango <- function(x, range){
  x[!(x %in% range)] <- NA
  x
}

# arregla_fecha_lista <- function(fecha){
#   fecha %>%
#     as.character() %>%
#     substr(3, nchar(.)) %>%
#     as.Date(., format = '%d-%m-%y')
# }

arregla_cantidad <- function(x){
  x %>%
    gsub('[^0-9]', '', .) %>%
    as.numeric()/100
}

trunca <- function(x, cuantil_bajo = 0, cuantil_alto = 1){
  lim_sup <- quantile(x, cuantil_alto, na.rm = T, type = 1)
  x [x > lim_sup] <- NA
  
  lim_inf <- quantile(x, cuantil_bajo, na.rm = T, type = 1)
  x [x < lim_inf] <- NA
  x
}

topa <- function(pred, inf, sup){
 ifelse(pred < inf, inf, ifelse(pred > sup, sup, pred))
}

factor2num <- function(x){
  if(!is.numeric(x)){
   x <- as.numeric(as.character(x))
  }
  x
}

prueba <- function(x){
  sum(is.na(factor2num(x)) != is.na(x))
}

# Leemos los datos, quitamos los reglones fuera del experimento

df_seg <- read.csv('../Raw/seguimiento_audiencias.csv') %>% 
          filter(emplazamiento != 0)

# df_seg_val <- read.csv('../data/seguimiento_audiencias_val.csv') %>% 
#   filter(emplazamiento != 0)
# 
# # df_seg %>% select(ea1_prob_pago:erd5_cantidad_pago_s) %>% sapply(prueba)
# 
# df_seg_val$erd3_litigios[df_seg_val$erd3_litigios == 'NA'] <- NA
# 
# # Lo guardamos en un feather para validaciones en Python
# write_feather(df_seg_val, '../data/seguimiento_audiencias_val.feather')

# Creamos dummies de conciliadores

nombres_conciliadores <- c('MARIBEL', 'ISAAC', 
                           'ANA', 'MARINA', 
                           'AGUSTIN', 'MARGARITA', 
                           'HIGUERA', 'CORRAL',
                           'DEYANIRA', 'DOCTOR',
                           'CESAR', 'LUPITA',
                           'KARINA')

for(name in nombres_conciliadores){
  df_seg[paste("conciliador", tolower(name), sep = "_")] <- ifelse(grepl(name, 
                                                                         df_seg$conciliadores), 1, 0)
}

# Creamos número de conciliadores presentes en cierto horario

df_seg %>%
  dplyr::select(starts_with('conciliador_')) %>% 
  rowSums() -> conciliadores_presentes

df_seg$num_conciliadores <- conciliadores_presentes

df_seg %>%
  group_by(fecha_lista, horario_aud) %>%
  dplyr::summarise(busyness = sum(emplazamiento == 1 | emplazamiento == 2, na.rm = T)) %>% 
  right_join(df_seg) -> df_seg

# Creamos dummies de juntas

juntas <- c('2', '7', '9', '11', '16')

for(jun in juntas){
  df_seg[paste("junta", jun, sep = "_")] <- ifelse(df_seg$junta == jun, 1, 0)
}

# Arreglamos la fecha de lista
# Luego, le inputamos cero a los NA para:
# 1. Contadores de partes que se presentan (p_* y registro_actor), 
# 2. Todas las dummies de tratamiento (desde registro_actor hasta aviso_conciliador)

df_seg <- df_seg %>%
            mutate(fecha_lista = dmy(as.character(fecha_lista)),
                   notificado = as.numeric(emplazamiento == 1)) %>%
                    mutate_at(vars(starts_with('p_'), 
                           registro_actor:aviso_conciliador, 
                           convenio, desistimiento), arregla_na)
 
 # Después, nos aseguramos que todas las variables categóricas estén en rango
 df_seg <- df_seg %>%
            mutate(emplazamiento = arregla_rango(emplazamiento, 
                                        range = 1:3)) %>%
            mutate_at(vars(registro_actor:aviso_conciliador, 
                           convenio, desistimiento,
                           ea4_compra, ea6_trabaja, 
                           ea7_busca_trabajo), 
                            arregla_rango, 
                            range = 0:1) %>%
            mutate_at(vars(ea3_enojo, 
                           ea5_estudios, 
                           ed3_estabilidad,
                           ed4_enojo, 
                           era3_litigios,
                           erd3_litigios),
                          arregla_rango,
                            range = 1:4)

# Quitamos caracteres especiales de todas las cantidades, las truncamos a 99% y volvemos 0 a los NA.
# Luego, truncamos probabilidades de parte actora a min 10%
 
 df_seg <- df_seg %>%
            mutate_at(vars(contains('cantidad')), arregla_cantidad)  %>%
            mutate_at(vars(ea1_prob_pago:erd5_cantidad_pago_s), factor2num) %>%
            mutate(update_prob_a = (ea8_prob_pago_s - ea1_prob_pago)/ea1_prob_pago,
                   update_prob_ra = (era4_prob_pago_s - era1_prob_pago)/era1_prob_pago,
                   update_prob_rd = (erd4_prob_pago_s - erd1_prob_pago)/erd1_prob_pago,
                   update_pago_a = (ea9_cantidad_pago_s - ea2_cantidad_pago)/ea2_cantidad_pago,
                   update_pago_ra = (era5_cantidad_pago_s - era2_cantidad_pago)/era2_cantidad_pago,
                   update_pago_rd = (erd5_cantidad_pago_s - erd2_cantidad_pago)/erd2_cantidad_pago) 
 
 
 df_seg <- df_seg %>%
            ungroup() %>%
            mutate_at(vars(contains('cantidad')), trunca, cuantil_alto = .99) %>%
            mutate_at(vars(ea1_prob_pago, ea8_prob_pago_s), topa, inf = 10, sup = 100)
 
# PENDIENTE: Validaciones Dianita
# PENDIENTE: dummies de quién se presentó en lugar de contadores
# PENDIENTE (no hay casos) Reemplazamos "NA" con NA para convenio 
# Variables fuera de rango
# - Alerta: se concilió = 1 y cantidad vacía
 
quita_nas <- function(x){
  x[is.na(x)] <- 0
  x
} 

cal <- read_excel('../Raw/calendario_no_encuestados.xlsx', skip = 1) %>% 
  gather(key = digito, value = no_encuestado, -Fecha) %>%
  dplyr::rename(fecha_lista = Fecha) %>%
  mutate(no_encuestado = quita_nas(no_encuestado))

df_seg <- df_seg %>%
  mutate(digito = str_sub(expediente, start = -1),
         fecha_lista = as.POSIXct(fecha_lista)) %>%
  left_join(cal)

# Guardamos los datos:
write.csv(df_seg, '../DB/seguimiento_audiencias_mc.csv', na = '')
saveRDS(df_seg, '../DB/seguimiento_audiencias.RDS')
