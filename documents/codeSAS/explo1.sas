/* Analyse exploratoire des données 'renfe'  */

/* Statistiques descriptives pour variables continues */
proc means data=multi.renfe;
run;
* Notez que jour est catégorielle, mais numérique;

/* Tableau de fréquence: combien de modalité pour les différences variables catégorielles */
proc freq data=multi.renfe;
tables classe*type / nopercent;
run;

/* Tableau des prix moyens par classe et type de billets */
proc tabulate data=multi.renfe;
class classe type;
var prix;
table (prix)*(MEAN STD), classe*type;
run;

proc tabulate data=multi.renfe;
class type;
var duree;
table (duree)*(MEAN STD), type;
run;

/* Graphiques pour visualiser la distribution des différentes variables */
proc sgplot data=multi.renfe;
vbar classe;
yaxis label="dénombrement";
run;
proc sgplot data=multi.renfe;
vbar type;
yaxis label="dénombrement";
run;
proc sgplot data=multi.renfe(where=(tarif="Promo"));
histogram prix;
xaxis label="Prix de billets au tarif Promo (en euros)";
run;
proc sgplot data=multi.renfe(where=(type NE "REXPRESS"));
vbox prix / category=classe group=type;
run;
