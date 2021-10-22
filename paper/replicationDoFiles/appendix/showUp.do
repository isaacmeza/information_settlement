/*Table C5:  Compliance Rate - Panel (c)*/
/*
Shows from the court's administrative data who shows up to the hearings
for each of the two phases, split by employee, employee lawyer, and firm lawyer.
*/

********************************************************************************
********************************************************************************
*									PILOT									   *
********************************************************************************
********************************************************************************

use ".\DB\pilot_operation.dta", clear

drop if tratamientoquelestoco==0
gen exp = expediente
gen treatment = tratamientoquelestoco
drop renglon

********************************************************************************

bysort exp anio: gen DuplicatesPredrop=_N
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

bysort exp anio: gen DuplicatesPostdrop=_N

********************************************************************************
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1
putexcel set "./Tables/show_up.xlsx", sheet("show_up") modify

local r=3
levelsof tratamientoquelestoco if tratamientoquelestoco!=0, local(levels)
foreach l of local levels {  
	
	if `l'==1 {
		local Col="H"
		}
	if `l'==2 {
		local Col="I"
		}	
	if `l'==3 {
		local Col="J"
		}
		

	local rr=4
	
	foreach var of varlist p_actor p_ractor p_rdem {
	
		qui su `var' if tratamientoquelestoco==`l'
		qui putexcel `Col'`rr'=(r(mean)) 
		local rr=`rr'+1
		
		}
	local r=`r'+1	
	}

	
	
	
	
********************************************************************************
********************************************************************************
*									ScaleUP									   *
********************************************************************************
********************************************************************************

use ".\DB\scaleup_operation.dta", clear
putexcel set "./Tables/show_up.xlsx", sheet("show_up") modify


local r=3
levelsof tratamiento, local(levels)
foreach l of local levels {  
	
	if `l'==0 {
		local Col="K"
		}
	if `l'==1 {
		local Col="L"
		}	
	
		

	local rr=4
	
	foreach var of varlist p_actor p_ractor p_rdem {
	
		qui su `var' if tratamiento==`l'
		qui putexcel `Col'`rr'=(r(mean)) 
		local rr=`rr'+1
		
		}
	local r=`r'+1	
	}
