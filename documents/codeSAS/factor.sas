*** Analyse factorielle;
*** Ce script contient tous les fichiers libellés `factor` dans le répertoire;
***=============================;

*Partie 1 : Statistiques descriptives;
*------------------------------------;

*Données : fichier "factor2" dans la librairie "multi";
*Consultez le recueil pour la description des variables;

*Exercice : produisez des statistiques descriptives pour les variables x1 à x12;
*1A - Combien y a-t-il de répondants?;
*1B - Quel est le minimum et le maximum de chaque variable?;
*1C - Quels sont les éléments les plus importants pour un client?;
*1D - Pour quels éléments y a-t-il le plus de consensus entre les répondants?;

proc means data=multi.factor2;
  var X1-X12;
run;

proc sgplot data=multi.factor2;             
vbar X7;
run;

proc sgplot data=multi.factor2;             
vbar X4;
run;

proc sgplot data=multi.factor2;             
vbar X5;
run;

*Partie 2 : Coefficient de corrélation linéaire;
*----------------------------------------------;
*Théorie : P.23 et 24 du recueil;

*2A - Calculez la corrélation entre X8 et X11 et décrivez cette corrélation;

proc corr data=multi.factor2;
var X8 X11;
run;
*Ce graphique permet de visualiser la relation entre les 2 variables;
*Regardez l'estimation de la droite plutôt que le nuage de points;
proc sgscatter data=multi.factor2;         
plot X8*X11 / reg=(degree=1);
run;

*2B - Calculez la corrélation entre X3 et X7 et décrivez cette corrélation;

proc corr data=multi.factor2;
var X3 X7;
run;
proc sgscatter data=multi.factor2;         
plot X3*X7 / reg=(degree=1);
run;

*2C - Calculez la corrélation entre X1 et X3 et décrivez cette corrélation;

proc corr data=multi.factor2;
var X1 X3;
run;
proc sgscatter data=multi.factor2;         
plot X1*X3 / reg=(degree=1);
run;


*Calcul de la matrice de corrélation entre toutes les variables;
proc corr data=multi.factor2;
var x1-x12;
run; 

*2D - Identifier les groupes de variables qui semblent corrélées entre elles?;
 
*Partie 3 : Modèle d'analyse factorielle;
*---------------------------------------;

*Explication des options utilisées:
method=ml: pour spécifier la méthode utilisée pour estimer les loadings (ici "ml").
rotate=varimax: pour faire la rotation des facteurs avec la méthode varimax .
maxiter=500: l'algorithme ne fera pas plus de 500 itérations pour tenter de converger.
nfact=4: pour fixer à 4 le nombre de facteurs. 
hey: permet d'éviter un arrêt prématuré du processus d'estimation (explications en classe).
(p. 32);

proc factor data=multi.factor2 method=ml rotate=varimax nfact=4 maxiter=500 flag=.3  hey;
var x1-x12;
run; 

/* Ici, le test khi-deux (statistique du rapport de vraisemblance?) suit une loi 
nulle khi-deux avec 24 degrés de liberté. 
On peut calculer manuellement la valeur-p (même résultat que SAS).
*/
data pval;
pval = 1-CDF("chisq", 12.5708, 24);
run;
proc print data=pval;
var pval;
run;

*3A - Consultez le tableau de résultats « Rotated Factor Pattern » et trouvez
      quelle variable est associée à quelle facteur;
*3B - Décrivez chaque facteur par une courte phrase;

*Partie 4 : Choix du nombre de facteurs;
*--------------------------------------;

**Méthode du maximum de vraisemblance;
*4A - Ajustez les modèles avec 1, 2, 3, 4 et 5 facteurs afin de choisir le nombre
de facteurs à l'aides des critères AIC, SBC et du test d'hypothèse;
title "Solution à un facteur";
proc factor data=multi.factor2 method=ml rotate=varimax nfact=1 maxiter=500 flag=.3 hey;
var x1-x12;
* on ne sélectionne que le tableau avec les critères d'information;
ods select Factor.InitialSolution.FitMeasures; 
run; 
title "Solution à deux facteurs";
proc factor data=multi.factor2 method=ml rotate=varimax nfact=2 maxiter=500 flag=.3 hey;
var x1-x12;
ods select Factor.InitialSolution.FitMeasures;
run; 
title "Solution à trois facteurs";
proc factor data=multi.factor2 method=ml rotate=varimax nfact=3 maxiter=500 flag=.3 hey;
var x1-x12;
run; 
title "Solution à quatre facteurs";
proc factor data=multi.factor2 method=ml rotate=varimax nfact=4 maxiter=500 flag=.3 hey;
var x1-x12;
ods select Factor.InitialSolution.FitMeasures;
run; 
*Note: l'option priors=one est nécessaire ici car sinon le modèle à 4 facteurs 
sera retourné à cause du critère MINEIGEN;
title "Solution à cinq facteur";
proc factor data=multi.factor2 method=ml rotate=varimax nfact=5 maxiter=500 flag=.3 hey priors=one;
var x1-x12;
ods select Factor.InitialSolution.FitMeasures;
run; 
title; *réinitisaliser les titres;

