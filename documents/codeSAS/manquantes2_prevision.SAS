
/*
Valeurs manquantes dans un contexte de prévision.
(p. 341-344)
*/

/* Statistiques descriptives et patterns des valeurs manquantes pour l'échantillon d'apprentissage. */

/* l'option "where" permet d'utiliser seulement un sous-ensemble des données.
Ici "where=(train=1)" indique de seulement utiliser l'échantillon d'apprentissage. */


proc means data=multi.dbmmissing(where=(train=1)) n nmiss;
var x1-x10;
run;
proc mi data=multi.dbmmissing(where=(train=1)) nimpute=0;
var x1-x10;
run;
/* Si en temps normal on inclut y dans les variables pour l'imputation, c'est contre-indiqué ici
 parce qu'on a des valeurs manquantes dans y pour toutes les variables et donc on aurait des modèles différents
 pour l'imputation dans l'échantillon test et dans l'échantillon d'apprentissage */
/* Création des variables indicatrices pour les variables explicatives catégorielles. */

data allmiss; 
set multi.dbmmissing;
x31=0; x32=0; x41=0; x42=0; x43=0; x44=0;
run;
data allmiss; set allmiss;
if x3=. then do; x31=.; x32=.; end;
if x4=. then do; x41=.; x42=.; x43=.; x44=.; end;
if x3=1 then x31=1;
if x3=2 then x32=1;
if x4=1 then x41=1;
if x4=2 then x42=1;
if x4=3 then x43=1;
if x4=4 then x44=1;
run;

/* Imputation pour obtenir 5 jeux de données complets.

IMPORTANT: le fichier "allmiss" contient toutes les 101 000 observations (apprentissage et à prédire).
Ici on impute simultanément les données d'apprentissage
et les données à prédire car il y a aussi des valeurs manquantes
dans ces dernières. */

proc mi data=allmiss out=allmiss nimpute=5 seed=4968754;
var x1 x2 x31 x32 x41 x42 x43 x44 x5 x6 x7 x8 x9 x10;
run;


/* Création des variables explicatives au carré et de tous les termes d'interaction. */

data allmiss;set allmiss;
cx2=x2**2; cx6=x6**2; cx7=x7**2; cx8=x8**2; cx9=x9**2; cx10=x10**2;
i_x2_x1=x2*x1; i_x2_x31=x2*x31; i_x2_x32=x2*x32; i_x2_x41=x2*x41; i_x2_x42=x2*x42;
i_x2_x43=x2*x43; i_x2_x44=x2*x44; i_x2_x5=x2*x5; i_x2_x6=x2*x6; i_x2_x7=x2*x7;
i_x2_x8=x2*x8; i_x2_x9=x2*x9; i_x2_x10=x2*x10;
i_x1_x31=x1*x31; i_x1_x32=x1*x32; i_x1_x41=x1*x41; i_x1_x42=x1*x42;
i_x1_x43=x1*x43; i_x1_x44=x1*x44; i_x1_x5=x1*x5; i_x1_x6=x1*x6;
i_x1_x7=x1*x7; i_x1_x8=x1*x8; i_x1_x9=x1*x9; i_x1_x10=x1*x10;
i_x5_x31=x5*x31; i_x5_x32=x5*x32; i_x5_x41=x5*x41; i_x5_x42=x5*x42;
i_x5_x43=x5*x43; i_x5_x44=x5*x44; i_x5_x6=x5*x6; i_x5_x7=x5*x7; i_x5_x8=x5*x8;
i_x5_x9=x5*x9; i_x5_x10=x5*x10;
i_x31_x41=x31*x41; i_x31_x42=x31*x42; i_x31_x43=x31*x43; i_x31_x44=x31*x44;
i_x31_x6=x31*x6; i_x31_x7=x31*x7; i_x31_x8=x31*x8; i_x31_x9=x31*x9; i_x31_x10=x31*x10;
i_x32_x41=x32*x41; i_x32_x42=x32*x42; i_x32_x43=x32*x43; i_x32_x44=x32*x44;
i_x32_x6=x32*x6; i_x32_x7=x32*x7; i_x32_x8=x32*x8; i_x32_x9=x32*x9; i_x32_x10=x32*x10;
i_x41_x6=x41*x6; i_x41_x7=x41*x7; i_x41_x8=x41*x8; i_x41_x9=x41*x9; i_x41_x10=x41*x10;
i_x42_x6=x42*x6; i_x42_x7=x42*x7; i_x42_x8=x42*x8; i_x42_x9=x42*x9; i_x42_x10=x42*x10;
i_x43_x6=x43*x6; i_x43_x7=x43*x7; i_x43_x8=x43*x8; i_x43_x9=x43*x9; i_x43_x10=x43*x10;
i_x44_x6=x44*x6; i_x44_x7=x44*x7; i_x44_x8=x44*x8; i_x44_x9=x44*x9; i_x44_x10=x44*x10;
i_x7_x6=x7*x6; i_x7_x8=x7*x8; i_x7_x9=x7*x9; i_x7_x10=x7*x10;
i_x6_x8=x6*x8; i_x6_x9=x6*x9; i_x6_x10=x6*x10;
i_x8_x9=x8*x9; i_x8_x10=x8*x10; i_x9_x10=x9*x10;
run;

