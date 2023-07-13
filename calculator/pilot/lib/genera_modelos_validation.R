
source("../lib/0_clean_dataset_final.R")
source("../lib/1_create_datasets_final.R")
source("funciones_auxiliares.R")

prepara.datos <- function(base){
  base <- quita.outliers(base)
  medias_est <- medias.estandarizar(base)
  medias_est$variable <- as.character(medias_est$variable)
  base.estandarizada <- estandarizar(base, medias_est)
  return(list(base = base.estandarizada, medias = medias_est))
}

################################################################################
## Duracion de convenio

d.convenio.df.t <- quita.outliers(d.convenio.df)
medias_duracion_convenio <- medias.estandarizar(d.convenio.df.t)
medias_duracion_convenio$variable <- as.character(medias_duracion_convenio$variable)
estandarizados_duracion_convenio <- estandarizar(d.convenio.df.t, medias_duracion_convenio)

set.seed(140693)
duracion_convenio_train <- sample_frac(estandarizados_duracion_convenio, size = .7)
sid <- as.numeric(rownames(duracion_convenio_train))
duracion_convenio_test <- estandarizados_duracion_convenio[-sid ,]

mod_duracion_convenio <- glm(log(1 + y) ~ ., 
                             data = dplyr::select(duracion_convenio_train, -id), family = 'gaussian')
save(mod_duracion_convenio, file = "../modelos/duracion_convenio_validation.rdata")

saveRDS(duracion_convenio_test, '../data/duracion_convenio_test.RDS')

# rm(d.convenio.df, d.convenio.df.t, medias_duracion_convenio, 
# estandarizados_duracion_convenio, mod_duracion_convenio)


################################################################################
## Duracion de desiste: bosque_log

d.desiste.df.t <- quita.outliers(d.desiste.df)
medias_duracion_desiste <- medias.estandarizar(d.desiste.df.t)
medias_duracion_desiste$variable <- as.character(medias_duracion_desiste$variable)
estandarizados_duracion_desiste <- estandarizar(d.desiste.df.t, medias_duracion_desiste)

set.seed(140693)
duracion_desiste_train <- sample_frac(estandarizados_duracion_desiste, size = .7)
sid <- as.numeric(rownames(duracion_desiste_train))
duracion_desiste_test <- estandarizados_duracion_desiste[-sid ,]

mod_duracion_desiste <- randomForest(
  log(1 + y) ~ .,
  #data = dplyr::select(dplyr::mutate_each(df.entrena.st, funs(chars2factors)), -id),
  data = dplyr::select(duracion_desiste_train, -id),
  ntree=300,
  importance=TRUE,
  do.trace=TRUE,
  na.action =na.omit
)

save(mod_duracion_desiste, file = "../modelos/duracion_desiste_validation.rdata")
saveRDS(duracion_desiste_test, '../data/duracion_desiste_test.RDS')

# rm(d.desiste.df, d.desiste.df.t, medias_duracion_desiste, estandarizados_duracion_desiste,
#    mod_duracion_desiste)

################################################################################

## Duracion de caducidad: mod_log

# d.caducidad.df <- d.caducidad.df[, -match(c("giro_empresa", "acci_on_principal", "sal_caidos_t", "causa"), names(d.caducidad.df))]
aux <- prepara.datos(d.caducidad.df)
medias_duracion_caducidad <- aux$medias

set.seed(140693)
duracion_caducidad_train <- sample_frac(aux$base, size = .7)
sid <- as.numeric(rownames(duracion_caducidad_train))
duracion_caducidad_test <- aux$base[-sid ,]

mod_duracion_caducidad <- glm(log(1 + y) ~ ., 
                              data = dplyr::select(duracion_caducidad_train, -id), family = 'gaussian')
save(medias_duracion_caducidad, mod_duracion_caducidad, file = "../modelos/duracion_caducidad_validation.rdata")
saveRDS(duracion_caducidad_test, '../data/duracion_desiste_test.RDS')
# rm(d.caducidad.df, aux, medias_duracion_caducidad, mod_duracion_caducidad)


################################################################################

## Duracion de laudo pierde: mod_log

aux <- prepara.datos(d.laudo.pierde.df)
medias_duracion_laudo_pierde <- aux$medias

set.seed(140693)
duracion_laudo_pierde_train <- sample_frac(aux$base, size = .7)
sid <- as.numeric(rownames(duracion_laudo_pierde_train))
duracion_laudo_pierde_test <- aux$base[-sid ,]

