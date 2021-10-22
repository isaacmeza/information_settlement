source('00_setup.R')
source('toolbox.R')

# Cargamos ambas bases: dfp para el piloto, dfs para el scale-up
# Seleccionamos variables que nos interesan
# Imputamos ceros a NAs en variables de terminación 
dfp <- read_excel('../Raw/pilot_operation.xlsx',
                  skip = 2, sheet = 'BASE SEGUIMIENTO') %>%
        setNames(., limpia_nombres(names(.))) %>% 
        select(fecha_lista:itt, 
               starts_with('p_'), 
               starts_with('e_'),
               tratamiento_que_les_toco:cantidad_de_desistimiento,
               -capturista, -observaciones)  %>%
        filter(itt == 'SI', tratamiento_que_les_toco %in% c(1,2)) %>%
        mutate_at(vars(p_actor:cantidad_de_desistimiento), na_fix)

dfs <- readRDS('../DB/scaleup_operation.RDS') 

# Resolver casos de múltiples actores, al unirlos con las iniciales

# Scale-up Employee present: unión de registro_actor y p_actor 
# Drop fichas y variables de encuestas
# Scale-up E_actor ~ dummy de alguna pregunta no-vacía
# Scale-up Presencia de las partes: generar dummies a partir de contadores

dfs <- dfs %>% 
  mutate(p_actor = p_actor>0 | registro_actor>0) %>%
  select(-starts_with('ficha'),
         -starts_with('ea'),
         -starts_with('ed'),
         -starts_with('era'),
         -starts_with('erd')) %>%
  mutate_at(vars(starts_with('p_')), contador_a_dummy) %>%
  mutate(piloto_1 = 0, 
         horario_aud = limpia_horario_scaleup(horario_aud))

# Pilot data
# Pilot registro_p_actora ~ E_Actor + E_R.Actor > 0. Esto es análogo para demandados
# Pilot calcu_p_* ~ tratamiento que les tocó*se llevó tratamiento
# Crear updates

dfp <- dfp %>% 
  mutate(registro_p_actora = as.numeric((e_actor + e_ractor) > 0),
         registro_p_dem = as.numeric((e_demandado + e_rdemandado) > 0),
         dummy_calculadora_partes = (tratamiento_que_les_toco == 2)*(se_llevo_tratamiento == 1),
          notificado = ifelse(itt == '1', 1, 0),
         tratamiento = ifelse(tratamiento_que_les_toco == 2, 1, 0),
         conciliadores = 'AGUSTIN;MARGARITA',
         junta = '7',
         piloto_1 = 1,
         horario_audiencia = limpia_horario_pilot(horario_audiencia),
         calcu_p_actora = 1,
         calcu_p_dem = 1) %>%
  decode_names_df()
  
# Pilot crear dummies de junta y de conciliadores

nombres_conciliadores <- c('MARIBEL', 'ISAAC', 
                           'ANA', 'MARINA', 
                           'AGUSTIN', 'MARGARITA', 
                           'HIGUERA', 'CORRAL',
                           'DEYANIRA', 'DOCTOR',
                           'CESAR', 'LUPITA',
                           'KARINA')

for(name in nombres_conciliadores){
  dfp[paste("conciliador", tolower(name), sep = "_")] <- ifelse(grepl(name, 
                                                                         dfp$conciliadores), 1, 0)
}

juntas <- c('2', '7', '9', '11', '16')

for(jun in juntas){
  dfp[paste("junta", jun, sep = "_")] <- ifelse(dfp$junta == jun, 1, 0)
}

dfp$num_conciliadores <- dfp %>% select(starts_with('conciliador_')) %>% rowSums()

dfp_selected <- dfp %>% 
  select(one_of(joint_vars))

dfs_selected <- dfs %>%
  select(one_of(joint_vars))

df <- rbind(dfp_selected, dfs_selected)

# Pendientes: 
# Meter iniciales y encuestas
# Sumar conciliadores activos en ese horario y hacer medida de busyness del conciliador
# *Recordar: ¿clustering de SEs?

#Guardamos en RDS

saveRDS(df, '../DB/seguimiento_joint.RDS')
saveRDS(dfp, '../DB/seguimiento_pilot.RDS')

# Guardamos en csv

write.csv(df, '../DB/seguimiento_joint.csv', na = '')
write.csv(dfp, '../DB/seguimiento_pilot.csv', na = '')

