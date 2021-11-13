*******************************;
**Cours#12 : Données manquantes;
*******************************;


**Partie 1 : Vérification des données manquantes et imputation simple;
**===================================================================;

*Fichier de données multi.survey_avec_missing;
*Ce fichier contient des données d'un sondage mené par une entreprise auprès de sa clientèle;
*Dans cet échantillon, on retrouve plusieurs variables socio-démographiques;

*Ce fichier contient les variables suivantes :

WRKSTAT : occupation
      1 = 'Plein temps'  
      2 = 'Temps partiel'  
      3 = 'Ne travaille pas temporairement'  
      4 = 'Chômage'  
      5 = 'Retraité'  
      6 = 'Etudiant'  
      7 = 'Au foyer'  
      8 = 'Autre'
MARITAL : statut marital
      1 = 'Marrié'  
      2 = 'Veuf/veuve'  
      3 = 'Divorcé'  
      4 = 'Séparé'  
      5 = 'Célibataire'
SEX
      1 = 'Homme'  
      2 = 'Femme' 
RINCOME : revenu
      1 = 'Inf ou eg à $1000'  
      2 = '$1000 à 2999'  
      3 = '$3000 à 3999'  
      4 = '$4000 à 4999'  
      5 = '$5000 à 5999'  
      6 = '$6000 à 6999'  
      7 = '$7000 à 7999'  
      8 = '$8000 à 9999'  
      9 = '$10000 - 14999'  
      10 = '$15000 - 19999'  
      11 = '$20000 - 24999'  
      12 = '$25000 et plus'
CHILDS : nombre d'enfants
AGE : age
SERVICE : Avez-vous utilisé nos services dans le dernier mois?
SATISF : Si vous avez utilisé nos services, indiquez votre niveau de satisfaction
         sur une échelle de 1 à 5 où 1 est très insatisfait et 5 très satisfait.
;

*Q1 Faites une analyse des valeurs manquantes;
*--------------------------------------------;

*Mettre l'option missing dans l'instruction TABLE pour avoir une catégorie de valeurs manquantes;
*Quel est le pourcentage de valeurs manquantes pour chacune des variables?;



proc freq data=multi.survey_avec_missing;
  tables wrkstat marital sex rincome service satisf / missing;
run;

*Mettre l'option NMISS dans l'instruction principale pour obtenir le nombre de valeurs manquantes;

proc means data=multi.survey_avec_missing N Nmiss mean std min max;
  var childs age;
run;

*Regarder la relation entre les valeurs manquantes de satisf et les valeurs prises par service
 Que constatez-vous?
;
proc freq data=multi.survey_avec_missing;
  tables satisf*service /missing;
run; 


*Supposons que le revenu est plutôt indiqué dans la variable rincome2;
*Comparer rincome2 et rincome. Que peut-on dire sur les valeurs manquantes de la variable rincome2?;

proc freq data=multi.survey_avec_missing;
  tables RINCOME2*RINCOME / missing;
run;


*Q2 Constatez l'impact des valeurs manquantes dans une analyse multivariée;
*--------------------------------------------------------------------------;

*Nous allons faire un modèle de régression logistique pour prévoir l'utilisation des services 
(la VD est SERVICE 0=non et 1=oui));
*Les variables socio-démographiques seront les variables explicatives du modèle;
*On peut traiter rincome comme une variable continue;

proc logistic data=multi.survey_avec_missing;
  class wrkstat marital / param=ref;
  model service(ref='0') =wrkstat marital sex rincome childs age/ expb;
run; 

*Combien avons-nous d'observations dans notre fichier de données?
*Combien d'observations ont été utilisées pour l'ajustement du modèle de régression logistique (vous tableau dans le output)?
*Peut-on avoir confiance dans les résultats de ce modèle?
*Y a-t-il une variable qui contient beaucoup de valeurs manquantes et qui contribuerait beaucoup
 au fait que plusieurs observations soient exclues de l'ajustement du modèle?

*Refait l'ajustement du modèle sans la variable wrkstat;

proc logistic data=multi.survey_avec_missing;
  class marital / param=ref;
  model service(ref='0') =marital sex rincome childs age/ expb;
run; 



*Combien d'observations ont été utilisées pour l'ajustement du modèle de régression logistique?

*Q3 Imputation de valeurs;
*------------------------;

*La variable AGE contient 253 valeurs manquantes;
*Comment pourriez-vous procéder pour imputer des valeurs à cette variable;



data imputation;
  set multi.survey_avec_missing;
  age_imp1=age;
  age_imp2=age;
run;

