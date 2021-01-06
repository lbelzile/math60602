  
  /* 
  Préparation des données et calculs de statistiques descriptives
  pour l'exemple: cibler les clients pour l'envoi d'un catalogue.
  (p. 96).
  */
  
  
  /* DÉBUT DE LA PRÉPARATION DES DONNÉES */
  
  /* Création de "labels" pour les variables. */
  /* Les noms des variables sont toujours X1 à X10. */
  /* Les labels permettent de lire plus facilement les sorties. */
  
  data all;
  set multi.dbm;
  label x1="sexe" x2="age" x3="revenu" x4="region" x5="conjoint"
  x6="anneeclient" x7="semainedernier" x8="montantdernier"
  x9="montantunan" x10="achatunan";
  run;
  
  /* Création de variables indicatrices pour les variables catégorielles. */
  /* Ces variables seront utilisées dans les modèles. */
  
  data all; set all;
  x31=0; x32=0; x41=0; x42=0; x43=0; x44=0;
  run;
  
  data all;set all;
  if x3=1 then x31=1;
  if x3=2 then x32=1;
  if x4=1 then x41=1;
  if x4=2 then x42=1;
  if x4=3 then x43=1;
  if x4=4 then x44=1;
  run;
  
  /* Création des variables explicatives au carré et de tous les termes d'interaction */
  
  data all;set all;
  cx2=x2**2;
  cx6=x6**2;
  cx7=x7**2;
  cx8=x8**2;
  cx9=x9**2;
  cx10=x10**2;
  
  i_x2_x1=x2*x1;
  i_x2_x31=x2*x31;
  i_x2_x32=x2*x32;
  i_x2_x41=x2*x41;
  i_x2_x42=x2*x42;
  i_x2_x43=x2*x43;
  i_x2_x44=x2*x44;
  i_x2_x5=x2*x5;
  i_x2_x6=x2*x6;
  i_x2_x7=x2*x7;
  i_x2_x8=x2*x8;
  i_x2_x9=x2*x9;
  i_x2_x10=x2*x10;
  
  i_x1_x31=x1*x31;
  i_x1_x32=x1*x32;
  i_x1_x41=x1*x41;
  i_x1_x42=x1*x42;
  i_x1_x43=x1*x43;
  i_x1_x44=x1*x44;
  i_x1_x5=x1*x5;
  i_x1_x6=x1*x6;
  i_x1_x7=x1*x7;
  i_x1_x8=x1*x8;
  i_x1_x9=x1*x9;
  i_x1_x10=x1*x10;
  
  i_x5_x31=x5*x31;
  i_x5_x32=x5*x32;
  i_x5_x41=x5*x41;
  i_x5_x42=x5*x42;
  i_x5_x43=x5*x43;
  i_x5_x44=x5*x44;
  i_x5_x6=x5*x6;
  i_x5_x7=x5*x7;
  i_x5_x8=x5*x8;
  i_x5_x9=x5*x9;
  i_x5_x10=x5*x10;
  
  i_x31_x41=x31*x41;
  i_x31_x42=x31*x42;
  i_x31_x43=x31*x43;
  i_x31_x44=x31*x44;
  i_x31_x6=x31*x6;
  i_x31_x7=x31*x7;
  i_x31_x8=x31*x8;
  i_x31_x9=x31*x9;
  i_x31_x10=x31*x10;
  
  i_x32_x41=x32*x41;
  i_x32_x42=x32*x42;
  i_x32_x43=x32*x43;
  i_x32_x44=x32*x44;
  i_x32_x6=x32*x6;
  i_x32_x7=x32*x7;
  i_x32_x8=x32*x8;
  i_x32_x9=x32*x9;
  i_x32_x10=x32*x10;
  
  i_x41_x6=x41*x6;
  i_x41_x7=x41*x7;
  i_x41_x8=x41*x8;
  i_x41_x9=x41*x9;
  i_x41_x10=x41*x10;
  
  i_x42_x6=x42*x6;
  i_x42_x7=x42*x7;
  i_x42_x8=x42*x8;
  i_x42_x9=x42*x9;
  i_x42_x10=x42*x10;
  
  i_x43_x6=x43*x6;
  i_x43_x7=x43*x7;
  i_x43_x8=x43*x8;
  i_x43_x9=x43*x9;
  i_x43_x10=x43*x10;
  
  i_x44_x6=x44*x6;
  i_x44_x7=x44*x7;
  i_x44_x8=x44*x8;
  i_x44_x9=x44*x9;
  i_x44_x10=x44*x10;
  
  i_x7_x6=x7*x6;
  i_x7_x8=x7*x8;
  i_x7_x9=x7*x9;
  i_x7_x10=x7*x10;
  
  i_x6_x8=x6*x8;
  i_x6_x9=x6*x9;
  i_x6_x10=x6*x10;
  
  i_x8_x9=x8*x9;
  i_x8_x10=x8*x10;
  
  i_x9_x10=x9*x10;
  
  run;
  
  /* Division de l'échantillon en deux parties: 
  
  1) Partie "training": 1000 clients qui ont reçu le catalogue et pour lesquels nous avons obtenus
  	les valeurs de yachat et ymontant
  2) Partie "test": 100 000 clients restant. En principe, nous n'aurions pas les valeurs de
  	yachat et ymontant pour ces clients. Mais pour les fins de l'exemple, elles sont
  	fournies afin de pouvoir évaluer la performance des modèles que nous allons développer */
  
  data train; set all;
  if train = 0 then delete;
  run;
  
  data test; set all;
  if test = 0 then delete;
  run;
  
  
  
  /* FIN DE LA PRÉPARATION DES DONNÉES */
  
  
  /* Quelques statistiques descriptives et graphiques pour l'échantillon "train" (N=1000) */
  
  proc freq data=train;
  tables x1 x3 x4 x5 x10 yachat;
  run;
  
  proc means data=train;
  var  x2 x6 x7 x8 x9 x10 ymontant;
  run;
  
  ods graphics on;
  proc sgplot data=train;
  histogram x2 ;
  run;
  proc sgplot data=train;
  histogram  x6;
  run;
  proc sgplot data=train;
  histogram  x7;
  run;
  proc sgplot data=train;
  histogram  x8;
  run;
  proc sgplot data=train;
  histogram  x9;
  run;
  proc sgplot data=train;
  histogram ymontant ;
  run;
  ods graphics off;
  
  
  
  
  
