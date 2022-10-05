/* ----------------------------------------------------------------------------------------------------------------------
   $Author: js463 $
   $Date: 2021/12/07 19:30:33 $
   $Source: /data/aric/dbgap/import_pheno_text/programs/RCS/pull_aric.sas,v $

   Purpose: Stroke Prediction project - Create Phenotype visit file and events file for ARIC.

   Assumptions: Source datasets exist

   Outputs: /data/aric/analdata/pheno_fram_offspring.sas7bdat
            /data/aric/analdata/events_fram_offspring.sas7bdat

   ---------------------------------------------------------------------------------------------------------------------
   Modification History
   ---------------------------------------------------------------------------------------------------------------------
   $Log: pull_aric.sas,v $
   Revision 1.6  2021/12/07 19:30:33  js463
   Added the variables ACTIVITY and INACTIVITY for Exams 1 and 4
   (Exam 4 data actually collected at Exam 3).

   Revision 1.5  2021/07/22 15:34:15  js463
   Added all the new variables except "Valvular heart disease" and "Physical inactivity".

   Revision 1.4  2021/06/22 18:11:39  js463
   *** empty log message ***

   Revision 1.3  2021/06/22 18:04:34  js463
   Renamed three variables:  DIABETES to DIAB, HTCM to HGT_CM, CHOLMED to ANYCHOLMED.

   Revision 1.2  2021/06/10 19:43:14  js463
   Renamed GENDER variable to SEX_C.  Created numeric version of gender variable, called SEX_N.

   Revision 1.1  2021/05/19 18:40:28  js463
   Initial revision



   ---------------------------------------------------------------------------------------------------------------------
*/

libname in1 '/data/aric/dbgap/import_pheno_text/outdata' access=readonly;

libname out1 '/data/aric/analdata';


/*****************/
/* Get Afib data */
/*****************/
/* the first four input files contain Y/N indicators at exams 1-4 */
proc sort data=in1.pht004037_v3_atrfib11(keep=subject_id af) out=afex1;
 by subject_id;
run;
proc sort data=in1.pht004038_v3_atrfib21(keep=subject_id af) out=afex2;
 by subject_id;
run;
proc sort data=in1.pht004039_v3_atrfib31(keep=subject_id af) out=afex3;
 by subject_id;
run;
proc sort data=in1.pht004040_v3_atrfib41(keep=subject_id af) out=afex4;
 by subject_id;
run;

/* the following file contains afib events by 2011, with a censor and time to event variable */
proc sort data=in1.pht006442_v1_incafps11 out=incafps11(keep=subject_id afincby11 ft11afinc where=(afincby11=1)) nodupkey;
 by subject_id;
run;

/***************/
/* Get MI data */
/***************/
/* the following file contains MI events by 2016, with a censor and time to event variable */
/* MI16: Myocardial Infarction by Censoring Date, INC16: Myocardial Infarction/FATCHD by Censoring Date */
proc sort data=in1.pht006443_v4_incps16 out=incps16(keep=subject_id mi16 inc16 fumi16 fuinc16 where=(mi16=1 or inc16=1)) nodupkey;
 by subject_id;
run;

data incps16(keep=subject_id t2mi);
 set incps16;

 t2mi=min(fumi16,fuinc16);
 if t2mi ne .;

run;

/****************/
/* Get CHF data */
/****************/
/* the following file contains CHF events by 2016, with a censor and time to event variable */
proc sort data=in1.pht006443_v4_incps16 out=inchf(keep=subject_id inchf16 c7_futimehf where=(inchf16=1)) nodupkey;
 by subject_id;
run;

data inchf(keep=subject_id t2chf);
 set inchf;

 t2chf=c7_futimehf;
 if t2chf ne .;

run;

/*******************************/
/* Get Cardiac procedures data */
/*******************************/
/* the following file contains Cardiac Procedure events by 2016, with a censor and time to event variable */
proc sort data=in1.pht006443_v4_incps16 out=cproc(keep=subject_id proc16 fuproc16 where=(proc16=1)) nodupkey;
 by subject_id;
run;

data cproc(keep=subject_id t2cproc);
 set cproc;

 t2cproc=fuproc16;
 if t2cproc ne .;

run;

proc format;

value $insuln

