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
ggplot(data = train, 
       mapping = aes(x=x,y=y)) + 
       geom_point()

# Validation croisée avec k groupes
lmkfold <- function(formula, data, k, ...){
   # Créer un accumulateur pour le calcul de l'EQM
   accu <- 0
   k <- as.integer(k) # nombre de groupes
   n <- nrow(data) # nombre d'observations
   # Permuter les indices des observatoins
   gp <- sample.int(n, n, replace = FALSE)
   # Créer une liste de k éléments avec les nos d'observations
   folds <- split(gp, cut(seq_along(gp), k, labels = FALSE))
   for(i in seq_len(k)){
      # Extraire les indices des observations de la portion validation
      g <- as.integer(unlist(folds[i]))
      # Ajuster le modèles à toutes les données, moins celles de la portion validation
      fitlm <- lm(formula, data = data[-g,])
      # ajouter l'erreur quadratique du pli de validation
      accu <- accu + sum((data[g, all.vars(formula)[1]] -predict(fitlm, newdata=data[g,]))^2)
   }
   # Diviser par la taille de l'échantillon pour obtenir la moyenne
   return(accu/n)
}

# Créer un contenant pour l'erreur quadratique moyenne
eqm <- matrix(0, nrow = 10, ncol = 7)
eqmcv <- matrix(0, nrow = 10, ncol = 100)
library(caret)
library(ggplot2)
for(i in 1:10){
   set.seed(i*1000)
   # Créer le modèle avec une chaîne de caractère pour le polynôme
   meanmod <- reformulate(response = "y", 
                          termlabels = paste0("I(x^", 1:i,")"))
   mod <-  lm(meanmod, data = train)
   # Calculer l'erreur moyenne dans les deux échantillons
   eqm[i,1:2] <- c(mean(resid(mod)^2), #apprentissage
                    mean((test$y - predict(mod, newdata = test))^2)) #échantillon test
   eqm[i,3] <- summary(mod)$r.squared
   eqm[i,4] <- summary(mod)$adj.r.squared
   eqm[i,5] <- AIC(mod) # Valeurs pas identiques à la sortie SAS, mais comparables entre elles
   eqm[i,6] <- BIC(mod)
   # validation croisée avec 10 groupes
   eqmcv[i,] <-  replicate(n = 100L, 
                           train(form = meanmod, data = train, method = "lm",
                                 trControl = trainControl(method = "cv", 
                                                          number = 10))$results$RMSE^2)
   # eqm[i,7] <- lmkfold(formula = meanmod, data = train, k = 10)
}
eqm[,7] <- rowMeans(eqmcv)


eqmdat <- data.frame(ordre = rep(1:10, length.out = 20), 
                     eqm = c(eqm[,1:2]),
                     echantillon = factor(c(rep("apprentissage",10), rep("théorique", 10)))
)
ggplot(data = eqmdat, aes(x=ordre, y=eqm, color=echantillon)) +
   geom_line() + 
   geom_point(aes(shape=echantillon, color=echantillon)) + 
   labs(title = "Erreur moyenne quadratique estimée en fonction de l'ordre", 
        x = "ordre du polynôme", 
        y = "erreur moyenne quadratique") + 
   theme(legend.position="bottom",
         legend.title=element_blank())

#Mesures d'adéquation du modèle linéaire et estimés de l'erreur
resultats <- eqm[,c(2,1,3:6)]
colnames(resultats) <- c("eqm","eqma","R2","R2ajust","AIC","BIC")


# Graphique 
eqmdat <- data.frame(ordre = rep(1:10, length.out = 20), 
                     eqm = c(eqm[,2], rowMeans(eqmcv)),
                     echantillon = factor(c(rep("théorique",10), rep("validation croisée", 10)))
)
ggplot(data = eqmdat, aes(x = ordre, y = eqm)) +
   geom_boxplot(data = data.frame(eqm = c(t(eqmcv)), 
                                  ordre = rep(1:10, each = 100)), 
                mapping = aes(group = ordre),
                show.legend = FALSE) +
   geom_point(aes(shape = echantillon, 
                  color = echantillon)) + 
   labs(title = "Erreur moyenne quadratique estimée en fonction de l'ordre", 
        x = "ordre du polynôme", 
        y = "erreur moyenne quadratique") + 
   theme(legend.position="bottom",
         legend.title=element_blank())



