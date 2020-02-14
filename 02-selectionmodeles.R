## Chargers les données depuis le serveur
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
  


