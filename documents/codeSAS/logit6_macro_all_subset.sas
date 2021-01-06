/* 
MACRO pour obtenir le AIC et le BIC/SBC de tous les modèles provenant d'une
recherche de type exhaustive de PROC LOGISTIC 
(p. 186)
*/

/*
La MACRO "logistic_aic_sbc_score" a 5 arguments:
yvariable = nom de la variable Y (variable dépendante)
xvariables = liste des variables explicatives. Par exemple xvar=x1 x2 x3 x3 x4 ou bien x1-x4
dataset = nom du fichier de données SAS à utiliser
minvar = nombre minimal de variables que l'on veut dans un  modèle
maxvar = nombre maximal de variables que l'on veut dans un  modèle
*/


%MACRO logistic_aic_sbc_score(yvariable=,xvariables=,dataset=,minvar=,maxvar=); 

proc datasets;
delete allaicsbc;
run;

%LET nmodels=&maxvar-&minvar+1; 
%DO i= 1 %to &nmodels;

proc datasets;
delete aicsbc model_reg_logistic temp ;
run;

proc logistic data=&dataset  ;
model &yvariable(ref='0') = &xvariables / selection=score best=1 start=&minvar stop=&maxvar;
ods output stat.Logistic.BestSubsets=model_reg_logistic;
run;

data model_reg_logistic; set model_reg_logistic;
keep VariablesInModel;
run;

data temp; set model_reg_logistic;
if _N_ NE &i then delete;
run;

data _null_ ;
set temp;
call symputx('xvar',VariablesInModel);
run;

proc logistic data=&dataset  ;
model &yvariable(ref='0') = &xvar;
ods output Stat.Logistic.FitStatistics=aicsbc;
run; 
data aicsbc;set aicsbc;
drop InterceptOnly;
if criterion ="-2 Log L" then delete;
run;
proc transpose data=aicsbc out=aicsbc;
run;
data aicsbc;set aicsbc;
rename COL1=AIC COL2=SBC;
run;
data aicsbc;set aicsbc;
keep AIC SBC;
run;

proc append base=allaicsbc data=aicsbc force;
run;
%END;

data allaicsbc;
merge allaicsbc model_reg_logistic;
run;

/* DM 'Clear Out'; */


proc print data=allaicsbc;
run;


%MEND logistic_aic_sbc_score;
