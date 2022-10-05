
options ls=256 nocenter;


/**************************************************************************************************************************/
/* See comment instructions througout program for libname/filename changes needed for using program for a different study */
/**************************************************************************************************************************/


/* Change this libname to point where you want to output the final metadata SAS data sets. */
/*libname here "/cerner/qubbd/data/mesa/dbgap/61171/import_pheno_text/metadata_61171";*/
libname here "/dcri/sigmadata/stroke_prediction/data/mesa/dbgap/import_pheno_text/metadata";



**** READ THE DIRECTORY FILENAMES INTO A DATASET;
/* Change this filename to point to the directory where the "...data_dict.xml" input files reside.             */
/* This filename command stores the result of executing the command "dir -B ...." at the Moba prompt to a file */
/* called dirlist, which contains a list of all filenames in that directory, separated by forward slashes "/". */

filename dirlist pipe "dir -B /dcri/sigmadata/stroke_prediction/data/mesa/dbgap/phenotype_files";

data dirlist ;
     length dname $200; 
     infile dirlist length=reclen;
     input dname $varying200. reclen;
run;

**** PARSE XML FILE NAMES AND DERIVE DATASET NAME;
data dirlist(drop=dname);
    length fname dsname $200;
    set dirlist;
    
    fname = scan(dname,-1,'/');

    /* data set "dirlist" contains the names of all files in the directory.  Keep only the "data_dict" .xml files. */
    if index(fname,"data_dict");

    dsname = substr(fname,15);
    dsname = substr(dsname,1,length(dsname)-14);
    dsname = translate(dsname,"_",".");

    if length(dsname) > 32 then
      do; 
*        put "WARN" "ING: created dataset name too big. Truncating to 32 " dsname= fname=; 
        dsname = substr(dsname,1,32);
      end;
run;
   
proc print data=dirlist(obs=10);
run; 

**** DETERMINE IF TRUNCATED DATASET NAME IS UNIQUE;    
proc sort
    data=dirlist;
    by dsname;
run;

data _null_;
    set dirlist;
    by dsname;
    
    if not (first.dsname and last.dsname) then
      put "ERR" "OR: truncated dataset name not unique " dsname= fname=;
run;
   
    
**** LOAD FILENAMES AND DATASET NAMES INTO A MACRO ARRAY;    
proc sql noprint;
    select unique fname into :fnames separated by '|'  from dirlist;
    select unique dsname into :dsnames separated by '|'  from dirlist;
    select count(unique fname) into :fname_count from dirlist;
quit;



/* This macro reads in each of the 96 MESA "...data_dict.xml" files one at a time, saving the items "name" and "description" */
/* from the .xml file to the output metadata SAS data set. */ 
/* Change the 'filename sfile' path below to point to where the input .xml files reside. */
/* Do not change the portion after the last forward slash, which begins with "%scan(&fnames..." */
/* Update the 'filename SXLEMAP' statement below.  Change 'mesa.map' to whatever the name of your XML map file is. */
   
%macro readxml;
    
%do i = 1 %to &fname_count;
    
filename sfile "/dcri/sigmadata/stroke_prediction/data/mesa/dbgap/phenotype_files/%scan(&fnames,&i,'|')";
filename SXLEMAP "./mesa.map"; 
libname  sfile xmlv2 xmlmap=SXLEMAP access=READONLY; 

data here.%scan(&dsnames,&i,"|");
  set sfile.variable(keep=name description);
run;

%end;
    
%mend readxml;
    
%readxml    
    
