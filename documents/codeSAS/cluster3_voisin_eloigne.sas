
/*
Analyse de regroupement avec la méthode du voisin le plus éloigné, au lieu de la
méthode de Ward que nous avons utilisé jusqu'à présent.
(p. 268)
*/

data temp; set multi.cluster1;
id=_N_;
run;



/* l'option "method=complete" précise d'utiliser la méthode du voisin le plus éloigné. */

proc cluster data=temp method=complete outtree=temp1 nonorm  rsquare ccc ;
var x1-x6;
copy id cluster_vrai;
ods output stat.cluster.ClusterHistory=criteres;
run;

ods graphics on;
proc sgplot data=criteres;
series x=NumberOfClusters y=distance/markers markerattrs=(symbol=CircleFilled color=red);
run;

proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy x1-x6 cluster_vrai;
run;
ods graphics off;

proc sort data=temp2 out=temp2;
by cluster;
run;

proc means data=temp2;
var x1-x6;
by cluster;
run;


