/* ----------------------------------------------------------------------------------------------------------------------
   $Author: js463 $
   $Date: 2021/12/08 14:59:20 $
   $Source: /data/regards/programs/RCS/pull_regards.sas,v $

   Purpose: Create Phenotype visit file and events file for REGARDS.

   Assumptions: Source datasets exist

   Outputs: /data/framingham/analdata/pheno_fram_offspring.sas7bdat
            /data/framingham/analdata/events_fram_offspring.sas7bdat

   ---------------------------------------------------------------------------------------------------------------------
   Modification History
   ---------------------------------------------------------------------------------------------------------------------
   $Log: pull_regards.sas,v $
   Revision 1.1  2021/12/08 14:59:20  js463
   Initial revision

   ---------------------------------------------------------------------------------------------------------------------
*/

libname in1 '/data/regards/data' access=readonly;

libname out1 '/data/regards/analdata';


proc freq data=in1.baseline_calculated_variables;
 tables stroke_sr tia_sr Exercise_cat / list missing;
run;

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
  2 = '$5,000 to $9,000'
  5 = '$10,000 to $14,000'
  7 = '$15,000 to $19,000'
  10 = '$20,000 to $24,000'
  12 = '$25,000 to $34,000'
  15 = '$35,000 to $49,000'
  20 = '$50,000 to $74,000'
  23 = '$75,000 to $149,000'
  24 = 'more than $150,000';

 value active
  1 = 'Inactive'
  2 = 'Slightly active'
  3 = 'Active';

run;

proc contents data=in1.baseline_calculated_variables;
run;

