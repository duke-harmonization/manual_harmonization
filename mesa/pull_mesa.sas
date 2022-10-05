/* ----------------------------------------------------------------------------------------------------------------------
   $Author: js463 $
   $Date: 2021/12/07 17:20:00 $
   $Source: /data/mesa/dbgap/import_pheno_text/programs/RCS/pull_mesa.sas,v $

   Purpose: Create Phenotype visit file for MESA.

   Assumptions: Source datasets exist

   Outputs: /data/mesa/analdata/pheno_mesa.sas7bdat
            /data/mesa/analdata/pheno_mesa.csv

   ---------------------------------------------------------------------------------------------------------------------
   Modification History
   ---------------------------------------------------------------------------------------------------------------------
   $Log: pull_mesa.sas,v $
   Revision 1.3  2021/12/07 17:20:00  js463
   Added five new variables for Exam 1:  ACTIVITY, INACTIVITY, FRUITS, VEGETABLES, and SODIUM.

   Revision 1.2  2021/07/22 16:07:50  js463
   Added all the new variables except "Sodium intake", "Fruits", "Vegetables", and "Physical inactivity".

   Revision 1.1  2021/06/10 20:21:31  js463
   Initial revision



   ---------------------------------------------------------------------------------------------------------------------
*/

/* Libname for source raw SAS data sets for the MESA participants */
libname in1 '/data/mesa/dbgap/import_pheno_text/outdata' access=readonly;
libname in2 '/data/mesa/dbgap2/import_pheno_text/outdata' access=readonly;
libname in3 '/data/mesa/exam1_diet/sasdata' access=readonly;
/* Output directory for final MESA phenotype data set. */
libname out1 '/data/mesa/analdata';

/***********************************************************************/
/*                                                                     */
/* All MESA phenotype variables come from these five source data sets: */
/* EXAM 1 - pht001116_v10_mesa_exam1main                               */
/* EXAM 2 - pht001118_v8_mesa_exam2main                                */
/* EXAM 3 - pht001119_v8_mesa_exam3main                                */
/* EXAM 4 - pht001120_v10_mesa_exam4main                               */
/* EXAM 5 - pht003091_v3_mesa_exam5main                                */
/*                                                                     */
/***********************************************************************/

proc format;
 value educf
  1 = 'Less than High School'
  2 = 'High School'
  3 = 'Some College'
  4 = 'College';

 value genhelb
  1 = 'Excellent'
  2 = 'Very good'
  3 = 'Good'
  4 = 'Fair'
  5 = 'Poor';

 value faminc
  1 = 'less than $5,000'
  3 = '$5,000 to $7,000'
  4 = '$8,000 to $11,000'
  6 = '$12,000 to $15,000'
  8 = '$16,000 to $19,000'
  10 = '$20,000 to $24,000'
  11 = '$25,000 to $29,000'
  13 = '$30,000 to $34,000'
  14 = '$35,000 to $39,000'
  18 = '$40,000 to $49,000'
  20 = '$50,000 to $74,000'
  21 = '$75,000 to $99,000 '
  22 = 'more than $100,000';

 value active
  1 = 'Inactive'
  2 = 'Slightly active'
  3 = 'Active';

run;


/*******************************************************************************************************/
/* Get data for creating History of Cardiovascular Disease variable for Framingham stroke risk model   */
/*******************************************************************************************************/
data cvdisease(rename=(date=cvdt));
 set in1.pht001123_v7_mesa_thruyear2011ev(drop=strkbis3)
     in2.pht001123_v7_mesa_thruyear2011ev(drop=strkbis3);

  if mi=1 or rca=1 or ang=1 or chf=1 or pvd=1;

  date = min(mitt,rcatt,angtt,chftt,pvdtt);

  keep sidno date;
run;

proc sort data=cvdisease nodupkey;
 by sidno cvdt;
run;

/********************************************************************************/
/* Get data for creating History of MI variable for REGARDS stroke model        */
/********************************************************************************/
data hxmi(rename=(date=midt));
 set in1.pht001123_v7_mesa_thruyear2011ev(drop=strkbis3)
     in2.pht001123_v7_mesa_thruyear2011ev(drop=strkbis3);

  if mi=1;

  date = mitt;

  keep sidno date;
run;

proc sort data=hxmi nodupkey;
 by sidno midt;
run;

/*******************************************************************************************************/
/* Get data for creating History of Heart Disease variable for CHS stroke model                        */
/*******************************************************************************************************/
data allhrtdis(rename=(date=hrtdt));
 set in1.pht001123_v7_mesa_thruyear2011ev(drop=strkbis3)
     in2.pht001123_v7_mesa_thruyear2011ev(drop=strkbis3);

  if mi=1 or rca=1 or ang=1 or chf=1 or pvd=1 or cbg=1 or ptca=1 or revc=1;

  date = min(mitt,rcatt,angtt,chftt,pvdtt,cbgtt,ptcatt,revctt);

  keep sidno date;
