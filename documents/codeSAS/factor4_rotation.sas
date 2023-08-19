
/* 
Analyse factorielle avec la rotation varimax oblique ("obvarimax").
*/

proc factor data=multi.factor method=ml rotate=obvarimax nfact=4 maxiter=500 flag=.3 hey;
var x1-x12;
run; 
