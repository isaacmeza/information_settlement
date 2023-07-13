
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	time_hearing_balance
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta

* Files created:  
		- time_hearing_balance.csv

* Purpose: This table assess balance in covariates for the distinct times of hearing, which is the variable we use as instrument for employee presence in the control function.

*******************************************************************************/
*/

* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase  trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley 
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use ".\DB\phase_1.dta" , clear	
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase  trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley 
append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if (renglon==1 & inlist(phase,1,2)) | phase==3

********************************************************************************

*Treatment var
gen calculadora=treatment-1 if inlist(phase,1,2)


*Controls
gen anioControl=anio
replace anioControl=2010 if anio<2010
replace numActores=3 if numActores>3
tab time_hr, gen(time_hr)

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 


********************************************************************************


local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley 

eststo clear
foreach var of varlist `balance_var' {
	eststo : reg `var' i.time_hr, vce(cluster cluster_v)
	test 2.time_hr==3.time_hr==4.time_hr==5.time_hr==6.time_hr==7.time_hr==8.time_hr=0
	estadd scalar Fpval = `r(p)'
}
 
*Save results	
esttab using "$directorio/Tables/appendix/c/time_hearing_balance.csv", se r2 ${star} b(a3) ///
		scalars("Fpval F p-value") replace 
