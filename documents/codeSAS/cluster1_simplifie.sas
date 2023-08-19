
/*
Analyse de regroupement avec seulement 20 observations et deux variables.
Voir le fichier "cluster2_complet.sas" pour la description des commandes
et des options.
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
series x=NumberOfClusters y=RSquared / markers markerattrs=(symbol=CircleFilled);
run;

proc sgplot data=criteres;
series x=NumberOfClusters y=SemipartialRSq / markers markerattrs=(symbol=CircleFilled);
run;