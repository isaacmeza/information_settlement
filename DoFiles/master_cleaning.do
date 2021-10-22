/*

**  Isaac Meza, isaac.meza@itam.mx


Master do file for cleaning and processing of data 
	- Pilot / Phase 1
	- Scaleup / Phase 2
	- HD / Historical Data
	
*/		


********************************* Historical Data ******************************
do "$sharelatex\DoFiles\cleaning\cleaning_hd.do"


************************************* Phase 1 **********************************
do "$sharelatex\DoFiles\cleaning\pilot.do"


************************************* Phase 2 **********************************
do "$sharelatex\DoFiles\cleaning\scaleup.do"


***************************** Time/Risk panel dataset **************************
do "$sharelatex\DoFiles\cleaning\mxfls_cleaning.do"
do "$sharelatex\DoFiles\cleaning\DB_time_pref.do"
