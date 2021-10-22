/*

**  Isaac Meza, isaac.meza@itam.mx


Master do file for main tables and figures of the ONLINE APPENDIX
		Information and Bargaining through Agents: Experimental
				Evidence from Mexico’s Labor Courts

Data first need to be processed with the main_cleaning dofile.	
For further details see the notes in the appendix and the dofile itself.	
*/		


*********************************** TABLES *************************************

*Table C3: Settlements against duration - Historical Data
do "$sharelatex\DoFiles\appendix\settlementq_time.do"

*Table C5:  Compliance Rate
	*Panel (a)
do "$sharelatex\DoFiles\appendix\table_compliance.do"
	*Panel (b) - Rscript balance_compliance.R
	*Panel (c)
do "$sharelatex\DoFiles\appendix\showed_up.do"
	

*Table C6:  Balance table
do "$sharelatex\DoFiles\appendix\balance.do"

*Table C7: Balance regression on characteristics conditional on employee present
do "$sharelatex\DoFiles\appendix\ep_balance.do"

*Table C8:  Unconfoundedness assessment
*Previously run for main results

*Table C9:  Comparison of aettlement amounts
do "$sharelatex\DoFiles\appendix\settlement_conciliator_matching_lr.do"

*Table C10:  Balance of casefiles having negative recovery amount.
do "$sharelatex\DoFiles\appendix\negative_returners.do"

*Table C11:  Treatment Effects with placebo arm - Phase 1
do "$sharelatex\DoFiles\appendix\te_placebo.do"

*Table C12: First stage and robustness for the control function regression
*Previously run for main results

*Table C13: Treatment Effects with different end mode outcomes
do "$sharelatex\DoFiles\appendix\treatment_effects_end_mode.do"

*Table C14: Treatment Effects conditional on type of lawyer
do "$sharelatex\DoFiles\appendix\te_bylawyer.do"

*Table C15: Heterogeneity in treatment effects
do "$sharelatex\DoFiles\appendix\te_heterogeneity.do"

*Table C16: Treatment generated updating in probability - Phase 1
do "$sharelatex\DoFiles\appendix\update_reg_theta_rel_oc.do"
do "$sharelatex\DoFiles\appendix\update_reg_theta_rel_uc.do"

*Table C17: Employee presence
do "$sharelatex\DoFiles\appendix\te_heterogeneity.do"


*********************************** FIGURES ************************************

*Figure C1: Compensation histograms - Historical Data
do "$sharelatex\DoFiles\appendix\te_heterogeneity.do"

*Figure C2: Subjective expectation minus prediction - Phase 1
do "$sharelatex\DoFiles\appendix\oc_comparison_B.do"

*Figure C3: Propensity score overlap
*Previously run for main results

*Figure C4: Discount rate against welfare effects
do "$sharelatex\DoFiles\appendix\settlement_conciliator_matching_interest_rate.do"

*Figure C5: Discount rate for Phase 1 and MxFLS
do "$sharelatex\DoFiles\appendix\discount_rate_ph1_mxfls.do"

*Figure C6: Prob plaintiff correctly knows what is in the lawsuit 
do "$sharelatex\DoFiles\appendix\knowledge_law_graph.do"

