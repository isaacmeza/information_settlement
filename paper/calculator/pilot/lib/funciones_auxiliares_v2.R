## Histograma para predicciones en conjunto de prueba estandarizado
# hist.pred <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
#   datos.prueba.estandarizados$pred <- predict(modelo, newdata = datos.prueba.estandarizados)
#   p <- qplot(pred, data = datos.prueba.estandarizados) + 
#     theme_bw() + 
#     ggtitle(nombre.modelo) + geom_density(aes(y=pred), colour="red", data=datos.prueba.estandarizados)
#   p
# }

y_hat <- function(modelo, nuevos.datos, nombre.modelo) {
  if ( grepl("_log", nombre.modelo) ){
    prediccion <- predict(modelo, newdata = nuevos.datos)
    prediccion <- exp(prediccion) - 1
  } else {
    prediccion <- predict(modelo, newdata = nuevos.datos)
  }
  prediccion
}

hist.pred <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
  if(!("pred" %in% names(datos.prueba.estandarizados))){
    datos.prueba.estandarizados$pred <- y_hat(modelo, datos.prueba.estandarizados, nombre.modelo)
  }
  p <- ggplot(data = datos.prueba.estandarizados, aes(x = pred)) + 
    geom_histogram(aes(y=..density..)) + 
    geom_density(aes(x = y), col = 'red') +
    ggtitle(nombre.modelo) + 
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.text.x = element_text(size = 2)) +
    theme(axis.text=element_text(size=6)) +
    theme(plot.title = element_text(lineheight=.5))
  p
}

## Predicciones vs. y
pred.v.y <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
  if(!("pred" %in% names(datos.prueba.estandarizados))){
    datos.prueba.estandarizados$pred <- y_hat(modelo, datos.prueba.estandarizados, nombre.modelo)
  }
  ggplot(datos.prueba.estandarizados, aes(x=pred, y=y, label=id)) + 
    geom_point(colour='red') + 
    #geom_abline(xintercept=0, slope=1) + 
    geom_text(colour='gray30', size=3,hjust=-0.4) + theme_bw() +
    ggtitle(nombre.modelo) + 
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.text.x = element_text(size = 2)) +
    theme(axis.text=element_text(size=6)) +
    theme(plot.title = element_text(lineheight=.5)) + theme(legend.position="none")
}  

bstrap <- function(x, B){
  x_rep <- sapply(1:B, function(i){
    sqrt(mean(sample(x, length(x), replace=T)))
  })
  #sd(x_rep)
  x_rep
}

boot.y.boot.pred <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
  if(!("pred" %in% names(datos.prueba.estandarizados))){
    datos.prueba.estandarizados$pred <- y_hat(modelo, datos.prueba.estandarizados, nombre.modelo)
  }
  predicciones <- bstrap(datos.prueba.estandarizados$pred, 1000)
  valores <- bstrap(datos.prueba.estandarizados$y, 1000)
  
  sims <- data.frame(
    variable = c(rep("y", length(valores)), rep("pred", length(predicciones))),
    medias = c(valores, predicciones)
  )
  
  p <- ggplot(sims, aes(x = medias, colour = variable)) + geom_density() + theme_bw() +
    ggtitle(nombre.modelo) + 
    geom_vline(aes(xintercept=mean(predicciones)), size=1, colour="red") + 
    geom_vline(aes(xintercept=mean(predicciones)-sd(predicciones)), linetype="dashed", size=1, colour="red") +
    geom_vline(aes(xintercept=mean(predicciones)+sd(predicciones)), linetype="dashed", size=1, colour="red") +
    geom_vline(aes(xintercept=mean(valores)), size=1, colour="cyan") + 
    geom_vline(aes(xintercept=mean(valores)-sd(valores)), linetype="dashed", size=1, colour="cyan") +
    geom_vline(aes(xintercept=mean(valores)+sd(valores)), linetype="dashed", size=1, colour="cyan") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.text.x = element_text(size = 2)) +
    theme(axis.text=element_text(size=6)) +
    theme(plot.title = element_text(lineheight=.5))
  p
}
## Histograma del error prueba en bootstrap
hist.error <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
  if(!("pred" %in% names(datos.prueba.estandarizados))){
    datos.prueba.estandarizados$pred <- y_hat(modelo, datos.prueba.estandarizados, nombre.modelo)
  }
  residual <- datos.prueba.estandarizados$y - datos.prueba.estandarizados$pred
  res_2 <- residual^2
  
  error.prediccion <- bstrap(res_2, 1000)
  p <- qplot(error.prediccion) +  
    geom_vline(aes(xintercept=mean(error.prediccion)), size=1, colour="red") + 
    geom_vline(aes(xintercept=mean(error.prediccion)-sd(error.prediccion)), linetype="dashed", size=1, colour="red") +
    geom_vline(aes(xintercept=mean(error.prediccion)+sd(error.prediccion)), linetype="dashed", size=1, colour="red") + theme_bw() + 
    ggtitle(nombre.modelo) + 
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.text.x = element_text(size = 2)) +
    theme(axis.text=element_text(size=6)) +
    theme(plot.title = element_text(lineheight=.5))
  p
}

error.prueba <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
  if(!("pred" %in% names(datos.prueba.estandarizados))){
    datos.prueba.estandarizados$pred <- y_hat(modelo, datos.prueba.estandarizados, nombre.modelo) 
  }
  residual <- datos.prueba.estandarizados$y - datos.prueba.estandarizados$pred
  res_2 <- residual^2
  sqrt(mean(res_2))
}



mape <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
  if(!("pred" %in% names(datos.prueba.estandarizados))){
    datos.prueba.estandarizados$pred <- y_hat(modelo, datos.prueba.estandarizados, nombre.modelo)
  }
  errores <- abs(datos.prueba.estandarizados$y - datos.prueba.estandarizados$pred)/datos.prueba.estandarizados$y
  mean(errores[!is.infinite(errores)], na.rm = T)
}

cor.fitted.y <- function(datos.prueba.estandarizados, modelo, nombre.modelo){
  if(!("pred" %in% names(datos.prueba.estandarizados))){
    datos.prueba.estandarizados$pred <- y_hat(modelo, datos.prueba.estandarizados, nombre.modelo)
  }
  cor(datos.prueba.estandarizados$y, datos.prueba.estandarizados$pred)
}


AIC2 <- function(modelo){
  x <- AIC(modelo)
  if(!is.numeric(x)){x <- NA}
  x
}
BIC2 <- function(modelo){
  x <- BIC(modelo)
  if(!is.numeric(x)){x <- NA}
  if(x >0)
  x
}
deviance2 <- function(modelo){
  x <- deviance(modelo)
  if(!is.numeric(x)){x <- NA}
  x
}


variable.name <- function(v1) {
  deparse(substitute(v1))
}

not.enough.data <- function(df){
  if(nrow(df) < 25) {
    NED <- F
    print("Not enough data!")
  } else {
    NED <- T
  }
  NED
}