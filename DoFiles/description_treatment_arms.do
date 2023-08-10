
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	description_treatment_arms
* Author: Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta
		- phase_3.dta
* Files created:  
		- description_treatment_arms.xlsx
* Purpose: Get basic statistics for pilot description table

*******************************************************************************/
*/


* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	

*Calculate things and write table
putexcel set "./Tables/description_treatment_arms.xlsx", modify sheet("description_treatment_arms")

count
local num = `r(N)'
putexcel D2 = (`num')
count if treatment == 2
putexcel E2 = (`r(N)')
sum fecha, f
local fechaMin: disp %tdDD/NN/CCYY r(min)
local fechaMax: disp %tdDD/NN/CCYY r(max)
putexcel K2 = ("`fechaMin'")
putexcel L2 = ("`fechaMax'")


* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear

count
putexcel D3 = (`r(N)')
count if treatment == 2
putexcel E3 = (`r(N)')
sum fecha, f
local fechaMin: disp %tdDD/NN/CCYY r(min)
local fechaMax: disp %tdDD/NN/CCYY r(max)
putexcel K3 = ("`fechaMin'")
putexcel L3 = ("`fechaMax'")


* Phase 3
********************************************************************************
use "./DB/phase_3.dta", clear

gen calculadora = main_treatment
replace calculadora = . if main_treatment==3
drop if missing(calculadora)

count
local num = `r(N)'
putexcel D4 = (`num')
count if calculadora == 2
putexcel E4 = (`r(N)')
sum fecha_alta, f
local fechaMin: disp %tdDD/NN/CCYY r(min)
local fechaMax: disp %tdDD/NN/CCYY r(max)
putexcel K4 = ("`fechaMin'")
putexcel L4 = ("`fechaMax'")


