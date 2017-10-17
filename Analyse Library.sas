libname S2V4_2 "/opt/sas/data/eclifrs9/staging/inbound/data_v4.1";
%let libref = S2V4_2;

/*create macro variable table_list which is populated by list of table names in library*/
proc sql;
          select distinct memname into: table_list separated by " "
          from sashelp.vtable
          where libname = "&libref"
          ;
quit;

%put table_list = &table_list;

%MACRO Data_Validation(libref, table_list);
          %local i next_name;
          %let i=1;
          %do %while (%scan(&table_list, &i) ne );
             %let table = %scan(&table_list, &i);
/*                  proc freq for simplified portfolios*/
                    %if &table = ACCT_CC_NZ_20161231
                              or &table = ACCT_PL_NZ_20161231
                              or &table =         ACCT_OD_NZ_20161231
                              or &table =         ACCT_GS_NZ_20161231  %THEN %DO;
                        proc freq data=&&libref..&table ;
                                        tables HARDSHIP_FLG BASEL_DEFAULT_FLG DELQ_STATUS;
                                        title "&table";
                              run;
                              %END;
                    /*do nothing for VL_CFAL*/
                    %IF &table = ACCT_VF_CFAL_20161231 %THEN %DO;
                    %END;
                    /*proc freqs for HL portfolios*/
                    %IF &table = ACCT_HL_WBC_20161231
                              or &table = ACCT_HL_NZ_20161231 %THEN %DO;
                              proc freq data=&&libref..&table ;
                                        tables IAP_FLG RISK_GRADE_ORGN_PM DELQ_STATUS;
                                        title "&table";
                              run;
                    %END;
                    /*proc freqs for FL and CC Portfolios SGB WBC*/
                    %IF &table = ACCT_FL_WBC_20161231
                              or &table = ACCT_CC_SGB_20161231
                              or &table = ACCT_CC_WBC_20161231 %THEN %DO;
                              proc freq data=&&libref..&table ;
                                        tables RISK_GRADE_ORGN_PM CYCLE_DELQ_BLEND;
                                        title "&table";
                              run;
                    %END;
                    /*Proc Freq for TM Portfolios*/
                    %IF &table = ACCT_TM_WBC_20161231 %THEN %DO;
                              proc freq data=&&libref..&table ;
                                        tables RISK_GRADE_ORGN_TM IAP_FLG RISK_GRADE_ORGN_TM*RISK_GRADE_IFRS9_TM;
                                        title "&table";
                              run;
                    %END;

             %let i = %eval(&i + 1);
          %end;
%MEND Data_Validation;

%Data_Validation(&libref, &table_list);

