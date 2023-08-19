** Exemple de statistiques descriptives et tests bivariées;
** Julie Meloche;
**=================================================================;

proc freq data=multi.ventes;
  tables hours;
run;

**Créer une variable ordinale;

data ventes;
  set multi.ventes;
  heures=0;
  if hours<50 then heures=1;
  else if hours<60 then heures=2;
  else heures=3;
run;

proc freq data=ventes;
  tables heures;
run;


proc format;
  value prom 0 = "Non" 1= "Oui";
  value hrs 1 = "40 à 49 heures" 2 = "50 à 59 heures" 3 = "60 heures et plus";
  value loc 1 = "A" 2 = "B" 3 = "C";
run;

**Exemples de fréquences;

proc freq data=ventes;
  label promo = "Promotion"
   heures = "Nombre d'heures d'ouverture par semaine";
   format promo prom. heures hrs. location loc.;
  tables promo heures location;
run;

**Exemples de statistiques descriptives;

proc means data=ventes maxdec=2;
  label sales = "Ventes hebdomadaires de céréales" display = "Superficie en pied carré";
  var sales display;
run;

*Relation entre les ventes et les variables qualitatives;

proc means data=ventes maxdec=2;
  label promo = "Promotion"
   heures = "Nombre d'heures d'ouverture par semaine"
   sales = "Ventes hebdomadaires de céréales" ;
   format promo prom. heures hrs. location loc.;
   class promo;
  var sales ;
run;

proc ttest data=ventes;
  label promo = "Promotion"
   heures = "Nombre d'heures d'ouverture par semaine"
   sales = "Ventes hebdomadaires de céréales" ;
   format promo prom. heures hrs. location loc.;
  class promo;
  var sales;
run;

proc means data=ventes maxdec=2;
  label promo = "Promotion"
   heures = "Nombre d'heures d'ouverture par semaine"
   sales = "Ventes hebdomadaires de céréales" ;
   format promo prom. heures hrs. location loc.;
   class heures;
  var sales ;
run;

proc means data=ventes maxdec=2;
  label promo = "Promotion"
   heures = "Nombre d'heures d'ouverture par semaine"
   sales = "Ventes hebdomadaires de céréales" ;
   format promo prom. heures hrs. location loc.;
   class location;
  var sales ;
run;



** Matrice de corrélation;

proc corr data=ventes;
  label sales = "Ventes hebdomadaires de céréales" 
  display = "Superficie en pied carré";
  var sales display;
run;

**Tableau croisé et test du khi-deux;

proc freq data=ventes;
   format heures hrs. location loc.;
  tables  heures * location / chisq;
run;


proc glm data=ventes;
  class heures location;
  model sales = display promo heures location / solution clparm;
run;
