/* cluster7_acp 
Analyse en composantes principales pour faire une 
analyse graphique avant/après l'analyse de regroupements.
l'option "cov" demande d'utilise la matrice de covariance plutôt que de corrélation */
 
proc princomp data=multi.cluster out=temp cov;
var x1-x6;
run;

/* Projection sur les deux premières composantes principales 
Ici, on ajoute les étiquettes des vrais regroupements
En pratique, si vous faites cette étape après, 
utilisez les étiquettes de regroupement pour "group"*/
proc sgplot data=temp;
scatter x=prin1 y=prin2 / group=;
run;

/* Matrice de nuages de points avec les vrais étiquettes des groupements */
proc sgscatter data=multi.cluster;
matrix x1-x6 / group=;
run;

/* cluster1_simplifie
Analyse de regroupement avec seulement 20 observations et deux variables.
*/
data cluster_small;
set multi.cluster(obs=20);
keep x1 x2;
run;

proc cluster 
  data=cluster_small 
  method=ward nonorm rsquare;
var x1 x2;
ods output stat.cluster.ClusterHistory=tableau;
run;

proc sgplot data=tableau;
series x=NumberOfClusters y=RSquared / markers;
run;

proc sgplot data=criteres;
series x=NumberOfClusters y=SemipartialRSq / markers;
run;



/* cluster2_complet */
/*Analyse de regroupement avec toutes les variables et toutes
les observations pour l'exemple du voyage organisé.
*/

/* Statistiques descriptives */
proc means data=multi.cluster;
var x1-x6;
run;

/* Création d'une variable qui servira à identifier les sujets ("id=_N_").
Cette variable, nommée "id", prendra les valeurs de 1 à 150, car
"_N_" veut dire le numéro de la ligne correspondant à l'observation.
Ainsi, l'observation à la 1ère ligne aura id=1, celle à la 2ème ligne
aura id=2 etc. */

data temp; 
set multi.cluster;
id=_N_;
run;

/*
Analyse de regroupement avec la méthode de Ward ("method=ward").
Description des autres options:
rsquare = pour obtenir le RSQ et le SPRSQ
nonorm = pour ne pas que les distances soient standardisées
outtree = pour sauvegarder l'historique des regroupements (ici dans le fichier "temp1").
La commande "copy" permet de faire suivre les variables spécifiées dans le fichier
crée par "outtree".
La commande "ods output" permet de sauvegarder les critères dans un fichier
(ici "criteres") afin de faire les graphes par la suite.

IMPORTANT: la variable "" donne le vrai groupe d'appartenance
des observations. En pratique, on ne connaît pas le vrai regroupement
et donc on n'aurait pas une telle variable. Ici, elle nous permet de voir
si l'analyse a permis de bien regrouper les observations.
*/


proc cluster data=temp method=ward outtree=temp1 nonorm rsquare;
var x1-x6;
copy id  x1-x6;
ods output stat.cluster.ClusterHistory=criteres;
run;

/* Graphiques des critères à partir du fichier crée avec le "ods output" 
en zoomant sur la partie avec 30 groupements et moins */

proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=RSquared/markers;
run;
proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=SemipartialRSq/markers;
run;

/*La procédure "tree" permet de tracer un dendrogramme et d'extraire une solution.
Ici, on demande d'extraire la solution avec trois groupes ("nclusters=3")
et on la sauvegarde dans le fichier "temp2". 
Dans ce fichier, la variable nommée "cluster" identifie les groupes. */

proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy id  x1-x6;
run;


/* Calcul des moyennes des variables groupe par groupe pour l'interprétation */

/* La procédure "sort" permet de trier les données  (par rapport à la variable "cluster"). */
proc sort data=temp2 out=temp2;
by cluster;
run;

/*La procédure "means" permet d'obtenir les moyennes des 
variables x1 à x6 pour chaque modalité de la variable "cluster". 
Pour ce faire, il faut absolument trier le jeu de données 
par rapport à cette variable*/

