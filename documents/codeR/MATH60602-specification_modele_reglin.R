# Modèle surspécifié ou sous-spécifié
n <- 200L
# Variables explicatives
X1 <- rpois(n = n, lambda = 1)
X2 <- rbinom(n = n, size = 1, prob = c(0.7, 0.3))
# Modèle de régression X*beta + aléas
y_a <- 20 + 2*X1 + 5*X2 + rnorm(n)
y_b <- 20 + 2*X1 + rnorm(n)
# Ajuster un modèle linéaire  lm(réponse ~ variables explicatives)
mod_1a <- lm(y_a ~ X1)
mod_2a <- lm(y_a ~ X1 + X2)

mod_1b <- lm(y_b ~ X1)
mod_2b <- lm(y_b ~ X1 + X2)

coef(mod_1a) #coefficients
confint(mod_1a) #intervalles de confiance
coef(mod_2a)
confint(mod_2a)

