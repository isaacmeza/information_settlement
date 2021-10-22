#setwd("/home/animalito/study/juicios/lib")
library(readxl)
library(rformat)
library(dplyr)

source("../lib/clean_up.R")

## Hack: skip == 2
datos <- lee(data.dir = "../data/BASE INICIALES JLCADF J7 SEGUNDO ACUMULADO.xlsx", recomendaciones.dir = "../data/BASE INICIALES JLCADF J7 PRIMER ACUMULADO.xlsx", skip = 2)

#### Fix a horas. Las horas no son necesariamente semanales. Hay diferentes unidades
unique(datos$data$pd_horas)

un.caso <- function(pd.horas, horas){
ifelse(pd.horas == 0, 6 * horas, 
       ifelse(pd.horas == 1, 0.25 * horas, 
              ifelse(pd.horas == 2, 0.5 * horas,
                     ifelse(pd.horas == 3, horas, NA))))
}

## Hack: mutar a numéricas
datos$data <- datos$data %>% 
             mutate_at(vars(ends_with('horas')), as.numeric)

check <- sapply(seq(nrow(datos$data)), FUN = function(x){
  un.caso(datos$data$pd_horas[x], datos$data$horas[x])
})

datos$data$horas <- check
###############################################################################

## hack: cambiar nombres a mano
names(datos$data)[162] = 'antig_anos'
names(datos$data)[116] = 'ano_nac'
names(datos$data) = gsub('__', '_', names(datos$data))
datos$recomendaciones$columna_original[162] = 'antig_anos'
datos$recomendaciones$columna_original[116] = 'ano_nac'
datos$recomendaciones$columna_original = gsub('__', '_', datos$recomendaciones$columna_original)


df <- datos$data %>% ## datos
  create.cod.imss(.) %>% ## Creo codemandados
  limpia.fechas(.) %>%
  checar.inconsistencias(.) %>% ## quito cosas that make no sense
  #limpiar.nombres.dataset(.) %>%
  select.variables.recomendadas(., 
                                datos$recomendaciones, 
                                vars.extra = c("cod_imss", "antig_anos")) %>%## Seleccionamos las variables chidas
  recodificar.limpiar(.) %>% ## normalizmamos niveles, codificamos apropiadamente
  dplyr::mutate_all(., funs(chars2factors)) %>% # todo caracter, debe ser factor
  retransforma.problematicos(.) ## Retransformacion de factores problematicos (demasiados niveles, muy concentrados) 
  

# ##### Nuevos laudos
laudos <- read_excel("../data/laudos.xlsx") 
names(laudos) <- normalize_names(names(laudos))
#hack
names(laudos)[c(116, 162)] = c('ano_nac', 'antig_anos')
names(laudos) <- gsub('__', '_', names(laudos))

# names(laudos) <- gsub("\\)|\\(", "", names(laudos))
# laudos$sueldo_diario_integrado <- as.numeric(gsub("\\$|\\,| ", "", laudos$sueldo_diario_integrado))
laudos$`sueldo_diario_(integrado)` <- as.numeric(gsub("\\$|\\,| ", "", laudos$`sueldo_diario_(integrado)`))
lt <- as.numeric(gsub("\\$|\\,|\\-| ", "", laudos$liq_total))
lt[is.na(lt)] <- 0
laudos$liq_total <- lt

#### Fix a horas. Las horas no son necesariamente semanales. Hay diferentes unidades
un.caso <- function(pd.horas, horas){
  ifelse(pd.horas == 0, 6 * horas, 
         ifelse(pd.horas == 1, 0.25 * horas, 
                ifelse(pd.horas == 2, 0.5 * horas,
                       ifelse(pd.horas == 3, horas, NA))))
}
laudos$horas <- as.numeric(laudos$horas)
check <- sapply(seq(nrow(laudos)), FUN = function(x){
  un.caso(laudos$pd_horas[x], laudos$horas[x])
})

