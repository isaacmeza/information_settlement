## check that factors have + that one level in train
valida.niveles <- function(train) {
  remove <- character()
  clases <- sapply(train, 'class', simplify = T)
  iter <- names(train)[clases == "factor"]
  for (n in iter) {
    #     if ( length(unique(as.character(train[, n]))) <= 1 ){
    #       remove <- c(remove, n)
    #     }
    if ( min(table(train[, n])) < 5 ){
      remove <- c(remove, n)
    }
  }
  return(remove)
}


### check singularities

create.numeric.df <- function(df) {
  transform.column <- function(x) {
    if ( class(x) == "character" ) {
      x <- as.numeric(as.factor(x))
    } else if ( class(x) == "factor" ) {
      x <- as.numeric(x)
    }
    return(x)
  }
  
  transform.df <- mutate_each(df, funs(transform.column))
  return(transform.df)
}

check.inf.na.nan <- function(df){
  l <- lapply( 1:ncol(df), FUN = function(i) {
    x <- df[, i]
    which(is.infinite(x))
  })
  ll <- Reduce('c', l)
  return(ll)
}

imputa.valores <- function(df){
  df$giro_empresa <- as.character(df$giro_empresa)
  df$giro_empresa[is.na(df$giro_empresa)] <- "No especificado"
  df$giro_empresa <- as.factor(df$giro_empresa)
  df
}

limpia.datos.rec <- function(data.dir, recomendaciones.dir, skip) {
  datos <- lee(data.dir = data.dir, recomendaciones.dir = recomendaciones.dir, skip = skip)
  
  df <- datos$data %>% ## datos
    create.cod.imss(.) %>% ## Creo codemandados
    checar.inconsistencias(.) %>% ## quito cosas that make no sense
    select.variables.recomendadas(., datos$recomendaciones) %>% ## Seleccionamos las variables chidas
    recodificar.limpiar(.) %>% ## normalizmamos niveles, codificamos apropiadamente
    dplyr::mutate_each(., funs(chars2factors)) %>% # todo caracter, debe ser factor
    retransforma.problematicos(.) ## Retransformacion de factores problematicos (demasiados niveles, muy  
  return(df)
}

lee <- function(data.dir, recomendaciones.dir, skip = skip) {
  df <- readxl::read_excel(data.dir,
                           sheet = 1, col_names = T, na = "", skip = skip)
  names(df) <- normalize_names(names(df))
  ## Recomendaciones para filtrar
  rec <- readxl::read_excel(recomendaciones.dir,
                            sheet = "recomendaciones", col_names = T, na = "")
  ## Normalizamos nombres
  names(rec) <- normalize_names(names(rec))
  rec$columna_original <- normalize_names(rec$columna_original)
  # Todas las vars recomendadas estan en la base?
  assertthat::assert_that(sum(rec$columna_original[which(rec$incluir == 1)] %in% names(df)) == sum(rec$incluir))
  #print(paste0("Faltan ", rec$columna_original[which(rec$incluir == 1)][!rec$columna_original[which(rec$incluir == 1)] %in% names(df)], collapse = ', '))
  return(list(data = df, recomendaciones = rec))
}

