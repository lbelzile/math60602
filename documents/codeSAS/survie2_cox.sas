/* Modèle de Cox avec "sexe" seulement comme variable explicative.

Lorsque plusieurs observations ont la même durée de survie, 
cela complique l'estimation et différentes façons
de traiter les ex-aequo sont possibles. La méthode "ties=exact" est 
la plus précise mais aussi la plus longue. Utiliser l'option 
"ties=breslow" si la méthode "ties=exact" prend trop de temps à
compiler.

L'option "zph" permet d'obtenir des diagnostics 
graphiques pour tester l'hypothèse de 
risques proportionnels. Si elle tient,
alors les *résidus* ne devraient pas avoir de tendance
temporelle; attention à surinterpréter les graphiques!
*/
proc lifetest data=multi.survival1;
time t*censure(1);
ods exclude ProductLimitEstimates;
strata sexe;
run;

proc phreg data=multi.survival1;
model t*censure(1)=sexe / ties=exact; 
run;



/* 
Modèle de Cox avec la variable "age" seulement 
*/


proc phreg data=multi.survival1;
model t*censure(1)=age / ties=exact; 
run;



/* 
Modèle de Cox avec toutes les variables explicatives.

La commande "CLASS" permet de traiter automatiquement les variables 
explicatives catégorielles. Elle fonctionne comme pour PROC LOGISTIC.
Voir le fichier "logit1_intro.sas".
*/

proc phreg data=multi.survival1;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1)=age sexe region service / ties=exact; 
run;


/*
Obtention de la courbe de survie pour des valeurs particulières
des variables explicatives.
*/

/* Le fichier "multi.survival2" contient 4 lignes qui
sont les 4 profils pour lesquels une estimation de la
courbe de survie est voulue. */

proc print data=multi.survival2;
run;

/* La commande "baseline" permet de calculer l'estimation de la fonction de survie
pour des valeurs spécifiées des variables explicatives.

Explications des options:
out = le fichier de données SAS qui contiendra l'estimation des fonctions de survie.
covariates = le nom du fichier SAS contenant les valeurs de x1,...,xp pour
			 lesquelles nous voulons calculer des fonctions de survie.
			Ici c'est le fichier "multi.survival2" qui contient 4 lignes. 
survival =  nom de la variable contenant les valeurs de S(t) dans le fichier "temp2". */

proc phreg data=multi.survival1 plots(overlay)=survival;
model t*censure(1)=sexe age / ties=exact;
baseline out=temp2 covariates=multi.survival2 survival=s; 
run;

/* Pour tester toutes les paires de modalités de service */
proc phreg data=multi.survival1;
class region(ref='5') service(ref='0') / param=glm;
model t*censure(1)=age sexe region service / ties=exact; 
lsmeans service / diff;
run;

