/*Analyse de regroupement avec toutes les variables et toutes
les observations pour l'exemple du voyage organisé.
(p. 241-250)
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

data temp; set multi.cluster;
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

IMPORTANT: la variable "cluster_vrai" donne le vrai groupe d'appartenance
des observations. En pratique, on ne connaît pas le vrai regroupement
et donc on n'aurait pas une telle variable. Ici, elle nous permet de voir
si l'analyse a permis de bien regrouper les observations.
*/


proc cluster data=temp method=ward 
outtree=temp1 nonorm rsquare;
var x1-x6;
copy id cluster_vrai x1-x6;
ods output stat.cluster.ClusterHistory=criteres;
run;

/* Graphiques des critères à partir du fichier crée avec le "ods output" précédent */

proc sgplot data=criteres;
series x=NumberOfClusters y=RSquared/markers markerattrs=(symbol=CircleFilled color=red);
run;
proc sgplot data=criteres;
series x=NumberOfClusters y=SemipartialRSq/markers markerattrs=(symbol=CircleFilled color=red);
run;
proc sgplot data=criteres;
series x=NumberOfClusters y=CubicClusCrit/markers markerattrs=(symbol=CircleFilled color=red);
run;

/* Mêmes graphes mais en zoomant sur la partie avec 30 clusters et moins */

proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=RSquared/markers markerattrs=(symbol=CircleFilled color=red);
run;
proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=SemipartialRSq/markers markerattrs=(symbol=CircleFilled color=red);
run;
proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=CubicClusCrit/markers markerattrs=(symbol=CircleFilled color=red);
run;


/*La procédure Tree permet de tracer un dendrogramme et d'extraire une solution.
Ici, on demande d'extraire la solution avec 3 groupes ("nclusters=3")
et de la sauvegarder dans le fichier "temp2". Dans ce fichier, la variable
nommée "cluster" identifie les groupes. */

proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy id cluster_vrai x1-x6;
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

proc means data=temp2;
var x1-x6;
by cluster;
run;