'Humalog                   ','Novolog                   ','novo nordisk novolog      ','10 HUMULIN N   INSULIN    ','ACTRAPID 5U               ','DIABETIC SHOTS            ',
'HUM.N/GLUCOSTIX/SWABS     ','HUMALIN                   ','HUMALIN A 60 UNITS        ','HUMALIN N 100U/ML         ','HUMALIN N INJECTION       ','HUMALIN N-25 AM 15 PM     ',
'HUMALIN NPH               ','HUMALIN R 5 AM 5 PM       ','HUMALIN REGULAR           ','HUMALIN-N INSULIN         ','HUMALOG                   ','HUMALOG INJECTION         ',
'HUMALOG INSULIN           ','HUMALOG INSULIN INJECTION ','HUMAN INSULIN             ','HUMAN INSULIN - NPH U     ','HUMAN INSULIN ISOPHANE SUS','HUMAN INSULIN NPH         ',
'HUMAN INSULIN NPH U       ','HUMAN NPH                 ','HUMAN-N                   ','HUMILIN                   ','HUMILIN N                 ','HUMILIN N 10 ML           ',
'HUMILIN N INSULIN         ','HUMILIN NV-100 INJECTTION ','HUMILIN R                 ','HUMILIN R 10 ML           ','HUMILIN R INSULIN INJ     ','HUMILIN R INSULIN O6      ',
'HUMILIN R REGULAR         ','HUMILIN U100 N            ','HUMILIN-N INSULIN         ','HUMILIN-R INSULIN         ','HUMILINN NP HUM INSULIN   ','HUMIN                     ',
'HUMIN N                   ','HUMINLIN INSULIN          ','HUMLIN                    ','HUMLIN 60 UNITS           ','HUMLIN II                 ','HUMLIN N                  ',
'HUMLIN N (INSULIN)        ','HUMLIN N INSULIN          ','HUMLIN N INSULIN 30       ','HUMLIN N-100 INSULIN      ','HUMLIN N100               ','HUMLIN NP INSULIN         ',
'HUMLIN NPH                ','HUMLIN NPH INSULIN        ','HUMLIN R                  ','HUMLIN REG. INSULIN       ','HUMLIN U-100 ISNULIN      ','HUMLIN-N                  ',
'HUMLIN-N   16 UNITS       ','HUMLIN-N  INSULIN         ','HUMLIN-N INSULIN          ','HUMLIN-N U 100 31 UNIT/2X ','HUMOLIN INSUL. TYPE N U100','HUMUILIN                  ',
'HUMUIN 20/30 INSULIN      ','HUMUIN NPH INJECTION      ','HUMULI N U100 (35U)       ','HUMULIM N 26 UNITS        ','HUMULIN                   ','HUMULIN  NPH              ',
'HUMULIN - H               ','HUMULIN - N               ','HUMULIN -N                ','HUMULIN -U-N 100          ','HUMULIN /ILETIN N         ','HUMULIN 10 ML             ',
'HUMULIN 100               ','HUMULIN 100U/ML           ','HUMULIN 10ML INSULIN      ','HUMULIN 50/10MG           ','HUMULIN 50/50             ','HUMULIN 5R LIQUID         ',
'HUMULIN 70/30             ','HUMULIN 70/30 INJ         ','HUMULIN 70/30 INJECTION   ','HUMULIN 70/30 INSULIN     ','HUMULIN 70/30 U-100       ','HUMULIN 70/30 VIAL LIL    ',
'HUMULIN H                 ','HUMULIN HUMAN INSULIN     ','HUMULIN INJ               ','HUMULIN INJ REG           ','HUMULIN INJECT 20 ML      ','HUMULIN INSUL             ',
'HUMULIN INSULIN           ','HUMULIN INSULIN   1O ML   ','HUMULIN INSULIN 70/30     ','HUMULIN INSULIN CARTRIDGE ','HUMULIN INSULIN INJ       ','HUMULIN INSULIN INJECTION ',
'HUMULIN INSULIN LENTE 65U ','HUMULIN INSULIN N         ','HUMULIN INSULIN N  100U/ML','HUMULIN INSULIN NPH       ','HUMULIN INSULIN R         ','HUMULIN INSULIN U1OO 70/30',
'HUMULIN INSULINE 10 ML    ','HUMULIN L                 ','HUMULIN L 10 MI 100UNIT/MI','HUMULIN L 100 U/ML        ','HUMULIN L INJECTION       ','HUMULIN L INSULIN         ',
'HUMULIN L U-100           ','HUMULIN N                 ','HUMULIN N  NPH  INSULIN   ','HUMULIN N  U 100          ','HUMULIN N  U-100          ','HUMULIN N  U100           ',
'HUMULIN N (2 CONTAINERS)  ','HUMULIN N (INSULIN NPH)   ','HUMULIN N - 10            ','HUMULIN N 10 ML           ','HUMULIN N 10 ML INSUL.    ','HUMULIN N 100             ',
'HUMULIN N 100 UNITS       ','HUMULIN N 100 UNITS ML    ','HUMULIN N 100 UNITS/ML    ','HUMULIN N 1000 PML        ','HUMULIN N 100U            ','HUMULIN N 100U/ML         ',
'HUMULIN N 100U/ML LIL     ','HUMULIN N 100UNITS/ML     ','HUMULIN N 10ML            ','HUMULIN N 10ML HI-310     ','HUMULIN N 22MG NPH 1/INJ  ','HUMULIN N 25 UNITS        ',
'HUMULIN N 28 UNITS        ','HUMULIN N 40 CC           ','HUMULIN N 40 UNIT         ','HUMULIN N 44 UNITS        ','HUMULIN N 54 UNITS        ','HUMULIN N 62 UNIT         ',
'HUMULIN N 70 UNITS DAILY  ','HUMULIN N HI              ','HUMULIN N HI 310 ULIL     ','HUMULIN N INJ             ','HUMULIN N INJ.            ','HUMULIN N INJECTION       ',
'HUMULIN N INS             ','HUMULIN N INSULI          ','HUMULIN N INSULIN         ','HUMULIN N INSULIN  U-100  ','HUMULIN N INSULIN 20 UNITS','HUMULIN N INSULIN 22 UNITS',
'HUMULIN N INSULIN 40 UNITS','HUMULIN N INSULIN INJ     ','HUMULIN N INSULIN NPH U100','HUMULIN N INSULIN U-100   ','HUMULIN N ISOPHANE SUSP   ','HUMULIN N ISOPHANE SUSPENS',
'HUMULIN N NPH INSULIN     ','HUMULIN N NPH U-100       ','HUMULIN N NPH U100 INSULIN','HUMULIN N REG 100 UNITS   ','HUMULIN N U 100           ','HUMULIN N U-100           ',
'HUMULIN N U-100 40 UNITS  ','HUMULIN N U-100 INJ       ','HUMULIN N U-100 INJECTION ','HUMULIN N U100            ','HUMULIN N U100 VIA        ','HUMULIN N VIAL U-100      ',
'HUMULIN N&R               ','HUMULIN N-100             ','HUMULIN N-100 UNITS INSULN','HUMULIN N-INSULIN 10 ML   ','HUMULIN N-NPH U-100 INSULN','HUMULIN N/U-100           ',
'HUMULIN N10 ML            ','HUMULIN NAT. INS. NPH     ','HUMULIN NPH               ','HUMULIN NPH 5 UNITS       ','HUMULIN NPH LIQUID        ','HUMULIN NPH U 100         ',
'HUMULIN NPH U 100 INJ     ','HUMULIN NPH U-100         ','HUMULIN NPH U-100 10 ML   ','HUMULIN NPH U-100 INSULIN ','HUMULIN NPH U100 H1310    ','HUMULIN NPH U100 HI310    ',
'HUMULIN NPH U100 INSULIN  ','HUMULIN NPH-U-100         ','HUMULIN NR INSULIN        ','HUMULIN R                 ','HUMULIN R  U100           ','HUMULIN R & N             ',
'HUMULIN R & N NPH         ','HUMULIN R - 10            ','HUMULIN R 10 ML           ','HUMULIN R 10 UNITS        ','HUMULIN R 100U            ','HUMULIN R 10ML            ',
'HUMULIN R 10ML HI-210     ','HUMULIN R 15 UNITS        ','HUMULIN R 18 UNITS        ','HUMULIN R 20 UNIT         ','HUMULIN R 5 UNITS         ','HUMULIN R INJ             ',
'HUMULIN R INJECTION       ','HUMULIN R INLULIN         ','HUMULIN R INSULIN         ','HUMULIN R INSULIN  U-100  ','HUMULIN R INSULIN 100 U/ML','HUMULIN R INSULIN 5 UNITS ',
'HUMULIN R INSULIN INJ     ','HUMULIN R INSULIN REG     ','HUMULIN R INSULIN U-100   ','HUMULIN R REG 100 UNITS/ML','HUMULIN R REG INSULIN     ','HUMULIN R REGULAR         ',
'HUMULIN R U               ','HUMULIN R U 100           ','HUMULIN R U-100           ','HUMULIN R U-100 10 ML     ','HUMULIN R U-100 HI210 20ML','HUMULIN R U-100 INJ       ',
'HUMULIN R U100            ','HUMULIN R U100 INSULIN    ','HUMULIN R USP REG U-100   ','HUMULIN R-INSULIN 10 ML   ','HUMULIN REG               ','HUMULIN REG INS HI 210    ',
'HUMULIN REG INS HI-210    ','HUMULIN REG INSULIN       ','HUMULIN REG INSULIN 8 UNIT','HUMULIN REG.              ','HUMULIN REG. INSULIN 10 IU','HUMULIN REG. INSULIN 8 IU ',
'HUMULIN REGULAR INSULIN HU','HUMULIN U                 ','HUMULIN U 100             ','HUMULIN U INSULIN         ','HUMULIN U SUSP            ','HUMULIN U U100            ',
'HUMULIN U ULTRALENTE      ','HUMULIN U-100             ','HUMULIN UU-100            ','HUMULIN-N                 ','HUMULIN-N H1310 20ML      ','HUMULIN-N INSUL HI310     ',
'HUMULIN-N INSULIN         ','HUMULIN-N INSULIN 26U DAIL','HUMULIN-N INSULIN H1310   ','HUMULIN-N INSULIN HI310   ','HUMULIN-N INSULIN U 100   ','HUMULIN-N INSULIN U-100   ',
'HUMULIN-N INSULIN U-100NPH','HUMULIN-N NPH INSULIN     ','HUMULIN-N U 100           ','HUMULIN-N U-100 INSULIN   ','HUMULIN-N U100            ','HUMULIN-N U100 INSULIN    ',
'HUMULIN-R                 ','HUMULIN-R 100 UNITS INSULN','HUMULIN/ILETIN            ','HUMULIN/ILETIN 10 ML      ','HUMULIN/ILETIN INJECTIBLE ','HUMULLIN N 100U/ML        ',
'HUMULM -N                 ','HUMULN R                  ','HUNILIN NPH INJECTION     ','HUNULIN NPH               ','HYMULIN 30/70             ','IDSULIN                   ',
'ILETIN                    ','ILETIN 1                  ','ILETIN 1 NPH INSULIN      ','ILETIN 1NPH 100U          ','ILETIN I INJECTION        ','ILETIN I INSULIN          ',
'ILETIN I INSULIN ZINC     ','ILETIN I NPH              ','ILETIN I NPH 100U/ML 1/2CC','ILETIN I NPH 100U/ML VIAL ','ILETIN I REGULAR          ','ILETIN II INSULIN         ',
'ILETIN INSULIN            ','ILETIN INSULIN U-100      ','ILETIN ISOPHANE INSULIN   ','ILETIN NPH 100U CP 1OCC   ','ILETIN NPH INSULIN        ','INS LENTE U-100 INJECTION ',
'INS NPH U-100             ','INS NPH U-100 CP-310      ','INSULATARD NPS INSULIN 100','INSULIC                   ','INSULIN                   ','INSULIN  (HUMULIN         ',
'INSULIN  MPH U100         ','INSULIN  U-100 N          ','INSULIN (HUMILIN-REG)     ','INSULIN (HUMULIN 70/30    ','INSULIN (HUMULIN N        ','INSULIN (HUMULIN N)       ',
'INSULIN (HUMULIN R AND N) ','INSULIN (HUMULIN)         ','INSULIN (HUMULIN-N)       ','INSULIN (R AND N )        ','INSULIN - INJECTION       ','INSULIN - N HUMULIN       ',
'INSULIN - R HUMULIN       ','INSULIN 10 ML HUMULIN N   ','INSULIN 10-14R            ','INSULIN 100               ','INSULIN 100 UNITS         ','INSULIN 100 UNITS /1 ML   ',
'INSULIN 100 UNITS/ML      ','INSULIN 10ML INJECTION    ','INSULIN 15U HUMULIN QAM   ','INSULIN 18 UNITS 70/30    ','INSULIN 20U NPH           ','INSULIN 30 NPHU-100       ',
'INSULIN 30R 75N           ','INSULIN 35 U/AM 27U/PM    ','INSULIN 45 UNITS U-100    ','INSULIN 60 U100           ','INSULIN 70/30             ','INSULIN 70/30 HUMAN       ',
'INSULIN HULIUM N& R       ','INSULIN HUM.70/30 HI71LIL ','INSULIN HUMALIN N         ','INSULIN HUMAN             ','INSULIN HUMAN INJ USP     ','INSULIN HUMAN NPH         ',
'INSULIN HUMAN R 100 IU INJ','INSULIN HUMILIN N HI 310  ','INSULIN HUMILIN N INJ     ','INSULIN HUMLIN            ','INSULIN HUMLIN N          ','INSULIN HUMULIN           ',
'INSULIN HUMULIN 60N 40R   ','INSULIN HUMULIN 70/30     ','INSULIN HUMULIN INJ       ','INSULIN HUMULIN LENTE     ','INSULIN HUMULIN N         ','INSULIN HUMULIN N 100 U/ML',
'INSULIN HUMULIN N 20 U    ','INSULIN HUMULIN N HI      ','INSULIN HUMULIN N HI 310  ','INSULIN HUMULIN N HI310   ','INSULIN HUMULIN NPH U100  ','INSULIN HUMULIN R         ',
'INSULIN HUMULIN R 10 ML   ','INSULIN HUMULIN U-I00     ','INSULIN HUMULIN-N         ','INSULIN HUMULIN-R         ','INSULIN ILETIN 1NPH 100U  ','INSULIN INJ               ',
'INSULIN INJ 100           ','INSULIN INJ HUMAN REGULAR ','INSULIN INJ HUMULIN       ','INSULIN INJ HUMULIN 70/30 ','INSULIN INJ HUMULIN N     ','INSULIN INJ HUMULIN R     ',
'INSULIN INJ NPH           ','INSULIN INJ NPH AND HUMAN ','INSULIN INJ REG           ','INSULIN INJ U 100 L       ','INSULIN INJ U 100 R       ','INSULIN INJ.              ',
'INSULIN INJ. HUMULIN N    ','INSULIN INJ. HUMULIN R    ','INSULIN INJ. REG          ','INSULIN INJECTION         ','INSULIN INJECTION HUMAN   ','INSULIN ISOPHANE SUSP.10ML',
'INSULIN LENTE 100 58U/DAY ','INSULIN LENTE U-100 34U/D ','INSULIN LENTE U100        ','INSULIN LILLY 100 U       ','INSULIN LILLY NPH U-100   ','INSULIN LILY R 15 UNITS   ',
'INSULIN LILY W 18 UNITS   ','INSULIN N                 ','INSULIN N 100             ','INSULIN N BEEF 100 U/ML   ','INSULIN N BEEF U100       ','INSULIN N U-100           ',
'INSULIN N&R               ','INSULIN N-100             ','INSULIN N-100 REG.        ','INSULIN N30 R22 SHOT      ','INSULIN NOVALIN-N         ','INSULIN NOVOLIN           ',
'INSULIN NOVOLIN 70/30     ','INSULIN NOVOLIN N 10 ML   ','INSULIN NOVULIN 70/30     ','INSULIN NPH               ','INSULIN NPH 10 MI 100 UN  ','INSULIN NPH 100           ',
'INSULIN NPH 100 MG        ','INSULIN NPH 30            ','INSULIN NPH 30 IU         ','INSULIN NPH 64 UNITS      ','INSULIN NPH HUMAN         ','INSULIN NPH INJ           ',
'INSULIN NPH NILETIN       ','INSULIN NPH U 100         ','INSULIN NPH U 100 10 ML   ','INSULIN NPH U 100 37 UNITS','INSULIN NPH U-100         ','INSULIN NPH U-100 CP-310  ',
'INSULIN NPH U-100 INJ     ','INSULIN NPH U100          ','INSULIN NPH U100 INJECT   ','INSULIN NPH UKETIN I 10 CC','INSULIN NPH V100 UNITS    ','INSULIN NPH-100           ',
'INSULIN NPH-100-N         ','INSULIN NPH-U-100         ','INSULIN NPH-U100          ','INSULIN NPHU 100 13 UNITS ','INSULIN R                 ','INSULIN R 100             ',
'INSULIN R U-100 (ILETIN-I)','INSULIN R&NPH             ','INSULIN R-100             ','INSULIN R-U-100           ','INSULIN R-U100            ','INSULIN REG               ',
'INSULIN REG N-100         ','INSULIN REG U 100 BUFFERED','INSULIN REG U-100         ','INSULIN REG U-100 HUMAN   ','INSULIN REG.              ','INSULIN REGULAR           ',
'INSULIN REGULAR 100       ','INSULIN REGULAR NPH INJECT','INSULIN REGULAR U 100     ','INSULIN REGULAR U-20      ','INSULIN SY/ND             ','INSULIN TYPE N NPH U 100  ',
'INSULIN U 100             ','INSULIN U-100             ','INSULIN U-100 L           ','INSULIN U-100 NPH         ','INSULIN U.100 45 UNITS/DAY','INSULIN U100 REGULAR 40 U ',
'INSULIN ZINC SUSPENSION   ','INSULIN(HUMULIN N INJ     ','INSULIN(HUMULIN N)        ','INSULIN(HUMULIN R)        ','INSULIN-HUMULIN N         ','INSULINE ULTRA LENTE      ',
'ISOPAHANE INSULIN NPH(BEEF','ISOPHANE INSULIN          ','ISOPHANE INSULIN  100 UNIT','ISOPHANE INSULIN 100UNITML','ISOPHANE INSULIN 60UNIT 2X','ISOPHANE INSULIN SUSP 100I',
'ISOPHANE INSULIN SUSPENSIO','ISOPHANE INSULIN USP 100 U','ISOPHATE INSULIN          ','L LENTE ILETIN INSULIN    ','L. LENTE INSULIN 10 ML    ','LENTE ILETIN I INSULIN ZNC',
'LENTE ILETIN I U-100      ','LENTE ILETIN I U-100 L    ','LENTE ILETIN L U-100      ','LENTE ILETIN-I U-100 INSUL','LENTE INSULIN             ','LENTE INSULIN 100U/ML     ',
'LENTE INSULIN SUSP        ','LENTE INSULIN U 100       ','LENTE PORK INSULIN 11U    ','LENTE U 100 INSULIN       ','LENTLE INSULIN U100       ','LILLY U-100 N NPH INSULIN ',
'LILLY V-100 L 10MI        ','LISPRO (HUMALOG - INSULIN)','LONG ACTING REGULAR 6U    ','N INSULIN                 ','N NPH INSULIN             ','N NPH INSULIN SUSP        ',
'N P H ILETIN I 30 U       ','N P H U 100 85 UNITS      ','N P H-ILETIN I U-100 INSUL','N-100 HUMLIN              ','N-U 100 INSULIN           ','NHP INSULIN 10 ML         ',
'NILETIN                   ','NOLOLIN N INSULIN         ','NONOLIN N                 ','NOVALIN INSULIN 42 U 70/30','NOVALIN N                 ','NOVALIN R                 ',
'NOVLIN                    ','NOVLIN INSULIN            ','NOVOLIN                   ','NOVOLIN 70/ 30 INSULIN    ','NOVOLIN 70/30 HUM (INSULIN','NOVOLIN 70/30 HUMAN INSULI',
'NOVOLIN 70/30 INSULIN     ','NOVOLIN 70/30 INSULIN INJ ','NOVOLIN 70/30 PENFILL     ','NOVOLIN HUMANINSULIN 10 ML','NOVOLIN INJECTION         ','NOVOLIN INSULIN           ',
'NOVOLIN INSULIN 100U/ML   ','NOVOLIN INSULIN 70/30     ','NOVOLIN INSULIN INJ       ','NOVOLIN INSULIN INJECTION ','NOVOLIN L                 ','NOVOLIN N                 ',
'NOVOLIN N (HUMAN INSULIN) ','NOVOLIN N 10 ML           ','NOVOLIN N HUMAN INSULIN   ','NOVOLIN N INJ             ','NOVOLIN N INSUL. NPH 100 U','NOVOLIN N INSULIN         ',
'NOVOLIN N PEN FILL INSULIN','NOVOLIN N PENFILL INSULIN ','NOVOLIN NPH               ','NOVOLIN NPH U-100 INJ     ','NOVOLIN NPH U100          ','NOVOLIN NU                ',
'NOVOLIN NU-100 HUM INJ    ','NOVOLIN PENFILL           ','NOVOLIN R                 ','NOVOLIN R (HUMAN INSULIN) ','NOVOLIN R 10 ML           ','NOVOLIN R 100 U           ',
'NOVOLIN R INJ             ','NOVOLIN R INSULIN INJ     ','NOVOLIN R REG INJ         ','NOVOLIN R U-100 INJ       ','NOVOLIN REG. INSULIN      ','NOVOLIN-70/30 INSULIN     ',
'NOVOLIN-N                 ','NOVOLIN-N HUMAN           ','NOVOLINPEN 100 UNITS      ','NOVULIN INSULIN           ','NPH                       ','NPH  N                    ',
'NPH (HUMULIN) INSULIN     ','NPH (INSULIN)             ','NPH - N                   ','NPH - U100                ','NPH -U100                 ','NPH 100                   ',
'NPH 100 INSULIN           ','NPH 60                    ','NPH HUMAN                 ','NPH HUMAN INSULIN         ','NPH HUMAN INSULIN ISOPHANE','NPH HUMILIN               ',
'NPH HUMLIN 100 INSULIN    ','NPH HUMLIN INSULIN        ','NPH HUMULIN               ','NPH HUMULIN INSULIN       ','NPH I INSULIN INJECTION   ','NPH ILETIN                ',
'NPH ILETIN  INSULIN       ','NPH ILETIN (ISOPHANE INSUL','NPH ILETIN - I INSULIN    ','NPH ILETIN -U 100         ','NPH ILETIN 1              ','NPH ILETIN 1 10CC         ',
'NPH ILETIN 1 INJECTION    ','NPH ILETIN 1 INSULIN      ','NPH ILETIN 100UNITS/CC    ','NPH ILETIN I              ','NPH ILETIN I 100 U/ML     ','NPH ILETIN I INJECTION    ',
'NPH ILETIN I INSULIN      ','NPH ILETIN I INSULIN 100 U','NPH ILETIN I INSULIN U-100','NPH ILETIN I ISOPHANE INSU','NPH ILETIN I ISOPHATE INSU','NPH ILETIN I U 100        ',
'NPH ILETIN I U-100        ','NPH ILETIN I U-100 INJECT.','NPH ILETIN I U-100 N      ','NPH ILETIN I VI00         ','NPH ILETIN II             ','NPH ILETIN INSULIN        ',
'NPH ILETIN INSULIN  100 U ','NPH ILETIN INSULIN 100    ','NPH ILETIN INSULIN 100 U  ','NPH ILETIN INSULIN 100U/CC','NPH ILETIN INSULIN U-100  ','NPH ILETIN ISOPHANE INSULI',
'NPH ILETIN T              ','NPH ILETIN U-100          ','NPH ILETIN U100N          ','NPH ILETIN-I U-100 INSULIN','NPH INSUL 20ML 72-74 UNIT ','NPH INSULIN               ',
'NPH INSULIN  100 UNITS    ','NPH INSULIN  20U          ','NPH INSULIN  28 UNITS     ','NPH INSULIN (BEEF)        ','NPH INSULIN (BEEF) 100    ','NPH INSULIN 10 ML         ',
'NPH INSULIN 100 U         ','NPH INSULIN 100 UNITS     ','NPH INSULIN 20MG          ','NPH INSULIN 22 UNITS      ','NPH INSULIN 35 U          ','NPH INSULIN 38U & 28U     ',
'NPH INSULIN 45 UNITS      ','NPH INSULIN 50 UNITS      ','NPH INSULIN HUMAN         ','NPH INSULIN HUMLIN N      ','NPH INSULIN ILETIN 100U/CC','NPH INSULIN INJ           ',
'NPH INSULIN INJ HUMAN     ','NPH INSULIN INJ.100 U     ','NPH INSULIN INJECTIBLE    ','NPH INSULIN INJECTION     ','NPH INSULIN ISOPHANE 100ML','NPH INSULIN N             ',
'NPH INSULIN SUSPENSION    ','NPH INSULIN U-100         ','NPH INSULIN U-100 30 & 20 ','NPH INSULIN U-100 INSULIN ','NPH INSULIN U100          ','NPH INSULIN U100 26 UNITS ',
'NPH INSULIN USP (BEEF)    ','NPH INSULLIN              ','NPH ISOPHANE              ','NPH ISOPHANE INSULIN      ','NPH NILETIN               ','NPH NILETIN I U-100       ',
'NPH NILETIN INSULIN       ','NPH NILETIN INSULIN SUSP  ','NPH NILETIN INSULIN U-100 ','NPH REGULATE              ','NPH U 100                 ','NPH U II HUMULIN          ',
'NPH U-100                 ','NPH U-100 BEEF            ','NPH U-100 BEEF INSULIN    ','NPH U-100 INSULIN         ','NPH U-100 INSULIN 10 ML   ','NPH U100                  ',
'NPH U100 30 UNITS INSULIN ','NPH U100 INSULIN          ','NPH-100                   ','NPH-ILETIN I INSULIN U-100','NPH-ILETIN INSULIN        ','NPH-ILETIN U-100 INSULIN  ',
'NPH-INSULIN U100 20 ML    ','NPH-U 100                 ','NPH-U 100 INSULIN         ','NPH-U-100                 ','NPH-U-100 ILETIN INSULIN  ','NPH-U-100 INSULIN         ',
'NPH-U100 HUMULIN INSULIN  ','NPHILETIN I ISOPANE INS.  ','NPHINSULIN                ','NPHO100-HUMLIN INSULIN    ','NPHU 100                  ','NPHU 100 INSULIN          ',
'NPHU-100 BEEF INSULIN     ','NPI ILETIN I U 100        ','NPN ILETIN I INSULIN      ','NU100 INSULIN             ','PROTAMINE ZINC & ILETIN I ','PURIFIED PORK INSULIN 100U',
'R INSULIN                 ','R REG INSULIN INJ USP     ','R REGULAR INSULIN INJ.    ','R U-100 INSULIN           ','R. REGULAR INSULIN 10 ML  ','REG ILETIN I INJ          ',
'REG ILETIN I INSUL 100 UN ','REG ILETIN I INSULIN 100 U','REG ILETIN I V-100        ','REG INSULIN               ','REG INSULIN HUMAN INJ     ','REG INSULIN INJ USP(PORK) ',
'REG. INSULIN              ','REG. INSULIN U-100        ','REG.ILETIN 1 INSULIN 1001U','REG.ILETIN INSULIN U-100  ','REG.INSULIN (PORK)100U/ML ','REG/NPH 70/30 INSULIN     ',
'REGILETIN I INSULIN INJ.  ','REGULAR ILETIN I 100 U/ML ','REGULAR ILETIN I 100 UNITS','REGULAR ILETIN I 8 U      ','REGULAR ILETIN I INJECT.  ','REGULAR ILETIN I INSULIN  ',
'REGULAR ILETIN I R U-100  ','REGULAR ILETIN II         ','REGULAR ILETIN U-100 R    ','REGULAR INSULIN           ','REGULAR INSULIN 10 ML     ','REGULAR INSULIN 10 UNITS  ',
'REGULAR INSULIN 20 U      ','REGULAR INSULIN 22        ','REGULAR INSULIN 22U & 12 U','REGULAR INSULIN 5 UNITS   ','REGULAR INSULIN 5U        ','REGULAR INSULIN 8 UNITS   ',
'REGULAR INSULIN INJ       ','REGULAR INSULIN INJ HUMAN ','REGULAR INSULIN PORK 100 U','REGULAR INSULIN R         ','REGULAR INSULIN U-100     ','REGULAR U100 INSULIN      ',
'REGULAT ILETIN INSULIN INJ','SEMI-LENTE 8 UNITS        ','SEMI-LENTLE INSULIN U100  ','SQUIBB NOVA NPH N INSULIN ','U 100 INSULIN             ','U 100 LENTE 54 UNITS      ',
'U 100 N INSULIN           ','U 100 NPH INSULIN         ','U 100 PORK INSULIN        ','U 100-N ILETIN I          ','U- 100 NPH                ','U-100 HUMULIN INSULIN     ',
'U-100 HUMULIN-N NPH INSULN','U-100 ILETIN              ','U-100 ILETIN SEMILENTE    ','U-100 INSULIN             ','U-100 INSULIN NPH         ','U-100 L INSULIN           ',
'U-100 N                   ','U-100 N  INSULIN          ','U-100 N INSULIN           ','U-100 N NPH  INSULIN      ','U-100 NPH ILETIN I INSULIN','U-100 NPH ILETIN INSULIN  ',
'U-100 NPH ILETIN-I INSULIN','U-100 NPH INSULIN         ','U-100 PROTAMINE ZINC/ILETI','U-100 R INSULIN           ','U-100 REG ILETIN INSULIN  ','U-100 REGULAR ILETIN INSUL',
'U-100 REGULAR INSULIN     ','U-100N INSULIN            ','U-100N NPH INSULIN  65UNIT','U100-NPH ILETIN INSULIN   ','U100-REG INSULIN          ','ULIN HUMULIN U INJECTION  ',
'ULTRA LENTE (INSULIN)     ','ULTRA LENTE ILETIN 1 U-100','ULTRALENTE                ','UN 100 INSULIN            ','NOVOLIN 70-30             ','NOVOLIN 70/30             ',
'Insulin Aspart Inj 100 Uni','NOVOLOG (Insulin Aspart In','NOVOLOG FLEXPEN (Insulin A','NOVOLOG PENFILL (Insulin A','Insulin Glargine Inj 100 U','LANTUS (Insulin Glargine I',
'LANTUS SOLOSTAR (Insulin G','APIDRA (Insulin Glulisine ','Insulin Glulisine Subcutan','HUMALOG (Insulin Lispro (H','HUMALOG KWIKPEN (Insulin L','HUMALOG PEN (Insulin Lispr',
'LEVEMIR (Insulin Detemir I','LEVEMIR FLEXPEN (Insulin D','HUMULIN R (Insulin Regular','Insulin Regular (Human) In','NOVOLIN R (Insulin Regular','HUMULIN N (Insulin Isophan',
'NOVOLIN N (Insulin Isophan','Insulin Aspart Prot & Aspa','NOVOLOG MIX 70/30 (Insulin','HUMALOG MIX 75/25 (Insulin','HUMULIN 70/30 (Insulin Iso','HUMULIN 70/30 PEN (Insulin',
'NOVOLIN 70/30 (Insulin Iso','RELION 70/30 (Insulin Isop','INSULIN HUMAN (Insulin, Hu','BD INSULIN SYRINGE LUER-L ','INSULIN SYRINGE/0.5ML/31G ','INSULIN SYRINGE/U-100/1ML ',
'RELION INSULIN SYRINGE/U- ','NOVOFINE 30GX8MM (Insulin ','NOVOPEN 3 INSULIN DELIVER ' = '1'

