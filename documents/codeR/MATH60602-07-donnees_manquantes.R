# MATH 60602 - Analyse multidimensionnelle appliquée
# Données manquantes
library(mice)
url <- "https://lbelzile.bitbucket.io/MATH60602/missing1.sas7bdat"
missing1 <- haven::read_sas(url)

# Visualisation des différentes combinaisons de valeurs manquantes
md.pattern(missing1)

# imputation des données manquantes
summary(missing1)[7,]
impdata <- mice(data = missing1, n = 36)

# valeurs imputées pour la 1ère variable

impdata$imp[[1]]

# valeurs imputées pour la 2ème variable

impdata$imp[[2]]

# ajuste les modèles avec les données imputées

manyfit <- with(data = impdata,
               expr = glm(y~factor(x1)+factor(x2)+x3+x4+x5+factor(x6), family=binomial(link='logit')))

# combinaison des résultats 

fit <- pool(manyfit)
summary(fit)

# imputations avec les variables indicatrices au lieu des variables catégorielles originales

missing1new <- missing1
missing1new[,"x11"] <- as.numeric(missing1new[,"x1"]==1)
missing1new[,"x12"] <- as.numeric(missing1new[,"x1"]==2)
missing1new[,"x13"] <- as.numeric(missing1new[,"x1"]==3)
missing1new[,"x14"] <- as.numeric(missing1new[,"x1"]==4)
missing1new[,"x21"] <- as.numeric(missing1new[,"x2"]==1)
missing1new[,"x22"] <- as.numeric(missing1new[,"x2"]==2)
missing1new[,"x23"] <- as.numeric(missing1new[,"x2"]==3)
missing1new[,"x24"] <- as.numeric(missing1new[,"x2"]==4)
missing1new[,"x61"] <- as.numeric(missing1new[,"x6"]==1)
missing1new[,"x62"] <- as.numeric(missing1new[,"x6"]==2)


impdata1 <- mice(data = missing1new[,c("y","x11","x12","x13","x14","x21","x22","x23","x24","x3","x4","x5","x61","x62")], n = 26)
manyfit1 <- with(data = impdata1,
                expr = glm(y~x11+x12+x13+x14+x21+x22+x23+x24+x3+x4+x5+x61+x62,family=binomial(link='logit')))
fit1 <- pool(manyfit1)
summary(fit1)

