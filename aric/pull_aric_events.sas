/* ----------------------------------------------------------------------------------------------------------------------
   $Author: js463 $
   $Date: 2021/05/19 18:57:12 $
   $Source: /data/aric/dbgap/import_pheno_text/programs/RCS/pull_aric_events.sas,v $

   Purpose: ARIC Events dataset creation for Stroke prediction project.
            All events are "by 2016", except for Afib and Atrial Flutter, which are both "by 2011".

   Assumptions: Source datasets exist

   Outputs: /data/aric/analdata/cv_events.sas7bdat

   ---------------------------------------------------------------------------------------------------------------------
   Modification History

   $Log: pull_aric_events.sas,v $
   Revision 1.1  2021/05/19 18:57:12  js463
   Initial revision





   ---------------------------------------------------------------------------------------------------------------------
*/

libname in1 '/data/aric/dbgap/import_pheno_text/outdata' access=readonly;
libname inq '/dcri/cerner/qubbd/data/aric/dbgap/61083/import_pheno_text/outdata_61083' access=readonly;
libname out1 '/data/aric/analdata';
libname out2 '/dcri/cerner/qubbd/data/aric/analdata';


options nofmterr nonumber nodate nocenter validvarname=upcase;


proc sort data=in1.pht006443_v4_incps16(keep=subject_id fudth16) out=censoring nodupkey;
 by subject_id;
run;

proc sort data=inq.pht006443_v1_incps11(keep=subject_id fudth11) out=censoring2 nodupkey;
 by subject_id;
run;

proc sort data=in1.pht004058_v5_coccps16 out=coccps16;
 by subject_id;
run;

proc sort data=in1.pht004050_v5_cevtps16 out=cevtps16;
 by subject_id;
run;

proc sort data=in1.pht006443_v4_incps16 out=incps16;
 by subject_id;
run;

proc sort data=in1.pht006442_v1_incafps11 out=incafps11;
 by subject_id;
run;

data incafps11;
 merge incafps11 censoring2;
 by subject_id;
run;

* All Cause Hospitalization;
data occ1;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

merge coccps16(in=a) censoring(in=b);
 by subject_id;

if EVTYPE01 = "I" then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, NON CHD-RELATED";
   event_val_c  = "YES";
   if C_CHD = '1' then event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, CHD-RELATED";
   event_t2_o = DDATE0_DAYS;
   output;
end;

if last.subject_id then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, NON CHD-RELATED";
   event_val_c  = "NO";
   if C_CHD = '1' then event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, CHD-RELATED";
   event_t2_o = FUDTH16;
   output;
end;


   keep subject_id event_name_o event_val_c event_t2_o;
run;


data occ2;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

merge coccps16(in=a) censoring(in=b);
 by subject_id;

if EVTYPE01 = "N" then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, NON CHD-RELATED";
   event_val_c  = "YES";
   if C_CHD = '1' then event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, CHD-RELATED";
   event_t2_o = DDATE0_DAYS;
   output;
end;

if last.subject_id then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, NON CHD-RELATED";
   event_val_c  = "NO";
   if C_CHD = '1' then event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, CHD-RELATED";
   event_t2_o = FUDTH16;
   output;
end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;


* CHD related Death;
data chddth;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

merge cevtps16(in=a) censoring(in=b);
 by subject_id;

if CDTHYR ne . then do;
   event_name_o = "CHD-RELATED DEATH";
   event_val_c  = "YES";
   event_t2_o = DTHDATE_DAYS;
   output;
end;

if last.subject_id then do;
   event_name_o = "CHD-RELATED DEATH";
   event_val_c  = "NO";
   event_t2_o = FUDTH16;
   output;
end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* All cause death prior to censor date;
data dth16;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

if DEAD16  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUDTH16;
   event_name_o = "ALL CAUSE DEATH BY 2016";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUDTH16;
   event_name_o = "ALL CAUSE DEATH BY 2016";
 output;
end;

if DEAD16  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH16;
   event_name_o = "ALL CAUSE DEATH BY 2016";
 output;
end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* Hospitalized MI prior to censor date;
data MI16;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

if MI16  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUMI16;
   event_name_o = "MYOCARDIAL INFARCTION (DEFINITE + PROBABLE) BY 2016";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUMI16;
   event_name_o = "MYOCARDIAL INFARCTION (DEFINITE + PROBABLE) BY 2016";
 output;
end;

if MI16  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH16;
   event_name_o = "MYOCARDIAL INFARCTION (DEFINITE + PROBABLE) BY 2016";
 output;
end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* MI or Fatal CHD prior to censor date;
data INC16;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

if INC16  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUINC16;
   event_name_o = "MI OR FATAL CHD BY 2016";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUINC16;
   event_name_o = "MI OR FATAL CHD BY 2016";
 output;
end;

if INC16  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH16;
   event_name_o = "MI OR FATAL CHD BY 2016";
 output;
end;

   keep subject_id  event_name_o event_val_c event_t2_o;
run;

* Incident Heart Failure;
data hf16;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

 if INCHF16  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = C7_FUTIMEHF;
    event_name_o = "INCIDENT HF (FROM DISCHARGE CODES) BY 2016";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = C7_FUTIMEHF;
    event_name_o = "INCIDENT HF (FROM DISCHARGE CODES) BY 2016";
  output;
 end;

 if INCHF16  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH16;
    event_name_o = "INCIDENT HF (FROM DISCHARGE CODES) BY 2016";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* Cardiac Procedures prior to censor date;
