source('survey_oc.R')


###############################################

# Compute betas

##############################################

aux_decode = function(x){
  as.numeric(grepl('MAÑANA', x))
}


discount_factor = function(sum){
  
  if_else(sum == 0, 1,
          if_else(sum == 1, 10/12,
                  if_else(sum == 2, 2/3,
                          if_else(sum == 3, 0.5, 1/3))))
}


# Employee

df_beta = actor %>%
  filter(A_5_9 > 100) %>%
  mutate_at(vars(A_5_9, A_5_5, A_5_8), trunca, top = .95, bottom = 0.05) %>%
  mutate(A_5_1 = A_5_1/100,
         beta = exp((log(A_5_9)-(log(A_5_5)+log(A_5_1)))/A_5_8),
         beta = replace_inf(beta)) %>%
  mutate_at(vars(starts_with('A_10_2')), aux_decode) %>%
  mutate(aux_sum = A_10_2_1 + A_10_2_2 + A_10_2_3 + A_10_2_4 + A_10_2_5,
         beta_survey = discount_factor(aux_sum),
         more_survey = beta_survey > beta,
         beta_weird = beta>1,
         beta = beta^(1/12), 
         parte = 'Employee') %>%
        filter(beta < 2) %>%
  select(beta, beta_survey, parte, folio)



# Employee Lawyer

df_beta_ra = rep_actor %>%
  mutate_at(vars(A_5_9, A_5_3, A_5_8), trunca, top = .95, bottom = 0.01) %>%
  mutate(A_5_1 = A_5_1/100,
         beta = exp((log(A_5_9)-(log(A_5_5)+log(A_5_1)))/A_5_8),
         beta = replace_inf(beta)) %>%
  mutate_at(vars(starts_with('RA_6_2_')), aux_decode) %>% 
  mutate(aux_sum = RA_6_2_1 + RA_6_2_2 + RA_6_2_3 + RA_6_2_4 + RA_6_2_5,
         beta_survey = discount_factor(aux_sum),
         equipo_dem = if_else(grepl('empleado|negocios', RA_1_3), 'Defendants', 
                              if_else(grepl('trabajadores', RA_1_3), 'Plaintiffs', 'Both')),
         beta = beta^(1/12),
         parte = 'Employee Lawyer') %>%
  select(beta, beta_survey, equipo_dem, parte, folio)


# Firm lawyer 

df_beta_rd = rep_dem %>%
  mutate_at(vars(A_5_9, A_5_3, A_5_8), trunca, top = .95, bottom = 0.01) %>%
  mutate(beta = exp((log(A_5_9)-(log(A_5_5)+log(A_5_1)))/A_5_8),
         beta = replace_inf(beta)) %>%
  mutate_at(vars(starts_with('RD6_2_')), aux_decode) %>% 
  mutate(aux_sum = RD6_2_1 + RD6_2_2 + RD6_2_3 + RD6_2_4 + RD6_2_5,
         beta_survey = discount_factor(aux_sum),
         equipo_dem = if_else(grepl('empleado|negocios', RD1_3), 'Defendants', 
                              if_else(grepl('trabajadores', RD1_3), 'Plaintiffs', 'Both')),
         beta = beta^(1/12),
         parte = 'Firm Lawyer') %>%
  select(beta, beta_survey, equipo_dem, parte, folio)


beta_df = bind_rows(df_beta, df_beta_ra, df_beta_rd)

# Correlations

beta_df %>%
  group_by(parte) %>%
  select(-equipo_dem) %>%
  na.omit() %>%
  summarize(Correlation = format_strings(cor(beta, beta_survey), multiply = F)) %>%
  stargazer(out = '../Tables/cor_betas.tex', summary = F, float = F)


beta_df %>%
  left_join(df) %>%
  select(beta, beta_survey, salario_diario, cantidaddeconvenio) %>%
  na.omit() %>%
  summarize(imp_salario = cor(beta, salario_diario),
             exp_salario = cor(beta_survey, salario_diario),
             imp_cantidad = cor(beta, cantidaddeconvenio),
             exp_cantidad = cor(beta_survey, cantidaddeconvenio)) %>%
  gather(var, Correlation) %>%
  stargazer(out = '../Tables/cor_betas_covariates.tex', summary = F, float = F)
  

# Beta density comparison (Plaintiff)
df_beta %>%
  select(beta, beta_survey) %>%
  gather(var, value) %>%
  ggplot() +
  geom_density(aes(value, y = ..scaled.., color = var), size = 1.2) +
  scale_color_manual(values = c('steelblue4', 'tomato4'), 
                     name = 'Variable',
                     breaks = c('beta', 'beta_survey'),
                     labels = c('Estimation', 'Survey')) +
  labs(x = '', y = '') +
  scale_y_continuous(labels = scales::percent) +
  theme_classic()


ggsave('../Figuras/beta_comparison.tiff', width = 10, height = 8)

# Implicit beta, by type of subject

