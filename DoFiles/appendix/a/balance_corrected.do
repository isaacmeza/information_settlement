/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M & Sergio Lopez
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: November. 9, 2021  
* Modifications: Outlier removal		
* Files used:     
		- 
* Files created:  

* Purpose: Balance table on basic and strategic variables.

*******************************************************************************/
*/

local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley p_actor p_ractor p_dem p_rdem


use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0
rename convenio seconcilio
rename convenio_seg_2m convenio_2m 
rename convenio_seg_5m convenio_5m
gen fecha=date(fecha_lista,"YMD")
format fecha %td
foreach var in salario_diario min_ley{
	bysort `var': gen r`var' = _n
}
keep junta exp anio fecha treatment `balance_var'
gen phase=2
tempfile p2
save `p2', replace


use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

merge m:1 junta exp anio using ".\DB\inicialesP1Faltantes_wod.dta", ///
keep(1 3) gen(_mNuevasIniciales) keepusing(abogado_pubN numActoresN)
//keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M numActoresN)

//gen fechaDemanda = date(fecha, "YMD")
gen fechaDemanda = fecha

foreach var in numActores abogado_pub{
replace `var' = `var'N if missing(`var') & !missing(`var'N)
}

rename p_demandado p_dem
rename p_rdemandado p_rdem
foreach var in salario_diario min_ley{
	bysort `var': gen r`var' = _n
}
keep junta exp anio fecha treatment `balance_var'
append using  `p2'
replace phase=1 if missing(phase)

********************************************************************************

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

*Follow-up (more than 5 months)
merge 1:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen keep(1 3)
merge 1:1 junta exp anio using ".\DB\followUps2020.dta", gen(merchados) keep(1 3)

//local balance_var gen trabajador_base horas_sem c_antiguedad abogado_pub reinst indem salario_diario sal_caidos prima_antig hextra rec20  prima_dom  desc_sem  desc_ob sarimssinf utilidades nulidad min_ley p_actor p_ractor p_dem p_rdem
//local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley p_actor p_ractor p_dem p_rdem
************************************PHASE 1*************************************
********************************************************************************

/*
cap drop out
bacon salario_diario min_ley c_antiguedad  if phase==1, generate(out) percentile(1)

su salario_diario min_ley c_antiguedad if phase==1 & out==1
tab treatment if out==1

drop if out==1
*/


putexcel set ".\paper\Tables\Balance2.xlsx", sheet("Balance") modify
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
	
