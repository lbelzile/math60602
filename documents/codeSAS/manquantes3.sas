**Programme SAS : Cours12 - Valeurs manquantes;
**============================================;

data manquantes (drop=t censure); 
set multi.survival1;
depart=0;
if censure=0 then depart=1;
run;

proc logistic data=manquantes ;
class region(ref='5') service(ref='0')  / param=ref;
model depart(ref='0') =age sexe region service / clparm=pl clodds=pl expb;
run; 

proc logistic data=manquantes ;
class service(ref='0')  / param=ref;
model depart(ref='0') =age sexe service / clparm=pl clodds=pl expb;
run; 

data manquantes;
set manquantes;
alea=uniform(1);
run;

proc means data=manquantes;
var age;
run;

data manquantes;
set manquantes;
if sexe=0 then age=age+4;
if service=0 then age=age+5;
if service=1 then age=age-3;
if service=3 then age=age+2;
if age<18 then age=18;
run;

proc means data=manquantes;
class sexe;
var age;
run;

proc means data=manquantes;
class service;
var age;
run;

data manquantes;
set manquantes;
age_miss=age;
if sexe=0 then do;
if service=0 and alea<0.2 then age_miss=.;
if service=1 and alea<0.3 then age_miss=.;
if service=2 and alea<0.4 then age_miss=.;
if service=3 and alea<0.5 then age_miss=.;
end;
if sexe=1 then do;
if service=0 and alea<0.4 then age_miss=.;
if service=1 and alea<0.5 then age_miss=.;
if service=2 and alea<0.6 then age_miss=.;
if service=3 and alea<0.7 then age_miss=.;
end;
run;

proc means data=manquantes n nmiss mean std;
class sexe;
var age age_miss;
run; 

proc means data=manquantes n nmiss mean std;
class service;
var age age_miss;
run; 

proc means data=manquantes n nmiss mean std;
var age age_miss;
run; 

proc logistic data=manquantes ;
class service(ref='0')  / param=ref;
model depart(ref='0') =age sexe service / clparm=pl clodds=pl expb;
run; 

proc logistic data=manquantes ;
class service(ref='0')  / param=ref;
model depart(ref='0') =age_miss sexe service / clparm=pl clodds=pl expb;
run; 

data multi.manquantes;
set manquantes;
run;

**Imputation simple;
**=================;

*Imputer la moyenne;

proc means data=manquantes;
var age_miss;
run; 

data manquantes;
set manquantes;
age_imp1=age_miss;
if age_miss=. then age_imp1=35.15;
run;

proc means data=manquantes mean std;
var age age_miss age_imp1;
run;

data test;
set manquantes;
if age_miss=.;
erreur=(age-age_imp1)**2;
run; 
proc means data=test mean;
var erreur;
run;

proc logistic data=manquantes ;
class service(ref='0')  / param=ref;
model depart(ref='0') = age_imp1 sexe service / clparm=pl clodds=pl expb;
run; 

*Imputer la moyenne selon la variable sexe;

proc means data=manquantes;
class sexe;
var age age_miss;
run; 

data manquantes;
set manquantes;
age_imp2=age_miss;
if age_miss=. and sexe=0 then age_imp2=35.63;
if age_miss=. and sexe=1 then age_imp2=34.06;
run;

proc means data=manquantes;
var age age_miss age_imp2;
run;

data test;
set manquantes;
if age_miss=.;
erreur=(age-age_imp2)**2;
run; 
proc means data=test mean;
var erreur;
run;

proc logistic data=manquantes ;
class service(ref='0')  / param=ref;
model depart(ref='0') =age_imp2 sexe service / clparm=pl clodds=pl expb;
run; 


*Imputer la moyenne selon la variable service;

proc means data=manquantes;
class service;
var age age_miss;
run; 

data manquantes;
set manquantes;
age_imp3=age_miss;
if age_miss=. and service=0 then age_imp3=37.57;
if age_miss=. and service=1 then age_imp3=31.59;
if age_miss=. and service=2 then age_imp3=34.92;
if age_miss=. and service=3 then age_imp3=37.38;
run;

proc means data=manquantes;
var age age_miss age_imp3;
run;

data test;
set manquantes;
if age_miss=.;
erreur=(age-age_imp3)**2;
run; 
proc means data=test sum;
var erreur;
run;

proc logistic data=manquantes ;
class service(ref='0')  / param=ref;
model depart(ref='0') =age_imp3 sexe service / clparm=pl clodds=pl expb;
run; 

*Utiliser un modèle de régression linéaire pour imputer les valeurs;

proc glm data=manquantes;
class service;
model age_miss=sexe service / ss3 solution clparm ;
output out=previsions predicted=p;
run;

data previsions;
set previsions;
age_imp4=age_miss;
if age_miss=. then age_imp4=p;
run;

proc means data=previsions;
var age age_miss age_imp4;
run;

data test;
set previsions;
if age_miss=.;
erreur=(age-age_imp4)**2;
run; 
proc means data=test sum;
var erreur;
run;

proc logistic data=previsions;
class service(ref='0')  / param=ref;
model depart(ref='0') =age_imp4 sexe service / clparm=pl clodds=pl expb;
run; 


data multi.manquantes ;
set multi.manquantes;
drop alea region;
run;