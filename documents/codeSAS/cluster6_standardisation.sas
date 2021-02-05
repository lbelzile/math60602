
/* 
Analyse de regroupement avec la méthode de Ward en standardisant
les variables au préalable. 
*/

data temp; set multi.cluster1;
id=_N_;
run;

/* "proc stdize" permet de standardiser les variables de différentes manières.
L'utilisation par défaut, comme ici, standardise de la manière usuelle
en soustrayant la moyenne et en divisant par l'écart-type. Ainsi, les
variables standardisées ont une moyenne empirique de 0 et un écart-type (et une variance) de 1. */

proc stdize data=temp out=stand;
var x1-x6;
run;


proc cluster data=stand method=ward outtree=temp1 nonorm rsquare ccc;
var x1-x6;
copy id cluster_vrai x1-x6;
ods output stat.cluster.ClusterHistory=criteres;
run;


/* De manière identique, on peut directement demander de standardiser les données
avec l'option "std" ou "standard" dans l'appel à "cluster" */
proc cluster data=temp method=ward outtree=temp1 std nonorm rsquare;
var x1-x6;
copy id cluster_vrai x1-x6;
ods output stat.cluster.ClusterHistory=criteres;
run;

proc sgplot data=criteres;
series x=NumberOfClusters y=RSquared/markers markerattrs=(symbol=CircleFilled color=red);
run;

proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy id cluster_vrai x1-x6;
run;

proc sort data=temp2 out=temp2;
by cluster;
run;
proc means data=temp2;
var x1-x6;
by cluster;
run;






