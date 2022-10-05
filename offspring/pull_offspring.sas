/* ----------------------------------------------------------------------------------------------------------------------
   $Author: js463 $
   $Date: 2021/12/07 22:02:34 $
   $Source: /data/framingham/dbgap/import_pheno_text/programs/RCS/pull_offspring.sas,v $

   Purpose: Create Phenotype visit file and events file for Framingham Offspring.

   Assumptions: Source datasets exist

   Outputs: /data/framingham/analdata/pheno_fram_offspring.sas7bdat
            /data/framingham/analdata/events_fram_offspring.sas7bdat

   ---------------------------------------------------------------------------------------------------------------------
   Modification History
   ---------------------------------------------------------------------------------------------------------------------
   $Log: pull_offspring.sas,v $
   Revision 1.5  2021/12/07 22:02:34  js463
   Added the variables INACTIVITY, ACTIVITY, and ACTIVITY_ALT.

   Revision 1.4  2021/07/22 15:57:34  js463
   Addedd all the new variables except "Physical inactivity".

   Revision 1.3  2021/06/22 19:58:26  js463
   Converted height to centimeters.  New variable called HGT_CM.  Dropped HGT.

   Revision 1.2  2021/06/10 21:01:54  js463
   Renamed SEX variable to SEX_N.  Now, 0=Female, 1=Male.

   Revision 1.1  2021/04/27 17:29:07  js463
   Initial revision



   ---------------------------------------------------------------------------------------------------------------------
*/

libname in1 '/data/framingham/dbgap/import_pheno_text/outdata' access=readonly;
libname in2 '/data/framingham/dbgap2/import_pheno_text/outdata' access=readonly;

libname out1 '/data/framingham/analdata';

proc format;
 value educf
  1 = 'Less than High School'
  2 = 'High School'
  3 = 'Some College'
  4 = 'College';

 value faminc
  1 = 'less than $5,000'
  2 = '$5,000 to $9,000'
  5 = '$10,000 to $14,000'
  7 = '$15,000 to $19,000'
  10 = '$20,000 to $24,000'
  11 = '$25,000 to $29,000'
  13 = '$30,000 to $34,000'
  14 = '$35,000 to $39,000'
  16 = '$40,000 to $44,000'
  17 = '$45,000 to $49,000'
  19 = 'more than $50,000';

 value genhel
  1 = 'Excellent'
  2 = 'Good'
  3 = 'Fair'
  4 = 'Poor';

 value genhelb
  1 = 'Excellent'
  2 = 'Very good'
  3 = 'Good'
  4 = 'Fair'
  5 = 'Poor';

 value active
  1 = 'Inactive'
  2 = 'Slightly active'
  3 = 'Active';

run;

/*****************/
/* NEW VARIABLES */
/*****************/

/********************************************/
/* Family history of stroke (mother/father) */
/********************************************/
data fhstroke_v6(keep=shareid fh_stroke);
 set in1.pht000035_v10_ex1_6s(where=(idtype=1))
     in2.pht000035_v10_ex1_6s(where=(idtype=1));

 if f692=1 or f701=1 then fh_stroke=1;
  else if f692 in (0,2) and f701 in (0,2) then fh_stroke=0;

run;

proc sort data=fhstroke_v6(keep=shareid fh_stroke);
 by shareid;
run;

/**********************/
/* High sodium intake */
/**********************/
data hsod_v6(keep=shareid sodium);
 set in1.pht000681_v7_ffreq1_6s(where=(idtype=1) keep=shareid nut_sodium idtype)
     in2.pht000681_v7_ffreq1_6s(where=(idtype=1) keep=shareid nut_sodium idtype);

 sodium = nut_sodium;

run;

proc sort data=hsod_v6(keep=shareid sodium);
 by shareid;
run;

proc univariate data=hsod_v6;
 var sodium;
 title 'Offspring visit 6';
run;

data hsod_v8(keep=shareid sodium);
 set in1.pht002350_v6_vr_ffreq_ex08_1_061(where=(idtype=1) keep=shareid nut_sodium idtype)
     in2.pht002350_v6_vr_ffreq_ex08_1_061(where=(idtype=1) keep=shareid nut_sodium idtype);

 sodium = nut_sodium;
run;

proc sort data=hsod_v8(keep=shareid sodium);
 by shareid;
run;


/********************************************/
/* Valvular heart disease, Carotid Stenosis */
/********************************************/
data valvdis_v3(keep=shareid valvdis carsten);
 set in1.pht000032_v8_ex1_3s(where=(idtype=1) keep=shareid idtype c339 c340 c341 c361 c362)
     in2.pht000032_v8_ex1_3s(where=(idtype=1) keep=shareid idtype c339 c340 c341 c361 c362);

 if c339=1 or c340=1 or c341=1 then valvdis=1;
  else if c339 in (0,2) and c340 in (0,2) and c341 in (0,2) then valvdis=0;

 if c361=1 or c362=1 then carsten=1;
  else if c361 in (0,2) and c362 in (0,2) then carsten=0;

run;

proc sort data=valvdis_v3(keep=shareid valvdis carsten);
 by shareid;
run;

data valvdis_v6(keep=shareid valvdis carsten);
 set in1.pht000035_v10_ex1_6s(where=(idtype=1) keep=shareid idtype f617 f618 f619 f564 f565)
     in2.pht000035_v10_ex1_6s(where=(idtype=1) keep=shareid idtype f617 f618 f619 f564 f565);

 if f617=1 or f618=1 or f619=1 then valvdis=1;
  else if f617 in (0,2) and f618 in (0,2) and f619 in (0,2) then valvdis=0;

 if f564=1 or f565=1 then carsten=1;
  else if f564 in (0,2) and f565 in (0,2) then carsten=0;

run;

proc sort data=valvdis_v6(keep=shareid valvdis carsten);
 by shareid;
run;

data valvdis_v8(keep=shareid valvdis carsten);
 set in1.pht000747_v7_ex1_8s(where=(idtype=1) keep=shareid idtype h339 h340 h341 h298 h299)
     in2.pht000747_v7_ex1_8s(where=(idtype=1) keep=shareid idtype h339 h340 h341 h298 h299);

 if h339=1 or h340=1 or h341=1 then valvdis=1;
  else if h339 in (0,2) and h340 in (0,2) and h341 in (0,2) then valvdis=0;

 if h298=1 or h299=1 then carsten=1;
  else if h298 in (0,2) and h299 in (0,2) then carsten=0;

run;

proc sort data=valvdis_v8(keep=shareid valvdis carsten);
 by shareid;
run;

/**********/
/* Income */
/**********/
data income_v3(keep=shareid fam_income);
 set in1.pht000100_v8_psych1_3s(where=(idtype=1) keep=shareid py125 idtype)
     in2.pht000100_v8_psych1_3s(where=(idtype=1) keep=shareid py125 idtype);

 if py125=2 then fam_income=1;
  else if py125=3 then fam_income=2;
  else if py125=4 then fam_income=5;
  else if py125=5 then fam_income=7;
  else if py125=6 then fam_income=10;
  else if py125=7 then fam_income=11;
  else if py125=8 then fam_income=13;
  else if py125=9 then fam_income=14;
  else if py125=10 then fam_income=16;
  else if py125=11 then fam_income=17;
  else if py125=12 then fam_income=19;

 format fam_income faminc.;
run;

proc sort data=income_v3(keep=shareid fam_income);
 by shareid;
run;

/***********/
/* Alcohol */
/***********/
/* exam 3 calculated variable */
data alco_v3(keep=shareid alcohol);
 set in1.pht000032_v8_ex1_3s(where=(idtype=1) keep=shareid c452 idtype)
     in2.pht000032_v8_ex1_3s(where=(idtype=1) keep=shareid c452 idtype);

  alcohol=c452;
