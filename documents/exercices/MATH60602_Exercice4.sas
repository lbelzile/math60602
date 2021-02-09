** Exercices pratiques : s�lection de mod�le;
** Julie Meloche;
**=============================;

**S�lection de variables et de mod�les;
**====================================;

**Partie#1 : pr�paration des donn�es;
**----------------------------------;


data all;
set multi.dbm;
label x1="sexe" x2="age" x3="revenu" x4="region" x5="conjoint"
x6="anneeclient" x7="semainedernier" x8="montantdernier"
x9="montantunan" x10="achatunan";
run;

/* Cr�ation de variables indicatrices pour les variables cat�gorielles. */

data all; 
set all;
x31=0; 
x32=0; 
x41=0; 
x42=0; 
x43=0; 
x44=0;
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

*S�parez le fichier de donn�es pour avoir les donn�es d'apprentissage dans un jeu de donn�es ("entrainement")
 et un jeu de donn�es pour la validation ("validation") dans un autre;
*S�lection des clients qui ont fait un achat;


**Partie 2 : Statistiques descriptives;
**------------------------------------;

*2.1 D�terminez la nature des variables ymontant et x1 � x10;
*2.2 Produisez des tableaux de fr�quence pour les variables cat�gorielles;
*2.3 Calculez des statistiques descriptives (moyenne, �cart-type,...) pour les variables continues;



**Partie 3 : Analyses bivari�es;
**=============================;

*3.1 � l'aide de la proc�dure MEANS, comparez la moyenne et l'�cart-type des achats entre :
     a. les hommes et les femmes (x1)
     b. les diff�rents niveaux de revenu (x3)
     c. les r�gions (x4)
     d. le fait d'avoir un conjoint ou non (x5).;



*3.2 Calculez les corr�lations bivari�es entre chaque variable.
     - Indiquez la variable "ymontant" en premier
     - Utilisez x41 x42 x43 x44 plut�t que x4 car il s'agit d'une variable nominale
     - M�me si ce n'est pas tout � fait correct, entrez x3;



**Partie 4 : R�gression lin�aire;
**==============================;

*4.1 Utilisez la proc�dure REG pour ajuster un mod�le avec une seule variable explicative � la fois. 
     Autrement dit, faites 10 mod�les, le 1er ne contiendra que x1, le 2i�me uniquement x2, etc.
         - la variable � pr�dire est ymontant
         - N'oubliez pas d'utiliser x31 x32 plut�t que x3 et x41 x42 x43 x44 plut�t que x4
         - x31 et x32 sont entr�es dans le m�me mod�le. M�me chose pour x41 � x44.;
*4.2 Quel mod�le a obtenu le R-carr� ajust� le plus �lev�?;




**Partie 5 : S�lection d'un mod�le � l'aide des indicateurs AIC et BIC/SCB.
**====================================================================;

*5.1 Utilisez la proc�dure GLMSELECT pour tenter de trouver le meilleur mod�le
      - Essayez diff�rentes combinaisons de variables en notant le AIC et le BIC pour chacun
      - TRUCS :
            - Commencez par inclure la variable qui avait obtenu le R-carr� ajust� le plus �lev� � la partie 4
            - Les variables avec les plus petites valeurs pour la statistique "t value" (dans le tableau
              `Parameter estimates`) sont celles qui am�nent le moins d'information.
            - Vous pouvez entrer toutes les variables dans un m�me mod�le et tenter de voir celle qui a le plus
              petit "t-value"; si le AIC et BIC/SBC augmente en excluant cette variable, il faut l'exclure;

*L'id�al serait d'ajuster le mod�le avec tous les sous-ensembles de variables possibles. 
Le nombre de sous-ensembles possibles avec 10 variables est de 2^10 = 1024... Ce serait un peu long. 
Il faut donc utiliser son jugement pour s�lectionner des sous-ensembles qui semblent int�ressants et faire un choix parmi ceux-ci;

*5.2 Combien de variables contient votre meilleur mod�le? Quel est la valeur du AIC et du BIC/SBC?;

*Avec la variable x3;

proc glmselect data=entrainement;
  model ymontant=x31 x32  / selection=none;
run;

*Avec toutes les variables;

proc glmselect data=entrainement;
  model ymontant=x1 x2 x3 x41 x42 x43 x44 x5 x6 x7 x8 x9 x10  / selection=none;
run;

*� poursuivre...;


**Partie 6 : Estimation de l'erreur moyenne quadratique globale;
**=============================;

*6.1 Pr�dire les donn�es de validation � l'aide de votre meilleur mod�le. Estimez l'erreur moyenne quadratique sur les donn�es de validation;
     *utilisez le code suivant en rempla�ant x par le sous-ensemble de variables que vous avez s�lectionn�;

proc reg data=entrainement outest=estim noprint;
  /*Remplacez x par le sous-ensemble de variables que vous avez s�lectionn�*/
  model ymontant=x; 
run;

proc score data=validation score=estim out=resvalidation type=parms residual;
  /*Remplacez x par le sous-ensemble de variables que vous avez s�lectionn�*/
  var ymontant x ; 
run;

data resvalidation;
set resvalidation;
calcul_gmse=MODEL1**2;
run;

proc means data=resvalidation mean;
  var calcul_gmse;
run; 



 
