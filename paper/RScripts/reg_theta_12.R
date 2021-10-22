library(lmtest)
library(sandwich)

source('survey_oc.R')

oc = T
uc = F

reg_path = '../Tables/reg_update_theta12.tex'

if(oc){
  data = data %>%
    filter(base > comp_esp)
  
  reg_path = '../Tables/reg_update_theta12_oc.tex'
}

if(uc){
  data = data %>%
    filter(base < comp_esp)
  
  reg_path = '../Tables/reg_update_theta12_uc.tex'
}

data %>%
  filter(parte == 'actor') %>%
  lm(theta1 ~ tratamientoquelestoco + gen + trabajador_base + c_antiguedad + salario_diario + horas_sem + educ + mistreated + repeat_player, data = .) -> t1_emp


data %>%
  filter(parte == 'actor') %>%
  lm(theta2 ~ tratamientoquelestoco + gen + trabajador_base + c_antiguedad + salario_diario + horas_sem + educ + mistreated + repeat_player, data = .) -> t2_emp


# Employee lawyer

data %>%
  filter(parte == 'ractor') %>%
  lm(theta1 ~ tratamientoquelestoco + gen + trabajador_base + c_antiguedad + salario_diario + horas_sem, data = .) -> t1_el


data %>%
  filter(parte == 'ractor') %>%
  lm(theta2 ~ tratamientoquelestoco + gen + trabajador_base + c_antiguedad + salario_diario + horas_sem, data = .) -> t2_el


# Firm lawyer


data %>%
  filter(parte == 'rdem') %>%
  lm(theta1 ~ tratamientoquelestoco + gen + trabajador_base + c_antiguedad + salario_diario + horas_sem, data = .) -> t1_fl


data %>%
  filter(parte == 'rdem') %>%
  lm(theta2 ~ tratamientoquelestoco + gen + trabajador_base + c_antiguedad + salario_diario + horas_sem, data = .) -> t2_fl

robust_se = function(obj, varlist){
  se = sqrt(diag(vcovHC(obj, type = "HC1")))
  se[varlist]
}

model_se = list(t1_emp, t1_el, t1_fl, t2_emp, t2_el, t2_fl) %>%
  lapply(robust_se, varlist = c('(Intercept)', 'tratamientoquelestocoCalculator', 'tratamientoquelestocoConciliator'))

  stargazer(list(t1_emp, t1_el, t1_fl, t2_emp, t2_el, t2_fl),
            out = reg_path,
            keep = c('Constant', 'tratamientoquelestoco'),
            covariate.labels = c('Control', 'Calculator', 'Conciliator'),
            column.labels = c('Theta 1', 'Theta 2'),
            column.separate = c(3, 3),
            intercept.bottom = F,
            digits = 2,
            float = F,
            se = model_se,
            add.lines = list(c('Basic Variable Controls', rep('YES', 6)),
                               c('Other Controls', rep(c('YES', 'NO', 'NO'), 2))))