run;
proc sort data=alco_v3;
 by shareid;
run;

/* exam 6 */
data alco_v6(keep=shareid alcohol);
 set in1.pht000681_v7_ffreq1_6s(where=(idtype=1) keep=shareid ffd114-ffd117 idtype)
     in2.pht000681_v7_ffreq1_6s(where=(idtype=1) keep=shareid ffd114-ffd117 idtype);

  alcohol=round(sum(ffd114,ffd115,ffd116,ffd117),1);
run;
proc sort data=alco_v6;
 by shareid;
run;

/* exam 8 */
data alco_v8(keep=shareid alcohol);
 set in1.pht002350_v6_vr_ffreq_ex08_1_061(where=(idtype=1) keep=shareid ffd114-ffd117 idtype)
     in2.pht002350_v6_vr_ffreq_ex08_1_061(where=(idtype=1) keep=shareid ffd114-ffd117 idtype);

  alcohol=round(sum(ffd114,ffd115,ffd116,ffd117),1);
run;
proc sort data=alco_v8;
 by shareid;
run;

/*************************/
/* Fruits and Vegetables */
/*************************/
/* exam 3 */
data fruveg_v3(keep=shareid fruits vegetables);
 set in1.pht000689_v7_ffreq1_3s(where=(idtype=1) keep=shareid idtype apple orange grapfrut peaches bananas strawber blackber melon watermel
                                                      pineappl cherries papayas avocados prunes dates raisins
                                                      greenben broccoli cabbage caulflwr bruselsp carrots corn spinach peppers kale iceberg
                                                      romaine peas wintersq zucchini yams tomatoes lentils)
     in2.pht000689_v7_ffreq1_3s(where=(idtype=1) keep=shareid idtype apple orange grapfrut peaches bananas strawber blackber melon watermel
                                                      pineappl cherries papayas avocados prunes dates raisins
                                                      greenben broccoli cabbage caulflwr bruselsp carrots corn spinach peppers kale iceberg
                                                      romaine peas wintersq zucchini yams tomatoes lentils);

 /* convert fruits and vegetables to servings per week */
 %macro cserv(food=,fserv=);
  if &food=1 then &fserv=0;
   else if &food=2 then &fserv=0.5;
   else if &food=3 then &fserv=1;
   else if &food=4 then &fserv=3;
   else if &food=5 then &fserv=7;
   else if &food=6 then &fserv=17.5;
   else if &food=7 then &fserv=28;
 %mend cserv;

 %cserv(food=apple,fserv=appsv);
 %cserv(food=orange,fserv=oransv);
 %cserv(food=grapfrut,fserv=grapfsv);
 %cserv(food=peaches,fserv=peachsv);
 %cserv(food=bananas,fserv=bansv);
 %cserv(food=strawber,fserv=strawsv);
 %cserv(food=blackber,fserv=blacksv);
 %cserv(food=melon,fserv=melonsv);
 %cserv(food=watermel,fserv=wmelsv);
 %cserv(food=pineappl,fserv=pinesv);
 %cserv(food=cherries,fserv=cherrsv);
 %cserv(food=papayas,fserv=papasv);
 %cserv(food=avocados,fserv=avosv);
 %cserv(food=prunes,fserv=prunesv);
 %cserv(food=dates,fserv=datessv);
 %cserv(food=raisins,fserv=raissv);

 %cserv(food=greenben,fserv=grbnsv);
 %cserv(food=broccoli,fserv=brocsv);
 %cserv(food=cabbage,fserv=cabbsv);
 %cserv(food=caulflwr,fserv=caulsv);
 %cserv(food=bruselsp,fserv=brussv);
 %cserv(food=carrots,fserv=carrsv);
 %cserv(food=corn,fserv=cornsv);
 %cserv(food=spinach,fserv=spinsv);
 %cserv(food=peppers,fserv=peppsv);
 %cserv(food=kale,fserv=kalesv);
 %cserv(food=iceberg,fserv=icebsv);
 %cserv(food=romaine,fserv=romnsv);
 %cserv(food=peas,fserv=peassv);
 %cserv(food=wintersq,fserv=wsqsv);
 %cserv(food=zucchini,fserv=zuccsv);
 %cserv(food=yams,fserv=yamssv);
 %cserv(food=tomatoes,fserv=tomasv);
 %cserv(food=lentils,fserv=lentsv);

  fruits=round(sum(appsv,oransv,grapfsv,peachsv,bansv,strawsv,blacksv,melonsv,wmelsv,pinesv,cherrsv,papasv,avosv,prunesv,datessv,raissv),1);

  vegetables=round(sum(grbnsv,brocsv,cabbsv,caulsv,brussv,carrsv,cornsv,spinsv,peppsv,kalesv,icebsv,romnsv,peassv,wsqsv,zuccsv,yamssv,tomasv,lentsv),1);


run;
proc sort data=fruveg_v3;
 by shareid;
run;

/* exam 6 */
data fruveg_v6(keep=shareid fruits vegetables);
 set in1.pht000681_v7_ffreq1_6s(where=(idtype=1) keep=shareid idtype ffd30-ffd35 ffd37 ffd39 ffd42-ffd44 ffd45 ffd50-ffd70)
     in2.pht000681_v7_ffreq1_6s(where=(idtype=1) keep=shareid idtype ffd30-ffd35 ffd37 ffd39 ffd42-ffd44 ffd45 ffd50-ffd70);

  fruits=round(sum(of ffd30-ffd35, ffd37, ffd39, of ffd42-ffd44),1);

  vegetables=round(sum(ffd45, of ffd50-ffd70),1);

run;
proc sort data=fruveg_v6;
 by shareid;
run;

/* exam 8 */
data fruveg_v8(keep=shareid fruits vegetables);
 set in1.pht002350_v6_vr_ffreq_ex08_1_061(where=(idtype=1) keep=shareid idtype ffd30-ffd35 ffd37 ffd39 ffd42-ffd44 ffd45 ffd50-ffd70)
     in2.pht002350_v6_vr_ffreq_ex08_1_061(where=(idtype=1) keep=shareid idtype ffd30-ffd35 ffd37 ffd39 ffd42-ffd44 ffd45 ffd50-ffd70);

  fruits=round(sum(of ffd30-ffd35, ffd37, ffd39, of ffd42-ffd44),1);

  vegetables=round(sum(ffd45, of ffd50-ffd70),1);

run;
proc sort data=fruveg_v8;
 by shareid;
run;

/**********************************/
/* Physical Activity & Inactivity */
/**********************************/
/* exam 3 (exam 2) */
data pai_v3(keep=shareid inactivity activity activity_alt);
 set in1.pht000031_v9_ex1_2s(where=(idtype=1) keep=shareid idtype b107 b108)
     in2.pht000031_v9_ex1_2s(where=(idtype=1) keep=shareid idtype b107 b108);

 if b107=0 and b108=0 then inactivity=1;
  else if b107 > 0 or b108 > 0 then inactivity=0;

 if b107=0 and b108=0 then activity=1;
  else if b107 > 0 and b108=0 then activity=2;
  else if b108 > 0 then activity=3;

 if b107 in (0,1) and b108=0 then activity_alt=1;
  else if b107 > 1 and b108=0 then activity_alt=2;
  else if b108 > 0 then activity_alt=3;

 format activity activity_alt active.;

run;

proc sort data=pai_v3;
 by shareid;
run;

