/*
Valeurs manquantes dans un contexte de prévision.
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
if(ymontant EQ .) then ymontant=0;
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
var x1 x2 x31 x32 x41-x44 x5-x10;
run;


/* Création des variables explicatives au carré et de tous les termes d'interaction. */

proc glmselect data=allmiss outdesign(addinputvars)=matmod noprint;
class x3(param=ref split) x4(param=ref split);
model yachat=x1|x2|x31|x32|x41|x42|x43|x44|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  noint selection=none;
run;

/* Division des 5 échantillon imputés en deux parties: 

1) partie "entraînement": 1000 X 5 clients qui ont reçu le catalogue et pour lesquels nous avons obtenus
	les valeurs de yachat et ymontant
2) partie "test": 100 000 X 5 clients à prédire. En principe, nous n'aurions pas les valeurs de
	yachat et ymontant pour ces clients. Mais pour les fins de l'exemple, elles sont
	fournies afin de pouvoir évaluer la performance des modèles que nous allons développer */

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

proc hplogistic data=matmod;
partition role=train(train="1" validate="0");
model yachat(ref='0') = &_GLSMOD / link=logit;
selection method=stepwise;  
output out=predmiss0 pred=p_1 copyvar=(id ymontant yachat test _Imputation_); 
by _Imputation_; 
run;

data predmiss;
set predmiss0(where=(test=1));
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

data pred; 
set meanpred;
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
revenu = -10*yachatpred + ymontant*yachatpred;
run;

proc means data=result sum;
var revenu yachatpred;
run;
