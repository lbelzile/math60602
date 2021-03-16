** Sélection de modèles et calcul de la performance;
** Régression logistique;
**============================================================;
/*
Les données "logistclient" contiennent des données simulées pour un cas fictif de promotion pour des clients. La base de données contient les variables suivantes:

- "promo": variable binaire, 1 si le client s'est prévalue d'une offre promotionnelle, 0 sinon
- "sexe": 0 pour les femmes, 1 pour les hommes
- "tclient": variable catégorielle, soit "frequent" pour les clients réguliers ou "occasionnel" autrement
- "nachats": nombre d'achats au magasin dans le dernier mois

Estimer le modèle logistique pour "promo" avec les variables explicatives "nachats", "sexe" et "tclient"
1) Interpréter les coefficients
2) Tester si l'effet de "nachats" est statistiquement significatif
3a) Choisir le point de coupure sur la base du taux de bonne classification. 
3b) Pour le point de coupure choisi, construisez une matrice de confusion
3c) Faites un graphique de la fonction d'efficacité du récepteur (courbe ROC). 
Quelle est l'aire sous la courbe (estimée à l'aide de la validation croisée)
*/

proc logistic data=multi.logistclient;
class tclient / param=glm;
model promo(ref='0') = sexe tclient nachats / clodds=pl expb ctable;
output out=pred predprobs=crossvalidate;
run;

proc logistic data=pred;
class tclient / param=glm;
model promo(ref='0') = sexe tclient nachats;
roc pred=xp_1;
ods select Logistic.ROCComparisons.ROCOverlay;
run;

