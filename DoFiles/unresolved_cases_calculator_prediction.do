
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	unresolved_cases_calculator_prediction
* Author: Isaac M & Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta
* Files created:  

* Purpose: This figure presents the distribution of recovery amounts predicted by the calculator, conditional on winning a judgment, for treatment and control cases that were unresolved at the time of last data access. 
*******************************************************************************/
*/

* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear
keep liq_total_laudo modoTermino treatment junta exp anio fecha phase
tempfile p2
save `p2'

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	
keep liq_total_laudo modoTermino treatment junta exp anio fecha phase

append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

********************************************************************************

*******************************
* 		 	 PDF	    	  *
*******************************

twoway (kdensity liq_total_laudo if treatment==2 & liq_total_laudo<650000 & modoTermino==2 ,  lwidth(medthick) lpattern(solid) color(black)) ///
		(kdensity liq_total_laudo if treatment==1 & liq_total_laudo<650000 & modoTermino==2 , lpattern(dash) lcolor(gs10) lwidth(medthick)) ///
		, legend(lab(1 "Treatment") lab(2 "Control") rows(1) pos(6)) xtitle("Calculator Predicted Amounts for Court Win") ytitle("kdensity") graphregion(color(white)) ylabel(0 (0.000006) 0.000006)
graph export "./Figures/Calculator_CourtWin_Unresolved.tif", replace 





