OTHER = '2';

 value educf
  1 = 'Less than High School'
  2 = 'High School'
  3 = 'Some College'
  4 = 'College';

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

 value faminc1a
  1 = 'less than $5,000'
  3 = '$5,000 to $7,000'
  4 = '$8,000 to $11,000'
  6 = '$12,000 to $15,000'
  9 = '$16,000 to $24,000'
  12 = '$25,000 to $34,000'
  15 = '$35,000 to $49,000'
  19 = 'more than $50,000'
  99 = 'Refused';

 value faminc4b
  1 = 'less than $5,000'
  3 = '$5,000 to $7,000'
  4 = '$8,000 to $11,000'
  6 = '$12,000 to $15,000'
  9 = '$16,000 to $24,000'
  12 = '$25,000 to $34,000'
  15 = '$35,000 to $49,000'
  20 = '$50,000 to $74,000'
  21 = '$75,000 to $99,000 '
  22 = 'more than $100,000'
  99 = 'Refused';

 value active
  1 = 'Inactive'
  2 = 'Slightly active'
  3 = 'Active';

run;

/* Get the RACEGRP variable from EXAM1.  Will be merged onto each visit record at the end. */
/* Race Added 12/5/2018 */

data getrace(drop=racegrp);
 length race_c $20;
 set in1.pht004063_v2_derive13(keep=subject_id racegrp);

  if racegrp='B' then race_c='Black';
  else if racegrp='W' then race_c='White';

  label race_c = 'Race';
