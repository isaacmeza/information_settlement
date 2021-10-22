periodicidad_aux = function(per){
  recode(as.character(per), '0' = '1', '1' = '30', '2' = '15', '3' = '7') %>%
    as.numeric()
}



define_salario_base = function(base, integrado, estadistico){
  if_else(!is.na(base), base,
         if_else(!is.na(integrado), integrado, estadistico))
}



acota_fecha_inicial = function(fecha_inicial, fecha_entrada){
  if_else(fecha_inicial < fecha_entrada, fecha_entrada, fecha_inicial)
}



acota_fecha_final = function(fecha_final, fecha_salida){
  if_else(fecha_final > fecha_salida, fecha_salida, fecha_final)
}



aguinaldo_min = function(fecha_salida, salario, antiguedad){
  anio = year(fecha_salida)
  primero_enero = dmy(paste0('1-1-', anio))
  
  tiempo_aguinaldo = pmin(as.numeric(fecha_salida - primero_enero + 1)/365, antiguedad, na.rm = T)
  
  tiempo_aguinaldo * 15 * salario
}



aguinaldo = function(fecha_inicial, fecha_final, dias, monto, fecha_salida, antiguedad, salario){
  
  # Cantidad de aguinaldo pedida explícitamente con días o monto
  cantidad = if_else(is.na(monto), 0, monto)
  dias = if_else(is.na(dias), 0, dias*salario)
  
  # Antiguedad para calcular aguinaldo pedido con fechas
  antig = if_else(is.na(antiguedad), 0, antiguedad)
  
  # Buscamos el primero de enero del ultimo anio
  anio = year(fecha_salida)
  primero_enero = dmy(paste0('1-1-', anio))
  
  # Calculamos el tiempo que se debe de aguinaldo
  tiempo_pedido = as.numeric(fecha_final - fecha_inicial + 1)/365
  parte_prop = as.numeric(fecha_salida - primero_enero + 1)/365
  
  tiempo_aguinaldo = ifelse(is.na(tiempo_pedido), 
                            pmin(antig, parte_prop, na.rm = T), 
                            tiempo_pedido)
  
  tiempo = tiempo_aguinaldo * 15 * salario
  
  # Hacemos la cuantificación jerarquizando los tres tipos de aguinaldo
  if_else(cantidad > 0, cantidad, if_else(dias > 0, dias, tiempo))
}


# Días que corresponden de vacaciones según antigüedad
dias_vac = function(antig){
intervals = cut(antig, 
            breaks = c(0, 1, 2, 3, 4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69), 
            labels = c(6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38), right = F, 
            include.lowest = T)

days = if_else(antig > 69, '38', as.character(intervals))

as.numeric(as.character(days))
}


# Mínimo vacaciones
vacaciones_min = function(fecha_entrada, fecha_salida, salario, antiguedad){
  fecha_ultimoper = dmy(paste0(day(fecha_entrada), '-', month(fecha_entrada), '-', year(fecha_salida)))
  year(fecha_ultimoper) = if_else(fecha_ultimoper > fecha_salida, year(fecha_salida) - 1, year(fecha_salida))
  
  # Calculamos el número de periodos completos de vacaciones
  ultimo_per = trunc(antiguedad)
  
  # Calculamos la parte proporcional de vacaciones
  dias_ultimo = dias_vac(ultimo_per)
  tiempo_prop = as.numeric(fecha_salida - fecha_ultimoper)/365
  
  tiempo_prop*dias_ultimo*salario
}



# Cuantificación de vacaciones
vacaciones = function(fecha_inicial, fecha_final, fecha_entrada, fecha_salida, dias, monto, salario){
  
  # Calculamos vacaciones pedidas explícitamente
  cantidad = if_else(is.na(monto), 0, monto)
  dias = if_else(is.na(dias), 0, dias*salario)
  
  # Calculamos el número de periodos completos de vacaciones y sumamos los días acumulados
  periodos_completos = if_else(!is.na(fecha_entrada) & !is.na(fecha_salida),
                        trunc(as.numeric(fecha_salida - fecha_entrada + 1)/365), 
                        0)
  
  periodos_pedidos = if_else(!is.na(fecha_inicial) & !is.na(fecha_final),
                             as.numeric(fecha_final - fecha_inicial + 1)/365, 0)
  
  periodos_pagados = pmax(periodos_completos - periodos_pedidos, 0)
  
  dias_acumulados = 0
  i = periodos_pagados 
  
while(i < periodos_completos + 1){
    dias_periodo = dias_vac(i)
    dias_acumulados = dias_acumulados + dias_periodo
    i = i + 1 
    }
  
  vac_completos = dias_acumulados*salario
  
  # Calculamos la parte proporcional de vacaciones
  dias_ultimo = dias_vac(periodos_completos)

  fecha_ultimoper = dmy(paste0(day(fecha_entrada), '-', month(fecha_entrada), '-', year(fecha_salida)))
  year(fecha_ultimoper) = if_else(fecha_ultimoper > fecha_salida, year(fecha_salida) - 1, year(fecha_salida))
  tiempo_prop = as.numeric(fecha_salida - fecha_ultimoper)/365

  parte_proporcional = tiempo_prop*dias_ultimo*salario

  if_else(cantidad > 0, cantidad,
         if_else(dias > 0, dias, vac_completos + parte_proporcional))
}



