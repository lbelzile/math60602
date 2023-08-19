/*
Statistiques descriptives de base, calculées séparément selon les valeur de Y1 
*/
proc summary data=multi.logit6 print maxdec=1;
class y1;
var x;
run;
 
data logit6;
set multi.logit6;
x = x-18;
run; 
 
/*
Modèle logit multinomial. L'option "link=glogit" précise d'utiliser ce modèle.
*/
proc logistic data=logit6;
model y1(ref='0') = x / clparm=pl clodds=pl expb 
link=glogit;
score data=logit6 out=predmultilogit; 
run; 

proc freq data=predmultilogit;
table I_y1*y1 /norow nocol nocum nopercent;
run;
/*  ______________________________________________________  */
/*
Statistiques descriptives de base, calculées séparément selon les valeur de Y2 
*/

proc summary data=multi.logit6 print;
class y2;
var x;
run;
 

/*
Modèle logit cumulatif. Lorsque la variable dépendante (y) prend plus de 2 valeurs,
SAS utilise ce modèle par défaut.
*/
proc logistic data=multi.logit6;
model y2 = x / clparm=pl clodds=pl expb link=glogit;
run; 
proc logistic data=multi.logit6 descending;
model y2 = x / clparm=pl clodds=pl expb;
score data=multi.logit6 out=predcumlogit; 
run; 
 
data valp;
valp = 1-CDF("CHISQ", 193.796 - 192.041, 1);
run;
proc print data=valp;
var valp;
run;
