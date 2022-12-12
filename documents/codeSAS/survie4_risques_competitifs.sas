/* 
Modèle à risques compétitifs.
*/

proc freq data=multi.survival4;
tables censure;
run;

/* Modèle lorsque le client s'en va chez le compétiteur A. */

proc phreg data=multi.survival4;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1,3,4)=age sexe region  service / ties=exact; 
run;

/* Modèle lorsque le client s'en va chez le compétiteur B. */

proc phreg data=multi.survival4;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1,2,4)=age sexe region  service / ties=exact; 
run;

/* Modèle lorsque le client quitte parce qu'il n'a plus besoin de cellulaire. */

proc phreg data=multi.survival4;
class region(ref='5') service(ref='0') / param=ref;
model t*censure(1,2,3)=age sexe region  service / ties=exact; 
run;
