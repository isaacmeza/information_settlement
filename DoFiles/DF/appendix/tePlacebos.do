/*Table C11:  Treatment Effects with placebo arm - Phase 1*/
/*
The table reports regressions of the main treatment effects using the full sample 
and including variables indicating that the case received a placebo treatment.
*/
********************************************************************************

use ".\DB\pilot_operation.dta", clear
merge m:1 expediente anio using ".\DB\pilot_casefiles_wod.dta", keep(1 3)
drop _merge renglon


*Presence employee
replace p_actor=(p_actor==1)

rename (tratamientoquelestoco expediente) (treatment exp)

bysort junta exp anio: gen DuplicatesPredrop=_N
forvalues i=1/3{
	gen T`i'_aux=[treatment==`i'] 
	bysort junta exp anio: egen T`i'=max(T`i'_aux)
}

gen T1T2=[T1==1 & T2==1]
gen T1T3=[T1==1 & T3==1]
gen T2T3=[T2==1 & T3==1]
gen TAll=[T1==1 & T2==1 & T3==1]

replace T1T2=0 if TAll==1
replace T1T3=0 if TAll==1
replace T2T3=0 if TAll==1

*32 drops
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
*sort junta exp anio fecha
*bysort junta exp anio: keep if _n==1
********************************************************************************
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

append using ".\DB\placebo_operation.dta"



****REGRESSIONS****
	eststo clear
*******************

	
	*Same day conciliation w/placebo
	eststo: reg seconcilio i.treatment if treatment!=0 , robust
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)
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
	qui  test 2.treatment=4.treatment
	estadd scalar Pvalueplacebo=r(p)
	qui testparm i(2/4).treatment
	estadd scalar Pvalue_placebo=r(p)
	qui testparm i(4/5).treatment treatment#1.p_actor
	estadd scalar Pvalue_placebo_c=r(p)
	
	
	
	*************************
	esttab using "./Tables/reg_results/te_placebo.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "IntMean InteractionVarMean" "Pvalueplacebo Pvalueplacebo" "Pvalue_placebo Pvalue_placebo" "Pvalue_placebo_c Pvalue_placebo_c") replace 

		