/* exam 6 (exam 5) */
data pai_v6(keep=shareid inactivity activity activity_alt);
 set in1.pht000098_v8_act1_5s(where=(idtype=1) keep=shareid idtype eh_10d eh_10e)
     in2.pht000098_v8_act1_5s(where=(idtype=1) keep=shareid idtype eh_10d eh_10e);

 if eh_10d=0 and eh_10e=0 then inactivity=1;
  else if eh_10d > 0 or eh_10e > 0 then inactivity=0;

 if eh_10d=0 and eh_10e=0 then activity=1;
  else if eh_10d > 0 and eh_10e=0 then activity=2;
  else if eh_10e > 0 then activity=3;

 if eh_10d in (0,1) and eh_10e=0 then activity_alt=1;
  else if eh_10d > 1 and eh_10e=0 then activity_alt=2;
  else if eh_10e > 0 then activity_alt=3;

 format activity activity_alt active.;

run;

proc sort data=pai_v6;
 by shareid;
run;

/* exam 8 */
data pai_v8(keep=shareid inactivity activity activity_alt);
 set in1.pht000747_v7_ex1_8s(where=(idtype=1) keep=shareid idtype h483 h484)
     in2.pht000747_v7_ex1_8s(where=(idtype=1) keep=shareid idtype h483 h484);

 if h483=0 and h484=0 then inactivity=1;
  else if h483 > 0 or h484 > 0 then inactivity=0;

 if h483=0 and h484=0 then activity=1;
  else if h483 > 0 and h484=0 then activity=2;
  else if h484 > 0 then activity=3;

 if h483 in (0,1) and h484=0 then activity_alt=1;
  else if h483 > 1 and h484=0 then activity_alt=2;
  else if h484 > 0 then activity_alt=3;

 format activity activity_alt active.;

run;

proc sort data=pai_v8;
 by shareid;
run;


/*******************************************************************************************************/
/* Get data for creating History of Cardiovascular Disease variable for Framingham stroke risk model   */
/*******************************************************************************************************/
data cvdisease(rename=(date=cvdt));
 set in1.pht000309_v15_vr_soe_2019_a_1217(where=(idtype=1))
     in2.pht000309_v15_vr_soe_2019_a_1217(where=(idtype=1));

  if event in (1,2,3,4,5,9,6,7,30,39,40,41,49);

  keep shareid date;
run;

proc sort data=cvdisease nodupkey;
 by shareid cvdt;
run;

/********************************************************************************/
/* Get data for creating History of MI variable for REGARDS stroke model        */
/********************************************************************************/
data hxmi(rename=(date=midt));
 set in1.pht000309_v15_vr_soe_2019_a_1217(where=(idtype=1))
     in2.pht000309_v15_vr_soe_2019_a_1217(where=(idtype=1));

  if event in (1,2,3,4,5,9);

  keep shareid date;
run;

proc sort data=hxmi nodupkey;
 by shareid midt;
run;

/*******************************************************************************************************/
/* Get data for creating History of Heart Disease variable for CHS stroke model                        */
/*******************************************************************************************************/
data hrtdisease1(rename=(date=hrtdt));
 set in1.pht000309_v15_vr_soe_2019_a_1217(where=(idtype=1))
     in2.pht000309_v15_vr_soe_2019_a_1217(where=(idtype=1));

  if event in (1,2,3,4,5,9,6,7,30,39,40,41,49);

  keep shareid date;
run;

data hrtdisease2(rename=(procdate=hrtdt));
 set in1.pht000389_v12_vr_cvdproc_2019_a_(where=(idtype=1))
     in2.pht000389_v12_vr_cvdproc_2019_a_(where=(idtype=1));

  if procnum in (140,141);   /*CABG, Angioplasty*/

  keep shareid procdate;
run;

data allhrtdis;
 set hrtdisease1 hrtdisease2;
run;

proc sort data=allhrtdis nodupkey;
 by shareid hrtdt;
run;

/********************************************************************************/
/* Get data for creating BASE_CVD, BASE_STROKE, CENSDAY and DEATH_IND variables */
/********************************************************************************/
data survcvd(keep=shareid base_cvd);
 length base_cvd $3;
 set in1.pht003316_v9_vr_survcvd_2018_a_1(where=(idtype=1))
     in2.pht003316_v9_vr_survcvd_2018_a_1(where=(idtype=1));

 if cvd=1 and (.<cvddate<=0) then base_cvd="YES";
  else base_cvd="NO";
run;

proc sort data=survcvd(keep=shareid base_cvd);
 by shareid;
run;

/*******************************************************/
data svstk(drop=idtype);
 set in1.pht006023_v4_vr_svstk_2018_a_126(where=(idtype=1) keep=shareid idtype stroke strokedate)
     in2.pht006023_v4_vr_svstk_2018_a_126(where=(idtype=1) keep=shareid idtype stroke strokedate);
run;

proc sort data=svstk;
 by shareid;
run;

data svstktia(drop=idtype);
 set in1.pht006024_v4_vr_svstktia_2018_a_(where=(idtype=1) keep=shareid idtype stroke_tia stroketiadate)
     in2.pht006024_v4_vr_svstktia_2018_a_(where=(idtype=1) keep=shareid idtype stroke_tia stroketiadate);
run;

proc sort data=svstk;
 by shareid;
run;

proc sort data=svstktia;
 by shareid;
run;

data survstk(keep=shareid base_stroke);
 merge svstk svstktia;
 by shareid;

 if stroke=1 and (.<strokedate<=0) then base_stroke=2;
 if stroke_tia=1 and stroke=0 and (.<stroketiadate<=0) then base_stroke=1;
 if (base_stroke not in (1,2)) and stroke ne . and stroke_tia ne . then base_stroke=0;

run;

data survdth(keep=shareid death_ind censday);
 length death_ind $3;
 set in1.pht003317_v9_vr_survdth_2018_a_1(where=(idtype=1))
     in2.pht003317_v9_vr_survdth_2018_a_1(where=(idtype=1));

 if datedth = . then death_ind="NO";
  else if datedth ne . then death_ind="YES";

 if death_ind="YES" then censday=datedth;
  else if death_ind="NO" then censday=lastcon;

run;

proc sort data=survdth(keep=shareid death_ind censday);
 by shareid;
run;


/* Diabetes status data for exams 1-9 */
data diabstat;
 set in1.pht000041_v8_vr_diab_ex09_1_1002(where=(idtype=1))
     in2.pht000041_v8_vr_diab_ex09_1_1002(where=(idtype=1));

 keep dbGaP_Subject_ID shareid curr_diab1-curr_diab9;

run;

proc sort data=diabstat;
 by shareid;
run;

data dmdat1(keep=shareid curr_diab1 rename=(curr_diab1=diab))
     dmdat2(keep=shareid curr_diab2 rename=(curr_diab2=diab))
     dmdat3(keep=shareid curr_diab3 rename=(curr_diab3=diab))
     dmdat4(keep=shareid curr_diab4 rename=(curr_diab4=diab))
     dmdat5(keep=shareid curr_diab5 rename=(curr_diab5=diab))
     dmdat6(keep=shareid curr_diab6 rename=(curr_diab6=diab))
     dmdat7(keep=shareid curr_diab7 rename=(curr_diab7=diab))
     dmdat8(keep=shareid curr_diab8 rename=(curr_diab8=diab))
     dmdat9(keep=shareid curr_diab9 rename=(curr_diab9=diab));

 set diabstat;

run;

/* Gender data */
data sex;  /* merge this with calcvars data set */
 set in1.pht003099_v7_vr_dates_2019_a_117(where=(idtype=1))
     in2.pht003099_v7_vr_dates_2019_a_117(where=(idtype=1));

 if sex=1 then sex_c='M';
  else if sex=2 then sex_c='F';

 keep shareid sex sex_c;

run;

proc sort data=sex;
 by shareid;
run;