/* Division des 5 échantillon imputés en deux parties: 

1) partie "training": 1000 X 5 clients qui ont reçu le catalogue et pour lesquels nous avons obtenus
	les valeurs de yachat et ymontant
2) partie "test": 100 000 X 5 clients à prédire. En principe, nous n'aurions pas les valeurs de
	yachat et ymontant pour ces clients. Mais pour les fins de l'exemple, elles sont
	fournies afin de pouvoir évaluer la performance des modèles que nous allons développer */

data train; set allmiss;
if train = 0 then delete;
run;

data test; set allmiss;
if test = 0 then delete;
run;

/* On élimine le fichier "allmiss", qui est assez gros, afin de récupérer de la mémoire vive */
proc datasets;
delete allmiss;
run;

/* 
Estimation du modèle de régression logistique pour les 5 échantillons d'apprentissage.
On calcule aussi les estimations de P(pachat=1) pour les 5 échantillons à prédire.
Ici, on sélectionne les variables avec une approche séquentielle classique avec entrée et sortie pour test-t avec comme critère
valeur-p inférieure à 0,05.

Note: avec le "by _Imputation_", à la fois les estimations du modèle sont faites
séparément pour chaque valeur de "_Imputation_", mais aussi les estimations
de P(yachat=1). Le fichier "predmiss" va donc contenir 5 estimations de
P(yachat=1) pour chaque observation à prédire.
*/

proc logistic data=train;
model y(ref='0') = x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
cx2 cx6 cx7 cx8 cx9 cx10
i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
i_x6_x8 i_x6_x9 i_x6_x10
i_x8_x9 i_x8_x10
i_x9_x10 
  /  selection=stepwise  sle=.05 sls=.05;  
  score data=test out=predmiss; 
by _Imputation_; 
run;

/* 
Calcul de la moyenne des estimations de P(yachat=1) pour chaque observation à prédire.
Cette moyenne devient l'estimation finale de P(yachat=1). Il s'agit de la variable
"P_1" dans le fichier "pred". 
*/

proc summary data=predmiss mean;
class id;
var p_1 yachat ymontant;
output out=meanpred;
run;

data pred; set meanpred;
if _stat_ NE "MEAN" then delete;
if id=. then delete;
keep p_1 yachat ymontant id;
run;
/* On utilise 0.14 comme point de coupure 
 Normalement, on estimerait ce dernier par validation croisée
 en répétant la procédure (imputation multiple - prédiction) 
 sur des plis différents et en estimant à partir des prédictions 
 pour les données d'apprentissage. 
 On a prédit que pour les données test.
 */

data result;
set pred;
if(p_1 > 0.14) then yachatpred = 1; else yachatpred = 0;
if(ymontant = ".") then ymontant=0;
revenu = -10*yachatpred + ymontant*yachatpred;
run;

proc means data=result sum;
var revenu yachatpred;
run;
