# Scatter plots de predicciones
# Continuas
load('utils.RData')

trunca99 <- function(x){
  cuantil99 <- quantile(x, .99, na.rm=T, type=1)
  x [x>cuantil99] <- cuantil99
  x
}

quita_negativos <- function(x){
  x[x<0] <- 0
  x
}

get_r2 <- function(df, pred_var){
  m <- summary(lm(liq_total_tope ~ pred, df))
  format(m$r.squared, digits = 3)
}

df = read.csv('../DB/scaleup_hd.csv') %>%
          group_by(modo_termino) %>%
          mutate_at(vars(starts_with('liq_total'), starts_with('c_')), trunca99) %>%
          ungroup() %>%
          mutate_at(vars(starts_with('liq_total'), starts_with('c_')), quita_negativos) %>%
          mutate(ln_liq_total = log(1 + liq_total_tope),
                 ln_c_antiguedad = log(1 + c_antiguedad),
                 ln_c_indem = log (1 + c_indem))

juntas = c(2, 7, 9, 11, 16)
for(level in unique(juntas)){
  df[paste('junta', level, sep = '')] <- ifelse(df$junta == level, 1, 0)
}

df_convenio = df %>% filter(modo_termino == 1)
df_laudo = df %>% filter(modo_termino == 3, liq_total > 0)

# Hacemos train-test split y generamos los modelos para predecir

set.seed(1406)

train_convenio = sample_frac(df_convenio, 0.7)
sid = as.numeric(rownames(train))
test_convenio = df_convenio[-sid,]

train_laudo = sample_frac(df_laudo, 0.8)
sid = as.numeric(rownames(train))
test_laudo = df_laudo[-sid,]

modelo_laudo = lm(OLS_lau$formula, data = train_laudo)
modelo_convenio = lm(log_OLS_con$formula, data = train_convenio)

test_laudo$pred = predict(modelo_laudo, newdata = test_laudo)
test_convenio$pred = exp(predict(modelo_convenio, newdata = test_convenio))

r2_laudo <- get_r2(test_laudo)
r2_convenio <- get_r2(test_laudo)

ggplot(test_laudo, aes(x = pred/1000, y = liq_total_tope/1000)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE, color = 'red4') +
  labs(title = 'Winning Court Ruling',
       x = 'Prediction', y = 'y') + 
  theme_classic() +
  labs(subtitle = bquote(R^{2}==.(r2_laudo)), x = 'Prediction')

ggsave('../Figures/prediction_laudo.tiff')


ggplot(test_convenio, aes(x = pred/1000, y = liq_total_tope/1000)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE, color = 'red4') +
  labs(title = 'Compensation in Settlement',
       x = 'Prediction', y = 'y') + 
  theme_classic() +
  labs(subtitle = bquote(R^{2}==.(r2_convenio)), x = 'Prediction')

ggsave('../Figures/prediction_convenio.tiff')


