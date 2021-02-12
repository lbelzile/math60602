*4.5 Principes généraux;
*======================;

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

*Calcul des valeurs TMSE et GMSE;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
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
  calcul_gmse=MODEL1**2;
run;
proc means data=restest mean;
  var calcul_gmse;
run;

*Trouver les valeurs R-carré, AIC et BIC;
*=======================================;

*Modèle de degré 1;

proc glmselect data=train;
  model y=x; 
run;

**P.78 du manuel;

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


