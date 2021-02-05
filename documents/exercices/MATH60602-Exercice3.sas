**Exercice pratique : segmentation de types de bières;
**Julie Meloche;
**===================================================;
proc contents data=multi.biere;
run;

*Le tableau biere contient de l'information sur 35 types de bières;
*Chaque ligne est un type de bière, il y a donc 35 observations;
*La base de données contient les variables suivantes :
 - biere : type de bière (variable de type chaîne de caractères)
 - cout : coût pour 12 onces
 - calories : nombre de calories 
 - sodium : sodium en mg.
 - alcool : pourcentage d'alcool
 - classement : évaluation subjective de la qualité de la bière (1=Très bon, 2=bon et 3=correct);

* Statistiques descriptives;
proc means data=multi.biere;
  var cout calories sodium alcool;
run;

*En observant le tableau des statistiques descriptives, il apparaît que l'échelle 
des variables et les écart-types varie beaucoup, d'où la justification d'utiliser 
les variables standardisées. ; 

proc stdize data=multi.biere out=biere;
  var cout calories sodium alcool;
run;

proc means data=biere;
  var cout calories sodium alcool;
run;

*Méthode hiérarchique;
*====================;

**Permettra de déterminer le nombre de clusters;

proc cluster data=biere method=ward outtree=tempo nonorm rsquare;
  var cout calories sodium alcool;
  copy biere classement cout calories sodium alcool;
  ods output stat.cluster.ClusterHistory=criteres;
run;

proc cluster data=biere method=ward outtree=tempo nonorm rsquare standard;
  var cout calories sodium alcool;
  copy biere classement cout calories sodium alcool;
  ods output stat.cluster.ClusterHistory=criteres;
run;

*Graphiques;
proc sgplot data=criteres;
series x=NumberOfClusters y=RSquared/markers markerattrs=(symbol=CircleFilled);
run;
proc sgplot data=criteres;
series x=NumberOfClusters y=SemipartialRSq/markers markerattrs=(symbol=CircleFilled);
run;


*Dendogrammes;
proc tree data=tempo;
run;

*On va extraire la solution à trois regroupements;
*Cette première solution nous permettra de calculer 
les barycentres initiaux pour l'utilisation
 de la méthode du k-moyennes;

proc tree data=tempo out=tempo2 nclusters=3;
  id biere;
  copy biere classement cout calories sodium alcool;
run;

proc means data=tempo2;
  class cluster;
  var cout calories sodium alcool;
run;

*Méthode non hiérarchique : k-moyennes;
*==================================;

*On prend les moyennes des variables pour 
chaque regroupement comme barycentre de départ;

proc sort data=tempo2;
  by cluster;
run;

proc means data=tempo2;
 by cluster;
 var cout calories sodium alcool;
 output out=initial mean=cout calories sodium alcool;
run;

proc print data=initial;
run;

proc fastclus data=biere seed=initial distance maxclusters=3 out=tempo3 maxiter=30;
var cout calories sodium alcool;
run;

*Profilage des classes;
*=====================;

*Réorganisons les données pour faire le profilage sur les variables
 initiales et non les variables standardisées;

data groupe;
  set tempo3;
  keep biere cluster;
run;

proc sort data=groupe;
  by biere;
run;
  
proc sort data=multi.biere;
  by biere;
run;

data profil_biere;
  merge multi.biere groupe;
  by biere;
run;

*Statistiques descriptives sur les variables ayant servi à former les groupes;

proc means data=profil_biere;
 class cluster;
 var cout calories sodium alcool;
run;

*Statistiques descriptives sur la variable qui n'a pas servi à former les groupes;
*Cette variable donne une évaluation subjective de la qualité de la bière;

proc freq data=profil_biere;
  tables cluster*classement;
run;

*Comme la base de données est petite, on peut aussi faire sortir
 la liste des bières par regroupement;

proc sort data=profil_biere;
  by cluster;
run;

proc print data=profil_biere;
  var biere;
  by cluster;
run;