data PROC16;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

if PROC16  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUPROC16;
   event_name_o = "CARDIAC PROCEDURES BY 2016";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUPROC16;
   event_name_o = "CARDIAC PROCEDURES BY 2016";
 output;
end;

if PROC16  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH16;
   event_name_o = "CARDIAC PROCEDURES BY 2016";
 output;
end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* Incident Atrial Fibrillation (by 2011);
data af11;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incafps11;

 if AFINCBY11  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FT11AFINC;
    event_name_o = "INCIDENT ATRIAL FIBRILLATION BY 2011";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = FT11AFINC;
    event_name_o = "INCIDENT ATRIAL FIBRILLATION BY 2011";
  output;
 end;

 if AFINCBY11  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH11;
    event_name_o = "INCIDENT ATRIAL FIBRILLATION BY 2011";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* Incident Atrial Flutter (by 2011);
data afL11;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incafps11;

 if AFLINCBY11  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FT11AFLINC;
    event_name_o = "INCIDENT ATRIAL FLUTTER BY 2011";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = FT11AFLINC;
    event_name_o = "INCIDENT ATRIAL FLUTTER BY 2011";
  output;
 end;

 if AFLINCBY11  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH11;
    event_name_o = "INCIDENT ATRIAL FLUTTER BY 2011";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* DEFINITE/PROBABLE Incident Stroke;
data stroke;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

 if INDP16  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FT16DP;
    event_name_o = "DEFINITE/PROBABLE INCIDENT STROKE BY 2016";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = FT16DP;
    event_name_o = "DEFINITE/PROBABLE INCIDENT STROKE BY 2016";
  output;
 end;

 if INDP16  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH16;
    event_name_o = "DEFINITE/PROBABLE INCIDENT STROKE BY 2016";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* DEFINITE/PROBABLE/POSSIBLE Incident Stroke;
data DPP;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

 if INDPP16  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FTDPP16;
    event_name_o = "DEFINITE/PROBABLE/POSSIBLE INCIDENT STROKE BY 2016";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = FTDPP16;
    event_name_o = "DEFINITE/PROBABLE/POSSIBLE INCIDENT STROKE BY 2016";
  output;
 end;

 if INDPP16  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH16;
    event_name_o = "DEFINITE/PROBABLE/POSSIBLE INCIDENT STROKE BY 2016";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* DEFINITE/PROBABLE ISCHEMIC Incident Stroke;
data ISC;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

 if INISC16  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FTISC16;
    event_name_o = "DEFINITE/PROBABLE ISCHEMIC INCIDENT STROKE BY 2016";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = FTISC16;
    event_name_o = "DEFINITE/PROBABLE ISCHEMIC INCIDENT STROKE BY 2016";
  output;
 end;

 if INISC16  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH16;
    event_name_o = "DEFINITE/PROBABLE ISCHEMIC INCIDENT STROKE BY 2016";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* DEFINITE/PROBABLE BRAIN HEMORRHAGIC Incident Stroke;
data HEM;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

 if INHEM16  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FTHEM16;
    event_name_o = "DEFINITE/PROBABLE BRAIN HEMORRHAGIC INCIDENT STROKE BY 2016";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = FTHEM16;
    event_name_o = "DEFINITE/PROBABLE BRAIN HEMORRHAGIC INCIDENT STROKE BY 2016";
  output;
 end;

 if INHEM16  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH16;
    event_name_o = "DEFINITE/PROBABLE BRAIN HEMORRHAGIC INCIDENT STROKE BY 2016";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC Incident Stroke;
data CHM;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

   set incps16;

 if INCHM16  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FT16CHM;
    event_name_o = "DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC INCIDENT STROKE BY 2016";
  output;
 end;

 else do;
    event_val_c  = "NO";
    event_t2_o = FT16CHM;
    event_name_o = "DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC INCIDENT STROKE BY 2016";
  output;
 end;

 if INCHM16  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH16;
    event_name_o = "DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC INCIDENT STROKE BY 2016";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;
run;

* ##### ALL EVENTS DATA #####;
data cvevents;

   set occ1 occ2 chddth dth16 mi16 inc16 hf16 proc16 af11 afL11
   	   stroke dpp isc hem chm;

   label event_t2_o = 'Days since exam 1'
         event_name_o = 'Event/Procedure description'
         event_val_c = 'Event Value (YES/NO)'
         subject_id = 'Unique study participant identification number';

   rename event_name_o = event_desc
          event_t2_o = days_since_exam1;

run;

proc sort data=cvevents;
   by subject_id days_since_exam1;
run;

proc sort data=out1.pheno_aric(keep=DBGAP_SUBJECT_ID subject_id) out=fullpop nodupkey;
by subject_id;
run;

data cvevents;
 merge cvevents(in=a)
       fullpop(in=b);
 by subject_id;

 if a and b;

run;

options validvarname=upcase;
data out1.cv_events;
*data out2.cv_events_update_v2;
 set cvevents;
 by subject_id days_since_exam1;
run;

proc export data=cvevents
            outfile="/data/aric/analdata/cv_events.csv"
            dbms=csv
            replace;
run;


ods rtf file="/data/aric/analdata/cv_events_contents.rtf";

proc contents data=out1.cv_events;
*proc contents data=out2.cv_events_update_v2;
run;
ods rtf close;
