
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	settlement_amount_calculator
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: October. 25, 2021  
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta

* Files created:  


* Purpose: This figure presents the distribution of actual settlement amount over the calculator prediction

*******************************************************************************/
*/

* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear
keep fecha junta exp anio fecha treatment phase ganancia liq_total_convenio modoTermino abogado_pub
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use ".\DB\phase_1.dta" , clear	
keep fecha junta exp anio fecha treatment phase ganancia liq_total_convenio modoTermino abogado_pub
append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if (renglon==1 & inlist(phase,1,2)) | phase==3

********************************************************************************

gen ratioGananciaConvenio = ganancia/liq_total_convenio


*Graph only lower 95%;
twoway (kdensity ratioGananciaConvenio if treatment==2 & ratioGananciaConvenio<3.5 & modoTermino==3 & abogado_pub==0,  lwidth(medthick) lpattern(solid) color(black)) ///
	   (kdensity ratioGananciaConvenio if treatment==1 & ratioGananciaConvenio<3.5 & modoTermino==3 & abogado_pub==0, lpattern(dash) lcolor(gs10) lwidth(medthick)), ///
		legend(lab(1 "Treatment") lab(2 "Control") rows(1) pos(6)) xtitle("Ratio of Amounts")  graphregion(color(white)) ytitle("Density")
graph export ".\Figures\appendix\c\settlement_amount_calculator.tif", replace
