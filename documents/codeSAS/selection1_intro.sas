
/* Ajustement du modèle cubique.
x*x veut dire X au carré, x*x*x veut dire X à la puissance 3 etc. 
selection=none veut dire qu'il n'y a pas de sélection de variables. 
SAS ajuste donc le seul modèle spécifié, ici le modèle cubique.
*/
proc sgplot data=multi.selection1_train;
scatter x=x y=y;
run;

proc glm data=multi.selection1_train;
model y=x x*x;
run;

proc glmselect data=multi.selection1_train;
effect poly=polynomial(x / degree=10);
model y=poly / selection=none stat=aic;
run;

proc sgplot data=multi.selection1_train;
scatter x=x y=y;
reg x=x y=y / nomarkers degree=1 legendlabel="linéaire";
reg x=x y=y / nomarkers degree=2 legendlabel="quadratique";
reg x=x y=y / nomarkers degree=3 legendlabel="cubique";
reg x=x y=y / nomarkers degree=4 legendlabel="quartique";
run;

/* Validation croisée 
 voir selection2_methods pour description, mais brièvement:
 selection=backward pour ajuster tous les modèles un par un.
 couplés avec hier=single, cela contraint le modèle à ajouter
 les degrés du polynômes un par un, donc x, x x*x, etc.
 on arrête la recherche quand il n'y a plus de variables
 explicatives.
 choose=CV pour choisir le modèle final par validation croisée
 ici RANDOM(5) pour sélection aléatoire avec cinq plis
 STAT=(AIC PRESS) ajoute une colonne pour le AIC et une autre
 pour l'erreur de prédiction (LOO-CV)
 Spécifier un germe (SEED=) permet de fixer la séquence de nombres
 pseudo-aléatoires, de manière à toujours recouvrer le même modèle
 si on recompile le code.
*/
proc glmselect data=multi.selection1_train seed=2021;
effect poly=polynomial(x / degree=10);
model y=poly / selection=backward(stop=1 choose=CV) 
  stat=(aic press) cvmethod=random(5) hier=single;
run;

