/*
Estimation de la fonction de survie et de risque.
La variable dépendante est spécifiée avec "t*censure(1)",
ce qui veut dire que "t" est la variable qui donne le temps
de survie et "censure" est celle qui indique si le temps est
censuré ou non. La valeur entre parenthèses ("1" ici)
spécifie que, lorsque censure=1, le temps est censuré.

Description des options:
  method = méthode d'estimation utilisée. Ici "km" demande
la méthode de Kaplan-Meier.
  plots = demande des graphiques. Ici, on demande le graphe
de la fonction de survie ("survival) avec intervalles de confiances ponctuels ("cl") et
simultanés ("cb=ep"). L'option "nocensor" permet d'éviter l'ajout de signes
+ à chaque observation censuré, ce qui améliore règle générale la lisibilité du graphique.
Pour exclure le tableau de n lignes, décommenter la ligne "ods exclude"
*/

proc lifetest data=multi.survival1 method=km 
 plots=survival(cl cb=ep nocensor);
time t*censure(1);
*ods exclude ProductLimitEstimates;
run;

*INCORRECT - pour illustrer que les estimations 
utilisées ordinairement sont biaisées;
proc means data=multi.survival1 
q1 median q3 mean maxdec=2;
var t;
run;

/* 
Tests d'égalité de deux fonctions de survie.
La commande "strata" spécifie la variable binaire qui distingue 
les deux groupes que l'on veut comparer.

Note: Si la variable dans "strata" possède plus de deux valeurs (K disons),
alors des tests d'égalités des K fonctions de survie seront produits.
*/
proc lifetest data=multi.survival1 method=km plots=survival(cl nocensor);
time t*censure(1);
strata sexe;
run;

proc lifetest data=multi.survival1 method=km plots=survival(cl nocensor);
time t*censure(1);
strata region;
run;