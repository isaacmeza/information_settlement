rm(list = ls())
library(dplyr)
library(readxl)
library(ggplot2)
library(ggsignif)
library(broom)
library(data.table)
library(tidyr)


# Indicate path of the repository
setwd("C:/Users/isaac/Downloads/information_settlement")


source('./DoFiles/appendix/a/multiplot.R')

factores <- c('gen',
              'codem',
              'reinst',
              'indem',
              'trabajador_base',
              'sarimssinf',
              'abogado_pub', 
              'ended')

continuas <- c("c_antiguedad", "horas_sem", "c_rec20", "c_hextra")

load('./_aux/cov_dist_hd_ended.Rdata')


pilot = df %>% filter(ended == '0')
hd = df %>% filter(ended == '1')


###################

# Continuous

##################

plot_titles_cont <- c('Tenure', 'Weekly hours', '20 days', 'Overtime')

plot_covariates_cont <- function(var, plot_title){
  x = pilot[[var]]
  y = hd[[var]]
  m = ks.test(x, y)
  p = format(m$p.value, digits = 3)
  
  ggplot(df, aes_string(var, color = 'ended', linetype = 'ended')) +
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


tiff(file = "./Figures/appendix/a/covariates_hdsample_continous.tiff",width = 3750, height = 2800, units = "px", res = 100) 

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
  filter(!is.na(ended)) %>%
  # mutate_all(aux_nas) %>% 
  gather(key = var, value = valor, -ended) %>% 
  mutate(valor = aux_factor(valor))

pvals = cat %>%
  group_by(var) %>% do(tidy(t.test(valor ~ ended, data = .)))


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
  geom_bar(data = cat, aes(y = valor, x = as.factor(var), group = ended, fill = ended), stat = 'summary', fun.y = mean, position = 'dodge') +
  # geom_signif(stat = 'identity',
  #             data = pvals,
  #             aes(x = x, xend = xend, y = y, yend = y, annotation = annotation),
  #             position = position_dodge(width = 1)) +
  geom_text(data = pvals, aes(y = y+.15, label = label, x = as.factor(var)), size = 5) +
  stat_summary(data = cat, aes(y = valor, x = as.factor(var), group = ended),
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
                    labels = c('Not ended', 'Ended')) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 


ggsave('./Figures/appendix/a/covariates_hdsample_categorical.tiff', width = 99.21875, height = 74.08333, units = 'mm')