proc means data=temp2 maxdec=2;
var x1-x6;
by cluster;
run;

/* Standardisation des variables - cluster6 */

/* 
Analyse de regroupement avec la méthode de Ward en standardisant
les variables au préalable. 
*/

data temp; 
set multi.cluster;
id=_N_;
run;

/* "proc stdize" permet de standardiser les variables de différentes manières.
L'utilisation par défaut, comme ici, standardise de la manière usuelle
en soustrayant la moyenne et en divisant par l'écart-type. Ainsi, les
variables standardisées ont une moyenne empirique de 0 et un écart-type
 (et une variance) de 1. */

proc stdize data=temp out=stand;
var x1-x6;
run;

proc means data=stand;
var x1-x6;
run;

proc cluster data=stand method=ward outtree=temp1 nonorm rsquare;
var x1-x6;
copy id  x1-x6;
ods output stat.cluster.ClusterHistory=criteres;
run;

/* De manière identique, on peut directement demander de standardiser les données
avec l'option "std" ou "standard" dans l'appel à "cluster" 
Cette option n'est pas applica
ble avec les K-moyennes ("fastclust")*/
proc cluster data=temp method=ward outtree=temp1 std nonorm rsquare;
var x1-x6;
copy id;
ods output stat.cluster.ClusterHistory=criteres;
run;

proc sgplot data=criteres;
series x=NumberOfClusters y=SemiPartialRSq/markers;
run;

proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy id x1-x6;
run;

data temp2;

run;

proc sort data=temp2 out=temp2;
by cluster;
run;
proc means data=temp2;
var x1-x6;
by cluster;
run;

proc sgscatter data=temp2;
matrix x1-x6 / group=cluster;
run;


/* cluster3_voisin_eloigne */
/*
Analyse de regroupement avec la méthode du voisin le plus éloigné,
 au lieu de la méthode de Ward que nous avons utilisé jusqu'à présent.
*/

data temp; 
set multi.cluster;
id=_N_;
run;



/* l'option "method=complete" précise d'utiliser la méthode du voisin le plus éloigné. */

proc cluster data=temp method=complete outtree=temp1 nonorm  rsquare;
var x1-x6;
copy id;
ods output stat.cluster.ClusterHistory=criteres;
run;

proc sgplot data=criteres;
series x=NumberOfClusters y=distance/markers;
run;

proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy x1-x6;
run;

proc sort data=temp2 out=temp2;
by cluster;
run;

proc means data=temp2;
var x1-x6;
by cluster;
run;



/* cluster5_non_hierarchique
Analyse non-hiérarchique en utilisant les centres de groupes
obtenus avec la méthode de Ward.
*/

/* Nous ré-effectuons certaines procédures du fichier "cluster2_complet.sas" pour utiliser les groupes obtenus 
comme point de départ pour la méthode non-hiérarchique. */

data temp; 
set multi.cluster;
id=_N_;
run;


proc cluster data=temp method=ward outtree=temp1 nonorm rsquare;
var x1-x6;
copy id  x1-x6;
run;
proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy id  x1-x6;
run;

proc sort data=temp2 out=temp2;
by cluster;
run;

/* Manipulations pour donner les centroides (les moyennes) de la solution de Ward comme 
solution initiale à la procédure "fastclus". La procédure "means" retournera 
le fichier SAS "initial" avec 6 variables (les 6 moyennes) et 3 observations (les 3 groupes).*/

proc means data=temp2;
by cluster;
var x1-x6;
output out=initial mean=x1-x6;
run;

proc print data=initial;
run;

