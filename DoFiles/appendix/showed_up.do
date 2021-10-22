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

use "$sharelatex\DB\pilot_operation.dta", clear


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
		qui putexcel `Col'`rr'=(r(mean)) using "$sharelatex/Tables/show_up.xlsx", sheet("show_up") modify
		local rr=`rr'+1
		
		}
	local r=`r'+1	
	}

	
	
	
	
********************************************************************************
********************************************************************************
*									ScaleUP									   *
********************************************************************************
********************************************************************************

use "$scaleup\DB\scaleup_operation.dta", clear



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
		qui putexcel `Col'`rr'=(r(mean)) using "$sharelatex/Tables/show_up.xlsx", sheet("show_up") modify
		local rr=`rr'+1
		
		}
	local r=`r'+1	
	}
