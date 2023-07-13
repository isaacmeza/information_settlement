
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	case_outcomes_treatment_arm
* Author: Isaac M & Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- 
* Files created:  

* Purpose: Case outcomes by treatment arm

*******************************************************************************/
*/

* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear
keep treatment modoTermino payment junta exp anio fecha phase
tempfile temp_p2
save `temp_p2'

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear		
keep treatment modoTermino payment junta exp anio fecha phase
append using `temp_p2' 

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

********************************************************************************

*Subdivide court-ruling by sign of payment
replace modoTermino = 7 if modoTermino==6 & missing(payment) | payment == 0
replace modoTermino = 1 if modoTermino == 4

label define finales 1 "Expired / dropped" 2 "Continues" 3 "Settled" 4 "Dropped" 5 "" 6 "Court ruling with payment" 7 "Court ruling without payment", modify
label val modoTermino finales
********************************************************************************

*Follow-up (more than 5 months)

tab modoTermino treatment if (modoTermino != 5 & modoTermino != 4), matcell(valores)
putexcel set ".\Tables\case_outcomes_treatment_arm.xlsx", mod sheet("case_outcomes_treatment_arm")

putexcel C1 = ("Control") D1 = ("Calculator")
putexcel B2 =("Expired / Dropped") B3 = ("Continues") B4 = ("Settled") B5 = ("Court ruling with payment") B6 = ("Court ruling without payment")
putexcel C2 = matrix(valores)

	