/* Calculated "work through" variables */
data calcvars;
 set in1.pht006027_v3_vr_wkthru_ex09_1_10(where=(idtype=1))
     in2.pht006027_v3_vr_wkthru_ex09_1_10(where=(idtype=1));

 keep dbGaP_Subject_ID shareid age1-age9 bmi1-bmi9 hgt1-hgt9 wgt1-wgt9 currsmk1-currsmk9 date1-date9 dlvh1-dlvh9
      hrx1-hrx9 tc1-tc9 hdl1-hdl9 trig1-trig9 bg1-bg9 fasting_bg3-fasting_bg9 creat2 creat5-creat9 /*dmrx8 dmrx9*/;

run;

proc sort data=calcvars;
 by shareid;
run;

data calcvars;
 merge calcvars sex;
 by shareid;
run;

data calcvar1(keep=dbGaP_Subject_ID shareid age1 sex sex_c bmi1 hgt1 wgt1 currsmk1 date1 hrx1 tc1 hdl1 trig1 bg1 dlvh1
              rename=(age1=age bmi1=bmi hgt1=hgt wgt1=wgt currsmk1=currsmk date1=visday hrx1=hrx tc1=tc hdl1=hdl trig1=trig bg1=bg dlvh1=lvh))

     calcvar2(keep=dbGaP_Subject_ID shareid age2 sex sex_c bmi2 hgt2 wgt2 currsmk2 date2 hrx2 tc2 hdl2 trig2 bg2 creat2 dlvh2
              rename=(age2=age bmi2=bmi hgt2=hgt wgt2=wgt currsmk2=currsmk date2=visday hrx2=hrx tc2=tc hdl2=hdl trig2=trig bg2=bg creat2=creat dlvh2=lvh))

     calcvar3(keep=dbGaP_Subject_ID shareid age3 sex sex_c bmi3 hgt3 wgt3 currsmk3 date3 hrx3 tc3 hdl3 trig3 bg3 fasting_bg3 dlvh3
              rename=(age3=age bmi3=bmi hgt3=hgt wgt3=wgt currsmk3=currsmk date3=visday hrx3=hrx tc3=tc hdl3=hdl trig3=trig bg3=bg fasting_bg3=fasting_bg dlvh3=lvh))

     calcvar4(keep=dbGaP_Subject_ID shareid age4 sex sex_c bmi4 hgt4 wgt4 currsmk4 date4 hrx4 tc4 hdl4 trig4 bg4 fasting_bg4 dlvh4
              rename=(age4=age bmi4=bmi hgt4=hgt wgt4=wgt currsmk4=currsmk date4=visday hrx4=hrx tc4=tc hdl4=hdl trig4=trig bg4=bg fasting_bg4=fasting_bg dlvh4=lvh))

     calcvar5(keep=dbGaP_Subject_ID shareid age5 sex sex_c bmi5 hgt5 wgt5 currsmk5 date5 hrx5 tc5 hdl5 trig5 bg5 fasting_bg5 creat5 dlvh5
              rename=(age5=age bmi5=bmi hgt5=hgt wgt5=wgt currsmk5=currsmk date5=visday hrx5=hrx tc5=tc hdl5=hdl trig5=trig bg5=bg fasting_bg5=fasting_bg creat5=creat dlvh5=lvh))

     calcvar6(keep=dbGaP_Subject_ID shareid age6 sex sex_c bmi6 hgt6 wgt6 currsmk6 date6 hrx6 tc6 hdl6 trig6 bg6 fasting_bg6 creat6 dlvh6
              rename=(age6=age bmi6=bmi hgt6=hgt wgt6=wgt currsmk6=currsmk date6=visday hrx6=hrx tc6=tc hdl6=hdl trig6=trig bg6=bg fasting_bg6=fasting_bg creat6=creat dlvh6=lvh))

     calcvar7(keep=dbGaP_Subject_ID shareid age7 sex sex_c bmi7 hgt7 wgt7 currsmk7 date7 hrx7 tc7 hdl7 trig7 bg7 fasting_bg7 creat7 dlvh7
              rename=(age7=age bmi7=bmi hgt7=hgt wgt7=wgt currsmk7=currsmk date7=visday hrx7=hrx tc7=tc hdl7=hdl trig7=trig bg7=bg fasting_bg7=fasting_bg creat7=creat dlvh7=lvh))

     calcvar8(keep=dbGaP_Subject_ID shareid age8 sex sex_c bmi8 hgt8 wgt8 currsmk8 date8 hrx8 tc8 hdl8 trig8 bg8 fasting_bg8 creat8 dlvh8 /*dmrx8*/
              rename=(age8=age bmi8=bmi hgt8=hgt wgt8=wgt currsmk8=currsmk date8=visday hrx8=hrx tc8=tc hdl8=hdl trig8=trig bg8=bg fasting_bg8=fasting_bg creat8=creat dlvh8=lvh /*dmrx8=dmrx*/))

     calcvar9(keep=dbGaP_Subject_ID shareid age9 sex sex_c bmi9 hgt9 wgt9 currsmk9 date9 hrx9 tc9 hdl9 trig9 bg9 fasting_bg9 creat9 dlvh9 /*dmrx9*/
              rename=(age9=age bmi9=bmi hgt9=hgt wgt9=wgt currsmk9=currsmk date9=visday hrx9=hrx tc9=tc hdl9=hdl trig9=trig bg9=bg fasting_bg9=fasting_bg creat9=creat dlvh9=lvh /*dmrx9=dmrx*/));

 set calcvars;

run;

data calcvar1;
 set calcvar1;

 visit='EXAM1';
run;

data calcvar2;
 set calcvar2;

 visit='EXAM2';
run;

data calcvar3;
 set calcvar3;

 visit='EXAM3';
run;

data calcvar4;
 set calcvar4;

 visit='EXAM4';
run;

data calcvar5;
 set calcvar5;

 visit='EXAM5';
run;

data calcvar6;
 set calcvar6;

 visit='EXAM6';
run;

data calcvar7;
 set calcvar7;

 visit='EXAM7';
run;

data calcvar8;
 set calcvar8;

 visit='EXAM8';
run;

data calcvar9;
 set calcvar9;

 visit='EXAM9';
run;

/* Exam 1 - vitals, meds */
data exam1(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib anycholmed nonstatin);
 set in1.pht000030_v9_ex1_1s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype a55 a57 a56 a58 a80 a158)
     in2.pht000030_v9_ex1_1s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype a55 a57 a56 a58 a80 a158);

 if a80=1 then do;
  anycholmed=1; nonstatin=1;
 end;
  else do;
   anycholmed=0; nonstatin=0;
  end;

 rename a55=sysbp1 a57=sysbp2 a56=diabp1 a58=diabp2 a158=afib;

run;

proc sort data=exam1;
 by shareid;
run;

data exam1_all(drop=cvdt);
 length hxcvd $3;
 merge exam1
       calcvar1
       dmdat1
       survcvd
       survstk
       survdth
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam1_all(drop=midt);
 length hxmi $3;
 merge exam1_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam1_all(drop=hrtdt);
 length hxhrtd $3;
 merge exam1_all
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

/* Exam 2 - vitals, meds */
data exam2(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib educlev anycholmed nonstatin insulin);
 set in1.pht000031_v9_ex1_2s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype b24 b26 b25 b27 b43 b61 b68 b269)
     in2.pht000031_v9_ex1_2s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype b24 b26 b25 b27 b43 b61 b68 b269);

 if b61=1 then do;
  anycholmed=1; nonstatin=1;
 end;
  else do;
   anycholmed=0; nonstatin=0;
  end;

 if b68 in (1,2) then insulin=1;
  else insulin=0;

 if (. < b43 < 12) then educlev=1;
  else if b43 = 12 then educlev=2;
  else if (12 < b43 < 16) then educlev=3;
  else if b43 >= 16 then educlev=4;

 rename b24=sysbp1 b26=sysbp2 b25=diabp1 b27=diabp2 b269=afib;

 format educlev educf.;

