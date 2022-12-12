

/* Calcul des scores factoriels. 

L'option "score out=scorefact" va créer un fichier de données qui 
s'appelera "scorefact" et qui contiendra les 4 scores factoriels.
*/


proc factor data=multi.factor method=ml rotate=varimax nfact=4 maxiter=500 hey score out=scorefact;
var x1-x12;
run; 

/*
Afin de comparer les scores factoriels et les échelles construites en faisant 
la moyenne arithmétique des items de chaque facteur, nous ajoutons ces échelles 
au nouveau jeu de données "scorefact". Ensuite, nous regardons la 
corrélation entre une échelle et le score factoriel qui s'y apparente.
*/

data temp;
set scorefact;
prix=mean(x1,x5);
paiement=mean(x2,x7,x10);
produit=mean(x3,x6,x9,x12);
service=mean(x4,x8,x11);
run;


proc corr data=temp;
var factor1-factor4;
with service produit paiement prix;
run;


