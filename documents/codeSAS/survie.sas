/* /////////////////////////////////////////////////// */
/* Analyse de survie                                   */
/* /////////////////////////////////////////////////// */
/* 1. Fonction de survie */

/*
Estimation de la fonction de survie et de risque.
La variable dépendante est spécifiée avec "t*censure(1)",
ce qui veut dire que "t" est la variable qui donne le temps
de survie et "censure" est celle qui indique si le temps est
censuré ou non. La valeur entre parenthèses ("1" ici)
spécifie que, lorsque censure=1, le temps est censuré.

Description des options:
  method = méthode d'estimation utilisée. Ici "km" demande
la méthode de Kaplan-Meier.
  plots = demande des graphiques. Ici, on demande le graphe
de la fonction de survie ("survival) avec intervalles de confiances ponctuels ("cl") et
simultanés ("cb=ep"). L'option "nocensor" permet d'éviter l'ajout de signes
+ à chaque observation censuré, ce qui améliore règle générale la lisibilité du graphique.
Pour exclure le tableau de n lignes, décommenter la ligne "ods exclude"
*/

proc lifetest data=multi.survival1 method=km 
 plots=survival(cl cb=ep nocensor);
time t*censure(1);
*ods exclude ProductLimitEstimates;
run;

/*INCORRECT - pour illustrer que les estimations 
utilisées ordinairement sont biaisées */
proc means data=multi.survival1 
q1 median q3 mean maxdec=2;
var t;
run;

/* 
Tests d'égalité de deux fonctions de survie.
La commande "strata" spécifie la variable binaire qui distingue 
les deux groupes que l'on veut comparer.

Note: Si la variable dans "strata" possède plus de deux valeurs (K disons),
alors des tests d'égalités des K fonctions de survie seront produits.
*/
proc lifetest data=multi.survival1 method=km plots=survival(cl nocensor);
time t*censure(1);
strata sexe;
run;

proc lifetest data=multi.survival1 method=km plots=survival(cl nocensor);
time t*censure(1);
strata region;
run;

/* /////////////////////////////////////////////////// */
/* 2. Modèle à risques proportionnels de Cox */



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

/* /////////////////////////////////////////////////// */
/* 3. Modèle de Cox avec variables explicatives 
        qui varient dans le temps               */

/* 
Modèle de Cox avec variables explicatives qui dont les valeurs changent dans le temps.
Ici, seulement la variable "service" varie avec le temps et un seul changement peut survenir.
*/
proc print data=multi.survival3;
run;
/* Service comme variable catégorielle  */
proc phreg data=multi.survival3;
class region;
model t*censure(1)=age sexe region service1 service2 service3 / ties=exact; 

if service_avant=1 then service1=1; else service1=0;
if service_avant=2 then service2=1; else service2=0;
if service_avant=3 then service3=1; else service3=0;

if t >= temps_ch and temps_ch ^= . then do;
if service_apres=1 then service1=1; else service1=0;
if service_apres=2 then service2=1; else service2=0;
if service_apres=3 then service3=1; else service3=0;
end;
run;

/* Service comme variable continue  */
proc phreg data=multi.survival3;
class region;
model t*censure(1)=age sexe region service / ties=exact; 

service = service_avant;
if t>=temps_ch and temps_ch^=. then do;
service = service_apres;
end;

run;

/* /////////////////////////////////////////////////// */
/* 4. Modèle à risques compétitifs. */

proc freq data=multi.survival4;
tables censure;
run;

/* Modèle lorsque le client s'en va chez le compétiteur A. */

proc phreg data=multi.survival4;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1,3,4)=age sexe region  service / ties=exact; 
run;

/* Modèle lorsque le client s'en va chez le compétiteur B. */

proc phreg data=multi.survival4;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1,2,4)=age sexe region  service / ties=exact; 
run;

/* Modèle lorsque le client quitte parce qu'il n'a plus besoin de cellulaire. */

proc phreg data=multi.survival4;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1,2,3)=age sexe region  service / ties=exact; 
run;

/* /////////////////////////////////////////////////// */
/* 5. Modèle à risques non proportionnels */

/* 
Modèle de Cox avec une interaction entre l'âge et le temps.
IMPORTANT: l'interaction "iaget=age*t" doit être créée à l'intérieur
de l'appel à PROC PHREG.
*/

proc phreg data=multi.survival1;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1)=age iaget sexe region service / ties=exact;
iaget=age*t; 
run;


/* 
Modèle de Cox en stratifiant selon la variable "region"  
*/

proc phreg data=multi.survival1;
class service(ref='0') / param=ref;
model t*censure(1)=age sexe service / ties=exact;
strata region;
run;



