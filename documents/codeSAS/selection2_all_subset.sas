   
   /* NOTE IMPORTANTE: il faut d'abord préparer les données en exécutant la 1e partie
   du programme "prepare_DBM.sas", afin d'avoir un fichier nommé "train" qui contient
   l'échantillon d'apprentissage et un fichier nommé "test" qui contient les clients
   à cibler (ou a scorer"). */
   
   /* Commandes pour conserver seulement les 210 clients, parmi les 1000,
   qui ont acheté quelque chose */
   
   data trainymontant;
   set train;
   if ymontant=. then delete;
   run;
   
   /* Commandes pour conserver seulement les  clients, parmi les 100 000,
   qui ont acheté quelque chose. Ces observations serviront à évaluer 
   la performance réelle des modèles retenus par les différentes 
   méthodes de sélection de modèle. */
   
   data testymontant;
   set test;
   if ymontant=. then delete;
   run;
   
   /* 
   Commandes pour effectuer une recherche "all-subset" avec le critère du R carré
   et extraire le meilleur modèle avec une variable, le meilleur avec 2 variables etc. 
   */
   

   proc reg data=trainymontant;
   model ymontant= x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10 / selection=rsquare best=1 aic sbc;
   run;

   
   /* 
   Commandes pour évaluer la performance du modèle retenu par lecritère AIC,
   avec l'échantillon test 
   */
   
   /* La commande "score" demande à SAS de calculer les prévisions de ymontant
   pour les observations du fichier "testymontant". Elle seront sauvegardées
   dans le fichier "predaic". La variable "predymontant" contiendra les prévisions. */
   
   /* Ensuite, on calcule l'erreur au carré des prévisions et on en fait
   la moyenne */
   
   proc glmselect data=trainymontant;
   model ymontant= x1 x2 x31 x44 x5 x6 x7 x8 x9 x10 / selection=none;
   score data=testymontant out=predaic p=predymontant;
   run;
   
   data predaic;set predaic;
   erreur=(ymontant-predymontant)**2;
   run;
   
   proc means data=predaic n mean ;
   var erreur;
   run;
   
   
   /* 
   Commandes pour évaluer la performance du modèle retenu par le critére SBC,
   avec l'échantillon test 
   */
   
   proc glmselect data=trainymontant;
   model ymontant= x1 x31 x5 x6 x7 x8 x10 / selection=none;
   score data=testymontant out=predsbc p=predymontant;
   run;
   
   data predsbc;set predsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   
   proc means data=predsbc n mean ;
   var erreur;
   run;
   
   /* 
   Commandes pour ajuster le modèle avec les 104 variables sans faire de sélection
   et pour évaluer sa performance sur l'échantillon test 
   */
   
   proc glmselect data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
    cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10  /   selection=none ;
   score data=testymontant out=predall p=predymontant;
   run;
   
   data predall;set predall;
   erreur=(ymontant-predymontant)**2;
   run;
   
   proc means data=predall n mean ;
   var erreur;
   run; 
   
   
   /* 
   Commandes pour effectuer une sélection de variables avec la méthode séquentielle classique
   avec un critère d'entrée (SLE) de 0,15 et un critère de sortie (SLS) de 0,15 
   */

   proc reg data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   selection=stepwise sle=.15 sls=.15 ;
   run;

   
   /* Commandes pour évaluer la performance du modèle retenu par la méthode séquentielle classique,
   avec l'échantillon test */
   
   proc glmselect data=trainymontant;
   model ymontant= x32 x44 x5 x7 x10 cx6 cx10 
   i_x2_x31 i_x2_x43 i_x1_x43 i_x1_x6 i_x1_x10 i_x5_x8       
   i_x5_x10 i_x31_x41 i_x31_x8 i_x32_x8 i_x41_x8 i_x42_x8     
   i_x44_x6 i_x44_x9 i_x8_x10
   / selection=none;
   score data=testymontant out=predstep p=predymontant;
   run;
   data predstep;set predstep;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predstep n mean ;
   var erreur;
   run; 
   
   
   /* 
   Commandes pour faire un séquentielle avec des critères plus généreux (entrée=sortie=0,6).
   à la fin, il y aura plus de variables, 56 ici.
   Ces 56 variables seront ensuite envoyés dans une recherche all-subset. 
   */
   

   proc reg data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   selection=stepwise sle=.6 sls=.6 ;
   run;

   
   /* Recherche all-subset avec les 56 variables trouvées à l'étape précédente avec la procédure séquentielle (stepwise) */
   
   proc reg data=trainymontant;
   model ymontant=
   x2 x44 x5 x7 x8 x9 cx2 cx6 cx9 cx10
   i_x2_x1 i_x2_x31 i_x2_x41 i_x2_x42 i_x2_x43
   i_x2_x8 i_x2_x10 i_x1_x5 i_x1_x31 i_x1_x42
   i_x1_x43 i_x1_x6 i_x1_x8 i_x1_x10 i_x5_x44
   i_x5_x10 i_x31_x42 i_x31_x43 i_x31_x8
   i_x31_x9 i_x31_x10 i_x32_x41 i_x32_x42
   i_x32_x43 i_x32_x44 i_x32_x6 i_x32_x9
   i_x41_x7 i_x41_x9 i_x41_x10 i_x42_x6
   i_x42_x9 i_x42_x10 i_x43_x6 i_x43_x8
   i_x43_x9 i_x43_x10 i_x44_x7 i_x44_x6
   i_x44_x8 i_x44_x10 i_x7_x8 i_x6_x8
   i_x6_x9 i_x8_x9 i_x8_x10
   / selection=rsquare best=1 aic sbc;
   run;
   
   /* Commandes pour évaluer la performance du modèle retenu par le critère AIC, à partir des 56 variables,
   avec l'échantillon test */
   
   proc glmselect data=trainymontant;
   model ymontant=
   x2 x44 x5 x7 x8 x9
   cx2 cx6 cx9 cx10
   i_x2_x1 i_x2_x31
   i_x2_x41 i_x2_x43
   i_x2_x10 i_x1_x5
   i_x1_x31 i_x1_x42
   i_x1_x43 i_x1_x6
    i_x1_x10 i_x5_x10
   i_x31_x8 i_x31_x9
   i_x32_x41 i_x32_x44
   i_x32_x6 i_x42_x6
   i_x42_x9 i_x42_x10
   i_x43_x8 i_x43_x9
   i_x43_x10 i_x44_x10
   i_x6_x8 i_x6_x9
   i_x8_x9 i_x8_x10
   / selection=none;
   score data=testymontant out=predstepaic p=predymontant;
   run;
   data predstepaic;set predstepaic;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predstepaic n mean ;
   var erreur;
   run; 
   
   
   /* Commandes pour évaluer la performance du modèle retenu par le critère BIC/SBC, à partir des 56 variables,
   sur l'échantillon test */
   
   proc glmselect data=trainymontant;
   model ymontant=
   x2 x44 x5 x7 cx6
   cx10 i_x2_x31
   i_x2_x41 i_x2_x43
   i_x2_x8 i_x1_x43
   i_x1_x6 i_x5_x10
   i_x31_x8 i_x42_x6
   / selection=none;
   score data=testymontant out=predstepsbc p=predymontant;
   run;
   data predstepsbc;set predstepsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predstepsbc n mean ;
   var erreur;
   run; 
   
   /* 
   Commandes pour faire une recherche de type séquentielle en utilisant le AIC ("select=aic"), 
   au lieu des p-values, pour entrer ou retirer des variables et le BIC/SBC ("choose=sbc")
   pour sélectionner le meilleur modèle à la toute fin. 
   */
   

   proc glmselect data=trainymontant;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   
   selection=stepwise(select=aic choose=sbc)  ; 
   score data=testymontant out=predglmselectaicsbc p=predymontant;
   run;

   data predglmselectaicsbc;
   set predglmselectaicsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predglmselectaicsbc n mean ;
   var erreur;
   run; 
   
   /* Sélection de modèles avec régularisation
   La pénalité L1 (LASSO) force certains paramètres à zéro 
   Standardiser les variables préalablement */
   proc glmselect data=trainymontant plots=coefficients;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   
   selection=lasso(choose=sbc steps=50); 
   score data=testymontant out=predglmselectlasso p=predymontant;
   run;

   data predglmselectlasso;
   set predglmselectlasso;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predglmselectlasso n mean ;
   var erreur;
   run; 
   
   /* 
   Commandes pour faire une moyenne de modèles. Chaque modèle est construit avec
   un échantillon d'autoamorçage ("sampling=urs"). 500 échantillons sont utilisés ("nsamples=500").
   Les meilleurs 500 modèles sont conservés pour en faire la moyenne ("subset(best=500)").
   Chaque modèle est obtenu en faisant une recherche de type séquentielle en utilisant le BIC/SBC
   pour entrer ou retirer des variables et encore le SBC pour sélectionner le meilleur modèle
   à la toute fin. 
   */
   

   proc glmselect data=trainymontant seed=57484765;
   model ymontant=
   x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10
   cx2 cx6 cx7 cx8 cx9 cx10
   i_x2_x1 i_x2_x5 i_x2_x31 i_x2_x32 i_x2_x41 i_x2_x42 i_x2_x43 i_x2_x44
   i_x2_x7 i_x2_x6 i_x2_x8 i_x2_x9 i_x2_x10
   i_x1_x5 i_x1_x31 i_x1_x32 i_x1_x41 i_x1_x42 i_x1_x43 i_x1_x44
   i_x1_x7 i_x1_x6 i_x1_x8 i_x1_x9 i_x1_x10
   i_x5_x31 i_x5_x32 i_x5_x41 i_x5_x42 i_x5_x43 i_x5_x44
   i_x5_x7 i_x5_x6 i_x5_x8 i_x5_x9 i_x5_x10
   i_x31_x41 i_x31_x42 i_x31_x43 i_x31_x44
   i_x31_x7 i_x31_x6 i_x31_x8 i_x31_x9 i_x31_x10
   i_x32_x41 i_x32_x42 i_x32_x43 i_x32_x44
   i_x32_x7 i_x32_x6 i_x32_x8 i_x32_x9 i_x32_x10
   i_x41_x7 i_x41_x6 i_x41_x8 i_x41_x9 i_x41_x10
   i_x42_x7 i_x42_x6 i_x42_x8 i_x42_x9 i_x42_x10
   i_x43_x7 i_x43_x6 i_x43_x8 i_x43_x9 i_x43_x10
   i_x44_x7 i_x44_x6 i_x44_x8 i_x44_x9 i_x44_x10
   i_x7_x6 i_x7_x8 i_x7_x9 i_x7_x10
   i_x6_x8 i_x6_x9 i_x6_x10
   i_x8_x9 i_x8_x10
   i_x9_x10 /   
   selection=stepwise(select=sbc choose=sbc)  ; 
   score data=testymontant out=predaverage p=predymontant;
   modelaverage nsamples=500 sampling=urs subset(best=500)  ;
   run;

   
   data predaverage;set predaverage;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predaverage n mean ;
   var erreur;
   run; 
   
   
   
   /* Utilisation de CLASS et de la syntaxe avec | et @ */
   
   
   proc glmselect data=trainymontant;
   class x3 x4;
   model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10
    /   selection=stepwise(select=aic choose=sbc)  ; 
   score data=testymontant out=predglmselectaicsbc p=predymontant;
   run;
   
   data predglmselectaicsbc;set predglmselectaicsbc;
   erreur=(ymontant-predymontant)**2;
   run;
   proc means data=predglmselectaicsbc n mean ;
   var erreur;
   run; 
