** Sélection de modèles et calcul de la performance;
** Régression logistique;
**============================================================;
**
** Exercice 5.1
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



/* Exercice 5.3 */


proc logistic data=multi.multinom descending;
class educ revenu sexe;
model y = age educ revenu sexe / clparm=pl clodds=pl expb;
run;

proc logistic data=multi.multinom outmodel=mod;
class educ(ref="sec") revenu(ref="1");
model y(ref="1") = age educ revenu sexe / clparm=pl clodds=pl expb link=glogit;
run;
 /* Test du rapport de vraisemblance pour H0: régression ordinale 
 logistique à cotes proportionnelles versus H1: multinomiale logistique */
data pval;
pval=1-CDF('CHISQ', 2728.565 - 2685.863, 24-6);
run;
proc print data=pval;
run;
/* Même conclusion que le test du score: on rejette l'hypothèse nulle 
que le modèle plus simple est adéquat */
/* Prédiction pour le nouveal individu */
data multinomprof;
input age educ $ revenu $ sexe;
datalines;
30 cegep 2 0
;
run; 
proc logistic inmodel=mod;
score data=multinomprof out=pred;
run;
/* Imprimer les probabilités de chaque classe */
proc print data=pred;
run;
