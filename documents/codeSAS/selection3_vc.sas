
/* 
Estimation de l'EMQG pour un modèle de régression linéaire en 
utilisant la validation croisée.
*/


/* Utiliser directement glmselect avec polynome
La contrainte hierarchy=single implique qu'on ajoute seulement le
 terme d'ordre k si le terme d'ordre k-1 est déjà présent
 effect permet de créer de nouvelles variables (ici un polynôme en x)
 que l'on passe ensuite à modèle
 option stop=11 pour faire tous les modèles en partant du modèle
 avec uniquement l'ordonnée à l'origine jusqu'au modèle avec 11 covariables
 Ici, à cause de "hier", cela revient à ajouter x**10 dans le dernier modèle
 */
proc glmselect data=multi.selection1_train;
effect polyn = polynomial(x / degree=10);
model y = polyn / 
 selection=forward(stop=11 choose=CV) cvmethod=block(10) hierarchy=single;
run;



/* Le code suivant est d'intérêt historique 
Il consiste en une macro (une fonction créée par un utilisateur)
comprise entre les lignes %MACRO et %MEND, qui peut être ensuite appelée.
Comme la macro utilise la procédure reg, les variables catégorielles et les polynômes doivent être créés préalablement.
*/

/*##############1#################### */
/* création de nouvelles variables ou autres manipulations préalables */

data train;                   
set multi.selection1_train;
x1=x;
x2=x**2;
x3=x**3;
x4=x**4;
x5=x**5;
x6=x**6;
x7=x**7;
x8=x**8;
x9=x**9;
x10=x**10;
drop x;
run;
                             

/*##############2####################

/* MACRO qui estime le GMSE par validation-croisée */

/*
La macro cv a 5 arguments:
yvar = nom de la variable Y (variable dépendante)
xvar = liste des variables indépendantes (les X). Par exemple xvar=x1 x2 x3 x3 x4
n = nombre d'observations
k = nombre de groupes pour la validation croisée (on utilise 10 habituellement)
dataset = nom du fichier de données SAS à utiliser
*/

%MACRO cv(yvar=,xvar=,n=,k=,dataset=);

%LET nout=int(&n/&k);             
proc datasets;
delete validcv;
run;

* générer liste de permutations;
proc plan seed=10434052;
factors permut=&n / noprint;
output out=permu;
run;

data &dataset;
merge &dataset permu;
run;

proc sort data=&dataset out=datapermut;
by permut;
run;

%DO i= 1 %to &k;

data testcv traincv;
set datapermut;
if _N_>&nout*(&i-1) and _N_<&nout*&i+1 then output testcv;
else output traincv;
run;

proc reg data=traincv outest=estim noprint;
model &yvar = &xvar;  
run;

proc score data=testcv score=estim out=restestcv type=parms residual;
var &yvar &xvar; 
run;
proc means data=restestcv noprint;
var model1;
output out=valid uss= ;
run;
proc append base=validcv data=valid force;
run;
%END;
data validcv;
set validcv;
mse_cv=model1/_freq_;
run;
proc means data=validcv mean;
var mse_cv;
run;
/* fin de la macro cv */
%MEND cv;

/* Appels de la MACRO pour estimer l'EQMG dans notre exemple */

%cv(yvar=y,xvar=x1,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x2,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x3,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x4,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x5,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x6,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x7,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x8,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x9,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x1-x10,n=100,k=10,dataset=train);

