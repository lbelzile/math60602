
proc logistic data=multi.multinom descending;
class educ revenu sexe;
model y = age educ revenu sexe / clparm=pl clodds=pl expb;
run;

proc logistic data=multi.multinom outmodel=mod;
class educ(ref="sec") revenu(ref="1");
model y(ref="1") = age educ revenu sexe / clparm=pl clodds=pl expb link=glogit;
run;
 /* Test du rapport de vraisemblance pour H0: régression ordinale 
 logistique à cotes proportionnelles versus H1: multinomiale logistique */
data pval;
pval=1-CDF('CHISQ', 2728.565 - 2685.863, 24-6);
run;
proc print data=pval;
run;
/* Même conclusion que le test du score: on rejette l'hypothèse nulle 
que le modèle plus simple est adéquat */
/* Prédiction pour le nouveal individu */
data multinomprof;
input age educ $ revenu $ sexe;
datalines;
30 cegep 2 0
;
run; 
proc logistic inmodel=mod;
score data=multinomprof out=pred;
run;
/* Imprimer les probabilités de chaque classe */
proc print data=pred;
run;
