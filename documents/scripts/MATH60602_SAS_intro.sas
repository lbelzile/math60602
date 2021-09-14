* Analyse multidimensionnelle appliquée;
* Laboratoire SAS;

*Exemples en classe;
*==================;


*Partie 1 : Familiarisation avec SAS et gestion d'un fichier de données;
*======================================================================;

*Créer une nouvelle bibliothèque ;
*--------------------------;
*bouton nouvelle bibliothèque;
*créer la bibliothèque 'multi';


*Importing a comma separated file;
*--------------------------;
*Ex: aapl.csv

*Exemple d'un programme SAS;
*--------------------------;

*Création d'un jeu de données;
data depart;
  input age age_cat n_visite n_visite_cat sexe;
cards;
32 2 10 2 1
30 2 6 2 1
48 3 11 3 0
17 1 21 3 0
;
run;

/* Un programme SAS comprend des blocs d'instructions commencant
généralement par les mots DATA (créer ou mofifier un jeu de données) ou PROC
(utiliser des procédures SAS prédéfinies).*/

*Étape DATA;
data transforme;
  set depart;
  region="Montreal";  *Les chaînes de caractères doivent être encadrées de guillemets ou apostrophes;
  age_2020=age+4;
run;

*Étape Procédure;
proc freq data=transforme;
  tables age_cat;
run;

/*REMARQUEZ QUE CHAQUE LIGNE DE CODE SE TERMINE PAR UN POINT-VIRGULE!!!
L'oubli de ce point-virgule constitue l'erreur la plus fréquente lorque
l'on commence à rédiger des programmes SAS.
*/

*Création d'un jeu de données;
*----------------------------;

 /*Explication des données :

   On a demandé à 100 personnes sortant de 5 salles de cinéma à Montréal:
   1- Quel âge avez-vous? (variable "age" ci-bas)
   2- Combien de fois avez-vous été au cinéma au cours de
      la dernière année? (variable "n_visite" ci-bas)
   3- Combien de fois pensez-vous aller au cinéma dans la prochaine annee (variable "n_visite_future" ci-bas)?

   On a également compilé de sexe de ces personnes; variable "sexe"
   (0=homme, 1=femme).

   La variable "age_cat" a été formé en format de classes pour l'âge
   de la manière suivante, elle prend la valeur:
    1 si l'âge de la personne est entre 14 et 24 ans
    2 si l'âge de la personne est entre 25 et 34 ans
    3 si l'âge de la personne est de 35 ans ou plus.

   La variable "n_visite_cat" a été formé en format des classes pour le
   nombre de visite de la manière suivante, elle prend la valeur:
    1 si le nombre de visite est de 5 ou moins
    2 si le nombre de visite est entre 6 et 10 inclusivement
    3 si le nombre de visite est de plus de 10.
*/

data intro_ex1;      /* Création d'un nouveau fichier de données nommé "intro_ex1" */
  input age age_cat n_visite n_visite_cat n_visite_future sexe;  /* Donne les noms des 6 variables */
