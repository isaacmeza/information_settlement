
# Variables a seleccionar
working_vars <- c('abogado_pub',
                  'reclutamiento',
                  'sueldo',
                  'gen',
                  'horas_sem',
                  'vac',
                  'ag',
                  'hextra', 
                  'rec20',
                  'prima_dom',
                  'desc_sem',
                  'desc_ob',
                  'top_despacho_ac',
                  'sarimssinf',
                  'utilidades',
                  'c_antiguedad',
                  'c_indem',
                  'c_total', 
                  'codem',
                  'grado_exag',
                  'prop_hextra',
                  'c_hextra',
                  'min_ley',
                  'prop_hextra',
                  'edad')

to_drop = c('junta',
            'giro_empresa',
            'tipo_jornada')

# Crear dummies con los rangos correspondientes
rangos = list(
  giro_empresa = c(11, 21, 22, 23, 31, 32, 33, 43, 46, 48, 49, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 93),
  junta = c(2, 7, 9, 11, 16),
  tipo_jornada = c(1, 2, 3, 4)
)


dummy_fullrange = function(data, varlist, range_list){
for (var in varlist){
for(level in range_list[[var]]){
    data[paste(var, level, sep = '_')] = if_else(data[[var]] == level, 1, 0)
}
}
return(data)
}

