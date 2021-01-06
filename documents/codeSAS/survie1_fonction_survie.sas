
/*
Estimation de la foncton de survie et de risque.
La variable dépendante est spécifiée avec "t*censure(1)",
ce qui veut dire que "t" est la variable qui donne le temps
de survie et "censure" est celle qui indique si le temps est
censuré ou non. La valeur entre parenthèses ("1" ici)
spécifie que, lorsque censure=1, le temps est censuré.

Description des options:
  method = méthode d'estimation utilisée. Ici "km" demande
la méthode de Kaplan-Meier.
  plots = demande des graphiques. Ici, on demande le graphe
de la fonction de survie ("s") et de risque ("h"). L'option
"cl" demande des intervalles de confiances pour les courbes.
  censoredsymbol = en spécifiant "none", cette option rend les graphiques 
beaucoup plus faciles à lire en ne rajoutant pas de symboles sur les 
courbes à chaque observation censurée.
(p. 280)
*/


ods graphics on;
proc lifetest data=multi.survival1 method=km plots=(s(cl), h(cl)) censoredsymbol=none ;
time t*censure(1);
run;
ods graphics off;



/* 
Tests d'égalité de deux fonctions de survie.
La commande "strata" spécifie la variable binaire qui distingue 
les deux groupes que l'on veut comparer.

Note: Si la variable dans "strata" possède plus de deux valeurs (K disons),
alors des tests d'égalités des K fonctions de survie seront produits.
(p. 288). 
*/


ods graphics on;
proc lifetest data=multi.survival1 method=km plots=(s(cl)) censoredsymbol=none;
time t*censure(1);
strata sexe;
run;
ods graphics off;


