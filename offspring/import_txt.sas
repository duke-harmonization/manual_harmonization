/* -----------------------------------------------------------------------------------------------
   Source:
   Author: Tony Schibler
   Date: 2-19-2021

   Protocol   :
   Purpose    : Import Framingham dbGaP text files, rename variables, and combine with
                metadata from XML files to create variable labels.  Output files as SAS datasets.

   Assumptions:

   Output     :

   NOTES      :

   -----------------------------------------------------------------------------------------------
   Modification History
   -----------------------------------------------------------------------------------------------
   Log:

   -----------------------------------------------------------------------------------------------
*/


options ls=256 nocenter;
libname inlbl '/data/framingham/dbgap/import_pheno_text/metadata' access=readonly;
libname out '/data/framingham/dbgap/import_pheno_text/outdata';


/*********************************************/
/* Get all the label(metadata) dataset names */
/*********************************************/

filename dirlist pipe "ls /data/framingham/dbgap/import_pheno_text/metadata";

data dirlist(keep=dsname) ;
     length dname $200;
     infile dirlist length=reclen;
     input dname $varying200. reclen;

    dsname = substr(dname,1,length(dname)-9);

run;


**** LOAD DATASET NAMES INTO A MACRO ARRAY;
proc sql noprint;
    select unique dsname into :dsnames separated by '|'  from dirlist;
    select count(unique dsname) into :dsname_count from dirlist;
quit;


/*******************************/
/* Get all the text file names */
/*******************************/

filename dirlist2 pipe "ls /data/framingham/dbgap/import_pheno_text/text";

data dirlist2(keep=txtname) ;
     length txtname $200;
     infile dirlist2 length=reclen;
     input txtname $varying200. reclen;

run;


**** LOAD DATASET NAMES INTO A MACRO ARRAY;
proc sql noprint;
    select unique txtname into :txtnames separated by '|'  from dirlist2;
    select count(unique txtname) into :txtname_count from dirlist2;
quit;



/************************************************************************************************************************************************/
/* Import the text file twice, once to get just the variable names (row 11), and a second time to get just the data lines (row 12 and greater). */
/************************************************************************************************************************************************/

%macro imptxt;

%let j=1;

%do j = 1 %to &txtname_count;

/* First, get variable names */
proc import datafile="/data/framingham/dbgap/import_pheno_text/text/%scan(&txtnames,&j,"|")"
            out=impvars
            dbms=dlm
            replace;
     datarow=11;
     delimiter='09'x;
     getnames=yes;
     guessingrows=20000;
run;

data impvars;
 set impvars;

 /* The import above brings in row 11 and all rows following it. */
 /* Keep only the first line, which contains the variable names. */
 if _n_=1;

 /* In the PROC IMPORT step, this string was picked up from row 1 of the text file, and used as the first variable name. */
 /* Rename it to VAR1.                                                                                                   */
 /* The rest of the variables took on names VAR2 through VARn, where n = the number of columns in the import text file.  */
 rename __Study_accession__phs000007_v32 = VAR1;

run;


/* Next, get the data lines */
proc import datafile="/data/framingham/dbgap/import_pheno_text/text/%scan(&txtnames,&j,"|")"
            out=impdat
            dbms=dlm
            replace;
     datarow=12;
     delimiter='09'x;
     getnames=yes;
     guessingrows=20000;
run;

data impdat;
 set impdat;

 rename __Study_accession__phs000007_v32 = VAR1;

run;

/**************************************************************************************************************/
/* Get the number of variables in the data set (VARNUM), and assign that value to the macro variable &VARCNT. */
/**************************************************************************************************************/
proc contents data=impdat noprint out=conttxt;
title 'Old variable names';
run;


data numvar(keep=varnum);
 set conttxt end=eof;

 if eof;
run;

data _null_;
 set numvar;

 call symput('varcnt',compress(put(varnum,best9.)));

 %global varcnt;