run;

proc sort data=getrace nodupkey;
 by subject_id;
run;

/************************************************************************************/
/* Create BASE_CVD, BASE_STROKE, CENSDAY and DEATH_IND for merging onto Exam 1 data */
/************************************************************************************/
/* Added 02/07/2019 */
/***********************************/
/* Added BASE_STROKE on 03/15/2021 */
/***********************************/

/* Base CVD */
proc sort data=in1.pht004063_v2_derive13(keep=subject_id prvchd05 symchd03 roseic03 prevhf01)
          out=basecvd nodupkey;
 by subject_id;
run;

data basecvd(keep=subject_id base_cvd);
 length base_cvd $3;
 set basecvd;
  by subject_id;

  if prvchd05=1 or symchd03=1 or roseic03='1' or prevhf01=1 then base_cvd="YES";
    else base_cvd="NO";
run;

/* Base Stroke */
proc sort data=in1.pht004197_v2_stroke01(keep=subject_id stroke01 tia01)
          out=basestroke nodupkey;
 by subject_id;
run;

data basestroke(keep=subject_id base_stroke);
 set basestroke;
  by subject_id;

  if stroke01='Y' then base_stroke=2;
   else if tia01='Y' then base_stroke=1;
   else if stroke01='N' and tia01='N' then base_stroke=0;

run;

/* Death indicator */
proc sort data=in1.pht006443_v4_incps16(keep=subject_id dead16 fudth16)
          out=survdth nodupkey;
 by subject_id;
run;

data survdth(keep=subject_id censday death_ind);
 length death_ind $3;
 set survdth;
  by subject_id;

  if dead16=1 then death_ind="YES";
    else death_ind="NO";

  censday=fudth16;

run;

/*****************************************************/

proc sort data=in1.pht004063_v2_derive13(keep=subject_id prevhf01)
          out=basechf nodupkey;
 by subject_id;
run;

/***********************************************************************/
/*****************/
/* NEW VARIABLES */
/*****************/

/*******************************************************************/
/* Family history of stroke (mother/father), Site location (state) */
/*******************************************************************/
data fhstroke_v1(keep=subject_id fh_stroke state);
 set in1.pht004063_v2_derive13;

 if momhistorystr=1 or dadhistorystr=1 then fh_stroke=1;
  else if momhistorystr=0 and dadhistorystr=0 then fh_stroke=0;

 if centerid='A' then state='MN';
  else if centerid='B' then state='MD';
  else if centerid='C' then state='MS';
  else if centerid='D' then state='NC';

run;

proc sort data=fhstroke_v1(keep=subject_id fh_stroke state);
 by subject_id;
run;

/**********************/
/* High sodium intake */
/**********************/
data hsod_v1(keep=subject_id sodium);
 set in1.pht004036_v2_anut2(keep=subject_id sodi);

 sodium = sodi;

run;

proc sort data=hsod_v1(keep=subject_id sodium);
 by subject_id;
run;


data hsod_v3(keep=subject_id sodium);
 set in1.pht004139_v2_nutv3(keep=subject_id sodi);  /* Visit 4, uses visit 3 data */

 sodium = sodi;

run;

proc sort data=hsod_v3(keep=subject_id sodium);
 by subject_id;
run;

/********************/
/* Carotid Stenosis */
/********************/
data carsten_v1(keep=subject_id carsten);
 set in1.pht004143_v2_phea(keep=subject_id phea10);

 if phea10 in ('L','R','B') then carsten=1;
  else if phea10='N' then carsten=0;

run;

proc sort data=carsten_v1(keep=subject_id carsten);
 by subject_id;
run;

proc freq data=carsten_v1;
 tables carsten;
 title 'ARIC visit 1';
run;


data carsten_v4(keep=subject_id carsten);
 set in1.pht004065_v2_derive47(keep=subject_id plaque42);

 if plaque42=1 then carsten=1;
  else if plaque42=0 then carsten=0;

run;

proc sort data=carsten_v4(keep=subject_id carsten);
 by subject_id;
run;

proc freq data=carsten_v4;
 tables carsten;
 title 'ARIC visit 4';
run;

/***********/
/* Alcohol */
/***********/
/* exam 1 */
data alco_v1(keep=subject_id alcohol);
 set in1.pht004068_v2_dtia(keep=subject_id dtia90 dtia96-dtia98);

 if dtia96 = 'A' then dtia96 = ' ';
 if dtia97 = 'A' then dtia97 = ' ';
 if dtia98 = 'A' then dtia98 = ' ';

 wine = input(dtia96,8.);
 beer = input(dtia97,8.);
 liq = input(dtia98,8.);

 if dtia90='N' then alcohol=0;
  else alcohol=round(sum(wine,beer,liq),1);
run;
proc sort data=alco_v1;
 by subject_id;
run;

/* exam 4 */
data alco_v4(keep=subject_id alcohol);
 set in1.pht004146_v2_phxb04(keep=subject_id phxb14 phxb15 phxb17a phxb18a phxb19a);

 if phxb14='N' or phxb15='N' then alcohol=0;
  else alcohol=round(sum(phxb17a,phxb18a,phxb19a),1);
run;
proc sort data=alco_v4;
 by subject_id;
run;


/**********/
/* Income */
/**********/
data income_v1(keep=subject_id fam_income hom62);
 set in1.pht004111_v2_hom(keep=subject_id hom62);

 if hom62='1' then fam_income=1;
  else if hom62='2' then fam_income=3;
  else if hom62='3' then fam_income=4;
  else if hom62='4' then fam_income=6;
  else if hom62='5' then fam_income=9;
  else if hom62='6' then fam_income=12;
  else if hom62='7' then fam_income=15;
  else if hom62='8' then fam_income=19;
  else if hom62='A' then fam_income=99;

 format fam_income faminc1a.;
run;

proc sort data=income_v1(keep=subject_id fam_income hom62);
 by subject_id;
run;

data income_v4(keep=subject_id fam_income sesa6);
 set in1.pht004196_v2_sesa04(keep=subject_id sesa6);

 if sesa6='A' then fam_income=1;
  else if sesa6='B' then fam_income=3;
  else if sesa6='C' then fam_income=4;
  else if sesa6='D' then fam_income=6;
  else if sesa6='E' then fam_income=9;
  else if sesa6='F' then fam_income=12;
  else if sesa6='G' then fam_income=15;
  else if sesa6='H' then fam_income=20;
  else if sesa6='I' then fam_income=21;
  else if sesa6='J' then fam_income=22;
  else if sesa6='R' then fam_income=99;

 format fam_income faminc4b.;
run;

proc sort data=income_v4(keep=subject_id fam_income sesa6);
 by subject_id;
run;

