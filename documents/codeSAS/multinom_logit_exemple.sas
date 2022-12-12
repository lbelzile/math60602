***Régression logistique multinomiale;
proc freq data=multi.wallet;
  tables wallet male business punish explain;
run;

proc freq data=multi.wallet;
  tables (male business punish explain)*wallet;
run;

**Régression logistique multinomiale;
**==================================;

proc logistic data=multi.wallet;
  model wallet (ref="3") = male business punish explain / link=glogit;
run;

**Régression logistique pour VD ordinale;
**======================================;

*cumulative logit model;
proc logistic data=multi.wallet descending;
  model wallet = male business punish explain;
run;

