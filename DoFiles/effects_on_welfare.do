
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	effects_on_welfare
* Author: Isaac M 
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_3.dta
* Files created:  
		- welfare_reg_2m.csv
* Purpose: Phase 3: Effects on welfare

*******************************************************************************/
*/

use ".\DB\phase_3.dta", clear
duplicates drop id_actor, force
drop if main_treatment==3

local welfare_vars nivel_de_felicidad ultimos_3_meses_ha_dejado_de_pag ultimos_3_meses_le_ha_faltado_di  trabaja_actualmente 
local controls gen c_antiguedad salario_diario


*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear

foreach var of varlist `welfare_vars' {
	eststo: reg `var' i.main_treatment `controls', vce(cluster fecha_alta)
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)
	}
	
	*************************
esttab using "$directorio/Tables/effects_on_welfare.csv", se r2 ${star} b(a2) ///
		keep(2.main_treatment) scalars("DepVarMean DepVarMean") replace 
		