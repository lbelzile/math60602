
/* ________________________________  */

/* 
MACRO SAS pour tracer un lift chart 
(p. 174).
*/

%MACRO liftchart1(data,yreal,phat,ngroups); 

/* MACRO SAS pour obtenir un lift chart */

/* INPUT */
/*	data 	= fichier de données qui contient au moins les deux variables suivantes: */
/*	yreal 	= vraie valeur de la variable cible Y (0 ou 1) */
/*	phat 	= estimation de P(Y=1) pour le modèle étudié */
/*	ngroups = nombre de regroupement utilisés pour phat (habituellement 10) */

/* OUTPUT */
/*  Le fichier "lift" à la fin va contenir les variables suivantes:
	cumfreqpercent 				= % des observations de l'échantillon de validation qui sont classées comme 1 par le modèle
  	cumfreq 					= # d'observations de l'échantillon de validation qui sont classées comme 1 par le modèle
	cumn1y_expected_chance 		= # de 1 qui seraient détectés en choisissant les observations au hasard
	cumn1ypercent				= % des 1 qui sont détectés par le modèle 
	cumn1y						= # de 1 qui sont détectés par le modèle
	cumn1y_more_expected_chance = # de 1 supplémentaire que le modèle détecte comparativement au hasard = cumn1y-cumn1y_expected_chance
	lift 						= cumn1y/cumn1y_expected_chance

Un liftchart (avec cumn1ypercent et cumfreqpercent) sera produit
*/

data outsample;
set  &data ;
phat= &phat ;
yreal= &yreal ;
run;
data outsample;
set outsample;
if phat=. then delete;
if yreal=. then delete;
keep phat yreal;
run;

proc means data=outsample n noprint;
var phat;
output out=ntest n=ntest;
run;
data ntest;
set ntest;
keep ntest;
run;

proc means data=outsample sum noprint;
var yreal;
output out=n1test sum=n1test;
run;
data n1test;
set n1test;
keep n1test;
run;

proc rank data=outsample groups=&ngroups out=deciles descending ;
var phat;
run;

proc sort data=deciles out=deciles;
by phat;
run;

proc means data=deciles sum noprint;
var yreal;
by phat;
output out=lift sum=n1y;
run;
data lift;
set lift;
keep _freq_ phat n1y;
run;
proc sort data=lift out=lift;
by  phat;
run;
data lift;
set lift;
retain lagcumfreq lagcumn1y;
if _N_=1 then do; cumfreq=_freq_;lagcumfreq=_freq_;
				  cumn1y=n1y;lagcumn1y=n1y;
					end;
if _N_>1 then do; cumfreq=lagcumfreq+_freq_;lagcumfreq=lagcumfreq+_freq_;
				  cumn1y=lagcumn1y+n1y;lagcumn1y=lagcumn1y+n1y;
					end;
run;
data lift;
merge lift ntest n1test;
run;
data lift;
set lift ;
retain lagntest lagn1test;
if _N_=1 then do; lagntest=ntest;lagn1test=n1test;end;
if _N_>1 then do; ntest=lagntest;n1test=lagn1test;lagntest=lagntest;lagn1test=lagn1test;end;
rename phat=percent;
run;
data lift;
set lift ;
cumfreqpercent=cumfreq/ntest*100;
cumn1ypercent=cumn1y/n1test*100;
run;
data lift;
set lift ;
cumn1y_expected_chance=cumfreqpercent*n1test/100;
run;

data lift;
set lift ;
cumn1y_more_expected_chance=cumn1y-cumn1y_expected_chance;
lift=cumn1y/cumn1y_expected_chance;
run;

data lift;
set lift ;
keep cumfreqpercent cumfreq cumn1y_expected_chance cumn1ypercent cumn1y cumn1y_more_expected_chance lift  ;
run;

data lift;
set lift;
label cumfreqpercent="% des obs classées 1 par le modèle"
cumfreq="Nombre d'obs classées 1 par le modèle"
cumn1y_expected_chance="Nombre de 1 qui seraient détectés en choisissant les obs au hasard"
cumn1ypercent="% de 1 qui sont détectés par le modèle"
cumn1y="Nombre de 1 qui sont détectés par le modèle"
cumn1y_more_expected_chance="Nombre de 1 supplémentaire que le modèle détecte comparativement au hasard";
run;

proc print data=lift label;
var cumfreqpercent cumfreq cumn1y_expected_chance cumn1ypercent cumn1y cumn1y_more_expected_chance lift;
run;

ods graphics on;
proc sgplot data=lift;
series y=cumn1ypercent x=cumfreqpercent / curvelabel=""  ;
series y=cumfreqpercent x=cumfreqpercent / curvelabel="" ;
xaxis label=' Pourcentage des observations classées 1 par le modèle ' VALUES= (10 to 100 by 10) grid;
yaxis label='Pourcentage des 1 détectés par le modèle ' VALUES= (10 to 100 by 10) grid;
run; 
ods graphics off;

%MEND liftchart1;

/* fin de la MACRO */



                        
 
