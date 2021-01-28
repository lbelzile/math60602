/* cluster5_non_hierarchique
Analyse non-hiérarchique en utilisant les centres de groupes
obtenus avec la méthode de Ward.
*/

/* Nous ré-effectuons certaines procédures du fichier "cluster2_complet.sas" pour utiliser les groupes obtenus 
comme point de départ pour la méthode non-hiérarchique. */

data temp; set multi.cluster1;
id=_N_;
run;


proc cluster data=temp method=ward outtree=temp1 nonorm  rsquare ccc ;
var x1-x6;
copy id cluster_vrai x1-x6;
run;
proc tree data=temp1 out=temp2 nclusters=3;
id id;
copy id cluster_vrai x1-x6;
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
output out=initial mean=x1 x2 x3 x4 x5 x6;
run;
proc print data=initial;run;

/*
La procédure "fastclus" procède à l'analyse de regroupement non-hiérarchique (K-means).

Les options sont:
maxclusters = nombre de groupes qu'on veut (ici 3)
seed = précise (via un fichier SAS) les centres initiaux. Ici, on utilise
les moyennes des groupes obtenus avec la méthode de Ward, que nous avons
calculés à l'étape précédente avec "proc means".
distance = retourne la distance entre les centroïdes finaux de chaque groupe.
out = le nom du fichier SAS où l'on retrouve les groupes obtenus.
maxiter = nombre d'itérations maximal pour le K-means.
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



/* voici comment assigner (scorer) de nouvelles observations aux clusters construits par fastclus */

/* création d'un fichier avec 10 observations (ce sont les 10 premières du fichier original mais ça pourrait être des nouvelles observations) */

data new; set temp;
if _N_>10 then delete;
run;

/* sauvegarde les informations du clustering avec outstat=solution */
proc fastclus data=temp seed=initial distance maxclusters=3 out=temp3 maxiter=30 outstat=solution;
var x1-x6;
run;

/* l'option instat permet d'utiliser le fichier créé avec outstat auparavant pour faire l'assignation des observations du fichier "new" */
/* les assignations se trouvent dans "assignation" */

proc fastclus data=new instat=solution out=assignation;
var x1-x6;
run;