/*************************/
/* Fruits and Vegetables */
/*************************/
/* visit 1 */
data fruveg_v1(keep=subject_id fruits vegetables);
 set in1.pht004068_v2_dtia(keep=subject_id dtia09 dtia10 dtia12-dtia25);

 /* convert fruits and vegetables to servings per week */
 %macro cserv(food=,fserv=);
  if &food='A' then &fserv=42;
   else if &food='B' then &fserv=35;
   else if &food='C' then &fserv=17.5;
   else if &food='D' then &fserv=7;
   else if &food='E' then &fserv=5.5;
   else if &food='F' then &fserv=3;
   else if &food='G' then &fserv=1;
   else if &food='H' then &fserv=0.5;
   else if &food='I' then &fserv=0;
 %mend cserv;

 %cserv(food=dtia09,fserv=appsv);
 %cserv(food=dtia10,fserv=oransv);
 %cserv(food=dtia12,fserv=peachsv);
 %cserv(food=dtia13,fserv=bansv);
 %cserv(food=dtia14,fserv=othfrsv);

 %cserv(food=dtia15,fserv=grbnsv);
 %cserv(food=dtia16,fserv=brocsv);
 %cserv(food=dtia17,fserv=cabbsv);
 %cserv(food=dtia18,fserv=carrsv);
 %cserv(food=dtia19,fserv=cornsv);
 %cserv(food=dtia20,fserv=spinsv);
 %cserv(food=dtia21,fserv=peassv);
 %cserv(food=dtia22,fserv=wsqsv);
 %cserv(food=dtia23,fserv=yamssv);
 %cserv(food=dtia25,fserv=tomasv);
 %cserv(food=dtia24,fserv=lentsv);

  fruits=round(sum(appsv,oransv,peachsv,bansv,othfrsv),1);

  vegetables=round(sum(grbnsv,brocsv,cabbsv,carrsv,cornsv,spinsv,peassv,wsqsv,yamssv,tomasv,lentsv),1);


run;
proc sort data=fruveg_v1;
 by subject_id;
run;

/* visit 3 */
data fruveg_v3(keep=subject_id fruits vegetables);
 set in1.pht004070_v2_dtic04(keep=subject_id dtic9 dtic10 dtic12-dtic25);

 /* convert fruits and vegetables to servings per week */
 %macro cserv(food=,fserv=);
  if &food='A' then &fserv=42;
   else if &food='B' then &fserv=35;
   else if &food='C' then &fserv=17.5;
   else if &food='D' then &fserv=7;
   else if &food='E' then &fserv=5.5;
   else if &food='F' then &fserv=3;
   else if &food='G' then &fserv=1;
   else if &food='H' then &fserv=0.5;
   else if &food='I' then &fserv=0;
 %mend cserv;

 %cserv(food=dtic9,fserv=appsv);
 %cserv(food=dtic10,fserv=oransv);
 %cserv(food=dtic12,fserv=peachsv);
 %cserv(food=dtic13,fserv=bansv);
 %cserv(food=dtic14,fserv=othfrsv);

 %cserv(food=dtic15,fserv=grbnsv);
 %cserv(food=dtic16,fserv=brocsv);
 %cserv(food=dtic17,fserv=cabbsv);
 %cserv(food=dtic18,fserv=carrsv);
 %cserv(food=dtic19,fserv=cornsv);
 %cserv(food=dtic20,fserv=spinsv);
 %cserv(food=dtic21,fserv=peassv);
 %cserv(food=dtic22,fserv=wsqsv);
 %cserv(food=dtic23,fserv=yamssv);
 %cserv(food=dtic25,fserv=tomasv);
 %cserv(food=dtic24,fserv=lentsv);

  fruits=round(sum(appsv,oransv,peachsv,bansv,othfrsv),1);

  vegetables=round(sum(grbnsv,brocsv,cabbsv,carrsv,cornsv,spinsv,peassv,wsqsv,yamssv,tomasv,lentsv),1);


run;
proc sort data=fruveg_v3;
 by subject_id;
run;

/**********************************/
/* Physical Activity & Inactivity */
/**********************************/
/* visit 1 */
data rpaa1(keep=subject_id activity inactivity);
 set in1.pht004161_v2_rpaa02(keep=subject_id rpaa47 rpaa49 rpaa50 rpaa64 rpaa68 rpaa69);

 if rpaa47='N' and rpaa68 in ('N','L') and rpaa69 in ('N','L') then inactivity=1;
  else if rpaa47 ne ' ' and rpaa68 ne ' ' and rpaa69 ne ' ' then inactivity=0;

 if rpaa47='N' and rpaa68 in ('N','L') and rpaa69 in ('N','L') then activity=1;
  else if (rpaa47='Y' and rpaa49 in ('C','D','E') and rpaa50 in ('D','E')) or
          rpaa64 in ('O','V') or rpaa68 in ('O','V') or rpaa69 in ('O','V') then activity=3;
  else if rpaa47 ne ' ' and rpaa68 ne ' ' and rpaa69 ne ' ' then activity=2;

 format activity active.;
run;

/* visit 3 */
data rpac3(keep=subject_id activity inactivity);
 set in1.pht004163_v2_rpac04(keep=subject_id rpac8 rpac10 rpac11 rpac25 rpac29 rpac30);

 if rpac8='N' and rpac29 in ('N','L') and rpac30 in ('N','L') then inactivity=1;
  else if rpac8 ne ' ' and rpac29 ne ' ' and rpac30 ne ' ' then inactivity=0;

 if rpac8='N' and rpac29 in ('N','L') and rpac30 in ('N','L') then activity=1;
  else if (rpac8='Y' and rpac10 in ('C','D','E') and rpac11 in ('D','E')) or
          rpac25 in ('O','V') or rpac29 in ('O','V') or rpac30 in ('O','V') then activity=3;
  else if rpac8 ne ' ' and rpac29 ne ' ' and rpac30 ne ' ' then activity=2;

 format activity active.;
run;

proc sort data=rpaa1;
 by subject_id;
run;

proc sort data=rpac3;
 by subject_id;
run;


/**********/
/* EXAM 1 */
/**********/

proc sort data=in1.pht004063_v2_derive13(keep=dbGaP_Subject_ID subject_id v1age01 gender bmi01 cursmk01 diabts03 aspirincode01 cholmdcode01 statincode01 hyptmd01 hdl01 ldl02 glucos01 fast0802 fast1202 clvh01 mddxmi02 hxofmi02 prevhf01 roseic03 prvchd05 rangna01 pad02)
          out=derive13;
 by subject_id;
run;

proc sort data=in1.pht004032_v2_anta(keep=subject_id anta01 anta04)
          out=anta;
 by subject_id;
run;

proc sort data=in1.pht004192_v2_sbpa02(keep=subject_id sbpa21 sbpa22)
          out=sbpa02;
 by subject_id;
run;

proc sort data=in1.pht004121_v2_lipa(keep=subject_id lipa01 lipa02)
          out=lipa;
 by subject_id;
run;

proc sort data=in1.pht004051_v2_chma(keep=subject_id chma09)
          out=chma;
 by subject_id;
run;

data insul_v1;

   set in1.pht004132_v2_msrcod07;



   array medname {17} msra04aa msra04ba msra04ca msra04da msra04ea msra04fa msra04ga msra04ha msra04ia msra04ja
                      msra04ka msra04la msra04ma msra04na msra04oa msra04pa msra04qa;


   do i=1 to 17;

    if medname{i} ne ' ' and put(substr(medname{i},1,26),$insuln.)='1' then do;
          insulin=1;
          output;
    end;

   end;

   keep subject_id insulin;

 run;

proc sort data=insul_v1 nodupkey;
 by subject_id;
run;


proc sort data=in1.pht004063_v2_derive13(keep=subject_id) out=v1base_ft nodupkey;
 by subject_id;
run;


data insul_v1;
 merge v1base_ft(in=a)
       insul_v1(in=b);
 by subject_id;

 if a;

 if a and not b then insulin=0;

run;

/* Get level of education and general health V1 */
proc sort data =in1.pht004111_v2_hom(keep=subject_id hom54 hom09) out=educ_v1;
 by subject_id;
run;

data educ_v1(drop=hom54 hom09);
 set educ_v1;
  by subject_id;

 if (. < hom54 < 12) then educlev=1;
  else if hom54 in (12,13) then educlev=2;
  else if (13 < hom54 <= 19) then educlev=3;
  else if hom54 in (20,21) then educlev=4;

 if hom09='E' then genhlth=1;
  else if hom09='G' then genhlth=2;
  else if hom09='F' then genhlth=3;
  else if hom09='P' then genhlth=4;


 format educlev educf. genhlth genhel.;

run;


data aric_ex1(drop=anta01 anta04 sbpa21 sbpa22 cholmdcode01 cursmk01 diabts03 hyptmd01 fast0802 fast1202 ft11afinc af t2mi mddxmi02 hxofmi02 mdmi homi prevhf01 t2chf roseic03 prvchd05 rangna01 t2cproc hxcproc pad02);
 length hxcvd hxhrtd hxmi $3;
 merge derive13(keep=dbGaP_Subject_ID subject_id v1age01 gender bmi01 cursmk01 diabts03 aspirincode01 cholmdcode01 statincode01 hyptmd01 hdl01 ldl02 glucos01 fast0802 fast1202 clvh01 mddxmi02 hxofmi02 prevhf01 roseic03 prvchd05 rangna01 pad02 in=a)
       anta(keep=subject_id anta01 anta04)
       sbpa02(keep=subject_id sbpa21 sbpa22)
       lipa(keep=subject_id lipa01 lipa02)
       chma(keep=subject_id chma09)
       insul_v1(keep=subject_id insulin)
       educ_v1(keep=subject_id educlev genhlth)
       basecvd(keep=subject_id base_cvd)
       basestroke(keep=subject_id base_stroke)
       survdth(keep=subject_id censday death_ind)
       incafps11(keep=subject_id ft11afinc)
       afex1(keep=subject_id af)
       incps16(keep=subject_id t2mi)
       inchf(keep=subject_id t2chf)
       cproc(keep=subject_id t2cproc);

  by subject_id;

  if a;

 visit = 'EXAM1';
 visday = 0;

 if cursmk01 = 'T' then cursmk01 = ' ';
 if diabts03 = 'T' then diabts03 = ' ';
 if cholmdcode01 = 'T' then cholmdcode01 = ' ';
 if hyptmd01 = 'T' then hyptmd01 = ' ';
 if fast0802 = 'T' then fast0802 = ' ';
 if fast1202 = 'T' then fast1202 = ' ';
 if mddxmi02 = 'T' then mddxmi02 = ' ';
 if hxofmi02 = 'T' then hxofmi02 = ' ';
 if anta01 = 'A' then anta01 = ' ';
 if anta04 = 'A' then anta04 = ' ';
 if sbpa21 = 'A' then sbpa21 = ' ';
 if sbpa22 = 'A' then sbpa22 = ' ';


 htcm = input(anta01,8.);
 wgt = input(anta04,8.);
 sysbp = input(sbpa21,8.);
 diabp = input(sbpa22,8.);
 cholmed = input(cholmdcode01,8.);
 currsmk = input(cursmk01,8.);
 diabetes = input(diabts03,8.);
 fasting_8hr = input(fast0802,8.);
 fasting_12hr = input(fast1202,8.);
 mdmi = input(mddxmi02,8.);
 homi = input(hxofmi02,8.);
 hrx = input(hyptmd01,8.);

 if (. < ft11afinc <= visday) or af=1 then atrfib=1;
  else atrfib=0;

 if (. < t2mi <= visday) or mdmi=1 or homi=1 then hxmi='YES';
  else hxmi='NO';

 if (. < t2chf <= visday) or prevhf01=1 then hxchf=1;
  else hxchf=0;