*Méthode des composantes principales;

*4B - Ajustez le modèle avec la méthode des composantes principales ("principal"). 
En ne spécifiant pas "nfact", SAS choisit par défaut le nombre 
de facteurs selon le critère des valeurs propres supérieures à 1.
L'option "scree" demande le diagramme d'éboulis.;

proc factor data=multi.factor2 method=principal plot=scree rotate=varimax flag=.3 ;
var x1-x12;
run; 

*Partie 5 : Construction d'échelles à partir des facteurs;
*--------------------------------------------------------;

*Création de quatre échelles;

data echelle;
set multi.factor2;
prix=mean(x1,x5);
paiement=mean(x2,x7,x10);
produit=mean(x3,x6,x9,x12);
service=mean(x4,x8,x11);
run;

*5A - Quel est le facteur qui semble le moins important pour les clients?;

proc means data=echelle mean std sum maxdec=2;
  var service x4 x8 x11 produit x3 x6 x9 x12 paiement x2 x7 x10 prix x1 x5;
run;


*5B - Pour chaque échelle, obtenez et notez le coefficient Alpha de Cronbach.; 
*Pour ce faire, il suffit d'ajouter l'option "alpha" à la fin de la première 
ligne de la procédure CORR.;

/* pour le facteur service */
proc corr data=multi.factor2 alpha;
var x4 x8 x11;
run;
/* pour le facteur produits */
proc corr data=multi.factor2 alpha;
var x3 x6 x9 x12;
run;
/* pour le facteur paiement */
proc corr data=multi.factor2 alpha;
var x2 x7 x10;
run;
/* pour le facteur prix */
proc corr data=multi.factor2 alpha;
var x1 x5;
run;

*Partie 6 : Variables ordinales;
*------------------------------;

/* 
Calcul des corrélations polychoriques. Le fichier "corr_poly" va 
contenir la matrice des corrélations polychoriques.
*/


proc corr data=multi.factor2 polychoric out=corr_poly;
var x1-x12;
run;

*Analyse factorielle en donnant la matrice des corrélations polychoriques 
comme mesure d'association;

*Note: on peut donner directement une matrice de corrélation à PROC FACTOR.
Il suffit de la mettre comme "data", comme dans "data=corr_poly";

proc factor data=corr_poly method=ml rotate=varimax nfact=4 maxiter=500 flag=.3 hey;
var x1-x12;
run; 

*Complément : Pour comprendre davantage...;

*Obtenons la matrice de corrélation ordinaire;
proc corr data=multi.factor2 out=matcorr;
var x1-x12;
run; 

*Avec la matrice de corrélation;
proc factor data=matcorr method=ml rotate=varimax nfact=4 maxiter=500 flag=.3 hey;
var x1-x12;
run; 

*Avec le jeu de données;
proc factor data=multi.factor2  method=ml rotate=varimax nfact=4 maxiter=500 flag=.3  hey;
var x1-x12;
run; 

*Partie 7 : Analyse factorielle avec la rotation varimax oblique ("obvarimax");
*-----------------------------------------------------------------------------; 

proc factor data=multi.factor2 method=ml rotate=obvarimax nfact=4 maxiter=500 flag=.3 hey;
var x1-x12;
run; 

*Partie 8 : Scores factoriels;
*----------------------------;
*L'option "score out=scorefact" va créer un fichier de données qui 
s'appelera "scorefact" et qui contiendra les 4 scores factoriels;

proc factor data=multi.factor2 method=ml rotate=varimax nfact=4 maxiter=500 hey score out=scorefact;
var x1-x12;
run; 

*8A - Quelles sont les corrélations entre les scores factoriels et les échelles
 construites en faisant la moyenne arithmétiques des items de chaque facteur?;

*Calculez les échelles dans le jeu de données où on retrouve aussi les scores factoriels;
data temp;
set scorefact;
prix=mean(x1,x5);
paiement=mean(x2,x7,x10);
produit=mean(x3,x6,x9,x12);
service=mean(x4,x8,x11);
run;


proc corr data=temp;
var factor1-factor4;
with service produit paiement prix;
run;



