# MATH 60602 - Analyse multidimensionnelle appliquée
# Analyse factorielle 
# 
library(hecmulti)
data(factor, package = "hecmulti")
# Statistiques descriptives de base
summary(factor)

# Matrice de corrélation
cormat <- cor(factor, method = "pearson")
round(cormat, digits = 2)

# Analyse en composantes principales
acp <- princomp(factor, corr = TRUE)
biplot(acp)
# Conserver
cp <- with(acp, scores[ , sdev>1])


# Ajuster le modèle factoriel par maximum de vraisemblance
fa4 <- factanal(x = factor, 
                factors = 4L,
                covmat = cov(factor))
# Imprimer les chargements en omettant les valeurs inférieures à 0.3
print(fa4$loadings, cutoff = 0.3)
# Valeur-p pour le test du rapport de vraisemblance 
# (adéquation de la structure de corrélation paramétrique)
fa4$PVAL

# Le paquet hecmulti contient des méthodes pour 
# extraire la log-vraisemblance, les critères d'information 
# pour un modèle d'analyse factorielle 
# (objet de classe "factanal")
emv_crit <- adjustement_factanal(covmat = cov(factor),
                              factors = 1:5,
                              n.obs = nrow(factor))
emv_crit
# nombre de facteurs selon AIC
which.min(emv_crit$AIC) 
# nombre de facteurs selon BIC
which.min(emv_crit$BIC) 
# nombre minimal de facteurs selon test du khi-deux
which(emv_crit$pval > 0.05)[1] 

  
# Critère de Kaiser: valeurs propres de la matrice de corrélation supérieures à 1
# Décomposition matricielle valeurs propres/vecteurs propres
decompo <- eigen(cor(factor))
# Extraire le nombre de valeurs propres supérieures à 1
valpropres <- decompo$values
ckaiser <- sum(valpropres > 1)
Gamma_est <- decompo$vectors[,seq_len(ckaiser)] %*%
  diag(sqrt(valpropres[seq_len(ckaiser)]))
# Diagramme d'éboulis: nombre de facteur égal 
# à la dernière valeur propre avant le plateau (coude)
ggplot(data = data.frame(var = valpropres,
		         k = 1:length(valpropres)),
       mapping = aes(x = k, y = var)) + 
  geom_line() + 
  geom_point() + 
  scale_x_continuous(breaks = 1:length(valpropres),
                     minor_breaks = NULL) +
  labs(x = "nombre de facteurs",
       y = "variance")

# Supposons qu'on conserve quatre facteurs
facto_cp <- Gamma_est <- decompo$vectors[,seq_len(ckaiser)] %*%
  diag(sqrt(valpropres[seq_len(ckaiser)]))
# Solution avec rotation varimax
varimax(facto_cp)

# L'objet de classe `factanal` contient d'autres informations
# La matrice de rotation varimax (matrice de rotation orthogonale)
# isTRUE(all.equal(crossprod(fa4$rotmat), diag(4)))
# Variance des erreurs epsilon (unicité, uniqueness)
# Une valeur près de 1 (à 0.005) indique que la 
# solution est un cas de Heywood
# C'est le cas pour le modèle avec quatre facteurs
# fa4$uniquenesses

# Création des échelles
ech_service <- rowMeans(factor[,c("x4","x8","x11")])
ech_produit <- rowMeans(factor[,c("x3","x6","x9","x12")])
ech_paiement <- rowMeans(factor[,c("x2","x7","x10")])
ech_prix <- rowMeans(factor[,c("x1","x5")])

# Cohérence interne (alpha de Cronbach)
alpha(factor[,c("x4","x8","x11")])
alpha(factor[,c("x3","x6","x9","x12")])
alpha(factor[,c("x2","x7","x10")])
alpha(factor[,c("x1","x5")])
  
# Autre alternative: la fonction du paquet psych
# psych::alpha(factor[,c("x4","x8","x11")])$total$raw_alpha

# Estimation avec corrélation polychronique 
# (avec avertissement - ignorez-le)
polychor <- psych::polychoric(factor)$rho
fa_poly <- factanal(covmat = polychor, 
                    factors = 3, 
                    n.nobs = 200L)

# Rotation oblique promax 
# (autres options avec psych::fa, voir rotate)
fa_obvarimax <- factanal(x = factor, 
                         factors = 3, 
                         rotation = "promax")
  
# Calcul des prédictions des facteurs et des scores (méthode de régression)
poids_fact <- t(fa4$loadings) %*% solve(fa4$correlation)
scores <- tcrossprod(x = scale(factor, center = TRUE, 
                           scale = TRUE), 
                     y = poids_fact)
# Retourner les scores - # voir option ci-dessous avec scores = "reg"
# On vérifie que les résultats sont identiques 
# à ceux de notre calcul manuel
isTRUE(all.equal(scores, 
                 factanal(x = factor, 
                          factors = 4L, 
                          scores = "regression")$scores))
