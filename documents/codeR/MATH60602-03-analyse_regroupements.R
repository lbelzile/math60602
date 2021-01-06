# MATH 60602 - Analyse multidimensionnelle appliquée
# Analyse de regroupements
# Autre outils disponibles sur  https://lbelzile.bitbucket.io/math444/tp8.html

# Autres paquetages utiles pour la visualisation
library(cluster)
library(factoextra)
# Téléchargement des données
url <- "https://lbelzile.bitbucket.io/MATH60602/cluster1.sas7bdat"
cluster1 <- haven::read_sas(url)
# enlever les vrais identifiants de groupe pour ne garder que les données
vraigroupes <- cluster1$cluster_vrai

# Comparer les distances Euclidiennes - est-ce qu'on distingue des groupements?
fviz_dist(dist(cluster1), show_labels = FALSE)
# On voit clairement trois groupes, bien que le groupe 2 soit quelque par entre 1 et 3

cluster1$cluster_vrai <- NULL
# Pour standardiser les observations, utiliser scale
# dist est la fonction pour calculer la distance, plusieurs options (par défaut la distance euclidienne)
# Méthode de Ward (autre options disponibles)
clust <- hclust(dist(scale(cluster1)), method = "ward.D") #ward.D2 calcule la distance carrée
# Tracer le dendogramme - pas en fonction du R carré ici
plot(clust, main = "dendrogramme", hang =-1, ylab= "", sub = "", xlab = "numéro d'observation")
# Isoler les regroupements
rect.hclust(clust, k = 3)
# Historique - deux signes négatifs indiquent groupement de points isolés
#  Un coefficient positif indique une observation isolé qui se joint au groupe (la ligne de formation du groupe) 
# deux signes positifs indiquent une fusion de deux groupements
head(clust$merge)

# obtenir les étiquettes de groupe pour la solution à 3 groupes
Ward_groupes <- cutree(clust, k = 3)
# Calculer le barycentre (moyenne variable par variable) pour initialiser k-moyennes
bary_Ward <- t(sapply(1:3, function(i){colMeans(cluster1[which(Ward_groupes==i),])}))
# k-moyennes avec barycentres des regroupements hiérarchiques (Ward) comme germes
kmoy <- kmeans(x = cluster1, centers = bary_Ward)
# Tableau avec classification - vrai versus estimée
classif <- table(kmoy$cluster, vraigroupes)
# Taux de bonne classification
taux_bonne_classif <- sum(diag(classif))/sum(classif)
# Analyse en composantes principales sur la matrice de corrélation
# Visualisation des données avec les vrais groupes
pairs(cluster1, col = vraigroupes, pch = vraigroupes)
# On voit le groupe triangles rouges clairement démarqué uniquement dans la composante 1

# Projection sur les deux composantes principales avec la méthode des k-moyennes
acp <- princomp(cluster1)$scores[,1:2]
plot(acp, 
     xlab = "composante principale 1", 
     ylab= "composante principale 2", 
     bty = "l", col = kmoy$cluster)

# Visualisation des groupes avec l'enveloppe convexe
factoextra::fviz_cluster(list(data = acp, cluster = kmoy$cluster),
                         main = "Regroupements selon k-moyenne")

# Combinaison de méthode hiérarchique suivie des k-moyennes
# avec options pour métrique et mesure de dissimilarité
hkmoy <- factoextra::hkmeans(x = cluster1, k = 3, hc.metric = "manhattan", hc.method = "single")

# Fonction pour calculer le R carré et le R carré semi-partiel
rc_hclust <- function(x, hc, kmax){
   stopifnot(inherits(hc, "hclust")) # doit être un object de classe hclust
   k <- as.integer(kmax)
   stopifnot(k > 2)
   groups <- cutree(hc, k = seq_len(k))
   TSS <- function(x, g) {
      sum(aggregate(x, by=list(g), function(x) sum(scale(x, scale=FALSE)^2))[, -1])
   }
   TSS.all <- apply(groups, 2, function(g) TSS(x, g))
   data.frame(Rc = 1-TSS.all/TSS.all[1], Rcsp = c(0,-diff(TSS.all)/TSS.all[1]))
}

# Graphiques pour les R carré et R carré semi-partiel
rc_ec <- rc_hclust(x = cluster1, hc = clust, k = 20)
par(mfrow =c(1,2), bty = "l")
plot(x = 1:nrow(rc_ec), y = rc_ec$Rc, type = "b", 
     xlab = "nombre de regroupements", ylab = "R carré")
plot(x = 2:nrow(rc_ec), y = rc_ec$Rcsp[-1], type = "b", 
     xlab = "nombre de regroupements", ylab = "R carré semi-partiel")
