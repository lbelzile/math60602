
/* 
Calcul des corrélations polychoriques. Le fichier "corr_poly" va 
contenir la matrice des corrélations polychoriques.
*/


proc corr data=multi.factor2 polychoric out=corr_poly;
var x1-x12;
run;


proc factor data=corr_poly method=ml rotate=varimax nfact=4 maxiter=500 flag=.3 hey;
var x1-x12;
run; 