data base_v1(drop=race weight_kg height smoke fasted lipidemia_sr_meds reg_asa diabetes_meds_sr_insulin ed_cat lvh_12 gen_sr_health
                  Diabetes_SR Diab_SRMed_glu Hyper_Meds_SR_now CAD_SR_ECG PAD_amputation PAD_surgery DVT_SR Hyper_SR
                  MI_SR_ECG MI_SR AFib_ECG Afib_SR Income Exercise_cat);
 set in1.baseline_calculated_variables(keep=id age gender race weight_kg height bmi sbp dbp smoke cholest hdl trigly ldl glucose fasted
                                            creatinine_serum lipidemia_sr_meds reg_asa diabetes_meds_sr_insulin ed_cat lvh_12 gen_sr_health
                                            Diabetes_SR Diab_SRMed_glu Hyper_Meds_SR_now CAD_SR_ECG Stroke_SR TIA_SR PAD_amputation
                                            PAD_surgery DVT_SR MI_SR_ECG MI_SR AFib_ECG Afib_SR Alc_Drinks_Wk Income Hyper_SR
                                            InHomeDate state Exercise_cat);

  if race='B' then race_c='Black';
   else if race='W' then race_c='White';

  if gender='F' then sex_n=0;
   else if gender='M' then sex_n=1;

  /* convert weight from KG to LBS, for consistency with other studies */
  wgt = round((weight_kg * 2.20462),1);

  /* convert height from IN to CM, for consistency with other studies */
  hgt_cm = floor(height * 2.54);

  if Diabetes_SR='Y' or Diab_SRMed_glu='Y' then diab=1;
   else if Diabetes_SR='N' then diab=0;

  if Hyper_Meds_SR_now='Y' then hrx=1;
   else if Hyper_Meds_SR_now='N' then hrx=0;

  if CAD_SR_ECG='Y' then hxhrtd='YES';
   else if CAD_SR_ECG='N' then hxhrtd='NO';

  if CAD_SR_ECG='Y' or Stroke_SR='Y' or TIA_SR='Y' then hxcvd='YES';
   else if CAD_SR_ECG='N' and Stroke_SR='N' and TIA_SR='N' then hxcvd='NO';

  if PAD_amputation='Y' or PAD_surgery='Y' or DVT_SR='Y' then hxpad='YES';
   else if PAD_amputation='N' and PAD_surgery='N' and DVT_SR='N' then hxpad='NO';

  if MI_SR_ECG='Y' then hxmi=1;
   else if MI_SR_ECG='N' then hxmi=0;

  if MI_SR='Y' then hxmi_sr=1;
   else if MI_SR='N' then hxmi_sr=0;

  if AFib_ECG='Y' or Afib_SR='Y' then afib=1;
   else if AFib_ECG='N' and Afib_SR='N' then afib=0;

  if smoke='Current' then currsmk=1;
   else if smoke in ('Never','Past') then currsmk=0;

  if fasted='Y' then fasting=1;
   else if fasted='N' then fasting=0;

  if lipidemia_sr_meds='N' then anycholmed=0;
   else if lipidemia_sr_meds='Y' then anycholmed=1;

  if reg_asa='N' then aspirin=0;
   else if reg_asa='Y' then aspirin=1;

  if diabetes_meds_sr_insulin='N' then insulin=0;
   else if diabetes_meds_sr_insulin='Y' then insulin=1;

  if lvh_12='No' then lvh=0;
   else if lvh_12='Yes' then lvh=1;

 if ed_cat='Less than high school' then educlev=1;
  else if ed_cat='High school graduate' then educlev=2;
  else if ed_cat='Some college' then educlev=3;
  else if ed_cat='College graduate and above' then educlev=4;

 if gen_sr_health='Excellent' then genhlth2=1;
  else if gen_sr_health='Very good' then genhlth2=2;
  else if gen_sr_health='Good' then genhlth2=3;
  else if gen_sr_health='Fair' then genhlth2=4;
  else if gen_sr_health='Poor' then genhlth2=5;

 if income=1 then fam_income=1;
  else if income=2 then fam_income=2;
  else if income=3 then fam_income=5;
  else if income=4 then fam_income=7;
  else if income=5 then fam_income=10;
  else if income=6 then fam_income=12;
  else if income=7 then fam_income=15;
  else if income=8 then fam_income=20;
  else if income=9 then fam_income=23;   /* add 75K - 150K, code as 23 */
  else if income=10 then fam_income=24;  /* add > 150K, code as 24 */

 if Stroke_SR='Y' then base_stroke=1;
  else if Stroke_SR='N' then base_stroke=0;

 if TIA_SR='Y' then hxtia=1;
  else if TIA_SR='N' then hxtia=0;

 if AFib_SR='Y' then afib_sr2=1;
  else if AFib_SR='N' then afib_sr2=0;

 if Hyper_SR="Y" then hyper_sr2=1;
  else if Hyper_SR="N" then hyper_sr2=0;

 if Diabetes_SR="Y" then diab_sr2=1;
  else if Diabetes_SR="N" then diab_sr2=0;

 if Exercise_cat="None" then inactivity=1;
  else if Exercise_cat ne " " then inactivity=0;

 if Exercise_cat="None" then activity=1;
  else if Exercise_cat="1 to 3 time per week" then activity=2;
  else if Exercise_cat="4 or more per week" then activity=3;



  rename gender=sex_c
         sbp=sysbp
         dbp=diabp
         cholest=tc
         trigly=trig
         creatinine_serum=creat
         Alc_Drinks_Wk=alcohol;


  label race_c = 'Race'
        wgt = 'Weight (lbs)'
        hgt_cm = 'Height (centimeters)'
        diab = 'Diabetes Mellitus Status (0=No, 1=Yes)'
        diab_sr2 = 'Self-reported Diabetes Mellitus Status (0=No, 1=Yes)'
        hrx = 'Treated for hypertension (0=No, 1=Yes)'
        hyper_sr2 = 'Self-reported Hypertension (0=No, 1=Yes)'
        hxhrtd = 'History of Heart Disease (self-reported MI, CABG, bypass, angioplasty, or stenting OR evidence of MI via ECG)'
        hxcvd = 'History of cardiovascular disease'
        hxpad = 'History of PAD'
        hxmi = 'History of Myocardial Infarction (0=No, 1=Yes)'
        hxmi_sr = 'History of Myocardial Infarction, self-reported (0=No, 1=Yes)'
        afib = 'Atrial fibrillation (0=No, 1=Yes)'
        afib_sr2 = 'Self-reported Atrial fibrillation (0=No, 1=Yes)'
        id = 'REGARDS subject ID'
        age = 'Age'
        gender = 'Participant gender (character)'
        sex_n = 'Participant gender (0=Female, 1=Male)'
        bmi = 'Body mass index (kg/m2)'
        sbp = 'Systolic blood pressure (MM HG)'
        dbp = 'Diastolic blood pressure (MM HG)'
        cholest = 'Total cholesterol (mg/dL)'
        hdl = 'HDL cholesterol'
        trigly = 'Total Triglycerides (mg/dL)'
        ldl = 'LDL cholesterol'
        glucose = 'Glucose (mg/dL)'
        currsmk = 'Current smoking status (0=No, 1=Yes)'
        fasting = 'Fasting status (0=No, 1=Yes)'
        creatinine_serum = 'Creatinine (mg/dL)'
        anycholmed = 'Taking cholesterol lowering medication (0=No, 1=Yes)'
        aspirin = 'Taking aspirin (0=No, 1=Yes)'
        insulin = 'Taking insulin (0=No, 1=Yes)'
        lvh = 'Left ventricular hypertrophy on ECG'
        educlev = 'Education level (1=Less than High School, 2=High School, 3=Some College, 4=College)'
        genhlth2 = 'General Health (5 levels)'
        Alc_Drinks_Wk = 'Alcohol (servings per week)'
        fam_income = 'Family income'
        base_stroke = 'Participant reported stroke at baseline'
        hxtia = 'Participant reported TIA at baseline'
        state = 'State of residence at baseline'
        inactivity = 'Physical inactivity (0=No, 1=Yes)'
        activity = 'Physical activity (3-levels)';

 format educlev educf. genhlth2 genhelb. fam_income faminc. activity active.;