if (. < t2cproc <= visday) then hxcproc=1;
  else hxcproc=0;

 if hxmi='YES' or hxchf=1 or roseic03='1' or prvchd05=1 or rangna01=1 or base_cvd='YES'
  then hxcvd='YES';
  else hxcvd='NO';

 if hxmi='YES' or hxchf=1 or hxcproc=1 or pad02=1 or rangna01=1 or base_cvd='YES'
  then hxhrtd='YES';
  else hxhrtd='NO';

 label v1age01 = 'Age'
       aspirincode01 = 'Taking aspirin (0=No, 1=Yes)'
       bmi01 = 'Body mass index (kg/m2)'
       chma09 = 'Creatinine (mg/dL)'
       cholmed = 'Taking cholesterol lowering medication (0=No, 1=Yes)'
       currsmk = 'Current cigarette smoker (0=No, 1=Yes)'
       atrfib = 'Atrial fibrillation (0=No, 1=Yes)'
       hxmi = 'History of MI'
       hxcvd = 'History of cardiovascular disease'
       hxhrtd = 'History of heart disease'
       hxchf = 'History of CHF (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diabetes = 'Diabetes - lower cut point 126 [mg/dL] (0=No, 1=Yes)'
       clvh01 = 'Left ventricular hypertrophy'
       fasting_8hr = 'Fasting time of 8 hours or more (0=No, 1=Yes)'
       fasting_12hr = 'Fasting time of 12 hours or more (0=No, 1=Yes)'
       educlev = 'Education level (1=Less than High School, 2=High School, 3=Some College, 4=College)'
       genhlth = 'General Health (Exams 1 & 5, 4-category)'
       diabp = 'Seated diastolic blood pressure (MM HG)'
       glucos01 = 'Glucose value in mg/dL'
       hdl01 = 'HDL cholesterol (recalibrated lipid)'
       htcm = 'Standing height (to the nearest cm)'
       hrx = 'Taking blood pressure lowering medication (0=No, 1=Yes)'
       insulin = 'Taking insulin (0=No, 1=Yes)'
       ldl02 = 'Recalibrated LDL cholesterol'
       gender = 'Participant gender'
       subject_id = 'ARIC subject ID'
       sysbp = 'Seated systolic blood pressure (MM HG)'
       lipa01 = 'Total cholesterol (mg/dL)'
       lipa02 = 'Total Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wgt = 'Weight (to the nearest lb)'
       statincode01 = 'Taking statin (0=No, 1=Yes)'
       base_cvd = 'Baseline CVD'
       base_stroke = 'Baseline Stroke/TIA (0=No, 1=TIA, 2=Stroke)'
       censday = 'Censor day'
       death_ind = 'Death indicator';

 rename v1age01 = age
        aspirincode01 = aspirin
        bmi01 = bmi
        chma09 = creat
        glucos01 = glucose
        hdl01 = hdl
        ldl02 = ldl
        lipa01 = tc
        lipa02 = trig
        statincode01 = statin
        clvh01 = lvh;

run;


/**********/
/* EXAM 2 */
/**********/

proc sort data=in1.pht004062_v2_derive2_10(keep=dbGaP_Subject_ID subject_id v2age22 gender bmi21 cursmk21 diabts23 aspirincode21 cholmdcode21 statincode21 hyptmd21 ldl22 v2days fast0823 fast1223 clvh21 mddxmi21 hxofmi21)
          out=derive2_10;
 by subject_id;
run;

proc sort data=in1.pht004033_v2_antb(keep=subject_id /*anta01*/ antb01)
          out=antb;
 by subject_id;
run;

proc sort data=in1.pht004193_v2_sbpb02(keep=subject_id sbpb21 sbpb22)
          out=sbpb02;
 by subject_id;
run;

proc sort data=in1.pht004122_v2_lipb(keep=subject_id lipb03a lipb01a lipb02a)
          out=lipb;
 by subject_id;
run;

proc sort data=in1.pht004052_v2_chmb(keep=subject_id chmb07 chmb08)
          out=chmb;
 by subject_id;
run;

data insul_v2;

   set in1.pht004133_v2_msrcod26;



   array medname {17} msrb04a msrb05a msrb06a msrb07a msrb08a msrb09a msrb10a msrb11a msrb12a msrb13a
                      msrb14a msrb15a msrb16a msrb17a msrb18a msrb19a msrb20a;


   do i=1 to 17;

    if medname{i} ne ' ' and put(substr(medname{i},1,26),$insuln.)='1' then do;
          insulin=1;
          output;
    end;

   end;

   keep subject_id insulin;

 run;

proc sort data=insul_v2 nodupkey;
 by subject_id;
run;


proc sort data=in1.pht004062_v2_derive2_10(keep=subject_id) out=v2base_ft nodupkey;
 by subject_id;
run;


data insul_v2;
 merge v2base_ft(in=a)
       insul_v2(in=b);
 by subject_id;

 if a;

 if a and not b then insulin=0;

run;


data aric_ex2(drop=antb01 sbpb21 sbpb22 cholmdcode21 cursmk21 diabts23 hyptmd21 lipb01a lipb02a lipb03a v2days fast0823 fast1223 ft11afinc af mddxmi21 hxofmi21 t2mi t2chf prevhf01);
 length hxmi $3;
 merge derive2_10(keep=dbGaP_Subject_ID subject_id v2age22 gender bmi21 cursmk21 diabts23 aspirincode21 cholmdcode21 statincode21 hyptmd21 ldl22 v2days
                       fast0823 fast1223 clvh21 mddxmi21 hxofmi21 in=a)
       antb(keep=subject_id antb01)
       sbpb02(keep=subject_id sbpb21 sbpb22)
       lipb(keep=subject_id lipb03a lipb01a lipb02a)
       chmb(keep=subject_id chmb07 chmb08)
       insul_v2(keep=subject_id insulin)
       incafps11(keep=subject_id ft11afinc)
       afex2(keep=subject_id af)
       incps16(keep=subject_id t2mi)
       inchf(keep=subject_id t2chf)
       basechf;

  by subject_id;

 if a;

 visit = 'EXAM2';
 visday = v2days;


 if cursmk21 = 'T' then cursmk21 = ' ';
 if diabts23 = 'T' then diabts23 = ' ';
 if cholmdcode21 = 'T' then cholmdcode21 = ' ';
 if hyptmd21 = 'T' then hyptmd21 = ' ';
 if fast0823 = 'T' then fast0823 = ' ';
 if fast1223 = 'T' then fast1223 = ' ';
 if antb01 in ('A','O') then antb01 = ' ';
 if sbpb21 = 'A' then sbpb21 = ' ';
 if sbpb22 = 'A' then sbpb22 = ' ';
 if lipb03a = 'A' then lipb03a = ' ';
 if lipb01a = 'A' then lipb01a = ' ';
 if lipb02a = 'A' then lipb02a = ' ';

 *htcm = input(anta01,8.);
 wgt = input(antb01,8.);
 sysbp = input(sbpb21,8.);
 diabp = input(sbpb22,8.);
 cholmed = input(cholmdcode21,8.);
 currsmk = input(cursmk21,8.);
 fasting_8hr = input(fast0823,8.);
 fasting_12hr = input(fast1223,8.);
 diabetes = input(diabts23,8.);
 hrx = input(hyptmd21,8.);
 hdl = input(lipb03a,8.);
 tc = input(lipb01a,8.);
 trig = input(lipb02a,8.);

 if (. < ft11afinc <= visday)or af=1 then atrfib=1;
  else atrfib=0;

 if (. < t2mi <= visday) or mddxmi21=1 or hxofmi21=1 then hxmi='YES';
  else hxmi='NO';

 if (. < t2chf <= visday) or prevhf01=1 then hxchf=1;
  else hxchf=0;

 label v2age22 = 'Age'
       aspirincode21 = 'Taking aspirin (0=No, 1=Yes)'
       bmi21 = 'Body mass index (kg/m2)'
       chmb08 = 'Creatinine (mg/dL)'
       cholmed = 'Taking cholesterol lowering medication (0=No, 1=Yes)'
       currsmk = 'Current cigarette smoker (0=No, 1=Yes)'
       atrfib = 'Atrial fibrillation (0=No, 1=Yes)'
       hxmi = 'History of MI'
       hxchf = 'History of CHF (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diabetes = 'Diabetes - lower cut point 126 [mg/dL] (0=No, 1=Yes)'
       clvh21 = 'Left ventricular hypertrophy'
       fasting_8hr = 'Fasting time of 8 hours or more (0=No, 1=Yes)'
       fasting_12hr = 'Fasting time of 12 hours or more (0=No, 1=Yes)'
       diabp = 'Seated diastolic blood pressure (MM HG)'
       chmb07 = 'Glucose value in mg/dL'
       hdl = 'HDL cholesterol (recalibrated lipid)'
       hrx = 'Taking blood pressure lowering medication (0=No, 1=Yes)'
       insulin = 'Taking insulin (0=No, 1=Yes)'
       ldl22 = 'Recalibrated LDL cholesterol'
       gender = 'Participant gender'
       subject_id = 'ARIC subject ID'
       sysbp = 'Seated systolic blood pressure (MM HG)'
       tc = 'Total cholesterol (mg/dL)'
       trig = 'Total Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wgt = 'Weight (to the nearest lb)'
       statincode21 = 'Taking statin (0=No, 1=Yes)';

 rename v2age22 = age
        aspirincode21 = aspirin
        bmi21 = bmi
        chmb08 = creat
        chmb07 = glucose
        ldl22 = ldl
        statincode21 = statin
        clvh21 = lvh;

run;

/**********/
/* EXAM 3 */
/**********/

proc sort data=in1.pht004064_v2_derive37(keep=dbGaP_Subject_ID subject_id v3age31 /*gender*/ bmi32 cursmk31 diabts34 aspirincode31 cholmdcode31 statincode31 hyptmd31 ldl32 v3days fast0834 fast1234 clvh31 mddxmi31 hxofmi31 prvchd33 pad32)
          out=derive37;
 by subject_id;
run;

proc sort data=in1.pht004034_v2_antc04(keep=subject_id antc1 antc2)
          out=antc;
 by subject_id;
run;

proc sort data=in1.pht004194_v2_sbpc04_02(keep=subject_id sbpc22 sbpc23)
          out=sbpc04_02;
 by subject_id;
run;

proc sort data=in1.pht004123_v2_lipc04(keep=subject_id lipc3a lipc1a lipc2a lipc4a)
          out=lipc04;
 by subject_id;
run;


data insul_v3;

   set in1.pht004131_v2_msrc04;



   array medname {17} msrc4a msrc5a msrc6a msrc7a msrc8a msrc9a msrc10a msrc11a msrc12a msrc13a
                      msrc14a msrc15a msrc16a msrc17a msrc18a msrc19a msrc20a;


   do i=1 to 17;

    if medname{i} ne ' ' and put(substr(medname{i},1,26),$insuln.)='1' then do;
          insulin=1;
          output;
    end;

   end;

   keep subject_id insulin;

 run;

proc sort data=insul_v3 nodupkey;
 by subject_id;
run;


proc sort data=in1.pht004064_v2_derive37(keep=subject_id) out=v3base_ft nodupkey;
 by subject_id;
run;


data insul_v3;
 merge v3base_ft(in=a)
       insul_v3(in=b);
 by subject_id;

 if a;

 if a and not b then insulin=0;

run;

proc sort data=in1.pht004104_v2_hhxc04(keep=subject_id hhxc1) out=angex3 nodupkey;
 by subject_id;
run;

