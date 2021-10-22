library(dplyr)
library(readxl)
library(ggplot2)
library(ggsignif)
library(broom)
library(data.table)

df = read_excel('../Raw/hd_sample_quantified.xlsx', sheet = 'BASE CAPTURISTA', skip = 4)

dems_imss = select(df, id_actor, starts_with("nombre_d"), -nombre_despido) %>%
  gather(dem, nombre, -id_actor) %>%
  mutate(codem_imss = grepl("IMSS", nombre) | (grepl("INSTITUTO", nombre) &
                                                 (grepl("SEGURO", nombre) | grepl("FONDO", nombre))) |
           grepl("INFONAVIT", nombre)) %>%
  group_by(id_actor) %>%
  summarise(codem = sum(codem_imss)) %>%
  mutate(dummy_codem = ifelse(codem>0, 1,0)) %>%
  select(-codem)

df = left_join(df, dems_imss)
      
rm(dems_imss)

df = df %>%
      mutate(abogado_pub = ifelse(tipo_abogado_ac == '3', 1, 0))

source('multiplot.R')

factores <- c('gen',
              'codem',
              'reinst',
              'indem',
              'trabajador_base',
              'sarimssinf',
              'abogado_pub', 
              'terminado_3a')

factores_fun <- function(x){as.factor(as.character(x))}
log_fun <- function(x){log(1 + (as.numeric(x)))}

setnames(df, old = names(df), new = gsub('dummy_', '', names(df)))

df = df %>%
      select(sueldo, gen, c_antiguedad, codem, horas_sem, c_indem, c_rec20, c_hextra, reinst, indem, trabajador_base, sarimssinf, abogado_pub, terminado_3a)

continuas <- names(df)[!(names(df) %in% factores)]

df <- df %>%
  mutate_at(vars(one_of(factores)), factores_fun) %>%
  mutate_at(vars(one_of(continuas)), log_fun)


pilot = df %>% filter(terminado_3a == '0')
hd = df %>% filter(terminado_3a == '1')

plot_titles_cont <- c('Wage', 'Tenure', 'Weekly hours', 'Severance Pay', '20 days', 'Overtime')


plot_covariates_cont <- function(var, plot_title){
  x = pilot[[var]]
  y = hd[[var]]
  m = ks.test(x, y)
  p = format(m$p.value, digits = 3)
  
  ggplot(df, aes_string(var, color = 'terminado_3a', linetype = 'terminado_3a')) +
    geom_density(aes(y = ..scaled..), size = 1) + 
    scale_y_continuous(labels = scales::percent_format()) +
    labs(title = plot_title, x = '', y = 'Percent',
         subtitle = bquote(P-value==.(p))) +
    scale_colour_manual(values = c('gray77', 'gray43'), 
                        name = '') +
    guides(color = F, linetype = F) +
    theme_classic()
}


tiff(file = "../Figuras/covariates_hdsample_continous.tiff", width = 885, height = 564, units = "px", res = 100) 

plot_list = lapply(1:6, function(i) plot_covariates_cont(continuas[i], plot_titles_cont[i]))

multiplot(plotlist = plot_list, cols = 2)

dev.off()

# ggsave('../Figuras/covariates_continous.png')

###################

# Categóricas

##################

aux_factor <- function(x){as.numeric(as.character(x))}
aux_nas <- function(x){
  x[is.na(x)] <- '0'
  x
}

cat = df %>%
  select(one_of(factores)) %>%
  filter(!is.na(terminado_3a)) %>%
  # mutate_all(aux_nas) %>% 
  gather(key = var, value = valor, -terminado_3a) %>% 
  mutate(valor = aux_factor(valor))

pvals = cat %>%
  group_by(var) %>% do(tidy(t.test(valor ~ terminado_3a, data = .)))


sign.stars <- function(p.value) {
  ifelse(p.value <= 0.001, '***',
         ifelse(p.value <= 0.01, ' **',
                ifelse(p.value <= 0.05, '  *',
                       ifelse(p.value <= 0.1, '  .', '   '))))
}


pvals = pvals %>%
  mutate(label = sign.stars(p.value),
         y = max(estimate1, estimate2)) %>%
  select(var, label, y) 



ggplot(cat, aes(y = valor, x = as.factor(var), group = terminado_3a)) +
  geom_bar(aes(fill = terminado_3a), stat = 'summary', fun.y = mean, position = 'dodge') +
  # geom_signif(stat = 'identity',
  #             data = pvals,
  #             aes(x = x, xend = xend, y = y, yend = y, annotation = annotation),
  #             position = position_dodge(width = 1)) +
  # geom_text(data = pvals, aes(y = y, label = label, x = var), position = position_dodge(width = 1)) +
  
  stat_summary(fun.data = mean_cl_normal,
               geom = 'errorbar', 
               position = position_dodge(width = 0.85), 
               width = 0.2) +
  scale_x_discrete(labels = c('abogado_pub' = 'Public Lawyer',
                              'codem' = 'Co-defendant',
                              'gen' = 'Gender', 
                              'indem' = 'Severance Pay',
                              'reinst' = 'Reinstatement',
                              'sarimssinf' = 'Social Security',
                              'trabajador_base' = 'At-will worker')) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(y = 'Percent', x = 'Variable', title = 'Historical cases ended after 3 years') + 
  scale_fill_manual(values = c('gray77', 'gray53'), 
                    name = '',
                    labels = c('Not ended', 'Ended')) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 


ggsave('../Figuras/covariates_hdsample_categorical.tiff')
  