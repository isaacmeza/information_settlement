
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	
* Author: Isaac M 
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- 
* Files created:  

* Purpose: Impact of the update in expectations in the settlement rate

*******************************************************************************/
*/

		 
use ".\DB\treatment_data.dta", clear
merge 1:1 id_actor using ".\DB\survey_data_2m.dta", keep(3)
keep if !missing(main_treatment) & main_treatment != 3

*****************************      PROBABILITY      ****************************

*Independent dummy variable
gen bajo_inm_prob_d=prob_ganar_treat<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm_prob_d=0 if main_treatment==1 & !missing(prob_ganar)

gen bajo_inm_prob=prob_ganar_treat-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm_prob=0 if main_treatment==1 & !missing(prob_ganar)

gen bajo_inm_quant_d=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm_quant_d=0 if main_treatment==1 & !missing(cantidad_ganar)

gen bajo_inm_quant=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm_quant=0 if main_treatment==1 & !missing(cantidad_ganar)

qui gen esample=1	
qui gen nvals=.

local depvar bajo_inm_prob_d  bajo_inm_prob bajo_inm_quant_d bajo_inm_quant
local controls mujer antiguedad salario_diario
gen altT = main_treatment - 1

bysort fecha_alta: egen minT = min(altT)
bysort fecha_alta: egen maxT = max(altT)
gen indicadora = minT != maxT

drop if indicadora == 1

*****************************
*       REGRESSIONS         *
*****************************

local indica = -1

foreach var in `depvar'	{
local indica = `indica'+1

	if `indica' < 3{
		local dec = 2
	} 
	else {
		local dec = 0
	}
di "indica = `indica'"
di "dec = `dec'"
di "`var'"
	if `indica' == 0 {
	ritest altT _b[altT], reps(1000) seed(125) cluster(fecha_alta):  reg `var' altT `controls', robust cluster(fecha_alta)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	
	qui reg `var' i.main_treatment `controls', robust cluster(fecha_alta)
	local Source="2m"
	forvalues i=1/2 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	local obs_per_gr="`obs_1'/`obs_2'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/2 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	local days_per_gr="`obs_1'/`obs_2'"
	local pvalNoInteract = `pvalNoInteract'	
	qui sum `var' if esample == 1 & main_treatment == 1
	local DepVarMean = r(mean)
	
	outreg2 using ".\Tables\reg_results\te_updating.xls", replace ctitle("`var'") ///
	addtext(BVC, Yes, Source, "`Source'", Observations per group, "`obs_per_gr'", Days per group, "`days_per_gr'") addstat(DepVarMean, `DepVarMean',  pvalueRI, `pvalNoInteract') keep(2.main_treatment) dec(`dec')
	

}
	else {
	qui ritest altT _b[altT], reps(1000) seed(125) cluster(fecha_alta):  reg `var' altT `controls', robust cluster(fecha_alta)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	
	qui reg `var' i.main_treatment `controls', robust cluster(fecha_alta)
	local Erre=e(r2)
	local BVC="YES"
	local Source="2m"
	forvalues i=1/2 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	local obs_per_gr="`obs_1'/`obs_2'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/2 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	local days_per_gr="`obs_1'/`obs_2'"
	local pvalNoInteract = `pvalNoInteract'	

	outreg2 using ".\Tables\reg_results\te_updating.xls", append ctitle("`var'") ///
	addtext(BVC, Yes, Source, "`Source'", Observations per group, "`obs_per_gr'", Days per group, "`days_per_gr'") addstat(DepVarMean, `DepVarMean',  pvalueRI, `pvalNoInteract') keep(2.main_treatment) dec(`dec')

	}

}
	

