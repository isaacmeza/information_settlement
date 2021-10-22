/*Table C7:  Balance regression on characteristics conditional on employee present*/
/*
The table shows results of regressions with the specification 
$y_i = \alpha_t + \sum_{j = 1,2}\beta_{j} T_{j} + \epsilon_{i}$, 
where j refers to the treatment assignment ${calculator, conciliator}$.
*/
********************************************************************************

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

keep seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor ///
abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem abogado_pub ///
junta exp anio
gen phase=2
tempfile temp_p2
save `temp_p2'

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
ren expediente exp
keep seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor ///
abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem abogado_pub ///
junta exp anio
append using `temp_p2'
replace phase=1 if missing(phase)

*keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment ///
*p_actor abogado_pub fechadem

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
drop if T1T2==1 & treatment == 1
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

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

*Drop conciliator observations
drop if treatment==3


********************************************************************************

*CONDITIONAL ON EP
keep if p_actor==1


tab junta, gen(junta)

for var abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem junta1-junta5: egen Xs=std(X)

local bvc abogado_pub gens trabajador_bases c_antiguedads salario_diarios horas_sems

	
	
foreach var of varlist `bvc' {	
	reg `var' i.treatment junta2s-junta5s if treatment!=0, robust  cluster(fecha)
	//estadd scalar Erre=e(r2)	
	//estadd scalar F_stat=e(F)
	qui test 2.treatment = 0 
	local pval = `r(p)'
	estadd local Junta="YES"
	if "`var'" == "abogado_pub"{
	outreg2 using ".\Tables\reg_results\ep_balance.xls", replace ctitle("`var'") ///
	addstat(treatment=0, `pval')  keep(2.treatment)  dec(3)
	} 
	else {
	    outreg2 using ".\Tables\reg_results\ep_balance.xls", append ctitle("`var'") ///
	addstat(treatment=0, `pval')  keep(2.treatment)
	}
	}

		

