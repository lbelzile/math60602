
/* 
Analyse en composantes principales pour faire une analyse graphique 
avant l'analyse de regroupements.
*/ 

proc princomp data=multi.cluster1 out=temp cov;
var x1-x6;
run;


proc sgplot data=temp;
scatter x=prin1 y=prin2 ;
run;
