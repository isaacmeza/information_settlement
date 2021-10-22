library(dplyr)
library(tidyr)
library(stargazer)
library(stringr)
library(broom)


df_seg = read.csv('../DB/scaleup_operation.csv') %>%
        setNames(nm = recode(names(.), 'a.o' = 'anio',
                             'expediente' = 'exp')) %>%
        mutate(p_actor = as.numeric(as.character(p_actor)))



## Take up table

format_strings = function(x){
  num = format(round(x*100, 2), digits = 2, nsmall = 2)
  ifelse(x == 0, '-', num)
}

take_up = df_seg %>% 
          filter(notificado==1) %>%
          mutate(t_Group = recode(tratamiento, `1` = 'Treatment', `0` = 'Control')) %>%
          filter(!(tratamiento == 0 & dummy_calculadora_partes == 1),
                 !(tratamiento == 0 & dummy_registro_partes == 1)) %>%
          group_by(t_Group) %>%
          summarise(t_Assignment = n(),
                    t_Plaintiff = sum(calcu_p_actora)/n(),
                    t_Defendant = sum(calcu_p_dem)/n(),
                    t_Both = sum(calcu_p_actora*calcu_p_dem)/n(),
                    t_Any = sum(pmax(calcu_p_actora,calcu_p_dem))/n(),
                    s_Plaintiff = sum(registro_p_actora)/n(),
                    s_Defendant = sum(registro_p_dem2)/n(),
                    s_Both = sum(registro_p_actora*registro_p_dem2)/n(),
                    s_Any = sum(pmax(registro_p_actora,registro_p_dem2))/n()) %>%
          mutate_at(vars(-t_Group, -t_Assignment), format_strings) %>%
          setNames(nm = str_sub(names(.), start = 3L))

stargazer(take_up, out = '../../Paper/Tables/Compliance_2.tex', header = F, summary = F, digits = 2, rownames = F)
