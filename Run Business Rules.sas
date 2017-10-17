/*count the number of observations in INSTTYPE LKUP*/
%MACRO DO_BRM;
	/*BEGIN Run BRM_GET_RULE_FLOW_CODE*/

	/*RUN the below macro to get BRM RULEFLOW code to pass into BRM_RULE_FLOW Macro*/
	/*FOLDER_PATH is the folder path in SAS Business Rules Manager*/
	%LET FOLDER_PATH = ;

	/*RULEFLOW_SK is the serial key for the RULEFLOW_NAME. This can be found in SAS Business Rules Manager*/
	%LET RULEFLOW_NAME = ;
	%LET RULEFLOW_SK = ;

	/*Writes the PROC DS2 code to a Directory on SASApp which BRM_RULE_FLOW will read*/
	%LET FILELOCATION = ;

	%BRM_GET_RULE_FLOW_CODE(RULEFLOW_NAME = %STR(&RULEFLOW_NAME),
							RULEFLOW_SK = &RULEFLOW_SK,
							FOLDER_PATH = %STR(&FOLDER_PATH),
							FILELOCATION = %STR(&FILELOCATION));  
	/*END Run BRM_GET_RULE_FLOW_CODE*/


	/*BEGIN Define Business Rule Flow Parameters*/
	%LET DCM_USE_LATEST_VERSION = Y;
	%LET DCM_DEPLOYED_RULEFLOW_NAME = &RULEFLOW_NAME(&RULEFLOW_SK);

	/*PUT Variables to Log for Debugging*/
	%PUT = &DCM_USE_LATEST_VERSION;
	%PUT = &DCM_DEPLOYED_RULEFLOW_NAME;
	/*END Define Business Rule Flow Parameters*/
	
	/*code to create the mapping table - this was taken from SAS BRM Rule Flow Test log*/
	%macro create_mapping_table();
		data work.MAPPING;
		    attrib table length = $100;
		    attrib column length = $100;
		    attrib termid length = $100;
		    attrib type length = $100;
		    attrib datasetid length = $100;
		    
		    /* COL_TYPE = C | N for Character or Numeric */
		    attrib col_type length = $1;
		    
		    /* COL_LENGTH = length (as a string) */
		    attrib col_length length = $5;
		    
		    /* COL_FORMAT = format name (or blank) */
		    attrib col_format length=$32;
		    
		    /* COL_INFORMAT = informat name (or blank) */
		    attrib col_informat length=$32;
		    
		    call missing(of _all_);
			stop;
		run;
		 
		 proc sql;
			 insert into work.MAPPING
			 values ('work.brm_rule_flow_test_r','RULE_ACTION_FIRE_ID','RULE_ACTION_FIRE_ID','output','1','C','100','','')
			 values ('work.brm_rule_flow_test_r','RULE_SET_SK','RULE_SET_SK','output','1','N','8','','')
			 values ('work.brm_rule_flow_test_r','RULE_SET_NM','RULE_SET_NM','output','1','C','100','','')
			 values ('work.brm_rule_flow_test_r','RULE_SK','RULE_SK','output','1','N','8','','')
			 values ('work.brm_rule_flow_test_r','RULE_NM','RULE_NM','output','1','C','100','','')
			 values ('work.brm_rule_flow_test_r','DEPLMT_SK','DEPLMT_SK','output','1','N','8','','')
			 values ('work.brm_rule_flow_test_r','RULE_FLOW_SK','RULE_FLOW_SK','output','1','N','8','','')
			 values ('work.brm_rule_flow_test_r','RULE_FLOW_NM','RULE_FLOW_NM','output','1','C','100','','')
			 values ('work.brm_rule_flow_test_r','RULE_FIRE_DTTM','RULE_FIRE_DTTM','output','1','N','8','nldatm.','nldatm.')
			 values ('work.brm_rule_flow_test_r','DEPLMT_EXECUTION_ID','DEPLMT_EXECUTION_ID','output','1','C','100','','')
			 values ('work.brm_rule_flow_test_r','ENTITY_PRIMARY_KEY','ENTITY_PRIMARY_KEY','output','1','C','1024','','')
			 values ('work.brm_rule_flow_test_r','TRANSACTION_DTTM','TRANSACTION_DTTM','output','1','N','8','nldatm.','nldatm.')
			 values ('work.brm_rule_flow_test_r','_RECORDSEQUENCEKEY','_RECORDSEQUENCEKEY','output','1','N','8','','')
			 values ('work.brm_rule_flow_test_e','DEPLMT_SK','DEPLMT_SK','output','2','N','8','','')
			 values ('work.brm_rule_flow_test_e','DEPLMT_NM','DEPLMT_NM','output','2','C','100','','')
			 values ('work.brm_rule_flow_test_e','TRANSACTION_MODE_CD','TRANSACTION_MODE_CD','output','2','C','20','','')
			 values ('work.brm_rule_flow_test_e','RECORDS_PROCESSED_NO','RECORDS_PROCESSED_NO','output','2','N','8','','')
			 values ('work.brm_rule_flow_test_e','TEST_FLG','TEST_FLG','output','2','C','1','','')
			 values ('work.brm_rule_flow_test_e','START_DTTM','START_DTTM','output','2','N','8','nldatm.',' nldatm.')
			 values ('work.brm_rule_flow_test_e','END_DTTM','END_DTTM','output','2','N','8','nldatm.','nldatm.')
			 values ('work.brm_rule_flow_test_s','RULE_SK','RULE_SK','output','6','N','8','','')
			 values ('work.brm_rule_flow_test_s','RULE_NM','RULE_NM','output','6','C','100','','')
			 values ('work.brm_rule_flow_test_s','RULE_SET_SK','RULE_SET_SK','output','6','N','8','','')
			 values ('work.brm_rule_flow_test_s','RULE_SET_NM','RULE_SET_NM','output','6','C','100','','')
			 values ('work.brm_rule_flow_test_s','RULE_FLOW_SK','RULE_FLOW_SK','output','6','N','8','','')
			 values ('work.brm_rule_flow_test_s','RULE_FLOW_NM','RULE_FLOW_NM','output','6','C','100','','')
			 values ('work.brm_rule_flow_test_s','ruleFiredCount','ruleFiredCount','output','6','N','8','','')
			/*Insert Fields for INPUT DATA*/
			 values ("&TESTTABLE",'FIELD_NAME','FIELD_NAME','input','4','N','8','','')
			/*Insert Fields for OUTPUT DATA*/
		     values ('&OUTPUTTABLE','FIELD_NAME','FIELD_NAME','output','5','N','8','','')
		 ;
		  quit;
	%mend create_mapping_table;

	%create_mapping_table();

	/*BEGIN Running Rule Flow*/

	FILENAME FILE %STR("&file");

	%BRM_RULE_FLOW(INPUTTABLE = &TESTTABLE,
					MAPPING = WORK.MAPPING,
					FILELOCATION = FILE,
					RULEFIRE = Y);

	/*END Running Rule Flow*/

%MEND DO_BRM;
