                                              
/* 
Régression logistique avec x5 seulement.

expb: pour avoir les exp(beta) sur la ligne des paramètres estimés (les rapports de cote).
clparm=pl: pour avoir les intervalles de confiance pour beta (vraisemblance profilée).
clodds=pl: pour avoir les intervalles de confiance pour exp(beta) (vraisemblance profilée).

"y(ref='0')" spécifie qu'on utilise Y=0 comme valeur de référence.
Ainsi, on modélise P(Y=1).
*/
proc logistic data=multi.logit1;
model y(ref='0') = x5 / clparm=pl clodds=pl expb;
run; 



/* Modèle avec toutes les variables explicatives.

La commande CLASS permet de déclarer des variables explicatives catégorielles.
"x1(ref=last)" précise que la plus grande valeur de X1 est la catégorie de référence.
*/


proc logistic data=multi.logit1 ;
class x1(ref=last) x2(ref=last) x6(ref=last) /  param=ref ;
model y(ref='0') =x1-x6 / clparm=pl clodds=pl expb;
run; 



/* Même modèle que le précédent mais en créant nous-mêmes les indicatrices
pour les variables explicatives catégorielles.*/

/* Création des variables indicatrices */
data temp;
set multi.logit1;
                              
if x1=1 then x11=1; else x11=0;
if x1=2 then x12=1; else x12=0;
if x1=3 then x13=1; else x13=0;
if x1=4 then x14=1; else x14=0;

if x2=1 then x21=1; else x21=0;
if x2=2 then x22=1; else x22=0;
if x2=3 then x23=1; else x23=0;
if x2=4 then x24=1; else x24=0;

if x6=1 then x61=1; else x61=0;
if x6=2 then x62=1; else x62=0;
run;    

proc logistic data=temp ;
model y(ref='0') = x11 x12 x13 x14 x21 x22 x23 x24 x3 x4 x5 x61 x62 / clparm=pl clodds=pl expb;
run; 


/* 
Modèle sans la variable X6  afin d'obtenir le -2*LL pour faire un test 
du rapport de vraisemblance sur cette variable 
*/


proc logistic data=multi.logit1 ;
class x1(ref=last) x2(ref=last)  / param=ref;
model y(ref='0') =x1-x5;
run; 


/* 
Pour calculer la valeur-p du test de rapport de vraisemblance
*/

data pval;
pval=1-CDF('CHISQ', 49.487, 2);
run;
proc print data=pval;
run;


/* Comparaisons entre les modalités de X1 d'un seul coup */

proc logistic data=multi.logit1 ;
class x1 x2 x6 / param=glm;
model y(ref='0') =x1-x6 / clparm=pl clodds=pl expb;
lsmeans x1 /diff=all;
run; 

/* Pour obtenir les estimations de P(Y=1) et
 les intervalles de confiance pour ces probabilités */

proc logistic data=multi.logit1 ;
class x1(ref=last) x2(ref=last) x6(ref=last) / param=ref;
model y(ref='0') = x1-x6 / clparm=pl clodds=pl expb;
score data=multi.logit1 out=pred clm;
run; 

 

