*=========================;
*   selection1_intro	  ;
*=========================;

/* Ajustement du modèle cubique.
x*x veut dire X au carré, x*x*x veut dire X à la puissance 3 etc. 
selection=none veut dire qu'il n'y a pas de sélection de variables. 
SAS ajuste donc le seul modèle spécifié, ici le modèle cubique.
*/

proc glmselect data=multi.selection1_train;
model y=x x*x x*x*x  /selection=none;
run;

*=========================;
*  selection5_polynome	  ;
*=========================;

* Reproduit les manipulations dans la section;
*4.5 Principes généraux;

data train;                   
set multi.selection1_train;
x2=x**2;
x3=x**3;
x4=x**4;
x5=x**5;
x6=x**6;
x7=x**7;
x8=x**8;
x9=x**9;
x10=x**10;
run;

data test;                   
set multi.selection1_test;
x2=x**2;
x3=x**3;
x4=x**4;
x5=x**5;
x6=x**6;
x7=x**7;
x8=x**8;
x9=x**9;
x10=x**10;
run;

*Calcul des valeurs TMSE et EMQG;
*===============================;

*Modèle de degré 1;

proc reg data=train outest=estim;
  model y=x; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;

**Valeurs de l'erreur moyenne quadratique globale des différents modèles;


*Modèle de degré 2;

proc reg data=train outest=estim;
  model y=x x2; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;



*Modèle de degré 3;

proc reg data=train outest=estim;
  model y=x x2 x3; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;


*Modèle de degré 4;

proc reg data=train outest=estim;
  model y=x x2 x3 x4; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3 x4; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3 x4; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;


*Modèle de degré 5;

proc reg data=train outest=estim;
  model y=x x2 x3 x4 x5; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3 x4 x5; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3 x4 x5; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;


*Modèle de degré 6;

proc reg data=train outest=estim;
  model y=x x2 x3 x4 x5 x6; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3 x4 x5 x6; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3 x4 x5 x6; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;


*Modèle de degré 7;

proc reg data=train outest=estim;
  model y=x x2 x3 x4 x5 x6 x7; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3 x4 x5 x6 x7; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3 x4 x5 x6 x7; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;


*Modèle de degré 8;

proc reg data=train outest=estim;
  model y=x x2 x3 x4 x5 x6 x7 x8; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3 x4 x5 x6 x7 x8; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3 x4 x5 x6 x7 x8; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;

*Modèle de degré 9;

proc reg data=train outest=estim;
  model y=x x2 x3 x4 x5 x6 x7 x8 x9; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3 x4 x5 x6 x7 x8 x9; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3 x4 x5 x6 x7 x8 x9; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;


*Modèle de degré 10;

proc reg data=train outest=estim;
  model y=x x2 x3 x4 x5 x6 x7 x8 x9 x10; 
run;
proc score data=train score=estim out=restrain type=parms residual;
  var y x x2 x3 x4 x5 x6 x7 x8 x9 x10; 
run;
proc score data=test score=estim out=restest type=parms residual;
  var y x x2 x3 x4 x5 x6 x7 x8 x9 x10; 
run;

data restrain;
  set restrain;
  calcul_tmse=MODEL1**2;
run;
proc means data=restrain mean;
  var calcul_tmse;
run;

data restest;
  set restest;
  calcul_EMQG=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_EMQG;
run;

*Trouver les valeurs R-carré, AIC et BIC;
*=======================================;

*Modèle de degré 1;

proc glmselect data=train;
  model y=x; 
run;


*Modèle de degré 2;

proc glmselect data=train;
  model y=x x2; 
run;

*Modèle de degré 3;

proc glmselect data=train;
  model y=x x2 x3; 
run;

*Modèle de degré 4;

proc glmselect data=train;
  model y=x x2 x3 x4; 
run;

*Modèle de degré 5;

proc glmselect data=train;
  model y=x x2 x3 x4 x5; 
run;

*Modèle de degré 6;

proc glmselect data=train;
  model y=x x2 x3 x4 x5 x6; 
run;

*Modèle de degré 7;

proc glmselect data=train;
  model y=x x2 x3 x4 x5 x6 x7; 
run;

*Modèle de degré 8;

proc glmselect data=train;
  model y=x x2 x3 x4 x5 x6 x7 x8; 
run;

*Modèle de degré 9;

proc glmselect data=train;
  model y=x x2 x3 x4 x5 x6 x7 x8 x9; 
run;

*Modèle de degré 10;

proc glmselect data=train;
  model y=x x2 x3 x4 x5 x6 x7 x8 x9 x10; 
run;

*=========================;
*     selection3_vc	  ;
*=========================;



/* 
Estimation du EMQG pour un modèle de régression linéaire en 
utilisant la validation croisée.
*/

                             

/*##############2####################

/* MACRO qui estime l'EMQG par validation-croisée */

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

%MEND cv;

/* Appels de la MACRO pour estimer l'EMQG dans notre exemple */

