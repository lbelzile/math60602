/* Régression logistique */
/* //////////////////////////////////////////////////////////// */
/* 1. Introduction */
/* //////////////////////////////////////////////////////////// */
proc freq data=multi.logit1 ;
  tables y;
run;

proc freq data=multi.logit1 ;
  tables (x1-x4 x6) * y / nocum nopercent nocol;
run;

proc means data=multi.logit1 maxdec=1;
class y;
var x5;
run;


**Régression logistique avec une seule variable;

/*
Explication des différents paramètres de "logistic"
expb: pour avoir les exp(beta) sur la ligne des paramètres estimés (les rapports de cote).
clparm=pl: pour avoir les intervalles de confiance pour beta (vraisemblance profilée).
clodds=pl: pour avoir les intervalles de confiance pour exp(beta) (vraisemblance profilée).

"y(ref='0')" spécifie qu'on utilise Y=0 comme valeur de référence.
Ainsi, on modélise P(Y=1).
*/

proc logistic data=multi.logit1;
model y(ref='0') = x5 / clparm=pl clodds=pl expb;
run;
 
proc logistic data=multi.logit1;
model y(ref='1') = x5  / clparm=pl clodds=pl expb;
run; 

/* Modèle avec toutes les variables explicatives.

La commande CLASS permet de déclarer des variables explicatives catégorielles.
"x1(ref=last)" précise que la plus grande valeur de X1 est la catégorie de référence.
C'est l'option par défauts=
*/


proc logistic data=multi.logit1 ;
class x1 x2 x6 / param=ref;
model y(ref='0') =x1-x6 / clparm=pl clodds=pl expb;
run;

/* Même modèle que le précédent mais en créant nous-mêmes les indicatrices
pour les variables explicatives catégorielles.*/

/* Création des variables indicatrices */
data temp;
set multi.logit1;
                              
if x1=1 then x11=1; else x11=0;
if x1=2 then x12=1; else x12=0;
if x1=3 then x13=1; else x13=0;
if x1=4 then x14=1; else x14=0;

if x2=1 then x21=1; else x21=0;
if x2=2 then x22=1; else x22=0;
if x2=3 then x23=1; else x23=0;
if x2=4 then x24=1; else x24=0;

if x6=1 then x61=1; else x61=0;
if x6=2 then x62=1; else x62=0;
run;    

proc logistic data=temp ;
model y(ref='0') = x11 x12 x13 x14 x21 x22 x23 x24 x3 x4 x5 x61 x62 / clparm=pl clodds=pl expb;
run; 

/* lsmeans: comparaison entre toutes les modalités de X1 deux à deux*/

proc logistic data=multi.logit1 ;
class x1 x2 x6 / param=ref;
model y(ref='0') =x1-x6 / clparm=pl clodds=pl expb;
lsmeans x1 / diff=all;
run; 

/* Pour obtenir les estimations de P(Y=1) et
 les intervalles de confiance pour ces probabilités */

proc logistic data=multi.logit1 ;
class x1(ref=last) x2(ref=last) x6(ref=last) / param=ref;
model y(ref='0') = x1-x6 / clparm=pl clodds=pl expb;
score data=multi.logit1 out=pred clm;
run; 

 

**Interprétation de paramètres;
**============================;

*Exercice : Ajuster 3 régressions logistiques avec respectivement X3, X5 et X6;
*Pour chaque variable interprétez adéquatement les paramètres;

*Variable indépendante binaire;

proc freq data=multi.logit1;
  tables x3*y / chisq;
run;

proc logistic data=multi.logit1 ;
model y(ref='0') = x3 / clparm=pl clodds=pl expb;
run; 

proc logistic data=multi.logit1 ;
model y(event='1') = x3 / clparm=pl clodds=pl expb;
run; 

proc logistic data=multi.logit1 ;
model y = x3 / clparm=pl clodds=pl expb;
run; 

*Variable indépendante continue;

proc logistic data=multi.logit1 ;
model y(ref='0') = x5  / clparm=pl clodds=pl expb;
run; 

*Variable indépendante catégorielle;

proc freq data=multi.logit1;
  tables x6*y / chisq;
run;

proc logistic data=multi.logit1 ;
class x6(ref=last) / param=ref;
model y(ref='0') = x6  / clparm=pl clodds=pl expb;
run; 

********FIN DE L'EXERCICE**********;

*Choix de la catégorie de référence;

proc freq data=multi.logit1;
  tables x1*y / chisq;
run;

proc logistic data=multi.logit1 ;
class x1(ref=last) / param=ref;
model y(ref='0') =x1 / clparm=pl clodds=pl expb;
run; 