run;

proc sort data=allhrtdis nodupkey;
 by sidno hrtdt;
run;

/********************************************************************************/
/* Get data for creating Atrial Fibrillation variable for stroke models         */
/********************************************************************************/
data hxafib(rename=(date=afibdt));
 set in1.pht001217_v5_mesa_mesaafibevents
     in2.pht001217_v5_mesa_mesaafibevents;

  if afib=1;

  date = afibtt;

  keep sidno date;
run;

proc sort data=hxafib nodupkey;
 by sidno afibdt;
run;



/* Get the RACE1C variable for Exam 1.  Will be merged onto each visit record at the end. */
/* Race added 12/5/2018 */

data getrace(drop=race1c);
 length race_c $20;
 set in1.pht001116_v10_mesa_exam1main(keep=sidno race1c)
     in2.pht001116_v10_mesa_exam1main(keep=sidno race1c);

  if race1c=1 then race_c='White';
   else if race1c=2 then race_c='Chinese American';
   else if race1c=3 then race_c='Black';
   else if race1c=4 then race_c='Hispanic';

  label race_c = 'Race';
run;

proc sort data=getrace nodupkey;
 by sidno;
run;

/************************/

/* Create BASE_CVD, CENSDAY, DEATH_IND and DEATH_IND_T2 for merging onto the Exam 1 record for each patient. */
/* Added 02/7/2019 */
data addvar_ex1(keep=sidno base_cvd censday death_ind death_ind_T2);
 length base_cvd death_ind $3;
 set in1.pht001123_v7_mesa_thruyear2011ev(keep=sidno prebase fuptt dth dthtt)
     in2.pht001123_v7_mesa_thruyear2011ev(keep=sidno prebase fuptt dth dthtt);

 if prebase in ('ang','chf','mi','pvd') then base_cvd="YES";
  else base_cvd="NO";

 censday=fuptt;

 if dth=1 then death_ind="YES";
  else death_ind="NO";

 death_ind_T2=dthtt;

 label base_cvd = 'Baseline CVD'
       censday = 'Censoring time for non-fatal events'
       death_ind = 'Death indicator'
       death_ind_t2 = 'Censoring time for all-cause death (only relevant to MESA)';

run;

proc sort data=addvar_ex1 nodupkey;
 by sidno;
run;


/*********************************************/
/* Get Sodium, Fruits & Vegetables at Exam 1 */
/*********************************************/
proc sort data=in3.exam1dietnutrients(keep=sidno nan1c) out=sodium_v1(rename=(nan1c=sodium));
 by sidno;
run;

data fruveg_v1(keep=sidno fruits vegetables);
 set in3.exam1diet(keep=sidno svdapple1c svdorange1c svdpeach1c svdbanana1c svdstrawberries1c svdcantaloupe1c svdavacado1c
                        svddriedfruit1c svdotherfruit1c svdgreenbean1c svdbroccoli1c svdcarrot1c svdhominy1c svdlettuce1c
                        svdspinach1c svdsquash1c svdsweetpotato1c svdtomato1c svdbean1c svdotherveg1c);

 /* convert fruits and vegetables (servings per day)  to servings per week */
 %macro cserv(food=,fserv=);
  &fserv = &food * 7;
 %mend cserv;

 %cserv(food=svdapple1c,fserv=appsv);
 %cserv(food=svdorange1c,fserv=oransv);
 %cserv(food=svdpeach1c,fserv=peachsv);
 %cserv(food=svdbanana1c,fserv=bansv);
 %cserv(food=svdstrawberries1c,fserv=strawsv);
 %cserv(food=svdcantaloupe1c,fserv=cantasv);
 %cserv(food=svdavacado1c,fserv=avosv);
 %cserv(food=svddriedfruit1c,fserv=driedsv);
 %cserv(food=svdotherfruit1c,fserv=othfrsv);

 %cserv(food=svdgreenbean1c,fserv=grbnsv);
 %cserv(food=svdbroccoli1c,fserv=brocsv);
 %cserv(food=svdcarrot1c,fserv=carrsv);
 %cserv(food=svdhominy1c,fserv=homisv);
 %cserv(food=svdspinach1c,fserv=spinsv);
 %cserv(food=svdlettuce1c,fserv=lettsv);
 %cserv(food=svdbean1c,fserv=beansv);
 %cserv(food=svdsquash1c,fserv=squasv);
 %cserv(food=svdsweetpotato1c,fserv=swptsv);
 %cserv(food=svdtomato1c,fserv=tomasv);
 %cserv(food=svdotherveg1c,fserv=othvsv);

  fruits=round(sum(appsv,oransv,peachsv,bansv,strawsv,cantasv,avosv,driedsv,othfrsv),1);

  vegetables=round(sum(grbnsv,brocsv,carrsv,homisv,spinsv,lettsv,beansv,squasv,swptsv,tomasv,othvsv),1);

