library(dplyr)
library(purrr)
library(miceadds)
library(multiwayvcov)
library(lmtest)
library(ggplot2)
library(plm)

# df = readRDS('../DB/scaleup_operation.RDS')

# Assumptions: ITT is not heterogeneous by court
# For each court, notification and conciliation probs ~ N(mu, sigma)
# As described below


# Sourcing custom summary function for clustering SE
#source('summary.lm.R')


# Days range
dias = 5:38
juntas = c('2', '7', '9', '11', '16')

# Daily notified cases at each court
juntas_not_mean = c(15, 15, 16, 19, 15)
juntas_not_sd = c(2.6, 3.62, 5.09, 5.42, 4.97)

# Daily conciliation rates at each court
juntas_conc_mean = c(0.08, 0.1, 0.09, 0.2, 0.07)
juntas_conc_sd = c(0.04, 0.06, 0.04, 0.07, 0.05)

# ITT effect
itt = 0.045

# Iterations
n_iter = 1000

# Initial court ordering
order = sample(juntas[1:4], 4)
order_chain = rep(order, 8)



################################

# Power calculations

#################################


# Calculating power function

calcula_poder = function(n_dias){
  
  coef = numeric()
  p_val = numeric()
  
for (i in 1:n_iter){

    data = data_frame()
    
for (dia in 1:n_dias){
        print(paste0('iteration: ', i))
        print(paste0('Dia ', dia, ':', n_dias))      
  
        # Generate number of observations according to notification distribution at each court
        n_obs =  1:5 %>%
        map_dbl(function(x) round(rnorm(1, juntas_not_mean[x], juntas_not_sd[x])))
        n_obs = pmax(8, n_obs)
        
        # Generate court data
        junta = 1:5 %>%
        map(function(x) rep(juntas[x], n_obs[x])) %>% unlist()
        
        # Generate treatment data
        treated = as.numeric(juntas %in% order_chain[dia:(dia+2)])
        if (dia%%2) treated[5] <- 1
        tratamiento = 1:5 %>%
                      map(function(x) rep(treated[x], n_obs[x])) %>% unlist()
        
        # Conciliation data
        p = 1:5 %>% 
            map(function(x) rnorm(n_obs[x], juntas_conc_mean[x], juntas_conc_sd[x])) %>% unlist()
        p = if_else(tratamiento == 1, p + rnorm(1, itt, 0.001), p)
        p = pmax(0, p)
        
        conciliacion = rbinom(length(p), 1, p)
        
        data = bind_rows(data, data_frame(dia, junta, tratamiento, conciliacion))
}
    
    # Use data on all days to run regression
    data = data %>% mutate(junta = as.factor(junta), ind = row_number())
    p_data <- pdata.frame(data, index = c('dia', 'ind'), drop.index = F, row.names = T)
    model = plm(data = p_data, formula = conciliacion ~ tratamiento + junta, model = 'pooling')
    
    # compute Stata like df-adjustment
    G <- length(unique(p_data$dia))
    N <- length(p_data$dia)
    dfa <- (G/(G - 1)) * (N - 1)/model$df.residual
    
    # display with cluster VCE and df-adjustment
    vcov_clust <- dfa * vcovHC(model, type = 'HC0', cluster = 'group', adjust = T)
    coef = c(coef, coeftest(model, vcov_clust)['tratamiento', 'Estimate'])
    p_val = c(p_val, coeftest(model, vcov_clust)['tratamiento', 'Pr(>|t|)'])
}
  
  # Check significance
  vec = c(mean(coef), mean(p_val), mean(p_val <= 0.05))
  names(vec) = c('coef', 'p_val', 'power')
  return(vec)
}



# Power calculation for all day sets
power_data = dias %>%
            map(calcula_poder) %>%
            do.call(bind_rows, .)



################################

# Plots

#################################


ggplot(power_data) +
  geom_line(aes(x = dias, y = power), colour = 'tomato4', size = 1.5) +
  labs(title = 'Power', x = 'Days', y = 'Power') +
  guides(color = 'none') +
  theme_light()

ggsave('../../Paper/Figuras/simulations_itt_power.tiff')


ggplot(power_data) +
  geom_line(aes(x = dias, y = coef), colour = 'royalblue4', size = 1) +
  labs(title = '', x = 'Days', y = 'Mean ITT coefficient') +
  guides(color = 'none') +
  geom_hline(yintercept = 0.045) + 
  theme_light()

ggsave('../../Paper/Figuras/simulations_itt_coef.tiff')


ggplot(power_data) +
  geom_line(aes(x = dias, y = p_val), colour = 'violetred4', size = 1.5) +
  labs(title = '', x = 'Days', y = 'P-value') +
  guides(color = 'none') +
  geom_hline(yintercept = 0.05) + 
  theme_light()

ggsave('../../Paper/Figuras/simulations_itt_pval.tiff')

