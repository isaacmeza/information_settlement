source("../lib/0_clean_dataset_final.R")

# Remove NA
df <- datos %>% select(-ano_nac) %>% na.exclude(.)
## modo_de_termino como caracter
df$modo_de_termino <- as.character(df$modo_de_termino)

### Back-up
data.back.up <- df

################################################################################
## Bases para liq_total
df <- dplyr::rename(data.back.up, y = liq_total) %>% dplyr::select(., -djuicio)

lt.laudo.gana.df <- dplyr::filter(df, modo_de_termino == "laudo", y > 0) %>% dplyr::select(-modo_de_termino)
lt.laudo.pierde.df <- dplyr::filter(df, modo_de_termino == "laudo", y <= 0) %>% dplyr::select(-modo_de_termino)
lt.convenio.df <- dplyr::filter(df, modo_de_termino == "convenio") %>% dplyr::select(-modo_de_termino)

################################################################################
## Bases para duracion
df <- dplyr::rename(data.back.up, y = djuicio)
# 
d.laudo.gana.df <- dplyr::filter(df, modo_de_termino == "laudo", liq_total > 0) %>% dplyr::select(-modo_de_termino, -liq_total)
d.laudo.pierde.df <- dplyr::filter(df, modo_de_termino == "laudo", liq_total <= 0) %>% dplyr::select(-modo_de_termino, -liq_total)
d.convenio.df <- dplyr::filter(df, modo_de_termino == "convenio") %>% dplyr::select(-modo_de_termino, -liq_total)
d.desiste.df <- dplyr::filter(df, modo_de_termino == "desiste") %>% dplyr::select(-modo_de_termino, -liq_total)
d.caducidad.df <- dplyr::filter(df, modo_de_termino == "caducidad") %>% dplyr::select(-modo_de_termino, -liq_total)
d.desycad.df <- dplyr::filter(df, modo_de_termino %in% c("caducidad", "desiste")) %>% dplyr::select(-modo_de_termino, -liq_total)


## Bases para categoricas
data.back.up <- data.frame(data.back.up)
df.desiste <- data.back.up
df.desiste$y <- 0L
df.desiste$y[which(df.desiste$modo_de_termino == "desiste")] <- 1L
df.desiste <- dplyr::select(df.desiste, -djuicio, -liq_total, -modo_de_termino)

df.convenio <- data.back.up
df.convenio$y <- 0L
df.convenio$y[which(df.convenio$modo_de_termino == "convenio")] <- 1L
df.convenio <- dplyr::select(df.convenio, -djuicio, -liq_total, -modo_de_termino)

df.caduca <- data.back.up
df.caduca$y <- 0L
df.caduca$y[which(df.caduca$modo_de_termino == "caducidad")] <- 1L
df.caduca <- dplyr::select(df.caduca, -djuicio, -liq_total, -modo_de_termino)

df.laudo <- data.back.up
df.laudo$y <- 0L
df.laudo$y[which(df.laudo$modo_de_termino == "laudo")] <- 1L
df.laudo <- dplyr::select(df.laudo, -djuicio, -liq_total, -modo_de_termino)

df.laudo.gana <- dplyr::filter(data.back.up, modo_de_termino == "laudo")
df.laudo.gana$y <- 0L
df.laudo.gana$y[which(df.laudo.gana$liq_total > 0)] <- 1L
df.laudo.gana <- dplyr::select(df.laudo.gana, -djuicio, -liq_total, -modo_de_termino)

df.laudo.pierde <- dplyr::filter(data.back.up, modo_de_termino == "laudo")
df.laudo.pierde$y <- 0L
df.laudo.pierde$y[which(df.laudo.pierde$liq_total <= 0)] <- 1L
df.laudo.pierde <- dplyr::select(df.laudo.pierde, -djuicio, -liq_total, -modo_de_termino)

################## Multinomial logit

data.probas <- dplyr::select(data.back.up, -liq_total, -djuicio)
data.probas$modo_de_termino <- factor(data.probas$modo_de_termino, 
                                      levels = c("convenio", "desiste", "caducidad", "laudo"),
                                      labels = c(1:4))

# library(foreign)
# write.dta(data.probas, file = "data4multinomial.dta")


# Guardar todos los dataframes (est? feo, ni pedo)
rm(datos)

obj_save <- function(objects) {
  object_names <- names(objects)
  sapply(1:length(objects), function(i) {
    filename_rds = paste0('../data/', object_names[i], '.rds')
    filename_csv = paste0('../data/', object_names[i], '.csv')
    saveRDS(objects[i], filename_rds)
    write.csv(objects[i], file = filename_csv, row.names = F)
  })
}

df_list <- Filter(function(x) is(x, 'data.frame'), mget(ls()))

obj_save(df_list)