## Sélection de modèles (partie 2)
library(leaps)
url <- "https://lbelzile.bitbucket.io/MATH60602/dbm.sas7bdat"
dbm <- haven::read_sas(url)
# Transformer les variables catégorielles en facteurs
# Je fixe le niveau de référence pour copier SAS
dbm$x3 <- relevel(factor(dbm$x3), ref = 3)
dbm$x4 <- relevel(factor(dbm$x4), ref = 5)
str(dbm)
# (...)^2 crée toutes les interactions d'ordre deux
# I(x^2) permet de créer les termes quadratiques
formule <- formula(ymontant ~ (x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10)^2 + I(x2^2) + I(x6^2) + I(x7^2) + I(x8^2) + I(x9^2) + I(x10^2))
dbm_entrainement <- 
  as.data.frame(cbind(ymontant = dbm$ymontant[!is.na(dbm$ymontant) & dbm$train == 1L], 
        model.matrix(object = formule, 
                     data = dbm[dbm$train == 1L,])[,-1]))
dbm_validation <- 
  as.data.frame(cbind(ymontant = dbm$ymontant[!is.na(dbm$ymontant) & dbm$train == 0L], 
                      model.matrix(object = formule, 
                                   data = dbm[dbm$train == 0L,])[,-1]))

# La procédure fonctionne avec des variables catégorielles 
# (et donc pourrait garder/enlever un facteur à plusieurs niveaux)
exhaustive <- leaps::regsubsets(ymontant ~ 
                           x1+x2+x31+x32+x41+x42+x43+
                           x44+x5+x6+x7+x8+x9+x10, 
                         nvmax = 13L, 
                         nbest = 1L,
                         method = "exhaustive",
                         data = dbm_entrainement)
exhaustive_mod <- summary(exhaustive)
# Pas de AIC, mais on peut le calculer à partir du BIC
exhaustive_mod$aic <- exhaustive_mod$bic + seq_along(exhaustive_mod$bic)*(2-log(nrow(dbm_entrainement)))
exhaustive_modtab <- data.frame(exhaustive_mod$rsq, exhaustive_mod$aic, exhaustive_mod$bic)
colnames(exhaustive_modtab) <- c("$R2$", "AIC","BIC")
#knitr::kable(exhaustive_modtab, digits = 2)
exhaustive_modtab
which.min(exhaustive_modtab[,"AIC"])
which.min(exhaustive_modtab[,"BIC"])

# Ces valeurs du AIC et du BIC diffèrent de celles de SAS
# mais sont comparables entre elles pour les modèles linéaires

#Sélection ascendante, descendante et séquentielle basé sur le AIC ou le BIC
#step or MASS::stepAIC


# Procédure de sélection séquentielle par AIC
# Note: la façon de faire la procédure séquentielle 
# est légèrement différente de celle de SAS. 
# C'est pourquoi le modèle final peut être différent. 
# Avec glmselect en SAS, on fait obligatoirement (au moins) 
# une étape descendante après avoir ajouté une variable.  
# Ainsi, après avoir ajouté une variable, il est possible d'en 
# retirer une si cela améliore le critère de sélection 
# (par exemple le AIC), même si en ajouter une autre 
# dès maintenant aurait amélioré le critère encore plus.   
# Avec stepAIC en R, il n'y a pas de con_entrainementtes et, 
# à chaque étape, on ajoute ou retire la variable qui
# améliore le plus le critère de sélection. 
modelcomplet <- lm(ymontant ~ ., data = dbm_entrainement)
seqAIC <- MASS::stepAIC(lm(ymontant ~ 1,
                           data = dbm_entrainement), 
                        scope = formula(modelcomplet), 
                        direction = "both", 
                        trace = FALSE,
                        keep = function(mod, AIC, ...){
                          list(bic = BIC(mod), 
                               coef = coef(mod))})
# J'ai ajouté la valeur de BIC et les coefficients à chaque étape à une liste
whichminbic <- which.min(unlist(seqAIC$keep[1,]))
# On isole les paramètres du modèle avec le plus petit BIC
coefs <- seqAIC$keep[2, whichminbic]$coef

# Formule du modèle BIC 
formule_seq_bic <- reformulate(response = "ymontant",
                               termlabels = paste0(names(seqAIC$keep[2, whichminbic]$coef)[-1]))
