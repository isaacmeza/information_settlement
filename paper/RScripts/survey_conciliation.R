library(readstata13)
library(dplyr)
library(stringr)
library(stargazer)

variables = c('Actor', 'Actor', 'Demandado', 'Representante del actor', 'Representante del demandado')
names(variables) = c('salida', 'actor', 'dem', 'rep_actor', 'rep_dem')

surveys = list.files('../Raw/', pattern = 'Append *', full.names = T) %>%
  lapply(read.dta13) %>%
  lapply(function(x) distinct(x, folio, .keep_all = T)) %>%
  setNames(., nm = c('salida', 'actor', 'dem', 'rep_actor', 'rep_dem'))

list2env(surveys, .GlobalEnv)



# Upload seguimiento

fix_exp = function(x){
  paste0('00', x) %>%
  str_sub(start = -4)
}


df = read.dta13('../DB/pilot_operation.dta') %>%
      mutate(expediente = fix_exp(expediente),
        folio = paste0(expediente, '-', anio))



# Employee

trunca = function(x, top = NULL, bottom = NULL){
  upper_bound = max(x, na.rm = T)
  lower_bound = min(x, na.rm = T)
  
  if(!is.null(top)){
    upper_bound = quantile(x, top, type = 4, na.rm = T)
  } 
  
  if(!is.null(bottom)){
    lower_bound = quantile(x, bottom, type = 4, na.rm = T)
  }
  
  num = pmax(pmin(x, upper_bound), lower_bound)
 
  return(num) 
}


actor_up = actor %>%
          left_join(df) %>%
          right_join(filter(salida, ES_1_1 == 'Actor')) %>%
          mutate_at(vars(A_5_5, ES_1_4, comp_esp), trunca, top = .99) %>%
          transmute(base = A_5_5,
                    exit = ES_1_4,
                    comp_esp = comp_esp,
                    theta = abs((exit - comp_esp)/(base - comp_esp)),
                    rel = (exit - base)/base,
                    parte = 'actor',
                    tratamientoquelestoco = tratamientoquelestoco,
                    gen = gen,
                    trabajador_base = trabajador_base,
                    c_antiguedad = c_antiguedad,
                    salario_diario = salario_diario,
                    horas_sem = horas_sem,
                    repeat_player = A_7_3,
                    educ = A_1_2,
                    mistreated = A_6_1)
        

# Employee Lawyer


ractor_up = rep_actor %>%
            left_join(df) %>%
            right_join(filter(salida, ES_1_1 == 'Representante del actor')) %>%
            mutate_at(vars(RA_5_5, ES_1_4, comp_esp), trunca, top = .99) %>%
            transmute(base = RA_5_5,
                      exit = ES_1_4,
                      comp_esp = comp_esp,
                      theta = abs((exit - comp_esp)/(base - comp_esp)),
                      rel = (exit - base)/base,
                      parte = 'ractor',
                      tratamientoquelestoco = tratamientoquelestoco,
                      gen = gen,
                      trabajador_base = trabajador_base,
                      c_antiguedad = c_antiguedad,
                      salario_diario = salario_diario,
                      horas_sem = horas_sem)


# Firm Lawyer


rdem_up = rep_dem %>%
  left_join(df) %>%
  right_join(filter(salida, ES_1_1 == 'Representante del demandado')) %>%
  mutate_at(vars(RD5_5, ES_1_4, comp_esp), trunca, top = .99) %>%
  transmute(base = RD5_5,
            exit = ES_1_4,
            comp_esp = comp_esp,
            theta = abs((exit - comp_esp)/(base - comp_esp)),
            rel = (exit - base)/base,
            parte = 'rdem',
            tratamientoquelestoco = tratamientoquelestoco,
            gen = gen,
            trabajador_base = trabajador_base,
            c_antiguedad = c_antiguedad,
            salario_diario = salario_diario,
            horas_sem = horas_sem)


# Join datasets

data = bind_rows(actor_up, ractor_up, rdem_up) %>% 
        filter(base > 0, exit > 0,
               tratamientoquelestoco %in% c('Control', 'Calculator', 'Conciliator')) %>%
        mutate(theta1 = (abs(base - comp_esp) - abs(exit - comp_esp))/comp_esp,
               theta2 = (abs(base - comp_esp) - abs(exit - comp_esp))/(base - comp_esp)) %>%
        mutate_at(vars(starts_with('theta')), replace_inf) %>%
        mutate_at(vars(starts_with('theta')), trunca, top = .95, bottom = .05)


