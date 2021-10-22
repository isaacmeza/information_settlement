library(dplyr)
library(ggplot2)
library(scales)

# Reading data

pilot = readRDS('../DB/pilot_casefiles.RDS')
scaleup_casefiles = readRDS('../../ScaleUp/DB/scaleup_casefiles.RDS')
scaleup_predictions = readRDS('../../ScaleUp/DB/scaleup_predictions.RDS')

scaleup = left_join(scaleup_casefiles, scaleup_predictions)

# Plotting stuff

vars_pilot = c('comp_esp', 'comp_min', 'prob_ganar')
vars_scaleup = c('liq_total_laudo_avg', 'min_ley', 'X1')
filenames_pilot = paste0('../Figuras/', c('pq_expcomp', 'pq_comp_min', 'pq_prob'), '_p1.tiff')
filenames_scaleup = paste0('../Figuras/', c('pq_expcomp', 'pq_comp_min', 'pq_prob'), '_p2.tiff')

trunca = function(x, perc){
  quant = quantile(x, perc, na.rm = T, type = 7)
  ifelse(x > quant, quant, x)
}

pilot = pilot %>%
        mutate_at(vars(one_of(vars_pilot)), trunca, perc = .95)

scaleup = scaleup %>%
          mutate_at(vars(one_of(vars_scaleup)), trunca, perc = .95)

plot_histogram = function(data, var, filename){
  ggplot(data, aes_string(var)) +
    geom_histogram() +
    labs(title = '', y = '', x = '') +
    scale_x_continuous(labels = scales::comma) +
    theme_classic()
  
ggsave(filename)
}

lapply(1:3, function(i) plot_histogram(pilot, vars_pilot[i], filenames_pilot[i]))
lapply(1:3, function(i) plot_histogram(scaleup, vars_scaleup[i], filenames_scaleup[i]))

  