run;

proc sort data=fruveg_v1;
 by sidno;
run;

/* EXAM 1 */
data mesa_ex1(drop=cig1c dm031c basq1c fibr1c mlpd1c niac1c prob1c lipid1c educ1 pstk1 rheuhv1 maxstn1c income1 site1c pavcm1c pamcm1c);

 set in1.pht001116_v10_mesa_exam1main(keep=dbGaP_Subject_ID sidno age1c bmi1c cig1c dm031c dbp1c htcm1 gender1 sbp1c wtlb1 htn1c
                                                     glucos1c creatin1 hdl1 ldl1 chol1 trig1 ecglvh1c educ1 claud1t afib1c
                                                     asa1c htnmed1c insln1c sttn1c basq1c fibr1c mlpd1c niac1c prob1c lipid1c
                                                     pstk1 rheuhv1 maxstn1c alcwkc1 income1 site1c pavcm1c pamcm1c)
     in2.pht001116_v10_mesa_exam1main(keep=dbGaP_Subject_ID sidno age1c bmi1c cig1c dm031c dbp1c htcm1 gender1 sbp1c wtlb1 htn1c
                                                     glucos1c creatin1 hdl1 ldl1 chol1 trig1 ecglvh1c educ1 claud1t afib1c
                                                     asa1c htnmed1c insln1c sttn1c basq1c fibr1c mlpd1c niac1c prob1c lipid1c
                                                     pstk1 rheuhv1 maxstn1c alcwkc1 income1 site1c pavcm1c pamcm1c);

 visit = 'EXAM1';

 /* visday --> days since exam1 */
 visday = 0;

 if gender1=1 then gender1_c='M';
  else if gender1=0 then gender1_c='F';

 if cig1c in (0,1) then currsmk = 0;
  else if cig1c = 2 then currsmk = 1;

 if dm031c in (0,1) then diab = 0;
  else if dm031c in (2,3) then diab = 1;

 if pstk1=1 then fh_stroke = 1;
  else if pstk1 in (0,9) then fh_stroke = 0;

 if rheuhv1=1 then valvdis = 1;
  else if rheuhv1 in (0,9) then valvdis = 0;

 if maxstn1c in (0,1,2) then carsten = 0;
  else if maxstn1c in (3,4,5) then carsten = 1;

 if income1=1 then fam_income=1;
  else if income1=2 then fam_income=3;
  else if income1=3 then fam_income=4;
  else if income1=4 then fam_income=6;
  else if income1=5 then fam_income=8;
  else if income1=6 then fam_income=10;
  else if income1=7 then fam_income=11;
  else if income1=8 then fam_income=13;
  else if income1=9 then fam_income=14;
  else if income1=10 then fam_income=18;
  else if income1=11 then fam_income=20;
  else if income1=12 then fam_income=21;
  else if income1=13 then fam_income=22;

 if site1c=3 then state='NC';
  else if site1c=4 then state='NY';
  else if site1c=5 then state='MD';
  else if site1c=6 then state='MN';
  else if site1c=7 then state='IL';
  else if site1c=8 then state='CA';

 if basq1c=1 or fibr1c=1 or mlpd1c=1 or niac1c=1 or prob1c=1 then nonstatin=1;
  else nonstatin=0;

 if sttn1c=1 or basq1c=1 or fibr1c=1 or mlpd1c=1 or niac1c=1 or prob1c=1 or lipid1c=1 then anycholmed=1;
  else anycholmed=0;

 if educ1 in (0,1,2) then educlev=1;
  else if educ1 = 3 then educlev=2;
  else if educ1 in (4,5,6) then educlev=3;
  else if educ1 in (7,8) then educlev=4;

 if pavcm1c=0 and (0 <= pamcm1c <= 500) then inactivity=1;
  else if pavcm1c > 0 or pamcm1c > 500 then inactivity=0;

 if pavcm1c=0 and (0 <= pamcm1c <= 500) then activity=1;
  else if pavcm1c=0 and pamcm1c > 500 then activity=2;
  else if pavcm1c > 0 then activity=3;


 format educlev educf. fam_income faminc. activity active.;

 rename asa1c=aspirin
        htnmed1c=hrx
        insln1c=insulin
        sttn1c=statin
        age1c=age
        bmi1c=bmi
        dbp1c=diabp
        sbp1c=sysbp
        htcm1=hgt_cm
        gender1=sex
        gender1_c=sex_c
        wtlb1=wgt
        htn1c=hypt
        glucos1c=fasting_bg
        creatin1=creat
        hdl1=hdl
        ldl1=ldl
        chol1=tc
        trig1=trig
        ecglvh1c=lvh
        alcwkc1=alcohol;

 label age1c = 'Age (years)'
       anycholmed = 'Taking any cholesterol medication (statin or non-statin) (0=No, 1=Yes)'
       asa1c = 'Taking aspirin (0=No, 1=Yes)'
       bmi1c = 'Body mass index (kg/m2)'
       creatin1 = 'Creatinine (mg/dL)'
       currsmk = 'Current smoking status (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diab = 'Diabetes Mellitus Status (Source: Calculated) (0=No, 1=Yes)'
       dbp1c = 'SEATED DIASTOLIC BLOOD PRESSURE (MM HG)'
       glucos1c = 'Fasting blood glucose (mg/dL)'
       hdl1 = 'HDL cholesterol (mg/dL)'
       htcm1 = 'Height (centimeters)'
       htnmed1c = 'Treated for hypertension (0=No, 1=Yes)'
       htn1c = 'Hypertension (0=No, 1=Yes)'
       insln1c = 'Taking insulin (0=No, 1=Yes)'
       ldl1='LDL cholesterol (mg/dl)'
       nonstatin = 'Taking non-statin medication (0=No, 1=Yes)'
       gender1 = 'Participant gender (1=Male, 0=Female)'
       gender1_c = 'Participant gender (character)'
       sidno = 'SHARE ID NUMBER'
       sttn1c = 'Taking statin medication (0=No, 1=Yes)'
       sbp1c = 'SEATED SYSTOLIC BLOOD PRESSURE (MM HG)'
       chol1 = 'Total cholesterol (mg/dL)'
       trig1 = 'Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wtlb1 = 'Weight (lbs)'
       ecglvh1c = 'Left Ventricular Hypertrophy'
       educlev = 'Education level (1=Less than High School, 2=High School, 3=Some College, 4=College)'
       fh_stroke = 'Family history of stroke, Mother or Father (0=No, 1=Yes)'
       valvdis = 'Valvular heart disease (0=No, 1=Yes)'
       carsten = 'Carotid stenosis (0=No, 1=Yes)'
       alcwkc1 = 'Alcohol (servings per week)'
       fam_income = 'Family income'
       state = 'Site location (state)'
       inactivity = 'Physical inactivity (0=No, 1=Yes)'
       activity = 'Physical activity (3-levels)';