/*
La procédure "fastclus" procède à l'analyse de regroupement non-hiérarchique (K-means).

Les options sont:
maxclusters = nombre de groupes qu'on veut (ici 3)
seed = précise (via un fichier SAS) les centres initiaux. Ici, on utilise
les moyennes des groupes obtenus avec la méthode de Ward, que nous avons
calculés à l'étape précédente avec "proc means".
distance = retourne la distance entre les barycentres de chaque groupe à la dernière itération.
out = le nom du fichier SAS où l'on retrouve les groupes obtenus.
maxiter = nombre d'itérations maximal pour les K-moyennes.
*/

proc fastclus data=temp seed=initial distance maxclusters=3 out=temp3 maxiter=30;
var x1-x6;
run;

/* Calcul des moyennes des variables groupe par groupe pour l'interprétation de la 
 solution du K-means. */

proc sort data=temp3 out=temp3;
by cluster;
run;
proc means data=temp3;
var x1-x6;
by cluster;
run;



/* voici comment assigner de nouvelles observations aux regroupements construits par fastclus */

/* création d'un fichier avec 10 observations (ce sont les 10 premières du fichier original mais ça pourrait être des nouvelles observations) */

data new; set temp;
if _N_>10 then delete;
run;

/* sauvegarde les informations du regroupement avec outstat=solution */
proc fastclus data=temp seed=initial distance maxclusters=3 
	out=temp3 maxiter=30 outstat=solution;
var x1-x6;
run;

/* l'option instat permet d'utiliser le fichier créé avec outstat 
	auparavant pour faire l'assignation des observations du fichier "new" 
 	les assignations se trouvent dans "assignation" */

proc fastclus data=new instat=solution out=assignation;
var x1-x6;
run;

/* cluster4_cityblock
Analyse de regroupement avec la distance de Manhattan au lieu de la
distance euclidienne que nous avons utilisé jusqu'à maintenant. 
*/

/* Création d'une variable particulière pour identifier les sujets.
Cette variable, nommée "id1", prendra les valeurs OB1, OB2, ... OB150.
Elle servira à "apparier" le fichier original avec la solution
produite par PROC CLUSTER. */

data temp; 
set multi.cluster;
id=_N_;
ob="OB";
run;
data temp; 
set temp;
id1=compress(ob || id);
run;


/* PROC DISTANCE permet de calculer des distances et de les sauvegarder dans un fichier. 
Ce fichier peut ensuite être fournie directement à PROC CLUSTER. 
PROC DISTANCE permet une multitude de choix de mesure de dissemblances (voir la rubrique d'aide de SAS). */

/* Ici, la distance  "cityblock" est utilisée ("method=CITYBLOCK").
Le fichier "distance" contiendra la matrice des distances ("out=distance").
Ensuite, la matrice de distance est fournie à proc cluster et on utilise la méthode "centroïde" */

proc distance data=temp method=CITYBLOCK  out=distance;
var interval(x1-x6);
run;

/* La matrice de distances calculée avec PROC DISTANCE est donnée directement
à PROC CLUSTER pour faire l'analyse.

Ici, nous prenons la méthode de liaison moyenne ("method=average"). */


proc cluster data=distance method=average outtree=temp1 nonorm rsquare;
ods output stat.cluster.ClusterHistory=criteres;
run;

proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=RSquared/markers;
run;
proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=SemipartialRSq/markers;
run;

proc tree data=temp1 out=temp2 nclusters=3;
run;



/* IMPORTANT: manipulations pour avec une solution concordant avec la solution avec les données originales.  
Cette étape est nécessaire car l'analyse a été faite avec une matrice de distances
calculée avec PROC DISTANCE et non pas avec les données originales. 
Le fichier final sera "temp3".
*/

proc sort data=temp2 out=temp2;
by _NAME_;
run;
data temp2; set temp2;
id2=_N_;
run;

proc sort data=temp out=temp;
by id1;
run;
data temp; set temp;
id2=_N_;
run;

data temp3;
merge temp2 temp;
by id2;
run;

/* Calcul des moyennes des variables par groupe. */

proc sort data=temp3 out=temp3;
by cluster;
run;

proc means data=temp3;
var x1-x6;
by cluster;
run;



