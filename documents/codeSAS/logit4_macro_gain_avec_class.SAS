
/* 
MACROS pour estimer le gain moyen par validation-croisée pour
un modèle de classification en régression logistique.
*/ 


/*
La MACRO "cvlogistic" a 12 arguments:
yvar = nom de la variable Y (variable dépendante)
xvar = liste de toutes les variables explicatives (les X). Par exemple xvar=x1 x2 x3 x3 x4 ou bien x1-x4
xvarclass = liste des variables à inclure dans la commande CLASS de PROC LOGISTIC (un sous-ensemble de xvar)
n = nombre d'observations
k = nombre de groupes pour la validation croisée (on utilise 10 habituellement)
ncv = nombre de répétitions de la validation-croisée. À la fin, on fait la moyenne des résultats.
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

%MACRO cvlogisticclass(yvar=,xvar=,xvarclass=,n=,k=,ncv=,dataset=,c00=,c01=,c10=,c11=,cutpoint=);

proc datasets;
delete  alloutcv datapermut traincv testcv estim restestcv valid n1 n1append;
run;

data rseed;
do k=1 to &ncv;
rseed = round(1000000*ranuni(5847564)+100000);
output;
end;
run;

%LET nout=int(&n/&k);  

%DO j= 1 %to &ncv;

data tempseed; set rseed;
if _N_ NE &j then delete;
run;
data _null_ ;
set tempseed;
call symputx('rseed',rseed);
run;
 
proc datasets;
delete validcv n1append ;
run;
proc plan seed=&rseed;
factors permut=&n / noprint;
output out=permu;
run;
data &dataset;
merge &dataset permu ;
run;
proc sort data=&dataset out=datapermut;
by permut;
run;
%DO i= 1 %to &k;
proc datasets;
delete traincv testcv estim restestcv valid n1;
run;
data testcv traincv;
set datapermut;
if _N_>&nout*(&i-1) and _N_<&nout*&i+1 then output testcv;
else output traincv;
run;
proc means data=testcv noprint;
var &yvar;
output out=n1 sum=nombre_1_test;
run;
proc append base=n1append data=n1 force;
run;
proc logistic data=traincv outest=estim descending noprint;
class &xvarclass;
model &yvar = &xvar; 
score data=testcv out=restestcv;
run;							     
data restestcv;
set restestcv;
if p_1<&cutpoint then ychap=0;
else ychap=1;
run;
data restestcv;
set restestcv;
if (ychap=1 and &yvar=0) then do; gain=&c10 ; good=0; falsepos=1; falseneg=0 ; truepos=0 ; trueneg=0; end; else
if (ychap=0 and &yvar=1) then do; gain=&c01 ; good=0;falsepos=0; falseneg=1 ; truepos=0 ; trueneg=0; end; else
if (ychap=1 and &yvar=1) then do; gain=&c11  ; good=1; falsepos=0; falseneg=0 ; truepos=1 ; trueneg=0; end; else
if (ychap=0 and &yvar=0) then do; gain=&c00   ; good=1; falsepos=0; falseneg=0 ; truepos=0 ; trueneg=1; end;

run;
proc means data=restestcv noprint;
var gain good truepos trueneg falsepos falseneg;
output out=valid mean=;
run;
proc append base=validcv data=valid force;
run;
%END;
data validcv;
merge validcv n1append;
run;
data validcv;
set validcv;
sensitivity=_freq_*truepos/nombre_1_test;
specificity=_freq_*trueneg/(_freq_-nombre_1_test);
cutpoint=&cutpoint;
run;
proc means data=validcv mean;
var cutpoint gain good sensitivity specificity;
output out=outcv;
run;
data outcv;set outcv;
if _stat_ NE "MEAN" then delete;
run;
data outcv;set outcv;
keep cutpoint gain good sensitivity specificity;
run;
proc append base=alloutcv data=outcv;
run;
%END;
proc means data=alloutcv mean ;
output out=meanallcv;
run;
data meanallcv;set meanallcv;
if _stat_ NE "MEAN" then delete;
run;
data meanallcv;set meanallcv;
keep cutpoint gain good sensitivity specificity;
run;

proc datasets;
delete  outcv validcv permu datapermut traincv testcv estim restestcv valid n1 n1append rseed alloutcv tempseed;
run;

proc print data=meanallcv;
run;

%MEND cvlogisticclass;


/*
La MACRO "manycut_cvlogisticclass" permet d'estimer le gain moyen pour plusieurs point de coupure d'un seul coup.

Les paramétres yvar, xvar,xvarclass, n, k, ncv, dataset, c00, c01, c10, c11
sont les mémes que pour la MACRO "cvlogisticclass".

manycut = liste de points de coupure. Par exemple, manycut=0.05 0.1 0.15 0.2

*/

%macro manycut_cvlogisticclass(yvar=,xvar=,xvarclass=,n=,k=,ncv=,dataset=,c00=,c01=,c10=,c11=,manycut=);

proc datasets;
delete meanallcvmanycut;
run;

%local i manycut;
%let h=1;
%let onecut=%scan(&manycut,&h,%str( ));
%do %while (&onecut ne);

%cvlogisticclass(yvar=&yvar,xvar=&xvar,xvarclass=&xvarclass,n=&n,k=&k,ncv=&ncv,dataset=&dataset,
c00=&c00,c01=&c01,c10=&c10,c11=&c11,cutpoint=&onecut);

proc append base=meanallcvmanycut data=meanallcv;
run;

%let h=%eval(&h+1);
%let onecut=%scan(&manycut,&h,%str( ));
%end;

proc print data=meanallcvmanycut;
run;

%mend manycut_cvlogisticclass;


