
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	immediate_expectation_updating
* Author: Isaac M 
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_3.dta 
* Files created:  
		- immediate_expectation_updating.csv
* Purpose: Impact of the update in expectations in the settlement rate

*******************************************************************************/
*/

		 
use "./DB/phase_3.dta", clear
keep if status_encuesta==1
duplicates drop id_actor, force
keep if !missing(main_treatment) & main_treatment != 3

*Indicators for update in probability after treatment
	*Binary
gen bajo_inm_prob_d=prob_ganar_treat<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_treat) 
replace bajo_inm_prob_d=0 if main_treatment==1 & !missing(prob_ganar) 
	*Continuous
gen bajo_inm_prob=prob_ganar_treat-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_treat) 
replace bajo_inm_prob=0 if main_treatment==1 & !missing(prob_ganar)


*Indicators for update in amount after treatment
	*Binary
gen bajo_inm_quant_d=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat) 
replace bajo_inm_quant_d=0 if main_treatment==1 & !missing(cantidad_ganar) 
	*Continuous
gen bajo_inm_quant=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat) 
replace bajo_inm_quant=0 if main_treatment==1 & !missing(cantidad_ganar) 

*Treatment var
gen calculator = main_treatment - 1


*****************************
*       REGRESSIONS         *
*****************************
eststo clear

local controls gen c_antiguedad salario_diario

foreach var of varlist bajo_inm_prob_d  bajo_inm_prob bajo_inm_quant_d bajo_inm_quant {
	ritest calculator _b[calculator], cluster(fecha_alta) reps($reps) seed(9435) :  reg `var' calculator `controls', robust cluster(fecha_alta)
	matrix pvalues=r(p)
	local pval_ri = pvalues[1,1]

	eststo : reg `var' i.main_treatment `controls', vce(cluster fecha_alta)
	estadd scalar pval_ri = `pval_ri'
	}

*Save results	
esttab using "$directorio/Tables/immediate_expectation_updating.csv", se r2 ${star} b(a2) ///
		keep(2.main_treatment) scalars("pval_ri pval_ri") replace 
		
		
	