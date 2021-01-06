
/* Ajustement du modèle cubique.
x*x veut dire X au carré, x*x*x veut dire X à la puissance 3 etc. 
selection=none veut dire qu'il n'y a pas de sélection de variables. 
SAS ajuste donc le seul modèle spécifié, ici le modèle cubique.
(p. 76).
*/

proc glmselect data=multi.selection1_train;
model y=x x*x x*x*x  /selection=none;
run;