run;

proc sort data=mesa_ex1;
 by sidno;
run;

data mesa_ex1(drop=claud1t cvdt midt hrtdt afibdt afib1c);
 length hxcvd hxmi hxhrtd $3;
 merge mesa_ex1
       addvar_ex1
       cvdisease
       hxmi
       allhrtdis
       hxafib
       fruveg_v1
       sodium_v1;
 by sidno;

 hxcvd="NO"; hxmi="NO"; hxhrtd="NO"; afib=0;

 if (. < cvdt <= visday) or base_cvd="YES" or claud1t=1 then hxcvd="YES";
 if (. < midt <= visday) then hxmi="YES";
 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";
 if (. < afibdt <= visday) or afib1c=1 then afib=1;

 label sodium = 'Sodium intake (mg/day)'
       fruits = 'Fruits (servings per week)'
       vegetables = 'Vegetables (servings per week)';

run;

/* EXAM 2 */
data mesa_ex2(drop=e12dyc cig2c dm032c basq2c fibr2c mlpd2c niac2c prob2c lipid2c);

 set in1.pht001118_v8_mesa_exam2main(keep=dbGaP_Subject_ID sidno age2c bmi2c cig2c dm032c dbp2c htcm2 gender1 sbp2c wtlb2 htn2c
                                                     glucos2c hdl2 ldl2 chol2 trig2 e12dyc genhel2 claud2t
                                                     asa2c htnmed2c insln2c sttn2c basq2c fibr2c mlpd2c niac2c prob2c lipid2c)
     in2.pht001118_v8_mesa_exam2main(keep=dbGaP_Subject_ID sidno age2c bmi2c cig2c dm032c dbp2c htcm2 gender1 sbp2c wtlb2 htn2c
                                                     glucos2c hdl2 ldl2 chol2 trig2 e12dyc genhel2 claud2t
                                                     asa2c htnmed2c insln2c sttn2c basq2c fibr2c mlpd2c niac2c prob2c lipid2c);


 visit = 'EXAM2';

 /* visday --> days since exam1 */
 visday = e12dyc;

 if gender1=1 then gender1_c='M';
  else if gender1=0 then gender1_c='F';

 if cig2c in (0,1) then currsmk = 0;
  else if cig2c = 2 then currsmk = 1;

 if dm032c in (0,1) then diab = 0;
  else if dm032c in (2,3) then diab = 1;

 if basq2c=1 or fibr2c=1 or mlpd2c=1 or niac2c=1 or prob2c=1 then nonstatin=1;
  else nonstatin=0;

 if sttn2c=1 or basq2c=1 or fibr2c=1 or mlpd2c=1 or niac2c=1 or prob2c=1 or lipid2c=1 then anycholmed=1;
  else anycholmed=0;


 rename asa2c=aspirin
        htnmed2c=hrx
        insln2c=insulin
        sttn2c=statin
        age2c=age
        bmi2c=bmi
        dbp2c=diabp
        sbp2c=sysbp
        htcm2=hgt_cm
        gender1=sex
        gender1_c=sex_c
        wtlb2=wgt
        htn2c=hypt
        glucos2c=fasting_bg
        hdl2=hdl
        ldl2=ldl
        chol2=tc
        trig2=trig
        genhel2=genhlth2;

 label age2c = 'Age (years)'
       anycholmed = 'Taking any cholesterol medication (statin or non-statin) (0=No, 1=Yes)'
       asa2c = 'Taking aspirin (0=No, 1=Yes)'
       bmi2c = 'Body mass index (kg/m2)'
       currsmk = 'Current smoking status (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diab = 'Diabetes Mellitus Status (Source: Calculated) (0=No, 1=Yes)'
       dbp2c = 'SEATED DIASTOLIC BLOOD PRESSURE (MM HG)'
       glucos2c = 'Fasting blood glucose (mg/dL)'
       hdl2 = 'HDL cholesterol (mg/dL)'
       htcm2 = 'Height (centimeters)'
       htnmed2c = 'Treated for hypertension (0=No, 1=Yes)'
       htn2c = 'Hypertension (0=No, 1=Yes)'
       insln2c = 'Taking insulin (0=No, 1=Yes)'
       ldl2='LDL cholesterol (mg/dl)'
       nonstatin = 'Taking non-statin medication (0=No, 1=Yes)'
       gender1 = 'Participant gender (1=Male, 0=Female)'
       gender1_c = 'Participant gender (character)'
       sidno = 'SHARE ID NUMBER'
       sttn2c = 'Taking statin medication (0=No, 1=Yes)'
       sbp2c = 'SEATED SYSTOLIC BLOOD PRESSURE (MM HG)'
       chol2 = 'Total cholesterol (mg/dL)'
       trig2 = 'Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wtlb2 = 'Weight (lbs)'
       genhel2 = 'General Health (Exam 2, 5-category)';

 format genhel2 genhelb.;


