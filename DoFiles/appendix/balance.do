/*Table C6:  Balance table*/
/*
Balance table on basic and strategic variables.
*/

********************************************************************************

use "$scaleup\DB\scaleup_operation.dta", clear
duplicates drop junta exp ao, force
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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

gen phase=2
tempfile temp_p2
save `temp_p2'

**************

use "$sharelatex/DB/pilot_operation.dta" , clear
duplicates drop folio, force
merge m:1 folio  using ///
	"$sharelatex\DB\pilot_casefiles_wod.dta", keep(1 3)
drop _merge	
replace junta=7 if missing(junta)

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

*Homologation
rename p_demandado p_dem
rename p_rdemandado p_rdem

append using `temp_p2', force
replace phase=1 if missing(phase)


local balance_var gen trabajador_base	horas_sem c_antiguedad abogado_pub	reinst	indem	salario_diario	sal_caidos	prima_antig	hextra	rec20  prima_dom  desc_sem  desc_ob sarimssinf utilidades nulidad min_ley p_actor p_ractor p_dem p_rdem

************************************PHASE 1*************************************
********************************************************************************


orth_out `balance_var' ///
			if phase==1, ///
				by(treatment)  vce(robust)   bdec(3)  count
				
qui putexcel L5=matrix(r(matrix)) using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve	
	qui replace treatment=. if treatment==3	
	qui ttest `var' if phase==1, by(treatment) unequal		
	local vp=round(r(p),.01)
	qui putexcel O`i'=(`vp') using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
	restore
	
	
	*3 vs 1
	preserve	
	qui replace treatment=. if treatment==2	
	qui ttest `var' if phase==1, by(treatment) unequal		
	local vp=round(r(p),.01)
	qui putexcel Q`i'=(`vp') using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
	restore	

	local i=`i'+1
	}	

	

************************************PHASE 2*************************************
********************************************************************************


orth_out `balance_var' ///
			if phase==2, ///
				by(treatment)  vce(robust)   bdec(3)  count
				
qui putexcel S5=matrix(r(matrix)) using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve	
	qui replace treatment=. if treatment==3	
	qui ttest `var' if phase==2, by(treatment) unequal	
	local vp=round(r(p),.01)
	qui putexcel U`i'=(`vp') using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
	restore
	
	local i=`i'+1
	}	

	
************************************PHASE 1/2***********************************
********************************************************************************


orth_out `balance_var' if treatment!=3,  ///
				by(treatment)  vce(robust)   bdec(3)  count
				
qui putexcel W5=matrix(r(matrix)) using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve	
	qui replace treatment=. if treatment==3	
	qui ttest `var', by(treatment) unequal		
	local vp=round(r(p),.01)
	qui putexcel Y`i'=(`vp') using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
	restore
	
	local i=`i'+1
	}	
	
	
