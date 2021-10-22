/*

**  Isaac Meza, isaac.meza@itam.mx


Master do file for main tables and figures of the paper
	Information and Bargaining through Agents: 
		Experimental Evidence from Mexico's Labor Courts

Data first need to be processed with the main_cleaning dofile.	
For further details see the notes in the paper and the dofile itself.	
*/		


*********************************** TABLES *************************************

*Table 1—: Summary Statistics
do "$sharelatex\DoFiles\main_results\Table_SS.do"

*Table 2—: Expectations Relative to Prediction
do "$sharelatex\DoFiles\main_results\prediction_cases_pooled.do"

*Table 3—: Amount asked (log), amount won (log), and probability of winning
do "$sharelatex\DoFiles\main_results\reg_amount.do"

*Table 4—: Treatment Effects
do "$sharelatex\DoFiles\main_results\treatment_effects.do"
do "$sharelatex\DoFiles\main_results\treatment_effects_IV_CF.do"

*Table 5—: Comparison of Settlement Amounts
do "$sharelatex\DoFiles\main_results\settlement_conciliator_matching.do"



*********************************** FIGURES ************************************

*Figure 1. : Differences in Claims and Compensation by case file outcome
*Rscript - amount_plots.R

*Figure 2. : Distribution of Amount Collected, by Type of Lawyer
do "$sharelatex\DoFiles\main_results\cdf_value_claims.do"

*Figure 3. : Time Duration
do "$sharelatex\DoFiles\main_results\caseending_overtime.do"

*Figure 4. : Knowledge about Law and their Own Claims in Lawsuit
do "$sharelatex\DoFiles\main_results\knowledge_emp.do"
do "$sharelatex\DoFiles\main_results\knowledge_lawsuit.do"
