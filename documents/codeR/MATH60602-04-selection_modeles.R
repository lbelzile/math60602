# MATH 60602 - Analyse multidimensionnelle appliquée
## Sélection de modèles (partie 1)

## Charger les données depuis le serveur
file <- "https://lbelzile.bitbucket.io/MATH60602/selection1_train.sas7bdat"
train <- haven::read_sas(data_file = file)
file <- "https://lbelzile.bitbucket.io/MATH60602/selection1_test.sas7bdat"
test <- haven::read_sas(data_file = file)
library(ggplot2)
# Graphiques avec ggplot2 (plus joli, mais courbe d'apprentissage plus élevée)
# La fonction ne prend que des jeux de données en format `data.frame`
print(ggplot(data = train, mapping = aes(x=x,y=y)) + geom_point())

# Validation croisée avec k groupes - fonction codée par le prof
lmkfold <- function(formula, data, k, ...){
   accu <- 0
   k <- as.integer(k)
   n <- nrow(data)
   gp <- sample.int(n, n, replace = FALSE)
   folds <- split(gp, cut(seq_along(gp), 10, labels = FALSE))
   for(i in 1:k){
      g <- as.integer(unlist(folds[i]))
      fitlm <- lm(formula, data[-g,])
      accu <- accu + sum((data[g, all.vars(formula)[1]] -predict(fitlm, newdata=data[g,]))^2)
   }
   return(accu/n)
}

# Créer un contenant pour l'erreur moyenen quadratique
emq <- matrix(0, nrow = 10, ncol = 7)
emqcv <- matrix(0, nrow = 10, ncol = 100)
library(caret)
library(ggplot2)
for(i in 1 :10){
   set.seed(i*1000)
   # Créer le modèle avec une chaîne de caractère pour le polynôme
   meanmod <- as.formula(paste0("y~", paste0("I(x^",1 :i,")", collapse= "+")))
   mod <-  lm(meanmod, data = train)
   # Calculer l'erreur moyenne dans les deux échantillons
   emq[i,1 :2] <- c(mean(resid(mod)^2), #apprentissage
                    mean((test$y - predict(mod, newdata = test))^2)) #échantillon test
   emq[i,3] <- summary(mod)$r.squared
   emq[i,4] <- summary(mod)$adj.r.squared
   emq[i,5] <- AIC(mod) # Valeurs pas identiques à la sortie SAS, mais comparables entre elles
   emq[i,6] <- BIC(mod)
   # validation croisée avec 10 groupes
   emqcv[i,] <-  replicate(n = 100L, 
                           train(form = meanmod, data = train, method = "lm",
                                 trControl = trainControl(method = "cv", 
                                                          number = 10))$results$RMSE^2)
   # emq[i,7] <- lmkfold(formula = meanmod, data = train, k = 10)
}
emq[,7] <- rowMeans(emqcv)


emqdat <- data.frame(ordre = rep(1 :10, length.out = 20), 
                     emq = c(emq[,1 :2]),
                     echantillon = factor(c(rep("apprentissage",10), rep("théorique", 10)))
)
ggplot(data = emqdat, aes(x=ordre, y=emq, color=echantillon)) +
   geom_line() + 
   geom_point(aes(shape=echantillon, color=echantillon)) + 
   labs(title = "Erreur moyenne quadratique estimée en fonction de l'ordre", 
        x = "ordre du polynôme", 
        y = "erreur moyenne quadratique") + 
   theme(legend.position="bottom",
         legend.title=element_blank())

#Mesures d'adéquation du modèle linéaire et estimés de l'erreur
resultats <- emq[,c(2,1,3:6)]
colnames(resultats) <- c("EMQ","EMQa","R2","R2ajust","AIC","BIC")


