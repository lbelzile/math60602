
 /* Commandes pour conserver seulement les clients, parmi les 101 000,
 qui ont acheté quelque chose. Ces observations serviront à évaluer 
 la performance réelle des modèles retenus par les différentes 
 méthodes de sélection de modèle. */

proc contents data=multi.dbm;
run;

data ymontant;
set multi.dbm;
drop test; *la colonne "train" dans la base de données contient déjà l'information sur les regroupements entraînement/validation;
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
////////////////////////////////////////////////////////
// EXPLICATIONS DES OPTIONS de la procédure GLMSELECT //
////////////////////////////////////////////////////////

***************************
***** ligne PARTITION *****
***************************

Deux options:
1) "partition" pour séparer en entraînement/validation/test. Dans le tableau final, on aura ASE - Validation (average squared error, ASE=EMQ)
Par exemple, avec la ligne " partition role=train(train="1" validate="0");" on sélection la variable "train" de la base de données pour définir "train"/"validate" et "test"
2) Si on n'avait pas de base de données entraînement/validation, on pourrait en créer une aléatoirement avec "partition fraction(validation=0.5);". penser à mettre un germe aléatoire seed=1234 sur la ligne d'appel de la procédure, par ex. "proc glmselect data=ymontant seed=1234;" si on veut avoir le même échantillon de validation pour tous les modèles qu'on essaie

***************************
***** ligne CLASSE ********
***************************

Sert à la déclaration des variables catégorielles, une liste avec toutes les variables.
- "ref" donne la catégorie de référence (par défaut la plus grande valeur)
- "split" permet de n'inclure qu'une poignée des indicateurs de groupes (les catégories omises sont donc fusionnées avec la référence)

***************************
****** ligne MODEL ********
***************************

c) model y=x.... / selection ...
On choisit la méthode de sélection, par exemple "forward", "backward", "stepwise", "lasso"
Les options sont incluses entre parenthèses
SELECT: critère qui permet de déterminer quelle variable rajouter à une étape donnée (par défaut, SBC). Un critère parmi (ADJRSQ, AIC, AICC, BIC, CP, CV, PRESS, RSQUARE, SBC, SL) 
STOP/STEP: critère d'arrêt. Pour STEP, nombre d'étapes. Pour STOP, soit le nombre de termes du modèle final, soit un critère comme CV/AIC/SBC/SL - si on ne peut améliorer le critère donnée à une étape, la procédure de sélection se termine.
CHOOSE: si absent, le modèle final est retourné. Un critère, par exemple CV/PRESS/SBC/AIC permet de choisir le modèle final à prendre parmi le catalogue de propositions avec la "meilleure" valeur du critère

Exemple model y=x .../ selection=stepwise(select=AIC, stop = AIC, choose=SBC);

La syntaxe suivante comprend toutes les interactions/produit de variables entre elles, tandis que @2 restreint aux produits/interactions d'ordre 2
"model ymontant = x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 *toutes les interactions d'ordre 2 et les produits de variable continue;"


Si on choisit CV pour une ou l'autre des options, alors on spécifie le type de validation croisée
Les trois options principales (hors procédures classiques via tests d'hypothèse) sont les suivantes:
- Pour la validation croisée, l'option par défaut est PRESS (validation à n groupes, donc on ajuste le modèle avec n-1 observations et on prédit l'observation restante (LOOCV). Pas recommandé parce qu'on risque le surajustement; 
- RECOMMANDÉ: normalement, on privilégiera les options "cvmethod=random(5)" ou "cvmethod=random(10)" pour créer aléatoirement 5 ou 10 groupes 
-pour des observations consécutives, utilisez plutôt block(10). 
- L'option cvmethod=split(10) crée des groupes d'observations consécutives en gardant par exemple 5 observations en retrait. (DÉCONSEILLÉ pour les même raisons que PRESS)

Le tableau résumé inclura la statistique PRESS, soit n*EMQ. Utilisez ce critère pour calculer l'EMQ.

ATTENTION: si vous utilisez CV comme critère de sélection, vous ne pouvez pas calculer manuellement l'erreur moyenne quadratique! Vos prédictions utiliseraient alors toutes les données et vous risquez le surajustement. C'est aussi un problème quand vous calculez les erreurs de sortie ou les prédictions.

hier=none (défaut) / hier=single - ordinairement, soit si hier=single, les interactions ne sont ajoutées que si les effets principaux sont déjà présent (par exemple, on inclut x2*x3 seulement si x2 et x3 sont déjà dans le modèle). Pour les étapes descendantes, on n'enlève x2 ou x3 uniquement si tous les termes d'ordre supérieur (polynômes ou interactions) sont déjà éliminés. 
"hier=none" permet de contourner cette restriction, mais le modèle final est une boîte noire


***************************
***** ligne EFFECT ********
***************************

Cette ligne permet de créer des polynômes ou des regroupements.
C'est utile si on veut conserver un bloc de variables explicatives telles quelles (c'est tout ou rien pour la sélection)

Pour inclure des polynômes avec tous les produits entre deux variables et les polynômes, on spécifie "polynomial" avec la liste de variables et le degré du polynôme, par exemple 

