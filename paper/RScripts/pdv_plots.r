library(dplyr)
library(ggplot2)

df = readRDS('../DB/scaleup_hd_pred.RDS') %>%
      filter(!is.na(abogado_pub)) %>%
      mutate(comp = comp_esp_p2,
         beta = 0.95,
         t = duracion,
         keep = if_else(abogado_pub == 1, 1, 0.7),
         fixed_cost = if_else(abogado_pub == 1, 0, 2000),
         valor = keep*comp*((beta)^t) - fixed_cost,
         valor = valor/1000,
         check = valor < 0)
  
df %>%
  filter(abogado_pub == 1) %>%
  ggplot() +
  geom_histogram(aes(valor, y = ..count../sum(..count..))) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(x = 'Predicted discounted value', y = 'Percentage') +
  theme_classic()

ggsave('../Figuras/pdv_public.tiff')


df %>%
  filter(abogado_pub == 0) %>%
  ggplot() +
  geom_histogram(aes(valor, y = ..count../sum(..count..))) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(x = 'Predicted discounted value', y = 'Percentage') +
  theme_classic()

ggsave('../Figuras/pdv_private.tiff')


df %>%
  ggplot() +
  geom_histogram(aes(valor, y = (..count..)/tapply(..count..,..PANEL..,sum)[..PANEL..])) +
  labs(x = 'Predicted discounted value', y = 'Percentage') +
  scale_y_continuous(labels = scales::percent_format()) +
  facet_grid(.~ abogado_pub) + 
  theme_classic()

ggsave('../Figuras/pdv_both.tiff')


df %>%
  ggplot() +
  geom_density(aes(x = valor, color = abogado_pub), size = 1) +
  scale_color_manual(values = c('grey47', 'black'), 
                    name = 'Type of\nLawyer',
                    breaks = c('0', '1'),
                    labels=c('Private', 'Public')) +
  scale_y_continuous(labels = scales::percent_format()) +
  guides(color = guide_legend(override.aes = list(shape = 22))) +
  theme_classic()
 
ggsave('../Figuras/pdv_density.tiff')
