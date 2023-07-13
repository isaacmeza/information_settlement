rm(list = ls())
library(dplyr)
library(readxl)
library(ggplot2)
library(ggsignif)
library(broom)
library(data.table)
library(tidyr)
library(haven)


# Indicate path of the repository
setwd("C:/Users/isaac/Dropbox/repos/information_settlement")


source('./DoFiles/appendix/a/multiplot.R')

factores <- c('gen',
              'codem',
              'reinst',
              'indem',
              'trabajador_base',
              'sarimssinf',
              'abogado_pub', 
              'hd')

continuas <- c("c_antiguedad", "horas_sem", "c_rec20", "c_hextra")

factores_fun <- function(x){as.factor(as.character(x))}
log_fun <- function(x){log(1 + (as.numeric(x)))}

pilot <- read_dta('./DB/phase_1.dta') %>%
         dplyr::select(gen,
                codem,
                reinst,
                indem,
                trabajador_base,
                sarimssinf,
                abogado_pub,
                c_antiguedad,
                horas_sem,
                c_rec20,
                c_hextra) %>%
    mutate(hd = 0) %>%
  mutate_at(vars(one_of(factores)), factores_fun) %>%
  mutate_at(vars(one_of(continuas)), log_fun)

hd <- read_dta('./DB/scaleup_hd.dta') %>%
      dplyr::select(gen,
                codem,
                reinst,
                indem,
                trabajador_base,
                sarimssinf,
                abogado_pub,
                c_antiguedad,
                horas_sem,
                c_rec20,
                c_hextra) %>%
      mutate(hd = 1) %>%
  mutate_at(vars(one_of(factores)), factores_fun) %>%
  mutate_at(vars(one_of(continuas)), log_fun)


df <- rbind(hd, pilot)


###################

# Continuous

##################

plot_titles_cont <- c('Tenure', 'Weekly hours', '20 days', 'Overtime')

plot_covariates_cont <- function(var, plot_title){
  x = pilot[[var]]
  y = hd[[var]]
  m = ks.test(x, y)
  p = format(m$p.value, digits = 3)
  
  ggplot(df, aes_string(var, color = 'hd', linetype = 'hd')) +
    geom_density(aes(y = ..scaled..), size = 6) + 
    scale_y_continuous(labels = scales::percent_format()) +
    labs(title = plot_title, x = '', y = 'Percent',
         subtitle = bquote(P-value==.(p))) +
    scale_colour_manual(values = c('gray77', 'gray43'), 
                        name = '') +
    guides(color = F, linetype = F) +
    theme(plot.title = element_text(size=50)) +
    theme(plot.subtitle=element_text(size=35)) +
    theme(panel.background = element_rect(fill = 'white', color = 'black'))
}


tiff(file = "./Figures/appendix/a/covariates_continous.tiff",width = 3750, height = 2800, units = "px", res = 100) 

plot_list = lapply(1:4, function(i) plot_covariates_cont(continuas[i], plot_titles_cont[i]))

multiplot(plotlist = plot_list, cols = 2)

dev.off()

###################

# Categorical

##################

aux_factor <- function(x){as.numeric(as.character(x))}
aux_nas <- function(x){
  x[is.na(x)] <- '0'
  x
}

cat = df %>%
  select(one_of(factores)) %>%
  filter(!is.na(hd)) %>%
  # mutate_all(aux_nas) %>% 
  gather(key = var, value = valor, -hd) %>% 
  mutate(valor = aux_factor(valor))

pvals = cat %>%
  group_by(var) %>% do(tidy(t.test(valor ~ hd, data = .)))


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


ggplot() +
  geom_bar(data = cat, aes(y = valor, x = as.factor(var), group = hd, fill = hd), stat = 'summary', fun.y = mean, position = 'dodge') +
  # geom_signif(stat = 'identity',
  #             data = pvals,
  #             aes(x = x, xend = xend, y = y, yend = y, annotation = annotation),
  #             position = position_dodge(width = 1)) +
  geom_text(data = pvals, aes(y = y+.15, label = label, x = as.factor(var)), size = 5) +
  stat_summary(data = cat, aes(y = valor, x = as.factor(var), group = hd),
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
  labs(y = 'Percent', x = 'Variable') + 
  scale_fill_manual(values = c('gray77', 'gray53'), 
                    name = '',
                    labels = c('Phase 1', 'Historical Data')) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 


ggsave('./Figures/appendix/a/covariates_categorical.tiff', width = 99.21875, height = 74.08333, units = 'mm')