mod_duracion_laudo_pierde <- glm(log(1 + y) ~ ., 
                                 data = dplyr::select(aux$base, -id), family = 'gaussian')

save(medias_duracion_laudo_pierde, mod_duracion_laudo_pierde, file = "../modelos/duracion_laudo_pierde.rdata")
saveRDS(mod_duracion_laudo_pierde, '../data/duracion_laudo_pierde_test.RDS')

# rm(d.laudo.pierde.df, aux, medias_duracion_laudo_pierde, mod_duracion_laudo_pierde)



################################################################################

## Duracion de laudo gana: bosque_log

aux <- prepara.datos(d.laudo.gana.df)
medias_duracion_laudo_gana <- aux$medias
set.seed(140693)
duracion_laudo_gana_train <- sample_frac(aux$base, size = .7)
sid <- as.numeric(rownames(duracion_laudo_gana_train))
duracion_laudo_gana_test <- aux$base[-sid ,]


mod_duracion_laudo_gana <- randomForest(
  log(1 + y) ~ .,
  #data = dplyr::select(dplyr::mutate_each(df.entrena.st, funs(chars2factors)), -id),
  data = dplyr::select(aux$base, -id),
  ntree=300,
  importance=TRUE,
  do.trace=TRUE,
  na.action =na.omit
)
save(medias_duracion_laudo_gana, mod_duracion_laudo_gana, file = "../modelos/duracion_laudo_gana.rdata")
saveRDS(mod_duracion_laudo_gana, '../data/duracion_laudo_pierde_test.RDS')
# rm(d.laudo.gana.df, aux, medias_duracion_laudo_gana, mod_duracion_laudo_gana)

################################################################################
################################################################################

## Liqtotal convenios

aux <- prepara.datos(lt.convenio.df)
medias_liqtotal_convenios <- aux$medias

lt_convenio_train = sample_frac(aux$base, .7)
sid <- as.numeric(rownames(lt_convenio_train))
lt_convenio_test <- aux$base[-sid ,]

mod_liqtotal_convenios <- randomForest(
  log(1 + y) ~ .,
  #data = dplyr::select(dplyr::mutate_each(df.entrena.st, funs(chars2factors)), -id),
  data = dplyr::select(lt_convenio_train, -id),
  ntree=300,
  importance=TRUE,
  do.trace=TRUE,
  na.action =na.omit
)

save(mod_liqtotal_convenios, file = "../modelos/liqtotal_convenio_validation.rdata")
saveRDS(lt_convenio_test, '../data/lt_convenio_test.RDS')


# rm(lt.convenio.df, aux, medias_liqtotal_convenios, mod_liqtotal_convenios)

################################################################################
## Liqtotal laudo gana

aux <- prepara.datos(lt.laudo.gana.df)
medias_liqtotal_laudo_gana <- aux$medias

lt_laudo_gana_train = sample_frac(aux$base, .7)
sid <- as.numeric(rownames(lt_laudo_gana_train))
lt_laudo_gana_test <- aux$base[-sid ,]

mod_liqtotal_laudo_gana <- randomForest(
  log(1 + y) ~ .,
  #data = dplyr::select(dplyr::mutate_each(df.entrena.st, funs(chars2factors)), -id),
  data = dplyr::select(lt_laudo_gana_train, -id),
  ntree=300,
  importance=TRUE,
  do.trace=TRUE,
  na.action =na.omit
)

save(medias_liqtotal_laudo_gana, mod_liqtotal_laudo_gana, file = "../modelos/liqtotal_laudo_gana_validation.rdata")
saveRDS(lt_laudo_gana_test, '../data/lt_laudo_gana_test.RDS')

save(lt_convenio_test, 
     duracion_convenio_test,
     duracion_caducidad_test,
     duracion_laudo_gana_test,
     duracion_laudo_pierde_test,
     lt_laudo_gana_test,
     duracion_desiste_test, file = '../data/test_data.RData')

save(lt_convenio_train, 
     duracion_convenio_train,
     duracion_caducidad_train,
     duracion_laudo_gana_train,
     duracion_laudo_pierde_train,
     lt_laudo_gana_train,
     duracion_desiste_train, file = '../data/train_data.RData')

save(mod_liqtotal_convenios,
   mod_liqtotal_laudo_gana,
   mod_duracion_laudo_gana,
   mod_duracion_laudo_pierde,
   mod_duracion_convenio,
   mod_duracion_caducidad,
  mod_duracion_desiste,
  file = '../data/validation_models.RData'
)

