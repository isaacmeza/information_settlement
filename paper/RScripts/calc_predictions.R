
# Environment setup
source('environment.R')
source('vars_functions.R')

# Load data
probability_win = readRDS('../Calculator/scaleup/modelos/probability_win.RDS')
load('../Calculator/scaleup/modelos/utils.RData')


# Cherry-picking variables


df = readRDS('../DB/scaleup_hd_original.RDS') %>%
      filter(modo_termino == '3') %>%
      mutate(laudo_gana = as.numeric(liq_total > 0),
             grado_exag = ifelse(is.infinite(grado_exag), NA, grado_exag)) %>%
      select(one_of(working_vars), one_of(to_drop), laudo_gana) %>%
      dummy_fullrange( varlist = to_drop, range_list = rangos) %>%
      select(-one_of(to_drop)) %>%
      mutate_all(function(x) as.numeric(as.character(x)))

# Resample and split 

df %>%
  select(-laudo_gana) %>%
  ubSMOTE(., as.factor(df$laudo_gana), perc.over = 200, k = 5, 
          perc.under = 200, verbose = TRUE) -> listas

X <- listas$X %>% na.roughfix()
Y <- listas$Y %>% na.roughfix()


set.seed(140693)
smp_size <- floor(0.80 * nrow(X))
train_ind <- sample(seq_len(nrow(X)), size = smp_size, replace = FALSE)
X_train <- X[train_ind, ]
X_test  <- X[-train_ind, ]
Y_train <- Y[train_ind]
Y_test  <- Y[-train_ind]


# Grid search
hyper_params = list(
  RF = list(ntree = c(900, 1000, 1100, 
                      1200, 1300, 1400, 1500)),
  NN = list(decay = c(0.1, 0.001, 0.0001),
            size = 5:10,
            maxit = 1000))

RF = tune.randomForest(X_train, Y_train, ntree = c(900, 1000, 1100,1200, 1300, 1400, 1500))

train = cbind(X_train, Y_train) %>% rename(laudo_gana = Y_train)
NN = tune.nnet(laudo_gana ~ ., data = train, decay = c(0.1, 0.001, 0.0001), size = 5:10, maxit = 1000)

RF_best = randomForest(X_train, Y_train, ntree = RF$best.parameters[1])
NN_best = nnet(laudo_gana ~ ., data = train, decay = NN$best.parameters$decay, size = NN$best.parameters$size, maxit = 1000)
logit <- glm(laudo_gana ~ ., data = train, family = 'binomial')
probit <- glm(laudo_gana ~ ., data = train, family=binomial(link='probit'))
gboost <- glmboost(laudo_gana ~ ., data = train, family = Binomial(), control = boost_control(mstop = 500))


# Test models


list(RF_best, NN_best, logit, probit, gboost) %>%
  map(function(x) predict(x, newdata = X_test))