prima_vacacional = function(fecha_entrada, fecha_salida, salario, monto_prima, monto_vac, c_vacaciones){
  cantidad = if_else(is.na(monto_prima), 0, monto_prima)
  cantidad_vacaciones = if_else(!is.na(monto_vac), monto_vac, 
                               if_else(!is.na(c_vacaciones), c_vacaciones*.25, 0))
  
  if_else(cantidad > 0, cantidad, cantidad_vacaciones)
}



jornada_semanal = function(jornada, per){
  per = recode(per, `3` = 1, `0` = 6)
  
  jornada*per
}


jornada_legal = function(tipo){
  recode(tipo, `1` = 48, `2` = 48, `3` = 45, `4` = 84)
}


horas_extras = function(fecha_entrada, fecha_salida, salario, tipo_jornada, horas_sem, horas_extra, num_semanas, monto, total_horas, per_horas){
  
  # Prioritario: la cantidad pedida explícitamente
  cantidad = if_else(is.na(monto), 0, monto)
  
  
  # Siguiente en importancia: horas totales que pide
  horas_sem = jornada_semanal(horas_sem, per_horas)
  legal = jornada_legal(tipo_jornada)
  
  salario_hora = if_else(is.na(legal), 0, salario*7/legal)
  total_horas = if_else(is.na(total_horas), 0, total_horas*salario_hora*2)
  num_semanas = if_else(!is.na(num_semanas),
                        as.double(num_semanas),
                        if_else(!is.na(fecha_entrada) & !is.na(fecha_salida), 
                        as.numeric(fecha_salida - fecha_entrada + 1)/7, 0))
  
  # Truncar a 6 anios
  num_semanas = if_else(num_semanas > 312, 312, num_semanas)
  
  # Dividir dobles y triples
  horas_extra_sem = if_else(is.na(horas_extra), 0, horas_extra)
  horas_dobles = min(9, horas_extra_sem)
  horas_triples = max(0, horas_extra_sem - 9)
  
  suma_horas = num_semanas*salario_hora*(2*horas_dobles + 3*horas_triples)
  
  # Siguiente caso: comparar con jornada legal
  extras_legal = max(horas_sem - legal, 0, na.rm = T)
  horas_dobles = min(9, extras_legal)
  horas_triples = max(0, extras_legal - 9)
  
  suma_horas_legal = num_semanas*salario_hora*(2*horas_dobles + 3*horas_triples)
  
  if_else(cantidad > 0, cantidad, 
          if_else(suma_horas > 0, suma_horas, suma_horas_legal))
}


descanso_semanal = function(fecha_entrada, fecha_salida, salario, monto){
  cantidad = if_else(is.na(monto), 0, monto)
  
  semanas = as.numeric((fecha_salida - fecha_entrada + 1))/7
  
  if_else(cantidad > 0, cantidad, semanas*salario*2)
}


prima_dominical = function(fecha_entrada, fecha_salida, salario, monto){
  cantidad = if_else(is.na(monto), 0, monto)
  
  semanas = as.numeric((fecha_salida - fecha_entrada + 1))/7
  
  if_else(cantidad > 0, cantidad, semanas*salario*0.25)
}


descanso_obligatorio = function(fecha_entrada, fecha_salida, salario, monto){
  cantidad = if_else(is.na(monto), 0, monto)
  
  anios = as.numeric((fecha_salida - fecha_entrada + 1))/365
  
  if_else(cantidad > 0, cantidad, anios*salario*2*7)
}


prima_antiguedad = function(fecha_entrada, fecha_salida, salario, monto){
  cantidad = if_else(is.na(monto), 0, monto)
  
  anios = as.numeric((fecha_salida - fecha_entrada + 1))/365
  salario_max = min(salario, 140)
  
  if_else(cantidad > 0, cantidad, anios*salario_max*12)
}

