
/* Créer soit-même les variables indicatrices ou bien les déclarer
avec la commande CLASS revient au même comme dans l'exemple suivant */

proc glmselect data=trainymontant;
class x3 x4;
model ymontant=x1-x10  /   selection=none;
run;

proc glmselect data=trainymontant;
model ymontant= x1  x2 x31 x32 x41 x42 x43 x44  x5  x6 x7 x8 x9 x10 /   selection=none;
run;


/* Utilisation de la syntaxe spéciale pour spécifier les interactions d'ordre 2 */


proc glmselect data=trainymontant;
class x3 x4;
model ymontant=x1|x2|x3|x4|x5|x6|x7|x8|x9|x10@2 cx2 cx6 cx7 cx8 cx9 cx10  /   
selection=stepwise(select=aic choose=sbc)  ; 
score data=testymontant out=predglmselectaicsbc p=predymontant;
run;



