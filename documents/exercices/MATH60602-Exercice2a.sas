*** MATH 60602 : Analyse factorielle;
*** Julie Meloche;
***=============================;

***Exercice pratique supplémentaire;

*Statistiques descriptives;

proc contents data=multi.sondage_entreprise;
run;

proc means data=multi.sondage_entreprise;
  var Q8-Q17;
run;
*La variable avec la plus forte homogénéité est celle qui a la plus faible variance;

*Calul de la matrice de corrélation entre toutes les variables;
proc corr data=multi.sondage_entreprise;
var Q8-Q17;
run; 

 
*Analyse en composantes principales : choix du nombre de facteurs;
**Mettre flag=.4;

proc factor data=multi.sondage_entreprise method=principal scree rotate=varimax flag=.4 ;
var Q8-Q17;
run; 

/* 
Selon la méthode des valeurs propres, 2 facteurs seraient à retenir;
Le diagramme d'éboulis suggère un coude après 2 facteurs, donc même solution.
Évaluons les solutions de 1 à 4 facteurs avec la méthode du maximum de vraisemblance;
*/

*Modèles d'analyse factorielle;

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=1 maxiter=500 flag=.4  hey;
var Q8-Q17;
run; 
*AIC=285 et SBC=139;

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=2 maxiter=500 flag=.4  hey;
var Q8-Q17;
run; 
*AIC=84 et SBC=-25;

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=3 maxiter=500 flag=.4  hey;
var Q8-Q17;
run; 
*AIC=15 et SBC=-60;

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=4 maxiter=500 flag=.4  hey;
var Q8-Q17;
run;
*AIC=-11 et SBC=-57;

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=5 maxiter=500 flag=.4  hey priors=one;
var Q8-Q17;
run;
*AIC=-5 et SBC=-26;

/* La solution est moins évidente que pour l'exemple du recueil. Ici, utiliser entre deux et quatre facteurs serait raisonnable. Certaines variables semblent être corrélées avec plus d'un facteur.
*/

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=2 maxiter=500 flag=.4  hey;
var Q8-Q17;
run; 
/*
- Le facteur 1 est défini par les questions 8, 9, 14, 15, 16 et 17 et 
 tourne autour du rôle social de la compagnie. 
- Le facteur 2 est défini par les questions 10, 11, 12 et 13 et concerne 
 plutôt le positionnement de la compagnie dans l'industrie;
- Même si les variables peuvent être attribuées clairement  chacune à 
 un seul facteur, certaines ont quand même une corrélation assez importante 
 avec l'autre facteur;
- Les variables plutôt attribuées à un facteur, mais avec une corrélation assez 
 forte pour l'autre ont souvent des corrélations plus faibles pour le facteur 
 avec lequel on les associe;
*/

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=3 maxiter=500 flag=.4  hey;
var Q8-Q17;
run; 
*Le facteur 3 serait défini par Q9 et Q14 et concerne la confiance qu'on les
 gens dans cette entreprise;

proc factor data=multi.sondage_entreprise  method=ml rotate=varimax nfact=4 maxiter=500 flag=.4  hey;
var Q8-Q17;
run;
*Ici le facteur 3 est défini par une seule variable, soit l'innovation;
*Le facteur 4 est défini par Q9 et Q14 mais la question Q9 reste aussi corrélé avec le
 facteur 1;

*Pour contruire les échelles commençons par évaluer la solution à 2 facteurs;

/* pour le facteur rôle social */
proc corr data=multi.sondage_entreprise alpha;
var Q8 Q9 Q14-Q17;
run;
/* 
Le alpha de Cronbach est de 0.877: chaque variable a aussi une corrélation assez forte avec le total 
*/

/* pour le facteur positionnement de la compagnie dans l'industrie */
proc corr data=multi.sondage_entreprise alpha;
var Q10-Q12;
run;
*Le alpha est de 0.8;
*Chaque variable a aussi une corrélation assez forte avec le total;

/* La solution à deux facteurs semblent adéquate. 
 Avec la méthode de Kaiser, il s'agit de la solution choisie. 
En ajoutant des facteurs on ne semble pas avoir de gain au niveau de l'interprétation.
*/

data echelle;
set multi.sondage_entreprise;
role_social=mean(Q8,Q9,Q14,Q15,Q16,Q17);
positionnement=mean(Q10,Q11,Q12,Q13);
run;

proc means data=echelle mean;
 var Q8 Q9 Q14-Q17 role_social Q10-Q13 positionnement;
run;





