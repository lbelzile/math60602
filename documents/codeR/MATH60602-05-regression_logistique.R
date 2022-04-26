# MATH 60602 - Analyse multidimensionnelle appliquée
# Régression logistique et extensions

url <- "https://lbelzile.bitbucket.io/MATH60602/logit1.sas7bdat"
logit1 <- haven::read_sas(url)
mod1 <- glm(formula = y~x5, family=binomial(link="logit"), data=logit1)
summary(mod1)
cote <- exp(mod1$coefficients) #cote
#intervalles de confiance profilés pour les paramètres
confbeta <- confint(mod1) 
confbeta
# intervalles de confiance pour la cote
exp(confbeta) 
# tester significativité globale par rapport de vraisemblance
anova(mod1, test = 'Chisq')
# Critères d'information (définis à constante près)
AIC(mod1); #-2*logLik(mod1) + 2*length(coef(mod1))
BIC(mod1); #-2*logLik(mod1) + log(nrow(mod1$data))*length(coef(mod1))
-2*logLik(mod1)

# Test du rapport de vraisemblance (automatique)
mod2 <- glm(formula = y~factor(x1) + factor(x2) + x3 + x4 + x5 + factor(x6), family=binomial(link="logit"), data=logit1)
anova(mod2, test = "Chisq")
# On peut le faire manuellement et comparer les deux modèles
mod3 <- glm(formula = y~factor(x1) + factor(x2) + x3 + x4 + x5, family=binomial(link="logit"), data=logit1)
anova(mod3, mod2, test="Chisq")
# ou calculer la statistique manuellement
D <- 2*as.numeric(logLik(mod2)-logLik(mod3))
pchisq(q = D, df = 2, lower.tail = FALSE)



# Estimation conjointe de la probabilité d'achat et du montant d'achat
# L'avantage du modèle avec les variables latente, c'est qu'on combine l'information
# et donc l'estimation est plus précise. On a pas non plus de point de coupure
# à estimer

url <- "https://lbelzile.bitbucket.io/MATH60602/dbm.sas7bdat"
dbm <- haven::read_sas(url)
# Transformer les variables catégorielles en facteurs
dbm$x3 <- factor(dbm$x3)
dbm$x4 <- factor(dbm$x4)
# Ne conserver que l'échantillon d'apprentissage
train <- dbm[(dbm$train == 1),]
test <- dbm[(dbm$test == 1),]
# Modèle Tobit de type II

library(sampleSelection)
fachat <- as.formula(yachat ~ x2 + I(x4 == 1) + x1:x2 + x2:x10 +
                       x1:x5 + x1:x10 + x5:I(x3==2) + I(x3==1)*I(x4==4) + 
                       I(x4==1)*x7 + I(x4==3)*x8 + x7:x8 + x6:x8 + x6:x10)
fmontant <- as.formula(ymontant ~ I(x3==2) + I(x4==4) + x5 + x7 + x10 + I(x6^2) +
                         I(x10^2) + x2:I(x3==1) + x2:I(x4==3) + x1:I(x4==3) + 
                         x1:x6 + x1:x10 + x5:x8 + x5:x10 + I(x3==1):I(x4==1) + 
                         I(x3==1):x8 + I(x3==2):x8 + I(x4==1):x8 + I(x4==2):x8 + 
                         I(x4==4):x6 + I(x4==4):x9 + x8:x10)
heckit.ml <- heckit(selection = fachat,
                    outcome = fmontant, 
                    method = "ml", data = train)
summary(heckit.ml)
pred_achat <- predict(heckit.ml, part = "selection", newdata = test, type = "response") * predict(heckit.ml,part = "outcome", newdata = test)
#Remplacer valeurs manquantes par zéros
test$ymontant[is.na(test$ymontant)] <- 0
# On envoie le catalogue seulement si le montant d'achat prédit est supérieur à 10$
# Revenu total avec cette stratégie
sum(test$ymontant[which(pred_achat > 10)] - 10)

# Régression logistique, partie 2

url <- "https://lbelzile.bitbucket.io/MATH60602/dbm.sas7bdat"
dbm <- haven::read_sas(url)
# Transformer les variables catégorielles en facteurs
dbm$x3 <- factor(dbm$x3)
dbm$x4 <- factor(dbm$x4)
# Ne conserver que l'échantillon d'apprentissage
train <- dbm[(dbm$train == 1),]
# Formule pour la moyenne du modèle logistique
form <- formula("yachat ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10")
# Créer un conteneur pour les probabilités
n <- nrow(train)
loocv_prob <- rep(0, n)
# Calculer la prédiction avec validation croisée (n groupes)
# On retourne la probabilité de façon à obtenir le taux de mauvaise classification
# la sensibilité et la spécificité pour différents seuils
for(i in 1:n){
  mod <- glm(data = train, 
             formula = form, 
             family = binomial(link="logit"),
             subset = -i)
  loocv_prob[i] <- predict(mod, newdata = train[i,], type = "response")
}