limpia.fechas <- function(datos){
  datos$fecha_demanda <- as.Date(as.integer((datos$fecha_demanda)), origin = "1899-12-30")
  datos$fecha_termino <- as.Date(as.integer((datos$fecha_de_termino)), origin = "1899-12-30")
  datos$fecha_ent_t <- as.Date(as.integer((datos$fecha_ent_t)), origin = "1899-12-30")
  datos$fecha_sal_t <- as.Date(as.integer((datos$fecha_sal_t)), origin = "1899-12-30")
  datos$fecha_de_termino <- as.Date(as.integer((datos$fecha_de_termino)), origin = "1899-12-30")
  datos
}
limpia.fechas.v2 <- function(datos){
  datos$fecha_demanda <- as.Date(datos$fecha_demanda, format = "%d/%m/%Y")
  datos$fecha_termino <- as.Date(datos$fecha_de_termino, format = "%d/%m/%Y")
  datos$fecha_ent_t <- as.Date(datos$fecha_ent_t, format = "%d/%m/%Y")
  datos$fecha_sal_t <- as.Date(datos$fecha_sal_t, format = "%d/%m/%Y")
  datos$fecha_de_termino <- as.Date(datos$fecha_de_termino, format = "%d/%m/%Y")
  datos
}
retransforma.problematicos <- function(datos){
  datos$causa <- as.character(datos$causa)
  datos$causa <- plyr::revalue(datos$causa,
                               c(
                                 "No recibir salario, lugar o fecha esp" = "Otro",
                                 "Reduccion salarial" = "Otro"
                               ))
  datos$causa <- as.factor(datos$causa)
  
  datos$tipo_de_abogado <- as.character(datos$tipo_de_abogado)
  datos$tipo_de_abogado <- plyr::revalue(datos$tipo_de_abogado,
                                         c(
                                           "Sindicato" = "Otro"
                                           , "Procurador" = "Otro"
                                         ))
  datos$tipo_de_abogado <- factor(datos$tipo_de_abogado,
                                  levels = c("Otro", "Privado"),
                                  labels = c("Otro", "Privado"))
  return(datos)  
}
recodificar.limpiar <- function(datos){
  ## Cleanup
#   print(head(datos$sueldo_diario_integrado))
#   print(names(datos))
  datos$sueldo_diario_integrado <- as.numeric(datos$sueldo_diario_integrado)
  datos$horas <- as.numeric(datos$horas)
  datos$anio <- as.character(datos$anio)
  # datos$fecha_demanda <- as.Date(as.integer((datos$fecha_demanda)), origin = "1899-12-30")
  # PRIMER ABOGADO: 1=PRIVADO, 2=SINDICATO, 3=PROCURADOR
  datos$tipo_de_abogado <- factor(datos$tipo_de_abogado, 
                                  levels = c(1, 2, 3), 
                                  labels = c("Privado", "Sindicato", "Procurador"))
  # Giro de la empresa
  datos$giro_empresa <- fancy_names(normalize_names(datos$giro_empresa))
  datos$giro_empresa[which(datos$giro_empresa == "No Menciona")] <- NA
  datos$giro_empresa[which(datos$giro_empresa == "No Especifica")] <- NA
  datos$giro_empresa[which(datos$giro_empresa == "Recutamiento")] <- "Reclutamiento"
  datos$giro_empresa <- plyr::revalue(datos$giro_empresa,
                                      c("Sevicios Profesionales" = "Servicios Profesionales"
                                        , "Autoservicio" = "Comercial"
                                        , "Entretenimiento" = "Servicios"
                                        , "Salud" = "Servicios Profesionales"
                                        , "Extractiva" = "Construccion"
                                        , "Seguridad Privada" = "Servicios"
                                        , "Servicios Profesionales, Autoservicio" = "Servicios Profesionales"
                                        , "Bienes Raices" = "Comercial"
                                        , "Educativo" = "Servicios Profesionales"
                                        , "Servicios Financieros" = "Instituciones Financieras"
                                        , "Paqueteria Y Mensajeria" = "Servicios"
                                        , "Reclutamiento, Comercial" = "Reclutamiento"
                                        , "Turismo" = "Servicios"
                                        , "Electrodomesticos" = "Manufactura"
                                        , "Limpieza" = "Servicios"
                                        , "Restaurante" = "Comercial"
                                        , "Servicios, Comercial" = "Comercial"
                                        , "Autotransporte" = "Transporte"
                                        , "Transporte De Carga" = "Transporte"
                                        , "Manufactura, Comercial" = "Manufactura"
                                        , "Promocion De Servicios" = "Servicios"
                                        , "Publicidad" = "Servicios"
                                      ))
  # Trabajador base: 0=base, 1=confianza
  datos$trab_base <- factor(datos$trab_base, levels = c(0, 1), labels = c("base", "confianza"))
  # Fecha de entrada y salida del trabajador
#   datos$fecha_ent_t <- as.Date(as.integer((datos$fecha_ent_t)), origin = "1899-12-30")
#   datos$fecha_sal_t <- as.Date(as.integer((datos$fecha_sal_t)), origin = "1899-12-30")
  # Accion principal
  ## COMO ES UNA CALCULADORA DE COMPENSACION POR DESPIDO, JOYCE SUGIERE QUITAR TODOS LOS QUE NO SON INDEMNIZACION CONSTITUCIONAL O REINSTALACION O RESCISION. PERDEMOS ALGUNOS DATOS PERO NO SON DATOS UTILES PARA ESTA CALCULADORA PORQUE NO ES EL MISMO UNDERLYING ISSUE.
  datos$acci_on_principal <- fancy_names(normalize_names(datos$acci_on_principal))
  datos$acci_on_principal[which(datos$acci_on_principal == "No Aplica")] <- NA
  
  datos <- dplyr::filter(datos,
                         acci_on_principal %in% c("Indemnizacion Constitucional", "Reinstalacion", "Rescision"))
  # Causa: 1=sin previo aviso,2=reducciOn salario, 3=no recibir salario lugar o fecha esp, 4=reducciOn o cambio horario, 5=falta de providad, 6=otro
  datos$causa[which(datos$causa == 6)] <- 5 # falta de providad es otros
  datos$causa <- factor(datos$causa, levels = c(1, 2, 3, 4, 5),
                        labels = c("Sin previo aviso", "Reduccion salarial", 
                                   "No recibir salario, lugar o fecha esp",
                                   "Reduccion o cambio horario",
                                   "Otro"))
  ## GÃ©nero: 0=HOMBRE, 1=MUJER
  datos$gen <- factor(datos$gen, levels = c(0, 1), labels = c("Hombre", "Mujer"))
  
  ## AÃ‘o de nacimiento: Dropping because of missing values
  # sum(is.na(datos$ano_nac))/nrow(datos) * 100
  # datos <-datos[, -match("ano_nac", names(datos))]
  
  # Reinstalacion,indemnizaciÃ³n, salarios caidos, recibe horas extras,
  # recibe 20 dias son dummies
  datos$reinstalacion_t <- as.factor(as.character(datos$reinstalacion_t))
  datos$indem_const_t <- as.factor(as.character(datos$indem_const_t))
  datos$sal_caidos_t <- as.factor(as.character(datos$sal_caidos_t))
  
  datos$rec_hr_extra[which(datos$rec_hr_extra == 3)] <-0
  datos$rec_hr_extra <- as.factor(as.character(datos$rec_hr_extra))
  datos$rec_20_d_ias_t <- as.factor(as.character(datos$rec_20_d_ias_t))
  datos$sarimssinfo <- as.factor(as.character(datos$sarimssinfo))
  
  # Fecha de termino
  # datos$fecha_de_termino <- as.Date(as.integer((datos$fecha_de_termino)), origin = "1899-12-30")
  
#   # Modo de tÃ©rmino: 1-CONVENIO  2.DESISTIMIENTO 3.-LAUDO 4.CADUCIDAD
#   datos$modo_de_termino[which(datos$modo_de_termino == 4)] <- 2 # caducidad pasa a desistimiento
#   datos$modo_de_termino <- factor(datos$modo_de_termino, 
#                                   levels = c(1, 2, 3),
#                                   labels = c("convenio", "desiste", "laudo"))
#   
  # Modo de tÃ©rmino: 1-CONVENIO  2.DESISTIMIENTO 3.-LAUDO 4.CADUCIDAD
  datos$modo_de_termino <- factor(datos$modo_de_termino, 
                                  levels = c(1, 2, 3, 4),
                                  labels = c("convenio", "desiste", "laudo", "caducidad"))
  
  # Generemos la duracion del juicio, en anos
  datos$djuicio <- as.numeric(datos$fecha_de_termino - datos$fecha_demanda)/365
  
  # wassup con antiguedad
  #View(df[which(df$periodo_t_a_nos != df$antig_anos), c("periodo_t_a_nos", "antig_anos")])
  
  
  ### Quitamos variables redundantes
  
  datos <- dplyr::select(datos, -fecha_captura_exp, -fecha_demanda, -fecha_ent_t,
                         -fecha_sal_t, -periodo_t_a_nos, -fecha_de_termino)
  return(datos)
}
limpiar.nombres.dataset <- function(datos){
  names(datos) <- limpiar.nombres.sucios(names(datos))
  datos <- datos[, which(!duplicated(names(datos)))]
  return(datos)
}
select.variables.recomendadas <- function(df, rec, vars.extra = c("cod_imss", "antig_anos")) {
  datos <- df[, which(names(df) %in% rec$columna_original[which(rec$incluir == 1)])]
  names(datos) <- limpiar.nombres.sucios(names(datos))
  
  # Aumentamos cod_imss
  datos <- cbind(datos, df[, vars.extra])
  return(datos)
}
checar.inconsistencias <- function(df) {
  ### DJUICIOS negativos
#   fecha_demanda <- as.Date(as.integer((df$fecha_demanda)), origin = "1899-12-30")
#   fecha_de_termino <- as.Date(as.integer((df$fecha_de_termino)), origin = "1899-12-30")
  djuicio <- as.numeric(df$fecha_de_termino - df$fecha_demanda)/365
  # write.csv(df[which(djuicio <= 0), ], file = "djuicio_negativo.csv", row.names = F)
  df <- df[-which(djuicio <= 0), ]
  return(df)
}
create.cod.imss <- function(df){
  ## Calculemos la variable chida
  df$id <- c(1:nrow(df))
  extra <- df[, c(match("nombre_demandado_1", names(df)):match("fecha_de_desistimiento6", names(df)))]
  extra <- extra[, which(grepl("nombre_demandado", names(extra)))]
  extra$id <- c(1:nrow(extra))
  demandados <- extra %>% tidyr::gather(key = key, value = value, -id)
  demandados$value <- stringr::str_trim(tolower(demandados$value))
  
  
  ids <- unique(demandados$id[which(grepl("imss|instituto mexicano del seguro social", demandados$value))])
  
  df$cod_imss <- 0
  df$cod_imss[which(ids %in% df$id)] <- 1
  
  ids <- unique(demandados$id[which(grepl("imss|instituto mexicano del seguro social|seguro social|infonavit|issste", demandados$value))])
  
  df$cod_imss <- 0
  df$cod_imss[which(ids %in% df$id)] <- 1
  df$cod_imss <- as.factor(df$cod_imss)
  return(df)
}


