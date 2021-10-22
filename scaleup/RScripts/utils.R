limpia_fechas <- function(date){
  fecha <- as.Date(as.numeric(date), origin="1899-12-30")
  fecha[grepl("\\/", date)] <- dmy(date[grepl("\\/", date)])
  fecha
}


genera_dummy <- function(fecha1, fecha2, cuantif){
  if (is.na(as.numeric(cuantif))){
    if(!is.na(limpia_fechas(fecha1)) | !is.na(limpia_fechas(fecha2))){
      dummy <- T 
    } else if (grepl("MENC", fecha1)){
      dummy <- F
    } else if (grepl("ESPE", fecha1)){
      dummy <- 1
    } else {
      dummy <- NA
    }
  } else {
    dummy <- as.numeric(cuantif)>0
  }
  as.factor(as.numeric(dummy))
  
}

  
limpia_dummy = function(var){
  replace(var, var!=0 & var!=1, NA)
}


limpia_montos <- function(var){
 c = as.numeric(as.character(var)) 
 c = replace(c, c<0, NA)
 return(c)
}

limpia_categorica = function(x, validos){
  validos = as.character(validos)
  ifelse(x %in% validos, as.numeric(x), NA)
}