# Graphique 
emqdat <- data.frame(ordre = rep(1:10, length.out = 20), 
                     emq = c(emq[,2], rowMeans(emqcv)),
                     echantillon = factor(c(rep("théorique",10), rep("validation croisée", 10)))
)
ggplot(data = emqdat, aes(x=ordre, y=emq)) +
   geom_boxplot(data = data.frame(emq = c(t(emqcv)), 
                                  ordre = rep(1:10, each=100)), aes(group=ordre),show.legend = FALSE) +
   geom_point(aes(shape=echantillon, color=echantillon)) + 
   labs(title = "Erreur moyenne quadratique estimée en fonction de l'ordre", 
        x = "ordre du polynôme", 
        y = "erreur moyenne quadratique") + 
   theme(legend.position="bottom",
         legend.title=element_blank())



## Sélection de modèles (partie 2)

url <- "https://lbelzile.bitbucket.io/MATH60602/dbm.sas7bdat"
dbm <- haven::read_sas(url)
#Transformer les variables catégorielles en facteurs
dbm$x3 <- as.factor(dbm$x3)
dbm$x4 <- as.factor(dbm$x4)

library(leaps)
# Créer les variables binaires pour les variables catégorielles
dbm$x31 <- as.integer(dbm$x3==1)
dbm$x32 <- as.integer(dbm$x3==2)
dbm$x41 <- as.integer(dbm$x4==1)
dbm$x42 <- as.integer(dbm$x4==2)
dbm$x43 <- as.integer(dbm$x4==3)
dbm$x44 <- as.integer(dbm$x4==4)
# Créer les interactions et les variables carrées
attach(dbm)
dbm$cx2 <- x2^2
dbm$cx6 <- x6^2
dbm$cx7 <- x7^2
dbm$cx8 <- x8^2
dbm$cx9 <- x9^2
dbm$cx10 <- x10^2

dbm$i_x2_x1 <- x2*x1
dbm$i_x2_x31 <- x2*x31
dbm$i_x2_x32 <- x2*x32
dbm$i_x2_x41 <- x2*x41
dbm$i_x2_x42 <- x2*x42
dbm$i_x2_x43 <- x2*x43
dbm$i_x2_x44 <- x2*x44
dbm$i_x2_x5 <- x2*x5
dbm$i_x2_x6 <- x2*x6
dbm$i_x2_x7 <- x2*x7
dbm$i_x2_x8 <- x2*x8
dbm$i_x2_x9 <- x2*x9
dbm$i_x2_x10 <- x2*x10

dbm$i_x1_x31 <- x1*x31
dbm$i_x1_x32 <- x1*x32
dbm$i_x1_x41 <- x1*x41
dbm$i_x1_x42 <- x1*x42
dbm$i_x1_x43 <- x1*x43
dbm$i_x1_x44 <- x1*x44
dbm$i_x1_x5 <- x1*x5
dbm$i_x1_x6 <- x1*x6
dbm$i_x1_x7 <- x1*x7
dbm$i_x1_x8 <- x1*x8
dbm$i_x1_x9 <- x1*x9
dbm$i_x1_x10 <- x1*x10

dbm$i_x5_x31 <- x5*x31
dbm$i_x5_x32 <- x5*x32
dbm$i_x5_x41 <- x5*x41
dbm$i_x5_x42 <- x5*x42
dbm$i_x5_x43 <- x5*x43
dbm$i_x5_x44 <- x5*x44
dbm$i_x5_x6 <- x5*x6
dbm$i_x5_x7 <- x5*x7
dbm$i_x5_x8 <- x5*x8
dbm$i_x5_x9 <- x5*x9
dbm$i_x5_x10 <- x5*x10

dbm$i_x31_x41 <- x31*x41
dbm$i_x31_x42 <- x31*x42
dbm$i_x31_x43 <- x31*x43
dbm$i_x31_x44 <- x31*x44
dbm$i_x31_x6 <- x31*x6
dbm$i_x31_x7 <- x31*x7
dbm$i_x31_x8 <- x31*x8
dbm$i_x31_x9 <- x31*x9
dbm$i_x31_x10 <- x31*x10

