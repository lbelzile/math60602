
/* 
Analyse en composantes principales pour faire une analyse graphique 
avant l'analyse de regroupements.
*/ 

proc princomp data=multi.cluster out=temp cov;
var x1-x6;
run;


proc sgplot data=temp;
scatter x=prin1 y=prin2;
run;

proc sgscatter data=temp;
matrix prin1-prin5;
run;
