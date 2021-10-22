source('00_setup.R')
source('utils.R')

trunca99 <- function(x){
  cuantil99 <- quantile(x, .99, na.rm=T, type=1)
  x [x>cuantil99] <- cuantil99
  x
}

# Notas sobre variables en la gráfica:
# amount asked es c_total al 99%
# amount won = liqtotal al 99%
# min compensation by law = min_ley
# min compensation + fallen wages = min_ley + sueldo*duracion*365 

# Leo datasets
vars_truncadas <- c('c_total', 'liq_total')
vars <- c(vars_truncadas, 'min_ley', 'minley_salcaidos')

inpc = read.csv('../Raw/inpc.csv')

# 
# gen months=(fecha_con-fechadem)/30
# gen npv=(c1_cantidad_total_pagada_conveni/(1+(${int})/100)^months)*(1-${perc_pag})
# *NPV at constant prices (June 2016) 
# replace npv=(npv/inpc)*118.901
# global int=.797   /* Interest rate */

target <- c('c_total', 'min_ley', 'minley_salcaidos', 'liq_total', 'liq_total_pos')

deflacta = function(x, inpc){
  (x/inpc)*118.901
}

npv = function(x, months, interest_rate, payment_perc){
 (x/(1 + (interest_rate/100)^months))(1 - payment_perc)
}

df <- readRDS('../DB/scaleup_hd_original.RDS') %>%
  mutate(months_dif = as.numeric(fecha_termino - fecha_demanda)/30,
         mes = month(fecha_demanda),
         anio = as.numeric(as.character(anio))) %>%
  group_by(modo_termino) %>%
  mutate_at(vars(one_of(vars_truncadas)), trunca99) %>%
  ungroup() %>% 
  mutate(minley_salcaidos = min_ley + sueldo*duracion*365)%>%
  left_join(inpc) %>%
  select(-mes, -inpc) %>%
  mutate(mes = month(fecha_termino)) %>%
  left_join(inpc) %>%
  mutate(liq_total_pv = (liq_total/(1 + (3.43/100)^months_dif)),
         liq_total_pv = liq_total_pv*0.7) %>%
  filter(!(modo_termino == 2 & liq_total != 0), 
         !(modo_termino == 4 & liq_total !=0)) 
# %>%
# mutate_each(funs(((function(x){x/1000})(.))), one_of(vars))

# Preparo los datos para tener la matriz que necesito de modos de termino, nombre de la variable y cantidad promedio.
df_plot <- df %>%
  dplyr::select(one_of(vars), modo_termino) %>%
  mutate(liq_total_pos = ifelse(liq_total>0, liq_total, NA)) %>%
  gather(key = var, value = monto, -modo_termino) %>%
  filter(!is.na(modo_termino)) %>%
  group_by(modo_termino, var) %>%
  summarise(monto = mean(monto, na.rm = T)) %>%
  mutate(monto = ifelse(is.na(monto), 0, monto/1000)) %>%
  spread(key = modo_termino, value = monto) 

df_plot <- df_plot[match(target, df_plot$var),]

varnames <- df_plot$var

df_plot <- df_plot %>%
  dplyr::select(-var) %>%
  as.matrix(.)

# Poner nombres bonitos a la matriz que vamos a graficar
rownames(df_plot) <- c('Amount asked', 'Min. comp. by law', 'Min. comp. + lost wages', 'Amount won', 'Amount won (positive)')
colnames(df_plot) <- c('Settlement', 'Drop', 'Court ruling', 'Expiry')
ylim <- range(df_plot)*c(1,1.25)

# Generamos los porcentajes que necesitamos de cada modo de t?rmino:
prop_mt <- df %>% 
  ungroup() %>% 
  count(modo_termino) %>% 
  mutate(n = n*100 / nrow(df),
         modo_termino = as.character(modo_termino)) %>%
  filter(!is.na(modo_termino))

laudos_pos <- df %>% 
              filter(modo_termino == 3) %>%
              ungroup() %>%
              count(liq_total_pos) %>%
              mutate(n = n*100/nrow(df)) %>%
              filter(liq_total_pos == '1') %>%
              rename(modo_termino = liq_total_pos) %>%
              mutate(modo_termino = '5')

prop_mt <- rbind(prop_mt, laudos_pos)

prop_mt_leg <- paste0(c(colnames(df_plot),
                        'Winning court ruling'),
                      ' - ',
                      substr(as.character(prop_mt$n), 1, 4), '%')

# Defino las gr?ficas y les pongo legends

par(mar = c(4.1, 5.1, 2.1, 3.1))

tiff(file = "../Figuras/Amountasked.tiff", width = 3750, height = 2800, units = "px", res = 800) 

barplot(df_plot,
        beside = T, 
        ylim = ylim, 
        col = 1, 
        lwd = 1:2, 
        angle = c(0, 45, 90, 135, 0), 
        density = c(0, 20, 20, 30, 35), 
        cex.names = 0.7, 
        cex.axis = 0.7)
barplot(df_plot, 
        add = TRUE, 
        beside = TRUE, 
        ylim = ylim, 
        col = 1, 
        lwd = 1:2, 
        angle = c(0, 45, 90, 135, 0), 
        density = c(0, 20, 20, 60, 35), 
        ylab = 'Amounts (in thousands of pesos)',
        cex.lab = 0.8,
        cex.names = 0.7, 
        cex.axis = 0.7) -> ex

legend('top', legend = rownames(df_plot),
       ncol = 2, fill = TRUE, cex = 0.6, col = 1,
       angle = c(0, 45, 90, 135, 0),
       density = c(0, 30, 35, 60, 65),
       inset = c(0.1, -0.3), xpd=TRUE)
legend('bottom', legend = prop_mt_leg, 
       ncol = 2, cex = 0.55, 
       inset = c(0, -0.5), xpd=TRUE)

dev.off()