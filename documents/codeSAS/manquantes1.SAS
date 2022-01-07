
/*
Imputation multiple pour traiter les données manquantes 
*/

/* l'option "nmiss" va fournir le nombre de valeurs manquantes par variable. */
options nolabel;
proc means data=multi.missing1 n nmiss;
var x1-x6 y;
run; 

/* PROC MI permet d'imputer les valeurs manquantes. Mais ici,
nous allons seulement l'utliser pour explorer les patterns des
valeurs manquantes. L'option "nimpute=0" fait en sorte
qu'il n'y aura pas d'imputation. */


proc mi data=multi.missing1 nimpute=0;
var y x1-x6;
run;


/* Modèle de régression logistique en ne faisant rien
pour les valeurs manquantes. Par défaut, SAS n'utilise
pas les observations qui ont au moins une valeur manquante
pour l'une des variables nécessaire à l'analyse. */

 
proc logistic data=multi.missing1;
class x1(ref=last) x2(ref=last) x6(ref=last) / param=ref;
model y(ref='0') =x1 x2 x3 x4 x5 x6 / expb;
run; 


/* Création des indicatrices pour les variables explicatives catégorielles. */
 
data miss;
set multi.missing1; 

if x1=1 then x11=1; else x11=0;
if x1=2 then x12=1; else x12=0;
if x1=3 then x13=1; else x13=0;
if x1=4 then x14=1; else x14=0;
if x1=. then do; x11=.; x12=.; x13=.; x14=.; end;

if x2=1 then x21=1; else x21=0;
if x2=2 then x22=1; else x22=0;
if x2=3 then x23=1; else x23=0;
if x2=4 then x24=1; else x24=0;
if x2=. then do; x21=.; x22=.; x23=.; x24=.; end;

if x6=1 then x61=1; else x61=0;
if x6=2 then x62=1; else x62=0;
if x6=. then do; x61=.; x62=.; end;

run;             

/* 
Imputation multiple. Ici on demande 36 jeux de données complets ("nimpute=36"), 
soit le pourcentage de cas avec données manquantes.
Ces jeux de données seront dans le fichier "outmi" ("out=outmi").
Le "seed" sert à initialiser le générateur de nombre aléatoire.
En utilisant le même germe ("seed"), on peut reproduire les mêmes résultats.
Ici, toutes les variables explicatives vont servir dans un modèle
afin de générer des imputations des valeurs manquantes. Il est préférable
de ne pas utiliser la variable dépendante (Y) pour imputer
les variables explicatives. 

IMPORTANT: pour les variables explicatives catégorielles, on utilise
les indicatrices et non pas les variables originales.
*/


proc mi data=miss out=outmi nimpute=pctmissing seed=746383643;
var x11 x12 x13 x14 x21 x22 x23 x24 x3 x4 x5 x61 x62;
run;

/* La variable "_imputation_" dans le fichier "outmi" identifie
les jeux de données imputés. Ici, on ajuste le modèle de régression
logistique séparément pour chaque jeu de données avec la commande
"by _imputation_". Il y a dnc 36 modèles en tout. Les estimations
sont sauvegardées dans le fichier "outlogistic". */

proc logistic data=outmi outest=outlogistic covout noprint;
model y(ref='0') = x11 x12 x13 x14 x21 x22 x23 x24 x3 x4 x5 x61 x62;
by _imputation_;
run;
data temp1;
set outlogistic;
if _type_^='PARMS' then delete; 
run;
proc print data=temp1;
run;

/* PROC MIANALYZE combine les estimations des 36 modèles afin
d'avoir les estimations finales. */

proc mianalyze data=outlogistic;
var intercept x11 x12 x13 x14 x21 x22 x23 x24 x3 x4 x5 x61 x62;
run;


