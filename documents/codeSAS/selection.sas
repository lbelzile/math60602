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

      
   /* NOTE IMPORTANTE: il faut d'abord préparer les données en exécutant la 1e partie
   du programme "prepare_DBM.sas", afin d'avoir un fichier nommé "train" qui contient
   l'échantillon d'apprentissage et un fichier nommé "test" qui contient les clients
   à cibler (ou a scorer"). */
   
   /* Commandes pour conserver seulement les 210 clients, parmi les 1000,
   qui ont acheté quelque chose */
   
   data trainymontant;
   set train;
   if ymontant=. then delete;
   run;
   
   /* Commandes pour conserver seulement les  clients, parmi les 100 000,
   qui ont acheté quelque chose. Ces observations serviront à évaluer 
   la performance réelle des modèles retenus par les différentes 
   méthodes de sélection de modèle. */
   
   data testymontant;
   set test;
   if ymontant=. then delete;
   run;
   
   /* 
   Commandes pour effectuer une recherche "all-subset" avec le critère du R carré
   et extraire le meilleur modèle avec une variable, le meilleur avec 2 variables etc. 
   */
   

   proc reg data=trainymontant;
   model ymontant= x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10 / selection=rsquare best=1 aic sbc;
   run;

   
   /* 
   Commandes pour évaluer la performance du modèle retenu par lecritère AIC,
   avec l'échantillon test 
   */
   
   /* La commande "score" demande à SAS de calculer les prévisions de ymontant
   pour les observations du fichier "testymontant". Elle seront sauvegardées
   dans le fichier "predaic". La variable "predymontant" contiendra les prévisions. */
   
   /* Ensuite, on calcule l'erreur au carré des prévisions et on en fait
   la moyenne */
   
   proc glmselect data=trainymontant;
   model ymontant= x1 x2 x31 x44 x5 x6 x7 x8 x9 x10 / selection=none;
   score data=testymontant out=predaic p=predymontant;
   run;
   
   data predaic;set predaic;
   erreur=(ymontant-predymontant)**2;
   run;
   
   proc means data=predaic n mean ;
   var erreur;
   run;
   
   
   /* 
   Commandes pour évaluer la performance du modèle retenu par le critére SBC,
   avec l'échantillon test 
   */
   
   proc glmselect data=trainymontant;
   model ymontant= x1 x31 x5 x6 x7 x8 x10 / selection=none;
   score data=testymontant out=predsbc p=predymontant;
   run;
   
   data predsbc;set predsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   
   proc means data=predsbc n mean ;
   var erreur;
   run;
   
   /* 
   Commandes pour ajuster le modèle avec les 104 variables sans faire de sélection
   et pour évaluer sa performance sur l'échantillon test 
   */
   
   proc glmselect data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
    cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10  /   selection=none ;
   score data=testymontant out=predall p=predymontant;
   run;
   
   data predall;set predall;
   erreur=(ymontant-predymontant)**2;
   run;
   
   proc means data=predall n mean ;
   var erreur;
   run; 
   
   
   /* 
   Commandes pour effectuer une sélection de variables avec la méthode séquentielle classique
   avec un critère d'entrée (SLE) de 0,15 et un critère de sortie (SLS) de 0,15 
   */

   proc reg data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   selection=stepwise sle=.15 sls=.15 ;
   run;

   
   /* Commandes pour évaluer la performance du modèle retenu par la méthode séquentielle classique,
   avec l'échantillon test */
   
   proc glmselect data=trainymontant;
   model ymontant= x32 x44 x5 x7 x10 cx6 cx10 
   i_x2_x31 i_x2_x43 i_x1_x43 i_x1_x6 i_x1_x10 i_x5_x8       
   i_x5_x10 i_x31_x41 i_x31_x8 i_x32_x8 i_x41_x8 i_x42_x8     
   i_x44_x6 i_x44_x9 i_x8_x10
   / selection=none;
   score data=testymontant out=predstep p=predymontant;
   run;
   data predstep;set predstep;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predstep n mean ;
   var erreur;
   run; 
   
   
   /* 
   Commandes pour faire un séquentielle avec des critères plus généreux (entrée=sortie=0,6).
   à la fin, il y aura plus de variables, 56 ici.
   Ces 56 variables seront ensuite envoyés dans une recherche all-subset. 
   */
   

   proc reg data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   selection=stepwise sle=.6 sls=.6 ;
   run;

   
   /* Recherche all-subset avec les 56 variables trouvées à l'étape précédente avec la procédure séquentielle (stepwise) */
   
   proc reg data=trainymontant;
   model ymontant=
   x2 x44 x5 x7 x8 x9 cx2 cx6 cx9 cx10
   i_x2_x1 i_x2_x31 i_x2_x41 i_x2_x42 i_x2_x43
   i_x2_x8 i_x2_x10 i_x1_x5 i_x1_x31 i_x1_x42
   i_x1_x43 i_x1_x6 i_x1_x8 i_x1_x10 i_x5_x44
   i_x5_x10 i_x31_x42 i_x31_x43 i_x31_x8
   i_x31_x9 i_x31_x10 i_x32_x41 i_x32_x42
   i_x32_x43 i_x32_x44 i_x32_x6 i_x32_x9
   i_x41_x7 i_x41_x9 i_x41_x10 i_x42_x6
   i_x42_x9 i_x42_x10 i_x43_x6 i_x43_x8
   i_x43_x9 i_x43_x10 i_x44_x7 i_x44_x6
   i_x44_x8 i_x44_x10 i_x7_x8 i_x6_x8
   i_x6_x9 i_x8_x9 i_x8_x10
   / selection=rsquare best=1 aic sbc;
   run;
   
   /* Commandes pour évaluer la performance du modèle retenu par le critère AIC, à partir des 56 variables,
   avec l'échantillon test */
   
   proc glmselect data=trainymontant;
   model ymontant=
   x2 x44 x5 x7 x8 x9
   cx2 cx6 cx9 cx10
   i_x2_x1 i_x2_x31
   i_x2_x41 i_x2_x43
   i_x2_x10 i_x1_x5
   i_x1_x31 i_x1_x42
   i_x1_x43 i_x1_x6
    i_x1_x10 i_x5_x10
   i_x31_x8 i_x31_x9
   i_x32_x41 i_x32_x44
   i_x32_x6 i_x42_x6
   i_x42_x9 i_x42_x10
   i_x43_x8 i_x43_x9
   i_x43_x10 i_x44_x10
   i_x6_x8 i_x6_x9
   i_x8_x9 i_x8_x10
   / selection=none;
   score data=testymontant out=predstepaic p=predymontant;
   run;
   data predstepaic;set predstepaic;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predstepaic n mean ;
   var erreur;
   run; 
   
   
   /* Commandes pour évaluer la performance du modèle retenu par le critère BIC/SBC, à partir des 56 variables,
   sur l'échantillon test */
   
   proc glmselect data=trainymontant;
   model ymontant=
   x2 x44 x5 x7 cx6
   cx10 i_x2_x31
   i_x2_x41 i_x2_x43
   i_x2_x8 i_x1_x43
   i_x1_x6 i_x5_x10
   i_x31_x8 i_x42_x6
   / selection=none;
   score data=testymontant out=predstepsbc p=predymontant;
   run;
   data predstepsbc;set predstepsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predstepsbc n mean ;
   var erreur;
   run; 
   
   /* 
   Commandes pour faire une recherche de type séquentielle en utilisant le AIC ("select=aic"), 
   au lieu des p-values, pour entrer ou retirer des variables et le BIC/SBC ("choose=sbc")
   pour sélectionner le meilleur modèle à la toute fin. 
   */
   

   proc glmselect data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   
   selection=stepwise(select=aic choose=sbc)  ; 
   score data=testymontant out=predglmselectaicsbc p=predymontant;
   run;

   data predglmselectaicsbc;
   set predglmselectaicsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predglmselectaicsbc n mean ;
   var erreur;
   run; 
   
   /* Sélection de modèles avec régularisation
   La pénalité L1 (LASSO) force certains paramètres à zéro 
   Standardiser les variables préalablement */
   proc glmselect data=trainymontant plots=coefficients;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   
   selection=lasso(choose=sbc steps=50); 
   score data=testymontant out=predglmselectlasso p=predymontant;
   run;

   data predglmselectlasso;
   set predglmselectlasso;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predglmselectlasso n mean ;
   var erreur;
   run; 
   
   /* 
   Commandes pour faire une moyenne de modèles. Chaque modèle est construit avec
   un échantillon d'autoamorçage ("sampling=urs"). 500 échantillons sont utilisés ("nsamples=500").
   Les meilleurs 500 modèles sont conservés pour en faire la moyenne ("subset(best=500)").
   Chaque modèle est obtenu en faisant une recherche de type séquentielle en utilisant le BIC/SBC
   pour entrer ou retirer des variables et encore le SBC pour sélectionner le meilleur modèle
   à la toute fin. 
   */
   

   proc glmselect data=trainymontant seed=57484765;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   
   selection=stepwise(select=sbc choose=sbc)  ; 
   score data=testymontant out=predaverage p=predymontant;
   modelaverage nsamples=500 sampling=urs subset(best=500)  ;
   run;

   
   data predaverage;set predaverage;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predaverage n mean ;
   var erreur;
   run; 
   
   
   
   /* Utilisation de CLASS et de la syntaxe avec | et @ */
   
   
   proc glmselect data=trainymontant;
   class x3 x4;
   model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10
    /   selection=stepwise(select=aic choose=sbc)  ; 
   score data=testymontant out=predglmselectaicsbc p=predymontant;
   run;
   
   data predglmselectaicsbc;set predglmselectaicsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predglmselectaicsbc n mean ;
   var erreur;
   run; 
   
   
*=========================================;
*      selection4_syntax_interaction	  ;
*=========================================;
   
/* Créer soit-même les variables indicatrices ou bien les déclarer
avec la commande CLASS revient au même comme dans l'exemple suivant */

proc glmselect data=trainymontant;
class x3 x4;
model ymontant=x1-x10  /   selection=none;
run;

proc glmselect data=trainymontant;
model ymontant= x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10 /   selection=none;
run;


/* Utilisation de la syntaxe spéciale pour spécifier les interactions d'ordre 2 */


proc glmselect data=trainymontant;
class x3 x4;
model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 cx2 cx6 cx7 cx8 cx9 cx10  /   
selection=stepwise(select=aic choose=sbc)  ; 
score data=testymontant out=predglmselectaicsbc p=predymontant;
run;




