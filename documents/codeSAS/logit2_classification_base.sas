proc logistic data=multi.dbm(where=(train EQ 1));
class x3 x4 / param=glm;
model yachat(ref='0') = x1-x10 / ctable;
score data=multi.dbm(where=(train EQ 0)) out=pred1;
output out=pred2 predprobs=crossvalidate;
run;
/* Afin d'obtenir la courve ROC et l'aire sous la courbe (AUC) avec des estimations des probabilités obtenues par validation-croisée.
On sauvegarde d'abord les probabilités estimées par validation-croisée dans le fichier "pred2".
Ensuite, on exécute de nouveau PROC LOGISTIC avec ce fichier et la commande "ROC".
*/

/* Performance sur l'échantillon d'apprentissage
avec validation-croisée à n groupes (LOO-CV) */
proc logistic data=pred2;
class x3 x4;
model yachat(ref='0') = x1-x10;
roc pred=xp_1;
run;

/* Note: la variable qui contient l'estimation de P(Y=1) dans le fichier "pred1", créé
avec le PROC LOGISTIC précédent, se nomme "xp_1" 
Avec l'option "roc", on obtiendra trois graphiques de la courbe d'efficacité du récepteur
soit prédictions brutes, validation croisée à n groupes et les deux courbes ROC sur un même graphique
*/

/* 
Commandes pour obtenir le lift chart. 
IMPORTANT: il faut d'abord compiler la MACRO liftchart1
en exécutant le code dans le fichier "logit3_lift_chart.sas"
*/

/* Note: la variable qui contient l'estimation de P(Y=1) dans le fichier "pred", créé
avec le PROC LOGISTIC précédent, se nomme "xp_1" */
%liftchart1(pred2, yachat, xp_1, 10);


/* 
Commandes pour trouver le meilleur point de coupure afin de maximiser
le gain moyen. 
*/

/* Calcul du revenu moyen pour les clients qui ont acheté quelque chose 
*/

proc means data=multi.dbm(where=(train EQ 1));
var ymontant;
run;


/*
IMPORTANT: il faut d'abord compiler les MACROS en exécutant le fichier "logit4_macro_gain.sas".
*/

%manycut_cvlogisticclass(
yvar=yachat,
xvar=x1-x10,
xvarclass=x3-x4, 
n=1000,
k=10,
ncv=1,
dataset=multi.dbm(where=(train EQ 1)),
c00=0,
c01=0,
c10=-10,
c11=57,
manycut=.05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .5);
