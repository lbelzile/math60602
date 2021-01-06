# MATH 60602 - Analyse multidimensionnelle appliquée
# Analyse factorielle 
# 
# Le chiffrier `factor2.csv` contient les observations pour ces 12 questions. 
# Tout d'abord, les statistiques descriptives ainsi que la matrice des 
# corrélations qui suivent sont obtenues en exécutant les lignes suivantes:
path <- "https://lbelzile.bitbucket.io/MATH60602/factor.csv"
facto <- read.csv(file = path, header = TRUE)

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
# ATTENTION: ce script ne retourne pas les mêmes valeurs
# pour les critères d'information que SAS (et les différences ne sont pas égales)
# Cela semble un problème avec les valeurs de BIC de SAS
logLik.factanal <- function(object, ...) {
  # Log-vraisemblance de la loi de Wishart
  n <- object$n.obs
  x <- object$correlation
  p <- nrow(x)
  L <- object$loadings
  psi <- object$uniquenesses
  k <- object$factors
  p <- nrow(object$correlation)
  V <- tcrossprod(L) + diag(psi)
  as.numeric(
    -n/2*(determinant(V, logarithm = TRUE)$modulus - sum(diag(solve(V) %*% x)))
    # -n*p/2*log(2)+ p*(p-1)/4 * log(pi) - sum(lgamma((n + 1 - 1:p)/2)) +
    # (n-p-1)/2*determinant(x)$modulus 
    
  )
}

AIC.factanal <- function(object, ...){
  n <- object$n.obs
  k <- object$factors
  p <- nrow(object$correlation)
  as.numeric(-2*logLik(object ) + 2*p*(k+1)-k*(k-1))
}

BIC.factanal <- function(object, ...){
  n <- object$n.obs
  k <- object$factors
  p <- nrow(object$correlation)
  as.numeric(-2*logLik(object) + log(n)*(p*(k+1)-k*(k-1)/2))
}

  # Boucle pour calculer les AIC, BIC et la valeur-p du test d'adéquation
  emv_crit <- matrix(0, ncol = 3, nrow = 5)
  for(i in 1:5){
    fai <- factanal(x = facto, factors = i)
    emv_crit[i,] <- c(AIC(fai), BIC(fai), fai$PVAL)
  }
  colnames(emv_crit) <- c("AIC","BIC","valeur-p")
  
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
  