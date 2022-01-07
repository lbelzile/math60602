/* Analyse exploratoire des données 'aerien' */
/* Question 1.1 
- y a-t-il des valeurs manquantes? si oui, peut-on les remplacer?
- quelle est la répartition en classe économique versus affaires?
- quel est le lien entre l'âge et la classe du billet 
- à quoi ressemble la distribution de l'âge?
- que faire avec les valeurs de service internet en vol = 0?
- quelles sont les caractéristiques les plus importantes pour le service?
- est-ce que la satisfaction globale diffère selon le sexe?
*/
* Créer une copie locale de la base de données;
data aerien;
set multi.aerien;
drop id;
run;

/* Q1.2
Variables quantitatives continues: 
- âge (en années), delai_depart_min (en minutes), delai_arrivee_min (en minutes), distance_vol (km)
Variables catégorielles ordinales (zéro indique NA):
- revenu, service_internet_en_vol -- proprete 
Variables catégorielles nominales:
- classe
Variables catégorielles binaires:
- sexe, loyaute_consommateur, satisfaction, test
*/


/* Q1.3 Valeurs manquantes
/* Statistiques descriptives
nmiss: nombre de valeurs manquantes */
proc means data=aerien nmiss;
run;
/* Il y a des valeurs manquantes uniquement pour delai_arrivee_min. */

/* Quelle est la corrélation linéaire entre retard au départ et les autres variables? */
proc corr data=aerien;
var delai_depart_min delai_arrivee_min;
run;
/* Imputer par la moyenne serait illogique parce que la corrélation avec delai_depart_min est ~0.97: 
on peut plutôt construire un modèle linéaire simple et utiliser la prédiction
*/
/* Nuage de point avec droite de régression */
proc sgplot data=aerien;
scatter y=delai_arrivee_min x=delai_depart_min; 
reg y=delai_arrivee_min x=delai_depart_min; 
xaxis label="délai au départ (en minutes)";
yaxis label="délai à l'arrivée (en minutes)";
run; 

/* Modèle linéaire simple */
proc glm data=aerien noprint; /* Ne pas imprimer la sortie */
model delai_arrivee_min = delai_depart_min;  
/* Variable réponse = variables explicatives */
/* Avec "y = " (soit rien à droite de l'égalité), on obtient la moyenne */
store modele_lin;    /* stocker la sortie modèle */
quit;
proc plm restore=modele_lin; /* Restorer le modèle (et les estimés) */
score data=aerien out=pred;  /* prédire sur les données */
run;

/* Transformer les données */
data aerien_nouv;
set pred(keep=predicted); /* Conserver uniquement la prédiction */
set aerien; /* Ajouter les colonnes pour aerien */
/* Créer une variable binaire pour les valeurs manquantes */
if(delai_arrivee_min = .) then delai_arrivee_manqu = 1; 
else delai_arrivee_manqu = 0; 
/* Remplacer les valeurs manquantes par la prédiction */
if(delai_arrivee_min = .) then delai_arrivee_min = predicted;
drop predicted;
run;

/* Vérifier que notre manipulation a fonctionné */
proc means data=aerien_nouv nmiss;
var delai_arrivee_min;
run;

/* Question 1.4 */
/* Statistiques descriptives: moyenne, écart-type, minimum et maximum 
Pour toutes les variables quantitatives */
proc means data=aerien mean stddev min max;
run;

/* Répartition selon les classes */
proc freq data=aerien;
tables classe;
run;


/* Question 1.5 */
/* Distribution de la variable continue âge: 
On peut utiliser une histogramme ou un diagramme à bande (parce que le nombre de personnes est important) */
proc sgplot data=aerien;
hbar age; *étiquettes lisibles seulement si rotation 90°;
yaxis label="âge (en années)";
run;

/* Répartition dans les classes selon l'âge: 
est-ce que les personnes plus âgées voyagent davantage en classe supérieure */
proc sgplot data=aerien;
vbox age / group=classe;
run;
/* Légèrement plus élevé pour Eco < Ecoplus < Affaires */
proc sgplot data=aerien;
vbox  / group=satisfaction;
run;

/* Tableau de l'âge moyen par classe et sexe */
proc tabulate data=aerien;
class classe sexe;
var age;
table (age)*(MEAN STD MIN MAX), classe*sexe;
run;
/* Pas de différence notable de moyenne selon le sexe (mais on pourrait faire un test-t) */

* On regarde plus en détail le nombre de zéros et la répartition pour les échelles de Likert;
proc freq data=aerien;
tables service_internet_en_vol--proprete;
run;

proc sgplot data=aerien;
histogram age / group=satisfaction transparency=0.5;
run;
/* Les gens d'âge moyen sont plus susceptibles d'être satisfaits */

/* Moyenne pour les échelles de Likert selon le degré de satisfaction
ATTENTION AU ZÉROS = NA*/
data aerien_manq;
set aerien;
if(service_internet_en_vol = 0) then service_internet_en_vol=.; 
if(temps_arrivee_depart_convenable = 0) then temps_arrivee_depart_convenable=.;
if(facilite_reservation_en_ligne = 0) then facilite_reservation_en_ligne=.;
if(localisation_porte = 0) then localisation_porte=.;
if(nourriture = 0) then nourriture=.;
if(preenregistrement_en_ligne = 0) then preenregistrement_en_ligne=.;
if(confort_siege = 0) then confort_siege=.;
if(divertissement_en_vol = 0) then divertissement_en_vol=.;
if(service_embarquement = 0) then service_embarquement=.;
if(service_espace_jambes = 0) then service_espace_jambes=.;
if(service_enregistrement = 0) then service_enregistrement=.;
if(service_vol = 0) then service_vol=.;
if(proprete = 0) then proprete=.;
run;

/* On calcule avec les valeurs manquantes en lieu et place des zéros*/
proc tabulate data=aerien_manq;
class satisfaction;
var service_internet_en_vol--proprete;
table (service_internet_en_vol--proprete)*(MEAN), satisfaction;
run;

/* Moyenne de satisfaction en fonction du sexe */
/* Créer une copie de la base de données avec seulement sexe et satisfaction */
data aerien_satisf;
set aerien;
keep sexe satisfaction;
run;
/* Trier par sexe pour les opérations subséquentes*/
proc sort data=aerien_satisf;
by sexe;
run;
/* Calculer la moyenne par sexe, puis sauvegarder dans aerien_satisf_moy */
proc means data=aerien_satisf mean;
by sexe;
*output out=aerien_satisf_moy mean=moyenne; 
* créer une copie de la base de données résultante;
run;


/* Q1.6 Fait saillants:
- 393 valeurs manquantes pour delai_arrivee_min 
- âge moyen ~ 39.4 ans
- hormis gestion_bagage, plusieurs valeurs 'non applicable' = 0 pour les échelles de Likert
- très forte corrélation linéaire entre delai arrivée et départ, quelques valeurs manquantes pour cette dernière

*/