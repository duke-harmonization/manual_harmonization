/* ----------------------------------------------------------------------------------------------------------------------
   $Author:  $
   $Date:  $
   $Source:  $

   Purpose: Create Phenotype CV events file for MESA.

   Assumptions: Source datasets exist

   Outputs: /data/mesa/analdata/cv_events.sas7bdat
            /data/mesa/analdata/cv_events.csv

   ---------------------------------------------------------------------------------------------------------------------
   Modification History
   ---------------------------------------------------------------------------------------------------------------------
   $Log:  $


   ---------------------------------------------------------------------------------------------------------------------
*/

libname in1 '/data/mesa/dbgap/import_pheno_text/outdata' access=readonly;
libname in2 '/data/mesa/dbgap2/import_pheno_text/outdata' access=readonly;

libname out1 '/data/mesa/analdata';


/* Create the CV events data set */
proc format;
 value yesno
  0='NO'
  1='YES';

run;

%macro reinitialize;
 event_name_o=' ';
 event_val_c=' ';
 event_t2_o=.;
%mend reinitialize;

/*************************/
/* Cardiovascular Events */
/*************************/

* Getting Censoring Times for all subjects;
data censoring;
 set in1.pht001123_v7_mesa_thruyear2011ev(keep=dbGaP_Subject_ID sidno fuptt)
     in2.pht001123_v7_mesa_thruyear2011ev(keep=dbGaP_Subject_ID sidno fuptt);
run;

proc sort data=censoring nodupkey;
   by sidno;
run;


/* Getting Events */
/********************************************************************************************************/
/* All events, except Atrial Fibrillation, are in the "pht001123_v7_mesa_thruyear2011ev" data set.      */
/* Atrial Fibrillation events are input from the data set "pht001217_v5_mesa_mesaafibevents" near       */
/* the bottom of the program, then combined with the other events before outputting the final data set. */
/* Both input events data sets mentioned above contain one observation per subject.                     */
/********************************************************************************************************/