factors2chars <- function(x){
  if ( class(x) == "factor" ) {
    x <- as.character(x)
  }
  return(x)
}

chars2factors <- function(x){
  if ( class(x) == "character" ) {
    x <- as.factor(x)
  }
  return(x)
}

limpiar.nombres.sucios <- function(nombres) {
  nombres <- gsub("\\(|\\)", "", nombres) %>%
    gsub("^\\#\\_", "no_", .) %>%
    gsub("\\_\\#$", "_no", .) %>%
    gsub("\\_\\#\\_", "_no_", .) %>% 
    gsub("\\_\\$$", "_pesos", .) %>%
    gsub("\\_\\_", "_", .)
  nombres
}


# Arreglamos nombres para postgresql
normalizarNombres <- function(nombres_de_columnas) {
  # Quitamos trailing spaces y cambiamos espacios multiples por uno solo.
  nombres_de_columnas <- gsub("^ *|(?<= ) | *$", "", nombres_de_columnas, perl=T)
  # Cambiamos espacios y puntos por _
  nombres_de_columnas <- gsub('\\ |\\.', '_', nombres_de_columnas)
  # Cambiamos casos como camelCase por camel_case
  nombres_de_columnas <- gsub("([a-z])([A-Z])", "\\1_\\L\\2", nombres_de_columnas, perl = TRUE)
  # Quitamos Ã±'s
  nombres_de_columnas <- gsub('Ã±','n',nombres_de_columnas)
  # Quitamos acentos
  nombres_de_columnas <- iconv(nombres_de_columnas, to='ASCII//TRANSLIT')
  # Quitamos mayusculas
  tolower(nombres_de_columnas)
}

