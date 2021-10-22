********************************************************************************
*																			   *
*						Main do file for cleaning data						   *
*																			   *
********************************************************************************

clear
set more off
cd "D:\MCLC\Pilot 1\information_sett\ReplicationFinal"
//qui do ".\DoFiles\tabnumlab.do"

*********************
*		Pilot 1		* 
*********************

do ".\DoFiles\cleaning\cleaning_pilot_rep.do" 

*****************************
*		Pilot 2	(scaleup)	* 
*****************************

do ".\DoFiles\cleaning\cleaning_scaleup.do"

*****************************
*		Historical data 	* 
*****************************

do ".\DoFiles\cleaning\cleaning_hd_rep.do"

*****************************
*		Time preferences 	* 
*****************************

do ".\DoFiles\cleaning\mxfls_cleaning.do"
do ".\DoFiles\cleaning\DB_time_pref.do"

*****************************
*		P1 & P2 Followups 	* 
*****************************

do ".\DoFiles\cleaning\importAppend2020Followups.do"
do ".\DoFiles\cleaning\cleaning_missingCasefiles.do"
do ".\DoFiles\cleaning\clean_missing_predictions.do"
do ".\DoFiles\cleaning\cleanTerminaciones_v2.do"

*****************************
*		P3 results 		 	* 
*****************************

do ".\DoFiles\cleaning\clean_pilot3.do"
do ".\DoFiles\cleaning\CleaningP3.do"

*****************************
* Correct Sample Pilots		* 
*****************************

do ".\DoFiles\cleaning\ITTSample.do"