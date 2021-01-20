**Révision de la régression linéaire multiple;
**===========================================;

data bdreg ;     
  input y x1 x2 x3 x4;
cards;  
45	2	0	3  4
55	9	1	2  20
123	11	0	3  20
169	7	0	2  15
201	17	0	3  32
274	21	1	2  42
298	15	0	3  30
299	11	1	2  24
303	14	0	3  25
307	18	0	3  36
330	16	0	3  33
333	11	0	2  23
373	22	1	2  44
373	20	1	2  40
383	22	1	2  43
406	23	1	1  47
409	17	1	2  35
412	19	1	2  40
424	24	1	1  50
433	10	0	1  20
435	14	0	1  25
435	14	1	3  28
439	17	1	3  34
449	18	0	2  35
458	20	1	1  40
469	21	0	2  45
475	26	1	2  50
478	22	1	1  45
490	20	1	3  40
491	19	1	1  17
494	25	1	3  50
529	21	0	2  40
590	21	1	1  44
593	23	1	1  44
599	11	0	2  23
601	15	0	2  30
612	19	1	3  26
614	24	1	1  48
627	17	1	3  34
629	20	1	3  40
633	28	0	2  60
640	20	0	3  40
660	15	0	1  30
666	16	0	1  30
744	27	1	1  60
823	29	1	1  60
891	27	1	2  55
935	33	1	1  65
946	22	1	3  45
947	19	1	1  40
;
run;

*Définition des variables :
y  : montant des ventes
x1 : nombre visites au magasin dans la dernière année
x2 : possède la carte fidélité (1) ou non (0)
x3 : région A, B ou C
x4 : nombre d'items achetés dans la dernière année;

*Régression linéaire simple;
*===========================;

*Variable quantitative (continue);

proc reg data=bdreg;
  model y = x1 / CLB ;
run;

*Variable binaire codée 0 et 1;

proc means data=bdreg;
  class x2;
  var y;
run;

proc reg data=bdreg;
  model y = x2 / CLB ;
run;

*Variable qualitative (nominale);

proc means data=bdreg;
  class x3;
  var y;
run;

data bdreg;
  set bdreg;
  if x3=1 then x3_1=1; else x3_1=0;
  if x3=2 then x3_2=1; else x3_2=0;
run;

proc reg data=bdreg;
  model y = x3_1 x3_2 / CLB ;
run;

*Proc GLM;

proc glm data=bdreg;
  class x3 (ref=last);
  model y = x3 / solution clparm ;
run;

proc glm data=bdreg;
  class x3 (ref=first);
  model y = x3 / solution clparm ;
run;

*Régression linéaire multiple;
*============================;

proc reg data=bdreg;
  model y = x1 x2 x3_1 x3_2 / CLB ;
run;

*Calcul des prévisions et des résidus;

proc reg data=bdreg;
  model y = x1 x2 x3_1 x3_2 / CLB p r ;
run;

ods trace on;

proc reg data=bdreg;
  model y = x1 x2 x3_1 x3_2 / CLB p r ;
run;

ods trace off;

proc reg data=bdreg;
  model y = x1 x2 x3_1 x3_2 / CLB p r ;
  ods output Reg.MODEL1.ObswiseStats.y.OutputStatistics=previsions;
run;

*Multicollinéarité;
*=================;

proc reg data=bdreg;
  model y = x1 x4 / VIF ;
run;

proc corr data=bdreg;
  var y x1 x4;
run;
