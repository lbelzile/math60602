library(jpeg)
library(ggplot2)
library(patchwork)
# Télécharger et lire le fichier image
url <- "https://www.hec.ca/nouvelles/2013/images/Decelles-entree.jpg"
decelles <- tempfile()
download.file(url = url, destfile = decelles, mode="wb")
img <- jpeg::readJPEG(decelles)
file.remove(decelles)
# Transformer le cube en base de données
imgRGB <- data.frame(
  x = rep(1:dim(img)[2], each = dim(img)[1]),
  y = rep(dim(img)[1]:1, dim(img)[2]),
  R = as.vector(img[,,1]),
  G = as.vector(img[,,2]),
  B = as.vector(img[,,3])
)

# K-moyennes avec 2, 4 et 10 groupements
kmoy_2 <- kmeans(imgRGB[,c("R","G","B")], centers = 2)
kmoy_4 <- kmeans(imgRGB[,c("R","G","B")], centers = 4)
kmoy_10 <- kmeans(imgRGB[,c("R","G","B")], centers = 10)

g0 <-   ggplot(data = imgRGB, aes(x = x, y = y)) + 
  geom_point(colour = rgb(imgRGB[c("R", "G", "B")])) +
  theme_void() + 
  scale_y_continuous(limits = c(0, dim(img)[1]), expand = c(0, 0)) +
  scale_x_continuous(limits = c(0, dim(img)[2]), expand = c(0, 0))

# Calculer la moyenne des groupes, transformer en couleur RGB
kcouleurs_2 <- rgb(kmoy_2$centers)[kmoy_2$cluster]
g1 <- ggplot(data = imgRGB, aes(x = x, y = y)) + 
  geom_point(colour = kcouleurs_2) +
  theme_void() + 
  scale_y_continuous(limits = c(0, dim(img)[1]), expand = c(0, 0)) +
  scale_x_continuous(limits = c(0, dim(img)[2]), expand = c(0, 0))

kcouleurs_4 <- rgb(kmoy_4$centers)[kmoy_4$cluster]
g2 <- ggplot(data = imgRGB, aes(x = x, y = y)) + 
  geom_point(colour = kcouleurs_4) +
  theme_void() + 
  scale_y_continuous(limits = c(0, dim(img)[1]), expand = c(0, 0)) +
  scale_x_continuous(limits = c(0, dim(img)[2]), expand = c(0, 0))

kcouleurs_10 <- rgb(kmoy_10$centers)[kmoy_10$cluster]
g3 <- ggplot(data = imgRGB, aes(x = x, y = y)) + 
  geom_point(colour = kcouleurs_10) +
  theme_void() + 
  scale_y_continuous(limits = c(0, dim(img)[1]), expand = c(0, 0)) +
  scale_x_continuous(limits = c(0, dim(img)[2]), expand = c(0, 0))

(g0 + g1) / (g2 + g3) & theme(plot.margin =  unit(rep(0.1,4), "cm"))
