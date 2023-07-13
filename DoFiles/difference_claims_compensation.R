library(dplyr)
library(ggplot2)
library(tidyverse)
library(haven)

# Indicate path of repo
setwd("C:/Users/isaac/Downloads/information_settlement")


trunca99 <- function(x){
  cuantil99 <- quantile(x, .99, na.rm=T, type=1)
  x [x>cuantil99] <- cuantil99
  x
}


# Read dataset and select relevant variables
vars_truncadas <- c('c_total', 'liq_total')
vars <- c(vars_truncadas, 'min_ley')

target <- c('c_total', 'min_ley', 'liq_total', 'liq_total_pos')


df <- read_dta('./DB/scaleup_hd.dta') %>%
  group_by(modo_termino) %>%
  mutate_at(vars(one_of(vars_truncadas)), trunca99) %>%
  mutate(liq_total_pos = as.numeric(liq_total>0)) %>%
  ungroup() %>% 
  filter(!(modo_termino == 2 & liq_total != 0), 
         !(modo_termino == 4 & liq_total !=0), 
         !is.na(modo_termino)) 


# Prepare data to obtain matrix with end mode, variable name, and average amount.
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


# Name matrix to graph
rownames(df_plot) <- c('Amount asked', 'Min. comp. by law', 'Amount won', 'Amount won (positive)')
colnames(df_plot) <- c('Settlement', 'Drop', 'Court ruling', 'Expiry')
ylim <- range(df_plot)*c(1,1.25)

df_plot2<-df_plot

# Percentage of each end mode
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

# Graph plot

par(mar = c(4.1, 5.1, 2.1, 3.1))

tiff(file = "./Figures/difference_claims_compensation.tiff", width = 3750, height = 2800, units = "px", res = 800) 

barplot(df_plot2,
        beside = T, 
        ylim = ylim, 
        col = 1, 
        lwd = 1:2, 
        angle = c(0, 45, 90, 0), 
        density = c(0, 20, 20, 35), 
        ylab = 'Amounts (in thousands of pesos)',
        cex.names = 0.7, 
        cex.axis = 0.7)
barplot(df_plot2, 
        add = TRUE, 
        beside = TRUE, 
        ylim = ylim, 
        col = 1, 
        lwd = 1:2, 
        angle = c(0, 45, 90, 0), 
        density = c(0, 20, 20, 35), 
        ylab = 'Amounts (in thousands of pesos)',
        cex.lab = 0.8,
        cex.names = 0.7, 
        cex.axis = 0.7) -> ex

legend('top', legend = rownames(df_plot2),
       ncol = 2, fill = TRUE, cex = 0.6, col = 1,
       angle = c(0, 45, 90, 0),
       density = c(0, 30, 35, 65),
       inset = c(0.1, -0.3), xpd=TRUE)
legend('bottom', legend = prop_mt_leg, 
       ncol = 2, cex = 0.55, 
       inset = c(0, -0.5), xpd=TRUE)

dev.off()