run;

proc sort data=exam2;
 by shareid;
run;

data exam2_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam2
       calcvar2
       dmdat2
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam2_all(drop=midt);
 length hxmi $3;
 merge exam2_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam2_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam2_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

/* Exam 3 - vitals, meds */
data exam3(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib anycholmed nonstatin insulin);
 set in1.pht000032_v8_ex1_3s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype c184 c286 c185 c287 c26 c29 c302)
     in2.pht000032_v8_ex1_3s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype c184 c286 c185 c287 c26 c29 c302);

 if c26=1 then do;
  anycholmed=1; nonstatin=1;
 end;
  else do;
   anycholmed=0; nonstatin=0;
  end;

 if c29=1 then insulin=1;
  else insulin=0;

 rename c184=sysbp1 c286=sysbp2 c185=diabp1 c287=diabp2 c302=afib;

run;

proc sort data=exam3;
 by shareid;
run;

data exam3_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam3
       calcvar3
       dmdat3
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam3_all(drop=midt);
 length hxmi $3;
 merge exam3_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam3_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam3_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

/* Exam 4 - vitals, meds */
data exam4(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib anycholmed nonstatin insulin);
 set in1.pht000033_v10_ex1_4s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype d192 d288 d193 d289 d030 d035 d306)
     in2.pht000033_v10_ex1_4s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype d192 d288 d193 d289 d030 d035 d306);

 if d030=1 then do;
  anycholmed=1; nonstatin=1;
 end;
  else do;
   anycholmed=0; nonstatin=0;
  end;

 if d035=1 then insulin=1;
  else insulin=0;

 rename d192=sysbp1 d288=sysbp2 d193=diabp1 d289=diabp2 d306=afib;

run;

proc sort data=exam4;
 by shareid;
run;

data exam4_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam4
       calcvar4
       dmdat4
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam4_all(drop=midt);
 length hxmi $3;
 merge exam4_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam4_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam4_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

/* Exam 5 - vitals, meds */
data exam5(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib anycholmed nonstatin statin insulin aspirin genhlth);
 set in1.pht000034_v9_ex1_5s(where=(idtype=1)
                             keep=dbGaP_Subject_ID shareid idtype e485 e581 e486 e582 e247 e246 e249 e245 e248 e254 e218 e219 e589 e065)
     in2.pht000034_v9_ex1_5s(where=(idtype=1)
                             keep=dbGaP_Subject_ID shareid idtype e485 e581 e486 e582 e247 e246 e249 e245 e248 e254 e218 e219 e589 e065);

 if e247=1 or e246=1 or e249=1 or e245=1 or e248=1 then anycholmed=1;
  else anycholmed=0;

 if e247=1 or e246=1 or e249=1 or e245=1 then nonstatin=1;
  else nonstatin=0;

 if e248=1 then statin=1;
  else statin=0;

 if e254=1 then insulin=1;
  else insulin=0;

 /* aspirin:  e218=quantity, e219=1(day), 2(week), 3(month) */
 if (e218>=1 and e219=1) or (e218>=5 and e219=2) or (e218>=20 and e219=3) then aspirin=1;
  else aspirin=0;

 if e589=6 then afib=1;
  else if e589 ne . then afib=0;

 rename e485=sysbp1 e581=sysbp2 e486=diabp1 e582=diabp2 e065=genhlth;
 format e065 genhel.;

run;

proc sort data=exam5;
 by shareid;
run;

data exam5_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam5
       calcvar5
       dmdat5
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam5_all(drop=midt);
 length hxmi $3;
 merge exam5_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam5_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam5_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

/* Exam 6 - vitals, meds */
data exam6(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib anycholmed nonstatin statin insulin aspirin genhlth);
 set in1.pht000035_v10_ex1_6s(where=(idtype=1)
                              keep=dbGaP_Subject_ID shareid idtype f476 f576 f477 f577 f211 f210 f213 f209 f212 f218 f181 f182 f584 f087)
     in2.pht000035_v10_ex1_6s(where=(idtype=1)
                              keep=dbGaP_Subject_ID shareid idtype f476 f576 f477 f577 f211 f210 f213 f209 f212 f218 f181 f182 f584 f087);

 if f211=1 or f210=1 or f213=1 or f209=1 or f212=1 then anycholmed=1;
  else anycholmed=0;

 if f211=1 or f210=1 or f213=1 or f209=1 then nonstatin=1;
  else nonstatin=0;

 if f212=1 then statin=1;
  else statin=0;

 if f218=1 then insulin=1;
  else insulin=0;

 /* aspirin:  f181=quantity, f182=1(day), 2(week), 3(month) */
 if (f181>=1 and f182=1) or (f181>=5 and f182=2) or (f181>=20 and f182=3) then aspirin=1;
  else aspirin=0;

 if f584=6 then afib=1;
  else if f584 ne . then afib=0;

 rename f476=sysbp1 f576=sysbp2 f477=diabp1 f577=diabp2 f087=genhlth;
 format f087 genhel.;

run;

proc sort data=exam6;
 by shareid;
run;

data exam6_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam6
       calcvar6
       dmdat6
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam6_all(drop=midt);
 length hxmi $3;
 merge exam6_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam6_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam6_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

/* Exam 7 - vitals, meds */
data exam7(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib anycholmed nonstatin statin insulin aspirin genhlth);
 set in1.pht000036_v10_ex1_7s(where=(idtype=1)
                              keep=dbGaP_Subject_ID shareid idtype g271 g354 g272 g355 g043 g042 g045 g041 g044 g050 g038 g039 g362 g514)
     in2.pht000036_v10_ex1_7s(where=(idtype=1)
                              keep=dbGaP_Subject_ID shareid idtype g271 g354 g272 g355 g043 g042 g045 g041 g044 g050 g038 g039 g362 g514);

 if g043=1 or g042=1 or g045=1 or g041=1 or g044=1 then anycholmed=1;
  else anycholmed=0;

 if g043=1 or g042=1 or g045=1 or g041=1 then nonstatin=1;
  else nonstatin=0;

 if g044=1 then statin=1;
  else statin=0;

 if g050=1 then insulin=1;
  else insulin=0;

 /* aspirin:  g038=quantity, g039=1(day), 2(week), 3(month) */
 if (g038>=1 and g039=1) or (g038>=5 and g039=2) or (g038>=20 and g039=3) then aspirin=1;
  else aspirin=0;

 if g362=6 then afib=1;
  else if g362 ne . then afib=0;

 rename g271=sysbp1 g354=sysbp2 g272=diabp1 g355=diabp2 g514=genhlth;
 format g514 genhel.;

run;

proc sort data=exam7;
 by shareid;
run;

data exam7_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam7
       calcvar7
       dmdat7
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam7_all(drop=midt);
 length hxmi $3;
 merge exam7_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam7_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam7_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

/* Exam 8 - vitals */
data exam8(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib hxdiab aspirin genhlth2);
 set in1.pht000747_v7_ex1_8s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype h111 h233 h112 h234 h016 h011 h012 h309 h714)
     in2.pht000747_v7_ex1_8s(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype h111 h233 h112 h234 h016 h011 h012 h309 h714);

 if h016=1 then hxdiab=1;
  else hxdiab=0;

 /* aspirin:  h011=quantity, h012=1(day), 2(week), 3(month) */
 if (h011>=1 and h012=1) or (h011>=5 and h012=2) or (h011>=20 and h012=3) then aspirin=1;
  else aspirin=0;

 if h309=6 then afib=1;
  else if h309 ne . then afib=0;

 if h714=0 then genhlth2=5;
  else if h714=1 then genhlth2=4;
  else if h714=2 then genhlth2=3;
  else if h714=3 then genhlth2=2;
  else if h714=4 then genhlth2=1;

 rename h111=sysbp1 h233=sysbp2 h112=diabp1 h234=diabp2;
 format genhlth2 genhelb.;

