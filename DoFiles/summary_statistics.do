
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	summary_statistics
* Author: Isaac Meza & Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- scaleup_hd.dta
		- phase_1.dta
		- phase_2.dta
		- phase_3.dta
* Files created:  
		- SS.xlsx
* Purpose: Summary statistics table for Outcomes, Basic and Strategic variables for the 3 pilots

*******************************************************************************/
*/

********************************************************************************
	*DB: HD:5005
use  "./DB/scaleup_hd.dta", clear

*We define win as liq_total>0
gen win=(liq_total>0)
*Settlememt
gen con=(modo_termino==1)
*Court ruling
gen cr_0=(modo_termino==3 & liq_total==0)
gen cr_m=(modo_termino==3 & liq_total>0)


foreach var in liq_total c_total {
	replace `var' = `var'/1000
	} 
	

*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  {
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	 
	qui putexcel B`n'=(r(N))  
	*Mean
	 
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'") 		
	*Std Dev
	 
	local std=round(r(sd),0.01)
	local sd="(`std')"
	
	qui putexcel C`m'=("`sd'") 		
	*Range
	local range="[`r(min)', `r(max)']"
	 
	qui putexcel D`n'=("`range'")		

	local n=`n'+2
	local m=`m'+2
	}

	

*PANEL B (Basic)
local n=5
local m=6
putexcel set  "./Tables/SS.xlsx", sheet("PanelB") modify
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem {
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel B`n'=(r(N))		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")			
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")
		
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel D`n'=("`range'")
		
	local n=`n'+2
	local m=`m'+2
	}
	

********************************************************************************
	*DB: Subcourt 7 
keep if junta==7
	

*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelA") modify	
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  {
	qui su `var'

	*Obs
	qui putexcel H`n'=(r(N))  
		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'") 		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")		
		
	local n=`n'+2
	local m=`m'+2
	}


	
*PANEL B (Basic)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem  {
	qui su `var'

	*Obs
	qui putexcel H`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'")  		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'")  		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")	
		
	local n=`n'+2
	local m=`m'+2
	}
	

********************************************************************************
	*DB: Phase 1
use "./DB/phase_1.dta", clear

*Generate missing variables
foreach var in ///
	win liq_total c_total convenio_5m cr_0 cr_m  ///
	abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem {
		capture confirm variable  `var'
		if !_rc {
               qui di ""
               }
        else {
               gen `var'=.
               }
	}	
foreach var in liq_total c_total {
	replace `var' = `var'/1000
	} 

	
*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total convenio_5m cr_0 cr_m  {
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel E`n'=(r(N))  		
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'") 		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'")  
		
	local n=`n'+2
	local m=`m'+2
	}

	
	
*PANEL B (Basic)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem  {
	qui su `var'
	
	*Obs
	qui putexcel E`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'")  		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'") 
	
	local n=`n'+2
	local m=`m'+2
	}
	

********************************************************************************
	*DB: Phase2
use "./DB/phase_2.dta", clear

*Generate missing variables
foreach var in ///
	win liq_total c_total seconcilio cr_0 cr_m  ///
	abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem {
		capture confirm variable  `var'
		if !_rc {
               qui di ""
               }
        else {
               gen `var'=.
               }
	}	


*PANEL A (Outcomes)
local n=5
local m=6
foreach var in c_total {
		replace `var' = `var'/1000
		} 
		
		
putexcel set "./Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total seconcilio cr_0 cr_m {
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel K`n'=(r(N)) 		
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'") 		
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'")	
		
	local n=`n'+2
	local m=`m'+2
	}


	
*PANEL B (Basic)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem {
	qui su `var'
	
	*Obs
	qui putexcel K`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'") 		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'")
		
	local n=`n'+2
	local m=`m'+2
	}
	

********************************************************************************
	*DB: Phase3
use "./DB/phase_3.dta", clear
drop if missing(main_treatment) | main_treatment == 3

*Generate missing variables
foreach var in ///
	win liq_total c_total doble_convenio cr_0 cr_m  ///
	abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem {
		capture confirm variable  `var'
		if !_rc {
               qui di ""
               }
        else {
               gen `var'=.
               }
	}	


*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total doble_convenio cr_0 cr_m {
	 su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel N`n'=(r(N)) 		
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel O`n'=("`mu'")		
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel O`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel P`n'=("`range'")		
		
	local n=`n'+2
	local m=`m'+2
	}


	
*PANEL B (Basic)
local n=5
local m=6
putexcel set "./Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem  {
	qui su `var'
	
	*Obs
	qui putexcel N`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel O`n'=("`mu'")  		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel O`m'=("`sd'")  		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel P`n'=("`range'") 
	
	local n=`n'+2
	local m=`m'+2
	}