proc logistic data=multi.logit1 ;
class x1(ref='4')  / param=ref;
model y(ref='0') =x1  / clparm=pl clodds=pl expb;
run; 

**Modèles avec toutes les variables explicatives;
**==============================================;

proc logistic data=multi.logit1;
class x1(ref=last) x2(ref=last) x6(ref=last) / param=ref;
model y(ref='0') =x1 x2 x3 x4 x5 x6 / clparm=pl clodds=pl expb;
run; 

*Quels sont les effets significatifs?
*Faites l'interprétation des paramètres.
*Écrivez l'équation du modèle ajusté.
*Quel est le nom du test pour tester les paramètres en régression logistique?


*Test du rapport de vraisemblance pour un ou plusieurs paramètres;
*=================================================================;

*Modèle avec toutes les variables;
proc logistic data=multi.logit1 ;
class x1(ref=last) x2(ref=last) x6(ref=last) / param=ref;
model y(ref='0') =x1-x6 / clparm=pl clodds=pl expb;
run; 

*Modèle sans la variable x6;
proc logistic data=multi.logit1 ;
class x1(ref=last) x2(ref=last)  / param=ref;
model y(ref='0') =x1-x5;
run; 

*Pour calculer la valeur-p du test de rapport de vraisemblance;
data pval;
pval=1-CDF('CHISQ', 49.487, 2);
run;
proc print data=pval;
run;

**Multicolinéarité;
**================;

proc freq data=multi.colinearite;
  tables y;
run;

proc corr data=multi.colinearite;
var x1-x5;
run;

proc logistic data=multi.colinearite;
model y(ref='0') =x1  / clparm=pl clodds=pl expb;
run; 
proc logistic data=multi.colinearite;
model y(ref='0') =x2  / clparm=pl clodds=pl expb;
run; 
proc logistic data=multi.colinearite;
model y(ref='0') =x3  / clparm=pl clodds=pl expb;
run; 
proc logistic data=multi.colinearite;
model y(ref='0') =x4  / clparm=pl clodds=pl expb;
run; 
proc logistic data=multi.colinearite;
model y(ref='0') =x5  / clparm=pl clodds=pl expb;
run; 

proc logistic data=multi.colinearite;
model y(ref='0') =x3  / clparm=pl clodds=pl expb;
run; 
proc logistic data=multi.colinearite;
model y(ref='0') =x1-x5  / clparm=pl clodds=pl expb;
run; 

*Ajustons maintenant un modèle de régression logistique pour expliquer une variable
 indépendante en fonction des autres variables indépendantes;


*Calcul des prévisions;
*=====================;

proc logistic data=multi.logit1 ;
model y(ref='0') =x3  / clparm=pl clodds=pl expb;
output out=pred pred=prob;
run; 

proc means data=pred;
  class y;
  var prob;
run;

*Regardons la classification selon différents points de coupure;

data pred;
  set pred;
  if (prob<0.5) then ypred=0;
  else ypred=1;
run;

proc freq data=pred;
  tables ypred * y;
run;

data pred;
  set pred;
  if (prob<0) then ypred=0;
  else ypred=1;
run;

proc freq data=pred;
  tables ypred * y;
run;

data pred;
  set pred;
  if (prob<=1) then ypred=0;
  else ypred=1;
run;

proc freq data=pred;
  tables ypred * y;
run;

** Quasi-séparation de variables;

data t;
input Y X1 X2;
cards;
0 1  3
0 2  2
0 3 -1
0 3 -1
1 5  2
1 6  4
1 10 1
1 11 0 
;
run;

proc logistic data = t;
  model y = x1 x2;
  score out=pred;
run;

proc print data=pred;
run;

/* Correction de Firth, qui ajoute une correction de biais
et qui rétablit l'identifiabilité des paramètres
(interprétation comme apriori) */
proc logistic data = t;
  model y = x1 x2 / firth;
  score out=pred;
run;

proc print data=pred;
run;
/* Tiré de 
https://stats.idre.ucla.edu/other/mult-pkg/faq/general/faqwhat-is-complete-or-quasi-complete-separation-in-logistic-regression-and-what-are-some-strategies-to-deal-with-the-issue/
Introduction to SAS. UCLA: Statistical Consulting Group. 
from https://stats.idre.ucla.edu/sas/modules/sas-learning-moduleintroduction-to-the-features-of-sas/ (accessed August 22, 2016).
*/

/* ///////////////////////////////////////////// */
/* 2. Classification de base */
/* ///////////////////////////////////////////// */

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


/* 3. Sélection de variables */