run;

proc sort data=mesa_ex2;
 by sidno;
run;

data mesa_ex2(drop=claud2t cvdt midt hrtdt afibdt base_cvd);
 length hxcvd hxmi hxhrtd $3;
 merge mesa_ex2
       addvar_ex1(keep=sidno base_cvd)
       cvdisease
       hxmi
       allhrtdis
       hxafib;
 by sidno;

 hxcvd="NO"; hxmi="NO"; hxhrtd="NO"; afib=0;

 if (. < cvdt <= visday) or base_cvd="YES" or claud2t=1 then hxcvd="YES";
 if (. < midt <= visday) then hxmi="YES";
 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";
 if (. < afibdt <= visday) then afib=1;

run;


/* EXAM 3 */
data mesa_ex3(drop=e13dyc cig3c dm033c basq3c fibr3c mlpd3c niac3c prob3c lipid3c);

 set in1.pht001119_v8_mesa_exam3main(keep=dbGaP_Subject_ID sidno age3c bmi3c cig3c dm033c dbp3c htcm3 gender1 sbp3c wtlb3 htn3c
                                                     glucos3c creatin3 hdl3 ldl3 chol3 trig3 e13dyc claud3t
                                                     asa3c htnmed3c insln3c sttn3c basq3c fibr3c mlpd3c niac3c prob3c lipid3c)
     in2.pht001119_v8_mesa_exam3main(keep=dbGaP_Subject_ID sidno age3c bmi3c cig3c dm033c dbp3c htcm3 gender1 sbp3c wtlb3 htn3c
                                                     glucos3c creatin3 hdl3 ldl3 chol3 trig3 e13dyc claud3t
                                                     asa3c htnmed3c insln3c sttn3c basq3c fibr3c mlpd3c niac3c prob3c lipid3c);


 visit = 'EXAM3';

 /* visday --> days since exam1 */
 visday = e13dyc;

 if gender1=1 then gender1_c='M';
  else if gender1=0 then gender1_c='F';

 if cig3c in (0,1) then currsmk = 0;
  else if cig3c = 2 then currsmk = 1;

 if dm033c in (0,1) then diab = 0;
  else if dm033c in (2,3) then diab = 1;

 if basq3c=1 or fibr3c=1 or mlpd3c=1 or niac3c=1 or prob3c=1 then nonstatin=1;
  else nonstatin=0;

 if sttn3c=1 or basq3c=1 or fibr3c=1 or mlpd3c=1 or niac3c=1 or prob3c=1 or lipid3c=1 then anycholmed=1;
  else anycholmed=0;


 rename asa3c=aspirin
        htnmed3c=hrx
        insln3c=insulin
        sttn3c=statin
        age3c=age
        bmi3c=bmi
        dbp3c=diabp
        sbp3c=sysbp
        htcm3=hgt_cm
        gender1=sex
        gender1_c=sex_c
        wtlb3=wgt
        htn3c=hypt
        glucos3c=fasting_bg
        creatin3=creat
        hdl3=hdl
        ldl3=ldl
        chol3=tc
        trig3=trig;

 label age3c = 'Age (years)'
       anycholmed = 'Taking any cholesterol medication (statin or non-statin) (0=No, 1=Yes)'
       asa3c = 'Taking aspirin (0=No, 1=Yes)'
       bmi3c = 'Body mass index (kg/m2)'
       creatin3 = 'Creatinine (mg/dL)'
       currsmk = 'Current smoking status (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diab = 'Diabetes Mellitus Status (Source: Calculated) (0=No, 1=Yes)'
       dbp3c = 'SEATED DIASTOLIC BLOOD PRESSURE (MM HG)'
       glucos3c = 'Fasting blood glucose (mg/dL)'
       hdl3 = 'HDL cholesterol (mg/dL)'
       htcm3 = 'Height (centimeters)'
       htnmed3c = 'Treated for hypertension (0=No, 1=Yes)'
       htn3c = 'Hypertension (0=No, 1=Yes)'
       insln3c = 'Taking insulin (0=No, 1=Yes)'
       ldl3='LDL cholesterol (mg/dl)'
       nonstatin = 'Taking non-statin medication (0=No, 1=Yes)'
       gender1 = 'Participant gender (1=Male, 0=Female)'
       gender1_c = 'Participant gender (character)'
       sidno = 'SHARE ID NUMBER'
       sttn3c = 'Taking statin medication (0=No, 1=Yes)'
       sbp3c = 'SEATED SYSTOLIC BLOOD PRESSURE (MM HG)'
       chol3 = 'Total cholesterol (mg/dL)'
       trig3 = 'Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wtlb3 = 'Weight (lbs)';


