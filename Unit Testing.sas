/*This script will write the output of PROC COMPARE to PDFs in the chosen DIRECTORY*/
/*DIRECTORY is the directory where the PDF files will be written to. This will need to be a location the SASApp Server can write to.*/
%LET DIRECTORY = ;

/*Define the VALIDATION Libref and table*/
%LET val_lib = ;
%LET val_lib_path = ;
%LET val_tab = ;

/*Define the TEST Libref and table*/
%LET test_lib = ;
%LET test_lib_path = ;
%LET test_tab = ;

/*Assign Libraries if needed*/
LIBNAME &val_lib &val_lib_path;
LIBNAME &test_lib &test_lib_path;

/*Define the Key Variable to compare results against*/
%LET VAR =  ;

/*SORT both the VALIDATION TABLE and the TEST TABLE by the same key variables*/
PROC SORT DATA = &&val_lib..&val_tab OUT = WORK.VALIDTAB_SORT;
	BY &VAR;
RUN;

PROC SORT DATA = &&test_lib..&test_tab OUT = WORK.TESTTAB_SORT;
	BY &VAR;
RUN;

/*Write the results of Unit testing to PDF using ODS*/
ODS PDF FILE ="&DIRECTORY./SAS Reports - Unit Test.pdf";
/*Perform the PROC COMPARE with the TEST data against the VALIDATION data*/
PROC COMPARE BASE = WORK.VALIDTAB_SORT compare=WORK.TESTTAB_SORT 
		OUTDIF = DIFF
		OUTSTATS = STATS_SUMMARY
		OUTNOEQUAL ALLVAR LISTOBS LISTVAR STATS METHOD = EXACT;
	ID &VAR;
RUN;
ODS PDF CLOSE;
/*END UNIT TEST and close PDF*/