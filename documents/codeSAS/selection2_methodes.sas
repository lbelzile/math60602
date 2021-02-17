 /* Commandes pour conserver seulement les clients, parmi les 101 000,
 qui ont acheté quelque chose. Ces observations serviront à évaluer 
 la performance réelle des modèles retenus par les différentes 
 méthodes de sélection de modèle. */

 data ymontant;
 set multi.dbm;
 drop test; *déjà train dans la base de données;
 if ymontant=. then delete;
 run;
 /* Commandes pour conserver seulement les  clients, parmi les 100 000,
 qui ont acheté quelque chose. Ces observations serviront à évaluer 
 la performance réelle des modèles retenus par les différentes 
 méthodes de sélection de modèle. */

 data testymontant;
 set ymontant(where=(train=0));
 run;

 /* 
 Commandes pour effectuer une recherche exhaustive avec le critère du R carré
 et extraire le meilleur modèle avec une variable, le meilleur avec 2 variables etc. 
 */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split); *permettre de fusionner des groupes;
 model ymontant=x1-x10 / selection=forward(stop=15 choose=AIC);
 *score data=testymontant out=predaic p=predymontant;
 run;
 /*En sélectionnant "split" ou en créant des indicateurs binaires, 
 le modèle final dépend de la catégorie de référence; */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split); 
 model ymontant=x1-x10 / selection=forward(stop=15 choose=SBC);
 score data=testymontant out=predsbc p=predymontant;
 run;

 /* 
 Commandes pour ajuster le modèle avec les 104 variables sans faire de sélection
 et pour évaluer sa performance sur l'échantillon test 
 */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3 x4;
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / selection=none;
 run;

 
 /* 
 Commandes pour effectuer une sélection de variables avec la méthode séquentielle "stepwise" classique
 avec un critère d'entrée (slentry) de 0,15 et un critère de sortie (slstay) de 0,15 
 L'option "hier=none" indique qu'on peut enlever un effet principal en gardant l'interaction...
 */
 proc glmselect data=ymontant;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
 selection=stepwise(slentry=0.15 slstay=0.15 select=SL) hier=none;
 run;
 
 
 /* 
 Commandes pour faire un séquentielle avec des critères plus généreux (entrée=sortie=0,6).
 à la fin, il y aura plus de variables, 56 ici.
 Ces 56 variables seront ensuite utilisées avec une recherche exhaustive
 On enregistre les noms de variable dans glmselectOutput */
 proc glmselect data=ymontant outdesign=glmselectoutput;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
 selection=stepwise(slentry=0.6 slstay=0.6 select=SL) hier=none;
 run;
 /* On reprend la sortie, mais cette fois
 on fait une recherche exhaustive des modèles restants et on choisit
 le modèle par la suite qui a le plus petit SBC ou AIC */
 proc glmselect data=glmselectoutput;
 model ymontant= &_GLSMOD / selection=backward(stop=1 choose=sbc) hier=none;
 run;
  
 proc glmselect data=glmselectoutput;
 model ymontant= &_GLSIND / selection=backward(stop=1 choose=aic) hier=none;
 run;
 
 
 proc glmselect data=ymontant outdesign=glmselectoutput;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / 
 selection=stepwise(select=aic choose=sbc) hier=none; 
 run;
 
 
 /* 
 Commandes pour faire une moyenne de modèles. Chaque modèle est construit avec
 un échantillon d'autoamorçage ("sampling=urs"). 500 échantillons sont utilisés ("nsamples=500").
 Les meilleurs 500 modèles sont conservés pour en faire la moyenne ("subset(best=500)").
 Chaque modèle est obtenu en faisant une recherche de type séquentielle en utilisant le BIC/SBC
 pour entrer ou retirer des variables et encore le SBC pour sélectionner le meilleur modèle
 à la toute fin. 
 */
 

 proc glmselect data=ymontant seed=57484765;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / 
 selection=stepwise(select=sbc choose=sbc) hier=none; 
 score data=testymontant out=predaverage p=predymontant;
 modelaverage nsamples=500 sampling=urs subset(best=500);
 run;
 
 /* 
  La commande "score" demande à SAS de calculer les prévisions de ymontant
 pour les observations du fichier "testymontant". Elle seront sauvegardées
 dans le fichier "predaverage". La variable "predymontant" contiendra les prévisions. */
 */
 data predaverage;
 set predaverage;
 erreur=(ymontant-predymontant)**2;
 run;
 proc means data=predaverage n mean;
 var erreur;
 run; 
 
 
/* LASSO avec validation croisée à 10 groupes */
proc glmselect data=ymontant plots=coefficients;
partition role=train(train="1" validate="0");
class x3(param=ref split) x4(param=ref split);
model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2 
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /   
selection=lasso(steps=120 choose=cv) cvmethod=split(10) hier=none;
run;

