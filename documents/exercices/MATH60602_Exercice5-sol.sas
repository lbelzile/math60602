** Sélection de modèles et calcul de la performance;
** Régression logistique;
**============================================================;
/*
EXERCICE 5.1

Les données "logistclient" contiennent des données simulées pour un cas fictif de promotion pour des clients. La base de données contient les variables suivantes:

- "promo": variable binaire, 1 si le client s'est prévalue d'une offre promotionnelle, 0 sinon
- "sexe": 0 pour les femmes, 1 pour les hommes
- "tclient": variable catégorielle, soit "frequent" pour les clients réguliers ou "occasionnel" autrement
- "nachats": nombre d'achats au magasin dans le dernier mois

Estimez le modèle logistique pour "promo" avec les variables explicatives "nachats", "sexe" et "tclient"
1) Interprétez les coefficients
2) Testez si l'effet de "nachats" est statistiquement significatif
3a) Choisissez le point de coupure sur la base du taux de bonne classification. 
3b) Pour le point de coupure choisi, construisez une matrice de confusion
3c) Faites un graphique de la fonction d'efficacité du récepteur (courbe ROC). 
Quelle est l'aire sous la courbe (estimée à l'aide de la validation croisée)
*/

proc logistic data=multi.logistclient plots(only)=roc;
class tclient / param=glm;
model promo(ref='0') = sexe tclient nachats / clodds=pl expb ctable;
output out=pred predprobs=crossvalidate;
run;

proc logistic data=pred;
class tclient / param=glm;
model promo(ref='0') = sexe tclient nachats;
roc pred=xp_1;
*ods select Logistic.ROCComparisons.ROCOverlay;
run;

/*
EXERCICE 5.2
*/

proc hpgenselect data=sashelp.junkmail;
partition role=test(train="0" validate="1");
model class(ref='0') = make--captotal / dist=binary link=logit; 
selection method=stepwise(choose=bic)  details=all;
output out=predspam pred=pred role=role;
run;

data predspam2;
set sashelp.junkmail(keep=class);
set predspam;
where role=1;
drop role;
run;

# Compiler la macro logit10_macro_gainpred.sas
%mlogisticclass(yvar=class,ypred=pred,dataset=predspam2,c00=1,c01=-2,c10=-1,c11=1);

/*
EXERCICE 5.3
*/

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