run;

proc sort data=mesa_ex3;
 by sidno;
run;

data mesa_ex3(drop=claud3t cvdt midt hrtdt afibdt base_cvd);
 length hxcvd hxmi hxhrtd $3;
 merge mesa_ex3
       addvar_ex1(keep=sidno base_cvd)
       cvdisease
       hxmi
       allhrtdis
       hxafib;
 by sidno;

 hxcvd="NO"; hxmi="NO"; hxhrtd="NO"; afib=0;

 if (. < cvdt <= visday) or base_cvd="YES" or claud3t=1 then hxcvd="YES";
 if (. < midt <= visday) then hxmi="YES";
 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";
 if (. < afibdt <= visday) then afib=1;

run;

/* EXAM 4 */
data mesa_ex4(drop=e14dyc cig4c dm034c basq4c fibr4c mlpd4c niac4c prob4c lipid4c);

 set in1.pht001120_v10_mesa_exam4main(keep=dbGaP_Subject_ID sidno age4c bmi4c cig4c dm034c dbp4c htcm4 gender1 sbp4c wtlb4 htn4c
                                                     glucos4c creatin4 hdl4 ldl4 chol4 trig4 e14dyc claud4t
                                                     asa4c htnmed4c insln4c sttn4c basq4c fibr4c mlpd4c niac4c prob4c lipid4c)
     in2.pht001120_v10_mesa_exam4main(keep=dbGaP_Subject_ID sidno age4c bmi4c cig4c dm034c dbp4c htcm4 gender1 sbp4c wtlb4 htn4c
                                                     glucos4c creatin4 hdl4 ldl4 chol4 trig4 e14dyc claud4t
                                                     asa4c htnmed4c insln4c sttn4c basq4c fibr4c mlpd4c niac4c prob4c lipid4c);


 visit = 'EXAM4';

 /* visday --> days since exam1 */
 visday = e14dyc;

 if gender1=1 then gender1_c='M';
  else if gender1=0 then gender1_c='F';

 if cig4c in (0,1) then currsmk = 0;
  else if cig4c = 2 then currsmk = 1;

 if dm034c in (0,1) then diab = 0;
  else if dm034c in (2,3) then diab = 1;

 if basq4c=1 or fibr4c=1 or mlpd4c=1 or niac4c=1 or prob4c=1 then nonstatin=1;
  else nonstatin=0;

 if sttn4c=1 or basq4c=1 or fibr4c=1 or mlpd4c=1 or niac4c=1 or prob4c=1 or lipid4c=1 then anycholmed=1;
  else anycholmed=0;


 rename asa4c=aspirin
        htnmed4c=hrx
        insln4c=insulin
        sttn4c=statin
        age4c=age
        bmi4c=bmi
        dbp4c=diabp
        sbp4c=sysbp
        htcm4=hgt_cm
        gender1=sex
        gender1_c=sex_c
        wtlb4=wgt
        htn4c=hypt
        glucos4c=fasting_bg
        creatin4=creat
        hdl4=hdl
        ldl4=ldl
        chol4=tc
        trig4=trig;

 label age4c = 'Age (years)'
       anycholmed = 'Taking any cholesterol medication (statin or non-statin) (0=No, 1=Yes)'
       asa4c = 'Taking aspirin (0=No, 1=Yes)'
       bmi4c = 'Body mass index (kg/m2)'
       creatin4 = 'Creatinine (mg/dL)'
       currsmk = 'Current smoking status (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diab = 'Diabetes Mellitus Status (Source: Calculated) (0=No, 1=Yes)'
       dbp4c = 'SEATED DIASTOLIC BLOOD PRESSURE (MM HG)'
       glucos4c = 'Fasting blood glucose (mg/dL)'
       hdl4 = 'HDL cholesterol (mg/dL)'
       htcm4 = 'Height (centimeters)'
       htnmed4c = 'Treated for hypertension (0=No, 1=Yes)'
       htn4c = 'Hypertension (0=No, 1=Yes)'
       insln4c = 'Taking insulin (0=No, 1=Yes)'
       ldl4='LDL cholesterol (mg/dl)'
       nonstatin = 'Taking non-statin medication (0=No, 1=Yes)'
       gender1 = 'Participant gender (1=Male, 0=Female)'
       gender1_c = 'Participant gender (character)'
       sidno = 'SHARE ID NUMBER'
       sttn4c = 'Taking statin medication (0=No, 1=Yes)'
       sbp4c = 'SEATED SYSTOLIC BLOOD PRESSURE (MM HG)'
       chol4 = 'Total cholesterol (mg/dL)'
       trig4 = 'Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wtlb4 = 'Weight (lbs)';