run;

proc sort data=exam8;
 by shareid;
run;


/* Exam 8 - meds */
data exam8_meds(drop=idtype atc_cod1-atc_cod4);
 length medtyp $20 medname $25;
 set in1.pht000828_v7_meds1_8s(where=(idtype=1) keep=shareid idtype medname atc_cod1-atc_cod4)
     in2.pht000828_v7_meds1_8s(where=(idtype=1) keep=shareid idtype medname atc_cod1-atc_cod4);


 if substr(atc_cod1,1,5) in ('C10AA','C10BA','C10BX') or
    substr(atc_cod2,1,5) in ('C10AA','C10BA','C10BX') or
    substr(atc_cod3,1,5) in ('C10AA','C10BA','C10BX') or
    substr(atc_cod4,1,5) in ('C10AA','C10BA','C10BX') then medtyp='statin';

 if substr(atc_cod1,1,5) in ('C10AB','C10AC','C10AD','C10AX') or
    substr(atc_cod2,1,5) in ('C10AB','C10AC','C10AD','C10AX') or
    substr(atc_cod3,1,5) in ('C10AB','C10AC','C10AD','C10AX') or
    substr(atc_cod4,1,5) in ('C10AB','C10AC','C10AD','C10AX') then medtyp='nonstatin';


 if substr(atc_cod1,1,4) in ('A10A') or
    substr(atc_cod2,1,4) in ('A10A') or
    substr(atc_cod3,1,4) in ('A10A') or
    substr(atc_cod4,1,4) in ('A10A') then medtyp='insulin';

 if substr(atc_cod1,1,7) in ('B01AC06') or
    substr(atc_cod2,1,7) in ('B01AC06') or
    substr(atc_cod3,1,7) in ('B01AC06') or
    substr(atc_cod4,1,7) in ('B01AC06') then medtyp='aspirin2';

 if atc_cod1='C10AX09' and atc_cod2='C10AA01' then do;
   medtyp='nonstatin/statin';
   medname='EZETIMIBE/SIMVASTATIN';
 end;

 if medtyp in ('statin','nonstatin','insulin','aspirin2','nonstatin/statin');

 /*if medname=' ' then medname='MISSING';*/

run;

proc sort data=exam8_meds nodupkey;
 by shareid medtyp medname;
run;


data exam8_medpat(keep=shareid cnt_statin cnt_nonstat cnt_anychol cnt_insul cnt_asp cnt_statnonstat statin_names nonstat_names insul_names statnonstat_names);
 length statin_names nonstat_names insul_names statnonstat_names $100;
 set exam8_meds;
 by shareid medtyp;
 retain cnt_statin cnt_nonstat cnt_anychol cnt_insul cnt_asp cnt_statnonstat
        stat_name1-stat_name3 nonstat_name1-nonstat_name3 insul_name1-insul_name3;

 if first.shareid then do;
   cnt_statin=0; statin_names=' ';
   cnt_nonstat=0; nonstat_names=' ';
   cnt_anychol=0;
   cnt_insul=0; insul_names=' ';
   cnt_asp=0;
   cnt_statnonstat=0; statnonstat_names=' ';
 end;

 if medtyp='statin' then do;
  cnt_statin+1;
  if cnt_statin=1 then stat_name1=medname;
   else if cnt_statin=2 then stat_name2=medname;
   else if cnt_statin=3 then stat_name3=medname;
 end;

 if medtyp='nonstatin' then do;
  cnt_nonstat+1;
  if cnt_nonstat=1 then nonstat_name1=medname;
   else if cnt_nonstat=2 then nonstat_name2=medname;
   else if cnt_nonstat=3 then nonstat_name3=medname;
 end;

 if medtyp='insulin' then do;
  cnt_insul+1;
  if cnt_insul=1 then insul_name1=medname;
   else if cnt_insul=2 then insul_name2=medname;
   else if cnt_insul=3 then insul_name3=medname;
 end;

 if medtyp='nonstatin/statin' then cnt_statnonstat+1;

 if medtyp='aspirin2' then cnt_asp=1;

 if last.shareid then do;
  if cnt_statin>=1 or cnt_nonstat>=1 then cnt_anychol=1;

  if cnt_statin=1 then statin_names=stat_name1;
   else if cnt_statin=2 then statin_names=trim(stat_name1) || '|' || trim(stat_name2);
   else if cnt_statin=3 then statin_names=trim(stat_name1) || '|' || trim(stat_name2) || '|' || trim(stat_name3);

  if cnt_nonstat=1 then nonstat_names=nonstat_name1;
   else if cnt_nonstat=2 then nonstat_names=trim(nonstat_name1) || '|' || trim(nonstat_name2);
   else if cnt_nonstat=3 then nonstat_names=trim(nonstat_name1) || '|' || trim(nonstat_name2) || '|' || trim(nonstat_name3);

  if cnt_insul=1 then insul_names=insul_name1;
   else if cnt_insul=2 then insul_names=trim(insul_name1) || '|' || trim(insul_name2);
   else if cnt_insul=3 then insul_names=trim(insul_name1) || '|' || trim(insul_name2) || '|' || trim(insul_name3);

  if cnt_statnonstat>=1 then statnonstat_names='EZETIMIBE/SIMVASTATIN';
  output;
 end;
run;

data exam8_medpat;
 set exam8_medpat;

 if cnt_nonstat>=1 then cnt_nonstat=1;
 if cnt_statin>=1 then cnt_statin=1;
 if cnt_insul>=1 then cnt_insul=1;
 if cnt_statnonstat>=1 then cnt_statnonstat=1;

run;

data exam8(drop=cnt_asp cnt_anychol cnt_nonstat cnt_statin cnt_insul cnt_statnonstat);
 merge exam8 exam8_medpat;
 by shareid;

 if aspirin=1 or cnt_asp=1 then aspirin=1;

 if cnt_anychol=1 then anycholmed=1;
  else anycholmed=0;

 if cnt_nonstat=1 then nonstatin=1;
  else nonstatin=0;

 if cnt_statin=1 then statin=1;
  else statin=0;

 if cnt_insul=1 then insulin=1;
  else insulin=0;

 if cnt_statnonstat=1 then statnonstat=1;
  else statnonstat=0;

run;

data exam8_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam8
       calcvar8
       dmdat8
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam8_all(drop=midt);
 length hxmi $3;
 merge exam8_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam8_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam8_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

proc freq data=exam8_all;
 tables hxcvd hxmi hxhrtd;
 title 'Exam 8';
run;

/* Exam 9 - vitals */
data exam9(keep=shareid sysbp1 sysbp2 diabp1 diabp2 afib hxdiab aspirin genhlth2);
 set in1.pht005140_v3_e_exam_ex09_1b_0844(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype j116 j255 j118 j257 j018 j011 j012 j364 j890)
     in2.pht005140_v3_e_exam_ex09_1b_0844(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype j116 j255 j118 j257 j018 j011 j012 j364 j890);

 if j018=1 then hxdiab=1;
  else hxdiab=0;

 /* aspirin:  j011=quantity, j012=1(day), 2(week), 3(month) */
 if (j011>=1 and j012=1) or (j011>=5 and j012=2) or (j011>=20 and j012=3) then aspirin=1;
  else aspirin=0;

 if j364=6 then afib=1;
  else if j364 ne . then afib=0;

 if j890=0 then genhlth2=5;
  else if j890=1 then genhlth2=4;
  else if j890=2 then genhlth2=3;
  else if j890=3 then genhlth2=2;
  else if j890=4 then genhlth2=1;

 rename j116=sysbp1 j255=sysbp2 j118=diabp1 j257=diabp2;
 format genhlth2 genhelb.;

