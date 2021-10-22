library(dplyr)
library(stargazer)
library(tidyr)
library(cobalt)
library(stringr)

df_seg <- readRDS('../DB/scaleup_operation.RDS') %>%
      dplyr::rename(exp = expediente,
             anio = a.o) %>%
      mutate(id_exp = paste(junta, exp, anio, sep = '_')) %>%
      dplyr::select(-junta, -exp, -anio, -observaciones)

df <- readRDS('../DB/scaleup_casefiles.RDS') %>%
      mutate(id_exp =  paste(junta, exp, anio, sep = '_')) %>%
      dplyr::select(-junta, -exp, -anio, -observaciones, -num_actores)

df <- left_join(df_seg, df)

rm(df_seg, dems_imss)

survey_actor_exp <- df %>%
  dplyr::select(ea1_prob_pago, ea2_cantidad_pago, 
         ea8_prob_pago_s, ea9_cantidad_pago_s) %>% data.frame()

stargazer(survey_actor_exp, header = F, colnames = F, 
          column.labels = c('Variable', 'N.Obs', 'Mean', 'Std. Dev.', 'Min', 'Max'),
          covariate.labels = c('Payment prob. (baseline)',
                               'Payment amount (baseline)',
                               'Payment prob. (exit)',
                               'Payment amount (exit)'), out = '../Effect/expectation_stats.tex')

# survey_actor_enojo <- df %>%
#   group_by(ea3_enojo) %>%
#   dplyr::summarise(freq = n()) %>% 
#   filter(ea3_enojo != '') %>%
#   data.frame()
# 
# survey_actor_enojo$ea3_enojo <- c('Very angry',
#                                   'Angry',
#                                   'A bit angry',
#                                   'Not angry')
# names(survey_actor_enojo) <- c('Anger vs. firm', 'Frequency')
# 
# stargazer(survey_actor_enojo, header = F,
#           summary = F, rownames = F,
#           out = 'anger_stats.tex')

# survey_actor_dummies <- df %>%
#   select(ea4_compra, ea6_trabaja, ea7_busca_trabajo) %>%
#   gather(key = var, value = value) %>%
#   group_by(var) %>%
#   dplyr::summarise(Yes = sum(value, na.rm = T),
#                    No = sum(!value, na.rm = T)) %>%
#   data.frame()
# 
# survey_actor_dummies$var <- c('Bought durable goods recently',
#                               'Working at the time',
#                               'Looking for a job at the time')
# 
# names(survey_actor_dummies)[1] <- 'Question'
# 
# stargazer(survey_actor_dummies, header = F,
#           summary = F, rownames = F,
#           out = 'survey_dummy_stats.tex')


mifun <- function(x){as.numeric(as.character(x))}

admin_info_control <- df %>%
  filter(no_encuestado == 0) %>%
  dplyr::select(sueldo, c_antiguedad, abogado_pub, gen, 
         ea4_compra, ea6_trabaja, ea7_busca_trabajo) %>%
  mutate_at(vars(gen, abogado_pub), mifun) %>%
  gather(key = var, value = value) %>%
  group_by(var) %>%
  dplyr::summarise(nobs = sum(!is.na(value)),
                  mean = mean(value, na.rm = T),
                   sd = sd(value, na.rm = T)) %>%
  filter(!is.na(var)) 

admin_info_treat <- df %>%
  filter(no_encuestado == 1) %>%
  dplyr::select(sueldo, c_antiguedad, abogado_pub, gen, 
                ea4_compra, ea6_trabaja, ea7_busca_trabajo) %>%
  mutate_at(vars(gen, abogado_pub), mifun) %>%
  gather(key = var, value = value) %>%
  group_by(var) %>%
  dplyr::summarise(nobs = sum(!is.na(value)),
                   mean = mean(value, na.rm = T),
                   sd = sd(value, na.rm = T)) %>%
  filter(!is.na(var)) 

names(admin_info_treat) <- paste(names(admin_info_treat), '_treat')

admin_info <- cbind(admin_info_control, admin_info_treat)

df_balance <- df %>% dplyr::select(sueldo, c_antiguedad, abogado_pub, gen, 
                     ea4_compra, ea6_trabaja, ea7_busca_trabajo, no_encuestado) %>% 
  mutate_at(vars(gen, abogado_pub), mifun)

test <- function(exp_var, dep_var){
  x <- df_balance %>% select_(exp_var) %>% unlist()
  y <- df_balance %>% select_(dep_var) %>% unlist()
  t <- t.test(x ~ y)
  t$statistic
}

tests <- sapply(names(df_balance)[-8], test, dep_var = 'no_encuestado') 
tests[5:7] <- NA

tests_data <- data.frame(var = names(tests), t_test = tests) %>%
              mutate(var = str_sub(var, end = -3))

admin_info <- left_join(admin_info, tests_data) %>%
              dplyr::select(var,
                     starts_with('nobs'),
                     starts_with('mean'),
                     t_test,
                     starts_with('sd')) %>%
              arrange(-t_test)

admin_info$var <- c('Wage', 'Female', 'Public Lawyer', 'Tenure', 'Bought durable goods recently',
                    'Working at the time',
                    'Looking for a job')

names(admin_info) <- c('Statistic', 'Treatment', 'Control',
                       'Treatment', 'Control',
                       't-stat', 'Treatment', 'Control')



stargazer(admin_info, header = F, colnames = T, rownames = F,
          summary = F, out = '../Effect/admin_stats.tex')