seqBIC <- lm(formule_seq_bic, data = dbm_entrainement)
# coefs[1] est l'ordonnée à l'origine
# Prédiction avec le modèle AIC (direct car c'est un modèle de classe "lm"
predAIC <- predict(object = seqAIC, 
                   newdata = dbm_validation)
predBIC <- predict(object = seqBIC, 
                   newdata = dbm_validation)
# Estimation de l'erreur moyenne quadratique
mean((predAIC - dbm_validation$ymontant)^2)
mean((predBIC - dbm_validation$ymontant)^2)
# Valeurs prédites égales


# Moyenne de modèles par autoamorçage nonparamétrique
set.seed(20200207)

#' Moyenne de modèles 
#' 
#' Fonction pour faire la procédure séquentielle avec
#' critères d'information. De nouveaux jeux de données
#' sont obtenues par autoamorçage nonparamétrique
#' (tirage avec remplacement).
#' 
#' @param dat jeu de données
#' @param form formule pour le modèle linéaire
#' @param aic logique; si \code{FALSE}, le critère BIC est employé
#' @param B nombre de répétitions
#' @return un vecteur de coefficients correspondant à la formule
moyennemodeles <- function(
    data, 
    form, 
    aic = FALSE, 
    B = 100L){
  B <- as.integer(B)
  stopifnot(is.logical(aic),
            length(aic) == 1L,
            inherits(form, "formula"),
            B > 1,
            inherits(data, "data.frame"))
  N <- nrow(data)
  matmod <- model.matrix(form, data = data)
  p <- ncol(matmod) - 1L
  fmod <- formula(paste0("y ~", paste0("x", seq_len(p), collapse = "+")))
  noms <- colnames(matmod)
  nom_reponse <- all.vars(form)[attr(terms(form), "response")]
  matmod <- data.frame(cbind(
    y = get(nom_reponse, data), 
    matmod[,-1]))
    # Créer un vecteur avec tous les coefficients (initialement nuls)
  params <- rep(0, length(noms))
  nselect <- rep(0, length(noms) - 1L)

  # Boucle
  for(b in seq_len(B)){
  # Procédure de sélection avec AIC ou BIC
  modselect <- MASS::selectAIC(
    lm(formula = formula(paste0("y~1")), 
   # Rééchantillonner données (avec remplacement)
       data = matmod[sample.int(n = N, 
                             size = N, 
                             replace = TRUE),]),
    scope = fmod,
    k = ifelse(aic, 2, log(N)), # BIC
    direction = "both", 
    trace = FALSE)

  # Trouver quelles colonnes représentent un coefficient non-nul
  colind <- match(names(modselect$coefficients),
                  noms)
  # Remplacer cette valeur
  params[colind] <- params[colind] + modselect$coefficients
  nselect[colind[-1]] <- nselect[colind[-1]] + 1L
  }
  names(nselect) <- noms[-1]
  names(params) <- noms
  return(list(coefs = params / B,
              nselect = nselect / B))
}


# Définir contenant
mmodeles <- 
  moyennemodeles(
    data = dbm_entrainement, 
    form = formule,
    B = 10L)

# Proportion des modèles dans laquelle la variable est sélectionnée
sum(mmodeles$nselect > 0)
# moyenne des coefficients
mmodeles$coefs
# Valeurs prédites égales à x * betahat
eqmmoymod <- mean((as.matrix(dbm_validation[,-1]) %*% mmodeles$coefs[-1] + meancoef [1] - 
                           dbm_validation$ymontant)^2)


# Sélection par LASSO
library(glmnet)
# Paramètre de pénalité déterminé par validation croisée
lambda_seq <- seq(0.1,2, by = 0.01)

cv_output <- cv.glmnet(x = as.matrix(dbm_entrainement[,-(9:12)]), 
                       y = dbm_entrainement$ymontant, 
                       alpha = 1, lambda = lambda_seq)

# On réestime le modèle, cette fois-ci avec la pénalité
lambopt <- cv_output$lambda.min
lasso_best <- glmnet(x = as.matrix(dbm_entrainement[,-1]), 
                     y = dbm_entrainement$ymontant,
                     alpha = 1, 
                     lambda = lambopt )
pred <- predict(lasso_best, 
                s = lambopt, 
                newx = as.matrix(dbm_validation[,-1]))
eqmlasso <- mean((pred - dbm_validation$ymontant)^2)
eqmlasso
