hack_horas = function(horas, per){
  ifelse(per == 0, 6*horas,
         ifelse(per == 1, 0.25*horas,
                ifelse(per == 2, 0.5*horas,
                       ifelse(per == 3, horas, NA))))
}

aux_factor = function(x){as.numeric(as.character(x))}