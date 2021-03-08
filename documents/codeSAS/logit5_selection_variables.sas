
/* NOTE IMPORTANTE: il faut d'abord préparer les données en exécutant la 1ère partie
du programme "prepare_DBM.sas", afin d'avoir un fichier nommé "train" qui contient
l'échantillon d'apprentissage et un fichier nommé "test" qui contient les clients
à cibler (ou à prédire"). */

/*
Recherche de type exhaustive avec les 10 variables de base 
*/
proc logistic data=train;
model yachat(ref='0') = x1-x2 x31-x32 x41-x44 x6-x10 / 
selection=score best=1;
run;


/* 
Commande pour obtenir le AIC et le BIC/SBC de tous les modèles provenant d'une
recherche de type exhaustive de PROC LOGISTIC 

IMPORTANT: il faut d'abord compiler la MACRO en exécutant le fichier "logit6_macro_all_subset.sas".
*/

%logistic_aic_sbc_score(yvariable=yachat,
xvariables=x1-x2 x31-x32 x41-x44 x5-x10,
dataset=train,minvar=1,maxvar=14); 

/* Procédure haute performance hplogistic */
/* Supporte la syntaxe avec "class", mais pas l'option "split"
ce qui veut dire qu'une variable catégorielle conserve toutes
ses modalités (pas de fusion de classe possible) */
proc hplogistic data=train;
model yachat(ref='0')=x1-x2 x5-x10 x31-x32 x41-x44;
selection method=backward(select=aic choose=sbc) hierarchy=none;
run;
/* Selection avec le test du score */
proc hplogistic data=train;
model yachat(ref='0')=x1-x2 x5-x10 x31-x32 x41-x44;
selection method=backward(fast choose=aic) hierarchy=none;
run;


/*  ______________________________________________________  */

/* 
Recherche séquentielle classique avec critère d'entrée = critère de sortie = 0,05.
*/
/* effect liste=poly(variables / degré du polynome);
Tous les termes quadratiques et les interactions /
 ou produits de deux variables ou modalités
*/
proc logistic data=train outdesign=outdesign;
effect lvar=polynomial(x1-x2 x5-x10 x31-x32 x41-x44 / degree=2);
model yachat(ref='0') = lvar / 
selection=stepwise slentry=.05 slstay=.05;
run;


/*  ______________________________________________________  */

/* 
Recherche séquentielle suivie d'une recherche exhaustive
La recherche séquentielle donne 47 variables qui sont ensuite
passées à la macro "logistic_aic_sbc_score"
*/
%logistic_aic_sbc_score(yvariable=yachat,
xvariables=x2 x31 x32 x41 x42 x44 x8 x10 cx2 cx10 i_x2_x1
i_x2_x41 i_x2_x42 i_x2_x44 i_x2_x10 i_x1_x5 i_x1_x44 i_x1_x7 i_x1_x10 i_x5_x32 i_x5_x42 i_x5_x44
i_x5_x9 i_x5_x10 i_x31_x44 i_x31_x7 i_x31_x6 i_x31_x10 i_x32_x41 i_x32_x43 i_x32_x7 i_x32_x6
i_x32_x8 i_x41_x7 i_x41_x10 i_x42_x6 i_x42_x9 i_x43_x8 i_x43_x9 i_x44_x6 i_x7_x6 i_x7_x8
i_x7_x10 i_x6_x8 i_x6_x9 i_x8_x9,
dataset=train,minvar=1,maxvar=47); 


/*  ______________________________________________________  */

/* 
Utilisation de HPGENSELECT avec un Y binaire 
*/


proc hpgenselect data=train;
class x3(ref='3' split) x4(ref='5' split);
model yachat(ref='0')=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
link=logit distribution=binary;
selection method=stepwise(select=sl choose=sbc);
run;



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
set all;
if _N_>1000 then do;
 yachat=.;
 ymontant=.;end;
run;

/* Modèle Tobit en prenant les variables sélectionnées par le stepwise classique
avec entrée=sortie=0,05, pour yachat et ymontant.  
Les prévisions vont se trouver dans le fichier "tobit". */

proc qlim data=alltobit method=NRRIDG;
model yachat = x2 x41 i_x2_x1 i_x2_x10 i_x1_x5 i_x1_x10 i_x5_x32
i_x31_x44 i_x41_x7 i_x43_x8 i_x7_x8 i_x6_x8 i_x6_x10 / discrete;
model ymontant = x32 x44 x5 x7 x10 cx6 cx10 i_x2_x31
i_x2_x43 i_x1_x43 i_x1_x6 i_x1_x10 i_x5_x8
i_x5_x10 i_x31_x41 i_x31_x8 i_x32_x8
i_x41_x8 i_x42_x8 i_x44_x6 i_x44_x9 i_x8_x10  / select(yachat=1);
output out=tobit  predicted  proball;
run;

/* Calcul de la prévision de ymontant pour les observations à prédire. 
La variable "predymontant" dans le fichier "pred" contient cette prévision. */

data tobit;
set tobit;
if _N_ LE 1000 then delete;
predymontant=Prob2_yachat*P_ymontant;
run;

data tobit;set tobit;
keep predymontant;
run;
data pred;
merge test tobit;
run;


