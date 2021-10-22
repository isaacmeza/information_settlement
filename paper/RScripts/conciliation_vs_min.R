source('survey_oc.R')


# Do subjects conciliate for more or less?

df_p = actor %>%
  left_join(df) %>%
  filter(tratamientoquelestoco != 'Not in experiment',
         A_5_9 < quantile(A_5_9, .95, type = 4, na.rm = T),
         A_5_9 > 0) %>%
  mutate(conc_vs_min = c1_cantidad_total_pagada_conveni - A_5_9,
         conc_menos = conc_vs_min < 0,
         tratamientoquelestoco = as.character(tratamientoquelestoco),
         conc_vs_min = trunca(conc_vs_min)) %>%
  group_by(tratamientoquelestoco) %>%
  summarise_at(vars(conc_vs_min, conc_menos), funs(mean, sd), na.rm = T) %>%
  arrange(-conc_vs_min_mean) %>%
  select(tratamientoquelestoco, conc_vs_min_mean, conc_vs_min_sd, conc_menos_mean, conc_menos_sd) %>%
  setNames(., nm = c('Group', 'Mean', 'SD', 'Mean', 'SD'))


stargazer(df_p, out = '../Tables/conc_amount_stats.tex', summary = F, float = F, rownames = F)