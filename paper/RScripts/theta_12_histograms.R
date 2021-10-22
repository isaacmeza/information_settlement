library(ggplot2)


# Plot for Employee 
g_emp = data %>%
  filter(parte == 'actor') %>%
  group_by(tratamientoquelestoco) %>%
  summarise_at(vars(starts_with('theta')), mean, na.rm = T)

data %>%
  filter(parte == 'actor') %>% 
  ggplot() +
  geom_histogram(aes(theta1), binwidth = 2) +
  facet_grid(.~ tratamientoquelestoco) +
  labs(x = '', y = '') +
  geom_vline(data = g_emp, aes(xintercept = theta1), color = 'lightsteelblue', size = 2) +
  theme_gdocs()

ggsave('../Figuras/theta1_actor.tiff', width = 10, height = 5)


data %>%
  filter(parte == 'actor') %>% 
  ggplot() +
  geom_histogram(aes(theta2), binwidth = 0.5) +
  facet_grid(.~ tratamientoquelestoco) +
  labs(x = '', y = '') +
  geom_vline(data = g_emp, aes(xintercept = theta2), color = 'lightsteelblue', size = 2) +
  theme_gdocs()

ggsave('../Figuras/theta2_actor.tiff', width = 10, height = 5)




# Plot for Employee Lawyer
g_emplaw = data %>%
  filter(parte == 'ractor') %>%
  group_by(tratamientoquelestoco) %>%
  summarise_at(vars(starts_with('theta')), mean, na.rm = T)

data %>%
  filter(parte == 'ractor') %>% 
  ggplot() +
  geom_histogram(aes(theta1), binwidth = 2) +
  facet_grid(.~ tratamientoquelestoco) +
  labs(x = '', y = '') +
  geom_vline(data = g_emplaw, aes(xintercept = theta1), color = 'lightsteelblue', size = 2) +
  theme_gdocs()


ggsave('../Figuras/theta1_ractor.tiff', width = 10, height = 5)


data %>%
  filter(parte == 'ractor') %>% 
  ggplot() +
  geom_histogram(aes(theta2), binwidth = 0.5) +
  facet_grid(.~ tratamientoquelestoco) +
  labs(x = '', y = '') +
  geom_vline(data = g_emplaw, aes(xintercept = theta2), color = 'lightsteelblue', size = 2) +
  theme_gdocs()

ggsave('../Figuras/theta2_ractor.tiff', width = 10, height = 5)



# Plot for Firm Lawyer
g_firmlaw = data %>%
  filter(parte == 'rdem') %>%
  group_by(tratamientoquelestoco) %>%
  summarise_at(vars(starts_with('theta')), mean, na.rm = T)

data %>%
  filter(parte == 'rdem') %>% 
  ggplot() +
  geom_histogram(aes(theta1), binwidth = 1) +
  facet_grid(.~ tratamientoquelestoco) +
  labs(x = '', y = '') +
  geom_vline(data = g_firmlaw, aes(xintercept = theta1), color = 'lightsteelblue', size = 2) +
  theme_gdocs()


ggsave('../Figuras/theta1_rdem.tiff', width = 10, height = 5)


data %>%
  filter(parte == 'rdem') %>% 
  ggplot() +
  geom_histogram(aes(theta2), binwidth = 0.5) +
  facet_grid(.~ tratamientoquelestoco) +
  labs(x = '', y = '') +
  geom_vline(data = g_firmlaw, aes(xintercept = theta2), color = 'lightsteelblue', size = 2) +
  theme_gdocs()

ggsave('../Figuras/theta2_rdem.tiff', width = 10, height = 5)