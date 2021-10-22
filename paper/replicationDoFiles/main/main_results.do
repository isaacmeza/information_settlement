********************************************************************************
*																			   *
*						Main do file for main results						   *
*																			   *
********************************************************************************
clear
set more off
cd "D:\MCLC\Pilot 1\information_sett\ReplicationFinal"

*********************
*		Tables 		*
*********************

*T1) Description
do ".\DoFiles\main_results\pilotsDescription.do"

*T2) Summary stats

do ".\DoFiles\main_results\SS_replicates.do"

*T3) Main results
do ".\DoFiles\main_results\ITTVersion.do" //Pilots 1 and 2
do ".\DoFiles\main_results\treatment_effects_IV_CF_noConciliator_rep_NoDuplicatesITT.do" //CF
do ".\DoFiles\main_results\p3ResultMainTable.do" //P3

*T4) By lawyer type
do ".\DoFiles\main_results\teByLawyer.do"

*T5) P3 expectation updating
do ".\DoFiles\main_results\te_p3_updating.do"

*T6) Followup
do ".\DoFiles\main_results\endMode.do"

*T7) Recovery ammount
do ".\DoFiles\main_results\welfare42monthsP1P2.do"

*T8) P3 welfare
do ".\DoFiles\main_results\P3welfare.do"

*********************
*		Figures		*
*********************

*F2: Time duration HD
do ".\DoFiles\main_results\caseending_overtime_rep.do"

*F3: Knowledge of lw and lawsuit
do ".\DoFiles\main_results\knowledge_allByType.do"

*F5: Calculator prediction for settled casefiles
do ".\DoFiles\main_results\calculatorDistributionForSettled.do"

*F6: Calculator distribution for cases that won in court
do ".\DoFiles\main_results\caseValueKdensitiesdo.do"
