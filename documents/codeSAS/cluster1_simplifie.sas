
/*
Analyse de regroupement avec seulement 20 observations et deux variables.
Voir le fichier "cluster2_complet.sas" pour la description des commandes
et des options.
(p. 227)
*/


proc cluster data=multi.cluster1a method=ward nonorm  rsquare ;
var x1 x2;
ods output stat.cluster.ClusterHistory=criteres;
run;

proc sgplot data=criteres;
series x=NumberOfClusters y=RSquared / markers markerattrs=(symbol=CircleFilled color=red);
run;
proc sgplot data=criteres;
series x=NumberOfClusters y=SemipartialRSq / markers markerattrs=(symbol=CircleFilled color=red);
run;




