
/* 
Modèle de Cox avec une interaction entre l'âge et le temps.
IMPORTANT: l'interaction "iaget=age*t" doit être créée à l'intérieur
de l'appel à PROC PHREG.
(p. 318)
*/


proc phreg data=multi.survival1;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1)=age iaget sexe region service / ties=exact;
iaget=age*t; 
run;


/* 
Modèle de Cox en stratifiant selon la variable "region"  
(p. 321)
*/

proc phreg data=multi.survival1;
class service(ref='0') / param=ref;
model t*censure(1)=age sexe service / ties=exact;
strata region;
run;