# Arreglamos nombres de columnas para imprimir tablas o poner en Rmds
nombresMaricas <- function(x){
  # Cambiamos por espacios, cosas que se parezcan en un dataframe (i.e. -, _ y .)
  x <- gsub("(\\_|\\.|\\-)([A-Za-z])", " \\U\\2", x, perl = T)
  x <- gsub("^([A-Za-z])", "\\U\\1", x, perl = T)
  return(x)
}

numerito <- function(number){
  require(stringr)
  if((number - floor(number)) > 0){
    nf <- format(round(number, digits=2), big.mark=",", preserve.width="none")
  } else{
    nf <- format(number, big.mark=",", preserve.width="none")
  }
  nf <- stringr::str_trim(nf)
  return(nf)
}

formato.tabla <- function(df){
  df <- data.frame(df)
  # Numeros y enteros los hacemos leibles y bonitos
  clases <- sapply(df, class)
  for(i in c(1:length(clases))){
    if(clases[i] == "numeric"){
      df[, i] <- numerito(df[, i])
    }
  }
  
  # Ahora, arreglamos los nombres
  names(df) <- nombresMaricas(names(df))
  return(df)
}

limpia.texto <- function(x){
  # Quitamos trailing spaces y cambiamos espacios multiples por uno solo.
  x <- tolower(gsub("^ *|(?<= ) | *$", "", x, perl=T))
  # Quitamos acentos
  x <- iconv(x, to='ASCII//TRANSLIT')
}