# Prédiction des données avec dbmmissing
# régression logistique
# les procédures d'imputation et de sélection par AIC
# sont toutes deux gourmandes en calcul
if(FALSE){
  
  rm(list = ls())
  url <- "https://lbelzile.bitbucket.io/MATH60602/dbmmissing.sas7bdat"
  dbmmissing <- haven::read_sas(url)
  dbmmissing$x1 <- factor(dbmmissing$x1)
  dbmmissing$x3 <- factor(dbmmissing$x3)
  dbmmissing$x4 <- factor(dbmmissing$x4)
  dbmmissing$x5 <- factor(dbmmissing$x5)
  yachat <- dbmmissing$yachat
  ymontant <- dbmmissing$ymontant
  dbmmissing$id <- NULL
  dbmmissing$test <- NULL
  dbmmissing$yachat[dbmmissing$train == 0] <- NA
  dbmmissing$ymontant[dbmmissing$train == 0] <- NA
  class(dbmmissing) <- "data.frame"
  
  # Avertissement - très gluton en calcul
  impute <- mice(dbmmissing[,1:10], 
                 pred = quickpred(dbmmissing[,1:10], mincor=0.3),
                 m = 5)
  p1 <- matrix(0, nrow = 1e5, ncol = impute$m)
  for(i in 1:impute$m){
    data <- complete(impute, i)
    data$x1 <- as.integer(data$x1)
    data$x2 <- as.integer(data$x2)
    data$x5 <- as.integer(data$x5)
    data$x31 <- as.integer(data$x3==1)
    data$x32 <- as.integer(data$x3==2)
    data$x41 <- as.integer(data$x4==1)
    data$x42 <- as.integer(data$x4==2)
    data$x43 <- as.integer(data$x4==3)
    data$x44 <- as.integer(data$x4==4)
    data$x3 <- NULL
    data$x4 <- NULL
    data$y <- NA
    
    
    # Créer les interactions et les variables carrées
    attach(data)
    data$cx2 <- x2^2
    data$cx6 <- x6^2
    data$cx7 <- x7^2
    data$cx8 <- x8^2
    data$cx9 <- x9^2
    data$cx10 <- x10^2
    data$i_x2_x1 <- x2*x1
    data$i_x2_x31 <- x2*x31
    data$i_x2_x32 <- x2*x32
    data$i_x2_x41 <- x2*x41
    data$i_x2_x42 <- x2*x42
    data$i_x2_x43 <- x2*x43
    data$i_x2_x44 <- x2*x44
    data$i_x2_x5 <- x2*x5
    data$i_x2_x6 <- x2*x6
    data$i_x2_x7 <- x2*x7
    data$i_x2_x8 <- x2*x8
    data$i_x2_x9 <- x2*x9
    data$i_x2_x10 <- x2*x10
    data$i_x1_x31 <- x1*x31
    data$i_x1_x32 <- x1*x32
    data$i_x1_x41 <- x1*x41
    data$i_x1_x42 <- x1*x42
    data$i_x1_x43 <- x1*x43
    data$i_x1_x44 <- x1*x44
    data$i_x1_x5 <- x1*x5
    data$i_x1_x6 <- x1*x6
    data$i_x1_x7 <- x1*x7
    data$i_x1_x8 <- x1*x8
    data$i_x1_x9 <- x1*x9
    data$i_x1_x10 <- x1*x10
    data$i_x5_x31 <- x5*x31
    data$i_x5_x32 <- x5*x32
    data$i_x5_x41 <- x5*x41
    data$i_x5_x42 <- x5*x42
    data$i_x5_x43 <- x5*x43
    data$i_x5_x44 <- x5*x44
    data$i_x5_x6 <- x5*x6
    data$i_x5_x7 <- x5*x7
    data$i_x5_x8 <- x5*x8
    data$i_x5_x9 <- x5*x9
    data$i_x5_x10 <- x5*x10
    data$i_x31_x41 <- x31*x41
    data$i_x31_x42 <- x31*x42
    data$i_x31_x43 <- x31*x43
    data$i_x31_x44 <- x31*x44
    data$i_x31_x6 <- x31*x6
    data$i_x31_x7 <- x31*x7
    data$i_x31_x8 <- x31*x8
    data$i_x31_x9 <- x31*x9
    data$i_x31_x10 <- x31*x10
    data$i_x32_x41 <- x32*x41
    data$i_x32_x42 <- x32*x42
    data$i_x32_x43 <- x32*x43
    data$i_x32_x44 <- x32*x44
    data$i_x32_x6 <- x32*x6
    data$i_x32_x7 <- x32*x7
    data$i_x32_x8 <- x32*x8
    data$i_x32_x9 <- x32*x9
    data$i_x32_x10 <- x32*x10
    data$i_x41_x6 <- x41*x6
    data$i_x41_x7 <- x41*x7
    data$i_x41_x8 <- x41*x8
    data$i_x41_x9 <- x41*x9
    data$i_x41_x10 <- x41*x10
    data$i_x42_x6 <- x42*x6
    data$i_x42_x7 <- x42*x7
    data$i_x42_x8 <- x42*x8
    data$i_x42_x9 <- x42*x9
    data$i_x42_x10 <- x42*x10
    data$i_x43_x6 <- x43*x6
    data$i_x43_x7 <- x43*x7
    data$i_x43_x8 <- x43*x8
    data$i_x43_x9 <- x43*x9
    data$i_x43_x10 <- x43*x10
    data$i_x44_x6 <- x44*x6
    data$i_x44_x7 <- x44*x7
    data$i_x44_x8 <- x44*x8
    data$i_x44_x9 <- x44*x9
    data$i_x44_x10 <- x44*x10
    data$i_x7_x6 <- x7*x6
    data$i_x7_x8 <- x7*x8
    data$i_x7_x9 <- x7*x9
    data$i_x7_x10 <- x7*x10
    data$i_x6_x8 <- x6*x8
    data$i_x6_x9 <- x6*x9
    data$i_x6_x10 <- x6*x10
    data$i_x8_x9 <- x8*x9
    data$i_x8_x10 <- x8*x10
    data$i_x9_x10 <- x9*x10
    detach(data)
    data$y[1:1000] <- as.integer(dbmmissing$yachat[1:1000])
    mod1 <- glm(y ~ ., subset = 1:1000, data = data, family = binomial(link="logit"))
    modfin <- step(mod1, scope = "y~1", 
                   direction = "both", 
                   trace = FALSE,
                   k = 2, 
                   keep = function(x, bAIC){ list(formula = formula(x), AIC = bAIC, BIC = BIC(x))}) # pour valeur-p, utiliser qchisq(0.95, 1)       
    p1[,i] <- predict(modfin, newdata = data[-(1:1000),], 
                      type = "response")
  }
  
  p <- rowMeans(p1)
  ymontant[is.na(ymontant)] <- 0
  # avec point de coupure 0.14 (pas estimé par validation croisée)
  sum(-10*(p > 0.14) + (p > 0.14)*ymontant[-(1:1000)])
}