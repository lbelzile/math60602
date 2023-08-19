/* 
Modèle de Cox avec variables explicatives qui dont les valeurs changent dans le temps.
Ici, seulement la variable "service" varie avec le temps et un seul changement peut survenir.
*/
proc print data=multi.survival3;
run;
/* Service comme variable catégorielle  */
proc phreg data=multi.survival3;
class region;
model t*censure(1)=age sexe region service1 service2 service3 / ties=exact; 

if service_avant=1 then service1=1; else service1=0;
if service_avant=2 then service2=1; else service2=0;
if service_avant=3 then service3=1; else service3=0;

if t >= temps_ch and temps_ch ^= . then do;
if service_apres=1 then service1=1; else service1=0;
if service_apres=2 then service2=1; else service2=0;
if service_apres=3 then service3=1; else service3=0;
end;
run;

/* Service comme variable continue  */
proc phreg data=multi.survival3;
class region;
model t*censure(1)=age sexe region service / ties=exact; 

service = service_avant;
if t>=temps_ch and temps_ch^=. then do;
service = service_apres;
end;

run;