data aric_ex3(drop=cholmdcode31 cursmk31 diabts34 hyptmd31 v3days fast0834 fast1234 ft11afinc af mddxmi31 hxofmi31 homi t2mi t2chf prevhf01 prvchd33 t2cproc hxcproc pad32 hhxc1 base_cvd);
 length hxcvd hxhrtd hxmi $3;
 merge derive37(keep=dbGaP_Subject_ID subject_id v3age31 bmi32 cursmk31 diabts34 aspirincode31 cholmdcode31 statincode31 hyptmd31 ldl32 v3days
                     fast0834 fast1234 clvh31 mddxmi31 hxofmi31 prvchd33 pad32 in=a)
       antc(keep=subject_id antc1 antc2)
       sbpc04_02(keep=subject_id sbpc22 sbpc23)
       lipc04(keep=subject_id lipc3a lipc1a lipc2a lipc4a)
       insul_v3(keep=subject_id insulin)
       incafps11(keep=subject_id ft11afinc)
       afex3(keep=subject_id af)
       angex3(keep=subject_id hhxc1)
       incps16(keep=subject_id t2mi)
       inchf(keep=subject_id t2chf)
       basecvd
       basechf
       cproc(keep=subject_id t2cproc);

  by subject_id;

  if a;

 visit = 'EXAM3';
 visday = v3days;

 if cursmk31 = 'T' then cursmk31 = ' ';
 if diabts34 = 'T' then diabts34 = ' ';
 if cholmdcode31 = 'T' then cholmdcode31 = ' ';
 if hyptmd31 = 'T' then hyptmd31 = ' ';
 if fast0834 = 'T' then fast0834 = ' ';
 if fast1234 = 'T' then fast1234 = ' ';
 if hxofmi31 = 'T' then hxofmi31 = ' ';

 cholmed = input(cholmdcode31,8.);
 currsmk = input(cursmk31,8.);
 diabetes = input(diabts34,8.);
 homi = input(hxofmi31,8.);
 hrx = input(hyptmd31,8.);
 fasting_8hr = input(fast0834,8.);
 fasting_12hr = input(fast1234,8.);

 if (. < ft11afinc <= visday) or af=1 then atrfib=1;
  else atrfib=0;

 if (. < t2mi <= visday) or mddxmi31=1 or homi=1 then hxmi='YES';
  else hxmi='NO';

 if (. < t2chf <= visday) or prevhf01=1 then hxchf=1;
  else hxchf=0;

 if (. < t2cproc <= visday) then hxcproc=1;
  else hxcproc=0;

 if hxmi='YES' or hxchf=1 or /*roseic03='1' or*/ prvchd33=1 or hhxc1='Y' or base_cvd='YES'
  then hxcvd='YES';
  else hxcvd='NO';

 if hxmi='YES' or hxchf=1 or hxcproc=1 or pad32=1 or hhxc1='Y' or base_cvd='YES'
  then hxhrtd='YES';
  else hxhrtd='NO';

 label v3age31 = 'Age'
       aspirincode31 = 'Taking aspirin (0=No, 1=Yes)'
       bmi32 = 'Body mass index (kg/m2)'
       cholmed = 'Taking cholesterol lowering medication (0=No, 1=Yes)'
       currsmk = 'Current cigarette smoker (0=No, 1=Yes)'
       atrfib = 'Atrial fibrillation (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diabetes = 'Diabetes - lower cut point 126 [mg/dL] (0=No, 1=Yes)'
       fasting_8hr = 'Fasting time of 8 hours or more (0=No, 1=Yes)'
       fasting_12hr = 'Fasting time of 12 hours or more (0=No, 1=Yes)'
       clvh31 = 'Left ventricular hypertrophy'
       sbpc23 = 'Seated diastolic blood pressure (MM HG)'
       lipc4a = 'Glucose value in mg/dL'
       lipc3a = 'HDL cholesterol (recalibrated lipid)'
       antc1 = 'Standing height (to the nearest cm)'
       hxmi = 'History of MI'
       hxchf = 'History of CHF (0=No, 1=Yes)'
       hxcvd = 'History of cardiovascular disease'
       hxhrtd = 'History of heart disease'
       hrx = 'Taking blood pressure lowering medication (0=No, 1=Yes)'
       insulin = 'Taking insulin (0=No, 1=Yes)'
       ldl32 = 'Recalibrated LDL cholesterol'
       subject_id = 'ARIC subject ID'
       sbpc22 = 'Seated systolic blood pressure (MM HG)'
       lipc1a = 'Total cholesterol (mg/dL)'
       lipc2a = 'Total Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       antc2 = 'Weight (to the nearest lb)'
       statincode31 = 'Taking statin (0=No, 1=Yes)';

 rename v3age31 = age
        aspirincode31 = aspirin
        bmi32 = bmi
        sbpc23 = diabp
        sbpc22 = sysbp
        lipc4a = glucose
        lipc3a = hdl
        lipc1a = tc
        lipc2a = trig
        antc1 = htcm
        antc2 = wgt
        ldl32 = ldl
        statincode31 = statin
        clvh31 = lvh;

run;

/**********/
/* EXAM 4 */
/**********/

proc sort data=in1.pht004065_v2_derive47(keep=dbGaP_Subject_ID subject_id v4age41 gender bmi41 cursmk41 diabts42 aspirincode41 cholmdcode41 statincode41 hyptmd41 ldl41 v4days clvh41 mddxmi41 hxofmi41 prvchd43 pad42)
          out=derive47;
 by subject_id;
run;

proc sort data=in1.pht004035_v2_antd05(keep=subject_id antd1 antd2)
          out=antd;
 by subject_id;
run;

proc sort data=in1.pht004195_v2_sbpd04_02(keep=subject_id sbpd19 sbpd20)
          out=sbpd04_02;
 by subject_id;
run;

proc sort data=in1.pht004124_v2_lipd04(keep=subject_id lipd3a lipd1a lipd2a lipd4a)
          out=lipd04;
 by subject_id;
run;


data insul_v4;

   set in1.pht004136_v2_msrd04;



   array medname {17} msrd4a msrd5a msrd6a msrd7a msrd8a msrd9a msrd10a msrd11a msrd12a msrd13a
                      msrd14a msrd15a msrd16a msrd17a msrd18a msrd19a msrd20a;


   do i=1 to 17;

    if medname{i} ne ' ' and put(substr(medname{i},1,26),$insuln.)='1' then do;
          insulin=1;
          output;
    end;

   end;

   keep subject_id insulin;

 run;

proc sort data=insul_v4 nodupkey;
 by subject_id;
run;


proc sort data=in1.pht004065_v2_derive47(keep=subject_id) out=v4base_ft nodupkey;
 by subject_id;
run;


data insul_v4;
 merge v4base_ft(in=a)
       insul_v4(in=b);
 by subject_id;

 if a;

 if a and not b then insulin=0;

run;

proc sort data=in1.pht004106_v2_hhxd04(keep=subject_id hhxd1) out=angex4 nodupkey;
 by subject_id;
run;

data aric_ex4(drop=cholmdcode41 cursmk41 diabts42 hyptmd41 v4days ft11afinc af mddxmi41 hxofmi41 t2mi t2chf prevhf01 prvchd43 t2cproc hxcproc pad42 hhxd1 base_cvd);
 length hxcvd hxhrtd hxmi $3;
 merge derive47(keep=dbGaP_Subject_ID subject_id v4age41 gender bmi41 cursmk41 diabts42 aspirincode41 cholmdcode41 statincode41 hyptmd41 ldl41 v4days clvh41 mddxmi41 hxofmi41 prvchd43 pad42 in=a)
       antd(keep=subject_id antd1 antd2)
       sbpd04_02(keep=subject_id sbpd19 sbpd20)
       lipd04(keep=subject_id lipd3a lipd1a lipd2a lipd4a)
       insul_v4(keep=subject_id insulin)
       incafps11(keep=subject_id ft11afinc)
       afex4(keep=subject_id af)
       angex4(keep=subject_id hhxd1)
       incps16(keep=subject_id t2mi)
       inchf(keep=subject_id t2chf)
       basecvd
       basechf
       cproc(keep=subject_id t2cproc);

  by subject_id;

  if a;

 visit = 'EXAM4';
 visday = v4days;

 if cursmk41 = 'T' then cursmk41 = ' ';
 if diabts42 = 'T' then diabts42 = ' ';
 if cholmdcode41 = 'T' then cholmdcode41 = ' ';
 if hyptmd41 = 'T' then hyptmd41 = ' ';

 cholmed = input(cholmdcode41,8.);
 currsmk = input(cursmk41,8.);
 diabetes = input(diabts42,8.);
 hrx = input(hyptmd41,8.);

 if (. < ft11afinc <= visday) or af=1 then atrfib=1;
  else atrfib=0;

 if (. < t2mi <= visday) or mddxmi41=1 or hxofmi41=1 then hxmi='YES';
  else hxmi='NO';

 if (. < t2chf <= visday) or prevhf01=1 then hxchf=1;
  else hxchf=0;

 if (. < t2cproc <= visday) then hxcproc=1;
  else hxcproc=0;

 if hxmi='YES' or hxchf=1 or /*roseic03='1' or*/ prvchd43=1 or hhxd1='Y' or base_cvd='YES'
  then hxcvd='YES';
  else hxcvd='NO';

 if hxmi='YES' or hxchf=1 or hxcproc=1 or pad42=1 or hhxd1='Y' or base_cvd='YES'
  then hxhrtd='YES';
  else hxhrtd='NO';

 label v4age41 = 'Age'
       aspirincode41 = 'Taking aspirin (0=No, 1=Yes)'
       bmi41 = 'Body mass index (kg/m2)'
       cholmed = 'Taking cholesterol lowering medication (0=No, 1=Yes)'
       currsmk = 'Current cigarette smoker (0=No, 1=Yes)'
       atrfib = 'Atrial fibrillation (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diabetes = 'Diabetes - lower cut point 126 [mg/dL] (0=No, 1=Yes)'
       sbpd20 = 'Seated diastolic blood pressure (MM HG)'
       lipd4a = 'Glucose value in mg/dL'
       lipd3a = 'HDL cholesterol (recalibrated lipid)'
       antd1 = 'Standing height (to the nearest cm)'
       hrx = 'Taking blood pressure lowering medication (0=No, 1=Yes)'
       hxmi = 'History of MI'
       hxchf = 'History of CHF (0=No, 1=Yes)'
       hxcvd = 'History of cardiovascular disease'
       hxhrtd = 'History of heart disease'
       clvh41 = 'Left ventricular hypertrophy'
       insulin = 'Taking insulin (0=No, 1=Yes)'
       ldl41 = 'Recalibrated LDL cholesterol'
       gender = 'Participant gender'
       subject_id = 'ARIC subject ID'
       sbpd19 = 'Seated systolic blood pressure (MM HG)'
       lipd1a = 'Total cholesterol (mg/dL)'
       lipd2a = 'Total Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       antd2 = 'Weight (to the nearest lb)'
       statincode41 = 'Taking statin (0=No, 1=Yes)';

 rename v4age41 = age
        aspirincode41 = aspirin
        bmi41 = bmi
        sbpd20 = diabp
        sbpd19 = sysbp
        lipd4a = glucose
        lipd3a = hdl
        lipd1a = tc
        lipd2a = trig
        antd1 = htcm
        antd2 = wgt
        ldl41 = ldl
        statincode41 = statin
        clvh41 = lvh;

run;

/**********/
/* EXAM 5 */
/**********/

proc sort data=in1.pht006431_v1_derv(keep=dbGaP_Subject_ID subject_id age_stage_1 gender bmi current_smoker diabetes_c3 /*v4days*/where=(age_stage_1 ne .))
          out=derive51;
 by subject_id;