effect xlist = polynomial(x1-x10 / degree=2);
 model ymontant= xlist ...
 
Cette option ("effect") ne fonctionne pas avec le LASSO
*/



/* 
Commandes pour effectuer une recherche exhaustive avec le critère du R
 carré et extraire le meilleur modèle avec une variable, 
 le meilleur avec 2 variables etc. avec proc reg
*/

 proc glmselect data=ymontant outdesign=donneessimples;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split); *'split' permet de fusionner des groupes à la catégorie de référence;
 model ymontant=x1-x10 / selection=none;
 run;
 /* Recherche des meilleurs sous-ensembles 
 &_GLSind contient les variables choisies 
 dans le modèle précédent par glmselect */
 proc reg data=donneessimples(where=(_ROLE_="TRAIN"))  plots=none;
 model ymontant= &_GLSmod / selection=rsquare best=1 aic sbc;
 run;

 proc glmselect data=ymontant plots(StartStep=1)=(ASEPlot);
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split); *'split' permet de fusionner des groupes à la catégorie de référence;
 model ymontant=x1-x10 / 
 selection=forward(step=15 choose=AIC) stat=(AIC SBC);
 *score data=testymontant out=predaic p=predymontant;
 run;
 
 /*Note: En sélectionnant "split" ou en créant des indicateurs binaires, 
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
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2
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
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
 selection=stepwise(slentry=0.15 slstay=0.15 select=SL) hier=none;
 run;
 
 proc glmselect data=ymontant outdesign=glmselectoutput;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 /  
 selection=stepwise(slentry=0.6 slstay=0.6 select=SL stop=40) hier=none;
 ods output GLMSelect.Summary.SelectionSummary=historiqueSelection;
 run;

 proc sgplot data=historiqueSelection;
 series x=nParmsIn y=AIC / markers markerattrs=(symbol=CircleFilled color="CXFDE725") lineattrs=(color="CXFDE725");
 series x=nParmsIn y=SBC /  markers markerattrs=(symbol=CircleFilled color="CX21918C") lineattrs=(color="CX21918C");
 series x=nParmsIn y=ValidationASE / y2axis  markers markerattrs=(symbol=CircleFilled color="CX440154") lineattrs=(color="CX440154");
 yaxis label="Critère d'information";
 y2axis label="EMQ (validation)";
 xaxis label="Nombre de termes";
 run;
 
 /* Recherche exhaustive */
 proc reg data=glmselectoutput(where=(_ROLE_="TRAIN")) plots=none;
 model ymontant= &_GLSmod / selection=rsquare best=1 aic sbc;
 run;
 
 /* Recherche séquentielle avec critères d'information */
 proc glmselect data=ymontant outdesign=glmselectoutput;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / 
 selection=stepwise(select=aic choose=sbc) hier=none;
 run;
 
 
 
/* LASSO avec validation croisée à 10 groupes 
 effect ne fonctionne pas avec cette procédure...*/
 proc glmselect data=ymontant plots=coefficient seed=60602;
 partition role=train(train="1" validate="0");
 class x3(param=ref split) x4(param=ref split);
 model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10 @2
 x2*x2 x6*x6 x7*x7 x8*x8 x9*x9 x10*x10 / 
 selection=lasso(steps=120 choose=cv) 
 cvmethod=random(10) hier=none;
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
 dans le fichier "predaverage". La variable "predymontant" contiendra les prévisions. 
 */
 
 data predaverage;
 set predaverage;
 erreur=(ymontant-predymontant)**2;
 run;
 
 proc means data=predaverage n mean;
 var erreur;
 run; 
 

 /* Note: en général, on n'aura pas une base de donnée de validation.
 On choisira le modèle optimal en 
(a) en sélection l'option "partition" pour faire de la validation externe et en 
 sélectionnant le modèle avec le plus petite EMQ de validation 
 (ASE - Validation dans le tableau de la sortie, sauf pour la moyenne de modèles où il faut faire le calcul à la main
(b) en choisissant comme critère de sélection pour notre modèle la validation croisée (choose=CV) et en prenant
le modèle avec la plus petite valeur de CV PRESS (c'est n*EMQ, donc la somme plutôt que la moyenne)
 */

/* 
Exemple de procédure avec scission aléatoire en échantillons apprentissage/validation; 
*/
proc glmselect data=ymontant seed=12345;
 partition fraction(validate=0.2);
 class x3(param=ref split) x4(param=ref split); 
 model ymontant=x1-x10 / selection=forward(stop=15 choose=VALIDATE);
 output out=outpred resid=erreur pred=predmoy;
run;
/* Sauvegarder les données avec colonne _ROLE_, les résidus resid=... et les prédictions pred = ...
C'est utile pour "modelaverage" qui ne retourne pas l'EMQ (mais ça marche plus généralement avec toutes les méthodes de sélection, sauf que ces information est déjà disponible dans le tableau 
*/

 /* Calculer l'EMQ de validation à la mitaine en faisant le carré des erreurs */
 data outpred2;
 set outpred(where=(_role_ EQ "validate"));
 erreurquad = erreur**2;
 run;
 /* Calculer la moyenne du carré des erreurs */
 proc means data=outpred2 mean n;
 var erreurquad;
 run;

