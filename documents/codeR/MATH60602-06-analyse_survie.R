# MATH 60602 - Analyse multidimensionnelle appliquée
# Analyse de survie

library(survival)

url <- "https://lbelzile.bitbucket.io/MATH60602/survival1.sas7bdat"
survival1 <- haven::read_sas(url)
colnames(survival1)[1] <- "time"
survival1$region <- factor(survival1$region)
survival1$service <- factor(survival1$service)

# Estimateur de Kaplan-Meier
# La réponse est le temps de survie et l'indicateur de censure 
# "0" pour censuré à droite, "1" pour événement
kapm <- survfit(Surv(time, 1-censure) ~ 1, 
                type="kaplan-meier", 
                conf.type="log", data = survival1)
summary(kapm)
plot(kapm, ylab = "fonction de survie", xlab = "temps") 

# test du khi-deux pour le log des rangs

#valeur-p du test asymptotique
survdiff(Surv(time, 1-censure) ~ sexe, data = survival1)
# valeur-p exact par simulation
# (pour petits échantillons, utiliser distribution="exact")
coin::logrank_test(Surv(time, 1-censure) ~ factor(sexe), 
                   data = survival1, 
                   distribution = coin::approximate(nresample=100000))

# Le test du log-rang calcule si les deux courbes sont identiques
# Idée de base: sous H0, les étiquettes 'sexe' ne sont pas pertinentes
# On peut les permuter et comparer les courbes

# Graphique avec plusieurs courbes
plot(survfit(Surv(time, 1-censure) ~ sexe, data = survival1), 
     conf.int = FALSE,
     col = c("red", "blue"), 
     xlab = "temps", 
     ylab = "fonction de survie")

# modèle de risque proportionnel de Cox

cox1 <- coxph(Surv(time, 1-censure) ~ sexe, data = survival1)
summary(cox1)

cox2 <- coxph(Surv(time, 1-censure) ~ age, data = survival1)
summary(cox2)

# Les tests de vraisemblance comparent au modèle nul sans variable explicative

cox3 <- coxph(Surv(time, 1-censure) ~ age + sexe + region + service, 
              data = survival1, ties = "exact")
summary(cox3)

# Courbes de survie différentes pour différentes valeurs des variables explicatives
cox4 <- coxph(Surv(time, 1-censure) ~ age + sexe, 
              data = survival1, ties = "exact")
surv4 <- survfit(cox4, 
                 newdata = data.frame(age = rep(c(25, 60), each = 2), 
                                      sexe = c(0,1,0,1)))
plot(surv4, col = 1:4, lty = 1:4)
  
# Il est important de tester l'hypothèse de risques proportionnels
cox.zph(cox3)
# Ici, le modèle n'est pas adéquat globalement 
# principalement en raison de service 
par(mfrow = c(2,2), mar = c(4,4,1,1))
plot(cox.zph(cox3))
graphics.off()

# Comparer deux modèles de Cox par rapport de vraisemblance
anova(cox2, cox3)

# Pour les variables explicatives qui varient dans le temps et des effets qui vaient dans le temps, voir 
# Using Time Dependent Covariates and Time Dependent Coefficients in the Cox Model
# Terry Therneau, Cynthia Crowson, Elizabeth Atkinson
# https://cran.r-project.org/web/packages/survival/vignettes/timedep.pdf

# interaction entre service et temps
# objet avec 'tt' varie dynamiquement
  cox4 <- coxph(Surv(time, 1-censure) ~ age + sexe + region + tt(age), 
                data = survival1, tt = function(x, t, ...){ x * t })
summary(cox4)

url <- "https://lbelzile.bitbucket.io/MATH60602/survival3.sas7bdat"
survival3 <- haven::read_sas(url, )
# t et T sont des mots réservés en R
colnames(survival3)[1] <- "time"
# Transformer les . en valeurs manquantes
survival3[survival3 == "."] <- NA
survival3$temps_ch <- as.numeric(survival3$temps_ch)
survival3$service <- survival3$service_avant
survlong <- survival3
survlong$depart <- 0

# Copie pour faire des modifications
dupli <- which(!is.na(survlong$temps_ch))
surdupl <- survlong[dupli,]
# Pour les copies, change la valeur de service
# mettre l'intervalle de temps
surdupl$depart <- survlong$temps_ch[dupli]
surdupl$service <- survival3$service_apres[dupli]
survlong$time[dupli] <- survlong$temps_ch[dupli]
survlong$censure[dupli] <- 1
# Pour le modèle avec point de rupture de la section 6.5.1,
# on brise la contribution de la vraisemblance en morceaux
# Les données doivent être en format long (plutôt que format large)
# Il faut alors spécifier la valeur de départ
survlong <- rbind(survlong, surdupl)
cox4 <- coxph(Surv(time = depart, time2 = time, event = 1-censure) ~ 
                age + sexe + factor(region) + factor(service) + age, 
              data = survlong)
summary(cox4)


# stratification pour région
# Risque de la catégorie de référence différent pour chaque région
cox5 <- coxph(Surv(time, 1-censure) ~ age + sexe + factor(service) + strata(region), data = survival1)
summary(cox5)


