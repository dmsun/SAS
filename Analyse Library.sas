%MACRO data_analysis(libref);
	/*cancel the TITLE statment*/
	TITLE;
 
	/*create macro variable table_list which is populated by list of table names in library*/
	PROC SQL;
		select distinct memname label = "Table_List" into: table_list separated by " "
	/*queries sashelp.vtable. Once library has been assigned this table will have a record for each table in each library*/
		from sashelp.vtable
		where libname = "&libref"
		;
	QUIT;

	%put table_list = &table_list;

	%local i next_name;
	%let i=1;

	%do %while (%scan(&table_list, &i) ne );

		/*assigns macro variable table to be equal to next table in table_list*/
    	%let table = %scan(&table_list, &i);

		/*GET field names of table and write to CONTENTS_TABLE*/
		PROC CONTENTS DATA = &&libref..&table OUT = work.CONTENTS_&table. NOPRINT;
		RUN;

		PROC SQL;
		/*GET Numerical Field Names and assing to numvar_list*/
			select distinct NAME label = "Numvar_List" into: numvar_list separated by " "
			from work.CONTENTS_&table.
 			where TYPE = 1
			;
		/*GET Character Field Names and assign to charvar_list*/
			select distinct NAME label = "Charvar_List" into: charvar_list separated by " "
			from work.CONTENTS_&table.
			where TYPE = 2
			;
		QUIT;
		
		%put numvar_list = &numvar_list;
		%put charvar_list = &charvar_list;

		/* proc freq */
		title "&table - Character Variables";
	    proc freq data=&&libref..&table NLEVELS ;
	        tables &charvar_list /MISSING;

		run;

		title "&table - Numerical Variable analysis";
		proc univariate data=&&libref..&table;
			var &numvar_list;

		run;

		/*Increments iterator by 1 to pick next table in table list	*/
	     %let i = %eval(&i + 1);
  %end;
%MEND data_analysis;

/*********************************/
/*********************************/
/*BEGIN Example with Work Tables*/

proc copy in=sashelp out=work;
	select cars class;
run;


/*Note Library name is case sensitive*/
%let libref = WORK;
%data_analysis(%UPCASE(&libref));

/*********************************/
/*********************************/