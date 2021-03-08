
/*
Statistiques descriptives de base, calculées séparément selon les valeur de Y1 
(p. 205)
*/
 
 
proc summary data=multi.logit6 print;
class y1;
var x;
run;
 

/*
Modèle logit multinomial. L'option "link=glogit" précise d'utiliser ce modèle.
(p. 205)
*/


proc logistic data=multi.logit6;
model y1(ref='0') = x / clparm=pl clodds=pl  expb link=glogit;
score data=multi.logit6 out=predmultilogit; 
run; 


/*  ______________________________________________________  */


/*
Statistiques descriptives de base, calculées séparément selon les valeur de Y2 
(p. 213)
*/

 
proc summary data=multi.logit6 print;
class y2;
var x;
run;
 

/*
Modèle logit cumulatif. Lorsque la variable dépendante (y) prend plus de 2 valeurs,
SAS utilise ce modèle par défaut.
(p. 214)
*/


proc logistic data=multi.logit6 descending;
model y2 = x / clparm=pl clodds=pl expb;
score data=multi.logit6 out=predcumlogit; 
run; 
 





