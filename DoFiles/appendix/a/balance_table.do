
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	balance_table
* Author:	Isaac M & Sergio Lopez
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: November. 9, 2021  
* Modifications: 	
* Files used:     
		- phase_1.dta
		- phase_2.dta
* Files created:  
		- balance_table.xlsx

* Purpose: Balance table on basic and strategic variables.

*******************************************************************************/
*/

local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley p_actor p_ractor p_dem p_rdem

* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear
keep junta exp anio fecha treatment phase `balance_var'
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	
keep junta exp anio fecha treatment phase `balance_var'
append using  `p2'


********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

************************************PHASE 1*************************************
********************************************************************************

/*
*Identification of outliers

net install st0197.pkg
cap drop out
bacon salario_diario min_ley c_antiguedad  if phase==1, generate(out) percentile(1)

su salario_diario min_ley c_antiguedad if phase==1 & out==1
tab treatment if out==1

drop if out==1
*/


putexcel set "./Tables/appendix/a/balance_table.xlsx", sheet("balance_table") modify
orth_out `balance_var' if phase==1,	by(treatment)  vce(robust)   bdec(3)  count
				
qui putexcel L5=matrix(r(matrix)) 
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve
	local stars = ""
	qui replace treatment=. if treatment==3	
	qui ttest `var' if phase==1, by(treatment) unequal		
	local vp=round(r(p),.01)
	qui putexcel N`i'=(`vp') 
	if `vp' < .1 {
		local stars = "*"
	}
	if `vp' < .05 {
		local stars = "**"
	}
	if `vp' < .01 {
		local stars = "***"
	}
	qui putexcel O`i'=("`stars'") 
	local i=`i'+1
	restore
}

reg treatment `balance_var' if phase==1
local pval = Ftail(e(df_m), e(df_r), e(F))
	if `pval' < .1 {
		local stars = "*"
	}
	if `pval' < .05 {
		local stars = "**"
	}
	if `pval' < .01 {
		local stars = "***"
	} 
qui putexcel N16 = `pval' 
qui putexcel O16 = ("`stars'") 

************************************PHASE 2*************************************
********************************************************************************

orth_out `balance_var' ///
			if phase==2, ///
				by(treatment)  vce(robust)   bdec(3)  count
				
qui putexcel P5=matrix(r(matrix)) 
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve	
	local stars = ""
	qui replace treatment=. if treatment==3	
	qui ttest `var' if phase==2, by(treatment) unequal	
	local vp=round(r(p),.01)
	qui putexcel R`i'=(`vp') 
	if `vp' < .1 {
		local stars = "*"
	}
	if `vp' < .05 {
		local stars = "**"
	}
	if `vp' < .01 {
		local stars = "***"
	}
	qui putexcel S`i'=("`stars'") 
	local i=`i'+1
	restore
	}	

reg treatment `balance_var' if phase==2
local pval = Ftail(e(df_m), e(df_r), e(F))
	if `pval' < .1 {
		local stars = "*"
	}
	if `pval' < .05 {
		local stars = "**"
	}
	if `pval' < .01 {
		local stars = "***"
	} 
qui putexcel R16 = `pval' 
qui putexcel S16 = ("`stars'") 
	
************************************PHASE 1/2***********************************
********************************************************************************

orth_out `balance_var' if treatment!=3,  ///
				by(treatment)  vce(robust)   bdec(3)  count
				
qui putexcel T5=matrix(r(matrix)) 
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve	
	local stars = ""
	qui replace treatment=. if treatment==3	
	qui ttest `var', by(treatment) unequal		
	local vp=round(r(p),.01)
	qui putexcel V`i'=(`vp') 
	if `vp' < .1 {
		local stars = "*"
	}
	if `vp' < .05 {
		local stars = "**"
	}
	if `vp' < .01 {
		local stars = "***"
	}
	qui putexcel W`i'=("`stars'") 
	local i=`i'+1
	restore
	
	}	

reg treatment `balance_var'
local pval = Ftail(e(df_m), e(df_r), e(F))
	if `pval' < .1 {
		local stars = "*"
	}
	if `pval' < .05 {
		local stars = "**"
	}
	if `pval' < .01 {
		local stars = "***"
	} 
qui putexcel V16 = `pval' 
qui putexcel W16 = ("`stars'") 
	
