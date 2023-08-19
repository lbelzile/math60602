# MATH 60602 - Analyse multidimensionnelle appliquée
# Données manquantes
library(mice)
library(dplyr)
url <- "https://lbelzile.bitbucket.io/MATH60602/missing1.sas7bdat"
missing1 <- haven::read_sas(url) %>%
  mutate(x1 = factor(x1),
         x2 = factor(x2),
         x6 = factor(x6))

# Visualisation des différentes combinaisons de valeurs manquantes
md.pattern(missing1)

# imputation des données manquantes
# Combien de valeurs manquantes par variable

# Pour chaque colonne, calculer la somme du nombre de valeurs manquantes
# is.na: oui=1 (manquante) ou non=0 (observé)
apply(missing1, 2, function(x){sum(is.na(x))})

# Imputation multiple avec équations enchaînées
impdata <- mice(data = as.data.frame(missing1), 
                n = 36, 
                seed = 2021,
                method = "pmm")
# Chaque copie est disponible (1, ..., 36)
complete(impdata, action = 1)
# ajuste les modèles avec les données imputées

manyfit <- with(data = impdata,
               expr = glm(y ~ x1 + x2 + x3 + x4 + x5 + x6,
                          family = binomial(link = 'logit')))

# combinaison des résultats 
fit <- pool(manyfit)
summary(fit)

# Prédiction des données avec dbmmissing
# régression logistique
# les procédures d'imputation et de sélection par AIC
# sont toutes deux gourmandes en calcul
if(FALSE){
  rm(list = ls())
  url <- "https://lbelzile.bitbucket.io/MATH60602/dbmmissing.sas7bdat"
  dbmmissing <- haven::read_sas(url) %>%
    mutate(x1 = factor(x1),
           x3 = factor(x3),
           x4 = factor(x4),
           x5 = factor(x5))
  yachat <- dbmmissing$yachat
  ymontant <- dbmmissing$ymontant
  dbmmissing$id <- NULL
  dbmmissing$test <- NULL
  dbmmissing$yachat[dbmmissing$train == 0] <- NA
  dbmmissing$ymontant[dbmmissing$train == 0] <- NA
  class(dbmmissing) <- "data.frame"
  # Avertissement - très glouton en calcul
  impute <- mice(dbmmissing[,1:10], 
                 pred = quickpred(dbmmissing[,1:10], mincor=0.3),
                 m = 5, 
                 method = "pmm")
  p1 <- matrix(0, nrow = sum(dbmmissing$train == 0), ncol = impute$m)
  for(i in seq_len(impute$m)){
    mmat <- data.frame(y = as.integer(yachat),
      model.matrix(ymontant ~ -1 + .*. + I(x2^2) + I(x6^2) + I(x7^2)+ I(x8^2)+ I(x9^2), 
                         data = complete(impute, i))
    )
    mod1 <- glm(y ~ .,
                data = mmat,
                subset = dbmmissing$train == 1,
                family = binomial(link = "logit"))
    modfin <- step(mod1, scope = "y~1", 
                   direction = "both", 
                   trace = FALSE,
                   k = 2, 
                   keep = function(x, bAIC){ 
                     list(formula = formula(x), 
                          AIC = bAIC, 
                          BIC = BIC(x))}) 
    # pour valeur-p, utiliser qchisq(1-alpha, 1)       
    p1[,i] <- predict(object = modfin, 
                      newdata = mmat[dbmmissing$train == 0,], 
                      type = "response")
  }
  
  p <- rowMeans(p1)
  ymontant[is.na(ymontant)] <- 0
  # avec point de coupure 0.14 (pas estimé par validation croisée)
  sum(-10*(p > 0.14) + (p > 0.14)*ymontant[dbmmissing$train == 0])
}