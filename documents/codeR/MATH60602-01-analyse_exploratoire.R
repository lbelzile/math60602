library(ggplot2)
library(poorman)
if(!require(hecmodstat)){
  remotes::install_github("lbelzile/hecmodstat")
}
data(renfe, package = "hecmodstat")

g1 <- ggplot(data = renfe, aes(x = classe)) + 
  geom_bar() + 
  labs(x = "classe", y = "dénombrement")
g2 <- ggplot(data = renfe, aes(x = type)) + 
  geom_bar() + 
  labs(x = "type de train", y = "dénombrement")
gridExtra::grid.arrange(g1, g2, ncol=2)


renfe %>% subset(tarif == "Promo") %>%
  ggplot(aes(x = prix)) + 
    geom_histogram(aes(y = ..density..), bins = 30) +
    geom_rug(sides = "b") + 
    labs(x = "prix de billets au tarif Promo (en euros)", y = "densité") 

renfe %>% subset(tarif == "Promo") %>%
    ggplot(aes(y = prix, x = classe, col = type)) + 
    geom_boxplot() + 
    labs(y = "prix (en euros)", col = "type de train") + 
    theme(legend.position = "bottom")


ggplot(data = renfe, aes(x = type, y = prix, col = dest)) + 
  geom_boxplot() + 
  labs(y = "prix (en euros)",
       x = "type de train",
       color = "destination") +
  theme(legend.position = "bottom")

renfe %>% subset(tarif  != "AdultoIda") %>%
ggplot(aes(y = prix, x = classe, col = tarif)) + 
  geom_boxplot() + 
  labs(y = "prix (en euros)",
       x = "classe",
       color = "tarif") +
  theme(legend.position = "bottom")


ggplot(data = renfe, aes(x = prix, y=..density.., fill = tarif)) +
    geom_histogram(binwidth = 5) +
    labs(x = "prix (en euros)", y = "densité") + 
    theme(legend.position = "bottom")


a <- renfe %>% subset(tarif  == "Flexible") %>% count(prix, classe)
knitr::kable(a,caption = "Nombre de billets au tarif Flexible selon le prix de vente.")