# Histogramme des probabilités prédites par validation croisée avec n groupes
hist(loocv_prob, 
     breaks = 25, 
     xlab = "Probabilité d'achat prédite", 
     ylab = "densité", main = "")
#  Modèle complet et valeurs prédites
train_prob <- fitted(glm(data = train, 
                         formula = form, 
                         family=binomial), 
                     type = "response") 

perfo <- function(prob, resp){
  # VRAI == 1, FAUX == 0
  cuts <- seq(from = 0.01, to = 0.99, by = 0.01)
  tab <- data.frame(coupe = cuts,
                    t(sapply(cuts, function(cut){
                      nsucces <- sum(resp == 1)
                      nechec <- length(resp) - nsucces
                      n <- length(resp)
                      predy <- ifelse(prob >= cut, 1, 0) 
                      c1 <- sum(predy & resp) # Y=1, Yhat=1
                      c0 <- sum(!predy & !resp) # Y=0, Yhat=0
                      i1 <- sum(!predy & resp) # Y=1, Yhat=0
                      i0 <- sum(predy & !resp) # Y=0, Yhat=1
                      c(c1 = c1, 
                        c0 = c0, 
                        i0 = i0,
                        i1 = i1,      
                        pcorrect = 100*(c0+c1)/n, 
                        sensi = 100*c1/(c1+i1), # Y=1 & Yhat=1 / # Y=1
                        speci = 100*c0/(c0+i0), # Y=0 & Yhat=0 / # Y=0
                        fpos = 100*i0/(c1+i0), # Y=0 & Yhat=1 / # Yhat=1
                        fneg = 100*i1/(c0+i1)) # Y=1 & Yhat=0 / # Yhat=0
                    })))
}


# Performance du modèle avec données d'apprentissage
perfo0 <- perfo(prob = train_prob, resp = train$yachat)
perfo1 <- perfo(prob = loocv_prob, resp = train$yachat, plot = TRUE)
perfo1
knitr::kable(perfo1, digits = c(2, rep(0,4), rep(1,5)), 
             col.names = c("coupe",
                           "correct (1)",
                           "correct (0)",
                           "erreur (1)",
                           "erreur (0)",
                           "correct (%)",
                           "sensibilité (%)",
                           "spécificité (%)",
                           "faux positif (%)",
                           "faux négatif (%)"),
             escape = TRUE)
perfo1$cut
perfo1$confusion

# La fonction cv.glm permet aussi de faire la validation croisée, 
# Définir une fonction de coût, mais pour un seul point de coupure
# cost <- function(yachat, pi = 0){ 1-mean(abs(yachat - (pi > 0.56)))}
# vcboot <- boot::cv.glm(data = train, 
#                         glmfit = glm(data = train, 
#                                      formula = form, family=binomial), 
#                                      cost = cost)$delta

# Calculer la courbe lift
lift <- function(prob, resp){
  od <- order(prob, decreasing = TRUE)
  #Réordonner les observations
  resp <- resp[od]
  n <- length(resp)
  prand <- seq(1, sum(resp), length.out = length(resp))
  slift <- cumsum(resp)/prand
  plot(x = prand/sum(resp), y= cumsum(resp)/sum(resp),
       ylim = c(0, 1), xlim = c(0, 1), yaxs= "i", 
       xaxs = "i", bty = "l", type= "s", 
       panel.first = abline(a = 0, b = 1, lty = 2),
       xlab = "Pourcentage de positifs classés",
       ylab = "Pourcentage de positifs détectés")
  return(slift)
}

lift(prob = loocv_prob, resp = train$yachat)


