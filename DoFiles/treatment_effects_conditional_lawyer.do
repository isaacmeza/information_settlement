
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	treatment_effects_conditional_lawyer
* Author: Isaac M & Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta
* Files created:  

* Purpose: Treatment Effects conditional on type of lawyer

*******************************************************************************/
*/

clear all
set maxvar 32767


* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase abogado_pub
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase abogado_pub
append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if (renglon==1 & inlist(phase,1,2)) 

********************************************************************************

*Treatment var
gen calculadora=treatment-1 if inlist(phase,1,2)

*Controls
gen anioControl=anio
replace anioControl=2010 if anio<2010
replace numActores=3 if numActores>3

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 

********************************************************************************
eststo clear

*********************************
*			PHASE 1/2			*
*********************************
forvalues i = 0/1 {
	foreach var of varlist seconcilio convenio_m5m {
			*Interaction employee present
		*Randomization Inference (Fisher)
		qui ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg `var' c.calculadora##c.p_actor i.junta if abogado_pub==`i'
		local pval_ri = r(p)[1,1]
		local pval_ri_int = r(p)[1,2]


		*Clustered std. errors (Liang-Zeger(1986))
		eststo : reg `var' c.calculadora##c.p_actor i.junta if abogado_pub==`i', vce(cluster cluster_v)
		su `var' if e(sample) & calculadora==0 
		local DepVarMean = `r(mean)'
		su `var' if e(sample) & calculadora==0 & p_actor == 1
		local IntContMean = `r(mean)'
		qui test calculadora + c.calculadora#c.p_actor = 0
		local testInteraction=`r(p)'

		estadd scalar DepVarMean = `DepVarMean'
		estadd scalar IntContMean = `IntContMean'
		estadd scalar testInteraction = `testInteraction'
		estadd scalar pval_ri = `pval_ri'
		estadd scalar pval_ri_int = `pval_ri_int'
	}
}

	
********************************************************************************	

*Save results	
esttab using "$directorio/Tables/treatment_effects_conditional_lawyer.csv", se r2 ${star} b(a2) ///
		keep(calculadora p_actor c.calculadora#c.p_actor ) ///
		scalars("DepVarMean DepVarMean" "IntContMean IntContMean" "testInteraction testInteraction" ///
		"pval_ri pval_ri" ///
		"pval_ri_int pval_ri_int") replace 
	
	
	