beta_df %>%
  filter(beta < 2) %>%
  ggplot(group = parte) +
  geom_histogram(aes(beta, y = ..count../tapply(..count..,..PANEL..,sum)[..PANEL..])) +
  labs(x = 'Beta', y = '') +
  xlim(0.75, 1.25) +
  scale_y_continuous(labels=scales::percent_format(), breaks = c(0.25, 0.5))+
  facet_grid(parte ~ ., drop = T) +
  theme_minimal() +
  theme(strip.text.y = element_text(angle = 0)) 


ggsave('../Figuras/beta_est_histogram.tiff', height = 5, width = 5)


format_strings = function(x){
  x_1 = as.numeric(x)
  num = format(round(x_1, 2), digits = 2, nsmall = 2)
  ifelse(is.na(x_1), '-', num)
}

expand_factor = function(df, var, new_name = NULL){
  newdata = df
  categories = unique(newdata[[var]])
  base = if_else(is.null(new_name), var, new_name)
  
  for(x in categories){
    newdata[paste0(base, '_', x)] <- if_else(newdata[[var]] == x, 1, 0)
  }
  
  newdata
}

num = function(x, na.rm = T){length(x[x==1])}


# Explicit beta, by type of subject


beta_df_tp = beta_df %>%
              expand_factor('beta_survey', 'bs') %>%
              group_by(parte) %>%
              summarize_at(vars(starts_with('bs_')), funs(mean, sd, num), na.rm = T) %>%
              gather(stat, value, -parte) %>%
              mutate(beta = gsub('bs_(.*)_[a-z]+', '\\1', stat),
                     beta = format_strings(beta),
                     stat = gsub('bs_.*_([a-z]+)', '\\1', stat)) %>%
              spread(stat, value) %>%
              group_by(parte) %>%
              mutate(n = sum(num)) %>%
              ungroup() %>%
              mutate(se = sd/sqrt(n),
                     tstat = qt(0.95, n-1))



beta_df_tp %>%
  ggplot() +
  geom_bar(aes(beta, mean), stat = 'identity') +
  labs(x = 'Beta', y = '') +
  geom_errorbar(aes(beta, ymin = mean-tstat*se, ymax = mean+tstat*se), 
                position = position_dodge(0.1), width = .15) +
  scale_y_continuous(labels = scales::percent_format()) +
  facet_grid(.~parte, drop = T) +
  theme_minimal()


ggsave('../Figuras/beta_survey_histogram.tiff', height = 5, width = 5)




## Dividing by parts they represent

lawyers = bind_rows(df_beta_ra, df_beta_rd) %>%
  filter(beta < 2) %>%
  mutate(equipo_dem_f = factor(equipo_dem, levels = c('Plaintiffs', 'Defendants', 'Both'), 
                               labels = c('Plaintiffs', 'Defendants', 'Both')))

# Implicit beta

lawyers %>%
  ggplot(group = equipo_dem_f) +
  geom_histogram(aes(beta, y = ..count../tapply(..count..,..PANEL..,sum)[..PANEL..])) +
  labs(x = 'Beta', y = '') +
  xlim(0.75, 1.25) +
  scale_y_continuous(labels = scales::percent_format(), breaks = c(0.2, 0.4)) +
  facet_grid(.~equipo_dem_f ~ ., drop = T) +
  theme_minimal() +
  theme(strip.text.y = element_text(angle = 0)) 

ggsave('../Figuras/beta_est_byteam.tiff', height = 5, width = 5)


# Explicit beta

lawyers_tp = lawyers %>%
  expand_factor('beta_survey', 'bs') %>%
  group_by(equipo_dem_f) %>%
  summarize_at(vars(starts_with('bs_')), funs(mean, sd, num), na.rm = T) %>%
  gather(stat, value, -equipo_dem_f) %>%
  mutate(beta = gsub('bs_(.*)_[a-z]+', '\\1', stat),
         beta = format_strings(beta),
         stat = gsub('bs_.*_([a-z]+)', '\\1', stat)) %>%
  spread(stat, value) %>%
  group_by(equipo_dem_f) %>%
  mutate(n = sum(num)) %>%
  ungroup() %>%
  mutate(se = sd/sqrt(n),
         tstat = qt(0.95, n-1))


lawyers_tp %>%
  ggplot() +
  geom_bar(aes(beta, mean), stat = 'identity') +
  labs(x = 'Beta', y = '') +
  geom_errorbar(aes(beta, ymin = mean-(se*tstat), ymax = mean+(se*tstat)), 
                position = position_dodge(0.1), width = .15) +
  scale_y_continuous(labels = scales::percent_format()) +
  facet_grid(.~equipo_dem_f, drop = T) +
  theme_minimal()

ggsave('../Figuras/beta_survey_byteam.tiff', height = 5, width = 5)




df_beta %>% 
  select(folio, beta_survey) %>%
  left_join(rename(df_beta_ra, beta_survey_ra = beta_survey)) %>%
  mutate(up = beta_survey > beta_survey_ra,
         down = beta_survey < beta_survey_ra,
         same = beta_survey == beta_survey_ra) %>% 
  summarize_at(vars(up, down, same), mean, na.rm = T)