/* 
Utiliser la syntaxe de la procédure glmselect
pour créer toutes les interactions et les termes d'ordre
deux - on sauvegarde la nouvelle base de données "matmod"
*/
ods exclude all; 
proc glmselect data=multi.dbm outdesign=matmod;
partition role=train(train="1" validate="0");
class x3(param=ref split) x4(param=ref split);
model yachat=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
selection=none;
run;
ods exclude none;

/* Scinder en échantillon d'entraînement et de validation */
data test;
set matmod;
if(_ROLE_ EQ 'VALIDATE') then output;
else delete;
run;

data train;
set matmod;
if(_ROLE_ EQ 'TRAIN') then output;
else delete;
run;

/*
Recherche de type exhaustive (approximative) avec les 10 variables de base 

proc logistic data=train;
model yachat(ref='0') = x1-x2 x3_1-x3_2 x4_1-x4_4 x6-x10 /
 selection=score best=1;
run;
 
Commande pour obtenir le AIC et le BIC/SBC de tous les modèles provenant d'une
recherche de type exhaustive de PROC LOGISTIC 

IMPORTANT: il faut d'abord compiler la MACRO en exécutant le fichier "logit6_macro_all_subset.sas".
*/

%logistic_aic_sbc_score(yvariable=yachat,
xvariables=x1 x2 x3_1 x3_2 x4_1-x4_4 x5-x10,
dataset=train, minvar=1, maxvar=14); 

/* Procédure hpgenselect (version haute performance de genmod)
La syntaxe est semblable à glmselect
mais on ne peut sauvegarder la base de données 
correspondant au modèle final
On ajoute la fonction de liaison (logit) 
et la loi des données (binaires) 
Le seul mécanisme de sélection est le test de score pour
méthode séquentielle/ascendante/descendante ou le LASSO
Ici, j'utilise sle=1 pour inclure toutes les variables
(recherche exhaustive) et details=all pour avoir en 
sortie un tableau avec tous les critères d'information
La console inclut les détails pour toutes les étapes,
aussi je filtre pour ne conserver que ce dernier
avec ods select
*/
proc hpgenselect data=multi.dbm;
partition rolevar=train(validate=0);
class x3(ref='3' split) x4(ref='5' split);
model yachat(ref='0')=x1-x10 /  
link=logit distribution=binary;
selection method=forward(choose=aic sle=1) details=all;
ods select Hpgenselect.Summary.SelectionDetails;
run;
/* Recherche avec LASSO */
proc hpgenselect data=train;
model yachat(ref='0')=&_GLSmod /  
link=logit distribution=binary;
selection method=lasso(choose=bic stop=bic) details=all;
run;


/* Procédure haute performance hplogistic */
/* Supporte la syntaxe avec "class", mais pas l'option "split"
ce qui veut dire qu'une variable catégorielle conserve toutes
ses modalités (pas de fusion de classe possible) 
Ici, ce n'est pas un problème parce qu'on passe la base de données
utilisée précédemment avec toutes les interactions.

Plutôt que d'ajuster les modèles pour chaque étape, 
on approximate l'adéquation du modèle avec le test
du score via l'option "fast"; cela fait en sorte 
que les valeurs de AIC/SBC sont approximatives */

proc hplogistic data=train;
model yachat(ref='0')= &_GLSmod;
selection method=backward(fast select=aic choose=sbc) hierarchy=none;
run;

/* On peut également faire la procédure descendante 
et spécifier le nombre de variable minimal qu'on veut 
si la procédure ne termine pas auparavant 
Il n'est malheureusement pas possible de sauvegarder
le nom des variables sélectionnées...*/
proc hplogistic data=train;
model yachat(ref='0')= &_GLSmod;
selection method=backward(fast mineffects=51) hierarchy=none;
run;
/* 51 effets, incluant l'ordonnée à l'origine */

/* 
Recherche séquentielle suivie d'une recherche exhaustive
La recherche séquentielle donne 50 variables qui sont ensuite
passées à la macro "logistic_aic_sbc_score"

J'ai fait un copier-coller des variables listées dans la sortie ci-dessus
*/

