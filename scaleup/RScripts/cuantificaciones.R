library(dplyr)
library(lubridate)
library(tidyr)
library(readxl)

source('aux_cuantificaciones.R')

df_cuant = df %>%
          mutate_at(vars(contains('salario'), sueldo), as.numeric) %>%
          mutate_at(vars(per_salario_base, per_salario_int), periodicidad_aux) %>%
          mutate(salario_base_diario = salario_base/per_salario_base,
                 salario_int_diario = salario_int/per_salario_int,
                 c_salario = define_salario_base(salario_base_diario,
                                                   salario_int_diario,
                                                   sueldo)) %>%
          filter(!is.na(c_salario)) %>%
          mutate_at(vars(contains('inic')), acota_fecha_inicial, fecha_entrada = .[['fecha_entrada']]) %>%
          mutate_at(vars(contains('fin')), acota_fecha_final, fecha_salida = .[['fecha_salida']]) %>%
          mutate_at(vars(contains('monto'), contains('dias'), hextra_sem), as.numeric) %>%
          mutate(min_aguinaldo = aguinaldo_min(fecha_salida, c_salario, antiguedad),
                  c_aguinaldo = aguinaldo(fecha_inicial = fecha_inic_ag, 
                                          fecha_final = fecha_fin_ag, 
                                          dias = dias_ag, 
                                          monto = monto_ag, 
                                          fecha_salida = fecha_salida, 
                                          antiguedad = antig, 
                                          salario = c_salario),
                 min_vac = vacaciones_min(fecha_salida, fecha_entrada, c_salario, antiguedad),
                 c_vacaciones = vacaciones(fecha_inic_vac, fecha_fin_vac, 
                                           fecha_entrada, fecha_salida, 
                                           dias_vac, monto_vac, c_salario),
                 c_primavac = prima_vacacional(fecha_entrada, fecha_salida, 
                                               c_salario, monto_prima_vac, monto_vac, c_vacaciones),
                 min_primavac = min_vac*0.25,
                 c_hextra = horas_extras(fecha_entrada = fecha_entrada,
                                         fecha_salida = fecha_salida,
                                         salario = c_salario,
                                         tipo_jornada = tipo_jornada,
                                         horas_sem = horas_sem,
                                         horas_extra = hextra_sem,
                                         num_semanas = hextra_total_sem,
                                         monto = monto_hextra_total,
                                         total_horas = hextra_total, 
                                         per_horas = per_horas)*-1,
                 c_indem = c_salario*90,
                 c_descanso_semanal = descanso_semanal(fecha_entrada, fecha_salida,
                                                       c_salario, monto_desc_sem),
                 c_descanso_obligatorio = descanso_obligatorio(fecha_entrada, fecha_salida,
                                                               c_salario, monto_desc_ob),
                 c_prima_antig = prima_antiguedad(fecha_entrada, fecha_salida,
                                                  c_salario, monto_prima_antig),
                 c_primadom = prima_dominical(fecha_entrada, fecha_salida,
                                              c_salario, monto_prima_dom),
                 )


write.csv(df_cuant, '../DB/scaleup_paired_courts.csv')
saveRDS(df_cuant, '../DB/scaleup_paired_courts.RDS')