dbm$i_x32_x41 <- x32*x41
dbm$i_x32_x42 <- x32*x42
dbm$i_x32_x43 <- x32*x43
dbm$i_x32_x44 <- x32*x44
dbm$i_x32_x6 <- x32*x6
dbm$i_x32_x7 <- x32*x7
dbm$i_x32_x8 <- x32*x8
dbm$i_x32_x9 <- x32*x9
dbm$i_x32_x10 <- x32*x10

dbm$i_x41_x6 <- x41*x6
dbm$i_x41_x7 <- x41*x7
dbm$i_x41_x8 <- x41*x8
dbm$i_x41_x9 <- x41*x9
dbm$i_x41_x10 <- x41*x10

dbm$i_x42_x6 <- x42*x6
dbm$i_x42_x7 <- x42*x7
dbm$i_x42_x8 <- x42*x8
dbm$i_x42_x9 <- x42*x9
dbm$i_x42_x10 <- x42*x10

dbm$i_x43_x6 <- x43*x6
dbm$i_x43_x7 <- x43*x7
dbm$i_x43_x8 <- x43*x8
dbm$i_x43_x9 <- x43*x9
dbm$i_x43_x10 <- x43*x10

dbm$i_x44_x6 <- x44*x6
dbm$i_x44_x7 <- x44*x7
dbm$i_x44_x8 <- x44*x8
dbm$i_x44_x9 <- x44*x9
dbm$i_x44_x10 <- x44*x10

dbm$i_x7_x6 <- x7*x6
dbm$i_x7_x8 <- x7*x8
dbm$i_x7_x9 <- x7*x9
dbm$i_x7_x10 <- x7*x10

dbm$i_x6_x8 <- x6*x8
dbm$i_x6_x9 <- x6*x9
dbm$i_x6_x10 <- x6*x10

dbm$i_x8_x9 <- x8*x9
dbm$i_x8_x10 <- x8*x10

dbm$i_x9_x10 <- x9*x10
detach(dbm)
dbm$x3 <- NULL
dbm$x4 <- NULL

dbmtrain <- dbm[(dbm$train == 1)&(dbm$yachat == 1),c(1:10,12)]
# La procédure fonctionne avec des variables catégorielles 
# (et donc pourrait garder/enlever un facteur à plusieurs niveaux)
allsubsets <- regsubsets(ymontant ~ x1+x2+x31+x32+x41+x42+x43+x44+x5+x6+x7+x8+x9+x10, 
                         nvmax = 13L, nbest = 1L,
                         method = "exhaustive",
                         data = dbmtrain)
allsub <- summary(allsubsets)
# Pas de AIC, mais on peut le calculer à partir du BIC
allsub$aic <- allsub$bic + seq_along(allsub$bic)*(2-log(nrow(dbmtrain)))
allsubtab <- data.frame(allsub$rsq, allsub$aic, allsub$bic)
colnames(allsubtab) <- c("$R^2$", "AIC","BIC")
#knitr::kable(allsubtab, digits = 2)
allsubtab
which.min(allsubtab[,"AIC"])
which.min(allsubtab[,"BIC"])

# Ces valeurs du AIC et du BIC diffèrent de celles de SAS
# mais sont comparables entre elles pour les modèles linéaires

#Sélection ascendante, descendante et séquentielle basé sur le AIC ou le BIC
#step or MASS::stepAIC
form <- as.formula(paste("ymontant ~" , paste(colnames(dbm)[-(9:12)], collapse = "+", sep = "")))

# Procédure de sélection séquentielle par AIC
seqAIC <- MASS::stepAIC(lm(ymontant ~ 1,
                           data = dbm, 
                           subset = (dbm$train == 1)&(dbm$yachat == 1)),
                        scope = form, 
                        direction="both", 
                        trace = FALSE,
                        keep = function(mod, AIC, ...){list(bic = BIC(mod), coef=coef(mod))})
