********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	master
* Author: Isaac M 

* Purpose: This is the master dofile that calls all individual dofiles necessary to replicate the main analysis in the paper. 
*******************************************************************************/
*/



************************************ Tables ************************************


* Table 1: Description of Treatment Arms
do ".\DoFiles\description_treatment_arms.do"

* Table 2: Summary Statistics
do ".\DoFiles\summary_statistics.do"

* Table 3: Effect of Treatment on Settlement
do ".\DoFiles\effect_treatment_settlement.do"

* Table 4: Treatment Effects conditional on type of lawyer
do ".\DoFiles\treatment_effects_conditional_lawyer.do"

* Table 5: Immediate expectation updating
do ".\DoFiles\immediate_expectation_updating.do"

* Table 6: Case outcomes by treatment arm
do ".\DoFiles\case_outcomes_treatment_arm.do"

* Table 7: Recovery after 42 months, Phase 1/2 samples
do ".\DoFiles\recovery_after_42_months.do"

* Table 8: Phase 3: Effects on welfare
do ".\DoFiles\effects_on_welfare.do"



*********************************** Figures ************************************


* Figure 2: Differences in Claims and Compensation by case file outcome - Historical Data
rscript using ".\DoFiles\difference_claims_compensation.R", rversion(4.2.2)

* Figure 3: Time Duration
do ".\DoFiles\time_duration.do"

* Figure 4: Knowledge about Law and their Own Claims in Lawsuit
do ".\DoFiles\knowledge_about_law.do"

* Figure 6: Treatment and settlement of cases
do ".\DoFiles\treatment_settlement_cases.do"

* Figure 7: Unresolved Cases: Calculator Prediction Conditional on Court Win
do ".\DoFiles\unresolved_cases_calculator_prediction.do"














