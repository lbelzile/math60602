proc lifetest data=multi.chaussures method=km 
plots=survival(cl nocensor);
ods exclude ProductLimitEstimates;
time temps*statut(1,2);
run;

data multi.chaussures_prof;
input prix sexe;
datalines;
120 0
120 1
;
run;

proc phreg data=multi.chaussures plots(overlay)=survival;
model temps*statut(1,2)=sexe prix / ties=exact;
baseline out=multi.chaussures_sp covariates=multi.chaussures_prof survival=s; 
run;

data chaussures;
set multi.chaussures;
if(temps > 15) then prixinit = 1.25*prix; 
else prixinit = prix;
run;

proc phreg data=chaussures;
model temps*statut(1,2)=sexe prixvente / ties=exact;
prixvente = prixinit;
if temps > 15 then do;
prixvente = prixinit*0.8;
end;
run;

proc phreg data=chaussures;
model temps*statut(1,2)=sexe prixt / ties=exact;
if(temps > 15) then tch = 1; else tch = 0;
prixt = prixinit -0.2*prixinit*tch;
run;