proc glm data=imputation;
  class marital ;
  model age = marital sex rincome childs / solution clparm;  
run;

proc glm data=imputation;
  class marital ;
  model age = marital rincome childs / solution clparm;  
run;
/*
proc means data=imputation;
  var rincome childs;
run;
*/
data imputation;
  set imputation;

  if age_imp1=. then age_imp1=40;

  if marital=. then marital=1;
  if rincome=. then rincome=10;
  if childs=. then childs=1.6;

  if (marital=1) then beta_marital=6.50847646;
  if (marital=2) then beta_marital=17.40389266;
  if (marital=3) then beta_marital=7.92638261;
  if (marital=4) then beta_marital=4.56406474;
  if (marital=5) then beta_marital=0;

  age_est=25.28546+beta_marital+0.56060445*rincome+2.56907377*childs;

  if age_imp2=. then age_imp2=age_est;

run;




*Travailler avec la table imputation;
*Imputer des valeurs lorsqu'il y a une valeur manquante pour les variables age_imp1 et age_imp;
*Utiliser une approche différente pour age_imp1 et age_imp2;
*Le but ici est d'utiliser votre intuition et non les notes de cours;

*Quelques pistes :
*Calculer la moyenne d'âge pour ceux qui ont des valeurs valides pour l'âge;
*Calculer la moyenne d'âge selon d'autres variables : wrkstat marital sex rincome childs;
*Est-ce que l'âge pourrait être estimé à partir de wrkstat marital sex rincome childs?;


*Avez-vous des estimations près de la réalité?
*Le code suivant vous permettra d'ajouter une variable avec l'âge sans valeur manquante;

data age (rename=(age=age_obs));
  set multi.survey_sans_missing (keep=id age);
run;

data verification (keep=id age age_imp1 age_imp2 age_obs) ;
  merge imputation age;
  by id;
run;

proc means data=verification;
  var age age_imp1 age_imp2 age_obs;
run;

data verif;
  set verification;
  if age=.;
run;

proc means data=verif;
  var age age_imp1 age_imp2 age_obs;
run;


**Fin de la partie 1**

***************************************************************************************************************************;


**Partie 2 : Imputation multiple;
**==============================;



proc mi data=multi.survey_avec_missing nimpute=0;
var service marital sex rincome childs age;
run;


data miss;
set multi.survey_avec_missing; 

if marital=1 then marital1=1; else marital1=0;
if marital=2 then marital2=1; else marital2=0;
if marital=3 then marital3=1; else marital3=0;
if marital=4 then marital4=1; else marital4=0;
if marital=. then do; marital1=.; marital2=.; marital3=.; marital4=.; end;

sex=sex-1;

run;            


proc mi data=miss out=outmi nimpute=5 seed=746382643;
var marital1 marital2 marital3 marital4 sex rincome childs age ;
run;

/* La variable "_imputation_" dans le fichier "outmi" identifie
les jeux de données imputés. Ici, on ajuste le modèle de régression
logistique séparément pour chaque jeu de données avec la commande
"by _imputation_". Il y a dnc 5 modèles en tout. Les estimations
sont sauvegardées dans le fichier "outlogistic". */

proc logistic data=outmi outest=outlogistic covout noprint;
model service(ref='0') = marital1 marital2 marital3 marital4 sex rincome childs age;
by _imputation_;
run;
data temp1;
set outlogistic;
if _type_^='PARMS' then delete; 
run;
proc print data=temp1;
run;

/* PROC MIANALYZE combine les estimations des 5 modèles afin
d'avoir les estimations finales. */

proc mianalyze data=outlogistic;
var intercept marital1 marital2 marital3 marital4 sex rincome childs age;
run; 

ods rtf close;

**Comparons les résultats obtenus avec le modèle sans imputation;
**--------------------------------------------------------------;

proc logistic data=miss;
  model service(ref='0') =marital1 marital2 marital3 marital4 sex rincome childs age/ expb;
run; 

**Comparons les résultats obtenus avec le fichier de données sans valeurs manquantes;
**----------------------------------------------------------------------------------;

data sans_miss;
set multi.survey_sans_missing; 

if marital=1 then marital1=1; else marital1=0;
if marital=2 then marital2=1; else marital2=0;
if marital=3 then marital3=1; else marital3=0;
if marital=4 then marital4=1; else marital4=0;
if marital=. then do; marital1=.; marital2=.; marital3=.; marital4=.; end;

sex=sex-1;

run;          

proc logistic data=sans_miss;
  model service(ref='0') =marital1 marital2 marital3 marital4 sex rincome childs age/ expb;
run; 