/* L'expression "cards" signifie que l'on débute la lecture des données */
cards;
32 2 10 2  12 1
30 2 6 2 5   1
48 3 11 3 10  0
17 1 21 3 15  0
21 1 1 1 8   1
56 3 7 2 7   0
27 2 8 2 9   0
22 1 2 1 0   0
29 2 11 3 11  1
18 1 2 1 2   1
25 2 10 2 5   0
24 1 4 1 4   1
34 2 10 2 9   0
42 3 6 2 6   0
32 2 7 2 6   0
43 3 7 2 5   1
25 2 7 2 9   0
33 2 4 1 5   0
19 1 17 3 15  0
48 3 10 2 2   0
23 1 3 1 10  1
38 3 9 2 7   0
18 1 2 1 3   0
49 3 13 3 10  0
34 2 6 2 20  1
40 3 12 3 12  1
33 2 11 3 12  0
26 2 9 2 10  0
32 2 11 3 10  0
61 3 7 2 7   1
34 2 9 2 10  1
16 1 22 3 20  0
28 2 10 2 10  0
14 1 9 2 8   0
45 3 9 2 2   1
42 3 7 2 0   0
31 2 9 2 10  1
29 2 9 2 8   0
35 3 5 1 5   0
34 2 10 2 6   1
18 1 19 3 20  1
25 2 7 2 10  0
35 3 9 2 10  0
29 2 9 2 9   0
18 1 3 1 3   0
28 2 6 2 12  0
28 2 9 2 12  1
32 2 9 2 8   0
42 3 9 2 6   0
37 3 13 3 12  0
40 3 12 3 12  0
41 3 6 2 12  0
40 3 7 2 6   1
18 1 10 2 12  0
41 3 7 2 6   1
48 3 7 2 7   0
24 1 1 1 12  1
32 2 6 2 2   0
22 1 14 3 10  1
17 1 14 3 15  0
19 1 11 3 10  0
26 2 10 2 10  0
26 2 9 2 10  0
46 3 6 2 6   0
25 2 7 2 6   1
26 2 7 2 7   1
22 1 6 2 8   1
22 1 15 3 4   0
18 1 16 3 16  1
15 1 18 3 12  0
28 2 8 2 12  1
30 2 12 3 14  0
24 1 1 1 2   1
31 2 6 2 8   0
24 1 6 2 7   0
37 3 9 2 10  0
45 3 8 2 7   1
22 1 8 2 8   0
22 1 18 3 18  0
35 3 8 2 10  1
30 2 6 2 6   0
30 2 9 2 9   1
35 3 9 2 9   1
27 2 7 2 7   1
37 3 10 2 11  1
36 3 9 2 10  1
43 3 9 2 8   1
18 1 21 3 15  0
15 1 25 3 30  0
16 1 19 3 20  0
17 1 1 1 4   0
34 2 5 1 5   1
22 1 6 2 6   0
29 2 10 2 5   0
44 3 8 2 6   1
20 1 4 1 4   1
42 3 6 2 6   1
38 3 9 2 9   1
25 2 8 2 9   1
25 2 7 2 9   0
;
run;


*Partie 2 : Étapes DATA et PROC;
*==============================;

*Modifier un jeu de données qui existe déjà;

data intro_ex1_mod;
  set intro_ex1; /* Création d'un nouveau fichier de données nommé "intro_ex1_mod", à partir du fichier "intro_ex1"  */
  age_2020=age+4; /*Création d'une nouvelle variable nommée "age_2020" */
run;

*Fonctions mathématiques;
data intro_ex1_mod;
  set intro_ex1_mod;
  n_visite_mois=round(n_visite/12,0.1); /*Calculer le nombre moyen de visites par mois*/
   n_visite_carre=n_visite**2; /*Calculate le carré du nombre de visites */
run;

* Appliquer des fonctions sur plusieurs colonnes;
data intro_ex1_mod;
  set intro_ex1_mod;
  n_visite_max=max(n_visite,n_visite_future); /*Calculer le maximum entre le nombre de visites au cinéma cette
                                                année et celles anticipées pour la prochaine année*/
run;

*Conditions;
data intro_ex1_mod;
  set intro_ex1_mod;
  if age <= 17 then adulte=0;
  else adulte=1;   /* La variable adulte vaut 0 si l'individu a 17 ans ou moins et 1 sinon*/
  if (adulte=1 & n_visite_cat = 3) then adulte_fanatique = 1;   /* "&" signifie "et"*/
  else adulte_fanatique = 0;    /* La variable vaut 1 si et seulement la personne est un adulte qui a vu plus de 10 films. */
  if (n_visite=1 | n_visite=2) then visiteur_frequent=0;
  else visiteur_frequent=1;         /* "|" sinigifie "ou" */
run;

*Sélection de variables;
data intro_ex1_mod2;
  set intro_ex1_mod;
  keep age adulte_fanatique visiteur_frequent; /* Permet de garder seulement certainement variables */
run;

*Sélection d'observations;
data intro_ex1_mod3;
  set intro_ex1_mod;
  if (visiteur_frequent=1); /* Permet de garder seulement les visiteurs fréquents*/
run;

/* Nous allons maintenant voir 3 procédures de base: CONTENTS, MEANS et FREQ. Nous utiliserons aussi SORT. */

/* CONTENTS donne le contenu du fichier de données */

proc contents data=intro_ex1_mod;
run;

/* FREQ peut donner plusieurs tableaux de fréquences. Rajouter un "*" entre deux variables
permet d'obtenir le tableau croisé des deux variables*/

proc freq data=intro_ex1;
  tables sexe age_cat n_visite_cat age_cat*n_visite_cat;
run;


/* MEANS donne les résumés numériques mentionnés à la fin de la ligne, nous pouvons
   choisir parmi tous ces résumés: N, NMISS, NOBS, MIN, MAX, RANGE, SUM, SUMWGT, MEAN,
   CSS, USS, VAR, STD, STDERR, CV, SKEWNESS, KURTOSIS.*/