# SÉLECTION DE MODÈLES 
# Fonction pour trouver le point de coupure optimal
cutoff <- function(model, c00 = 1, c11 = 1, c01 = 0, c10 = 0, 
                   plot = FALSE, nrep = 10L, ncv = 10L){
  nrep <- as.integer(nrep)
  ncv <- as.integer(ncv)
  stopifnot(nrep > 0, ncv > 1)
  # model$data$y <- model$y
  n <- nrow(model$data)
  perfor_cv <- replicate(n = nrep, expr = {
    #Shuffle the indices
    inds <- sample.int(n = n, size = n, replace = FALSE)
    #Split into K groups of ~ equal size (from https://stackoverflow.com/a/16275428)
    form_group <- function(x, n){ split(x, cut(seq_along(x), n, labels = FALSE)) }
    groups <- form_group(inds, ncv)
    probs <- rep(0, n)
    for(j in 1:ncv){
      probs[groups[[j]]] <- predict(glm(model$formula, 
                                        family = model$family, 
                                        data = model$data[-groups[[j]],]), 
                                    newdata = model$data[groups[[j]],], type = "response")
    }
    perfo <- perfo(probs, resp = model$y)
    gain <- perfo$c0 * c00 + perfo$c1 * c11 + perfo$i0 *c10 + perfo$i1 * c01
    gain
  })
  meanperfo <- rowMeans(perfor_cv)
  cut <- seq(from = 0.01, to = 0.99, by = 0.01)
  if(plot){
    plot(cut, meanperfo, xlab = "coupe", ylab = "gain moyen")
  }
  cut[which.max(meanperfo)]
}
# Modèle avec toutes les variables principales
princi <- glm(yachat ~ ., data = train[,1:11], family = binomial) 
princi_coupe <- cutoff(princi, c00 = 0, c01 = 0, c10 = -10, c11 = 57)
# Modèle avec toutes les interactions d'ordre 2 et termes quadratiques
form <- formula(yachat ~ .*. + I(x2^2) + I(x6^2) + I(x7^2) + I(x8^2) + I(x9^2) + I(x10^2))
complet <- glm(formula = form, 
               data = train[,1:11], family = binomial(link="logit"))
complet_coupe <- cutoff(complet, c00 = 0, c01 = 0, c10 = -10, c11 = 57)
# Nouvelle base de données avec toutes ces variables
trains <- data.frame(cbind(y = train$yachat, model.matrix(complet)[,-1]))
trains$y <- as.integer(trains$y)
# Sélection de modèle avec algorithme glouton
# Recherche séquentielle par AIC ou BIC
sequAIC <- step(object = complet, 
                direction = "both", # séquentielle
                k = 2, trace = 0) # AIC 
sequAIC_coupe <- cutoff(sequAIC, c00 = 0, c01 = 0, c10 = -10, c11 = 57)
sequBIC <- step(object = complet,
                direction = "both", # séquentielle
                k = log(length(complet$y)), trace = 0) # AIC 
sequBIC_coupe <- cutoff(sequBIC, c00 = 0, c01 = 0, c10 = -10, c11 = 57)
# Sélection de modèles - très lent par rapport à SAS
# la raison est que SAS n'ajuste que le modèle SANS 
# covariable et calcule plutôt uniquement le test du score 
# pour beta_1 = ... = beta_p=0 pour un sélection de modèles avec
# un algorithme de séparation et d'évaluation
# library(bestglm)
# exhprBIC <- bestglm(trains[, c(2:15,1)], IC="BIC", family=binomial)
# exhprBIC_coupe <- cutoff(exhprBIC$BestModel, c00 = 0, c01 = 0, c10 = -10, c11 = 57)
# exhprAIC <- bestglm(trains[,c(2:15,1)], IC="AIC", family=binomial)
library(glmulti)
#Alternative plus rapide, mais néanmoins coûteuse
exhprAIC <- glmulti(y ~ ., data = trains[,1:15],
                    level = 1,               # sans interaction
                    method = "h",            # recherche exhaustive
                    crit = "aic",            # critère (AIC, BIC, ...)
                    confsetsize = 1,         # meilleur modèle uniquement
                    plotty = FALSE, report = FALSE,  # sans graphique ou rapport
                    fitfunction = "glm")    
exhprBIC <- glmulti(y ~ ., data = trains[,1:15],
                    level = 1,               # sans interaction
                    method = "h",            # recherche exhaustive
                    crit = "bic",            # critère (AIC, BIC, ...)
                    confsetsize = 1,         # meilleur modèle uniquement
                    plotty = FALSE, report = FALSE,  # sans graphique ou rapport
                    fitfunction = "glm")

summary(exhprAIC@objects[[1]])
exhprAIC_coupe <- cutoff(exhprAIC@objects[[1]], c00 = 0, c01 = 0, c10 = -10, c11 = 57)
exhprBIC_coupe <- cutoff(exhprBIC@objects[[1]], c00 = 0, c01 = 0, c10 = -10, c11 = 57)
exhgenetic <- glmulti(y ~ ., data = trains[,1:31],  #nombre de variables limitées
                      level = 1,               # sans interaction
                      method = "g",            # recherche 
                      crit = "bic",            # critère (AIC, BIC, ...)
                      confsetsize = 1,         # meilleur modèle uniquement
                      plotty = FALSE, report = FALSE,  # sans graphique ou rapport
                      fitfunction = "glm") 
