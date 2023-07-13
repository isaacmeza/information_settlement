********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	appendix_c
* Author: Isaac M 

* Purpose: This is the master dofile that calls all individual dofiles necessary to replicate the analysis in Appendix C
*******************************************************************************/
*/


* Table C.1: Amount asked (log), amount won (log), and probability of winning - Historic Data
do ".\DoFiles\appendix\c\amount_winnning_public_lawyer_hd.do"

* Table C.2: Balance on characteristics by employee presence and lawyer type
do ".\DoFiles\appendix\c\balance_ep_pl.do"

* Table C.3: Treatment effects with interactions from variables on Table C.2
do ".\DoFiles\appendix\c\treatment_effects_interactions.do"

* Table C.4: Expectations Relative to Prediction
do ".\DoFiles\appendix\c\expectations_relative_prediction.do"

* Table C.5: First stage and robustness for the control function regression
do ".\DoFiles\appendix\c\fs_robustness_control_function.do"

* Table C.6: Time of hearing balance table
do ".\DoFiles\appendix\c\time_hearing_balance.do"

* Table C.7: Heterogeneity in treatment effects
do ".\DoFiles\appendix\c\heterogeneity_treatment_effects.do"

* Table C.8: Duration of Cases by Treatment
do ".\DoFiles\appendix\c\duration_cases_treatment.do"

* Figure C.3: Distribution of Amount Collected, by Type of Lawyer
do ".\DoFiles\appendix\c\cdf_value_claims.do"

* Figure C.4: Subjective expectation minus prediction - Phase 1
do ".\DoFiles\appendix\c\subjective_expectation_prediction.do"

* Figure C.5: Settlement Amount vs. Calculator
do ".\DoFiles\appendix\c\settlement_amount_calculator.do"

* Figure C.6: Outcomes when Plaintiff was Present, by Treatment
do ".\DoFiles\appendix\c\npv_outcomes_treatment.do"

* Figure C.7: Calculator Predictions for Plaintiff Court Judgment, By Phase
do ".\DoFiles\appendix\c\unresolved_cases_calculator_prediction_byphase.do"

* Figure C.8: Discount rate for Phase 1 and MxFLS
do ".\DoFiles\appendix\c\discount_rate_tp_comp.do"
