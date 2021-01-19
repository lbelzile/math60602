# MATH 60602 - Analyse multidimensionnelle appliquée
# Analyse factorielle 
# 
# Le chiffrier `factor2.csv` contient les observations pour ces 12 questions. 
# Tout d'abord, les statistiques descriptives ainsi que la matrice des 
# corrélations qui suivent sont obtenues en exécutant les lignes suivantes:
path <- "https://lbelzile.bitbucket.io/MATH60602/factor2.sas7bdat"
facto <- haven::read_sas(path)
# Statistiques descriptives de base
summary(facto)

cormat <- cor(facto, method = "pearson")
round(cormat, digits = 2)

# Ajuster le modèle factoriel par maximum de vraisemblance
fa4 <- factanal(x = facto, factors = 4L)
# Imprimer les chargements en omettant les valeurs inférieures à 0.3
print(fa4$loadings, cutoff = 0.3)
# Valeur-p pour le test du rapport de vraisemblance 
# (adéquation de la structure de corrélation paramétrique)
fa4$PVAL
# Méthodes S3 de base pour objects de classe "factanal"
logLik.factanal <- function(object, ...) {
  # Log-vraisemblance de la loi de Wishart
  n <- object$n.obs
  L <- object$loadings
  psi <- object$uniquenesses
  V <- tcrossprod(L) + diag(psi)
  #Johnson & Wichern, eq. 9.35
  -n/2*(as.numeric(determinant(V, logarithm = TRUE)$modulus) + sum(diag(solve(V) %*% object$correlation))) 
}
nobs.factanal <- function(object, ...){
  k <- object$factors
  p <- nrow(object$correlation)
  p*(k+1)-k*(k-1)/2
}
AIC.factanal <- function(object, ...){
  n <- object$n.obs
  k <- object$factors
  p <- nrow(object$correlation)
  as.numeric(-2*logLik(object) + 2*nobs(object))
}

BIC.factanal <- function(object, ...){
  n <- object$n.obs
  k <- object$factors
  p <- nrow(object$correlation)
  as.numeric(-2*logLik(object) + log(n)*nobs(object))
}

  # Boucle pour calculer les AIC, BIC et la valeur-p du test d'adéquation
  emv_crit <- matrix(0, ncol = 4, nrow = 5)
  for(i in 1:nrow(emv_crit)){
    # corrmat_facto <- cov2cor((nrow(facto)-1)/nrow(facto)*cov(facto, use = "pairwise.complete.obs"))
    fai <- factanal(x = facto, factors = i)
    # fai <- factanal(factors = i, covmat = cormat_facto, n.obs = nrow(facto))
    # fai <- psych::fa(r = as.matrix(facto), nfactors = i, fm = "ml")
    # fai$correlation <- cor(facto)
    # class(fai) <- "factanal"
    emv_crit[i,] <- c(i, AIC(fai), BIC(fai), fai$PVAL)
  }
  colnames(emv_crit) <- c("k","AIC","BIC","valeur-p")
  emv_crit
  
  which.min(emv_crit[,'AIC']) # nombre de facteurs selon AIC
  which.min(emv_crit[,'BIC']) # nombre de facteurs selon BIC
  which(emv_crit[,"valeur-p"] > 0.05)[1] # # nombre minimal de facteurs selon test du khi-deux
  # NDLR: l'estimation par maximum de vraisemblance est 
  # très sensible au choix de l'algorithme d'optimisation
  # SAS ajuste le critère AIC en cas de solution impropre (Heywood),
  # mais les valeurs de BIC de SAS sont illogiques
  # (car l'écart entre AIC et BIC dans SAS diminue à mesure que le nombre de facteurs, 
  # et donc de paramètres, augmente)
  
  # Critère de Kaiser: valeurs propres de la matrice de corrélation supérieures à 1
  valpropres <- eigen(cor(facto), only.values = TRUE)$values
  critkaiser <- sum(valpropres>1)
  # Diagramme d'éboulis: nombre de facteur égale à la dernière valeur propre
  # avant le plateau (coude)
  plot(x = 1:length(valpropres), 
       y = valpropres, 
       xlab = "nombre de facteurs",
       ylab = "valeurs propres",
       main = "diagramme d'éboulis")  
  
  # L'objet de classe `factanal` contient d'autres informations
  # La matrice de rotation varimax (matrice de rotation orthogonale)
  #isTRUE(all.equal(crossprod(fa4$rotmat), diag(4)))
  # Variance des erreurs epsilon (uniqueness)
  # Une valeur près de 1 (0.005) indique que la solution est un cas de Heywood
  # C'est le cas pour le modèle avec quatre facteurs
  #fa4$uniquenesses

  # Création des échelles
  ech_service <- rowMeans(facto[,c("x4","x8","x11")])
  ech_produit <- rowMeans(facto[,c("x3","x6","x9","x12")])
  ech_paiement <- rowMeans(facto[,c("x2","x7","x10")])
  ech_prix <- rowMeans(facto[,c("x1","x5")])
  
  # Cohérence interne (alpha de Cronbach)
  alpha_Cronbach <- function(x){
   S2 <- var(rowSums(x))
   ncol(x)/(ncol(x)-1)*(S2-sum(apply(x, 2, var)))/S2
  }
  alpha_Cronbach(facto[,c("x4","x8","x11")])
  # Autre alternative: la fonction du paquetage psych
  #psych::alpha(facto[,c("x4","x8","x11")])$total$raw_alpha
  alpha_Cronbach(facto[,c("x3","x6","x9","x12")])
  alpha_Cronbach(facto[,c("x2","x7","x10")])
  alpha_Cronbach(facto[,c("x1","x5")])
  
  # Estimation avec corrélation polychronique (avec avertissement - ignorez-le)
  polychor <- psych::polychoric(facto)$rho
  fa_poly <- factanal(covmat = polychor, factors = 3, n.nobs = 200L)
  # Estimation à l'aide de la méthode des composantes principales
  fa_compprin <- psych::principal(r = facto, nfactors = 3L, rotate="varimax")
  # Rotation oblique promax (autres options avec psych::fa, voir rotate)
  fa_obvarimax <- factanal(x = facto, factors = 3, rotation = "promax")
  
  # Calcul des prédictions des facteurs et des scores (méthode de régression)
  poids_fact <- t(fa4$loadings) %*% solve(fa4$correlation)
  scores <- tcrossprod(scale(facto, center = TRUE, scale = TRUE), poids_fact)
  # Retourner les scores - voir option ci-dessous avec scores = "reg"
  # On vérifie que les résultats sont identiques à ceux de notre calcul manuel
  isTRUE(all.equal(scores, factanal(x = facto, factors = 4L, scores = "regression")$scores))
  