run;

proc sort data=in1.baseline_meds out=bmeds(keep=id meds_statin) nodupkey;
 by id;
run;

proc sort data=in1.family_history out=famhist(keep=id dadstroke momstroke) nodupkey;
 by id;
run;

proc freq data=famhist;
 tables dadstroke*momstroke / list missing;
run;

proc sort data=in1.ffq_analyzed out=ffq(keep=id sodium fruitsrv vegsrv) nodupkey;
 by id;
run;

proc sort data=base_v1;
 by id;
run;

data base_v1(drop=dadstroke momstroke fruitsrv vegsrv);
 merge base_v1(in=a)
       bmeds(in=b)
       famhist(in=c)
       ffq(in=d);
  by id;

 if compress(dadstroke)='Yes' or compress(momstroke)='Yes' then fh_stroke=1;
  else if dadstroke ne ' ' or momstroke ne ' ' then fh_stroke=0;

 fruits = fruitsrv*7;

 vegetables = vegsrv*7;

 rename meds_statin=statin
        id=regards_subj_id;

 label meds_statin = 'Taking statin medication (0=No, 1=Yes)'
       fh_stroke = 'Family history of stroke, Mother or Father (0=No, 1=Yes)'
       sodium = 'Sodium intake (mg/day)'
       fruits = 'Fruits (servings per week)'
       vegetables = 'Vegetables (servings per week)';

run;

/* Bring in stroke events */
/* create stroke evt vars in data, see Daniel's program code */
/* subset final data with base_stroke, hxtia, age */
proc sort data=in1.stroke_outcome(keep=id stroke19 stroke19dt) out=strkevt(rename=(id=regards_subj_id stroke19=stroke));
 by id;
run;

data base_v1;
 merge base_v1(in=a)
       strkevt;
 by regards_subj_id;

 t2stroke = (stroke19dt - inhomedate) + 1;

 t2stroke_yrs = t2stroke / 365.25;

 if stroke=1 and t2stroke_yrs <= 10 then do;
    stroke10=1;
    t2stroke10=t2stroke;
    t2stroke10_yrs=t2stroke_yrs;
 end;

  else do;
     stroke10=0;
     t2stroke10=min(t2stroke,3653);
     if t2stroke_yrs ne . then t2stroke10_yrs=min(t2stroke_yrs,10);
     end;

run;


/* Final data set */
data base_v1(drop=stroke_sr tia_sr inhomedate stroke19dt);
 set base_v1;

 if age<45 or stroke_sr='Y' or tia_sr='Y' then delete;

   label stroke = "Any stroke during follow-up"
         t2stroke = "Time to stroke during follow-up"
         t2stroke_yrs="Time (in years) to Stroke/Censoring"
         stroke10="Any stroke in first 10 years of follow-up"
         t2stroke10="Time to Stroke/Censoring in first 10 years"
         t2stroke10_yrs="Time (in years) to Stroke/Censoring in first 10 years";

run;

/* Output final REGARDS phenotype SAS data set and CSV file */
options validvarname=upcase;
data out1.pheno_regards;
 set base_v1;
 by regards_subj_id;

run;

proc export data=base_v1
            outfile="/data/regards/analdata/pheno_regards.csv"
            dbms=csv
            replace;
run;

ods rtf file="/data/regards/analdata/pheno_regards_contents.rtf";
proc contents data=out1.pheno_regards;
run;

ods rtf close;
