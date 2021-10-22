library(dplyr)
library(tidyr)
library(e1071)
library(randomForest)
library(data.table)

source('aux_functions.R')

# Cargamos modelos de scaleup

probability_win = readRDS('../Calculator/scaleup/modelos/probability_win.RDS')
load('../Calculator/scaleup/modelos/utils.RData')

# Preparamos los datos 
# Probability

df2 = readRDS('../../ScaleUp/DB/scaleup_casefiles.RDS')

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


df2_s <- select(df2, one_of(rownames(probability_win$importance))) %>%
  mutate_if(is.factor, aux_factor) %>%
  mutate_all(as.numeric)

df2_s = na.roughfix(df2_s) 

prob = predict(probability_win, df2_s, "prob") %>%
       as.data.frame()

setnames(prob, c('X0', 'X1'))


# Compensation

df3 <- mutate_at(df2, vars(c_ag, c_vac), function(x) ifelse(x<0, 0, x)) %>%
        mutate(ln_c_antiguedad = log(c_antiguedad + 1),
        ln_c_indem = log(c_indem + 1))

juntas <- c(2, 7, 9, 11, 16)
for(level in unique(juntas)){
  df3[paste("junta", level, sep = "")] <- ifelse(df3$junta == level, 1, 0)
}

df3 = df3 %>%
  mutate_at(vars(codem, gen, reinst), as.factor) %>%
  mutate(comp_laudogana_p2 = predict.glm(OLS_lau, .),
         comp_convenio_p2 = exp(predict.glm(log_OLS_con, .)))

# Truncating compensation predictions

topes$junta <- as.character(topes$junta)
df3$junta <- as.character(df3$junta)

df3 <- left_join(df3, topes)

topa_pred <- function(pred, inf, sup){
  ifelse(pred < inf, inf, ifelse(pred > sup, sup, pred))
}

df3 <- transmute(df3, liq_total_laudo = topa_pred(comp_laudogana_p2, tope_01_lau, tope_99_lau),
                 liq_total_convenio = topa_pred(comp_convenio_p2, tope_01_conv, tope_99_conv))



# Join all predictions

export_sc = bind_cols(df2, prob,  df3) %>%
    mutate(liq_total_laudo_avg = liq_total_laudo*X1) %>%
    select(id_exp, junta, exp, anio, X0, X1, liq_total_laudo, liq_total_convenio, liq_total_laudo_avg)

write.csv(export_sc, '../DB/scaleup_predictions.csv', na = '', row.names = F)
saveRDS(export_sc, '../DB/scaleup_predictions.RDS')

rm(list = ls())