run;

proc sort data=mesa_ex4;
 by sidno;
run;

data mesa_ex4(drop=claud4t cvdt midt hrtdt afibdt base_cvd);
 length hxcvd hxmi hxhrtd $3;
 merge mesa_ex4
       addvar_ex1(keep=sidno base_cvd)
       cvdisease
       hxmi
       allhrtdis
       hxafib;
 by sidno;

 hxcvd="NO"; hxmi="NO"; hxhrtd="NO"; afib=0;

 if (. < cvdt <= visday) or base_cvd="YES" or claud4t=1 then hxcvd="YES";
 if (. < midt <= visday) then hxmi="YES";
 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";
 if (. < afibdt <= visday) then afib=1;

run;

/* EXAM 5 */
data mesa_ex5(drop=e15dyc cig5c dm035c basq5c fibr5c mlpd5c niac5c prob5c lipid5c);

 set in1.pht003091_v3_mesa_exam5main(keep=dbGaP_Subject_ID sidno age5c bmi5c cig5c dm035c dbp5c htcm5 gender1 sbp5c wtlb5 htn5c
                                                     glucose5 creatin5 hdl5 ldl5 chol5 trig5 e15dyc ecglvh5c claud5t afib5c
                                                     asa5c htnmed5c insln5c sttn5c basq5c fibr5c mlpd5c niac5c prob5c lipid5c)
     in2.pht003091_v3_mesa_exam5main(keep=dbGaP_Subject_ID sidno age5c bmi5c cig5c dm035c dbp5c htcm5 gender1 sbp5c wtlb5 htn5c
                                                     glucose5 creatin5 hdl5 ldl5 chol5 trig5 e15dyc ecglvh5c claud5t afib5c
                                                     asa5c htnmed5c insln5c sttn5c basq5c fibr5c mlpd5c niac5c prob5c lipid5c);


 visit = 'EXAM5';

 /* visday --> days since exam1 */
 visday = e15dyc;

 if gender1=1 then gender1_c='M';
  else if gender1=0 then gender1_c='F';

 if cig5c in (0,1) then currsmk = 0;
  else if cig5c = 2 then currsmk = 1;

 if dm035c in (0,1) then diab = 0;
  else if dm035c in (2,3) then diab = 1;

 if basq5c=1 or fibr5c=1 or mlpd5c=1 or niac5c=1 or prob5c=1 then nonstatin=1;
  else nonstatin=0;

 if sttn5c=1 or basq5c=1 or fibr5c=1 or mlpd5c=1 or niac5c=1 or prob5c=1 or lipid5c=1 then anycholmed=1;
  else anycholmed=0;


 rename asa5c=aspirin
        htnmed5c=hrx
        insln5c=insulin
        sttn5c=statin
        age5c=age
        bmi5c=bmi
        dbp5c=diabp
        sbp5c=sysbp
        htcm5=hgt_cm
        gender1=sex
        gender1_c=sex_c
        wtlb5=wgt
        htn5c=hypt
        glucose5=fasting_bg
        creatin5=creat
        hdl5=hdl
        ldl5=ldl
        chol5=tc
        trig5=trig
        ecglvh5c=lvh;

 label age5c = 'Age (years)'
       anycholmed = 'Taking any cholesterol medication (statin or non-statin) (0=No, 1=Yes)'
       asa5c = 'Taking aspirin (0=No, 1=Yes)'
       bmi5c = 'Body mass index (kg/m2)'
       creatin5 = 'Creatinine (mg/dL)'
       currsmk = 'Current smoking status (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diab = 'Diabetes Mellitus Status (Source: Calculated) (0=No, 1=Yes)'
       dbp5c = 'SEATED DIASTOLIC BLOOD PRESSURE (MM HG)'
       glucose5 = 'Fasting blood glucose (mg/dL)'
       hdl5 = 'HDL cholesterol (mg/dL)'
       htcm5 = 'Height (centimeters)'
       htnmed5c = 'Treated for hypertension (0=No, 1=Yes)'
       htn5c = 'Hypertension (0=No, 1=Yes)'
       insln5c = 'Taking insulin (0=No, 1=Yes)'
       ldl5='LDL cholesterol (mg/dl)'
       nonstatin = 'Taking non-statin medication (0=No, 1=Yes)'
       gender1 = 'Participant gender (1=Male, 0=Female)'
       gender1_c = 'Participant gender (character)'
       sidno = 'SHARE ID NUMBER'
       sttn5c = 'Taking statin medication (0=No, 1=Yes)'
       sbp5c = 'SEATED SYSTOLIC BLOOD PRESSURE (MM HG)'
       chol5 = 'Total cholesterol (mg/dL)'
       trig5 = 'Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wtlb5 = 'Weight (lbs)'
       ecglvh5c = 'Left Ventricular Hypertrophy';