%cv(yvar=y,xvar=x,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3 x4,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3 x4 x5,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3 x4 x5 x6,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3 x4 x5 x6 x7,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3 x4 x5 x6 x7 x8,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3 x4 x5 x6 x7 x8 x9,n=100,k=10,dataset=train);
%cv(yvar=y,xvar=x x2 x3 x4 x5 x6 x7 x8 x9 x10,n=100,k=10,dataset=train);





*=========================;
*  selection2_exhaustive  ;
*=========================;

 /* Commandes pour conserver seulement les clients, parmi les 101 000,
 qui ont acheté quelque chose. Ces observations serviront à évaluer 
 la performance réelle des modèles retenus par les différentes 
 méthodes de sélection de modèle. */

 data ymontant;
 set multi.dbm;
 drop test; *déjà train dans la base de données;
 if ymontant=. then delete;
 run;
 
 /* Commandes pour conserver seulement les  clients, parmi les 100 000,
 qui ont acheté quelque chose. Ces observations serviront à évaluer 
 la performance réelle des modèles retenus par les différentes 
 méthodes de sélection de modèle. */

 data testymontant;
 set ymontant(where=(train=0));
 run;

 /* 
 Commandes pour effectuer une recherche exhaustive avec le critère du R carré
 et extraire le meilleur modèle avec une variable, le meilleur avec 2 variables etc. 
 */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split); *permettre de fusionner des groupes;
 model ymontant=x1-x10 / selection=forward(stop=15 choose=AIC);
 *score data=testymontant out=predaic p=predymontant;
 run;
 /*En sélectionnant "split" ou en créant des indicateurs binaires, 
 le modèle final dépend de la catégorie de référence; */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split); 
 model ymontant=x1-x10 / selection=forward(stop=15 choose=SBC);
 score data=testymontant out=predsbc p=predymontant;
 run;

 /* 
 Commandes pour ajuster le modèle avec les 104 variables sans faire de sélection
 et pour évaluer sa performance sur l'échantillon test 
 */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3 x4;
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / selection=none;
 run;

 
 /* 
 Commandes pour effectuer une sélection de variables avec la méthode séquentielle "stepwise" classique
 avec un critère d'entrée (slentry) de 0,15 et un critère de sortie (slstay) de 0,15 
 L'option "hier=none" indique qu'on peut enlever un effet principal en gardant l'interaction...
 */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
 selection=stepwise(slentry=0.15 slstay=0.15 select=SL) hier=none;
 run;
 
 
 /* 
 Commandes pour faire un séquentielle avec des critères plus généreux (entrée=sortie=0,6).
 à la fin, il y aura plus de variables, 56 ici.
 Ces 56 variables seront ensuite utilisées avec une recherche exhaustive
 On enregistre les noms de variable dans glmselectOutput */
 proc glmselect data=ymontant outdesign=glmselectoutput;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
 selection=stepwise(slentry=0.6 slstay=0.6 select=SL) hier=none;
 run;
 /* On reprend la sortie, mais cette fois
 on fait une recherche exhaustive des modèles restants et on choisit
 le modèle par la suite qui a le plus petit SBC ou AIC */
 proc glmselect data=glmselectoutput;
 model ymontant= &_GLSMOD / selection=backward(stop=1 choose=sbc) hier=none;
 run;
  
 proc glmselect data=glmselectoutput;
 model ymontant= &_GLSIND / selection=backward(stop=1 choose=aic) hier=none;
 run;
 
 
 proc glmselect data=ymontant outdesign=glmselectoutput;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / 
 selection=stepwise(select=aic choose=sbc) hier=none; 
 run;
 
 
 /* 
 Commandes pour faire une moyenne de modèles. Chaque modèle est construit avec
 un échantillon d'autoamorçage ("sampling=urs"). 500 échantillons sont utilisés ("nsamples=500").
 Les meilleurs 500 modèles sont conservés pour en faire la moyenne ("subset(best=500)").
 Chaque modèle est obtenu en faisant une recherche de type séquentielle en utilisant le BIC/SBC
 pour entrer ou retirer des variables et encore le SBC pour sélectionner le meilleur modèle
 à la toute fin. 
 */
 

 proc glmselect data=ymontant seed=57484765;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / 
 selection=stepwise(select=sbc choose=sbc) hier=none; 
 score data=testymontant out=predaverage p=predymontant;
 modelaverage nsamples=500 sampling=urs subset(best=500);
 run;
 
 /* 
  La commande "score" demande à SAS de calculer les prévisions de ymontant
 pour les observations du fichier "testymontant". Elle seront sauvegardées
 dans le fichier "predaverage". La variable "predymontant" contiendra les prévisions. */
 */
 data predaverage;
 set predaverage;
 erreur=(ymontant-predymontant)**2;
 run;
 proc means data=predaverage n mean;
 var erreur;
 run; 
 
 
/* LASSO avec validation croisée à 10 groupes */
proc glmselect data=ymontant plots=coefficients;
partition role=train(train="1" validate="0");
class x3(param=ref split) x4(param=ref split);
model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /   
selection=lasso(steps=120 choose=cv) cvmethod=split(10) hier=none;
run;

