/* Sortie alternative pour SAS Studio */
data alltobitcens; 
set alltobit;
if yachat eq 0 then lcens=.;
else lcens = ymontant;
if _N_ le 1000 then do;
if yachat = 0 then ymontant = 0;
end;
run;


proc lifereg data=alltobitcens outest=OUTEST(keep=_scale_);;
model (lcens, ymontant) = x32 x44 x5 x7 x10 cx6 cx10 i_x2_x31
i_x2_x43 i_x1_x43 i_x1_x6 i_x1_x10 i_x5_x8
i_x5_x10 i_x31_x41 i_x31_x8 i_x32_x8
i_x41_x8 i_x42_x8 i_x44_x6 i_x44_x9 i_x8_x10  / dist=normal;
output out=OUT xbeta=Xbeta;
run;

data predict;
   drop lambda _scale_ _prob_;
   set out;
   if _n_ eq 1 then set outest;
   lambda = pdf('NORMAL',Xbeta/_scale_)
            / cdf('NORMAL',Xbeta/_scale_);
   Predict = cdf('NORMAL', Xbeta/_scale_)
             * (Xbeta + _scale_*lambda);
   label Xbeta='variable latente prédite'
         Predict = 'moyenne de la variable censurée';
run;

