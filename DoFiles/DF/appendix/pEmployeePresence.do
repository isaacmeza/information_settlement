/*Table C17: Employee presence*/
/*
OLS of employee presence against basic variable controls as predictors.
*/

********************************************************************************

use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Age
gen age=year(date(c(current_date),"DMY"))-edad

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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
	gen age ///
	  trabajador_base ///
	c_antiguedad salario_diario horas_sem
gen phase=2
tempfile temp_p2
save `temp_p2'

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment


keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
	gen   ///
	  trabajador_base ///
	c_antiguedad salario_diario horas_sem
append using `temp_p2'
replace phase=1 if missing(phase)


*Follow-up (more than 5 months)
merge m:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
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


eststo clear


**********************************
*			PHASE 1				 *
**********************************


qui reg p_actor gen  ///
	  trabajador_base ///
	c_antiguedad salario_diario horas_sem if phase==1, robust 
test gen=trabajador_base=c_antiguedad=salario_diario=horas_sem 
	local p_val=`r(p)'
	
eststo: reg p_actor gen  ///
	abogado_pub  trabajador_base ///
	c_antiguedad salario_diario horas_sem if phase==1, robust 
	estadd scalar Erre=e(r2)
	qui su p_actor if e(sample)
	estadd scalar DepVarMean=r(mean)
	test gen=abogado_pub=trabajador_base=c_antiguedad=salario_diario=horas_sem 
	estadd scalar p_val=r(p)
	estadd scalar p_val_2=`p_val'

	
**********************************
*			PHASE 2				 *
**********************************
		

qui reg p_actor gen age ///
	  trabajador_base ///
	c_antiguedad salario_diario horas_sem if phase==2, robust 
test gen=trabajador_base=c_antiguedad=salario_diario=horas_sem 
	local p_val=`r(p)'
	
eststo: reg p_actor gen age ///
	abogado_pub  trabajador_base ///
	c_antiguedad salario_diario horas_sem if phase==2, robust 
	estadd scalar Erre=e(r2)
	qui su p_actor if e(sample)
	estadd scalar DepVarMean=r(mean)
	test gen=abogado_pub=trabajador_base=c_antiguedad=salario_diario=horas_sem 
	estadd scalar p_val=r(p)
	estadd scalar p_val_2=`p_val'
	

**********************************
*			PHASE 1/2			 *
**********************************
	
	
qui reg p_actor gen  ///
	  trabajador_base ///
	c_antiguedad salario_diario horas_sem, robust 
test gen=trabajador_base=c_antiguedad=salario_diario=horas_sem 
	local p_val=`r(p)'
	
eststo: reg p_actor gen  ///
	abogado_pub  trabajador_base ///
	c_antiguedad salario_diario horas_sem, robust 
	estadd scalar Erre=e(r2)
	qui su p_actor if e(sample)
	estadd scalar DepVarMean=r(mean)
	test gen=abogado_pub=trabajador_base=c_antiguedad=salario_diario=horas_sem 
	estadd scalar p_val=r(p)
	estadd scalar p_val_2=`p_val'	
	
	
esttab using ".\Tables\reg_results\pactor_reg.csv", se star(* 0.1 ** 0.05 *** 0.01)  b(3)  ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "p_val p_val" "p_val_2 p_val_2") replace 
	
