# MATH 60602 - Analyse multidimensionnelle appliquée
# Analyse de regroupements
# Autre outils disponibles sur  https://lbelzile.bitbucket.io/math444/tp8.html

# Autres paquets utiles pour la visualisation
library(cluster)
suppressPackageStartupMessages(library(factoextra))
library(dendextend) # outils graphiques pour dendogrammes
library(tidyverse) 
library(patchwork) # combiner des graphiques

# Choix de thème pour les graphiques 
theme_set(new = theme_classic())
theme_update(legend.position = "bottom")

# Téléchargement des données
url <- "https://lbelzile.bitbucket.io/MATH60602/cluster1.sas7bdat"
cluster1 <- haven::read_sas(url)
# ce sont des données simulées avec trois groupes 
# donc on connaît les vrais étiquettes
# enlever les vrais identifiants de groupe pour ne 
# garder que les données (c'est ce qui arrive en pratique)
cluster1$cluster_vrai <- NULL

# Comparer les distances Euclidiennes - est-ce qu'on distingue des groupements?
fviz_dist(dist.obj = dist(cluster1), 
          show_labels = FALSE)
# On voit clairement trois groupes, bien que le groupe 2 soit quelque par entre 1 et 3
# C'est évident ici parce que les données simulées
# sont ordonnées par groupe


# Pour standardiser les observations, utiliser scale
# dist est la fonction pour calculer la distance, plusieurs options (par défaut la distance euclidienne)
# Méthode de Ward (autre options disponibles)
clust <- cluster1 %>% # données
  scale %>% # échelonner et réduire
  dist %>% # distance Euclidienne
  hclust(method = "ward.D2") # regroupements hiérarchiques 
# Tracer le dendogramme - pas en fonction du R carré ici
clust %>%  
  as.dendrogram %>% 
  set("branches_k_color", k = 3) %>%
  set_labels(labels = NA) %>%
  ggplot(horiz = TRUE)
# Historique - deux signes négatifs indiquent groupement de points isolés
#  Un coefficient positif indique une observation isolé qui se joint au groupe (la ligne de formation du groupe)
# deux signes positifs indiquent une fusion de deux groupements
head(clust$merge)

# obtenir les étiquettes de groupe pour 
# la solution à 3 groupes
cluster1$groupe <- cutree(clust, k = 3)

factoextra::fviz_cluster(
      list(data = cluster1, 
           cluster = cutree(clust, k = 3)),
      stand = FALSE,
      main = "Regroupements selon méthode de Ward") + 
  labs(col = "regroupements",
       x = expression(x[1]),
       y = expression(x[2])) + 
  theme(legend.position = 'none')

# Calculer le barycentre (moyenne variable par variable) pour initialiser k-moyennes
bary_Ward <-  
  cluster1 %>% 
  group_by(groupe) %>% 
  summarize(across(x1:x6, ~mean(.x)))
# k-moyennes avec barycentres des regroupements hiérarchiques (Ward) comme germes
kmoy <- kmeans(x = cluster1, 
               centers = bary_Ward)
# Analyse en composantes principales sur la matrice de corrélation

# Projection sur les deux composantes principales avec la méthode des k-moyennes
ggplot(data = data.frame(princomp(cluster1)$scores,
                         groupe = factor(kmoy$cluster)), 
       mapping = aes(x = Comp.1, 
                     y = Comp.2,
                     color = groupe)) +
  geom_point() +
  labs(x = "composante principale 1",
       y = "composante principale 2") 

# Combinaison de méthode hiérarchique suivie des k-moyennes
# avec options pour métrique et mesure de dissimilarité
hkmoy <-
  factoextra::hkmeans(
    x = cluster1,
    k = 3,
    hc.metric = "manhattan",
    hc.method = "single"
  )

# Fonction pour calculer le R carré et le R carré semi-partiel
rc_hclust <- function(x, hc, kmax, plot = FALSE) {
  stopifnot(inherits(hc, "hclust")) # doit être un object de classe hclust
  k <- as.integer(kmax)
  stopifnot(k > 2)
  groups <- cutree(hc, k = seq_len(k))
  TSS <- function(x, g) {
    sum(aggregate(x, by = list(g), function(x)
      sum(scale(x, scale = FALSE) ^ 2))[, -1])
  }
  TSS.all <- apply(groups, 2, function(g)
    TSS(x, g))
  data.frame(index = 1:kmax,
             Rc = 1 - TSS.all / TSS.all[1],
             Rcsp = c(0, -diff(TSS.all) / TSS.all[1]))
}

# Graphiques pour les R carré et R carré semi-partiel
rc_ec <- rc_hclust(x = cluster1, hc = clust, k = 20)
g1 <- ggplot(data = rc_ec, 
       mapping = aes(x = index,
                     y = Rc)) +
  geom_line() +
  geom_point() +
  labs(x = "nombre de regroupements",
       y = "R-carré")

g2 <- ggplot(data = rc_ec, 
             mapping = aes(x = index,
                           y = Rcsp)) +
  geom_line() +
  geom_point() +
  labs(x = "nombre de regroupements",
       y = "R-carré semi-partiel")
g1 + g2