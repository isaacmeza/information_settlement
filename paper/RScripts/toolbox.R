contador_a_dummy <- function(x){
  as.numeric(x>0)
}

limpia_nombres <- function(name){
  name %>%
    tolower() %>%
    gsub('ó', 'o', .) %>%
    gsub(' ', '_', .) %>%
    gsub('[^A-Za-z0-9_]', '', .)
}

na_fix <- function(x){
  x[is.na(x)] <- 0
  x
}

nombres_pilot <- list('p_demandado' = 'p_dem',
                     'p_rdemandado' = 'p_rdem',
                     'cantidad_de_convenio' = 'cantidad_convenio',
                     'cantidad_de_desistimiento' = 'cantidad_desistimiento',
                     'se_concilio' = 'convenio',
                     'se_desistio' = 'desistimiento',
                     'horario_audiencia' = 'horario_aud')

get_name <- function(x){
  ifelse(is.null(nombres_pilot[[x]]),
                 x, nombres_pilot[[x]])
}

name_decode <- function(variable) {
  sapply(variable, get_name) %>% 
    unname()
}

decode_names_df <- function(df){
  names(df) <- name_decode(names(df))
  df
}

limpia_horario_pilot <- function(x){
  as.character(x) %>%
    gsub('1899-12-30 ', '', .) %>%
    str_sub(., end = -4)
}

limpia_horario_scaleup <- function(x){
  as.character(x) %>%
    paste0('0', .) %>%
    str_sub(., start = -5)
}

joint_vars <- c('junta',
                'expediente',
                'anio',
                'fecha_lista',
                'horario_aud',
                'p_actor',
                'p_ractor',
                'p_dem',
                'p_rdem',
                'convenio',
                'desistimiento',
                'notificado',
                'tratamiento', 
                'num_conciliadores',
                'junta_2',
                'junta_7',
                'junta_9', 
                'junta_11',
                'junta_16',
                'dummy_calculadora_partes',
                'piloto_1',
                'calcu_p_actora', 
                'calcu_p_dem'
)

