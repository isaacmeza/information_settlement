# ruta <- "C:/Users/ITAM-SADKA/AppData/Roaming/BERT/"
ruta <- ""

# caso <- matrix(c(0, 0, 435, 98, "Comercial", "Reinstalacion",	1, 1, 0, 1, 0, 1,	0, 1,	0, 7.2),
#  )

medias.estandarizar <- function(datos.entrenamiento) {
  clases <- sapply(datos.entrenamiento, class);
  df_e.n <- datos.entrenamiento[, which(clases %in% c("numeric", "integer"))] %>% tidyr::gather(variable, valor, -id);
  
  media_de <- df_e.n %>%
    group_by(variable) %>%
    summarise(media = mean(valor, na.rm = T), de = sd(valor, na.rm = T));
  media_de;
}
estandarizar <- function(nuevos_dat, media_de){
  clases <- sapply(nuevos_dat, class);
  vars <- unique(c(names(nuevos_dat)[which(!clases %in% c("numeric", "integer"))], 'y', 'id'));
  datos_est <- nuevos_dat[, which(clases %in% c("numeric", "integer"))] %>%
    gather(variable, valor, -id) %>%
    group_by(variable) %>%
    filter(variable != 'y') %>% data.frame(.)
  datos_est$variable <- as.character(datos_est$variable)
  
  datos_est <- datos_est %>%
    left_join(media_de) %>%
    mutate(valor_st = (valor - media)/de) %>%
    dplyr::select(id, variable, valor_st) %>%
    spread(variable, valor_st) %>%
    dplyr::left_join(nuevos_dat[, vars], by = c("id" = "id"));
  datos_est;
}
estandarizar.nuevos <- function(nuevos_dat, media_de){
  clases <- sapply(nuevos_dat, class);
  vars <- unique(c(names(nuevos_dat)[which(!clases %in% c("numeric", "integer"))], 'id'));
  datos_est <- nuevos_dat[, which(clases %in% c("numeric", "integer"))] %>%
    gather(variable, valor, -id) %>%
    group_by(variable) %>%
    filter(variable != 'y') %>% data.frame(.)
  datos_est$variable <- as.character(datos_est$variable);
  
  datos_est <- datos_est %>%
    left_join(media_de) %>%
    mutate(valor_st = (valor - media)/de) %>%
    dplyr::select(id, variable, valor_st) %>%
    spread(variable, valor_st) %>%
    dplyr::left_join(nuevos_dat[, vars], by = c("id" = "id"));
  datos_est;
}
quita.outliers <- function(datos.entrenamiento) {
  quitar <- valida.niveles(datos.entrenamiento)
  print(quitar)
  if ( length(quitar) >= 1) {
    datos.entrenamiento <- datos.entrenamiento[, -match(quitar, names(datos.entrenamiento))];
  }
  mod_1 <- lm(log(1 + y) ~ ., data = dplyr::select(datos.entrenamiento, -id));
  d1 <- cooks.distance(mod_1);
  r <- stdres(mod_1);
  a <- cbind(datos.entrenamiento, d1, r);
  outliers <- a[d1 > 4/nrow(datos.entrenamiento), ];
  datos.entrenamiento <- datos.entrenamiento[d1 < 4/nrow(datos.entrenamiento),];
  quitar <- valida.niveles(datos.entrenamiento)
  print(quitar)
  if ( length(quitar) >= 1) {
    datos.entrenamiento <- datos.entrenamiento[, -match(quitar, names(datos.entrenamiento))];
  }
  datos.entrenamiento
}
mapea.valores.excel.viejo <- function(caso){
  #recibo un vector desde genero en adelante
  as.data.frame(list(
    "gen" = as.integer(caso[1,1]),
    "trab_base" = as.integer(caso[2,1]),
    "sueldo_diario_integrado" = caso[3],
    "horas" = caso[4],
    "giro_empresa" = as.character(caso[5]),
    "acci_on_principal" = as.character(caso[6]),
    "causa" = caso[7],
    "tipo_de_abogado" = caso[8],
    "cod_imss" = caso[9],
    "reinstalacion_t" = caso[10],
    "indem_const_t" = caso[11],
    "rec_20_d_ias_t" = caso[12],
    "sal_caidos_t" = caso[13],
    "rec_hr_extra" = caso[14],
    "sarimssinfo" = caso[15],
    "antig_anos" = caso[16]
  ));
}

