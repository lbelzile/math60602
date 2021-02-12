**Exercices pratiques : cours#4;
**=============================;

**Sélection de variables et de modèles;
**====================================;

**Partie#1 : préparation des données;
**----------------------------------;

data all;
set multi.dbm;
label x1="sexe" x2="age" x3="revenu" x4="region" x5="conjoint"
x6="anneeclient" x7="semainedernier" x8="montantdernier"
x9="montantunan" x10="achatunan";
run;

/* Création de variables indicatrices pour les variables catégorielles. */

data all; set all;
x31=0; x32=0; x41=0; x42=0; x43=0; x44=0;
run;

data all;
  set all;
  if x3=1 then x31=1;
  if x3=2 then x32=1;
  if x4=1 then x41=1;
  if x4=2 then x42=1;
  if x4=3 then x43=1;
  if x4=4 then x44=1;
run;

*Séparer le fichier de données pour avoir les données d'apprentissage dans un
 et les données de validation dans un autre;
*Sélection des clients qui ont fait un achat;

data train; 
  set all;
  if train = 0 then delete;
  if ymontant=. then delete;
run;

data test; 
  set all;
  if test = 0 then delete;
  if ymontant=. then delete;
run;

**Partie 2 : Statistiques descriptives;
**------------------------------------;

*2.1 Déterminez la nature des variables ymontant et x1 à x10;
*2.2 Produisez des tableaux de fréquence pour les variables catégorielles;
*2.3 Calculez des statistiques sommaires (moyenne, écart-type,...) pour les variables continues;

proc freq data=train;
  tables x1 x3 x4 x5 x10;
run;

proc means data=train;
  var x2 x6 x7 x8 x9 x10 ymontant;
run;

**Partie 3 : Analyses bivariées;
**=============================;

*3.1 À l'aide de la procédure PROC MEANS, comparez la moyenne et l'écart-type des achats :
     a. entre les hommes et les femmes (x1)
     b. entre les différents niveaux de revenu (x3)
     c. entre les régions (x4)
     d. entre le fait d'avoir un conjoint ou non (x5).;

proc means data=train;
  class x1;
  var ymontant;
run;

proc means data=train;
  class x3;
  var ymontant;
run;

proc means data=train;
  class x4;
  var ymontant;
run;

proc means data=train;
  class x5;
  var ymontant;
run;

*3.2 Calculez les corrélations bivariées entre chaque variable.
     - Ajoutez la variable ymontant en premier
     - Utilisez x41 x42 x43 x44 plutôt que x4 car il s'agit d'une variable nominale
     - Même si ce n'est pas tout à fait correct, entrez x3;

proc corr data=train;
  var ymontant x1 x2 x3 x41 x42 x43 x44 x5 x6 x7 x8 x9 x10 ;
run;

**Partie 4 : Régression linéaire;
**==============================;

*4.1 Utilisez la procédure REG pour ajuster un modèle avec une seule variable explicative à la fois. 
     Autrement dit, faites 10 modèles, le 1er contiendra que x1, le 2ième que x2 et ainsi de suite.
         - la variable à prédire est ymontant
         - N'oubliez pas d'utiliser x31 x32 plutôt que x3 et x41 x42 x43 x44 plutôt que x4
         - x31 et x32 sont entrées dans le même modèle. Même chose pour x41 à x44.;
*4.2 Quel modèle a le R-carré ajusté le plus élevé?;

proc reg data=train;
  model ymontant=x1;
run;

proc reg data=train;
  model ymontant=x2;
run;

proc reg data=train;
  model ymontant=x31 x32;
run;

proc reg data=train;
  model ymontant=x41 x42 x43 x44;
run;

proc reg data=train;
  model ymontant=x5;
run;

proc reg data=train;
  model ymontant=x6;
run;

proc reg data=train;
  model ymontant=x7;
run;

proc reg data=train;
  model ymontant=x8;
run;

proc reg data=train;
  model ymontant=x9;
run;

proc reg data=train;
  model ymontant=x10;
run;


**Partie 5 : Sélection d'un modèle à l'aide des indicateurs AIC et SCB.
**====================================================================;

*5.1 Utilisez la procédure GLMSELECT pour tenter de trouver le meilleur modèle
      - Essayez différentes combinaisons de variables en notant le AIC et le BIC/SBC pour chacun
      - TRUCS :
            - Commencez par inclure la variable qui avait obtenu le R-carré ajusté le plus élevé à la partie 4
            - Les variables avec les plus petites valeurs pour la statistique "t value" (dans le tableau
              Parameter estimates) sont d'ordinairecelles qui amènent le moins d'information.
            - Vous pouvez entrez toutes les variables dans un même modèle et tentez de voir celle qui a le plus
              petit "t-value" si le AIC et BIC/SBC augmente en excluant cette variable, il faut l'exclure;

*L'idéal serait de tester tous les sous-ensembles de variables possibles. Le nombre de sous-ensembles
 possibles avec 10 variables est de 1024... Ce serait un peu long. Il faut donc utiliser son jugement pour 
 tester des sous-ensembles qui semblent intéressants et faire un choix parmi ceux-ci;

*5.2 Combien de variables contient votre meilleur modèle? Quel est la valeur du AIC et du SBC?;

*Avec la variable x3;

proc glmselect data=train;
  model ymontant=x31 x32  /selection=none;
run;

*Avec toutes les variables;

proc glmselect data=train;
  model ymontant=x1 x2 x3 x41 x42 x43 x44 x5 x6 x7 x8 x9 x10  /selection=none;
run;


**Partie 6 : Estimation de l'EMQG;
**=============================;

*6.1 Prédisez les réponses des données de validation à l'aide de votre meilleur modèle. Estimez l'erreur moyenne quadratique globale;
     *utilisez le code suivant en remplaçant x par le sous-ensemble de variables que vous avez sélectionnées;

proc reg data=train outest=estim noprint;
  /*Remplacez x par le sous-ensemble de variables que vous avez sélectionné*/
  model ymontant=x; 
run;

proc score data=test score=estim out=restest type=parms residual;
  /*Remplacez x par le sous-ensemble de variables que vous avez sélectionné*/
  var ymontant x ; 
run;

data restest;
  set restest;
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
run; 



 
