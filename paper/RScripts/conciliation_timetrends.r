library(dplyr)
library(ggplot2)
library(zoo)
library(xts)
library(forecast)
library(lubridate)
library(tseries)
library(dlm)

df = readRDS('../DB/scaleup_hd_original.RDS')


monyr <- function(x)
{
  x <- as.POSIXlt(x)
  x$mday <- 1
  as.Date(x)
}

calculate_start_of_week = function(week, year) {
  date <- ymd(paste(year, 1, 1, sep = "-"))
  week(date) = week
  return(date)
}



monthly = df %>%
  filter(!is.na(modo_termino)) %>%
  mutate(convenio = as.numeric(modo_termino == 1),
         fecha = monyr(fecha_demanda)) %>%
  filter(fecha >= '2011-01-01', fecha <= '2011-08-01') %>%
  group_by(fecha) %>%
  summarise(tasa_conc = mean(convenio, na.rm = T)) %>%
  ungroup()



weekly = df %>%
  filter(!is.na(modo_termino)) %>%
  mutate(convenio = as.numeric(modo_termino == 1),
         semana = week(fecha_demanda),
         anio = year(fecha_demanda),
         mes_inicio = monyr(fecha_demanda)) %>%
  filter(mes_inicio >= '2011-01-01', mes_inicio <= '2011-08-01') %>%
  group_by(anio, semana) %>%
  summarise(tasa_conc = mean(convenio, na.rm = T)) %>%
  ungroup() %>%
  mutate(fecha = calculate_start_of_week(semana, anio)) %>%
  filter(tasa_conc < 1)
  
# Plot them 

ggplot(monthly, aes(fecha, tasa_conc)) +
  geom_point(size = 1.5) + 
  geom_smooth() +
  ylim(c(0,1)) +
  labs(title = '', x = 'Month', y = 'Conciliation Rate') +
  theme_classic()

ggsave('../Figuras/conciliation_monthlyrate.tiff')

  
ggplot(weekly, aes(fecha, tasa_conc)) +
  geom_point(size = 1.5) + 
  geom_smooth() +
  ylim(c(0,1)) +
  labs(title = '', x = 'Week', y = 'Conciliation Rate') +
  theme_classic()


ggsave('../Figuras/conciliation_weeklyrate.tiff')



  