dias.semana <- function(weekdays_vector){
  # recibe vector de character con dias de la semana: monday, tuesday, wednesday ...
  # devuelve vector ordenado con dias de la semana en espanol
  require(plyr)
  require(stringr)
  weekdays_vector <- plyr::revalue(
    stringr::str_trim(weekdays_vector), 
    c("monday"="lunes",
      "tuesday" = "martes",
      "wednesday" = "miércoles",
      "thursday" = "jueves",
      "friday" = "viernes",
      "saturday" = "sábado",
      "sunday" = "domingo")
  )
  ordenado <- ordered(weekdays_vector, levels = c("lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"))
  ordenado  
}

meses <- function(meses_vector){
  # recibe vector de character con dias de la semana: monday, tuesday, wednesday ...
  # devuelve vector ordenado con dias de la semana en espanol
  require(plyr)
  require(stringr)
  weekdays_vector <- plyr::revalue(
    stringr::str_trim(meses_vector), 
    c("january" = "enero",
      "february" = "febrero",
      "march" = "marzo",
      "april" = "abril",
      "may" = "mayo",
      "june" = "junio",
      "july" = "julio", 
      "august" = "agosto",
      "september" = "septiembre",
      "october" = "octubre",
      "november" = "noviembre",
      "december" = "diciembre")
  )
  ordenado <- ordered(weekdays_vector, levels = c("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"))
  ordenado  
}

total.porcentaje <- function(totales, porcentajes){
  if(dim(totales)[1]!=dim(porcentajes)[1]){
    stop("No tienen el mismo numero de renglones")
  }
  if(dim(totales)[2]!=dim(porcentajes)[2]){
    stop("No tienen el mismo numero de columnas")
  }
  if(!identical(totales[, 1], porcentajes[, 1])){
    stop("No tienen las mismas categorias")
  }
  tabla.tot <- formato.tabla(totales)
  tabla.por <- formato.tabla(porcentajes)
  for(i in c(2:dim(tabla.tot)[2])){
    tabla.tot[, i] <- paste0(tabla.tot[, i], " (", tabla.por[, i], "%)")
  }
  return(tabla.tot)
}