run;

proc sort data=in1.pht006453_v1_msr(keep=subject_id msrf33d msrf33e msrf34)
          out=msr5;
 by subject_id;
run;

proc sort data=in1.pht006419_v1_ant(keep=subject_id ant3 ant4)
          out=ant5;
 by subject_id;
run;

proc sort data=in1.pht006480_v1_sbp(keep=subject_id sbp14 sbp15)
          out=sbp5;
 by subject_id;
run;

proc sort data=in1.pht006444_v1_lip(keep=subject_id lip13 lip3 lip8 lip23 lip18)
          out=lip5;
 by subject_id;
run;

proc sort data=in1.pht006427_v1_chm(keep=subject_id chm21)
          out=chm5;
 by subject_id;
run;

data insul_v5;

   set in1.pht006454_v1_msrcod51;



   array medname {25} msrcod5a msrcod6a msrcod7a msrcod8a msrcod9a msrcod10a msrcod11a msrcod12a msrcod13a msrcod14a
                      msrcod15a msrcod16a msrcod17a msrcod18a msrcod19a msrcod20a msrcod21a msrcod22a msrcod23a msrcod24a
                      msrcod25a msrcod26a msrcod27a msrcod28a msrcod29a;

   array medcode {25} code5a2 code6a2 code7a2 code8a2 code9a2 code10a2 code11a2 code12a2 code13a2 code14a2 code15a2 code16a2 code17a2
                      code18a2 code19a2 code20a2 code21a2 code22a2 code23a2 code24a2 code25a2 code26a2 code27a2 code28a2 code29a2;

   do i=1 to 25;

    if medname{i} ne ' ' and put(substr(medname{i},1,26),$insuln.)='1' then do;
          insulin=1;
          output;
    end;

   end;

   keep subject_id insulin;

 run;

proc sort data=insul_v5 nodupkey;
 by subject_id;
run;


proc sort data=derive51(keep=subject_id) out=v5base_ft nodupkey;
 by subject_id;
run;


data insul_v5;
 merge v5base_ft(in=a)
       insul_v5(in=b);
 by subject_id;

 if a;

 if a and not b then insulin=0;

run;


data statin_v5;

   set in1.pht006454_v1_msrcod51;



   array medname {25} msrcod5a msrcod6a msrcod7a msrcod8a msrcod9a msrcod10a msrcod11a msrcod12a msrcod13a msrcod14a
                      msrcod15a msrcod16a msrcod17a msrcod18a msrcod19a msrcod20a msrcod21a msrcod22a msrcod23a msrcod24a
                      msrcod25a msrcod26a msrcod27a msrcod28a msrcod29a;

   array medcode {25} code5a2 code6a2 code7a2 code8a2 code9a2 code10a2 code11a2 code12a2 code13a2 code14a2 code15a2 code16a2 code17a2
                      code18a2 code19a2 code20a2 code21a2 code22a2 code23a2 code24a2 code25a2 code26a2 code27a2 code28a2 code29a2;

   do i=1 to 25;

    if medcode{i} in (3940001010,3940003010,3940005000,3940006510,3940006010,3940007500,3940990245,3940990270,3999400230,4099250215) then do;
          statin_v5=1;
          output;
    end;

   end;

   keep subject_id statin_v5;

 run;

proc sort data=statin_v5 nodupkey;
 by subject_id;
run;

data statin_v5;
 merge v5base_ft(in=a)
       statin_v5(in=b);
 by subject_id;

 if a;

 if a and not b then statin_v5=0;

run;

/* Get general health V5 */
proc sort data =in1.pht006481_v1_sfe(keep=subject_id sfe1) out=genhel_v5;
 by subject_id;
run;

data genhel_v5(drop=sfe1);
 set genhel_v5;
  by subject_id;

 genhlth2=sfe1;

 format genhlth2 genhelb.;

run;

data aric_ex5(drop=msrf33d msrf33e msrf34 diabetes_c3 ant4);
 merge derive51(keep=dbGaP_Subject_ID subject_id age_stage_1 gender bmi current_smoker diabetes_c3 in=a)
       msr5(keep=subject_id msrf33d msrf33e msrf34)
       ant5(keep=subject_id ant3 ant4)
       sbp5(keep=subject_id sbp14 sbp15)
       lip5(keep=subject_id lip13 lip3 lip8 lip23 lip18)
       chm5(keep=subject_id chm21)
       insul_v5(keep=subject_id insulin)
       statin_v5(keep=subject_id statin_v5)
       genhel_v5(keep=subject_id genhlth2);

  by subject_id;

 if a;

 visit = 'EXAM5';
 visday = . ;

 if msrf33d = 'N' then hrx=0;
  else if msrf33d = 'Y' then hrx=1;
  else if msrf33d in ('U',' ') then hrx=.;

 if msrf33e = 'N' then cholmed=0;
  else if msrf33e = 'Y' then cholmed=1;
  else if msrf33e in ('U',' ') then cholmed=.;

 if msrf34 = 'N' then aspirin=0;
  else if msrf34 = 'Y' then aspirin=1;
  else if msrf34 in (' ') then aspirin=.;

 if diabetes_c3 in (1,2) then diabetes=0;
  else if diabetes_c3 = 3 then diabetes=1;


 /* convert KG weight to LBS */

 wgt = round((ant4*2.20462),1);

 label age_stage_1 = 'Age'
       aspirin = 'Taking aspirin (0=No, 1=Yes)'
       bmi = 'Body mass index (kg/m2)'
       cholmed = 'Taking cholesterol lowering medication (0=No, 1=Yes)'
       current_smoker = 'Current cigarette smoker (0=No, 1=Yes)'
       dbGaP_Subject_ID = 'dbGaP Subject ID'
       diabetes = 'Diabetes - lower cut point 126 [mg/dL] (0=No, 1=Yes)'
       sbp15 = 'Seated diastolic blood pressure (MM HG)'
       lip23 = 'Glucose value in mg/dL'
       lip13 = 'HDL cholesterol (recalibrated lipid)'
       chm21 = 'Creatinine (mg/dL)'
       ant3 = 'Standing height (to the nearest cm)'
       hrx = 'Taking blood pressure lowering medication (0=No, 1=Yes)'
       insulin = 'Taking insulin (0=No, 1=Yes)'
       genhlth2 = 'General Health (Exams 1 & 5, 5-category)'
       lip18 = 'Recalibrated LDL cholesterol'
       gender = 'Participant gender'
       subject_id = 'ARIC subject ID'
       sbp14 = 'Seated systolic blood pressure (MM HG)'
       lip3 = 'Total cholesterol (mg/dL)'
       lip8 = 'Total Triglycerides (mg/dL)'
       visday = 'Visit day (days since exam 1)'
       visit = 'Visit'
       wgt = 'Weight (to the nearest lb)'
       statin_v5 = 'Taking statin (0=No, 1=Yes)';

 rename age_stage_1 = age
        current_smoker = currsmk
        sbp15 = diabp
        sbp14 = sysbp
        lip23 = glucose
        lip13 = hdl
        chm21 = creat
        lip3 = tc
        lip8 = trig
        ant3 = htcm
        lip18 = ldl
        statin_v5 = statin;

run;



/* The rough DERV version of the visit 5 derived dataset contains excess patients who were not included */
/* in the previous visits.  The following step removes these 25 patients.                               */
data aric_ex5;
 merge aric_ex5(in=a)
       aric_ex1(in=b keep=subject_id);

 by subject_id;

 if a and b;
run;



/*****************************************/
/* Merge in New Variables for exams 1, 4 */
/*****************************************/
data aric_ex1;
 merge aric_ex1(in=a)
       fhstroke_v1(keep=subject_id fh_stroke state)
       hsod_v1(keep=subject_id sodium)
       carsten_v1(keep=subject_id carsten)
       income_v1(keep=subject_id fam_income)
       alco_v1(keep=subject_id alcohol)
       fruveg_v1(keep=subject_id fruits vegetables)
       rpaa1;

 by subject_id;
 if a;


 label fh_stroke = 'Family history of stroke, Mother or Father (0=No, 1=Yes)'
       sodium = 'Sodium intake (mg/day)'
       carsten = 'Carotid stenosis (0=No, 1=Yes)'
       fam_income = 'Family income'
       alcohol = 'Alcohol (servings per week)'
       fruits = 'Fruits (servings per week)'
       vegetables = 'Vegetables (servings per week)'
       state = 'Site location (state)'
       inactivity = 'Physical inactivity (0=No, 1=Yes)'
       activity = 'Physical activity (3-levels)';

run;


data aric_ex4;
 merge aric_ex4(in=a)
       fhstroke_v1(keep=subject_id state)
       hsod_v3(keep=subject_id sodium)
       carsten_v4(keep=subject_id carsten)
       income_v4(keep=subject_id fam_income)
       alco_v4(keep=subject_id alcohol)
       fruveg_v3(keep=subject_id fruits vegetables)
       rpac3;

 by subject_id;
 if a;


 label sodium = 'Sodium intake (mg/day)'
       carsten = 'Carotid stenosis (0=No, 1=Yes)'
       fam_income = 'Family income'
       alcohol = 'Alcohol (servings per week)'
       fruits = 'Fruits (servings per week)'
       vegetables = 'Vegetables (servings per week)'
       state = 'Site location (state)'
       inactivity = 'Physical inactivity (0=No, 1=Yes)'
       activity = 'Physical activity (3-levels)';

run;


/* Combine all data */

data pheno_aric(drop=hxchf);
 set aric_ex1
     aric_ex2
     aric_ex3
     aric_ex4
     aric_ex5;

 htcm = round(htcm,1);

 if gender='F' then sex_n=0;
  else if gender='M' then sex_n=1;

 rename atrfib=afib
        gender=sex_c
        htcm=hgt_cm
        diabetes=diab
        cholmed=anycholmed;

 label gender='Participant gender (character)'
       sex_n='Participant gender (0=Female, 1=Male)'
       diabetes='Diabetes status (0=No, 1=Yes)'
       htcm='Height (centimeters)';
run;


/* Expand the final data set to five full exam records per patient */

proc sort data=pheno_aric(keep=subject_id) out=uniq_pat nodupkey;
 by subject_id;
run;

data exp_visdat(keep=subject_id visit);
 set uniq_pat;

 visit = 'EXAM1'; output;
 visit = 'EXAM2'; output;
 visit = 'EXAM3'; output;
 visit = 'EXAM4'; output;
 visit = 'EXAM5'; output;

run;

proc sort data=exp_visdat;
 by subject_id visit;
run;

proc sort data=pheno_aric;
 by subject_id visit;
run;

/* Add RACE_C to each record before merging with full template */

data pheno_aric;
 merge pheno_aric(in=a)
       getrace(in=b);

 by subject_id;

 if a;

run;

data pheno_aric;
 merge exp_visdat(in=a) pheno_aric(in=b);
 by subject_id visit;

run;

proc contents data=pheno_aric;
run;

options validvarname=upcase;
data out1.pheno_aric;
 set pheno_aric;
 by subject_id visit;

run;

proc export data=pheno_aric
            outfile="/data/aric/analdata/pheno_aric.csv"
            dbms=csv
            replace;
run;

ods rtf file="/data/aric/analdata/pheno_aric_contents.rtf";
proc contents data=out1.pheno_aric;
run;
ods rtf close;
