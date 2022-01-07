
/*
Analyse de regroupement avec la distance city-block, au lieu de la
distance euclidienne que nous avons utilisé jusqu'à maintenant. 
*/

/* Création d'une variable particuliére pour identifier les sujets.
Cette variable, nommée "id1", prendra les valeurs OB1, OB2, ... OB150.
Elle servira à "matcher" le fichier original avec la solution
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

Ici, nous prenons la méthode de liaison moyenne ("method=average"). 
*/


proc cluster data=distance method=average outtree=temp1 nonorm rsquare;
ods output stat.cluster.ClusterHistory=criteres;
run;

proc sgplot data=criteres;
series x=NumberOfClusters y=RSquared/markers);
run;
proc sgplot data=criteres;
series x=NumberOfClusters y=SemipartialRSq/markers);
run;

proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=RSquared/markers);
run;
proc sgplot data=criteres(where=(NumberOfClusters LE 30));
series x=NumberOfClusters y=SemipartialRSq/markers);
run;

proc tree data=temp1 out=temp2 nclusters=3;
run;


/* IMPORTANT: manipulations pour "matcher" la solution avec les données originales.  
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
data temp; 
set temp;
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