%logistic_aic_sbc_score(yvariable=yachat,
xvariables=x1 x2 x3_1 x3_2 x4_1 x4_3 x1*x4_4 x2*x4_1 x2*x4_2 x3_1*x4_4 x3_2*x4_1 x3_2*x4_2 x3_2*x4_4 x1*x5 x5*x3_2 x5*x4_4 x6*x3_1 x6*x3_2 x6*x4_2 x6*x4_4 x7 x1*x7 x2*x7 x7*x3_1 x7*x4_1 x7*x4_2 x7*x4_3 x6*x7 x8 x8*x3_2 x8*x4_3 x5*x8 x6*x8 x7*x8 x2*x9 x9*x3_1 x9*x4_1 x9*x4_3 x9*x4_4 x5*x9 x6*x9 x8*x9 x1*x10 x2*x10 x10*x4_1 x10*x4_4 x5*x10 x2*x2 x9*x9 x10*x10,
dataset=train,minvar=1,maxvar=50); 


/*  ______________________________________________________  */
/*
Modèle Tobit.
*/

/* La procédure "QLIM" qui estime le modèle Tobit n'a pas de commande "score".
Mais elle peut calculer des prévisions pour les observations du fichier utilisé
pour ajuster le modèle. Le truc est alors de mettre toutes les observations 
(apprentissage et à scorer) dans un même fichier et de s'assurer d'avoir des valeurs
manquantes pour les variables dépendantes des observations à scorer. 
Ainsi, SAS va seulement utiliser les observations sans valeurs manquantes pour ajuster 
le modèle. Mais il sera en mesure de calculer les prévisions pour toutes les observations du fichier
(s'il n'y a pas de valeurs manquantes pour les variables explicatives). Il suffit
ensuite d'extraire les prévisions pour les observations à scorer. */

/* Création d'un fichier avec toutes observations mais des valeurs manquantes
pour les variables dépendantes des observations à scorer. */


data alltobit; 
set matmod;
set multi.dbm(keep=ymontant);
if _role_ = "VALIDATE" then do;
 yachat=.;
 ymontant=.;
end;
run;

/* Modèle Tobit en prenant les variables sélectionnées 
par la procédure séquentielle avec tests d'hypothèse
avec entrée=sortie=0,05, pour yachat et ymontant.  
Les prévisions vont se trouver dans le fichier "tobit". */

proc qlim data=alltobit method=NRRIDG;
model yachat = x2 x4_1 x2*x1 x2*x10 x1*x5 x1*x10 x5*x3_2
x3_1*x4_4 x4_1*x7 x4_3*x8 x7*x8 x6*x8 x6*x10 / discrete;
model ymontant = x3_2 x4_4 x5 x7 x10 x6*x6 x10*x10 x2*x3_1
x2*x4_3 x1*x4_3 x1*x6 x1*x10 x5*x8
x5*x10 x3_1*x4_1 x3_1*x8 x3_2*x8
x4_1*x8 x4_2*x8 x4_4*x6 x4_4*x9 x8*x10  / select(yachat=1);
output out=tobit predicted proball;
run;

/* Calcul de la prévision de ymontant pour les observations à prédire. 
La variable "predymontant" dans le fichier "pred" contient cette prévision. */

data tobit;
set tobit;
if _ROLE_ = "TRAIN" then delete;
predymontant=Prob2_yachat*P_ymontant;
run;

data tobit;
set tobit;
keep predymontant;
run;
data pred;
merge test tobit;
run;
/* //////////////////////////////////////////////////////////// */
/* 4. Extensions (modèle multinomial et à risque proportionnel) */
/* //////////////////////////////////////////////////////////// */

/*
Statistiques descriptives de base, calculées séparément selon les valeur de Y1 
*/
proc summary data=multi.logit6 print maxdec=1;
class y1;
var x;
run;
 
data logit6;
set multi.logit6;
x = x-18;
run; 
 
/*
Modèle logit multinomial. L'option "link=glogit" précise d'utiliser ce modèle.
*/
proc logistic data=logit6;
model y1(ref='0') = x / clparm=pl clodds=pl expb 
link=glogit;
score data=logit6 out=predmultilogit; 
run; 

proc freq data=predmultilogit;
table I_y1*y1 /norow nocol nocum nopercent;
run;
/*  ______________________________________________________  */
/*
Statistiques descriptives de base, calculées séparément selon les valeur de Y2 
*/

proc summary data=multi.logit6 print;
class y2;
var x;
run;
 

/*
Modèle logit cumulatif. Lorsque la variable dépendante (y) prend plus de 2 valeurs,
SAS utilise ce modèle par défaut.
*/
proc logistic data=multi.logit6;
model y2 = x / clparm=pl clodds=pl expb link=glogit;
run; 
proc logistic data=multi.logit6 descending;
model y2 = x / clparm=pl clodds=pl expb;
score data=multi.logit6 out=predcumlogit; 
run; 
 
data valp;
valp = 1-CDF("CHISQ", 193.796 - 192.041, 1);
run;
proc print data=valp;
var valp;
run;

