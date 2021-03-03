
/* NOTE IMPORTANTE: il faut d'abord préparer les données en exécutant la 1e partie
du programme "prepare_DBM.sas", afin d'avoir un fichier nommé "train" qui contient
l'échantillon d'apprentissage et un fichier nommé "test" qui contient les clients
à cibler (ou à prédire). */

/*
Prévision des clients pour lesquels on veut prédire la réponse avec le modèle qui utilise les 10 variables
de base seulement. La commande "score" permet de sauvegarder les estimations
de P(Y=1), des clients ("test") dans le fichier "pred".
*/


proc logistic data=train plots(only)=(roc);
model yachat(ref='0') = x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10 /ctable;
score data=test out=pred;
run;



/* Afin d'obtenir la courve ROC et l'aire sous la courbe (AUC)( avec des estimations des probabilités obtenues par validatioin-croisée.
On sauvegarde d'abord les probabilités estimées par validation-croisée dans le fichier "pred".
Ensuite, on exécule de nouveau PROC LOGISTIC avec ce fichier et la commande "ROC".
*/

proc logistic data=train;
model yachat(ref='0') = x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10;
output out=pred predprobs=crossvalidate;
run;

/* Note: la variable qui contient l'estimation de P(Y=1) dans le fichier "pred", créé
avec le PROC LOGISTIC précédent, se nomme "xp_1" */

proc logistic data=pred;
model yachat(ref='0') = x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10;
roc pred=xp_1;
run;



/*  ______________________________________________________  */


/* 
Commandes pour obtenir le lift chart. 
IMPORTANT: il faut d'abord compiler la MACRO liftchart1
en exécutant le code dans le fichier "logit3_lift_chart.sas"
*/


proc logistic data=train;
model yachat(ref='0') = x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10; 
output out=pred predprobs=crossvalidate;
run;

/* Note: la variable qui contient l'estimation de P(Y=1) dans le fichier "pred", créé
avec le PROC LOGISTIC précédent, se nomme "xp_1" */
%liftchart1(pred,yachat,xp_1,10);


/*  ______________________________________________________  */

/* 
Commandes pour trouver le meilleur point de coupure afin de maximiser
le gain moyen. 
*/

/* Calcul du revenu moyen pour les clients qui ont acheté quelque chose 
*/

proc means data=train;
var ymontant;
run;


/*
IMPORTANT: il faut d'abord compiler les MACROS en exécutant le fichier "logit4_macro_gain.sas".
*/

%manycut_cvlogistic(yvar=yachat,xvar=x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10,n=1000,k=10,ncv=1,
dataset=train, c00=0,c01=0,c10=-10,c11=57,
manycut=.05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .5);

