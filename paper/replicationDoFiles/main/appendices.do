********************************************************************************
*																			   *
*					Main do file for Appendices A	and C					   *
*																			   *
********************************************************************************

clear
set more off
cd "D:\MCLC\Pilot 1\information_sett\ReplicationFinal"
//qui do ".\DoFiles\tabnumlab.do"

***************
*   Tables    *
***************
/*
Appendix A
*/

*  A2: Survey SS For P1.
do "DoFiles\appendix\surveyP1SS.do"

* A3: Experiment integrity
do "DoFiles\appendix\complianceTable.do" //does panel A using only P1 data
do "DoFiles\appendix\ComplianceP2Tables.do" //does panel B using only P2 data
do "DoFiles\appendix\showUp.do" //does panel C using P1 & P2 data

* A4: Balance table
do "DoFiles\appendix\balance.do" //Me faltan observaciones del P1. Supongo que vienen de las neuvas iniciales? Está raro

/*
Appendix C
*/

*TC.1 .- Amount asked (log), amount won (log), and probability of winning - Historic Data
do "DoFiles\appendix\reg_amount.do" //Output gets aggregated in the TableReg1_log.xlsx file.

*TC.2.-  Balance of casefiles having negative recovery amount.
do "DoFiles\appendix\negReturnHD.do" //Output gets written in negative_returners_balance.xlsx

*TC.3.- Balance regression on characteristics conditional on employee present
do "DoFiles\appendix\ep_balance.do" //Output gets formatted in ep_balance.xlsx

*TC.4.- Employee presence
do "DoFiles\appendix\pEmployeePresence.do"

*TC.5.- Expectations Relative to Prediction
do "DoFiles\appendix\prediction_cases_pooled_MergeWithPilotOperation.do" //does Panel A w/P1 & P2
do "DoFiles\appendix\ExpectationsFromP3forPrediction_cases_pooles_panelB.do" //does Panel B with P3
//Results are merged and formatted in table prediction_cases_pooled.xlsx

*TC.6.- First stage and robustness for the control function regression
//do "DoFiles\appendix\treatment_effects_IV_CF.do" //Problem with column 1, gotta get back to it.

*TC.7.- Heterogeneity in treatment effects
do "DoFiles\appendix\te_heterogeneity.do" //produces raw output, te_heterogeneity.xlsx formats it.

*TC.8.- Treatment Effects with placebo arm - Phase 1
do "DoFiles\appendix\tePlacebos.do"

*TC.9.- Updating - Phase 1
do "DoFiles\appendix\update_reg_theta_rel_uc.do" /*performs the regression with underconfidents,
while */
do "DoFiles\appendix\update_reg_theta_rel_oc.do" /*does it for over confidents.
The table is actually composed of 2 different tables, both of which exist in the excel workbook update_reg_theta_rel.xlsx.*/

*TC.10 - Duration of Cases by Treatment
//welfare42monthsP1P2.do does, among other things, this regression. duration.xlsx adds format to the results.


***************
*   Figures   *
***************

*F4.C.- Distribution of Amount Collected, by Type of Lawyer
do "DoFiles\appendix\cdf_value_claims.do" //does both subgraphs and appends them

*F5.C.-
do "DoFiles\appendix\oc_comparison_B.do" //does 6 subfigures, they get appended directly on latex.

*F6.C.- Settlement Amount vs.  Calculator
do "DoFiles\appendix\ratioGananciaConvenio.do"

*F7.C.- Outcomes when Plaintiff was Present, by Treatment
//welfare42monthsp1p2.do_ does the 2 subfigures, latex compiled them as one

*F8.C.- Calculator Pr
//caseValueKdensitiesdo.do does it. It is run in main_results.do
