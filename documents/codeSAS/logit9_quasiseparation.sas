data t;
input Y X1 X2;
cards;
0 1  3
0 2  2
0 3 -1
0 3 -1
1 5  2
1 6  4
1 10 1
1 11 0 
;
run;

proc logistic data = t;
  model y = x1 x2;
  score out=pred;
run;

proc print data=pred;
run;

/* Correction de Firth, qui ajoute une correction de biais
et qui rétablit l'identifiabilité des paramètres
(interprétation comme apriori) */
proc logistic data = t;
  model y = x1 x2 / firth;
  score out=pred;
run;

proc print data=pred;
run;
/* Tiré de 
https://stats.idre.ucla.edu/other/mult-pkg/faq/general/faqwhat-is-complete-or-quasi-complete-separation-in-logistic-regression-and-what-are-some-strategies-to-deal-with-the-issue/
Introduction to SAS. UCLA: Statistical Consulting Group. 
from https://stats.idre.ucla.edu/sas/modules/sas-learning-moduleintroduction-to-the-features-of-sas/ (accessed August 22, 2016).
*/