exhgenetic_coupe <- cutoff(exhgenetic@objects[[1]], c00 = 0, c01 = 0, c10 = -10, c11 = 57)
# NOUVEAU
# L'algorithme algorithme de séparation et d'évaluation 
# pour la régression logistique avec les critères 
# d'information est implémenté dans R, mais pas pour les
# tests de score
library(glmbb)
#Attention: intensif en calcul
# Ici, sans les interactions; la syntaxe (x1 + x2)^2 donnerait toutes les interactions d'ordre 2
bbBIC <- glmbb::glmbb(yachat ~ (x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10) + I(x2^2) + I(x6^2) + I(x7^2) + I(x8^2) + I(x9^2) + I(x10^2),
                      family = binomial(link="logit"),
                      criterion = "BIC", data = train[,1:11])  
summary(bbBIC)

# LASSO
library(glmnet)
cvfit <- cv.glmnet(x = as.matrix(trains[,-1]), 
                   y= trains$y, 
                   family = "binomial", 
                   type.measure = "auc")
lasso <- glmnet::glmnet(x = as.matrix(trains[,-1]), 
                        y = trains$y, 
                        family = "binomial", 
                        alpha = cvfit$lambda.1se)

# Évaluer la performance du modèle sur l'échantillon test
test <- dbm[dbm$test == 1,]
# Nouvelle base de données avec toutes ces variables
testf <- data.frame(
  cbind(y = test$yachat, 
        model.matrix(formula(yachat ~ .*. + I(x2^2) + I(x6^2) + I(x7^2) + 
                               I(x8^2) + I(x9^2) + I(x10^2)), 
                     data = test[,1:11])[,-1]))
# Modèle 1: toutes les variables principales, sans sélection
princi_pred <- predict(object = princi, newdata = test, type = "response") > princi_coupe
-10*sum(princi_pred)+ sum(test[princi_pred,"ymontant"], na.rm = TRUE)

# Modèle 2: toutes les variables avec interactions et termes quadratiques
complet_pred <- predict(object = complet, newdata = test, type = "response") > complet_coupe
-10*sum(complet_pred)+ sum(test[complet_pred,"ymontant"], na.rm = TRUE)

# Modèle 3: BIC avec 15 variables de base
exhprBIC_pred <- predict.glm(object = exhprBIC@objects[[1]], newdata = testf, type = "response") > exhprBIC_coupe
-10*sum(exhprBIC_pred)+ sum(test[exhprBIC_pred,"ymontant"], na.rm = TRUE)

# Modèle 4: séquentielle selon BIC avec interactions et termes quadratiques
sequBIC_pred <- predict.glm(object = sequBIC, newdata = test, type = "response") > sequBIC_coupe
-10*sum(sequBIC_pred)+ sum(test[sequBIC_pred,"ymontant"], na.rm = TRUE)

# Modèle 5: séquentielle selon AIC avec interactions et termes quadratiques
sequAIC_pred <- predict.glm(object = sequAIC, newdata = test, type = "response") > sequAIC_coupe
-10*sum(sequAIC_pred)+ sum(test[sequAIC_pred,"ymontant"], na.rm = TRUE)


# Régression logistique, partie 3 
# Régression Tobit et multinomial
url <- "https://lbelzile.bitbucket.io/MATH60602/logit6.sas7bdat"
logit6 <- haven::read_sas(url)
# Modèle multinomial
multi1 <- nnet::multinom(y1 ~ x, data = logit6, Hess = TRUE)
summary(multi1)
# Prédiction du modèle, soit probabilité de chaque scénario
predict(multi1, type = "probs")
# Autrement, la classe la plus susceptible
predict(multi1, type = "class")

# Modèle de régression logistique multinomiale ordinale à cote proportionnelle
multi2a <- MASS::polr(ordered(y2) ~ x, data = logit6, method = "logistic", Hess = TRUE)
multi2b <- nnet::multinom(y2 ~ x, data = logit6, Hess = TRUE)
confint(multi2b)
# Le modèle est paramétré en terme du rapport de cote, ascendant

# Test du rapport de vraisemblance pour modèle à cote proportionnelle
pchisq(-2*(logLik(multi2a)[[1]] - logLik(multi2b)[[1]]), df = 1, lower.tail = FALSE)
# Intervalles de confiance pour beta_x - vraisemblance profilée
confint(multi2a)
# Critères d'information
AIC(multi2a); BIC(multi2a)
# Exponentielle des paramètres beta
exp(cbind(coef(multi2b)[,"x"], t(confint(multi2b)[2,,])))

# On a ces intervalles uniquement pour les variables explicatives
# Ici, un seul beta pour x
# Tableau des coefficients exp(beta) avec l'IC - vraisemblance profilée
exp(c(coef(multi2a), confint(multi2a)))

# intervalles de Wald avec confint.default
c(coef(multi2a), confint.default(multi2a))


# Pour un exemple plus détaillé, voir
# https://stats.idre.ucla.edu/r/dae/ordinal-logistic-regression/


