options ls=256 nocenter;
libname here "/data/framingham/dbgap/import_pheno_text/metadata";

**** READ THE DIRECTORY FILENAMES INTO A DATASET;
filename dirlist pipe "dir -B /data/framingham/dbgap/phenotype_files";

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


**** LOAD FINENAMES AND DATASET NAMES INTO A MACRO ARRAY;
proc sql noprint;
    select unique fname into :fnames separated by '|'  from dirlist;
    select unique dsname into :dsnames separated by '|'  from dirlist;
    select count(unique fname) into :fname_count from dirlist;
quit;

%macro readxml;

%do i = 1 %to &fname_count;

filename sfile "/data/framingham/dbgap/phenotype_files/%scan(&fnames,&i,'|')";
filename SXLEMAP "./fram.map";
libname  sfile xmlv2 xmlmap=SXLEMAP access=READONLY;

data here.%scan(&dsnames,&i,"|");
  set sfile.variable(keep=name description);
run;

%end;

%mend readxml;

%readxml