run;


/**************************************************************************************************************/
/* The data set IMPVARS1 contains one observation, and the variables contained in the data are VAR1-VARn.     */
/* The values of VAR1-VARn are the variable names from row 11 of the original import text file.               */
/*                                                                                                            */
/* Using the VARCNT variable from above, save the values of VAR1-VARn to "n" macro variables &NVNAM1-&NVNAMn. */
/* Also, create "n" additional macro variables &OVNAM1-&OVNAMn, containing the values "var1" through "varn".  */
/**************************************************************************************************************/
data _null_;
 set impvars;

 array vnams {*} var1-var&varcnt;

 incval=0;

 do i=1 to dim(vnams);
  incval+1;
  call symput('nvnam'||left(incval),compress(put(vnams{i},$32.)));
  call symput('ovnam'||left(incval),'var'||left(incval));
 end;

 %let i=1;
 %do %while (&i<=&varcnt);

  %global ovnam&i nvnam&i;

   %let i=%eval(&i+1);

 %end;

run;


/*******************************************************************************************/
/* Macro to rename all variables in the data set, using the macro variables created above. */
/*******************************************************************************************/
%macro renmit;

 %let i=1;
 %do %while (&i<=&varcnt);

   rename &&ovnam&i = &&nvnam&i;

   %let i=%eval(&i+1);

 %end;

%mend renmit;


/***********************************************************************************************/
/* Rename the variables in the data set containing only the data (minus the variable name row) */
/***********************************************************************************************/
data impdat;
 set impdat;

 %renmit;

run;


/*********************************************************************************************************************/
/* Get the number of variables in the labels data set (VARNUM), and assign that value to the macro variable &LBLCNT. */
/*********************************************************************************************************************/
proc contents data=inlbl.%scan(&dsnames,&j,'|') noprint out=contlbl;
title 'Labels data set';
run;

data numlbl(keep=nobs);
 set contlbl end=eof;

 if eof;
run;

data _null_;
 set numlbl;

 call symput('lblcnt',compress(put(nobs,best9.)));

 %global lblcnt;

run;

/***********************************************************************************************/
/* Retreive the labels for the variables                                                       */
/***********************************************************************************************/
data _null_;
 set inlbl.%scan(&dsnames,&j,'|');

 description=translate(description,':','=');
 description=compress(description,"';&");
 description=compress(description,'"');

  incval+1;
  call symput('vname'||left(incval),compress(put(name,$32.)));
  call symput('labl'||left(incval),put(description,$260.));

 %let i=1;
 %do %while (&i<=&lblcnt);

  %global vname&i labl&i;

   %let i=%eval(&i+1);

 %end;

run;


/*******************************************************************************************/
/* Macro to label all variables in the data set, using the macro variables created above.  */
/*******************************************************************************************/
%macro lblit;

 %let i=1;
 %do %while (&i<=&lblcnt);

   label &&vname&i = &&labl&i;

   %let i=%eval(&i+1);

 %end;

%mend lblit;


/***********************************************************************************************/
/* Label the variables in the data set containing only the data (minus the variable name row) */
/***********************************************************************************************/
data impdat;
 set impdat;

 %lblit;

 label dbGaP_Subject_ID = 'dbGaP Subject ID';

run;



/*********************************/
/* Clear out all macro variables */
/*********************************/
%macro delmvar;

 /* rename variables */
 %let i=1;
 %do %while (&i<=&varcnt);

  %symdel ovnam&i nvnam&i;

   %let i=%eval(&i+1);

 %end;


 /* label variables */
 %let i=1;
 %do %while (&i<=&lblcnt);

  %symdel vname&i labl&i;

   %let i=%eval(&i+1);

 %end;

 %symdel varcnt lblcnt;

%mend delmvar;


 %delmvar;

data out.%scan(&dsnames,&j,'|');
 set impdat;
run;
%end;


%mend imptxt;

%imptxt;
