predict_yhat <- function(data, model_name, variable){
  data$pred <- predict(get(model_name), newdata = data)
  data$y <- log(1+data[[variable]])
  data %>% select(y, pred)
}

plot_oos_fit <- function(df, model_name){
  ggplot(df, aes(x = pred, y = y)) +
    geom_point() +
    geom_smooth(method = 'lm', se = FALSE, color = 'red4') +
    labs(title = cont_title_list[model_name]) +
    theme_classic()
}

get_r2 <- function(df){
  m <- summary(lm(y ~ pred, df))
  format(m$r.squared, digits = 3)
}

plot_oos_fit_r2 <- function(data, model_name, variable){
  df <- predict_yhat(data, model_name, variable)
  r2 <- get_r2(df)
  
  plot_oos_fit(df, model_name) + 
    labs(subtitle = bquote(R^{2}==.(r2)), x = 'Prediction')
}