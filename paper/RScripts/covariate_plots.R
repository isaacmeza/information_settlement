# Cargamos los datos
library(dplyr)
library(ggplot2)
library(ggsignif)
library(broom)

source('multiplot.R')

factores <- c('gen',
              'codem',
              'reinst',
              'indem',
              'trabajador_base',
              'sarimssinf',
              'abogado_pub', 
              'hd')

factores_fun <- function(x){as.factor(as.character(x))}
log_fun <- function(x){log(1 + (as.numeric(x)))}

pilot <- read.csv('../DB/pilot_casefiles.csv') %>%
        dplyr::select(sueldo = salariodiariointegrado, 
               gen = gen,
               c_antiguedad = antigedad,
               codem = codemandaimssinfo,
               horas_sem = horas,
               reinst = reinstalaciont,
               indem = indemconsttdummy,
               c_indem = indemcdinero,
               c_rec20 = c_veintedias,
               c_hextra = c_horasextras,
               trabajador_base = trabbase,
               sarimssinf = sarimssinfo,
               abogado_pub = tipodeabogadocalc) %>%
        mutate(hd = 0) 

continuas <- names(pilot)[!(names(pilot) %in% factores)]

hd <- readRDS('../DB/scaleup_hd_original.RDS') %>%
      filter(junta == '7') %>%
      dplyr::select(sueldo,
             gen,
             c_antiguedad,
             codem, 
             horas_sem,
             reinst,
             indem,
             c_indem,
             c_rec20,
             c_hextra,
             trabajador_base,
             sarimssinf, 
             abogado_pub) %>%
  mutate(hd = 1)

df <- rbind(hd, pilot)%>%
      mutate_at(vars(one_of(factores)), factores_fun) %>%
      mutate_at(vars(one_of(continuas)), log_fun)

plot_titles_cont <- c('Wage', 'Tenure', 'Weekly working hours', 'Severance Pay', '20 days', 'Overtime')


plot_covariates_cont <- function(var, plot_title){
  x = pilot[[var]]
  y = hd[[var]]
  m = ks.test(x, y)
  p = format(m$p.value, digits = 3)
  
  ggplot(df, aes_string(var, color = 'hd', linetype = 'hd')) +
  geom_density(aes(y = ..scaled..), size = 1) + 
    scale_y_continuous(labels = scales::percent_format()) +
    labs(title = plot_title, x = '', y = 'Percent',
         subtitle = bquote(P-value==.(p))) +
    scale_colour_manual(values = c('gray77', 'gray43'), 
                      name = '') +
    guides(color = F, linetype = F) +
    theme_classic()
}


tiff(file = "../Figuras/covariates_continous.tiff", width = 3750, height = 2800, units = "px", res = 800) 

p1 <- plot_covariates_cont(continuas[1], plot_titles_cont[1])
p2 <- plot_covariates_cont(continuas[2], plot_titles_cont[2])
p3 <- plot_covariates_cont(continuas[3], plot_titles_cont[3])
p4 <- plot_covariates_cont(continuas[4], plot_titles_cont[4])
p5 <- plot_covariates_cont(continuas[5], plot_titles_cont[5])
p6 <- plot_covariates_cont(continuas[6], plot_titles_cont[6])
  
multiplot(p1, p2, p3, p4, p5, p6, cols = 2)

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



ggplot(cat, aes(y = valor, x = as.factor(var), group = hd)) +
geom_bar(aes(fill = hd), stat = 'summary', fun.y = mean, position = 'dodge') +
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
labs(y = 'Percent', x = 'Variable') + 
scale_fill_manual(values = c('gray77', 'gray53'), 
                  name = '',
                  labels = c('Pilot Data', 'Historic Data')) +
theme_classic() +
theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

  
  ggsave('../Figuras/covariates_categorical.tiff')
