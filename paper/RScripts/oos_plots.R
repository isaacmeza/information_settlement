# Scatter plots de predicciones
# Continuas
source('aux_oos_plots.R')
source('multiplot.R')
load('../Calculator/data/validation_models.RData')
load('../Calculator/data/test_data.RData')
#load(datos)

# Usamos la lista de nombres de modelos continuos para generar la lista de gráficas y sus títulos

outcomes = c('caducidad', 
             'convenio', 
             'desiste', 
             'laudo_gana', 
             'laudo_pierde') 

cont_modelname_list = c(paste0('mod_duracion_', outcomes),
                        'mod_liqtotal_laudo_gana', 'mod_liqtotal_convenios')
cont_variablename_list = c(rep('liqtotal', 2), rep('duracion', 5)) 
cont_title_list = c('Expiry', 'Settlement', 'Drop', 'Winning Court Ruling', 'Losing Court Ruling', 'Winning Court Ruling', 'Settlement')
data_list = list('mod_duracion_caducidad' = duracion_caducidad_test,
                 'mod_duracion_convenio' = duracion_convenio_test,
                 'mod_duracion_desiste' = duracion_desiste_test,
                 'mod_duracion_laudo_gana' = duracion_laudo_gana_test,
                 'mod_duracion_laudo_pierde' = duracion_laudo_pierde_test,
                 'mod_liqtotal_laudo_gana' = lt_laudo_gana_test,
                 'mod_liqtotal_convenio' = lt_convenio_test)

names(cont_title_list) = cont_modelname_list
names(cont_variablename_list) = cont_modelname_list
names(cont_modelname_list) = cont_modelname_list


# Generamos listas de gráficas, para duración y liqtotal
duracion_plot_list <- lapply(cont_modelname_list[1:5],
                     FUN = function(x){
                       plot_oos_fit_r2(data_list[[x]], cont_modelname_list[x], variable = 'y')})

# liqtotal_plot_list <- lapply(cont_modelname_list[6:7],
#                      FUN = function(x){
#                       plot_oos_fit_r2(data_list[[x]], cont_modelname_list[x], variable = 'y')})

lt_laudogana = plot_oos_fit_r2(lt_laudo_gana_test, 'mod_liqtotal_laudo_gana', 'y')
lt_convenio = plot_oos_fit_r2(lt_convenio_test, 'mod_liqtotal_convenios', 'y')

lt_plot_list = list('mod_liqtotal_laudo_gana' = lt_laudogana,
                    'mod_liqtotal_convenio' = lt_convenio)

plot_list = append(lt_plot_list, duracion_plot_list)

lapply(names(plot_list), 
       function(x) ggsave(filename = paste('../Figuras/', x,".tiff", sep = ""), plot = plot_list[[x]]))


# multiplot(duracion_plot_list[[1]], 
#           duracion_plot_list[[2]],
#           duracion_plot_list[[3]],
#           duracion_plot_list[[4]],
#           duracion_plot_list[[5]], 
#           cols = 2)
# 
# multiplot(lt_laudogana, 
#           lt_convenio)

# Clasificadores

accuracy_data = data.frame(model = c('Settlement',
                                     'Drop',
                                     'Expiry',
                                     'Won Court Ruling',
                                     'Lost Court Ruling'),
                           accuracy = c(0.61,
                                        0.78,
                                        0.93,
                                        0.67,
                                        0.69))

ggplot(accuracy_data, aes(model, accuracy)) +
  geom_bar(stat = 'identity') +
  labs(title = 'Accuracy Rate',
       y = '',
       x = '') +
  scale_y_continuous(labels = scales::percent_format()) +
  theme_classic() +
  theme(axis.text.x = element_text(size = 8))

ggsave(filename = '../Figuras/oos_fit_categorical.tiff')
