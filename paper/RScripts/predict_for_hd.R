library(dplyr)
library(tidyr)
library(e1071)
library(randomForest)
library(data.table)

source('aux_functions.R')

df = readRDS('../DB/scaleup_hd_original.RDS')

### Pilot calculator

# Cargamos modelos de piloto 1

dir('../Calculator/pilot/modelos', pattern = '.*.rdata', full.names = T) %>%
setNames(.,   gsub('(../Calculator/pilot/modelos/)(.*)(.rdata)', '\\2', .)) %>%
as.list() %>%
lapply(., load, .GlobalEnv)

# Preparamos los datos

# Rename y recode

df1 = rename(df, antig_anos = c_antiguedad,
                              sueldo_diario_integrado = sueldo,
                              tipo_de_abogado = abogado_pub,
                              trab_base = trabajador_base,
                              reinstalacion_t = reinst,
                              indem_const_t = indem,
                              rec_hr_extra = hextra,
                              rec_20_d_ias_t = rec20,
                              sarimssinfo = sarimssinf,
                              sal_caidos_t = sal_caidos,
                              acci_on_principal = accion_principal,
                              cod_imss = codem) %>%
                              mutate(horas = hack_horas(horas_sem, per_horas),
                              acci_on_principal = ifelse(grepl('INDEM', acci_on_principal), 'Indemnizacion Constitucional',
                                                         ifelse(grepl('REINST', acci_on_principal), 'Reinstalacion',
                                                                ifelse(grepl('RESC', acci_on_principal), 'Rescision', NA))),
                              causa = ifelse(causa == '1', 'Sin previo aviso', 'Otro'))

# Recode giro

dic = read.csv('../Calculator/pilot/clean_data/diccionario_giros.csv', fileEncoding = 'UTF-8-BOM') %>%
      rename(giro_empresa = giro_nuevo) %>%
      select(-contains('X'))


df1 = df1 %>%
      mutate(giro_empresa = as.numeric(as.character(giro_empresa))) %>%
      left_join(dic)  %>%
      mutate(giro_empresa = giro_viejo)


df1$giro_empresa <- factor(as.character(df1$giro_empresa),
                          labels = 1:11,
                          levels = c("Servicios", "Comercial", "Reclutamiento", "Manufactura", "Transporte", 
                                     "Servicios Profesionales", "Otro", "Comunicacion", "Construccion", 
                                     "Instituciones Financieras", "Servicios Publicos"))

df1$acci_on_principal <- factor(as.character(df1$acci_on_principal),
                               labels = c(1:3),
                               levels = c("Reinstalacion", "Indemnizacion Constitucional", "Rescision"))

df1$causa <- factor(as.character(df1$causa), labels = c(0, 1), levels = c("Sin previo aviso", "Otro"))

df1$giro_empresa[df1$giro_empresa %in% c('9', '10')] <- NA
df1$acci_on_principal[df1$acci_on_principal == '3'] <- NA

df1_preds = df1 %>%
      transmute(comp_laudogana_p1 = predice_nuevos(newdata = df1, 
                                                   object = mod_liqtotal_laudo_gana, 
                                                   medias_de = medias_liqtotal_laudo_gana,
                                                   exp = T),
                      prob_laudogana_p1 = predice_nuevos(newdata = df1, 
                                                         object = mod_probas_laudo_gana, 
                                                         medias_de = medias_probas_laudo_gana,
                                                         exp = F, prob = T),
                      prob_laudopierde_p1 = predice_nuevos(newdata = df1, 
                                                           object = mod_probas_laudo_pierde, 
                                                           medias_de = medias_probas_laudo_pierde,
                                                           exp = F, prob = T),
             comp_esp_p1 = comp_laudogana_p1*(prob_laudogana_p1/(prob_laudogana_p1 + prob_laudopierde_p1)))


# Cargamos modelos de scaleup

probability_win = readRDS('../Calculator/scaleup/modelos/probability_win.RDS')
load('../Calculator/scaleup/modelos/utils.RData')

# Preparamos los datos de hd y scaleup casefiles para ScaleUp
# Probability

df2 = df

juntas <- c(2,7,9,11,16)
for(level in unique(juntas)){
  df2[paste("junta", level, sep = "_")] <- ifelse(df2$junta == level, 1, 0)
}

giros <- c(11, 21, 22, 23, 31, 32, 33, 43, 46, 48, 49, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 93)
for(level in unique(giros)){
  df2[paste("giro_empresa", level, sep = "_")] <- ifelse(df2$giro_empresa == level, 1, 0)
}

jornadas <- c(1, 2, 3, 4)
for(level in unique(jornadas)){
  df2[paste("tipo_jornada", level, sep = "_")] <- ifelse(df2$tipo_jornada == level, 1, 0)
}

df2 = df2 %>%
      mutate(c_hextra = aux_factor(c_hextra), 
             prop_hextra = ifelse(c_total !=0, c_hextra/c_total, 0),
             grado_exag = ifelse(min_ley !=0, c_total/min_ley, 8))


df2 <- select(df2, one_of(rownames(probability_win$importance))) %>%
          mutate_if(is.factor, aux_factor) %>%
          mutate_all(as.numeric)

df2 = na.roughfix(df2) 

df2_preds <- predict(probability_win, df2, "prob") %>%
        as.data.frame()

setnames(df2_preds, c('prob_laudopierde_p2', 'prob_laudogana_p2'))


# Compensation

df3 <- mutate_at(df, vars(c_ag, c_vac), function(x) ifelse(x<0, 0, x)) %>%
  mutate(ln_c_antiguedad = log(c_antiguedad + 1),
         ln_c_indem = log(c_indem + 1))


juntas <- c(2, 7, 9, 11, 16)
for(level in unique(juntas)){
  df3[paste("junta", level, sep = "")] <- ifelse(df3$junta == level, 1, 0)
}

df3 = df3 %>%
      mutate(comp_laudogana_p2 = predict.glm(OLS_lau, .),
             comp_convenio_p2 = exp(predict.glm(log_OLS_con, .)) - 1)

# Truncating compensation predictions

topes$junta <- as.character(topes$junta)
df3$junta <- as.character(df3$junta)

df3 <- left_join(df3, topes)

topa_pred <- function(pred, inf, sup){
  ifelse(pred < inf, inf, ifelse(pred > sup, sup, pred))
}

df3_preds <- transmute(df3, comp_laudogana_p2 = topa_pred(comp_laudogana_p2, tope_01_lau, tope_99_lau),
                  comp_convenio_p2 = topa_pred(comp_convenio_p2, tope_01_conv, tope_99_conv))


# Join all predictions

export = bind_cols(df, df1_preds, df2_preds, df3_preds) %>%
          mutate(comp_esp_p2 = comp_laudogana_p2*prob_laudogana_p2)

write.csv(export, '../DB/scaleup_hd.csv', na = '', row.names = F)
saveRDS(export, '../DB/scaleup_hd.RDS')


rm(list = ls())