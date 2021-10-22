/*Table C11:  Treatment Effects with placebo arm - Phase 1*/
/*
The table reports regressions of the main treatment effects using the full sample 
and including variables indicating that the case received a placebo treatment.
*/
********************************************************************************

use "$sharelatex\DB\pilot_operation.dta", clear
merge m:1 expediente anio using "$sharelatex\DB\pilot_casefiles_wod.dta", keep(1 3)
drop _merge


*Presence employee
replace p_actor=(p_actor==1)

rename tratamientoquelestoco treatment

append using "$sharelatex\DB\placebo_operation.dta"



****REGRESSIONS****
	eststo clear
*******************

	
	*Same day conciliation w/placebo
	eststo: reg seconcilio i.treatment if treatment!=0 , robust
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui  test 2.treatment=3.treatment
	estadd scalar Pvalue=r(p)
	qui testparm i(2/3).treatment
	estadd scalar Pvalue_=r(p)
	qui  test 2.treatment=4.treatment
	estadd scalar Pvalueplacebo=r(p)
	qui testparm i(2/4).treatment
	estadd scalar Pvalue_placebo=r(p)
	qui testparm i(4/5).treatment
	estadd scalar Pvalue_placebo_c=r(p)
	
	
	*Interaction employee was present w/placebo
	eststo: reg seconcilio i.treatment##i.p_actor if treatment!=0 , robust
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment=3.treatment
	estadd scalar Pvalue=r(p)
	qui testparm i(2/3).treatment
	estadd scalar Pvalue_=r(p)
	qui  test 2.treatment=4.treatment
	estadd scalar Pvalueplacebo=r(p)
	qui testparm i(2/4).treatment
	estadd scalar Pvalue_placebo=r(p)
	qui testparm i(4/5).treatment treatment#1.p_actor
	estadd scalar Pvalue_placebo_c=r(p)
	
	
	
	*************************
	esttab using "$sharelatex/Tables/reg_results/te_placebo.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "IntMean InteractionVarMean" "Pvalue Pvalue" "Pvalue_ Pvalue_" "Pvalueplacebo Pvalueplacebo" "Pvalue_placebo Pvalue_placebo" "Pvalue_placebo_c Pvalue_placebo_c") replace 

		