# J'ai ajouté la valeur de BIC et les coefficients à chaque étape à une liste
whichminbic <- which.min(unlist(seqAIC$keep[1,]))
# On isole les paramètres du modèle avec le plus petit BIC
coefs <- seqAIC$keep[2, whichminbic]$coef
#Sélectionner les colonnes correspondant (pas nécessairement dans l'ordre!)
colscoefs <- match(names(coefs[-1]), colnames(dbm))
# Prédiction pour l'échantillon test
predBIC <- apply(as.matrix(dbm[(dbm$train==0)&(dbm$yachat==1),colscoefs]),
                 1, function(x){ sum(x*coefs[-1])+coefs[1]})
# Prédiction avec le modèle AIC (direct car c'est un modèle de classe "lm"
predAIC <- predict(object = seqAIC, 
                   newdata = dbm[(dbm$train==0)&(dbm$yachat==1),])
# Estimation de l'erreur moyenne quadratique
mean(unlist((predAIC - dbm[(dbm$train==0)&(dbm$yachat==1),"ymontant"])^2))
mean(unlist((predBIC - dbm[(dbm$train==0)&(dbm$yachat==1),"ymontant"])^2))
# Valeurs prédites quasi-égales
max(abs((predAIC - predBIC)))


ntrain <- sum((dbm$train==1)&(dbm$yachat==1))
traindat <- dbm[(dbm$train==1)&(dbm$yachat==1),]
# Moyenne de modèles par autoamorçage nonparamétrique
set.seed(20200207)
B <- 500L #nombre de réplications
bootstat <- function(dat, form, aic=FALSE){
  # Procédure de sélection avec AIC ou BIC
  modselect <- MASS::stepAIC(lm(formula = ymontant~1, data = dat),
                             scope = form,
                             k = ifelse(aic, 2, log(nrow(dat))), # BIC
                             direction = "both", trace = FALSE)
  # Créer un vecteur avec tous les coefficients (initialement nuls)
  allparvec <- rep(0, ncol(dat)+1L)
  # Trouver quelles colonnes représentent un coefficient non-nul
  colind <- c(1L, match(names(modselect$coefficients[-1]), colnames(dat)) + 1L)
  # Remplacer cette valeur
  allparvec[colind] <- modselect$coefficients
  # Ajouter l'ordonnée à l'origine
  return(allparvec)
}
N <- nrow(traindat)

# Définir contenant
modaver <- matrix(nrow = B, ncol = ncol(traindat)+1L) 
for(i in seq_len(B)){  
  modaver[i,] <- bootstat(dat = traindat[sample.int(n = N, size = N, replace = TRUE),], 
                          form = form)
}

# Proportion des modèles dans laquelle la variable est sélectionnée
colMeans(modaver != 0)
# Averaged coefficients
meancoef <- colMeans(modaver)

# Valeurs prédites égales à x * betahat
emqmoymod <- mean(unlist(as.matrix(dbm[(dbm$train==0)&(dbm$yachat==1),]) %*% 
                           meancoef [-1] + meancoef [1] - 
                           dbm[(dbm$train==0)&(dbm$yachat==1),"ymontant"])^2)


# Sélection par LASSO
library(glmnet)
# Paramètre de pénalité déterminé par validation croisée
lambda_seq <- seq(0.1,2, by = 0.01)

cv_output <- cv.glmnet(x = as.matrix(traindat[,-(9:12)]), 
                       y = traindat$ymontant, 
                       alpha = 1, lambda = lambda_seq)

# On réestime le modèle, cette fois-ci avec la pénalité
lambopt <- cv_output$lambda.min
lasso_best <- glmnet(x = as.matrix(traindat[,-(9:12)]), 
                     y = traindat$ymontant,
                     alpha = 1, 
                     lambda = lambopt )
pred <- predict(lasso_best, s = lambopt, 
                newx = as.matrix(dbm[(dbm$train==0)&(dbm$yachat==1),-(9:12)]))
emqlasso <- mean(unlist((pred - dbm[(dbm$train==0)&(dbm$yachat==1),10])^2))
emqlasso