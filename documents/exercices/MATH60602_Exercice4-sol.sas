/* Étape 1: Analyse exploratoire 
Aucune variable catégorielle hormis prive (binaire)
Q: est-ce qu'on inclut nadmission et ninscrits?
*/
proc means data=multi.college mean std min q1 q3 max maxdec=2;
var prive--tauxdiplom;
run;
/* Certaines universités ont une proportion de diplômés
 ou de doctorants supérieurs à 1... */

/* Investigation graphique des variables d'admission */
proc sgscatter data=multi.college;
matrix nadmission napplications ninscrits;
run;

proc sgplot data=multi.college;
scatter x=nadmission y=napplications;
reg x=nadmission y=napplications;
run;

/* Forte relation entre le nombre d'applications et 
le nombre d'admission: la plupart des établissements 
acceptent la même proportion de postulant(e)s */
proc glm data=multi.college;
model napplications=nadmission / ss3;
run;

/* Sélection de modèle avec validation externe 2/3 et 1/3 */
proc glmselect data=multi.college seed=60602;
partition fraction(validate=0.33);
* ajouter toutes les variables interactions + termes quadratiques;
effect poly=polynomial(prive m10p--tauxdiplom / degree=2);
model nadmission = poly / 
selection=stepwise(select=aic choose=validate) hier=none;
/* sélection séquentielle avec critère AIC, choix du meilleur modèle
selon l'erreur moyenne quadratique (EMQ) sur l'échantillon de validation */
run;

/* La même chose, mais cette fois avec un filet élastique 
(une variante du lasso) */
proc glmselect data=multi.college seed=60602;
partition fraction(validate=0.33);
effect polynom=polynomial(m10p--tauxdiplom / degree=2);
model nadmission = polynom / 
selection=elasticnet(steps=120 choose=validate) hier=none;
run;

proc glmselect data=multi.college seed=60602;
partition fraction(validate=0.33);
effect polynom=polynomial(m10p--tauxdiplom / degree=2);
model nadmission = polynom / 
selection=lasso(select=aic choose=validate) hier=none;
run;

/* Répétition avec la validation croisée à 10 plis */
proc glmselect data=multi.college seed=60602;
effect polynom=polynomial(m10p--tauxdiplom / degree=2);
model nadmission = polynom / 
 selection=stepwise(select=aic choose=cv) 
 cvmethod=random(10) hier=none;
run;
/* L'erreur PRESS est à l'échelle de la somme, diviser
par le nombre total d'observations pour obtenir l'EMQ */

proc glmselect data=multi.college seed=60602;
effect polynom=polynomial(m10p--tauxdiplom / degree=2);
model nadmission = polynom / 
selection=elasticnet(steps=120 choose=cv) 
cvmethod=random(10) hier=none;
run;
