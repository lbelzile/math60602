/* 
À partir des données de l'exemple sur le questionnaire portant sur un magasin,
nous allons créer un fichier contenant les 4 échelles basées sur les facteurs 
trouvés avec l'analyse factorielle. 

Par exemple, la nouvelle variable prix, mesurera l'importance accordée aux 
prix pour chaque individu de l'échantillon.

Note: le jeu de données créé, "echelle", ne sera pas conservé lorsque vous quitterez SAS. Pour
le conserver, il faut inscrire "data=multi.echelle" au lieu de "data=echelle".
(p. 33 et 43-48)
*/
data echelle;
set multi.factor2;
prix=mean(x1,x5);
paiement=mean(x2,x7,x10);
produit=mean(x3,x6,x9,x12);
service=mean(x4,x8,x11);
run;


/* 
Pour chaque échelle, nous allons obtenir le coefficient Alpha de Cronbach. 
Pour ce faire, il suffit d'ajouter l'option "alpha" é la fin de la premiére 
ligne de la procédure CORR.

Note: remarquez que nous utilisons les variables de départ (par exemple x1 et x5) 
et non pas les variables que nous venons de créer (prix, paiement, etc.).
(p. 44)
*/


/* pour le facteur service */
proc corr data=multi.factor2 alpha;
var x4 x8 x11;
run;
/* pour le facteur produits */
proc corr data=multi.factor2 alpha;
var x3 x6 x9 x12;
run;
/* pour le facteur paiement */
proc corr data=multi.factor2 alpha;
var x2 x7 x10;
run;
/* pour le facteur prix */
proc corr data=multi.factor2 alpha;
var x1 x5;
run;