data cvevents(keep=dbGaP_Subject_ID sidno evtype event_name_o event_val_c event_t2_o);
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;

 set in1.pht001123_v7_mesa_thruyear2011ev(drop=strkbis1 strkbis2 strkbis3)
     in2.pht001123_v7_mesa_thruyear2011ev(drop=strkbis1 strkbis2 strkbis3);


   /* MI */
   /* First, reset MI flag to No if MI occured after end of non-fatal event follow-up */
   if mi=1 and (mitt > fuptt)
     then mi=0;

   event_name_o = "MYOCARDIAL INFARCTION (MI)";
   event_val_c = put(mi,yesno.);
   if mi=1 then event_t2_o = mitt;
   else event_t2_o = fuptt;
   evtype = 'E';

   output;
   %reinitialize;

  /***********************************************************************************************************/
  /* For each type of event, at a minimum, a subject will have a record that indicates they did not have     */
  /* that event. This is called the censoring event record (where event_val_c = 'No').                       */
  /* For subjects who actually experienced a certain type of event, they will additionally have one record   */
  /* output where event_val_c = 'Yes' indicating the occurrence of that event.                               */
  /* For example, if a subject experienced an MI, in the output data set, they would have one record output  */
  /* for the MI, and also a censoring record for the MI (even though they experienced one).  This is done    */
  /* for statistical analysis reasons.                                                                       */
  /*                                                                                                         */
  /* The code immediately below outputs an MI censoring record only for subjects who experienced an MI.      */
  /* The code immediately above outputs either a record indicating an MI for those who experienced one, or,  */
  /* will output a censoring record for subjects who did not experience an MI.                               */
  /* This pattern of outputting event and censoring records is repeated for each type of event/procedure     */
  /* below, throughout the program.                                                                          */
  /***********************************************************************************************************/

   if mi=1 then do;
    event_name_o = "MYOCARDIAL INFARCTION (MI)";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';

    output;
    %reinitialize;
   end;


   /* RCA */
   /* First, reset RCA flag to No if RCA occured after end of non-fatal event follow-up */
   if rca=1 and (rcatt > fuptt)
     then rca=0;

   event_name_o = "RESUSCITATED CARDIAC ARREST";
   event_val_c = put(rca,yesno.);
   if rca=1 then event_t2_o = rcatt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if rca=1 then do;
    event_name_o = "RESUSCITATED CARDIAC ARREST";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* ANGINA */
   /* First, reset ANG flag to No if ANG occured after end of non-fatal event follow-up */
   if ang=1 and (angtt > fuptt)
     then ang=0;

   event_name_o = "ANGINA PECTORIS";
   event_val_c = put(ang,yesno.);
   if ang=1 then event_t2_o = angtt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if ang=1 then do;
    event_name_o = "ANGINA PECTORIS";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* PTCA */
   /* First, reset PTCA flag to No if PTCA occured after end of non-fatal event follow-up */
   if ptca=1 and (ptcatt > fuptt)
     then ptca=0;

   event_name_o = "PERCUTANEOUS TRANSLUMINAL CORONARY ANGIOPLASTY (PTCA), CORONARY STENT, OR CORONARY ATHERECTOMY";
   event_val_c = put(ptca,yesno.);
   if ptca=1 then event_t2_o = ptcatt;
   else event_t2_o = fuptt;
   evtype = 'P';
   output;
   %reinitialize;

   if ptca=1 then do;
    event_name_o = "PERCUTANEOUS TRANSLUMINAL CORONARY ANGIOPLASTY (PTCA), CORONARY STENT, OR CORONARY ATHERECTOMY";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'P';
    output;
    %reinitialize;
   end;


   /* CBG */
   /* First, reset CBG flag to No if CBG occured after end of non-fatal event follow-up */
   if cbg=1 and (cbgtt > fuptt)
     then cbg=0;

   event_name_o = "CORONARY BYPASS GRAFT (CBG)";
   event_val_c = put(cbg,yesno.);
   if cbg=1 then event_t2_o = cbgtt;
   else event_t2_o = fuptt;
   evtype = 'P';
   output;
   %reinitialize;

   if cbg=1 then do;
    event_name_o = "CORONARY BYPASS GRAFT (CBG)";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'P';
    output;
    %reinitialize;
   end;


   /* OTHREV */
   /* First, reset OTHREV flag to No if OTHREV occured after end of non-fatal event follow-up */
   if othrev=1 and (othrevtt > fuptt)
     then othrev=0;

   event_name_o = "OTHER REVASCULARIZATION";
   event_val_c = put(othrev,yesno.);
   if othrev=1 then event_t2_o = othrevtt;
   else event_t2_o = fuptt;
   evtype = 'P';
   output;
   %reinitialize;

   if othrev=1 then do;
    event_name_o = "OTHER REVASCULARIZATION";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'P';
    output;
    %reinitialize;
   end;


   /* CHF */
   /* First, reset CHF flag to No if CHF occured after end of non-fatal event follow-up */
   if chf=1 and (chftt > fuptt)
     then chf=0;

   event_name_o = "CONGESTIVE HEART FAILURE (CHF)";
   event_val_c = put(chf,yesno.);
   if chf=1 then event_t2_o = chftt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if chf=1 then do;
    event_name_o = "CONGESTIVE HEART FAILURE (CHF)";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* PVD */
   /* First, reset PVD flag to No if PVD occured after end of non-fatal event follow-up */
   if pvd=1 and (pvdtt > fuptt)
     then pvd=0;

   event_name_o = "PERIPHERAL VASCULAR DISEASE  (PVD)";
   event_val_c = put(pvd,yesno.);
   if pvd=1 then event_t2_o = pvdtt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if pvd=1 then do;
    event_name_o = "PERIPHERAL VASCULAR DISEASE  (PVD)";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* STROKE - ALL CAUSE*/
   /* First, reset STRK flag to No if STRK occured after end of non-fatal event follow-up */
   if strk=1 and (strktt > fuptt)
     then strk=0;

   event_name_o = "STROKE - ALL CAUSE";
   event_val_c = put(strk,yesno.);
   if strk=1 then event_t2_o = strktt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if strk=1 then do;
    event_name_o = "STROKE - ALL CAUSE";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* STROKE - HEMORRHAGIC*/
   event_name_o = "STROKE - HEMORRHAGIC";
   if strk=1 and strktype in (1,2,3) then event_val_c = "YES";
    else if strk in (0,1) then event_val_c="NO";
   if strk=1 and strktype in (1,2,3) then event_t2_o = strktt;
   else if strk in (0,1) then event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if strk=1 and strktype in (1,2,3) then do;
    event_name_o = "STROKE - HEMORRHAGIC";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* STROKE - ISCHEMIC*/
   event_name_o = "STROKE - ISCHEMIC";
   if strk=1 and strktype=4 then event_val_c = "YES";
    else if strk in (0,1) then event_val_c="NO";
   if strk=1 and strktype=4 then event_t2_o = strktt;
   else if strk in (0,1) then event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if strk=1 and strktype=4 then do;
    event_name_o = "STROKE - ISCHEMIC";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* STROKE - NEC*/
   event_name_o = "STROKE - NEC";
   if strk=1 and strktype in (5,6,9,.) then event_val_c = "YES";
    else if strk in (0,1) then event_val_c="NO";
   if strk=1 and strktype in (5,6,9,.) then event_t2_o = strktt;
   else if strk in (0,1) then event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if strk=1 and strktype in (5,6,9,.) then do;
    event_name_o = "STROKE - NEC";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* TIA */
   /* First, reset TIA flag to No if TIA occured after end of non-fatal event follow-up */
   if tia=1 and (tiatt > fuptt)
     then tia=0;

   event_name_o = "TRANSIENT ISCHEMIC ATTACK (TIA)";
   event_val_c = put(tia,yesno.);
   if tia=1 then event_t2_o = tiatt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if tia=1 then do;
    event_name_o = "TRANSIENT ISCHEMIC ATTACK (TIA)";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* DEATH - ALL CAUSE */

   /* First, reset DTH flag to No if DTH occured after end of non-fatal event follow-up */
   if dth=1 and (dthtt > fuptt)
     then dth=0;

   event_name_o = "DEATH - ALL CAUSE";
   event_val_c = put(dth,yesno.);
   if dth=1 then event_t2_o = dthtt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if dth=1 then do;
    event_name_o = "DEATH - ALL CAUSE";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* DEATH - MI */
   event_name_o = "DEATH - MI";
   if dth=1 and dthtype=1 then event_val_c = "YES";
    else if dth in (0,1) then event_val_c="NO";
   if dth=1 and dthtype=1 then event_t2_o = dthtt;
   else if dth in (0,1) then event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if dth=1 and dthtype=1 then do;
    event_name_o = "DEATH - MI";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* DEATH - STROKE */
   event_name_o = "DEATH - STROKE";
   if dth=1 and dthtype=2 then event_val_c = "YES";
    else if dth in (0,1) then event_val_c="NO";
   if dth=1 and dthtype=2 then event_t2_o = dthtt;
   else if dth in (0,1) then event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if dth=1 and dthtype=2 then do;
    event_name_o = "DEATH - STROKE";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* DEATH - OTHER CVD */
   event_name_o = "DEATH - OTHER CVD";
   if dth=1 and dthtype in (3,4) then event_val_c = "YES";
    else if dth in (0,1) then event_val_c="NO";
   if dth=1 and dthtype in (3,4) then event_t2_o = dthtt;
   else if dth in (0,1) then event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if dth=1 and dthtype in (3,4) then do;
    event_name_o = "DEATH - OTHER CVD";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* CHDH */
   /* First, reset CHDH flag to No if CHDH occured after end of non-fatal event follow-up */
   if chdh=1 and (chdhtt > fuptt)
     then chdh=0;

   event_name_o = "CORONARY HEART DISEASE (CHD), HARD";
   event_val_c = put(chdh,yesno.);
   if chdh=1 then event_t2_o = chdhtt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if chdh=1 then do;
    event_name_o = "CORONARY HEART DISEASE (CHD), HARD";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* CHDA */
   /* First, reset CHDA flag to No if CHDA occured after end of non-fatal event follow-up */
   if chda=1 and (chdatt > fuptt)
     then chda=0;

   event_name_o = "CORONARY HEART DISEASE (CHD), ALL";
   event_val_c = put(chda,yesno.);
   if chda=1 then event_t2_o = chdatt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if chda=1 then do;
    event_name_o = "CORONARY HEART DISEASE (CHD), ALL";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* CVDH */
   /* First, reset CVDH flag to No if CVDH occured after end of non-fatal event follow-up */
   if cvdh=1 and (cvdhtt > fuptt)
     then cvdh=0;

   event_name_o = "CARDIOVASCULAR DISEASE (CVD), HARD";
   event_val_c = put(cvdh,yesno.);
   if cvdh=1 then event_t2_o = cvdhtt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if cvdh=1 then do;
    event_name_o = "CARDIOVASCULAR DISEASE (CVD), HARD";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* CVDA */
   /* First, reset CVDA flag to No if CVDA occured after end of non-fatal event follow-up */
   if cvda=1 and (cvdatt > fuptt)
     then cvda=0;

   event_name_o = "CARDIOVASCULAR DISEASE (CVD), ALL";
   event_val_c = put(cvda,yesno.);
   if cvda=1 then event_t2_o = cvdatt;
   else event_t2_o = fuptt;
   evtype = 'E';
   output;
   %reinitialize;

   if cvda=1 then do;
    event_name_o = "CARDIOVASCULAR DISEASE (CVD), ALL";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';
    output;
    %reinitialize;
   end;


   /* REVC */
   /* First, reset REVC flag to No if REVC occured after end of non-fatal event follow-up */
   if revc=1 and (revctt > fuptt)
     then revc=0;

   event_name_o = "CORONARY REVASCULARIZATION";
   event_val_c = put(revc,yesno.);
   if revc=1 then event_t2_o = revctt;
   else event_t2_o = fuptt;
   evtype = 'P';
   output;
   %reinitialize;

   if revc=1 then do;
    event_name_o = "CORONARY REVASCULARIZATION";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'P';
    output;
    %reinitialize;
   end;