run;

proc sort data=mesa_ex5;
 by sidno;
run;

data mesa_ex5(drop=claud5t cvdt midt hrtdt afibdt afib5c base_cvd);
 length hxcvd hxmi hxhrtd $3;
 merge mesa_ex5
       addvar_ex1(keep=sidno base_cvd)
       cvdisease
       hxmi
       allhrtdis
       hxafib;
 by sidno;

 hxcvd="NO"; hxmi="NO"; hxhrtd="NO"; afib=0;

 if (. < cvdt <= visday) or base_cvd="YES" or claud5t=1 then hxcvd="YES";
 if (. < midt <= visday) then hxmi="YES";
 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";
 if (. < afibdt <= visday) or afib5c=1 then afib=1;

run;

/* Combine all EXAM1-EXAM5 data */
data pheno_mesa;
 set mesa_ex1
     mesa_ex2
     mesa_ex3
     mesa_ex4
     mesa_ex5;

 rename sex=sex_n;

 label afib = 'Atrial Fibrillation'
       hxcvd = 'History of cardiovascular disease'
       hxhrtd = 'History of heart disease'
       hxmi = 'History of MI';
run;

proc sort data=pheno_mesa;
 by sidno visit;
run;

/* Add RACE_C to each record  */
data pheno_mesa;
 merge pheno_mesa(in=a)
       getrace(in=b);

 by sidno;

 if a;

run;

proc sort data=pheno_mesa;
 by sidno visit;
run;

/* Output final MESA phenotype SAS data set and CSV file */
options validvarname=upcase;
data out1.pheno_mesa;
 set pheno_mesa;
 by sidno visit;
run;

proc export data=pheno_mesa
            outfile="/data/mesa/analdata/pheno_mesa.csv"
            dbms=csv
            replace;
run;

ods rtf file="/data/mesa/analdata/pheno_mesa_contents.rtf";

proc contents data=out1.pheno_mesa;
run;

ods rtf close;
endsas;
