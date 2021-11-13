
/* 
MACROS pour estimer le gain moyen pour une classification
avec les variables réponses binaires et les probabilités prédites.
*/ 


/*
La MACRO "logisticclass" a 8 arguments:
yvar = nom de la variable Y (variable dépendante)
ypred = probabilités prédites
dataset = nom du fichier de données SAS à utiliser

Dans ce qui suit, le gain est une mesure de l'avantage (revenu ou profit par exemple)
associé à la décision et au résultat.

c00 = gain associé à classifier une observation comme étant 0 lorsque qu'elle est en réalité 0
c01 = gain associé à classifier une observation comme étant 0 lorsque qu'elle est en réalité 1
c10 = gain associé à classifier une observation comme étant 1 lorsque qu'elle est en réalité 0
c11 = gain associé à classifier une observation comme étant 1 lorsque qu'elle est en réalité 1

cutpoint = point de coupure pour l'assignation à une classe. 
		Si la probabilité estimée est < cutpoint, alors prédiction=0
		Si la probabilité estimée est >= cutpoint, alors prédiction=1
*/

%MACRO logisticclass(yvar=,ypred=,dataset=,c00=,c01=,c10=,c11=,cutpoint=);

proc datasets;
delete classiftab valid output;
run;

/* Assign observations to 0/1 based on cutoff from probabilities &ypred */
data classiftab;
set &dataset;
if &ypred < &cutpoint then ychap=0;
else ychap=1;
run;

/* Classify observations */
data classiftab;
set classiftab;
if (ychap=1 and &yvar=0) then do; gain=&c10; good=0; falsepos=1; falseneg=0; truepos=0; trueneg=0; end; else
if (ychap=0 and &yvar=1) then do; gain=&c01; good=0; falsepos=0; falseneg=1; truepos=0; trueneg=0; end; else
if (ychap=1 and &yvar=1) then do; gain=&c11; good=1; falsepos=0; falseneg=0; truepos=1; trueneg=0; end; else
if (ychap=0 and &yvar=0) then do; gain=&c00; good=1; falsepos=0; falseneg=0; truepos=0; trueneg=1; end;
run;

/* Aggregate binary counts in a confusion matrix*/
proc means data=classiftab noprint;
var gain good truepos trueneg falsepos falseneg;
output out=valid(drop=_type_) sum=;
run;

/* Calculate specificity and sensitivity */
data valid;
set valid;
gain = gain/_freq_;
good = good/_freq_;
sensitivity=truepos/(truepos + falsepos);
specificity=trueneg/(trueneg + falseneg);
cutpoint=&cutpoint;
drop _freq_;
run;

data valid;
retain cutpoint gain sensitivity specificity good truepos trueneg falsepos falseneg;
set valid;
run;

proc datasets;
delete classiftab;
run;

%MEND logisticclass;


/*
La MACRO "mlogisticclass" permet d'estimer le gain moyen pour plusieurs point de coupure d'un seul coup.

Les paramètres yvar, dataset, c00, c01, c10, c11
sont les mêmes que pour la MACRO "logisticclass".

manycut = liste de points de coupure. Par exemple, manycut=0.05 0.1 0.15 0.2

*/

%macro mlogisticclass(yvar=,ypred=,dataset=,c00=,c01=,c10=,c11=);
options nonotes;   
ods exclude all;  
ods noresults;

proc datasets;
delete result valid;
run;

%do i = 0 %to 100 %by 2;
%logisticclass(yvar=&yvar,ypred=&ypred,dataset=&dataset,
c00=&c00,c01=&c01,c10=&c10,c11=&c11,cutpoint=&i/100);

proc append base=result data=valid;
run;
%end;

proc datasets;
delete valid;
run;

ods exclude none;  
ods results;
option notes;

proc print data=result;
run;

%mend mlogisticclass;

