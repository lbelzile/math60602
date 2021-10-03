data aerien_facto;
set multi.aerien_facto;
run;

/* Méthode des composantes principales avec rotation varimax */
proc factor data=aerien_facto method=principal rotate=varimax plots=scree flag=.5;
var service_internet_en_vol--proprete;
run;

/* Le diagramme d'éboulis suggère clairement 4 composantes principales, 
de même que le critère de Kaiser (valeurs propres supérieures à 1) 
L'interprétation (grosso modo) va comme suit en retenant uniquement les chargements de plus de 0.5:
F1: expérience en vol (nourriture, confort_siege, divertissement_en_vol, proprete)
F2: facilité d'accès (service_internet_en_vol, temps_arrivee_depart_convenable, facilite_reservation_en_ligne, localisation_porte)
F3: service (service_embarquement, service_espace_jambes, service_vol)
F4: enregistrement (preenregistrement_en_ligne, enregistrement)
*/

/* Avec la méthode du maximum de vraisemblance, on ajuste le modèle 
en variant le nombre de facteurs et on choisit la méthode avec la plus
petite valeur du AIC ou nombre pour lequel la valeur-p est supérieure à 0.05. 

ATTENTION: si la taille de l'échantillon est grande, les modèles plus compliqués
sont toujours préférés et aucun modèle `simple à outrance` n'est adéquat.
Dans ce cas, les critères d'information sont rarement utiles parce que les solutions retournées auront (souvent) trop de facteurs.
*/

title "Critères d'information pour l'analyse factorielle avec 3 facteurs";
proc factor data=aerien_facto method=ml rotate=varimax heywood nfactors=3 flag=.4;
var service_internet_en_vol--proprete;
ods select Factor.InitialSolution.FitMeasures;
run;

title "Critères d'information pour l'analyse factorielle avec 4 facteurs";
proc factor data=aerien_facto method=ml rotate=varimax heywood nfactors=4 flag=.4;
var service_internet_en_vol--proprete;
ods select Factor.InitialSolution.FitMeasures;
run;

title "Critères d'information pour l'analyse factorielle avec 5 facteurs";
proc factor data=aerien_facto method=ml rotate=varimax heywood 
	nfactors=5 priors=one flag=.4;
var service_internet_en_vol--proprete;
ods select Factor.InitialSolution.FitMeasures;
run;

title "Critères d'information pour l'analyse factorielle avec 6 facteurs";
proc factor data=aerien_facto method=ml rotate=varimax heywood
	nfactors=6 priors=one flag=.4;
var service_internet_en_vol--proprete;
ods select Factor.InitialSolution.FitMeasures;
run;

title "Critères d'information pour l'analyse factorielle avec 7 facteurs";
proc factor data=aerien_facto method=ml rotate=varimax heywood
	nfactors=7 priors=one flag=.4;
var service_internet_en_vol--proprete;
ods select Factor.InitialSolution.FitMeasures;
run;

title "Critères d'information pour l'analyse factorielle avec 8 facteurs";
proc factor data=aerien_facto method=ml rotate=varimax heywood
	nfactors=8 priors=one flag=.4;
var service_internet_en_vol--proprete;
ods select Factor.InitialSolution.FitMeasures;
run;
title; * pour désactiver les titres précédents;

data echelles; /* on garde 0.5 comme seuil*/
set aerien_facto;
F1 = mean(nourriture, confort_siege, divertissement_en_vol, proprete);
F2 = mean(service_internet_en_vol, temps_arrivee_depart_convenable, facilite_reservation_en_ligne, localisation_porte);
F3 = mean(service_embarquement, service_espace_jambes, service_vol);
F4 = mean(preenregistrement_en_ligne, service_enregistrement);
run;

proc corr data=aerien_facto alpha;
var nourriture confort_siege divertissement_en_vol proprete;
ods select Corr.CronbachAlpha;
run;

proc corr data=aerien_facto alpha;
var service_internet_en_vol temps_arrivee_depart_convenable facilite_reservation_en_ligne localisation_porte;
ods select Corr.CronbachAlpha;
run;

proc corr data=aerien_facto alpha;
var service_embarquement service_espace_jambes service_vol;
ods select Corr.CronbachAlpha;
run;

/* L'échelle suivante n'est pas cohérente - pas surprenant au vu des chargements*/
proc corr data=aerien_facto alpha;
var preenregistrement_en_ligne service_enregistrement;
ods select Corr.CronbachAlpha;
run;
/* Si la cohérence interne n'est pas assez élevée, augmenter le seuil -> 
Moins de variables au sein de l'échelles, ces dernières sont plus corrélées. */