run;

proc sort data=exam9;
 by shareid;
run;


/* Exam 9 - meds */
data exam9_meds(drop=idtype atc_cod1-atc_cod4);
 length medtyp $20 medname $25;
 set in1.pht004810_v3_vr_meds_ex09_1b_087(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype medname atc_cod1-atc_cod4)
     in2.pht004810_v3_vr_meds_ex09_1b_087(where=(idtype=1) keep=dbGaP_Subject_ID shareid idtype medname atc_cod1-atc_cod4);


 if substr(atc_cod1,1,5) in ('C10AA','C10BA','C10BX') or
    substr(atc_cod2,1,5) in ('C10AA','C10BA','C10BX') or
    substr(atc_cod3,1,5) in ('C10AA','C10BA','C10BX') or
    substr(atc_cod4,1,5) in ('C10AA','C10BA','C10BX') then medtyp='statin';

 if substr(atc_cod1,1,5) in ('C10AB','C10AC','C10AD','C10AX') or
    substr(atc_cod2,1,5) in ('C10AB','C10AC','C10AD','C10AX') or
    substr(atc_cod3,1,5) in ('C10AB','C10AC','C10AD','C10AX') or
    substr(atc_cod4,1,5) in ('C10AB','C10AC','C10AD','C10AX') then medtyp='nonstatin';


 if substr(atc_cod1,1,4) in ('A10A') or
    substr(atc_cod2,1,4) in ('A10A') or
    substr(atc_cod3,1,4) in ('A10A') or
    substr(atc_cod4,1,4) in ('A10A') then medtyp='insulin';

 if substr(atc_cod1,1,7) in ('B01AC06') or
    substr(atc_cod2,1,7) in ('B01AC06') or
    substr(atc_cod3,1,7) in ('B01AC06') or
    substr(atc_cod4,1,7) in ('B01AC06') then medtyp='aspirin2';

 if atc_cod1='C10AX09' and atc_cod2='C10AA01' then do;
   medtyp='nonstatin/statin';
   medname='EZETIMIBE/SIMVASTATIN';
 end;

 if medtyp in ('statin','nonstatin','insulin','aspirin2','nonstatin/statin');

 /*if medname=' ' then medname='MISSING';*/

run;

proc sort data=exam9_meds nodupkey;
 by shareid medtyp medname;
run;


data exam9_medpat(keep=shareid cnt_statin cnt_nonstat cnt_anychol cnt_insul cnt_asp cnt_statnonstat statin_names nonstat_names insul_names statnonstat_names);
 length statin_names nonstat_names insul_names statnonstat_names $100;
 set exam9_meds;
 by shareid medtyp;
 retain cnt_statin cnt_nonstat cnt_anychol cnt_insul cnt_asp cnt_statnonstat
        stat_name1-stat_name4 nonstat_name1-nonstat_name4 insul_name1-insul_name4;

 if first.shareid then do;
   cnt_statin=0; statin_names=' ';
   cnt_nonstat=0; nonstat_names=' ';
   cnt_anychol=0;
   cnt_insul=0; insul_names=' ';
   cnt_asp=0;
   cnt_statnonstat=0; statnonstat_names=' ';
 end;

 if medtyp='statin' then do;
  cnt_statin+1;
  if cnt_statin=1 then stat_name1=medname;
   else if cnt_statin=2 then stat_name2=medname;
   else if cnt_statin=3 then stat_name3=medname;
   else if cnt_statin=4 then stat_name4=medname;
 end;

 if medtyp='nonstatin' then do;
  cnt_nonstat+1;
  if cnt_nonstat=1 then nonstat_name1=medname;
   else if cnt_nonstat=2 then nonstat_name2=medname;
   else if cnt_nonstat=3 then nonstat_name3=medname;
   else if cnt_nonstat=4 then nonstat_name4=medname;
 end;

 if medtyp='insulin' then do;
  cnt_insul+1;
  if cnt_insul=1 then insul_name1=medname;
   else if cnt_insul=2 then insul_name2=medname;
   else if cnt_insul=3 then insul_name3=medname;
   else if cnt_insul=4 then insul_name4=medname;
 end;

 if medtyp='nonstatin/statin' then cnt_statnonstat+1;

 if medtyp='aspirin2' then cnt_asp=1;

 if last.shareid then do;
  if cnt_statin>=1 or cnt_nonstat>=1 then cnt_anychol=1;

  if cnt_statin=1 then statin_names=stat_name1;
   else if cnt_statin=2 then statin_names=trim(stat_name1) || '|' || trim(stat_name2);
   else if cnt_statin=3 then statin_names=trim(stat_name1) || '|' || trim(stat_name2) || '|' || trim(stat_name3);
   else if cnt_statin=4 then statin_names=trim(stat_name1) || '|' || trim(stat_name2) || '|' || trim(stat_name3) || '|' || trim(stat_name4);

  if cnt_nonstat=1 then nonstat_names=nonstat_name1;
   else if cnt_nonstat=2 then nonstat_names=trim(nonstat_name1) || '|' || trim(nonstat_name2);
   else if cnt_nonstat=3 then nonstat_names=trim(nonstat_name1) || '|' || trim(nonstat_name2) || '|' || trim(nonstat_name3);
   else if cnt_nonstat=4 then nonstat_names=trim(nonstat_name1) || '|' || trim(nonstat_name2) || '|' || trim(nonstat_name3) || '|' || trim(nonstat_name4);

  if cnt_insul=1 then insul_names=insul_name1;
   else if cnt_insul=2 then insul_names=trim(insul_name1) || '|' || trim(insul_name2);
   else if cnt_insul=3 then insul_names=trim(insul_name1) || '|' || trim(insul_name2) || '|' || trim(insul_name3);
   else if cnt_insul=4 then insul_names=trim(insul_name1) || '|' || trim(insul_name2) || '|' || trim(insul_name3) || '|' || trim(insul_name4);

  if cnt_statnonstat>=1 then statnonstat_names='EZETIMIBE/SIMVASTATIN';
  output;
 end;
run;

data exam9_medpat;
 set exam9_medpat;

 if cnt_nonstat>=1 then cnt_nonstat=1;
 if cnt_statin>=1 then cnt_statin=1;
 if cnt_insul>=1 then cnt_insul=1;
 if cnt_statnonstat>=1 then cnt_statnonstat=1;

run;

data exam9(drop=cnt_asp cnt_anychol cnt_nonstat cnt_statin cnt_insul cnt_statnonstat);
 merge exam9 exam9_medpat;
 by shareid;

 if aspirin=1 or cnt_asp=1 then aspirin=1;

 if cnt_anychol=1 then anycholmed=1;
  else anycholmed=0;

 if cnt_nonstat=1 then nonstatin=1;
  else nonstatin=0;

 if cnt_statin=1 then statin=1;
  else statin=0;

 if cnt_insul=1 then insulin=1;
  else insulin=0;

 if cnt_statnonstat=1 then statnonstat=1;
  else statnonstat=0;

run;

data exam9_all(drop=cvdt base_cvd);
 length hxcvd $3;
 merge exam9
       calcvar9
       dmdat9
       survcvd
       cvdisease;

 by shareid;

 if first.shareid then hxcvd="NO";
 retain hxcvd;

 if (. < cvdt <= visday) or base_cvd="YES" then hxcvd="YES";

 if last.shareid then output;