run;


* Getting AFIB Events;
data afibevt(keep=dbGaP_Subject_ID sidno evtype event_name_o event_val_c event_t2_o);
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;

 set in1.pht001217_v5_mesa_mesaafibevents(drop=afibcd afiblbl)
     in2.pht001217_v5_mesa_mesaafibevents(drop=afibcd afiblbl);


   /* AFIB */
   /* First, reset AFIB flag to No if AFIB occured after end of non-fatal event follow-up */
   if afib=1 and (afibtt > fuptt)
     then afib=0;

   event_name_o = "ATRIAL FIBRILLATION (AFIB)";
   event_val_c = put(afib,yesno.);
   if afib=1 then event_t2_o = afibtt;
   else event_t2_o = fuptt;
   evtype = 'E';

   output;
   %reinitialize;

   if afib=1 then do;
    event_name_o = "ATRIAL FIBRILLATION (AFIB)";
    event_val_c = 'NO';
    event_t2_o = fuptt;
    evtype = 'E';

    output;
    %reinitialize;
   end;

run;


/* Combine the AFIB events with all other event/procedure data */
data cvevents;
 set cvevents afibevt;

 label event_t2_o = 'Days since exam 1'
       event_name_o = 'Event/Procedure description'
       event_val_c = 'Event Value (YES/NO)'
       evtype = 'Type of record (E = event, P = procedure)'
       sidno = 'Unique study participant identification number';

 rename event_name_o = event_desc
        event_t2_o = days_since_exam1;

run;


/* Sort and output the final data set */
proc sort data=cvevents;
 by sidno days_since_exam1;
run;

options validvarname=upcase;
data out1.cv_events;
 set cvevents;
 by sidno days_since_exam1;
run;

proc export data=cvevents
            outfile="/data/mesa/analdata/cv_events.csv"
            dbms=csv
            replace;
run;


ods rtf file="/data/mesa/analdata/cv_events_contents.rtf";

proc contents data=out1.cv_events;
run;

ods rtf close;