mapea.valores.excel <- function(caso){
  #recibo un vector desde genero en adelante
  if(dim(caso)[2] > 1) caso <- t(caso);
  as.data.frame(list(
    "gen" = factor(caso[1, 1], levels = c(0,1)),
    "trab_base" = factor(caso[2, 1], levels = c(0,1)),
    "sueldo_diario_integrado" = as.numeric(as.character(caso[3, 1])),
    "horas" = as.numeric(as.character(caso[4, 1])),
    "giro_empresa" = factor(caso[5, 1], labels = c(1:11), levels = c("Servicios", "Comercial", "Reclutamiento", "Manufactura", "Transporte", "Servicios Profesionales", "Otro", "Comunicacion", "Construccion", "Instituciones Financieras", "Servicios Publicos")),
    "acci_on_principal" = factor(caso[6, 1], labels = c(1:3),
                                 levels = c("Reinstalacion", "Indemnizacion Constitucional", "Rescision")),
    "causa" = factor(caso[7, 1], levels = c(0,1)),
    "tipo_de_abogado" = factor(caso[8, 1], levels = c(0,1)),
    "cod_imss" = factor(caso[9, 1], levels = c(0,1)),
    "reinstalacion_t" = factor(caso[10, 1], levels = c(0,1)),
    "indem_const_t" = factor(caso[11, 1], levels = c(0,1)),
    "rec_20_d_ias_t" = factor(caso[12, 1], levels = c(0,1)),
    "sal_caidos_t" = factor(caso[13, 1], levels = c(0,1)),
    "rec_hr_extra" = factor(caso[14, 1], levels = c(0,1)),
    "sarimssinfo" = factor(caso[15, 1], levels = c(0,1)),
    "antig_anos" = as.numeric(as.character(caso[16, 1]))
  ));
}

predice_dura_convenio <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/duracion_convenio.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_duracion_convenio);
  prediccion <- predict(object = mod_duracion_convenio, newdata = nuevos.datos);
  prediccion <- exp(prediccion) - 1;
  prediccion;
}

predice_dura_caducidad <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/duracion_caducidad.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_duracion_caducidad);
  prediccion <- predict(object = mod_duracion_caducidad, newdata = nuevos.datos);
  prediccion <- exp(prediccion) - 1;
  prediccion;
}
predice_dura_desiste <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/duracion_desiste.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_duracion_desiste);
  prediccion <- predict(object = mod_duracion_desiste, newdata = nuevos.datos);
  prediccion <- exp(prediccion) - 1;
  prediccion;
}
predice_dura_laudo_gana <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/duracion_laudo_gana.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_duracion_laudo_gana);
  prediccion <- predict(object = mod_duracion_laudo_gana, newdata = nuevos.datos);
  prediccion <- exp(prediccion) - 1;
  prediccion;
}
predice_dura_laudo_pierde <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/duracion_laudo_pierde.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_duracion_laudo_pierde);
  prediccion <- predict(object = mod_duracion_laudo_pierde, newdata = nuevos.datos);
  prediccion <- exp(prediccion) - 1;
  prediccion;
}

predice_liqtotal_convenio <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/liqtotal_convenio.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_liqtotal_convenios);
  prediccion <- predict(object = mod_liqtotal_convenios, newdata = nuevos.datos);
  prediccion <- exp(prediccion) - 1;
  prediccion;
  
}
predice_liqtotal_laudo_gana <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/liqtotal_laudo_gana.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_liqtotal_laudo_gana);
  prediccion <- predict(object = mod_liqtotal_laudo_gana, newdata = nuevos.datos);
  prediccion <- exp(prediccion) - 1;
  prediccion;
}

predice_proba_convenio <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/proba_convenio.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_probas_convenio);
  prediccion <- predict(object = mod_probas_convenio, newdata = nuevos.datos, type = "response");
  prediccion;
}

predice_proba_desiste <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/proba_desiste.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_probas_desiste);
  prediccion <- predict(object = mod_probas_desiste, newdata = nuevos.datos, type = "response");
  prediccion;
}

predice_proba_caduca <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/proba_caduca.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_probas_caduca);
  prediccion <- predict(object = mod_probas_caduca, newdata = nuevos.datos, type = "response");
  prediccion;
}

predice_proba_laudo_gana <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/proba_laudo_gana.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_probas_laudo_gana);
  prediccion <- predict(object = mod_probas_laudo_gana, newdata = nuevos.datos, type = "response");
  prediccion;
}

predice_proba_laudo_pierde <- function(caso) {
  nuevos.datos <- mapea.valores.excel(caso);
  load(paste0(ruta, "calculadora_piloto/modelos/proba_laudo_pierde.rdata"));
  nuevos.datos$id <- 1:nrow(nuevos.datos);
  nuevos.datos <- estandarizar.nuevos(nuevos.datos, medias_probas_laudo_pierde);
  prediccion <- predict(object = mod_probas_laudo_pierde, newdata = nuevos.datos, type = "response");
  prediccion;
}