proc means data=intro_ex1_mod n nmiss mean std median min max;
  var age n_visite n_visite_carre;
run;

/* SORT permet d'ordonner les données selon une variable choisie
   Cette opération est nécessaire à l'utilisation de BY dans le
   prochain exemple. */

proc sort data=intro_ex1_mod;
  by sexe;
  run;

/* Un énoncé BY signifie que les moyennes seront données pour chaque groupe */

proc means data=intro_ex1_mod n nmiss mean std median min max;
  var age n_visite n_visite_carre;
  by sexe;
run;


*Partie 3 : ODS;
*==============;

/* L'utilisation de ODS permet de présenter les résultats de SAS sous une forme plus
   élégante: par exemple, sous forme de fichier RTF qui peut être édité dans Word.
   Il est aussi possible de produire des fichiers pdf ou html. */

ods rtf;
/* Pour SAS Studio (SAS University Edition), spécifier le répertoire
ods rtf file='/folders/myfolders/tableau1.rtf'; */
proc freq data=intro_ex1;
  tables age_cat*n_visite_cat;
run;

ods rtf close;

/* Le module ODS permet aussi de sélectionner une partie de la sortie SAS et d'en
   faire un jeu de données. */

ods trace on;  /* Suite à cette commande, la description de chaque partie du
                  output sera inscrite dans le journal. */

proc freq data=intro_ex1;
  tables age;
run;

ods trace off; /* Cesse d'ajouter la description au journal. */

proc freq data=intro_ex1;
  tables age;
  ods output Freq.Table1.OneWayFreqs=dist_age;
  /* Le tableau de fréquence se nomme Freq.Table1.OneWayFreqs.
  Nous le sauvegardons dans le jeu de données dist_age */
run;

/* Il est aussi possible de sélectionner les tableaux
 et ne conserver qu'une partie de la sortie
 en référant au nom de ces derniers */

ods trace on;
proc univariate data=multi.elnino;
var zon_winds;
run;
ods trace off;

/* Sélectionner uniquement deux tableaux */
ods select BasicMeasures TestsForLocation;
proc univariate data=multi.elnino;
var zon_winds;
run;



*Partie 4 : Graphiques;
*=====================;

ods graphics on;
ods rtf;

proc sgplot data=intro_ex1;              /* histogramme de l'âge */
histogram age;
run;

proc sgplot data=intro_ex1;              /* box-plot de l'âge */
hbox age;
run;

proc sgplot data=intro_ex1;          /* diagramme du nombre de visites en fonction de l'âge */
scatter x=age y=n_visite;
run;

ods rtf close;
ods graphics off;


/* Document préparé par Denis Larocque, revisé ensuite par Marc Fredette et Jean-François Plante. */


/* Exemples additionels fournis dans l'introduction
 utilisant les données El Nino */


/* PROC PRINT: imprimer des observations */
/* imprimer les 5 premières observations */
proc print data=multi.elnino (obs=5);
run;

/* Éliminer la colonne noobs */
proc print data=multi.elnino (obs=10) noobs;
run;

/* retirer les doublons */
proc sort data=multi.elnino nodupkey;
by obs;
run;

/* Fusionner des bases de données */
/* Créer un tableau avec température Farenheit:
    Copier les données de elnino,
    Créer une nouvelle Farenheit
    Ne conserver que l'identifiant et la nouvelle colonne */

data multi.farenheit;
set multi.elnino;
air_temp_f=(air_temp*(9/5))+32;
keep obs air_temp_f;
run;

/* Ordonner les données avant de les fusionner */
proc sort data=multi.elnino;
by obs;
run;

proc sort data=multi.farenheit;
by obs;
run;

data elninomerge;
merge multi.elnino multi.farenheit;
by obs;
run;

/* Passer de format large à format long */

/* Transposer de format large vers long avec température
  by:  variables à conserver comme colonnes;
       les colonnes non sélectionnées sont omises ("humidity")
  var: variables à empiler          */
proc transpose data=multi.elnino out=elnino_long  name=zone prefix=temp;
by obs--mer_winds;
var air_temp s_s_temp;
run;

/* Boîtes à moustache */

proc sgplot data=multi.elnino;
hbox air_temp;
run;

proc sgplot data=multi.elnino;
vbox air_temp / category = year;
title "Time evolution of air temperature";
yaxis label = "Air temperature (in Celsius)";
run;




