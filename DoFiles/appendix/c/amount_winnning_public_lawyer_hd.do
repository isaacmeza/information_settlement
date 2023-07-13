
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	amount_winnning_public_lawyer_hd
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- scaleup_hd.dta

* Files created:  
		- amount_winnning_public_lawyer_hd.csv

* Purpose: This table shows OLS regressions of log total amount asked in the initial labor 
suit, the amount actually won, the ratio of these two, and the probability of 
the worker recovering a positive amount.

*******************************************************************************/
*/

use  ".\DB\scaleup_hd.dta", clear 

*We define win as liq_total>0
gen win=(liq_total>0)*100

*Ratio amount won/amount asked
gen won_asked=liq_total/c_total 

*Amount won on log
replace liq_total=1 if liq_total==0
replace liq_total=log(liq_total)

*Total asked in log
replace c_total=1 if c_total==0
replace c_total=log(c_total)

*Tenure | Daily wage | Weekle hours in logs
foreach var of varlist c_antiguedad salario_diario horas_sem {
	replace `var'=1 if `var'==0
	replace `var'=log(`var')
	}

/***********************
       REGRESSIONS
************************/

eststo clear

********************************* ALL CASES ***********************************
foreach var of varlist c_total liq_total won_asked win {
	eststo: areg `var' abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem, absorb(giro_empresa) robust
	su `var' 
	estadd scalar DepVarMean=r(mean)
}

********************************* SETTLEMENT ***********************************
foreach var of varlist c_total liq_total won_asked win {
	eststo: areg `var' abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem if modo_termino==1, absorb(giro_empresa) robust
	su `var' 
	estadd scalar DepVarMean=r(mean)
}

********************************* COURT RULING *********************************
foreach var of varlist c_total liq_total won_asked win {
	eststo: areg `var' abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem if modo_termino==3, absorb(giro_empresa) robust
	su `var' 
	estadd scalar DepVarMean=r(mean)
}

********************************************************************************
esttab using "$directorio/Tables/appendix/c/amount_winnning_public_lawyer_hd.csv", se r2 ${star} b(a2) keep(abogado_pub) scalars("DepVarMean DepVarMean") replace 
		