run;

data exam9_all(drop=midt);
 length hxmi $3;
 merge exam9_all
       hxmi;

 by shareid;

 if first.shareid then hxmi="NO";
 retain hxmi;

 if (. < midt <= visday) then hxmi="YES";

 if last.shareid then output;

run;

data exam9_all(drop=hrtdt base_cvd);
 length hxhrtd $3;
 merge exam9_all
       survcvd
       allhrtdis;

 by shareid;

 if first.shareid then hxhrtd="NO";
 retain hxhrtd;

 if (. < hrtdt <= visday) or base_cvd="YES" then hxhrtd="YES";

 if last.shareid then output;

run;

proc freq data=exam9_all;
 tables hxcvd hxmi hxhrtd;
 title 'Exam 9';
run;


/********************************************/
/* Merge in New Variables for exams 3, 6, 8 */
/********************************************/
data exam3_all;
 merge exam3_all(in=a)
       valvdis_v3(keep=shareid valvdis carsten)
       income_v3(keep=shareid fam_income)
       alco_v3(keep=shareid alcohol)
       fruveg_v3(keep=shareid fruits vegetables)
       pai_v3;

 by shareid;
 if a;

 state = 'MA';

 label valvdis = 'Valvular heart disease (0=No, 1=Yes)'
       carsten = 'Carotid stenosis (0=No, 1=Yes)'
       fam_income = 'Family income'
       alcohol = 'Alcohol (servings per week)'
       fruits = 'Fruits (servings per week)'
       vegetables = 'Vegetables (servings per week)'
       state = 'Site location (state)'
       inactivity = 'Physical inactivity (0=No, 1=Yes)'
       activity = 'Physical activity (3-levels)'
       activity_alt = 'Physical activity, alternate (3-levels)';

run;


data exam6_all;
 merge exam6_all(in=a)
       fhstroke_v6(keep=shareid fh_stroke)
       hsod_v6(keep=shareid sodium)
       valvdis_v6(keep=shareid valvdis carsten)
       alco_v6(keep=shareid alcohol)
       fruveg_v6(keep=shareid fruits vegetables)
       pai_v6;

 by shareid;
 if a;

 state = 'MA';

 label fh_stroke = 'Family history of stroke, Mother or Father (0=No, 1=Yes)'
       valvdis = 'Valvular heart disease (0=No, 1=Yes)'
       carsten = 'Carotid stenosis (0=No, 1=Yes)'
       sodium = 'Sodium intake (mg/day)'
       alcohol = 'Alcohol (servings per week)'
       fruits = 'Fruits (servings per week)'
       vegetables = 'Vegetables (servings per week)'
       state = 'Site location (state)'
       inactivity = 'Physical inactivity (0=No, 1=Yes)'
       activity = 'Physical activity (3-levels)'
       activity_alt = 'Physical activity, alternate (3-levels)';

run;


data exam8_all;
 merge exam8_all(in=a)
       hsod_v8(keep=shareid sodium)
       valvdis_v8(keep=shareid valvdis carsten)
       alco_v8(keep=shareid alcohol)
       fruveg_v8(keep=shareid fruits vegetables)
       pai_v8;

 by shareid;
 if a;

 state = 'MA';

 label valvdis = 'Valvular heart disease (0=No, 1=Yes)'
       carsten = 'Carotid stenosis (0=No, 1=Yes)'
       sodium = 'Sodium intake (mg/day)'
       alcohol = 'Alcohol (servings per week)'
       fruits = 'Fruits (servings per week)'
       vegetables = 'Vegetables (servings per week)'
       state = 'Site location (state)'
       inactivity = 'Physical inactivity (0=No, 1=Yes)'
       activity = 'Physical activity (3-levels)'
       activity_alt = 'Physical activity, alternate (3-levels)';

run;


/* Combine all data */
data pheno_fram_offspring(drop=/*dmrx*/ hxdiab sex hgt);
 length race_c $20;
 set exam1_all
     exam2_all
     exam3_all
     exam4_all
     exam5_all
     exam6_all
     exam7_all
     exam8_all
     exam9_all;

 /* Hardcode the RACE_C variable */

  race_c = 'White';

  if sex_c='F' then sex_n=0;
   else if sex_c='M' then sex_n=1;

  hgt_cm = round((hgt*2.54),.01);

 label afib = 'Atrial fibrillation'
       age = 'Age (years)'
       anycholmed = 'Taking any cholesterol medication (statin or non-statin) (0=No, 1=Yes)'
       aspirin = 'Taking aspirin (0=No, 1=Yes)'
       base_cvd = 'Baseline CVD'
       base_stroke = 'Baseline Stroke/TIA (0=No, 1=TIA, 2=Stroke)'
       bg = 'Blood glucose (mg/dL) (includes fasting and non-fasting)'
       bmi = 'Body mass index (kg/m2)'
       censday = 'Censor day'
       creat = 'Creatinine (mg/dL)'
       currsmk = 'Current smoking status (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       death_ind = 'Death indicator'
       diab = 'Diabetes Mellitus Status (Source: Calculated) (0=No, 1=Yes)'
       diabp1 = 'PHYSICIAN DIASTOLIC BLOOD PRESSURE, FIRST (MM HG)'
       diabp2 = 'PHYSICIAN DIASTOLIC BLOOD PRESSURE, SECOND (MM HG)'
       educlev = 'Education level (1=Less than High School, 2=High School, 3=Some College, 4=College)'
       fasting_bg = 'Fasting blood glucose (>: 8 hours) (mg/dL)'
       genhlth = 'General Health (Exams 5-7, 4-category)'
       genhlth2 = 'General Health (Exams 8-9, 5-category)'
       hdl = 'HDL cholesterol (mg/dL)'
       hgt_cm = 'Height (centimeters)'
       hrx = 'Treated for hypertension (0=No, 1=Yes)'
       hxcvd = 'History of cardiovascular disease'
       hxmi = 'History of MI'
       hxhrtd = 'History of heart disease'
       insul_names = 'Insulin medication names'
       insulin = 'Taking insulin (0=No, 1=Yes)'
       lvh = 'Left ventricular hypertrophy on ECG'
       nonstat_names = 'Non-statin names'
       nonstatin = 'Taking non-statin medication (0=No, 1=Yes)'
       race_c = 'Race'
       sex_n = 'Participant gender (1=Male, 0=Female)'
       sex_c = 'Participant gender (character)'
       shareid = 'UNIQUE PARTICIPANT ID'
       statin = 'Taking statin medication (0=No, 1=Yes)'
       statin_names = 'Statin names'
       statnonstat = 'Taking non-statin/statin combination'
       statnonstat_names = 'Non-statin/statin names'
       sysbp1 = 'PHYSICIAN SYSTOLIC BLOOD PRESSURE, FIRST (MM HG)'
       sysbp2 = 'PHYSICIAN SYSTOLIC BLOOD PRESSURE, SECOND (MM HG)'
       tc = 'Total cholesterol (mg/dL)'
       trig = 'Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wgt = 'Weight (lbs)'
       ;

 /*if visday ne . then realvis='Y';
   else if visday=. then realvis='N';*/


run;


proc contents data=pheno_fram_offspring;
run;

proc sort data=pheno_fram_offspring;
 by shareid visit;
run;

options validvarname=upcase;
data out1.pheno_fram_offspring;
 set pheno_fram_offspring;
 by shareid visit;

run;

proc export data=pheno_fram_offspring
            outfile="/data/framingham/analdata/pheno_fram_offspring.csv"
            dbms=csv
            replace;
run;

ods rtf file="/data/framingham/analdata/pheno_fram_offspring_contents.rtf";

proc contents data=out1.pheno_fram_offspring;
run;

ods rtf close;
