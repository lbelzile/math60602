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

proc logistic data=train;
model yachat(ref='0') = x1 x2 x3_1 x3_2 x4_1-x4_4 x5-x10;
output out=pred predprobs=crossvalidate;
run;

/* Compiler la macro %lifchart1 du code logit3_lift_chart.sas au préalable */
%liftchart1(pred,yachat,xp_1,10);

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