laudos$horas <- check
###############################################################################


laudos2 <- laudos %>%
# laudos <- read.csv("../data/laudos2.csv", stringsAsFactors = F) %>% ## datos
  create.cod.imss(.) %>% ## Creo codemandados
  limpia.fechas.v2(.) %>%
  #checar.inconsistencias(.) %>% ## quito cosas that make no sense
  # limpiar.nombres.dataset(.) %>%
  select.variables.recomendadas(., 
                                datos$recomendaciones, 
                                vars.extra = c("cod_imss", "antig_anos")) %>%## Seleccionamos las variables chidas
  recodificar.limpiar(.) %>% ## normalizmamos niveles, codificamos apropiadamente
  dplyr::mutate_all(., funs(chars2factors)) %>% # todo caracter, debe ser factor
  retransforma.problematicos(.)


### Elimino laudos de la base grande, le pego laudos nuevos
df <- df[-which(df$modo_de_termino == "laudo"), ]
df <- rbind(df, laudos2)


################################################################################################# check w/ joyce!
## Variables donde hay perdidas, imputar
replace.na.in.factor <- function(ft, valor.missing) {
  ft <- as.character(ft)
  ft[is.na(ft)] <- valor.missing
  return(as.factor(ft))
}

df$giro_empresa <- replace.na.in.factor(df$giro_empresa, "Otro")
df$rec_hr_extra <- replace.na.in.factor(df$rec_hr_extra, "0")

df <- df[, -match("anio", names(df))]

###############################################################################
## FOrmato de la v1 de la calculadora

df$gen <- factor(as.character(df$gen), labels = c(0, 1), levels = c("Hombre", "Mujer"))
df$trab_base <- factor(as.character(df$trab_base), labels = c(0, 1), levels = c("base", "confianza"))
df$giro_empresa <- factor(as.character(df$giro_empresa),
                              labels = c(1:11),
                              levels = c("Servicios", "Comercial", "Reclutamiento", "Manufactura", "Transporte", "Servicios Profesionales", "Otro", "Comunicacion", "Construccion", "Instituciones Financieras", "Servicios Publicos"))
df$acci_on_principal <- factor(as.character(df$acci_on_principal),
                                   labels = c(1:3),
                                   levels = c("Reinstalacion", "Indemnizacion Constitucional", "Rescision"))
df$causa <- factor(as.character(df$causa), labels = c(0, 1), levels = c("Sin previo aviso", "Otro"))
df$tipo_de_abogado <- factor(as.character(df$tipo_de_abogado), 
                                 labels = c(0, 1), 
                                 levels = c("Privado", "Otro"))
df$cod_imss <- factor(as.character(df$cod_imss), 
                          labels = c(0, 1), 
                          levels = c(0, 1))
df$reinstalacion_t <- factor(as.character(df$reinstalacion_t), 
                                 labels = c(0, 1), 
                                 levels = c(0, 1))
df$indem_const_t <- factor(as.character(df$indem_const_t), 
                               labels = c(0, 1), 
                               levels = c(0, 1))
df$sal_caidos_t <- factor(as.character(df$sal_caidos_t), 
                              labels = c(0, 1), 
                              levels = c(0, 1))
df$rec_hr_extra <- factor(as.character(df$rec_hr_extra), 
                              labels = c(0, 1), 
                              levels = c(0, 1))
df$sarimssinfo <- factor(as.character(df$sarimssinfo), 
                             labels = c(0, 1), 
                             levels = c(0, 1))


################################################################################
## Creo un par de variables auxiliares
df$id <- c(1:nrow(df))

backup <- df
backup$menor.3.anos <- 0
backup$menor.3.anos[backup$djuicio <= 3] <- 1

df <- df[-which(df$djuicio > 3 & df$modo_de_termino != "laudo"), ]



datos <- df
rm(df)
rm(laudos, laudos2)


